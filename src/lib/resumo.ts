import type { SupabaseClient } from "@supabase/supabase-js";
import { diasPendentes, lerNumero } from "./frota/consumo";
import { hojeBahia, somarDias } from "./frota/dados";
import { EM_ABERTO, totalOS, type Compra, type Situacao } from "./frota/os";
import type { Usina } from "./tipos";

/* Números do Início e do Painel de Gestão. Tudo respeita as regras do banco (cada um vê só as suas usinas). */

export type BoletimHoje = {
  usina: Usina;
  inicio: string | null;
  hoje: "fechado" | "aberto" | "pendente";
  atrasados: string[]; // dias antes de hoje sem fechamento
};

export async function situacaoBoletins(supabase: SupabaseClient, usinas: Usina[]): Promise<BoletimHoje[]> {
  if (!usinas.length) return [];
  const ids = usinas.map((u) => u.id);
  const hoje = hojeBahia();
  const [parRes, bolRes] = await Promise.all([
    supabase.from("parametro").select("usina_id, valor").eq("chave", "inicio_boletim").in("usina_id", ids),
    supabase.from("boletim").select("usina_id, data, status").in("usina_id", ids).eq("origem", "lancado").gte("data", somarDias(hoje, -120)),
  ]);
  return usinas.map((u) => {
    const inicio = (parRes.data ?? []).find((p) => p.usina_id === u.id)?.valor;
    const meus = (bolRes.data ?? []).filter((b) => b.usina_id === u.id);
    const fechados = new Set(meus.filter((b) => b.status === "fechado").map((b) => b.data as string));
    const deHoje = meus.find((b) => b.data === hoje);
    return {
      usina: u,
      inicio: typeof inicio === "string" ? inicio : null,
      hoje: deHoje?.status === "fechado" ? "fechado" : deHoje ? "aberto" : "pendente",
      atrasados: typeof inicio === "string" ? diasPendentes(inicio, hoje, fechados) : [],
    };
  });
}

export type OSResumo = { id: string; usina_id: string; numero: string; status: Situacao; abertura: string | null; descricao: string | null; ativo: string };

export async function osEmAberto(supabase: SupabaseClient, usinas: Usina[], limite = 6) {
  if (!usinas.length) return { total: 0, aguardandoPeca: 0, lista: [] as OSResumo[] };
  const ids = usinas.map((u) => u.id);
  const { data } = await supabase
    .from("ordem_servico")
    .select("id, usina_id, numero, status, abertura, descricao, ativo_texto, ativo(codigo)")
    .in("usina_id", ids)
    .in("status", EM_ABERTO)
    .order("abertura", { ascending: true });
  const rows = (data ?? []) as unknown as (Omit<OSResumo, "ativo"> & { ativo_texto: string | null; ativo: { codigo: string } | null })[];
  return {
    total: rows.length,
    aguardandoPeca: rows.filter((r) => r.status === "Aguardando peça").length,
    lista: rows.slice(0, limite).map((r) => ({ ...r, ativo: r.ativo?.codigo ?? r.ativo_texto ?? "—" })),
  };
}

/* ---------------- Painel de Gestão: o mês ---------------- */

export type LinhaVeiculo = { codigo: string; tipo: string; litros: number; m3: number; lm3: number | null; diesel: number };
export type DiaProducao = { data: string; m3: number };

export type ResumoMes = {
  mes: string; // AAAA-MM
  m3: number;
  m3Anterior: number;
  litros: number;
  litrosAnterior: number;
  diesel: number; // R$
  lm3: number | null;
  lm3Anterior: number | null;
  manutencao: number; // R$ das OS concluídas no mês
  manutencaoAnterior: number;
  osConcluidas: number;
  osAbertas: number;
  aguardandoPeca: number;
  dias: DiaProducao[];
  veiculos: LinhaVeiculo[];
  porUsina: { codigo: string; m3: number; litros: number; manutencao: number }[];
};

const primeiroDia = (ym: string) => `${ym}-01`;
function mesAnterior(ym: string) {
  const [a, m] = ym.split("-").map(Number);
  return m === 1 ? `${a - 1}-12` : `${a}-${String(m - 1).padStart(2, "0")}`;
}
function ultimoDia(ym: string) {
  const [a, m] = ym.split("-").map(Number);
  return `${ym}-${String(new Date(Date.UTC(a, m, 0)).getUTCDate()).padStart(2, "0")}`;
}

type ItemBanco = { ativo_id: string; m3: number | null; litros: number | null; valor: number | null };

export async function resumoMes(supabase: SupabaseClient, usinas: Usina[], ym = hojeBahia().slice(0, 7)): Promise<ResumoMes> {
  const ids = usinas.map((u) => u.id);
  const ant = mesAnterior(ym);
  const desde = primeiroDia(ant);
  const ate = ultimoDia(ym);

  const [ativosRes, bolRes, osRes] = await Promise.all([
    supabase.from("ativo").select("id, codigo, tipo, usina_id").in("usina_id", ids),
    supabase.from("boletim").select("usina_id, data, boletim_item(ativo_id, m3, litros, valor)").in("usina_id", ids).gte("data", desde).lte("data", ate),
    supabase.from("ordem_servico").select("usina_id, status, termino, valor, compras").in("usina_id", ids).or(`status.in.(${EM_ABERTO.map((s) => `"${s}"`).join(",")}),termino.gte.${desde}`),
  ]);

  const ativos = new Map((ativosRes.data ?? []).map((a) => [a.id as string, a as { id: string; codigo: string; tipo: string; usina_id: string }]));
  const central = (id: string) => ativos.get(id)?.tipo === "Central de concreto";
  const codigoUsina = new Map(usinas.map((u) => [u.id, u.codigo]));

  const r: ResumoMes = {
    mes: ym, m3: 0, m3Anterior: 0, litros: 0, litrosAnterior: 0, diesel: 0, lm3: null, lm3Anterior: null,
    manutencao: 0, manutencaoAnterior: 0, osConcluidas: 0, osAbertas: 0, aguardandoPeca: 0, dias: [], veiculos: [], porUsina: [],
  };
  const porDia = new Map<string, number>();
  const porVeiculo = new Map<string, LinhaVeiculo>();
  const porUsina = new Map<string, { codigo: string; m3: number; litros: number; manutencao: number }>();
  for (const u of usinas) porUsina.set(u.id, { codigo: u.codigo, m3: 0, litros: 0, manutencao: 0 });

  for (const b of bolRes.data ?? []) {
    const doMes = (b.data as string).startsWith(ym);
    for (const i of (b.boletim_item ?? []) as ItemBanco[]) {
      const m3 = lerNumero(i.m3) ?? 0;
      const litros = lerNumero(i.litros) ?? 0;
      if (central(i.ativo_id)) {
        if (doMes) {
          r.m3 += m3;
          porDia.set(b.data, (porDia.get(b.data) ?? 0) + m3);
          porUsina.get(b.usina_id)!.m3 += m3;
        } else r.m3Anterior += m3;
        continue;
      }
      if (!doMes) {
        r.litrosAnterior += litros;
        continue;
      }
      r.litros += litros;
      r.diesel += lerNumero(i.valor) ?? 0;
      porUsina.get(b.usina_id)!.litros += litros;
      const a = ativos.get(i.ativo_id);
      if (!a || (!litros && !m3)) continue;
      const rotulo = usinas.length > 1 ? `${codigoUsina.get(a.usina_id)} · ${a.codigo}` : a.codigo;
      const v = porVeiculo.get(a.id) ?? { codigo: rotulo, tipo: a.tipo, litros: 0, m3: 0, lm3: null, diesel: 0 };
      v.litros += litros;
      v.m3 += m3;
      v.diesel += lerNumero(i.valor) ?? 0;
      porVeiculo.set(a.id, v);
    }
  }
  r.lm3 = r.m3 ? r.litros / r.m3 : null;
  r.lm3Anterior = r.m3Anterior ? r.litrosAnterior / r.m3Anterior : null;

  for (const o of (osRes.data ?? []) as { usina_id: string; status: Situacao; termino: string | null; valor: number | null; compras: Compra[] }[]) {
    if (EM_ABERTO.includes(o.status)) {
      r.osAbertas++;
      if (o.status === "Aguardando peça") r.aguardandoPeca++;
      continue;
    }
    if (o.status !== "Concluída" || !o.termino) continue;
    const valor = totalOS({ valor: o.valor, compras: Array.isArray(o.compras) ? o.compras : [] });
    if (o.termino.startsWith(ym)) {
      r.osConcluidas++;
      r.manutencao += valor;
      porUsina.get(o.usina_id)!.manutencao += valor;
    } else if (o.termino.startsWith(ant)) r.manutencaoAnterior += valor;
  }

  // todos os dias do mês até hoje, para o gráfico não pular dias sem produção
  const ultimo = ym === hojeBahia().slice(0, 7) ? hojeBahia() : ate;
  for (let d = primeiroDia(ym); d <= ultimo; d = somarDias(d, 1)) r.dias.push({ data: d, m3: porDia.get(d) ?? 0 });
  r.veiculos = [...porVeiculo.values()]
    .map((v) => ({ ...v, lm3: v.m3 ? v.litros / v.m3 : null }))
    .sort((a, b) => b.litros - a.litros);
  r.porUsina = [...porUsina.values()];
  return r;
}

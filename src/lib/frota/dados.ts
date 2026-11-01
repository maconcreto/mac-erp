import type { SupabaseClient } from "@supabase/supabase-js";
import { LIMITES_PADRAO, linhaVazia, type Ativo, type Limites, type Linha, type Registro } from "./consumo";
import { frotaDe, type Contexto } from "./regras";

const JANELA_DIAS = 180;

type LinhaBanco = Partial<Record<keyof Linha, unknown>>;

/** Linha gravada em branco (campos limpos depois de salvar) não conta como lançamento. */
export function linhaTemDados(l: Linha) {
  return l.parado || (Object.keys(l) as (keyof Linha)[]).some((k) => k !== "parado" && l[k] != null);
}

function paraLinha(r: LinhaBanco): Linha {
  const l = linhaVazia();
  (Object.keys(l) as (keyof Linha)[]).forEach((k) => {
    const v = r[k];
    if (v != null && v !== "") (l as Record<string, unknown>)[k] = v;
  });
  l.parado = r.parado === true;
  return l;
}

export function somarDias(data: string, dias: number) {
  const d = new Date(data + "T12:00:00Z");
  d.setUTCDate(d.getUTCDate() + dias);
  return d.toISOString().slice(0, 10);
}

/** Data de hoje no fuso da operação (Bahia). */
export function hojeBahia() {
  return new Intl.DateTimeFormat("sv-SE", { timeZone: "America/Bahia" }).format(new Date());
}

export type DiaBoletim = {
  contexto: Contexto;
  boletim: { id: string; status: "aberto" | "fechado"; origem: "lancado" | "importado"; sem_producao: boolean; atualizado_em: string } | null;
  linhas: Record<string, Linha>; // o que já está gravado hoje
  inicio: string | null; // início do boletim digital
  fechados: string[]; // dias já fechados no sistema (lançados aqui)
  abertos: string[]; // dias salvos parcialmente
  osAbertas: { numero: string; descricao: string | null; ativo_id: string | null }[];
};

export async function carregarDia(supabase: SupabaseClient, usinaId: string, data: string): Promise<DiaBoletim> {
  const desde = somarDias(data, -JANELA_DIAS);

  const [ativosRes, histRes, leitRes, parRes, osRes, fechRes] = await Promise.all([
    supabase
      .from("ativo")
      .select("id, codigo, tipo, grupo, usa_hora, usa_km, regra_consumo, fora_operacao, betobomba, bomba_id, data_inicio, marcos")
      .eq("usina_id", usinaId)
      .eq("ativo", true),
    supabase
      .from("boletim")
      .select(
        "id, data, status, origem, sem_producao, atualizado_em, boletim_item(ativo_id, parado, sit, sem_prod, os_ref, motorista, viagens, m3, vb, m3b, km0, km1, h0, h1, hb0, hb1, litros, preco, valor, posto, justificativa, obs)",
      )
      .eq("usina_id", usinaId)
      .gte("data", desde)
      .lte("data", data),
    supabase.from("leitura_ativo").select("ativo_id, data, horas, km").eq("usina_id", usinaId),
    supabase.from("parametro").select("usina_id, chave, valor").in("chave", ["limite_consumo_betoneira", "limite_consumo_bomba", "limite_consumo_implemento", "inicio_boletim", "posto_padrao"]),
    supabase.from("ordem_servico").select("numero, descricao, ativo_id, status").eq("usina_id", usinaId).order("numero"),
    supabase.from("boletim").select("data, status, origem").eq("usina_id", usinaId).eq("origem", "lancado"),
  ]);

  const ativos = ((ativosRes.data ?? []) as unknown as Ativo[]).map((a) => ({ ...a, marcos: Array.isArray(a.marcos) ? a.marcos : [] }));

  // parâmetros: o da usina vale mais que o geral da empresa
  const par = new Map<string, unknown>();
  for (const p of [...(parRes.data ?? [])].sort((a, b) => Number(a.usina_id != null) - Number(b.usina_id != null))) par.set(p.chave, p.valor);
  const numPar = (k: string, padrao: number) => {
    const v = Number(par.get(k));
    return Number.isFinite(v) && v > 0 ? v : padrao;
  };
  const lim: Limites = {
    betoneira: numPar("limite_consumo_betoneira", LIMITES_PADRAO.betoneira),
    bomba: numPar("limite_consumo_bomba", LIMITES_PADRAO.bomba),
    implemento: numPar("limite_consumo_implemento", LIMITES_PADRAO.implemento),
  };

  const historico = new Map<string, Registro[]>();
  let boletim: DiaBoletim["boletim"] = null;
  const linhas: Record<string, Linha> = {};
  const abertos: string[] = [];
  for (const b of histRes.data ?? []) {
    const itens = (b.boletim_item ?? []) as (LinhaBanco & { ativo_id: string })[];
    if (b.data === data) {
      boletim = { id: b.id, status: b.status, origem: b.origem, sem_producao: b.sem_producao, atualizado_em: b.atualizado_em };
      for (const i of itens) {
        const l = paraLinha(i);
        if (linhaTemDados(l)) linhas[i.ativo_id] = l;
      }
      continue;
    }
    if (b.origem === "lancado" && b.status === "aberto") abertos.push(b.data);
    for (const i of itens) {
      const lista = historico.get(i.ativo_id) ?? [];
      lista.push({ data: b.data, origem: b.origem, linha: paraLinha(i) });
      historico.set(i.ativo_id, lista);
    }
  }
  for (const rs of historico.values()) rs.sort((a, b) => a.data.localeCompare(b.data));

  const leituraBase = new Map<string, { data: string; km: number | null; horas: number | null }>();
  for (const l of leitRes.data ?? []) leituraBase.set(l.ativo_id, { data: l.data, km: l.km, horas: l.horas });

  const posto = par.get("posto_padrao");
  const inicio = par.get("inicio_boletim");

  return {
    contexto: { ativos, data, lim, historico, leituraBase, postoPadrao: typeof posto === "string" ? posto : "" },
    boletim,
    linhas,
    inicio: typeof inicio === "string" ? inicio : null,
    fechados: (fechRes.data ?? []).filter((b) => b.status === "fechado").map((b) => b.data),
    abertos: abertos.sort(),
    osAbertas: (osRes.data ?? []).filter((o) => !["Concluída", "Cancelada"].includes(o.status)).map((o) => ({ numero: o.numero, descricao: o.descricao, ativo_id: o.ativo_id })),
  };
}

export { frotaDe };

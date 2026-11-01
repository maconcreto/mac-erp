"use server";

import { revalidatePath } from "next/cache";
import { dataBr, diasPendentes, linhaVazia, type Linha } from "@/lib/frota/consumo";
import { carregarDia, hojeBahia } from "@/lib/frota/dados";
import { gestorDaUsina, podeLancarBoletim } from "@/lib/frota/permissao";
import { prepararItens } from "@/lib/frota/regras";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";

export type Modo = "parcial" | "fechar" | "sem_producao";
export type Entrada = {
  usinaId: string;
  data: string;
  modo: Modo;
  linhas: Record<string, unknown>;
  usinaM3: unknown;
};
export type Retorno = { ok?: string; erros?: string[] };

export async function salvarDia(e: Entrada): Promise<Retorno> {
  const s = await carregarSessao();
  if (!s) return { erros: ["Sua sessão expirou. Entre de novo."] };
  if (!/^\d{4}-\d{2}-\d{2}$/.test(e.data)) return { erros: ["Data inválida."] };
  if (e.data > hojeBahia()) return { erros: ["Não é possível lançar um dia que ainda não chegou."] };
  if (!s.usinas.some((u) => u.id === e.usinaId) || !podeLancarBoletim(s, e.usinaId)) {
    return { erros: ["Você não tem permissão para lançar o boletim desta usina."] };
  }

  const supabase = await criarClienteServidor();
  const dia = await carregarDia(supabase, e.usinaId, e.data);
  const gestor = gestorDaUsina(s, e.usinaId);

  if (e.modo !== "parcial" && !gestor) {
    const pend = diasPendentes(dia.inicio, e.data, new Set(dia.fechados));
    if (pend.length) return { erros: [`Os lançamentos seguem a ordem dos dias. Feche primeiro o dia ${dataBr(pend[0])}.`] };
  }

  let itens: Map<string, Partial<Linha>>;
  if (e.modo === "sem_producao") {
    if (Object.keys(dia.linhas).length) return { erros: ["Este dia já tem lançamentos. Feche o dia normalmente."] };
    itens = new Map();
  } else {
    const r = prepararItens(dia.contexto, e.linhas, e.usinaM3);
    if (e.modo === "fechar" && (r.erros.length || r.pendencias.length)) return { erros: [...r.erros, ...r.pendencias] };
    itens = r.itens;
  }

  const status = e.modo === "parcial" ? "aberto" : "fechado";
  const { data: b, error } = await supabase
    .from("boletim")
    .upsert(
      {
        usina_id: e.usinaId,
        data: e.data,
        status,
        origem: "lancado",
        fonte: null,
        lancado_por: s.pessoa.id,
        lancado_por_nome: s.pessoa.nome,
        sem_producao: e.modo === "sem_producao",
      },
      { onConflict: "usina_id,data" },
    )
    .select("id")
    .single();
  if (error || !b) return { erros: [mensagemBanco(error?.code)] };

  // Quem não pode apagar linhas (lançador) recebe a linha em branco: o histórico fica no registro de auditoria.
  const ids = new Set([...itens.keys(), ...Object.keys(dia.linhas)]);
  const linhas = [...ids].map((ativo_id) => ({
    boletim_id: b.id,
    usina_id: e.usinaId,
    ativo_id,
    ...linhaVazia(),
    ...(itens.get(ativo_id) ?? {}),
  }));
  if (linhas.length) {
    const { error: erroItens } = await supabase.from("boletim_item").upsert(linhas, { onConflict: "boletim_id,ativo_id" });
    if (erroItens) return { erros: [mensagemBanco(erroItens.code)] };
  }

  // Última leitura de cada veículo (só avança no tempo).
  const base = dia.contexto.leituraBase;
  const leituras = [...itens.entries()]
    .filter(([, l]) => l.km1 != null || l.h1 != null)
    .filter(([id]) => !base.get(id) || (base.get(id)?.data ?? "") <= e.data)
    .map(([id, l]) => ({
      ativo_id: id,
      usina_id: e.usinaId,
      data: e.data,
      km: l.km1 ?? base.get(id)?.km ?? null,
      horas: l.h1 ?? base.get(id)?.horas ?? null,
    }));
  if (leituras.length) await supabase.from("leitura_ativo").upsert(leituras, { onConflict: "ativo_id" });

  revalidatePath("/tarefa/boletim");
  if (e.modo === "sem_producao") return { ok: `Dia ${dataBr(e.data)} fechado como sem produção.` };
  if (e.modo === "fechar") return { ok: `Dia ${dataBr(e.data)} fechado.` };
  return { ok: "Salvo parcialmente. Feche o dia quando a produção terminar." };
}

function mensagemBanco(code?: string) {
  if (code === "42501") return "Seu acesso não permite gravar neste boletim.";
  if (code === "23505") return "Alguém salvou este dia ao mesmo tempo. Recarregue a página e confira.";
  return "Não foi possível salvar. Tente de novo.";
}

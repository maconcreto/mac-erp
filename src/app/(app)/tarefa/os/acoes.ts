"use server";

import { revalidatePath } from "next/cache";
import { lerNumero } from "@/lib/frota/consumo";
import { hojeBahia } from "@/lib/frota/dados";
import { CLASSES, SITUACOES, pendenciasOS, type Arquivo, type Compra, type OS } from "@/lib/frota/os";
import { ativosDaUsina, carregarOS, leituraDe } from "@/lib/frota/os-dados";
import { gestorDaUsina, podeUsarOS } from "@/lib/frota/permissao";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";

export type Retorno = { ok?: string; erros?: string[]; abertas?: { id: string; numero: string; ativo: string }[] };

const texto = (v: unknown, max = 4000) => (typeof v === "string" ? v.trim().slice(0, max) : "");
const data = (v: unknown) => (typeof v === "string" && /^\d{4}-\d{2}-\d{2}$/.test(v) ? v : null);
const hora = (v: unknown) => (typeof v === "string" && /^\d{2}:\d{2}/.test(v) ? v.slice(0, 5) : null);

function mensagemBanco(msg?: string, code?: string) {
  if (msg && /só a gestão da usina altera/.test(msg)) return msg.replace(/^.*?(OS )/, "$1") + ".";
  if (code === "42501" || /permiss/i.test(msg ?? "")) return "Seu acesso não permite gravar OS nesta usina.";
  if (code === "23505") return "Duas OS saíram com o mesmo número. Tente de novo.";
  return "Não foi possível salvar. Tente de novo.";
}

/* ---------------- abrir (uma OS por veículo) ---------------- */

export type NovaOS = {
  usinaId: string;
  ativos: string[]; // ids; vazio quando é "outro"
  ativoTexto: string;
  classe: string;
  tipo: string;
  descricao: string;
  colaborador: string;
  oficina: string;
  nomeOficina: string;
};

export async function abrirOS(e: NovaOS): Promise<Retorno> {
  const s = await carregarSessao();
  if (!s) return { erros: ["Sua sessão expirou. Entre de novo."] };
  if (!s.usinas.some((u) => u.id === e.usinaId) || !podeUsarOS(s, e.usinaId)) return { erros: ["Você não pode abrir OS nesta usina."] };

  const supabase = await criarClienteServidor();
  const ativos = await ativosDaUsina(supabase, e.usinaId);
  const escolhidos = [...new Set(e.ativos)].map((id) => ativos.find((a) => a.id === id)).filter((a) => !!a);
  const ativoTexto = texto(e.ativoTexto, 120);
  const descricao = texto(e.descricao);

  const erros: string[] = [];
  if (!escolhidos.length && !ativoTexto) erros.push("Escolha o veículo ou equipamento.");
  if (!descricao) erros.push("Descreva o problema ou a preventiva.");
  if (!(CLASSES as readonly string[]).includes(e.classe)) erros.push("Escolha se é conserto, preventiva ou melhoria.");
  if (erros.length) return { erros };

  const hoje = hojeBahia();
  const lote = escolhidos.length > 1 ? `Aberta junto com ${escolhidos.map((a) => a.codigo).join(", ")}` : "";
  const base = {
    classe: e.classe,
    tipo: texto(e.tipo, 60),
    descricao,
    colaborador: texto(e.colaborador, 120),
    oficina: e.oficina === "Terceiro" ? "Terceiro" : "Local",
    nome_oficina: texto(e.nomeOficina, 120) || (e.oficina === "Terceiro" ? "" : "USINA"),
    abertura: hoje,
    lote_obs: lote,
    por_nome: s.pessoa.nome,
  };

  const abertas: NonNullable<Retorno["abertas"]> = [];
  const alvos = escolhidos.length ? escolhidos.map((a) => ({ ativo_id: a.id, rotulo: a.codigo })) : [{ ativo_id: "", rotulo: ativoTexto }];
  for (const alvo of alvos) {
    const { data: os, error } = await supabase.rpc("abrir_os", {
      p_usina: e.usinaId,
      p_ano: Number(hoje.slice(0, 4)),
      p_dados: { ...base, ativo_id: alvo.ativo_id, ativo_texto: alvo.ativo_id ? "" : ativoTexto },
    });
    if (error || !os) {
      revalidatePath("/tarefa/os");
      return { abertas, erros: [mensagemBanco(error?.message, error?.code)] };
    }
    abertas.push({ id: os.id, numero: os.numero, ativo: alvo.rotulo });
  }
  revalidatePath("/tarefa/os");
  return { ok: abertas.length > 1 ? `${abertas.length} OS abertas.` : `OS ${abertas[0].numero} aberta.`, abertas };
}

/* ---------------- salvar a ficha ---------------- */

function arquivos(v: unknown, usinaId: string): Arquivo[] {
  if (!Array.isArray(v)) return [];
  return v
    .filter((a) => a && typeof a === "object")
    .map((a) => a as Arquivo)
    .filter((a) => (a.caminho ? a.caminho.startsWith(usinaId + "/") : !!a.id))
    .map((a) => ({ ...(a.caminho ? { caminho: a.caminho } : { id: a.id }), nome: texto(a.nome, 200), tipo: texto(a.tipo, 80), em: texto(a.em, 40) }));
}

export async function salvarOS(id: string, bruto: Record<string, unknown>): Promise<Retorno> {
  const s = await carregarSessao();
  if (!s) return { erros: ["Sua sessão expirou. Entre de novo."] };
  const supabase = await criarClienteServidor();
  const atual = await carregarOS(supabase, id);
  if (!atual) return { erros: ["OS não encontrada."] };
  if (!podeUsarOS(s, atual.usina_id)) return { erros: ["Você não pode alterar OS desta usina."] };
  const gestor = gestorDaUsina(s, atual.usina_id);
  if (!gestor && (atual.origem === "importado" || ["Concluída", "Cancelada"].includes(atual.status))) {
    return { erros: [`OS ${atual.numero} está ${atual.status.toLowerCase()}. Só a gestão da usina altera.`] };
  }

  const status = (SITUACOES as readonly string[]).includes(String(bruto.status)) ? (String(bruto.status) as OS["status"]) : atual.status;
  const compras: Compra[] = (Array.isArray(bruto.compras) ? bruto.compras : []).slice(0, 30).map((c) => {
    const r = (c ?? {}) as Record<string, unknown>;
    return { fornecedor: texto(r.fornecedor, 120), nf: texto(r.nf, 40), valor: lerNumero(r.valor), itens: texto(r.itens, 500), arquivos: arquivos(r.arquivos, atual.usina_id) };
  });

  const ativos = await ativosDaUsina(supabase, atual.usina_id);
  const ativoId = typeof bruto.ativo_id === "string" && ativos.some((a) => a.id === bruto.ativo_id) ? bruto.ativo_id : null;
  const hoje = hojeBahia();

  const novo: OS = {
    ...atual,
    ativo_id: ativoId,
    ativo_texto: ativoId ? null : texto(bruto.ativo_texto, 120) || null,
    classe: (CLASSES as readonly string[]).includes(String(bruto.classe)) ? (String(bruto.classe) as OS["classe"]) : atual.classe,
    tipo: texto(bruto.tipo, 60) || null,
    status,
    descricao: texto(bruto.descricao) || null,
    colaborador: texto(bruto.colaborador, 120) || null,
    checklist: data(bruto.checklist),
    oficina: bruto.oficina === "Terceiro" ? "Terceiro" : bruto.oficina === "Local" ? "Local" : atual.oficina,
    nome_oficina: texto(bruto.nome_oficina, 120) || null,
    encarregado: texto(bruto.encarregado, 120) || null,
    inicio: data(bruto.inicio),
    h_inicio: hora(bruto.h_inicio),
    termino: data(bruto.termino) ?? (status === "Concluída" ? hoje : null),
    h_termino: hora(bruto.h_termino),
    servicos: texto(bruto.servicos) || null,
    pecas: texto(bruto.pecas) || null,
    km: lerNumero(bruto.km),
    horas: lerNumero(bruto.horas),
    valor: lerNumero(bruto.valor),
    nf: texto(bruto.nf, 40) || null,
    recebimento: data(bruto.recebimento),
    pagamento: texto(bruto.pagamento, 300) || null,
    obs: texto(bruto.obs) || null,
    motivo_cancel: status === "Cancelada" ? texto(bruto.motivo_cancel) || null : null,
    compras,
    anexos: arquivos(bruto.anexos, atual.usina_id),
    nf_arquivos: arquivos(bruto.nf_arquivos, atual.usina_id),
  };

  // OS importada do sistema antigo: só confere o mínimo para não travar a correção de dados velhos.
  const ativo = ativos.find((a) => a.id === novo.ativo_id) ?? null;
  const erros = atual.origem === "importado" ? [] : pendenciasOS(novo, ativo, await leituraDe(supabase, novo.ativo_id));
  if (erros.length) return { erros };

  const { error } = await supabase
    .from("ordem_servico")
    .update({
      ativo_id: novo.ativo_id, ativo_texto: novo.ativo_texto, classe: novo.classe, tipo: novo.tipo, status: novo.status,
      descricao: novo.descricao, colaborador: novo.colaborador, checklist: novo.checklist, oficina: novo.oficina,
      nome_oficina: novo.nome_oficina, encarregado: novo.encarregado, inicio: novo.inicio, h_inicio: novo.h_inicio,
      termino: novo.termino, h_termino: novo.h_termino, servicos: novo.servicos, pecas: novo.pecas, km: novo.km,
      horas: novo.horas, valor: novo.valor, nf: novo.nf, recebimento: novo.recebimento, pagamento: novo.pagamento,
      obs: novo.obs, motivo_cancel: novo.motivo_cancel, compras: novo.compras, anexos: novo.anexos,
      nf_arquivos: novo.nf_arquivos, atualizado_por_nome: s.pessoa.nome,
    })
    .eq("id", id);
  if (error) return { erros: [mensagemBanco(error.message, error.code)] };

  revalidatePath("/tarefa/os");
  revalidatePath(`/tarefa/os/${id}`);
  if (status === "Concluída" && atual.status !== "Concluída") return { ok: `OS ${atual.numero} concluída.` };
  if (status === "Cancelada" && atual.status !== "Cancelada") return { ok: `OS ${atual.numero} cancelada.` };
  return { ok: "Salvo." };
}

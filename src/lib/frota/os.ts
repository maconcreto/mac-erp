/* Ordens de serviço — tipos e regras portadas do artefato "Plataforma MAC".
   Funções puras: o navegador mostra o que falta e o servidor confere de novo ao salvar. */

import { lerNumero } from "./consumo";

export const SITUACOES = ["Aberta", "Em execução", "Aguardando peça", "Concluída", "Cancelada"] as const;
export type Situacao = (typeof SITUACOES)[number];
export const EM_ABERTO: Situacao[] = ["Aberta", "Em execução", "Aguardando peça"];

export const CLASSES = ["Corretiva", "Preventiva", "Investimento"] as const;
export type Classe = (typeof CLASSES)[number];

export const TIPOS_SERVICO = [
  "Mecânica", "Elétrica", "Hidráulica", "Pneus", "Revisão", "Aferição / calibração",
  "Funilaria / pintura", "Compra de material / peças", "Aprimoramento", "Edificação / obra civil", "Limpeza / lavagem", "Outros",
] as const;

export type Arquivo = { caminho?: string; id?: string; nome: string; tipo: string; em: string };
export type Compra = { fornecedor: string; nf: string; valor: number | null; itens: string; arquivos: Arquivo[] };

export type OS = {
  id: string;
  usina_id: string;
  numero: string;
  numero_antigo: string | null;
  ativo_id: string | null;
  ativo_texto: string | null;
  classe: Classe | null;
  tipo: string | null;
  status: Situacao;
  abertura: string | null;
  inicio: string | null;
  termino: string | null;
  recebimento: string | null;
  checklist: string | null;
  h_inicio: string | null;
  h_termino: string | null;
  horas: number | null;
  km: number | null;
  oficina: "Local" | "Terceiro" | null;
  nome_oficina: string | null;
  descricao: string | null;
  servicos: string | null;
  pecas: string | null;
  colaborador: string | null;
  encarregado: string | null;
  valor: number | null;
  nf: string | null;
  pagamento: string | null;
  obs: string | null;
  motivo_cancel: string | null;
  lote_obs: string | null;
  compras: Compra[];
  anexos: Arquivo[];
  nf_arquivos: Arquivo[];
  origem: "lancado" | "importado";
  criado_por_nome: string | null;
  atualizado_por_nome: string | null;
  atualizado_em: string;
};

export const CAMPOS_OS =
  "id, usina_id, numero, numero_antigo, ativo_id, ativo_texto, classe, tipo, status, abertura, inicio, termino, recebimento, checklist, " +
  "h_inicio, h_termino, horas, km, oficina, nome_oficina, descricao, servicos, pecas, colaborador, encarregado, valor, nf, pagamento, obs, " +
  "motivo_cancel, lote_obs, compras, anexos, nf_arquivos, origem, criado_por_nome, atualizado_por_nome, atualizado_em";

export type AtivoOS = { id: string; codigo: string; tipo: string; grupo: "frota" | "usina"; usa_km: boolean; usa_hora: boolean };
export type LeituraOS = { km: number | null; horas: number | null; data: string | null };

export function totalOS(o: Pick<OS, "valor" | "compras">) {
  return (o.valor ?? 0) + (o.compras ?? []).reduce((t, c) => t + (lerNumero(c.valor) ?? 0), 0);
}

export function emAberto(s: Situacao) {
  return EM_ABERTO.includes(s);
}

/** OS sem nota anexada quando a nota é exigida (terceiro, ou compra de material). */
export function semNota(o: Pick<OS, "origem" | "oficina" | "anexos" | "nf_arquivos" | "compras">) {
  if (o.origem === "importado") return false;
  if ((o.anexos?.length ?? 0) || (o.nf_arquivos?.length ?? 0)) return false;
  if (o.oficina === "Terceiro") return true;
  return (o.compras ?? []).some((c) => !(c.arquivos?.length ?? 0));
}

/** Nome de verdade: 3 letras ou mais e não "ok", "teste", "x"… */
export function nomeValido(v: string | null | undefined) {
  const t = String(v ?? "").trim();
  return t.replace(/[^A-Za-zÀ-ÿ]/g, "").length >= 3 && !/^(ok|sim|nao|não|x+|teste|-+|\.+|na|n\/a|nenhum)$/i.test(t);
}

const fmt = (v: number, casas = 0) => v.toLocaleString("pt-BR", { maximumFractionDigits: casas });

/** Confere km e horímetro contra a última leitura do veículo (pega número trocado entre os campos). */
export function conferirLeituras(ativo: AtivoOS | null, km: number | null, horas: number | null, ult: LeituraOS | null, concluindo: boolean) {
  const erros: string[] = [];
  if (!ativo || ativo.grupo !== "frota") return erros;
  const c = ativo.codigo;
  if (concluindo && ativo.usa_km && km == null)
    erros.push(`${c}: informe o km do hodômetro no dia do serviço${ult?.km != null ? ` (última leitura: ${fmt(ult.km)} km)` : ""}.`);
  if (concluindo && ativo.usa_hora && horas == null)
    erros.push(`${c}: informe o horímetro no dia do serviço${ult?.horas != null ? ` (última leitura: ${fmt(ult.horas, 1)} h)` : ""}.`);
  if (km != null && ult?.km != null && (km < ult.km * 0.9 || km > ult.km + 5000)) {
    const trocado = ult.horas != null && Math.abs(km - ult.horas) < ult.horas * 0.1;
    erros.push(`${c}: km ${fmt(km)} não confere com o hodômetro (última leitura ${fmt(ult.km)} km). ${trocado ? "Parece que foi digitado o horímetro no campo de km." : "Confira o valor."}`);
  }
  if (horas != null && ult?.horas != null && (horas < ult.horas * 0.9 || horas > ult.horas + 1000)) {
    const trocado = ult.km != null && Math.abs(horas - ult.km) < ult.km * 0.1;
    erros.push(`${c}: horímetro ${fmt(horas, 1)} não confere (última leitura ${fmt(ult.horas, 1)} h). ${trocado ? "Parece que foi digitado o km no campo de horímetro." : "Confira o valor."}`);
  }
  return erros;
}

/** O que falta para salvar a OS na situação escolhida. Vazio = pode salvar. */
export function pendenciasOS(o: OS, ativo: AtivoOS | null, ult: LeituraOS | null): string[] {
  const erros: string[] = [];
  if (!o.ativo_id && !String(o.ativo_texto ?? "").trim()) erros.push("Escolha o veículo ou equipamento.");
  if (!String(o.descricao ?? "").trim()) erros.push("Descreva o problema ou a preventiva.");
  if (o.status === "Cancelada" && !String(o.motivo_cancel ?? "").trim()) erros.push("Informe o motivo do cancelamento.");

  const concluindo = o.status === "Concluída";
  if ((concluindo || String(o.colaborador ?? "").trim()) && !nomeValido(o.colaborador))
    erros.push(`Escreva o nome de quem relatou ou executou o serviço (não vale "${String(o.colaborador ?? "").trim() || "vazio"}").`);
  if (String(o.encarregado ?? "").trim() && !nomeValido(o.encarregado)) erros.push("Encarregado de manutenção: escreva o nome completo.");
  if (concluindo && !String(o.servicos ?? "").trim()) erros.push("Conte o que foi feito em Serviços executados.");

  erros.push(...conferirLeituras(ativo, o.km, o.horas, ult, concluindo));

  if (concluindo && o.oficina === "Terceiro") {
    if (!String(o.nf ?? "").trim()) erros.push("Serviço de terceiro: informe o número da nota fiscal.");
    if (!o.nf_arquivos.length && !o.anexos.length) erros.push("Serviço de terceiro: anexe a foto ou o PDF da nota fiscal.");
    if (!o.valor) erros.push("Serviço de terceiro: informe o valor do serviço.");
  }
  if (concluindo) {
    o.compras.forEach((c, i) => {
      const q = `Compra ${i + 1}: `;
      if (!String(c.fornecedor ?? "").trim()) erros.push(q + "informe o fornecedor.");
      if (!String(c.nf ?? "").trim()) erros.push(q + "informe o nº da nota.");
      if (!lerNumero(c.valor)) erros.push(q + "informe o valor.");
      if (!c.arquivos?.length) erros.push(q + "anexe a foto da nota.");
    });
  }
  return erros;
}

export const COR_SITUACAO: Record<Situacao, "alerta" | "info" | "erro" | "ok" | "neutro"> = {
  Aberta: "alerta",
  "Em execução": "info",
  "Aguardando peça": "erro",
  Concluída: "ok",
  Cancelada: "neutro",
};

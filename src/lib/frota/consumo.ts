/* Regras de consumo da Frota — portadas do artefato "Plataforma MAC".
   Funções puras: rodam no servidor (conferência ao salvar) e no navegador (cálculo ao vivo). */

export const BOMBAS = new Set(["Autobomba", "Bomba lança", "Betobomba"]);
export const PRODUZ = new Set(["Caminhão betoneira", "Autobomba", "Bomba lança", "Betobomba"]);
/** Veículos cuja produção é a da própria usina (não têm viagens/m³ próprios). */
export const AUTOVOL = new Set(["Apoio", "Comercial"]);

export type Limites = { betoneira: number; bomba: number; implemento: number };
export const LIMITES_PADRAO: Limites = { betoneira: 3, bomba: 1.5, implemento: 1 };

export type Ativo = {
  id: string;
  codigo: string;
  tipo: string;
  grupo: "frota" | "usina";
  usa_hora: boolean;
  usa_km: boolean;
  regra_consumo: boolean;
  fora_operacao: boolean;
  betobomba: boolean;
  bomba_id: string | null;
  data_inicio: string | null;
  marcos: { ate: string; m3: number }[];
};

/** Uma linha do boletim (um ativo em um dia). Números são `number | null`. */
export type Linha = {
  parado: boolean;
  sit: string | null; // '' trabalhou · 'servico' · 'manut'
  sem_prod: string | null;
  os_ref: string | null;
  motorista: string | null;
  viagens: number | null;
  m3: number | null;
  vb: number | null;
  m3b: number | null;
  km0: number | null;
  km1: number | null;
  h0: number | null;
  h1: number | null;
  hb0: number | null;
  hb1: number | null;
  litros: number | null;
  preco: number | null;
  valor: number | null;
  posto: string | null;
  justificativa: string | null;
  obs: string | null;
};

export function linhaVazia(): Linha {
  return {
    parado: false, sit: null, sem_prod: null, os_ref: null, motorista: null,
    viagens: null, m3: null, vb: null, m3b: null,
    km0: null, km1: null, h0: null, h1: null, hb0: null, hb1: null,
    litros: null, preco: null, valor: null, posto: null, justificativa: null, obs: null,
  };
}

/** Linha de histórico: data + valores + de onde veio. */
export type Registro = { data: string; origem: "lancado" | "importado" | "auto"; linha: Partial<Linha> };

export type Acumulado = { m3: number; m3b: number; km: number | null; hr: number | null; hb: number | null };
export type Leitura = { km: number | null; h: number | null; hb: number | null };

/** Aceita "1234,5", "1234.5" e "1.234,5". */
export function lerNumero(v: unknown): number | null {
  if (v === "" || v == null) return null;
  if (typeof v === "number") return Number.isFinite(v) ? v : null;
  const s = String(v).trim();
  const x = s.includes(",") ? parseFloat(s.replace(/\./g, "").replace(",", ".")) : parseFloat(s);
  return Number.isFinite(x) ? x : null;
}

export function limiteDe(tipo: string, lim: Limites) {
  return BOMBAS.has(tipo) ? lim.bomba : lim.betoneira;
}

export type Avaliacao = {
  lm3: number | null;
  lm3i: number | null;
  lim: number;
  limI: number;
  overT: boolean;
  overI: boolean;
  over: boolean;
};

/** Consumo de um abastecimento: litros ÷ m³ desde o abastecimento anterior.
 *  Bombas: total (L/m³ sobre o horímetro do caminhão) e implemento (parte dos litros
 *  proporcional às horas da bomba ÷ horas do caminhão). */
export function avaliar(a: Pick<Ativo, "tipo" | "betobomba" | "regra_consumo">, lit: number | null, acc: Acumulado, lim: Limites): Avaliacao {
  const o: Avaliacao = { lm3: null, lm3i: null, lim: limiteDe(a.tipo, lim), limI: lim.implemento, overT: false, overI: false, over: false };
  if (!lit || !(acc.m3 > 0 || acc.m3b > 0)) return o;
  const hr = acc.hr ?? 0;
  if (a.betobomba) {
    const fr = hr > 0 && acc.hb != null && acc.hb >= 0 ? Math.min(1, acc.hb / hr) : 0;
    const li = lit * fr;
    o.lm3 = acc.m3 > 0 ? (lit - li) / acc.m3 : null;
    o.lm3i = acc.m3b > 0 && fr > 0 ? li / acc.m3b : null;
    if (a.regra_consumo) {
      o.overT = o.lm3 != null && o.lm3 > o.lim;
      o.overI = o.lm3i != null && o.lm3i > o.limI;
      o.over = o.overT || o.overI;
    }
    return o;
  }
  o.lm3 = lit / acc.m3;
  if (BOMBAS.has(a.tipo) && hr > 0 && acc.hb != null && acc.hb >= 0) {
    o.lm3i = (lit * Math.min(1, acc.hb / hr)) / acc.m3;
  }
  if (a.regra_consumo) {
    o.overT = o.lm3 > o.lim;
    o.overI = o.lm3i != null && o.lm3i > o.limI;
    o.over = o.overT || o.overI;
  }
  return o;
}

/** Diferenças do dia (atual − anterior) quando as duas leituras existem. */
export function difs(l: Partial<Linha>) {
  const d = (a: keyof Linha, b: keyof Linha) => {
    const x = l[a] as number | null | undefined;
    const y = l[b] as number | null | undefined;
    return x != null && y != null ? y - x : null;
  };
  return { km: d("km0", "km1"), hr: d("h0", "h1"), hb: d("hb0", "hb1") };
}

/** Monta, por ativo, a lista ordenada de registros. Veículos de apoio/comercial recebem os m³ da usina. */
export function indice(registrosPorAtivo: Map<string, Registro[]>, ativos: Ativo[]) {
  const idx = new Map<string, Registro[]>();
  for (const [id, rs] of registrosPorAtivo) idx.set(id, rs.map((r) => ({ ...r, linha: { ...r.linha } })));
  const usina = ativos.find((a) => a.tipo === "Central de concreto");
  if (usina) {
    const ru = idx.get(usina.id) ?? [];
    for (const a of ativos.filter((x) => AUTOVOL.has(x.tipo))) {
      const lista = idx.get(a.id) ?? [];
      const porDia = new Map(lista.map((r) => [r.data, r]));
      for (const u of ru) {
        if (u.origem === "importado" || !((u.linha.m3 ?? 0) > 0)) continue;
        const r = porDia.get(u.data);
        if (r) {
          if (r.origem !== "importado") r.linha.m3 = u.linha.m3 as number;
        } else lista.push({ data: u.data, origem: "auto", linha: { m3: u.linha.m3 as number } });
      }
      idx.set(a.id, lista);
    }
  }
  for (const rs of idx.values()) rs.sort((a, b) => a.data.localeCompare(b.data));
  return idx;
}

/** Soma o que foi produzido/rodado desde o último abastecimento, antes de `data`. */
export function acumDesde(idx: Map<string, Registro[]>, ativoId: string, data: string): Acumulado {
  const rs = (idx.get(ativoId) ?? []).filter((r) => r.data < data);
  const A: Acumulado = { m3: 0, m3b: 0, km: null, hr: null, hb: null };
  for (let i = rs.length - 1; i >= 0; i--) {
    const l = rs[i].linha;
    if ((l.litros ?? 0) > 0) break;
    A.m3 += l.m3 ?? 0;
    A.m3b += l.m3b ?? 0;
    const d = difs(l);
    if (d.km != null) A.km = (A.km ?? 0) + d.km;
    if (d.hr != null) A.hr = (A.hr ?? 0) + d.hr;
    if (d.hb != null) A.hb = (A.hb ?? 0) + d.hb;
  }
  return A;
}

/** Soma o que foi lançado hoje ao acumulado. `ant` = leituras anteriores, usadas quando o início do dia não foi digitado. */
export function somaHoje(base: Acumulado, l: Partial<Linha>, ant: Leitura): Acumulado {
  const B: Acumulado = { ...base };
  B.m3 += l.m3 ?? 0;
  B.m3b += l.m3b ?? 0;
  const pares: [keyof Acumulado, keyof Linha, keyof Linha, number | null][] = [
    ["km", "km0", "km1", ant.km],
    ["hr", "h0", "h1", ant.h],
    ["hb", "hb0", "hb1", ant.hb],
  ];
  for (const [k, a, b, padrao] of pares) {
    const x0 = (l[a] as number | null | undefined) ?? padrao;
    const x1 = l[b] as number | null | undefined;
    if (x0 != null && x1 != null) B[k] = ((B[k] as number | null) ?? 0) + (x1 - x0);
  }
  return B;
}

/** Últimas leituras de km/horímetro anteriores a `data`: o registro mais recente de cada campo. */
export function ultimaLeitura(
  registros: Registro[],
  base: { data: string; km: number | null; horas: number | null } | null,
  hbBase: number | null,
  antesDe: string,
): Leitura {
  const out: Leitura = { km: null, h: null, hb: null };
  let dKm = "", dH = "", dHb = "";
  if (base && base.data < antesDe) {
    out.km = base.km; out.h = base.horas; out.hb = hbBase;
    dKm = dH = dHb = base.data;
  }
  for (const r of registros) {
    if (r.data >= antesDe) continue;
    const l = r.linha;
    if (l.km1 != null && r.data >= dKm) { out.km = l.km1; dKm = r.data; }
    if (l.h1 != null && r.data >= dH) { out.h = l.h1; dH = r.data; }
    if (l.hb1 != null && r.data >= dHb) { out.hb = l.hb1; dHb = r.data; }
  }
  return out;
}

/** Último motorista informado antes de `data`. */
export function ultimoMotorista(registros: Registro[], antesDe: string): string {
  for (let i = registros.length - 1; i >= 0; i--) {
    const r = registros[i];
    if (r.data < antesDe && r.linha.motorista) return r.linha.motorista;
  }
  return "";
}

export function volumeAcumuladoUsina(usina: Ativo, registros: Registro[], ate: string): number | null {
  const marcos = [...usina.marcos].filter((m) => m.ate <= ate).sort((a, b) => a.ate.localeCompare(b.ate));
  const base = marcos[marcos.length - 1];
  let tot = base ? Number(base.m3) : 0;
  const desde = base ? base.ate : "0000";
  const porDia = new Map<string, number>();
  for (const r of registros) {
    if (r.data > desde && r.data <= ate && r.linha.m3 != null) {
      if (!porDia.has(r.data) || r.origem !== "importado") porDia.set(r.data, r.linha.m3);
    }
  }
  for (const v of porDia.values()) tot += v;
  return base || porDia.size ? tot : null;
}

/** Dias entre o início do boletim digital e `ate` (exclusive) ainda sem fechamento. */
export function diasPendentes(inicio: string | null, ate: string, fechados: Set<string>): string[] {
  const out: string[] = [];
  if (!inicio || ate <= inicio) return out;
  const d = new Date(inicio + "T12:00:00Z");
  const fim = new Date(ate + "T12:00:00Z");
  while (d < fim) {
    const k = d.toISOString().slice(0, 10);
    if (!fechados.has(k)) out.push(k);
    d.setUTCDate(d.getUTCDate() + 1);
  }
  return out;
}

export const n = (v: number | null | undefined, casas = 0) =>
  v == null || !Number.isFinite(v) ? "—" : new Intl.NumberFormat("pt-BR", { minimumFractionDigits: casas, maximumFractionDigits: casas }).format(v);
export const brl = (v: number | null | undefined) =>
  v == null || !Number.isFinite(v) ? "—" : new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(v);
export const dataBr = (s: string) => (s ? s.split("-").reverse().join("/") : "—");

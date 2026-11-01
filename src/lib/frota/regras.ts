/* Conferências do boletim — portadas de `salvarBoletim` do artefato.
   Pura: o servidor roda de novo na hora de gravar, então ninguém burla pelo navegador. */
import {
  AUTOVOL, BOMBAS, PRODUZ, acumDesde, avaliar, indice, lerNumero, n, somaHoje, ultimaLeitura, ultimoMotorista,
  type Ativo, type Leitura, type Limites, type Linha, type Registro,
} from "./consumo";

const NUMERICOS = ["viagens", "m3", "vb", "m3b", "km0", "km1", "h0", "h1", "hb0", "hb1", "litros", "preco", "valor"] as const;
const TEXTOS = ["sit", "sem_prod", "os_ref", "motorista", "posto", "justificativa", "obs"] as const;

/** Aceita o que vier do navegador e devolve só campos conhecidos, já no tipo certo. */
export function normalizar(bruto: unknown): Partial<Linha> {
  const o: Partial<Linha> = {};
  if (!bruto || typeof bruto !== "object") return o;
  const b = bruto as Record<string, unknown>;
  if (b.parado === true) o.parado = true;
  for (const k of NUMERICOS) {
    const v = lerNumero(b[k]);
    if (v != null) o[k] = v;
  }
  for (const k of TEXTOS) {
    const v = typeof b[k] === "string" ? (b[k] as string).trim() : "";
    if (v) o[k] = v.slice(0, 500);
  }
  return o;
}

export type Contexto = {
  ativos: Ativo[];
  data: string;
  lim: Limites;
  historico: Map<string, Registro[]>; // só dias anteriores a `data`
  leituraBase: Map<string, { data: string; km: number | null; horas: number | null }>;
  postoPadrao: string;
};

export type Resultado = {
  itens: Map<string, Partial<Linha>>;
  erros: string[]; // bloqueiam ao fechar o dia
  pendencias: string[]; // idem (campos que faltam)
};

export function frotaDe(ativos: Ativo[]) {
  return ativos
    .filter((a) => a.grupo === "frota")
    .sort((a, b) => a.codigo.localeCompare(b.codigo, "pt-BR", { numeric: true }));
}
export const usinaDe = (ativos: Ativo[]) => ativos.find((a) => a.tipo === "Central de concreto");

/** Por ativo: leituras anteriores, acumulado desde o último abastecimento e último motorista. */
export function derivar(ctx: Contexto) {
  const idx = indice(ctx.historico, ctx.ativos);
  const por = new Map<string, { ant: Leitura; acum: ReturnType<typeof acumDesde>; ultMotorista: string }>();
  for (const a of ctx.ativos) {
    const rs = idx.get(a.id) ?? [];
    por.set(a.id, {
      ant: ultimaLeitura(rs, ctx.leituraBase.get(a.id) ?? null, null, ctx.data),
      acum: acumDesde(idx, a.id, ctx.data),
      ultMotorista: ultimoMotorista(rs, ctx.data),
    });
  }
  return por;
}

export function prepararItens(ctx: Contexto, formularios: Record<string, unknown>, usinaM3Bruto: unknown): Resultado {
  const itens = new Map<string, Partial<Linha>>();
  const erros: string[] = [];
  const pend: string[] = [];
  const por = derivar(ctx);
  const usina = usinaDe(ctx.ativos);
  const usinaM3 = lerNumero(usinaM3Bruto);

  for (const f of frotaDe(ctx.ativos)) {
    const bomba = BOMBAS.has(f.tipo);
    const it = normalizar(formularios[f.id]);
    const o: Partial<Linha> = { ...it };
    const d = por.get(f.id)!;
    const ant = d.ant;

    if (it.sit === "servico" || it.sit === "manut") {
      delete o.viagens; delete o.m3; delete o.m3b; delete o.vb; delete o.motorista;
      if (it.sit === "servico" && !(o.sem_prod ?? "").trim()) pend.push(`${f.codigo}: descreva o serviço feito sem produção`);
    } else {
      delete o.sit; delete o.sem_prod; delete o.os_ref;
    }
    if (AUTOVOL.has(f.tipo)) delete o.m3;

    if (it.parado) {
      for (const k of ["viagens", "m3", "litros", "valor", "preco", "km0", "km1", "h0", "h1", "hb0", "hb1", "posto", "justificativa", "motorista"] as const) delete o[k];
      o.parado = true;
      itens.set(f.id, o);
      continue;
    }

    const abast = (o.litros ?? 0) > 0;
    const ativoHoje = (o.m3 ?? 0) > 0 || (o.viagens ?? 0) > 0 || (o.m3b ?? 0) > 0 || abast;

    if (bomba && !ativoHoje && o.km1 == null && o.h1 == null && o.hb1 == null) {
      delete o.km0; delete o.h0; delete o.hb0;
    }
    if (bomba && ativoHoje && it.sit !== "manut") {
      if (o.km0 == null && ant.km != null) o.km0 = ant.km;
      if (o.h0 == null && ant.h != null) o.h0 = ant.h;
      if (o.hb0 == null && ant.hb != null) o.hb0 = ant.hb;
      if (o.km1 == null) pend.push(`${f.codigo}: informe o km do caminhão`);
      if (o.h1 == null) pend.push(`${f.codigo}: informe o horímetro do caminhão`);
      if (o.hb1 == null) pend.push(`${f.codigo}: informe o horímetro da bomba`);
      if (o.km1 != null && o.km0 != null && o.km1 < o.km0) erros.push(`${f.codigo}: km do caminhão menor que o anterior (${n(o.km0)})`);
      if (o.h1 != null && o.h0 != null && o.h1 < o.h0) erros.push(`${f.codigo}: horímetro do caminhão menor que o anterior (${n(o.h0, 1)})`);
      if (o.hb1 != null && o.hb0 != null && o.hb1 < o.hb0) erros.push(`${f.codigo}: horímetro da bomba menor que o anterior (${n(o.hb0, 1)})`);
    }
    if (f.betobomba) {
      if ((o.m3b ?? 0) > 0 || (o.vb ?? 0) > 0) {
        if (o.hb0 == null && ant.hb != null) o.hb0 = ant.hb;
        if (o.hb1 == null) pend.push(`${f.codigo}: informe o horímetro da betobomba (obrigatório quando a betobomba trabalha)`);
        if (o.h1 == null) pend.push(`${f.codigo}: informe o horímetro do caminhão (necessário para separar o diesel da betobomba)`);
        if (o.hb1 != null && o.hb0 != null && o.hb1 < o.hb0) erros.push(`${f.codigo}: horímetro da betobomba menor que o anterior`);
      } else if (o.hb1 == null) delete o.hb0;
    }

    if (!abast) {
      for (const k of ["litros", "valor", "preco", "posto", "justificativa"] as const) delete o[k];
      if (!bomba) {
        if (o.km1 == null) delete o.km0;
        else {
          if (o.km0 == null && ant.km != null) o.km0 = ant.km;
          if (o.km0 != null && o.km1 < o.km0) erros.push(`${f.codigo}: km atual menor que o anterior (${n(o.km0)})`);
        }
        if (o.h1 == null) delete o.h0;
        else {
          if (o.h0 == null && ant.h != null) o.h0 = ant.h;
          if (o.h0 != null && o.h1 < o.h0) erros.push(`${f.codigo}: horímetro atual menor que o anterior (${n(o.h0, 1)})`);
        }
      }
    } else {
      if (!bomba) {
        if (o.km0 == null && ant.km != null && f.usa_km) o.km0 = ant.km;
        if (o.h0 == null && ant.h != null && f.usa_hora) o.h0 = ant.h;
        if (f.usa_km && o.km1 == null) pend.push(`${f.codigo}: informe o km atual`);
        if (f.usa_hora && o.h1 == null) pend.push(`${f.codigo}: informe o horímetro atual`);
        if (o.km1 != null && o.km0 != null && o.km1 < o.km0) erros.push(`${f.codigo}: km atual menor que o anterior`);
      }
      if (!o.posto) o.posto = ctx.postoPadrao;
      if (!o.litros) erros.push(`${f.codigo}: informe os litros abastecidos`);
      if (o.preco != null) {
        if (o.preco < 4 || o.preco > 12) {
          erros.push(`${f.codigo}: preço por litro R$ ${n(o.preco, 2)} fora do normal. Confira no cupom (diesel costuma ficar entre R$ 5 e R$ 9).`);
        } else o.valor = Math.round((o.litros ?? 0) * o.preco * 100) / 100;
      }
      if (!o.valor) erros.push(`${f.codigo}: informe o preço por litro do abastecimento`);
      const hoje = { ...o, m3: AUTOVOL.has(f.tipo) ? (usinaM3 ?? 0) : o.m3 };
      const A = somaHoje(d.acum, hoje, ant);
      const ev = avaliar(f, o.litros ?? null, A, ctx.lim);
      if (ev.over && !(o.justificativa ?? "").trim()) pend.push(`${f.codigo}: consumo acima do limite precisa de justificativa`);
      if (!ev.over) delete o.justificativa;
    }

    if ((PRODUZ.has(f.tipo) || f.tipo === "Pá carregadeira") && !o.motorista && ((o.m3 ?? 0) > 0 || (o.viagens ?? 0) > 0)) {
      if (d.ultMotorista) o.motorista = d.ultMotorista;
    }
    if (Object.keys(o).length) itens.set(f.id, o);
  }

  if (usina) {
    if (usinaM3 != null) itens.set(usina.id, { m3: usinaM3 });
    else if ([...itens.values()].some((l) => (l.m3 ?? 0) > 0 || (l.viagens ?? 0) > 0)) {
      pend.push("Informe a produção total da usina no dia (m³).");
    }
  }
  return { itens, erros, pendencias: pend };
}

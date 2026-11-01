#!/usr/bin/env node
/*
 * Importa o histórico da Frota do artefato antigo "Plataforma MAC" para o Supabase.
 *
 * Este script NÃO fala com o banco: ele lê a pasta exportada (arquivos fr_*.json) e
 * gera arquivos .sql. Quem roda os .sql, na ordem, é você (Supabase → SQL Editor).
 * Todos são idempotentes: rodar duas vezes não duplica nada.
 *
 * Uso:
 *   node supabase/importacao/frota.mjs <pasta-do-export> [pasta-de-saida] [--central maconc=VDC]
 *
 * --central liga o código da central do artefato ao código da usina no Supabase
 * (padrão: maconc=VDC). Pode repetir a opção se houver mais de uma central.
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";

// ---------- argumentos ----------
const args = process.argv.slice(2);
const mapa = new Map();
const pos = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--central") {
    const [c, u] = (args[++i] ?? "").split("=");
    if (!c || !u) fim("Use --central central=USINA, por exemplo --central maconc=VDC");
    mapa.set(c, u.toUpperCase());
  } else pos.push(args[i]);
}
if (mapa.size === 0) mapa.set("maconc", "VDC");
const [entrada, saida = "importar-frota"] = pos;
if (!entrada) fim("Informe a pasta do export. Exemplo: node supabase/importacao/frota.mjs ./plataforma-mac_2026-11-01_1859");

function fim(msg) {
  console.error("Erro: " + msg);
  process.exit(1);
}
const avisos = [];
const aviso = (m) => avisos.push(m);

// ---------- leitura ----------
function ler(nome, obrigatorio = true) {
  const f = join(resolve(entrada), nome + ".json");
  if (!existsSync(f)) {
    if (obrigatorio) fim(`Arquivo ${nome}.json não encontrado em ${entrada}`);
    return [];
  }
  return JSON.parse(readFileSync(f, "utf8")).documentos ?? [];
}
const frota = ler("fr_frota");
const centrais = ler("fr_centrais");
const config = ler("fr_config", false);
const contador = ler("fr_contador", false);
const leituras = ler("fr_leituras", false);
const hbol = ler("fr_hbol", false);
const hmes = ler("fr_hmes", false);
const hos = ler("fr_hos", false);
const lanc = ler("fr_lanc", false);

// ---------- normalização ----------
const num = (v) => {
  if (v === null || v === undefined || v === "") return null;
  const n = typeof v === "number" ? v : Number(String(v).replace(",", "."));
  return Number.isFinite(n) ? n : null;
};
const txt = (v) => {
  if (v === null || v === undefined) return null;
  const s = String(v).trim();
  return s === "" ? null : s;
};
const data = (v) => (typeof v === "string" && /^\d{4}-\d{2}-\d{2}/.test(v) ? v.slice(0, 10) : null);
const hora = (v) => (typeof v === "string" && /^\d{1,2}:\d{2}/.test(v) ? v.slice(0, 5) : null);
const ts = (v) => (typeof v === "string" && !Number.isNaN(Date.parse(v)) ? v : null);

function usinaDe(central) {
  const u = mapa.get(central);
  if (!u) fim(`A central "${central}" aparece nos dados, mas não foi ligada a uma usina. Use --central ${central}=CODIGO`);
  return u;
}

// id do artefato -> código do ativo no Supabase
const codigoDe = new Map();
for (const f of frota) codigoDe.set(f.id, String(f.dados.codigo ?? f.id).toUpperCase());
const usinas = new Set([...mapa.values()]);

// ---------- ativos ----------
const ativos = frota.map((f) => {
  const d = f.dados;
  return {
    usina: usinaDe(d.central),
    codigo: codigoDe.get(f.id),
    tipo: txt(d.tipo) ?? "Sem tipo",
    grupo: d.grupo === "usina" ? "usina" : "frota",
    capacidade_m3: num(d.capacidade),
    usa_hora: d.usaHora !== false,
    usa_km: d.usaKm !== false,
    regra_consumo: d.regra !== false,
    fora_operacao: d.foraOperacao === true,
    betobomba: d.betobomba === true,
    data_inicio: data(d.dataInicio),
    marcos: Array.isArray(d.marcos) ? d.marcos : [],
    obs: txt(d.obs),
    ativo: d.ativo !== false,
  };
});
const bombas = [];
for (const f of frota) {
  if (!f.dados.bombaId) continue;
  const alvo = codigoDe.get(f.dados.bombaId);
  if (!alvo) aviso(`Ativo ${codigoDe.get(f.id)} aponta para a bomba "${f.dados.bombaId}", que não existe no cadastro.`);
  else bombas.push({ usina: usinaDe(f.dados.central), codigo: codigoDe.get(f.id), bomba: alvo });
}

// ---------- boletins ----------
const ITENS_NUM = ["h0", "h1", "km0", "km1", "hb0", "hb1", "litros", "preco", "valor", "viagens", "vb", "m3", "m3b"];
function itensDe(obj, ctx) {
  const out = [];
  for (const [id, it] of Object.entries(obj ?? {})) {
    const codigo = codigoDe.get(id);
    if (!codigo) {
      aviso(`Boletim ${ctx}: ativo "${id}" não existe no cadastro; linha ignorada.`);
      continue;
    }
    const r = { codigo, parado: it.parado === true };
    for (const k of ITENS_NUM) r[k] = num(it[k]);
    r.posto = txt(it.posto);
    r.cupom = txt(it.cupom);
    r.motorista = txt(it.motorista);
    r.justificativa = txt(it.justificativa);
    r.sem_prod = txt(it.semProd);
    r.sit = txt(it.sit);
    r.obs = txt(it.obs);
    out.push(r);
  }
  return out;
}
const boletins = new Map(); // central|data -> boletim
for (const b of hbol) {
  const d = b.dados;
  const dia = data(d.data ?? b.id);
  if (!dia) { aviso(`Boletim histórico ${b.id} sem data válida; ignorado.`); continue; }
  boletins.set(`${d.central}|${dia}`, {
    usina: usinaDe(d.central), data: dia, status: "fechado", origem: "importado",
    fonte: txt(d.fonte), por_nome: null, itens: itensDe(d.itens, `${dia} (histórico)`),
  });
}
let sobrepostos = 0;
for (const b of lanc.filter((x) => x.caminho.includes("/bol/"))) {
  const d = b.dados;
  const dia = data(d.data ?? b.id);
  if (!dia) { aviso(`Boletim lançado ${b.caminho} sem data válida; ignorado.`); continue; }
  const k = `${d.central}|${dia}`;
  if (boletins.has(k)) sobrepostos++;
  boletins.set(k, {
    usina: usinaDe(d.central), data: dia, status: d.status === "fechado" ? "fechado" : "aberto",
    origem: "lancado", fonte: null, por_nome: txt(d.porNome), itens: itensDe(d.itens, `${dia}`),
  });
}
if (sobrepostos) aviso(`${sobrepostos} dia(s) existem no histórico e também lançados; ficou o lançado.`);

// ---------- ordens de serviço ----------
const CLASSES = new Set(["Preventiva", "Corretiva"]);
function osDe(doc, origem) {
  const d = doc.dados;
  const ano = num(d.ano), seq = num(d.seq);
  const numero = txt(d.numero);
  if (!numero || ano === null || seq === null) {
    aviso(`OS ${doc.id} sem número/ano/seq; ignorada.`);
    return null;
  }
  const codigo = codigoDe.get(d.ativo) ?? null;
  if (d.ativo && !codigo) aviso(`OS ${numero}: ativo "${d.ativo}" fora do cadastro; guardado só como texto.`);
  let classe = txt(d.classe);
  if (classe && !CLASSES.has(classe)) { aviso(`OS ${numero}: classe "${classe}" desconhecida; gravada vazia.`); classe = null; }
  return {
    usina: usinaDe(d.central), ano, seq, numero, numero_antigo: txt(d.numeroAntigo),
    ativo: codigo, ativo_texto: txt(d.ativoTexto) ?? (codigo ? null : txt(d.ativo)),
    classe, status: txt(d.status) ?? "Aberta",
    abertura: data(d.abertura), inicio: data(d.inicio), termino: data(d.termino),
    recebimento: data(d.recebimento), checklist: data(d.checklist),
    h_inicio: hora(d.hInicio), h_termino: hora(d.hTermino),
    horas: num(d.horas), km: num(d.km), m3: num(d.m3),
    oficina: txt(d.oficina), nome_oficina: txt(d.nomeOficina),
    descricao: txt(d.descricao), servicos: txt(d.servicos), pecas: txt(d.pecas),
    colaborador: txt(d.colaborador), encarregado: txt(d.encarregado),
    valor: num(d.valor), nf: txt(d.nf), pagamento: txt(d.pagamento), meses: num(d.meses),
    lote_obs: txt(d.loteObs), obs: txt(d.obs),
    compras: Array.isArray(d.compras) ? d.compras : [],
    origem, criado_por_nome: txt(d.criadoPor), atualizado_por_nome: txt(d.atualizadoPor),
    criado_em: ts(d.criadoEm), atualizado_em: ts(d.atualizadoEm),
  };
}
const ordens = new Map(); // usina|numero -> os
for (const o of hos) { const r = osDe(o, "importado"); if (r) ordens.set(`${r.usina}|${r.numero}`, r); }
for (const o of lanc.filter((x) => x.caminho.includes("/os/"))) {
  const r = osDe(o, "lancado");
  if (!r) continue;
  if (ordens.has(`${r.usina}|${r.numero}`)) aviso(`OS ${r.numero} existe no histórico e lançada; ficou a lançada.`);
  ordens.set(`${r.usina}|${r.numero}`, r);
}
// dois números diferentes com o mesmo (ano, seq) quebrariam a regra de unicidade
const vistos = new Map();
for (const r of ordens.values()) {
  const k = `${r.usina}|${r.ano}|${r.seq}`;
  if (vistos.has(k)) fim(`OS ${r.numero} e ${vistos.get(k)} têm o mesmo ano e sequência (${r.ano}/${r.seq}).`);
  vistos.set(k, r.numero);
}

// ---------- consumo mensal ----------
const consumo = new Map();
for (const m of hmes) {
  const d = m.dados;
  const codigo = codigoDe.get(d.v);
  if (!codigo || !/^\d{4}-\d{2}$/.test(d.ym ?? "")) { aviso(`Consumo ${m.id} inválido; ignorado.`); continue; }
  const usina = usinaDe(d.central);
  const k = `${usina}|${d.ym}|${codigo}`;
  if (consumo.has(k)) aviso(`Consumo ${m.id} repete ${d.ym}/${codigo}; ficou o último.`);
  consumo.set(k, {
    usina, mes: `${d.ym}-01`, ativo: codigo, dias: num(d.dias), horas: num(d.hr), km: num(d.km),
    litros: num(d.litros), viagens: num(d.viagens), volume_m3: num(d.vol), motorista: txt(d.motorista),
    capacidade_m3: num(d.cap), faturamento: num(d.faturamento), fonte: txt(d.fonte), sobrescrito: d.override === true,
  });
}

// ---------- contador de OS e leituras ----------
const maxSeq = new Map(); // usina|ano -> maior seq
for (const o of ordens.values()) {
  const k = `${o.usina}|${o.ano}`;
  maxSeq.set(k, Math.max(maxSeq.get(k) ?? 0, o.seq));
}
const unica = [...usinas][0];
if (usinas.size > 1 && contador.length) aviso("Há mais de uma usina: o contador de OS do export não diz de qual central é; usei só o maior número de cada usina.");
const contadores = new Map();
for (const [k, v] of maxSeq) { const [usina, ano] = k.split("|"); contadores.set(k, { usina, ano: Number(ano), ultimo: v }); }
if (usinas.size === 1) {
  for (const c of contador) {
    const ano = num(c.dados.ano), ult = num(c.dados.ultimo);
    if (ano === null || ult === null) continue;
    const k = `${unica}|${ano}`;
    contadores.set(k, { usina: unica, ano, ultimo: Math.max(ult, contadores.get(k)?.ultimo ?? 0) });
  }
}
const leit = [];
for (const l of leituras) {
  const usina = usinaDe(l.dados.central);
  for (const [id, v] of Object.entries(l.dados.itens ?? {})) {
    const codigo = codigoDe.get(id);
    if (!codigo || !data(v.data)) continue;
    leit.push({ usina, ativo: codigo, data: data(v.data), horas: num(v.h), km: num(v.km) });
  }
}

// ---------- parâmetros ----------
const params = [];
const cfg = config[0]?.dados ?? {};
const inicio = data(cfg.inicioBoletim);
for (const u of usinas) {
  if (inicio) params.push({ usina: u, chave: "inicio_boletim", valor: inicio, descricao: "Primeiro dia em que o boletim digital vale" });
}
for (const c of centrais) {
  if (txt(c.dados.posto) && mapa.has(c.id)) params.push({ usina: usinaDe(c.id), chave: "posto_padrao", valor: txt(c.dados.posto), descricao: "Posto de abastecimento usual" });
}
const notaLimites = config.length
  ? `Valores do artefato para conferir com a tabela parametro: limite L/m³ betoneira=${cfg.limiteLm3}, bomba=${cfg.limiteBomba}, implemento=${cfg.limiteImpl}, diesel de referência=${cfg.precoDieselRef}. O import não os altera.`
  : null;

// ---------- geração do SQL ----------
function aspas(json) {
  let tag = "j";
  while (json.includes(`$${tag}$`)) tag += "x";
  return `$${tag}$${json}$${tag}$`;
}
const J = (v) => aspas(JSON.stringify(v));
const cabecalho = (titulo) =>
  `-- Importação da Frota — ${titulo}\n-- Gerado de ${resolve(entrada)}\n-- Pode ser rodado mais de uma vez: nada é duplicado.\n`;
const exigeUsinas = () =>
  `do $$ begin\n  if (select count(*) from public.usina where codigo = any (array[${[...usinas].map((u) => `'${u}'`).join(",")}])) <> ${usinas.size} then\n    raise exception 'Usina(s) ${[...usinas].join(", ")} não encontrada(s) no banco.';\n  end if;\nend $$;\n`;

const arquivos = {};

// 1 — ativos e parâmetros
arquivos["1-ativos-e-parametros.sql"] = `${cabecalho("1 de 4: ativos e parâmetros")}
begin;
${exigeUsinas()}
insert into public.ativo (usina_id, codigo, tipo, grupo, capacidade_m3, usa_hora, usa_km, regra_consumo, fora_operacao, betobomba, data_inicio, marcos, obs, ativo)
select u.id, x.codigo, x.tipo, x.grupo, x.capacidade_m3, x.usa_hora, x.usa_km, x.regra_consumo, x.fora_operacao, x.betobomba, x.data_inicio, x.marcos, x.obs, x.ativo
from jsonb_to_recordset(${J(ativos)}::jsonb) as x(usina text, codigo text, tipo text, grupo text, capacidade_m3 numeric, usa_hora boolean, usa_km boolean, regra_consumo boolean, fora_operacao boolean, betobomba boolean, data_inicio date, marcos jsonb, obs text, ativo boolean)
join public.usina u on u.codigo = x.usina
on conflict (usina_id, codigo) do update set
  tipo = excluded.tipo, grupo = excluded.grupo, capacidade_m3 = excluded.capacidade_m3, usa_hora = excluded.usa_hora,
  usa_km = excluded.usa_km, regra_consumo = excluded.regra_consumo, fora_operacao = excluded.fora_operacao,
  betobomba = excluded.betobomba, data_inicio = excluded.data_inicio, marcos = excluded.marcos, obs = excluded.obs;
${
  bombas.length
    ? `
update public.ativo a set bomba_id = b.id
from jsonb_to_recordset(${J(bombas)}::jsonb) as x(usina text, codigo text, bomba text)
join public.usina u on u.codigo = x.usina
join public.ativo b on b.usina_id = u.id and b.codigo = x.bomba
where a.usina_id = u.id and a.codigo = x.codigo;
`
    : ""
}${
  params.length
    ? `
insert into public.parametro (empresa_id, usina_id, chave, valor, descricao)
select u.empresa_id, u.id, x.chave, x.valor, x.descricao
from jsonb_to_recordset(${J(params)}::jsonb) as x(usina text, chave text, valor jsonb, descricao text)
join public.usina u on u.codigo = x.usina
on conflict (empresa_id, usina_id, chave) do nothing;
`
    : ""
}${
  leit.length
    ? `
insert into public.leitura_ativo (ativo_id, usina_id, data, horas, km)
select a.id, u.id, x.data, x.horas, x.km
from jsonb_to_recordset(${J(leit)}::jsonb) as x(usina text, ativo text, data date, horas numeric, km numeric)
join public.usina u on u.codigo = x.usina
join public.ativo a on a.usina_id = u.id and a.codigo = x.ativo
on conflict (ativo_id) do update set data = excluded.data, horas = excluded.horas, km = excluded.km
  where excluded.data >= public.leitura_ativo.data;
`
    : ""
}commit;
`;

// 2 — boletins
const listaBol = [...boletins.values()].map(({ itens, ...b }) => b);
const listaItens = [...boletins.values()].flatMap((b) => b.itens.map((i) => ({ usina: b.usina, data: b.data, ...i })));
arquivos["2-boletins.sql"] = `${cabecalho("2 de 4: boletins diários")}
-- Rode depois do arquivo 1 (precisa dos ativos).
begin;
${exigeUsinas()}
insert into public.boletim (usina_id, data, status, origem, fonte, lancado_por_nome)
select u.id, x.data, x.status, x.origem, x.fonte, x.por_nome
from jsonb_to_recordset(${J(listaBol)}::jsonb) as x(usina text, data date, status text, origem text, fonte text, por_nome text)
join public.usina u on u.codigo = x.usina
on conflict (usina_id, data) do nothing;

insert into public.boletim_item (boletim_id, usina_id, ativo_id, parado, h0, h1, km0, km1, hb0, hb1, litros, preco, valor, posto, cupom, motorista, viagens, vb, m3, m3b, justificativa, sem_prod, sit, obs)
select b.id, u.id, a.id, x.parado, x.h0, x.h1, x.km0, x.km1, x.hb0, x.hb1, x.litros, x.preco, x.valor, x.posto, x.cupom, x.motorista, x.viagens, x.vb, x.m3, x.m3b, x.justificativa, x.sem_prod, x.sit, x.obs
from jsonb_to_recordset(${J(listaItens)}::jsonb) as x(usina text, data date, codigo text, parado boolean, h0 numeric, h1 numeric, km0 numeric, km1 numeric, hb0 numeric, hb1 numeric, litros numeric, preco numeric, valor numeric, posto text, cupom text, motorista text, viagens numeric, vb numeric, m3 numeric, m3b numeric, justificativa text, sem_prod text, sit text, obs text)
join public.usina u on u.codigo = x.usina
join public.boletim b on b.usina_id = u.id and b.data = x.data
join public.ativo a on a.usina_id = u.id and a.codigo = x.codigo
on conflict (boletim_id, ativo_id) do nothing;
commit;
`;

// 3 — ordens de serviço
const listaOS = [...ordens.values()];
const contLista = [...contadores.values()];
arquivos["3-ordens-de-servico.sql"] = `${cabecalho("3 de 4: ordens de serviço")}
-- Rode depois do arquivo 1 (precisa dos ativos).
begin;
${exigeUsinas()}
insert into public.ordem_servico (usina_id, ano, seq, numero, numero_antigo, ativo_id, ativo_texto, classe, status, abertura, inicio, termino, recebimento, checklist, h_inicio, h_termino, horas, km, m3, oficina, nome_oficina, descricao, servicos, pecas, colaborador, encarregado, valor, nf, pagamento, meses, lote_obs, obs, compras, origem, criado_por_nome, atualizado_por_nome, criado_em, atualizado_em)
select u.id, x.ano, x.seq, x.numero, x.numero_antigo, a.id, x.ativo_texto, x.classe, x.status, x.abertura, x.inicio, x.termino, x.recebimento, x.checklist, x.h_inicio, x.h_termino, x.horas, x.km, x.m3, x.oficina, x.nome_oficina, x.descricao, x.servicos, x.pecas, x.colaborador, x.encarregado, x.valor, x.nf, x.pagamento, x.meses, x.lote_obs, x.obs, coalesce(x.compras, '[]'::jsonb), x.origem, x.criado_por_nome, x.atualizado_por_nome, coalesce(x.criado_em, now()), coalesce(x.atualizado_em, x.criado_em, now())
from jsonb_to_recordset(${J(listaOS)}::jsonb) as x(usina text, ano int, seq int, numero text, numero_antigo text, ativo text, ativo_texto text, classe text, status text, abertura date, inicio date, termino date, recebimento date, checklist date, h_inicio time, h_termino time, horas numeric, km numeric, m3 numeric, oficina text, nome_oficina text, descricao text, servicos text, pecas text, colaborador text, encarregado text, valor numeric, nf text, pagamento text, meses numeric, lote_obs text, obs text, compras jsonb, origem text, criado_por_nome text, atualizado_por_nome text, criado_em timestamptz, atualizado_em timestamptz)
join public.usina u on u.codigo = x.usina
left join public.ativo a on a.usina_id = u.id and a.codigo = x.ativo
on conflict (usina_id, numero) do nothing;
${
  contLista.length
    ? `
-- o próximo número de OS continua de onde o artefato parou
insert into public.os_contador (usina_id, ano, ultimo)
select u.id, x.ano, x.ultimo
from jsonb_to_recordset(${J(contLista)}::jsonb) as x(usina text, ano int, ultimo int)
join public.usina u on u.codigo = x.usina
on conflict (usina_id, ano) do update set ultimo = greatest(public.os_contador.ultimo, excluded.ultimo);
`
    : ""
}commit;
`;

// 4 — consumo mensal
arquivos["4-consumo-mensal.sql"] = `${cabecalho("4 de 4: consumo e produção por mês")}
-- Rode depois do arquivo 1 (precisa dos ativos).
begin;
${exigeUsinas()}
insert into public.consumo_mensal (usina_id, mes, ativo_id, dias, horas, km, litros, viagens, volume_m3, motorista, capacidade_m3, faturamento, fonte, sobrescrito, origem)
select u.id, x.mes, a.id, x.dias, x.horas, x.km, x.litros, x.viagens, x.volume_m3, x.motorista, x.capacidade_m3, x.faturamento, x.fonte, x.sobrescrito, 'importado'
from jsonb_to_recordset(${J([...consumo.values()])}::jsonb) as x(usina text, mes date, ativo text, dias int, horas numeric, km numeric, litros numeric, viagens numeric, volume_m3 numeric, motorista text, capacidade_m3 numeric, faturamento numeric, fonte text, sobrescrito boolean)
join public.usina u on u.codigo = x.usina
join public.ativo a on a.usina_id = u.id and a.codigo = x.ativo
on conflict (usina_id, mes, ativo_id) do nothing;
commit;
`;

mkdirSync(saida, { recursive: true });
for (const [nome, sql] of Object.entries(arquivos)) writeFileSync(join(saida, nome), sql);

// ---------- resumo ----------
console.log(`Arquivos gerados em ${resolve(saida)}:`);
for (const nome of Object.keys(arquivos)) console.log("  " + nome);
console.log(`\nVai importar: ${ativos.length} ativos, ${listaBol.length} boletins (${listaItens.length} linhas), ${listaOS.length} ordens de serviço, ${consumo.size} registros de consumo mensal, ${leit.length} leituras.`);
if (notaLimites) console.log("\n" + notaLimites);
if (avisos.length) {
  console.log(`\n${avisos.length} aviso(s):`);
  for (const a of avisos) console.log("  - " + a);
}

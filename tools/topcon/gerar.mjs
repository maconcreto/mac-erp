#!/usr/bin/env node
/*
 * Gera, a partir do schema do Topcon (arquivo SQL só com os CREATE TABLE):
 *   - tools/topcon/tabelas.json  → lista do que será carregado (usada pelo carregador)
 *   - supabase/migrations/<data>_topcon_standby.sql → cria os schemas topcon_* VAZIOS e fechados
 *
 * Este script NÃO fala com nenhum banco. Só lê o arquivo de schema e escreve esses dois arquivos.
 *
 * Uso:
 *   node gerar.mjs <topcon_schema.sql>
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  SCHEMAS, ENTRAM, NAO_ENTRAM_TABELA, NAO_ENTRAM_COLUNA, TIPOS_BINARIOS,
} from "./regras.mjs";

const aqui = dirname(fileURLToPath(import.meta.url));
const entrada = process.argv[2];
if (!entrada) {
  console.error("Uso: node gerar.mjs <topcon_schema.sql>");
  process.exit(1);
}

// ---------- 1. ler o schema do MySQL ----------
const linhas = readFileSync(resolve(entrada), "utf8").split(/\r?\n/);
const tabelas = []; // { db, nome, colunas: [{nome, tipoMysql}], indice: [col...] }
let db = null;
let atual = null;
for (const l of linhas) {
  let m = l.match(/^USE `(.+?)`/);
  if (m) { db = m[1]; continue; }
  m = l.match(/^CREATE TABLE `(.+?)`/);
  if (m) { atual = { db, nome: m[1], colunas: [], indice: [] }; tabelas.push(atual); continue; }
  if (!atual) continue;
  if (l.startsWith(")")) { atual = null; continue; }
  const s = l.trim();
  m = s.match(/^PRIMARY KEY \((.+?)\)/);
  if (m) { atual.indice = [...m[1].matchAll(/`(.+?)`/g)].map((x) => x[1]); continue; }
  m = s.match(/^`(.+?)` (\w+)/);
  if (m && !/^(KEY|UNIQUE|CONSTRAINT|FULLTEXT)/i.test(s)) {
    atual.colunas.push({ nome: m[1], tipoMysql: m[2].toLowerCase() });
  }
}

// o dump repete USE/CREATE em duas seções; fica a primeira ocorrência de cada tabela
const vistas = new Set();
const unicas = tabelas.filter((t) => {
  const k = `${t.db}.${t.nome}`;
  if (vistas.has(k)) return false;
  vistas.add(k);
  return true;
});

// ---------- 2. aplicar as regras ----------
function entra(t) {
  const r = ENTRAM[t.db];
  if (!r) return false;
  if (!(r.exatas.includes(t.nome) || r.prefixos.some((p) => t.nome.startsWith(p)))) return false;
  return !NAO_ENTRAM_TABELA.some((re) => re.test(t.nome));
}

function tipoPg(base) {
  if (["tinyint", "smallint", "mediumint", "int", "integer", "bigint", "year"].includes(base)) return { pg: "bigint", k: "int" };
  if (["float", "double", "real", "decimal", "numeric"].includes(base)) return { pg: "numeric", k: "num" };
  if (["char"].includes(base)) return { pg: "text", k: "char" };
  if (["varchar", "text", "tinytext", "mediumtext", "longtext", "enum", "set", "time"].includes(base)) return { pg: "text", k: "txt" };
  if (base === "date") return { pg: "date", k: "date" };
  if (["datetime", "timestamp"].includes(base)) return { pg: "timestamp", k: "ts" };
  throw new Error(`Tipo MySQL sem mapeamento: ${base}`);
}

const manifesto = [];
const omitidas = [];
for (const t of unicas.filter(entra)) {
  const cols = [];
  for (const c of t.colunas) {
    if (TIPOS_BINARIOS.includes(c.tipoMysql)) { omitidas.push(`${t.db}.${t.nome}.${c.nome} (arquivo)`); continue; }
    if (NAO_ENTRAM_COLUNA.some((re) => re.test(c.nome))) { omitidas.push(`${t.db}.${t.nome}.${c.nome} (sensível)`); continue; }
    const { pg, k } = tipoPg(c.tipoMysql);
    cols.push({ mysql: c.nome, pg: c.nome.toLowerCase(), tipo: pg, k });
  }
  if (cols.length === 0) continue;
  const nomes = new Set(cols.map((c) => c.pg));
  if (nomes.size !== cols.length) throw new Error(`Colunas repetidas (maiúscula/minúscula) em ${t.db}.${t.nome}`);
  const indice = t.indice.map((n) => n.toLowerCase()).filter((n) => nomes.has(n));
  manifesto.push({
    db: t.db, schema: SCHEMAS[t.db], tabela: t.nome.toLowerCase(), tabelaMysql: t.nome,
    colunas: cols, indice: indice.length === t.indice.length ? indice : [],
  });
}

// ---------- 3. escrever tabelas.json ----------
writeFileSync(join(aqui, "tabelas.json"), JSON.stringify(manifesto, null, 1) + "\n");

// ---------- 4. escrever a migração ----------
const q = (s) => `"${s.replaceAll('"', '""')}"`;
const schemas = Object.values(SCHEMAS);
let sql = `-- =====================================================================
-- Topcon Suite — área de stand by (GERADO por tools/topcon/gerar.mjs; não edite à mão)
-- Cópia crua e somente leitura do que existe no Topcon, para análise futura.
-- Nada daqui é usado pelas telas do ERP. Fechado para anon/authenticated:
-- só o dono do banco (postgres/service_role) enxerga.
-- Tabelas: ${manifesto.length} | colunas omitidas (segredo/arquivo): ${omitidas.length}
-- =====================================================================

`;
for (const s of schemas) sql += `create schema if not exists ${q(s)};\n`;
sql += `
do $$
declare s text; r text;
begin
  foreach s in array array[${schemas.map((x) => `'${x}'`).join(", ")}] loop
    execute format('revoke all on schema %I from public', s);
    for r in select rolname from pg_roles where rolname in ('anon', 'authenticated') loop
      execute format('revoke all on schema %I from %I', s, r);
      execute format('alter default privileges in schema %I revoke all on tables from %I', s, r);
    end loop;
  end loop;
end $$;

-- controle: o que foi carregado, de qual cópia, quando
create table if not exists topcon_sys.carga_controle (
  schema_nome text not null,
  tabela      text not null,
  linhas      bigint not null,
  origem      text,
  carregado_em timestamptz not null default now(),
  primary key (schema_nome, tabela)
);
alter table topcon_sys.carga_controle enable row level security;

`;
for (const t of manifesto) {
  const nome = `${q(t.schema)}.${q(t.tabela)}`;
  sql += `create table if not exists ${nome} (\n`;
  sql += t.colunas.map((c) => `  ${q(c.pg)} ${c.tipo}`).join(",\n");
  sql += `\n);\n`;
  if (t.indice.length) sql += `create index if not exists ${q(`ix_${t.tabela}`.slice(0, 60))} on ${nome} (${t.indice.map(q).join(", ")});\n`;
  sql += `alter table ${nome} enable row level security;\n`;
}

// o índice precisa de nome único por schema: conferido abaixo
const nomesIdx = new Map();
for (const t of manifesto.filter((x) => x.indice.length)) {
  const k = `${t.schema}.${`ix_${t.tabela}`.slice(0, 60)}`;
  if (nomesIdx.has(k)) throw new Error(`Nome de índice repetido: ${k}`);
  nomesIdx.set(k, 1);
}

const dataHora = "20261102000000";
const destino = resolve(aqui, "..", "..", "supabase", "migrations", `${dataHora}_topcon_standby.sql`);
writeFileSync(destino, sql);

// ---------- 5. resumo ----------
const porSchema = {};
for (const t of manifesto) porSchema[t.schema] = (porSchema[t.schema] ?? 0) + 1;
console.log(`Tabelas: ${manifesto.length}`, porSchema);
console.log(`Colunas omitidas: ${omitidas.length}`);
writeFileSync(join(aqui, "omitidas.txt"), omitidas.join("\n") + "\n");
console.log("Escrevi tools/topcon/tabelas.json, omitidas.txt e", destino.replace(resolve(aqui, "..", ".."), "."));

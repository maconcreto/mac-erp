#!/usr/bin/env node
/*
 * Carrega a área de stand by (schemas topcon_*) no Supabase com os dados do Topcon.
 *
 * LÊ de um MySQL restaurado no SEU PC (cópia do backup) e ESCREVE só nos schemas topcon_*
 * do Supabase. Nunca toca no Topcon de produção: recusa a porta 20306.
 *
 * Sem --executar ele só CONTA (lê o MySQL, não escreve em lugar nenhum) e mostra o tamanho
 * de cada tabela, para você decidir o que entra.
 *
 * Uso:
 *   node carregar.mjs                         # só conta e mostra tamanhos
 *   node carregar.mjs --executar              # carrega tudo (apaga e recarrega cada tabela)
 *   node carregar.mjs --executar --so "^con_equipamento$|^man_"
 *   node carregar.mjs --executar --excluir "_versao$" --max-mb-tabela 150
 *
 * Variáveis de ambiente:
 *   DATABASE_URL   conexão do Supabase (Connect → Session pooler). Só com --executar.
 *   MYSQL_HOST (127.0.0.1)  MYSQL_PORTA (3307)  MYSQL_USUARIO (root)  MYSQL_SENHA (local123)
 */
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { Transform } from "node:stream";
import { pipeline } from "node:stream/promises";
import mysql from "mysql2";
import pg from "pg";
import { from as copyFrom } from "pg-copy-streams";

const aqui = dirname(fileURLToPath(import.meta.url));

// ---------- conversão de linha MySQL -> linha CSV do COPY ----------
const DATA = /^(\d{4})-(\d{2})-(\d{2})$/;
const DATAHORA = /^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2}):(\d{2})(\.\d+)?$/;

function dataValida(a, m, d) {
  const ano = +a, mes = +m, dia = +d;
  if (ano < 1 || mes < 1 || mes > 12 || dia < 1) return false;
  return dia <= new Date(Date.UTC(ano, mes, 0)).getUTCDate();
}

export function converter(valor, k) {
  if (valor === null || valor === undefined) return null;
  switch (k) {
    case "int":
    case "num":
      return String(valor);
    case "char":
      return String(valor).replaceAll("\0", "").replace(/ +$/, "");
    case "txt":
      return String(valor).replaceAll("\0", "");
    case "date": {
      const m = String(valor).match(DATA);
      return m && dataValida(m[1], m[2], m[3]) ? String(valor) : null; // 0000-00-00 vira nulo
    }
    case "ts": {
      const m = String(valor).match(DATAHORA);
      if (!m || !dataValida(m[1], m[2], m[3]) || +m[4] > 23 || +m[5] > 59 || +m[6] > 59) return null;
      return String(valor);
    }
    default:
      throw new Error(`Tipo interno desconhecido: ${k}`);
  }
}

export function linhaCsv(linha, colunas) {
  const partes = new Array(colunas.length);
  for (let i = 0; i < colunas.length; i++) {
    const v = converter(linha[i], colunas[i].k);
    partes[i] = v === null ? "" : `"${v.replaceAll('"', '""')}"`; // nulo = vazio sem aspas
  }
  return partes.join(",") + "\n";
}

// ---------- argumentos ----------
function argumentos(argv) {
  const a = { executar: false, so: null, excluir: null, maxMbTabela: null, origem: null };
  for (let i = 0; i < argv.length; i++) {
    const x = argv[i];
    if (x === "--executar") a.executar = true;
    else if (x === "--so") a.so = new RegExp(argv[++i], "i");
    else if (x === "--excluir") a.excluir = new RegExp(argv[++i], "i");
    else if (x === "--max-mb-tabela") a.maxMbTabela = Number(argv[++i]);
    else if (x === "--origem") a.origem = argv[++i];
    else fim(`Opção desconhecida: ${x}`);
  }
  return a;
}
function fim(msg) {
  console.error(msg);
  process.exit(1);
}
const mb = (bytes) => (bytes / 1024 / 1024).toFixed(1);

// ---------- principal ----------
async function main() {
  const arg = argumentos(process.argv.slice(2));
  const host = process.env.MYSQL_HOST ?? "127.0.0.1";
  const porta = Number(process.env.MYSQL_PORTA ?? 3307);
  if (porta === 20306) fim("Porta 20306 é a do Topcon de PRODUÇÃO. Use a cópia restaurada no seu PC (porta 3307).");

  const manifesto = JSON.parse(readFileSync(join(aqui, "tabelas.json"), "utf8"));
  const escolhidas = manifesto.filter(
    (t) => (!arg.so || arg.so.test(t.tabela)) && !(arg.excluir && arg.excluir.test(t.tabela)),
  );

  const conectar = () =>
    mysql.createConnection({
      host, port: porta,
      user: process.env.MYSQL_USUARIO ?? "root",
      password: process.env.MYSQL_SENHA ?? "local123",
      charset: "utf8mb4",
      dateStrings: true,
      supportBigNumbers: true,
      bigNumberStrings: true,
      rowsAsArray: true,
    });
  let my = conectar();
  const consulta = (sql, params) =>
    new Promise((ok, erro) => my.query(sql, params, (e, r) => (e ? erro(e) : ok(r))));

  // tamanhos e contagens aproximadas direto do MySQL
  const info = new Map();
  for (const bd of [...new Set(escolhidas.map((t) => t.db))]) {
    const linhas = await consulta(
      "select table_name, table_rows, data_length + index_length from information_schema.tables where table_schema = ?",
      [bd],
    );
    for (const [nome, rows, bytes] of linhas) info.set(`${bd}.${String(nome).toLowerCase()}`, { rows: Number(rows), bytes: Number(bytes) });
  }

  const faltando = [];
  const plano = [];
  for (const t of escolhidas) {
    const i = info.get(`${t.db}.${t.tabela}`);
    if (!i) { faltando.push(`${t.db}.${t.tabelaMysql}`); continue; }
    const grande = arg.maxMbTabela != null && i.bytes / 1024 / 1024 > arg.maxMbTabela && !arg.so;
    plano.push({ ...t, ...i, pular: grande });
  }

  plano.sort((a, b) => b.bytes - a.bytes);
  console.log(`\nMySQL ${host}:${porta} — ${plano.length} tabelas no plano`);
  console.log("Maiores tabelas (MB no MySQL ≈ MB no Supabase):");
  for (const t of plano.slice(0, 25)) {
    console.log(`  ${mb(t.bytes).padStart(8)} MB  ${String(t.rows).padStart(10)} linhas  ${t.db}.${t.tabelaMysql}${t.pular ? "   [PULADA: acima de --max-mb-tabela]" : ""}`);
  }
  const total = plano.filter((t) => !t.pular).reduce((s, t) => s + t.bytes, 0);
  console.log(`\nTotal a carregar: ${mb(total)} MB em ${plano.filter((t) => !t.pular).length} tabelas`);
  if (faltando.length) console.log(`Tabelas do plano que não existem nesse MySQL: ${faltando.length} (ex.: ${faltando.slice(0, 3).join(", ")})`);

  if (!arg.executar) {
    console.log("\nSó contagem (nada foi escrito). Para carregar: acrescente --executar e defina DATABASE_URL.");
    my.end();
    return;
  }

  // ---------- carga ----------
  const url = process.env.DATABASE_URL;
  if (!url) fim("Defina DATABASE_URL (Supabase → Connect → Session pooler) antes de usar --executar.");
  const u = new URL(url);
  const local = ["localhost", "127.0.0.1"].includes(u.hostname);
  u.searchParams.delete("sslmode");
  const cli = new pg.Client({ connectionString: u.toString(), ssl: local ? false : { rejectUnauthorized: false } });
  await cli.connect();
  await cli.query("set statement_timeout = 0");
  const existe = await cli.query("select 1 from information_schema.schemata where schema_name = 'topcon_sys'");
  if (existe.rowCount === 0) fim("O schema topcon_sys não existe nesse banco. Aplique antes a migração 20261102000000_topcon_standby.sql.");

  const origem = arg.origem ?? `mysql ${host}:${porta}`;
  const falhas = [];
  let feitas = 0;
  for (const t of plano.filter((x) => !x.pular)) {
    const alvo = `"${t.schema}"."${t.tabela}"`;
    const colsPg = t.colunas.map((c) => `"${c.pg}"`).join(", ");
    const colsMy = t.colunas.map((c) => `\`${c.mysql.replaceAll("`", "``")}\``).join(", ");
    const inicio = Date.now();
    let linhas = 0;
    try {
      await cli.query("begin");
      await cli.query(`truncate ${alvo}`);
      const origemRows = my.query({ sql: `select ${colsMy} from \`${t.db}\`.\`${t.tabelaMysql}\``, rowsAsArray: true }).stream({ highWaterMark: 2000 });
      const paraCsv = new Transform({
        writableObjectMode: true,
        transform(linha, _enc, cb) {
          linhas++;
          try { cb(null, linhaCsv(linha, t.colunas)); } catch (e) { cb(e); }
        },
      });
      const destino = cli.query(copyFrom(`copy ${alvo} (${colsPg}) from stdin with (format csv)`));
      await pipeline(origemRows, paraCsv, destino);
      await cli.query(
        `insert into topcon_sys.carga_controle (schema_nome, tabela, linhas, origem, carregado_em)
         values ($1, $2, $3, $4, now())
         on conflict (schema_nome, tabela) do update set linhas = excluded.linhas, origem = excluded.origem, carregado_em = now()`,
        [t.schema, t.tabela, linhas, origem],
      );
      await cli.query("commit");
      feitas++;
      console.log(`ok  ${String(linhas).padStart(9)} linhas  ${((Date.now() - inicio) / 1000).toFixed(1).padStart(6)}s  ${t.schema}.${t.tabela}`);
    } catch (e) {
      await cli.query("rollback").catch(() => {});
      my.destroy(); // a leitura interrompida pode deixar a conexão presa: abre outra
      my = conectar();
      falhas.push(`${t.schema}.${t.tabela}: ${e.message}`);
      console.log(`ERRO ${t.schema}.${t.tabela}: ${e.message}`);
    }
  }

  const uso = await cli.query(
    `select pg_size_pretty(coalesce(sum(pg_total_relation_size(c.oid)), 0)) as tamanho
       from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname like 'topcon\\_%' and c.relkind = 'r'`,
  );
  console.log(`\nConcluído: ${feitas} tabelas carregadas, ${falhas.length} com erro. Ocupação dos schemas topcon_*: ${uso.rows[0].tamanho}`);
  if (falhas.length) console.log("Falhas:\n  " + falhas.join("\n  "));
  await cli.end();
  my.end();
  if (falhas.length) process.exitCode = 2;
}

// só roda quando chamado direto (permite testar `converter` e `linhaCsv` isoladamente)
if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((e) => fim(`Falhou: ${e.message}`));
}

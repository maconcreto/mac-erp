// Regras de seleção do que vai para a área de stand by. Edite aqui e rode `npm run gerar` de novo.

// schema no Supabase <- banco no Topcon
export const SCHEMAS = { topsys: "topcon_sys", topgeral: "topcon_geral", topfixo: "topcon_fixo" };

// Quais tabelas entram (por banco). Prefixo = começa com; exato = nome inteiro.
export const ENTRAM = {
  topsys: { prefixos: ["con_", "man_", "fin_", "com_", "fis_", "ger_", "pdr_", "atf_", "integracao_fleetcom", "fat_"], exatas: [] },
  topgeral: { prefixos: ["ger_"], exatas: ["usr_empresa", "fis_operfiscal"] },
  topfixo: { prefixos: [], exatas: ["fix_municipio", "fix_estado", "fix_paises", "fix_ncm", "fix_cfop", "fix_cep"] },
};

// Fora: temporárias, cópias de segurança, logs/auditoria e filas internas do Topcon.
export const NAO_ENTRAM_TABELA = [
  /(^|_)(tmp|bkp|backup)(_|$)/i,
  /idt\d+/i,
  /_log(_item)?$/i,
  /^ger_db_events/i,
  /geocoding/i,
  /^ger_cons_sql$/i,
  /^ger_ver_master_log$/i,
  // dados pessoais/folha de funcionários: só entram se você decidir depois
  /^con_func_(complem|conta|plano_dep|retir|ocorr|anexo|ajuste_vlr|loc_tra)/i,
  /^con_(mot_aj_func|horas_func|dados_pes_manual|excesso_horas_motorista|ponto_registro)$/i,
  /^con_cartao_transacao$/i,
];

// Colunas que nunca saem do Topcon: segredos, cartão, salário, Pix.
export const NAO_ENTRAM_COLUNA = [
  /(^|_)senha/i,
  /^senha(_|$)/i,
  /password|passwd|(^|_)pwd(_|$)/i,
  /num_cartao/i,
  /cartaocred/i,
  /salario/i,
  /chave_pix/i,
  /^senha_ws$|^senha_oobj$/i,
];

// Tipos MySQL que viram texto/arquivo e ficam de fora (blob).
export const TIPOS_BINARIOS = ["blob", "tinyblob", "mediumblob", "longblob", "binary", "varbinary", "bit"];

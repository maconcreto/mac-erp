-- =====================================================================
-- Topcon Suite — área de stand by (GERADO por tools/topcon/gerar.mjs; não edite à mão)
-- Cópia crua e somente leitura do que existe no Topcon, para análise futura.
-- Nada daqui é usado pelas telas do ERP. Fechado para anon/authenticated:
-- só o dono do banco (postgres/service_role) enxerga.
-- Tabelas: 687 | colunas omitidas (segredo/arquivo): 28
-- =====================================================================

create schema if not exists "topcon_sys";
create schema if not exists "topcon_geral";
create schema if not exists "topcon_fixo";

do $$
declare s text; r text;
begin
  foreach s in array array['topcon_sys', 'topcon_geral', 'topcon_fixo'] loop
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

create table if not exists "topcon_sys"."atf_codctb" (
  "ger_empresa_cod" bigint,
  "atf_codctb_ctaanalit" bigint,
  "atf_codctb_seq" bigint,
  "atf_codctb_descr" text,
  "atf_codctb_empdepracum" bigint,
  "atf_codctb_depracum" bigint,
  "atf_codctb_empdespdepr" bigint,
  "atf_codctb_despdepr" bigint,
  "atf_codctb_txdepranual" numeric,
  "atf_codctb_fatordepr" numeric,
  "atf_codctb_imobandamento" text,
  "atf_codctb_credpiscofinsncumul" bigint,
  "atf_codctb_idcadast" text,
  "atf_codctb_idatual" text
);
create index if not exists "ix_atf_codctb" on "topcon_sys"."atf_codctb" ("ger_empresa_cod", "atf_codctb_ctaanalit", "atf_codctb_seq");
alter table "topcon_sys"."atf_codctb" enable row level security;
create table if not exists "topcon_sys"."atf_controle" (
  "atf_controle_emp" bigint,
  "atf_controle_inicioexer" bigint,
  "atf_controle_inicioexerdt" date,
  "atf_controle_proxdepr" bigint,
  "atf_controle_proxdeprdt" date,
  "atf_controle_emphist" bigint,
  "atf_controle_codhist" bigint,
  "atf_controle_pctpisncum" numeric,
  "atf_controle_empctapisncum" bigint,
  "atf_controle_ctapisncum" bigint,
  "atf_controle_emphistpis" bigint,
  "atf_controle_histpisncum" bigint,
  "atf_controle_pctcofinsncum" numeric,
  "atf_controle_empctacofinsncum" bigint,
  "atf_controle_ctacofinsncum" bigint,
  "atf_controle_emphistcofins" bigint,
  "atf_controle_histcofinsncum" bigint,
  "atf_controle_idcadast" text,
  "atf_controle_idatual" text
);
create index if not exists "ix_atf_controle" on "topcon_sys"."atf_controle" ("atf_controle_emp");
alter table "topcon_sys"."atf_controle" enable row level security;
create table if not exists "topcon_sys"."atf_deprec" (
  "ger_empresa_cod" bigint,
  "atf_imobil_numitem" bigint,
  "atf_imobil_seqitem" bigint,
  "atf_deprec_mesanodepr" bigint,
  "atf_deprec_datadepr" date,
  "atf_deprec_depracumul" bigint,
  "atf_deprec_empctadepracum" bigint,
  "atf_deprec_ctadepracumul" bigint,
  "atf_deprec_empctadeprdesp" bigint,
  "atf_deprec_ctadeprdesp" bigint,
  "atf_deprec_empccdesp" bigint,
  "atf_deprec_ccctadesp" bigint,
  "atf_deprec_vlrdepr" numeric,
  "atf_deprec_txdepranual" numeric,
  "atf_deprec_vlrpisncum" numeric,
  "atf_deprec_vlrcofinsncum" numeric,
  "atf_deprec_idcadast" text
);
create index if not exists "ix_atf_deprec" on "topcon_sys"."atf_deprec" ("ger_empresa_cod", "atf_imobil_numitem", "atf_imobil_seqitem", "atf_deprec_mesanodepr");
alter table "topcon_sys"."atf_deprec" enable row level security;
create table if not exists "topcon_sys"."atf_imoband" (
  "ger_empresa_cod" bigint,
  "atf_projeto_cod" bigint,
  "atf_imoband_numitem" bigint,
  "atf_imoband_descr" text,
  "atf_imoband_descrcomp" text,
  "atf_imoband_fornecedor" text,
  "atf_imoband_obs" text,
  "atf_imoband_numnf" bigint,
  "atf_imoband_dtadicao" date,
  "atf_imoband_vlrcusto" numeric,
  "atf_imoband_vlrorig" numeric,
  "atf_imoband_dtimobil" date,
  "atf_imoband_numitemdest" bigint,
  "atf_imoband_seqitemdest" bigint,
  "atf_imoband_idcadast" text,
  "atf_imoband_idatual" text
);
create index if not exists "ix_atf_imoband" on "topcon_sys"."atf_imoband" ("ger_empresa_cod", "atf_projeto_cod", "atf_imoband_numitem");
alter table "topcon_sys"."atf_imoband" enable row level security;
create table if not exists "topcon_sys"."atf_imobil" (
  "ger_empresa_cod" bigint,
  "atf_imobil_numitem" bigint,
  "atf_imobil_seqitem" bigint,
  "atf_imobil_descr" text,
  "atf_imobil_descrcompl" text,
  "atf_imobil_fornecedor" text,
  "atf_imobil_numnf" bigint,
  "atf_imobil_numpatrimonial" text,
  "empresacodctb" bigint,
  "ctaanaliticacodctb" bigint,
  "seqcodctb" bigint,
  "empresaccanalitico" bigint,
  "ccanalitico" bigint,
  "atf_local_cod" bigint,
  "atf_seguro_cod" bigint,
  "atf_imobil_coddepr" bigint,
  "atf_imobil_dtadicao" date,
  "atf_imobil_codadicao" bigint,
  "atf_imobil_dtbaixa" date,
  "atf_imobil_codbaixa" bigint,
  "atf_imobil_vlroriginal" numeric,
  "atf_imobil_vlrcusto" numeric,
  "atf_imobil_deprexercicio" numeric,
  "atf_imobil_depracumexant" numeric,
  "atf_imobil_obs" text,
  "atf_imobil_idcadast" text,
  "atf_imobil_idatual" text
);
create index if not exists "ix_atf_imobil" on "topcon_sys"."atf_imobil" ("ger_empresa_cod", "atf_imobil_numitem", "atf_imobil_seqitem");
alter table "topcon_sys"."atf_imobil" enable row level security;
create table if not exists "topcon_sys"."atf_imobilhist" (
  "ger_empresa_cod" bigint,
  "atf_imobil_numitem" bigint,
  "atf_imobil_seqitem" bigint,
  "aft_imobilhist_tpalteracao" bigint,
  "aft_imobilhist_seq" bigint,
  "aft_imobilhist_dtalteracao" date,
  "aft_imobilhist_codatual" bigint,
  "aft_imobilhist_seqcodatual" bigint,
  "aft_imobilhist_codnovo" bigint,
  "aft_imobilhist_seqcodnovo" bigint,
  "aft_imobilhist_obsevacao" text,
  "aft_imobilhist_idcadast" text
);
create index if not exists "ix_atf_imobilhist" on "topcon_sys"."atf_imobilhist" ("ger_empresa_cod", "atf_imobil_numitem", "atf_imobil_seqitem", "aft_imobilhist_tpalteracao", "aft_imobilhist_seq");
alter table "topcon_sys"."atf_imobilhist" enable row level security;
create table if not exists "topcon_sys"."atf_local" (
  "atf_local_cod" bigint,
  "atf_local_descr" text,
  "atf_local_idcadast" text,
  "atf_local_idatual" text
);
create index if not exists "ix_atf_local" on "topcon_sys"."atf_local" ("atf_local_cod");
alter table "topcon_sys"."atf_local" enable row level security;
create table if not exists "topcon_sys"."atf_projeto" (
  "ger_empresa_cod" bigint,
  "atf_projeto_cod" bigint,
  "atf_projeto_descr" text,
  "atf_codctb_ctaanalit" bigint,
  "atf_codctb_seq" bigint,
  "atf_projeto_dtiniproj" date,
  "atf_projeto_dtimob" date,
  "atf_projeto_idcadast" text,
  "atf_projeto_idatual" text
);
create index if not exists "ix_atf_projeto" on "topcon_sys"."atf_projeto" ("ger_empresa_cod", "atf_projeto_cod");
alter table "topcon_sys"."atf_projeto" enable row level security;
create table if not exists "topcon_sys"."atf_seguro" (
  "atf_seguro_cod" bigint,
  "atf_seguro_descr" text,
  "atf_seguro_idcadast" text,
  "atf_seguro_idatual" text
);
create index if not exists "ix_atf_seguro" on "topcon_sys"."atf_seguro" ("atf_seguro_cod");
alter table "topcon_sys"."atf_seguro" enable row level security;
create table if not exists "topcon_sys"."com_abast_externo" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "sequencia" bigint,
  "filial" bigint,
  "preco_unit" numeric,
  "status" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_abast_externo" on "topcon_sys"."com_abast_externo" ("empresa", "ano_requisicao", "no_requisicao", "sequencia");
alter table "topcon_sys"."com_abast_externo" enable row level security;
create table if not exists "topcon_sys"."com_abast_externo_cap" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "no_lancamento" bigint
);
create index if not exists "ix_com_abast_externo_cap" on "topcon_sys"."com_abast_externo_cap" ("empresa", "ano_requisicao", "no_requisicao", "no_lancamento");
alter table "topcon_sys"."com_abast_externo_cap" enable row level security;
create table if not exists "topcon_sys"."com_ccustos_usr" (
  "usuario" text,
  "ccustos" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_ccustos_usr" on "topcon_sys"."com_ccustos_usr" ("usuario");
alter table "topcon_sys"."com_ccustos_usr" enable row level security;
create table if not exists "topcon_sys"."com_cotacao" (
  "empresa" bigint,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "dt_inicio" date,
  "comprador" bigint,
  "dt_conclusao" date,
  "id_cadast" text,
  "id_atual" text,
  "total_selecao" numeric,
  "total_menor_vlr" numeric,
  "status" bigint,
  "id_aprov" text,
  "dt_abert_tela" timestamp
);
create index if not exists "ix_com_cotacao" on "topcon_sys"."com_cotacao" ("empresa", "ano_cotacao", "no_cotacao");
alter table "topcon_sys"."com_cotacao" enable row level security;
create table if not exists "topcon_sys"."com_cotacao_forn" (
  "empresa" bigint,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "sequencia" bigint,
  "fornecedor" bigint,
  "preco_unitario" numeric,
  "vlr_ipi" numeric,
  "vlr_icms" numeric,
  "vlr_desconto" numeric,
  "vlr_acrescimo" numeric,
  "custo_unitario" numeric,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "seq_pedido" bigint,
  "seq_item_pedido" bigint,
  "vlr_ipi_global" numeric,
  "vlr_icms_global" numeric,
  "vlr_desc_global" numeric,
  "vlr_acre_global" numeric,
  "vlr_fret_global" numeric,
  "total_unitario" numeric,
  "selecao" text,
  "cod_ref_forn" text,
  "vlr_desc_g_serv" numeric,
  "pct_ipi" numeric,
  "pct_icms" numeric,
  "pct_desconto" numeric,
  "pct_acrescimo" numeric,
  "pct_ipi_global" numeric,
  "pct_icms_global" numeric,
  "pct_desc_global" numeric,
  "pct_acre_global" numeric,
  "pct_fret_global" numeric,
  "pct_desc_g_serv" numeric
);
create index if not exists "ix_com_cotacao_forn" on "topcon_sys"."com_cotacao_forn" ("empresa", "ano_cotacao", "no_cotacao", "sequencia", "fornecedor");
alter table "topcon_sys"."com_cotacao_forn" enable row level security;
create table if not exists "topcon_sys"."com_cotacao_item" (
  "empresa" bigint,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "sequencia" bigint,
  "material" text,
  "especificacao" text,
  "quantidade" numeric,
  "unidade" text,
  "observacao" text,
  "id_cadast" text,
  "id_atual" text,
  "vlr_selecao" numeric,
  "vlr_menor_valor" numeric,
  "prod_serv" text
);
create index if not exists "ix_com_cotacao_item" on "topcon_sys"."com_cotacao_item" ("empresa", "ano_cotacao", "no_cotacao", "sequencia");
alter table "topcon_sys"."com_cotacao_item" enable row level security;
create table if not exists "topcon_sys"."com_cotacao_parc" (
  "empresa" bigint,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "fornecedor" bigint,
  "parcelas" bigint,
  "dt_parcelas" date,
  "pct_parcela" numeric,
  "tp_cobranca" bigint
);
create index if not exists "ix_com_cotacao_parc" on "topcon_sys"."com_cotacao_parc" ("empresa", "ano_cotacao", "no_cotacao", "fornecedor", "parcelas");
alter table "topcon_sys"."com_cotacao_parc" enable row level security;
create table if not exists "topcon_sys"."com_cotacao_total" (
  "empresa" bigint,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "fornecedor" bigint,
  "cond_pagto" bigint,
  "observacao" text,
  "sub_total" numeric,
  "vlr_ipi" numeric,
  "vlr_icms" numeric,
  "vlr_desconto" numeric,
  "vlr_acrescimo" numeric,
  "vlr_frete" numeric,
  "vlr_total" numeric,
  "dt_prev_entrega" date,
  "id_aprovacao" text,
  "vlr_total_sel" numeric,
  "contato_default" bigint,
  "compl_prev_entr" text,
  "dt_base_venc" text,
  "cotacao_obrigat" text,
  "vlr_desc_serv" numeric
);
create index if not exists "ix_com_cotacao_total" on "topcon_sys"."com_cotacao_total" ("empresa", "ano_cotacao", "no_cotacao", "fornecedor");
alter table "topcon_sys"."com_cotacao_total" enable row level security;
create table if not exists "topcon_sys"."com_familia" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_familia" on "topcon_sys"."com_familia" ("cod");
alter table "topcon_sys"."com_familia" enable row level security;
create table if not exists "topcon_sys"."com_filtro_filial" (
  "usuario" text,
  "filtros_filiais" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_filtro_filial" on "topcon_sys"."com_filtro_filial" ("usuario");
alter table "topcon_sys"."com_filtro_filial" enable row level security;
create table if not exists "topcon_sys"."com_integ_abast_pendente" (
  "id" text,
  "id_integracao_abast" text,
  "filial" bigint,
  "centro_custo" bigint,
  "data" date,
  "hora" text,
  "requisitante" bigint,
  "combustivel" text,
  "volume" numeric,
  "vlr_unit" numeric,
  "vlr_total" numeric,
  "veiculo_equip" text,
  "horimetro_equip" numeric,
  "km_equip" bigint,
  "status" text,
  "id_delete" text
);
create index if not exists "ix_com_integ_abast_pendente" on "topcon_sys"."com_integ_abast_pendente" ("id");
alter table "topcon_sys"."com_integ_abast_pendente" enable row level security;
create table if not exists "topcon_sys"."com_invent_mov_estq" (
  "filial" bigint,
  "seq" bigint,
  "local" text,
  "seq_item" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint
);
create index if not exists "ix_com_invent_mov_estq" on "topcon_sys"."com_invent_mov_estq" ("filial", "seq", "local", "seq_item", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "num_seq_item_nf");
alter table "topcon_sys"."com_invent_mov_estq" enable row level security;
create table if not exists "topcon_sys"."com_inventario" (
  "filial" bigint,
  "seq" bigint,
  "local" text,
  "usuario" text,
  "dt_contagem" date,
  "data_hora" timestamp,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text
);
create index if not exists "ix_com_inventario" on "topcon_sys"."com_inventario" ("seq", "filial", "local");
alter table "topcon_sys"."com_inventario" enable row level security;
create table if not exists "topcon_sys"."com_inventario_item" (
  "filial" bigint,
  "seq" bigint,
  "local" text,
  "seq_item" bigint,
  "material" text,
  "quant" numeric,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text
);
create index if not exists "ix_com_inventario_item" on "topcon_sys"."com_inventario_item" ("filial", "seq", "local", "seq_item");
alter table "topcon_sys"."com_inventario_item" enable row level security;
create table if not exists "topcon_sys"."com_item_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "grupo" bigint,
  "subgrupo" bigint,
  "item" bigint,
  "subitem" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "item_pedido" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "item_requisicao" bigint,
  "equipamento" text,
  "centro_custo" bigint,
  "empresa" bigint,
  "seq_pedido" bigint
);
create index if not exists "ix_com_item_nf" on "topcon_sys"."com_item_nf" ("filial", "interv", "tp_doc", "ser", "num_nf", "seq_nf", "num_seq_item_nf");
alter table "topcon_sys"."com_item_nf" enable row level security;
create table if not exists "topcon_sys"."com_local_estoque" (
  "filial" bigint,
  "cod" text,
  "descr" text,
  "periodicidade" bigint,
  "perm_apenas_um" bigint,
  "qtd_max_div" numeric,
  "id_cadast" text,
  "id_atual" text,
  "external_id" text
);
create index if not exists "ix_com_local_estoque" on "topcon_sys"."com_local_estoque" ("filial", "cod");
alter table "topcon_sys"."com_local_estoque" enable row level security;
create table if not exists "topcon_sys"."com_local_estq_item" (
  "filial" bigint,
  "cod" text,
  "material" text,
  "familia" bigint,
  "seq_item" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_local_estq_item" on "topcon_sys"."com_local_estq_item" ("filial", "cod", "material", "seq_item");
alter table "topcon_sys"."com_local_estq_item" enable row level security;
create table if not exists "topcon_sys"."com_local_inc_nf" (
  "id" text,
  "id_incons" text,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint
);
create index if not exists "ix_com_local_inc_nf" on "topcon_sys"."com_local_inc_nf" ("id");
alter table "topcon_sys"."com_local_inc_nf" enable row level security;
create table if not exists "topcon_sys"."com_local_inconsist" (
  "id" text,
  "filial" bigint,
  "cod" text,
  "material" text,
  "dt_hr_incons" timestamp,
  "id_resolucao" text
);
create index if not exists "ix_com_local_inconsist" on "topcon_sys"."com_local_inconsist" ("id");
alter table "topcon_sys"."com_local_inconsist" enable row level security;
create table if not exists "topcon_sys"."com_log_altera_nf" (
  "id" text,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "dt_alteracao" date,
  "hr_alteracao" timestamp,
  "usuario" text,
  "campo" text,
  "valor_anterior" text,
  "valor_novo" text
);
create index if not exists "ix_com_log_altera_nf" on "topcon_sys"."com_log_altera_nf" ("id");
alter table "topcon_sys"."com_log_altera_nf" enable row level security;
create table if not exists "topcon_sys"."com_mat_servico" (
  "cod_servico" text,
  "cod_material" text,
  "qtd_material" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_mat_servico" on "topcon_sys"."com_mat_servico" ("cod_servico", "cod_material");
alter table "topcon_sys"."com_mat_servico" enable row level security;
create table if not exists "topcon_sys"."com_mens_pedido" (
  "empresa" bigint,
  "inicio_validade" date,
  "sequencia" bigint,
  "mensagem" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_mens_pedido" on "topcon_sys"."com_mens_pedido" ("empresa", "inicio_validade", "sequencia");
alter table "topcon_sys"."com_mens_pedido" enable row level security;
create table if not exists "topcon_sys"."com_merc_combustivel" (
  "cod_material" text,
  "cod_combustivel" bigint,
  "op_abast_externo" bigint,
  "id_cadast" text,
  "id_atual" text,
  "cod_comb_cta" text,
  "op_abast_interno" bigint
);
create index if not exists "ix_com_merc_combustivel" on "topcon_sys"."com_merc_combustivel" ("cod_material", "cod_combustivel");
alter table "topcon_sys"."com_merc_combustivel" enable row level security;
create table if not exists "topcon_sys"."com_mov_estoque" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "dt_oper" date,
  "tp_mov" text,
  "oper" text
);
create index if not exists "ix_com_mov_estoque" on "topcon_sys"."com_mov_estoque" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "dt_oper", "tp_mov", "oper");
alter table "topcon_sys"."com_mov_estoque" enable row level security;
create table if not exists "topcon_sys"."com_nfe_panalisar" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "dt_nf" date,
  "id_emissao" text,
  "dt_hora_emissao" timestamp,
  "id_validacao" text
);
create index if not exists "ix_com_nfe_panalisar" on "topcon_sys"."com_nfe_panalisar" ("filial", "interv", "tp_doc", "serie", "num_nf");
alter table "topcon_sys"."com_nfe_panalisar" enable row level security;
create table if not exists "topcon_sys"."com_nota_debito" (
  "usina" bigint,
  "no_nota_debito" bigint,
  "data" date,
  "funcionario" bigint,
  "fornecedor" bigint,
  "transportador" bigint,
  "serie" text,
  "num_nf" bigint,
  "emp_pedido" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "motorista" text,
  "placa_caminhao" text,
  "material" text,
  "unidade_entrada" text,
  "unidade_medicao" text,
  "vol_altura1" bigint,
  "vol_altura2" bigint,
  "vol_altura3" bigint,
  "vol_alt_media" bigint,
  "vol_comprimento" bigint,
  "vol_largura" bigint,
  "vol_vol_nota" numeric,
  "vol_vol_real" numeric,
  "vol_diferenca" numeric,
  "peso_peso_nf" numeric,
  "peso_peso_bruto" bigint,
  "peso_tara" bigint,
  "peso_peso_liq" bigint,
  "peso_densid_mat" numeric,
  "peso_vol_calc" numeric,
  "peso_diferenca" numeric,
  "peso_umidade" numeric,
  "apropriada" text,
  "qtde_estoque" numeric,
  "qtde_a_pagar" numeric,
  "id_cadat" text,
  "id_atual" text,
  "obs" text,
  "dt_vinculacao" date,
  "vol_densid_mat" numeric,
  "vol_vol_calc" numeric,
  "placa_carreta" text,
  "vlr_diferenca" numeric,
  "hora_descarga" text
);
create index if not exists "ix_com_nota_debito" on "topcon_sys"."com_nota_debito" ("usina", "no_nota_debito");
alter table "topcon_sys"."com_nota_debito" enable row level security;
create table if not exists "topcon_sys"."com_nota_debito_cub" (
  "usina" bigint,
  "no_nota_debito" bigint,
  "seq" bigint,
  "vol_altura1" bigint,
  "vol_altura2" bigint,
  "vol_altura3" bigint,
  "vol_alt_media" numeric,
  "vol_comprimento" bigint,
  "vol_largura" bigint,
  "vol_volume" numeric
);
create index if not exists "ix_com_nota_debito_cub" on "topcon_sys"."com_nota_debito_cub" ("usina", "no_nota_debito", "seq");
alter table "topcon_sys"."com_nota_debito_cub" enable row level security;
create table if not exists "topcon_sys"."com_nota_debito_vinc" (
  "usina" bigint,
  "no_nota_debito" bigint,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "qtde_nf" numeric,
  "qtde_estoque" numeric,
  "diferenca" numeric,
  "qtde_pagar" numeric
);
create index if not exists "ix_com_nota_debito_vinc" on "topcon_sys"."com_nota_debito_vinc" ("usina", "no_nota_debito", "filial", "interv", "tp_doc", "serie", "num_nf");
alter table "topcon_sys"."com_nota_debito_vinc" enable row level security;
create table if not exists "topcon_sys"."com_parametro" (
  "empresa" bigint,
  "aprov_requis" text,
  "id_cadast" text,
  "id_atual" text,
  "dia_entrega" bigint,
  "filial_princip" bigint,
  "vlr_limite_dif" numeric,
  "pct_limite_dif" numeric,
  "interv_rec_fed" bigint,
  "interv_inss" bigint,
  "oper_cap_iss" bigint,
  "oper_cap_irrf" bigint,
  "oper_cap_inss" bigint,
  "oper_cap_pis" bigint,
  "oper_cap_cofins" bigint,
  "oper_cap_irpj" bigint,
  "oper_cap_csll" bigint,
  "cond_pag_iss" bigint,
  "cond_pag_irrf" bigint,
  "cond_pag_inss" bigint,
  "cond_pag_pis" bigint,
  "cond_pag_cofins" bigint,
  "cond_pag_irpj" bigint,
  "cond_pag_csll" bigint,
  "dif_dias_nf" bigint,
  "dif_dias_vencto" bigint,
  "obg_ncm_entrada" text,
  "analisar_nfe_ate_horas" bigint,
  "pct_nf_debito" numeric,
  "pct_pis" numeric,
  "pct_cofins" numeric,
  "pct_iss" numeric,
  "pct_irrf" numeric,
  "pct_inss" numeric,
  "pct_irpj" numeric,
  "pct_csll" numeric,
  "prazo_aprv_just" bigint,
  "vlr_alt_icms_ip" numeric,
  "bloq_inf_icms" text,
  "util_filial_est" text,
  "hab_est_fis_nf" text,
  "pmt_req_sem_usr" text,
  "tp_cob_iss" bigint,
  "tp_cob_irrf" bigint,
  "tp_cob_inss" bigint,
  "tp_cob_pis" bigint,
  "tp_cob_cofins" bigint,
  "tp_cob_irpj" bigint,
  "tp_cob_csll" bigint,
  "disp_aprov_req" text,
  "disp_aprov_cot" text,
  "disp_aprov_ped" text,
  "disp_cienc_imp" text,
  "conf_rec_p_enc" text,
  "obriga_enc_ped" bigint,
  "dias_enc_ped" bigint,
  "prazo_max_adia" bigint,
  "dt_prox_enc_ped" date,
  "email_aprov_ped" text,
  "email_anexa_ped" text,
  "email_anexa_cot" text,
  "dias_bloq_comp" bigint,
  "imp_etq_ent_nf" text,
  "prazo_aprov_req" bigint,
  "bloq_custo_zero" text,
  "tp_doc_trans_mp" bigint,
  "sel_ped_fil_est" text,
  "form_ger_req_ma" bigint,
  "valida_o_s_req" text,
  "disp_aprov_cont" text,
  "valida_preco" text,
  "pct_tolera_preco" numeric,
  "bloq_cc_equip_diferente" text,
  "urllogin_apiintegabast" text,
  "urlretorno_apiintegabast" text,
  "usuario_apiintegabast" text,
  "fxainirequis_apiintegabast" bigint,
  "fxafinalrequis_apiintegabast" bigint,
  "idempresa_apiintegabast" text,
  "pedido_pela_raiz_cnpj" text,
  "tp_doc_trans_uso" bigint,
  "valida_xml_no_banco" text,
  "dias_busca_nft_sem_chave" bigint,
  "dt_ultima_busca" date,
  "transf_cfop_uso" bigint,
  "transf_cfop_mp" bigint,
  "transf_seq_cfop_uso" bigint,
  "transf_seq_cfop_mp" bigint,
  "transf_trib_uso" text,
  "transf_trib_mp" text,
  "transf_oper_uso" bigint,
  "transf_oper_mp" bigint,
  "confirma_receb_merc" text,
  "usa_valor_ultima_compra" text,
  "decl_trans_nat" text,
  "decl_trans_decl" text,
  "decl_trans_obs" text,
  "marg_vinc_item_ped_xml" numeric,
  "razao_social_forn_cot" text,
  "dt_ult_integ_apiintegabast" timestamp
);
create index if not exists "ix_com_parametro" on "topcon_sys"."com_parametro" ("empresa");
alter table "topcon_sys"."com_parametro" enable row level security;
create table if not exists "topcon_sys"."com_pedido" (
  "empresa" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "seq_pedido" bigint,
  "fornecedor" bigint,
  "no_pedido_forn" text,
  "dt_pedido" date,
  "comprador" bigint,
  "local_faturam" bigint,
  "local_entrega" bigint,
  "local_cobranca" bigint,
  "vlr_total" numeric,
  "vlr_frete" numeric,
  "vlr_acrescimo" numeric,
  "vlr_desconto" numeric,
  "vlr_ipi" numeric,
  "vlr_icms" numeric,
  "vlr_liquido" numeric,
  "observacao" text,
  "status" bigint,
  "prazo_entrega" date,
  "cond_pagto" bigint,
  "dependente" text,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "cancelado" text,
  "id_cancel" text,
  "compl_prev_entr" text,
  "dt_encerramento" date,
  "id_ciencia_imp" text,
  "vlr_desc_serv" numeric,
  "contato" bigint,
  "dt_prorrogacao" date
);
create index if not exists "ix_com_pedido" on "topcon_sys"."com_pedido" ("empresa", "ano_pedido", "no_pedido", "seq_pedido");
alter table "topcon_sys"."com_pedido" enable row level security;
create table if not exists "topcon_sys"."com_pedido_forn_adic" (
  "empresa" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "seq_pedido" bigint,
  "fornecedor" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_com_pedido_forn_adic" on "topcon_sys"."com_pedido_forn_adic" ("empresa", "ano_pedido", "no_pedido", "seq_pedido", "fornecedor");
alter table "topcon_sys"."com_pedido_forn_adic" enable row level security;
create table if not exists "topcon_sys"."com_pedido_item" (
  "empresa" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "seq_pedido" bigint,
  "sequencia" bigint,
  "material" text,
  "quantidade" numeric,
  "unidade" text,
  "vlr_unitario" numeric,
  "vlr_total" numeric,
  "vlr_frete" numeric,
  "vlr_acrescimo" numeric,
  "vlr_desconto" numeric,
  "vlr_ipi" numeric,
  "vlr_icms" numeric,
  "vlr_liquido" numeric,
  "observacao" text,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "seq_cotacao" bigint,
  "qtde_entregue" numeric,
  "dt_ult_entrega" date,
  "id_cadast" text,
  "id_atual" text,
  "especificacao" text,
  "cod_ref_forn" text,
  "cod_ref_fabric" text,
  "prod_serv" text,
  "analis_contab" text,
  "id_aprov_contab" text,
  "operacao" bigint,
  "cfop" bigint,
  "seqcfop" bigint,
  "tribcontrib" text
);
create index if not exists "ix_com_pedido_item" on "topcon_sys"."com_pedido_item" ("empresa", "ano_pedido", "no_pedido", "seq_pedido", "sequencia");
alter table "topcon_sys"."com_pedido_item" enable row level security;
create table if not exists "topcon_sys"."com_pedido_ocor" (
  "emp" bigint,
  "ano_pedido" bigint,
  "no_pedido" bigint,
  "seq_pedido" bigint,
  "seq_item" bigint,
  "seq_ocorrencia" bigint,
  "cod_ocorrencia" bigint,
  "data_ocorrencia" date,
  "vlr_anterior" text,
  "vlr_ant_desc" text,
  "vlr_novo" text,
  "vlr_novo_desc" text,
  "obs" text,
  "aprovacao" text,
  "atualizado" text,
  "id_solicitacao" text,
  "id_aprovacao" text,
  "id_reprovacao" text
);
create index if not exists "ix_com_pedido_ocor" on "topcon_sys"."com_pedido_ocor" ("emp", "ano_pedido", "no_pedido", "seq_pedido", "seq_ocorrencia", "seq_item");
alter table "topcon_sys"."com_pedido_ocor" enable row level security;
create table if not exists "topcon_sys"."com_ref_forn" (
  "fornecedor" bigint,
  "material" text,
  "referencia" text
);
create index if not exists "ix_com_ref_forn" on "topcon_sys"."com_ref_forn" ("fornecedor", "material");
alter table "topcon_sys"."com_ref_forn" enable row level security;
create table if not exists "topcon_sys"."com_requisicao" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "data" date,
  "requisitante" bigint,
  "observacao" text,
  "resp_p_compra" bigint,
  "status" bigint,
  "fornecedor" bigint,
  "dt_prox_aprov" date,
  "centro_custo" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "departamento" bigint,
  "dep_usuario" bigint,
  "filial_solic" bigint,
  "disp_processo_compra" text
);
create index if not exists "ix_com_requisicao" on "topcon_sys"."com_requisicao" ("empresa", "ano_requisicao", "no_requisicao");
alter table "topcon_sys"."com_requisicao" enable row level security;
create table if not exists "topcon_sys"."com_requisicao_faixa" (
  "faixa_inicial" bigint,
  "faixa_final" bigint
);
alter table "topcon_sys"."com_requisicao_faixa" enable row level security;
create table if not exists "topcon_sys"."com_requisicao_item" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "sequencia" bigint,
  "material" text,
  "especificacao" text,
  "quantidade" numeric,
  "unidade" text,
  "veiculo_equip" text,
  "operacao" bigint,
  "observacao" text,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "seq_cotacao" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_aprov_contab" text,
  "status" bigint,
  "dt_prox_aprov" date,
  "dt_prev_entrega" date,
  "qtd_atendida" numeric,
  "id_aprov" text,
  "grupo" bigint,
  "subgrupo" bigint,
  "item" bigint,
  "subitem" bigint,
  "qtd_compra" numeric,
  "urgencia" text,
  "passar_almox" text,
  "analis_contab" text,
  "qtd_original" numeric,
  "filial" bigint,
  "filial_nf" bigint,
  "interv_nf" bigint,
  "tp_doc_nf" bigint,
  "serie_nf" text,
  "num_nf" bigint,
  "seq_item_nf" bigint,
  "obs_reprovacao" text,
  "dt_atendimento" date,
  "km_equip" bigint,
  "ciencia_reprov" text,
  "horimetro_equip" numeric,
  "dt_ult_atual" date,
  "qtd_entreg_forn" numeric,
  "vlr_unit" numeric,
  "vlr_total" numeric,
  "hora_abast" text,
  "dt_prorrog_bloq" date,
  "km_rodado" bigint,
  "local_estoque" text,
  "id_solic_compra" text,
  "horas_trabalhad" numeric,
  "ordem_servico" text
);
create index if not exists "ix_com_requisicao_item" on "topcon_sys"."com_requisicao_item" ("empresa", "ano_requisicao", "no_requisicao", "sequencia");
alter table "topcon_sys"."com_requisicao_item" enable row level security;
create table if not exists "topcon_sys"."com_requisicao_vinc_integ" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "id_integracao_abast" text
);
create index if not exists "ix_com_requisicao_vinc_integ" on "topcon_sys"."com_requisicao_vinc_integ" ("empresa", "ano_requisicao", "no_requisicao");
alter table "topcon_sys"."com_requisicao_vinc_integ" enable row level security;
create table if not exists "topcon_sys"."com_tp_doc_prog" (
  "empresa" bigint,
  "no_prog" bigint,
  "tp_doc" bigint,
  "id_cadast" text
);
create index if not exists "ix_com_tp_doc_prog" on "topcon_sys"."com_tp_doc_prog" ("empresa", "no_prog", "tp_doc");
alter table "topcon_sys"."com_tp_doc_prog" enable row level security;
create table if not exists "topcon_sys"."con_abrams" (
  "insumo" text,
  "seq" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "ac" numeric,
  "ac_ativo" bigint,
  "resist" bigint,
  "descr" text,
  "desvio" numeric
);
create index if not exists "ix_con_abrams" on "topcon_sys"."con_abrams" ("insumo", "seq", "tp_resist", "fck", "consumo");
alter table "topcon_sys"."con_abrams" enable row level security;
create table if not exists "topcon_sys"."con_acompanhamento" (
  "id_atend" bigint,
  "seq" bigint,
  "dt_visita" date,
  "responsavel" bigint,
  "historico" text,
  "horario" text
);
create index if not exists "ix_con_acompanhamento" on "topcon_sys"."con_acompanhamento" ("id_atend", "seq");
alter table "topcon_sys"."con_acompanhamento" enable row level security;
create table if not exists "topcon_sys"."con_aditivo_clicksign_envios" (
  "id" text,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "num_versao" bigint,
  "id_clicksign" text,
  "data_envio" timestamp,
  "data_assinatura" timestamp,
  "data_cancelamento" timestamp,
  "id_envio" text,
  "id_cancelamento" text,
  "qtd_assinatura_whatsapp" bigint
);
create index if not exists "ix_con_aditivo_clicksign_envios" on "topcon_sys"."con_aditivo_clicksign_envios" ("id");
alter table "topcon_sys"."con_aditivo_clicksign_envios" enable row level security;
create table if not exists "topcon_sys"."con_ajuste_mat_rem" (
  "usina" bigint,
  "uso" bigint,
  "pct_ajuste" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_ajuste_mat_rem" on "topcon_sys"."con_ajuste_mat_rem" ("usina", "uso");
alter table "topcon_sys"."con_ajuste_mat_rem" enable row level security;
create table if not exists "topcon_sys"."con_alt_traco" (
  "id" bigint,
  "tipo_cliente" text,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "tp_resist" bigint,
  "fck_cons" numeric,
  "volume_min" numeric,
  "volume_max" numeric,
  "uso_p" bigint,
  "pedra_p" bigint,
  "slump_p" bigint,
  "tp_resist_p" bigint,
  "fck_cons_p" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_alt_traco" on "topcon_sys"."con_alt_traco" ("id");
alter table "topcon_sys"."con_alt_traco" enable row level security;
create table if not exists "topcon_sys"."con_aprov" (
  "chave" text,
  "tipo_aprov" bigint,
  "usuario_req" text,
  "usuario_aprov" text,
  "dt_hora_solic" timestamp,
  "dt_hora_exec" timestamp,
  "complemento" text,
  "observacao" text
);
create index if not exists "ix_con_aprov" on "topcon_sys"."con_aprov" ("chave");
alter table "topcon_sys"."con_aprov" enable row level security;
create table if not exists "topcon_sys"."con_aprov_data" (
  "controle" bigint,
  "data_hora" timestamp,
  "usuario_soli" text,
  "nova_data" date,
  "usuario_aprov" text
);
create index if not exists "ix_con_aprov_data" on "topcon_sys"."con_aprov_data" ("controle");
alter table "topcon_sys"."con_aprov_data" enable row level security;
create table if not exists "topcon_sys"."con_aprov_eng" (
  "id" bigint,
  "tipo_cliente" text,
  "interv" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump_val" text,
  "slump" bigint,
  "tp_resist" bigint,
  "fck_cons_val" text,
  "fck_cons" numeric,
  "volume_val" text,
  "volume" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_aprov_eng" on "topcon_sys"."con_aprov_eng" ("id");
alter table "topcon_sys"."con_aprov_eng" enable row level security;
create table if not exists "topcon_sys"."con_aprov_script" (
  "chave_email" text,
  "operacao" text,
  "script" text,
  "status" text
);
create index if not exists "ix_con_aprov_script" on "topcon_sys"."con_aprov_script" ("chave_email", "operacao");
alter table "topcon_sys"."con_aprov_script" enable row level security;
create table if not exists "topcon_sys"."con_aprov_versao" (
  "num_versao" bigint,
  "chave" text,
  "tipo_aprov" bigint,
  "usuario_req" text,
  "usuario_aprov" text,
  "dt_hora_solic" timestamp,
  "dt_hora_exec" timestamp,
  "complemento" text,
  "observacao" text
);
create index if not exists "ix_con_aprov_versao" on "topcon_sys"."con_aprov_versao" ("num_versao", "chave");
alter table "topcon_sys"."con_aprov_versao" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_hierarquia" (
  "id" text,
  "aprovacao_comercial_usina_id" text,
  "titulo" text,
  "nivel_autoridade" bigint,
  "quantidade_aprovacoes_necessarias" bigint,
  "aprovacao_obrigatoria" bigint,
  "created_at" timestamp,
  "updated_at" timestamp
);
create index if not exists "ix_con_aprovacao_comercial_hierarquia" on "topcon_sys"."con_aprovacao_comercial_hierarquia" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_hierarquia" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao" (
  "id" text,
  "aprovacao_comercial_hierarquia_id" text,
  "valor_de" numeric,
  "valor_ate" numeric,
  "percentual_de" numeric,
  "percentual_ate" numeric,
  "tipo_pessoa_id" text,
  "tipo_valor" text
);
create index if not exists "ix_con_aprovacao_comercial_hierarquia_condicao" on "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao_pagamento" (
  "id" text,
  "aprovacao_comercial_hierarquia_id" text,
  "tipo_pessoa_id" text,
  "segmentacao_id" bigint,
  "media_dias_de" numeric,
  "media_dias_ate" numeric
);
create index if not exists "ix_con_aprovacao_comercial_hierarquia_condicao_pagamento" on "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao_pagamento" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_hierarquia_condicao_pagamento" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_hierarquia_usuario" (
  "id" text,
  "aprovacao_comercial_hierarquia_id" text,
  "usuario_id" text
);
create index if not exists "ix_con_aprovacao_comercial_hierarquia_usuario" on "topcon_sys"."con_aprovacao_comercial_hierarquia_usuario" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_hierarquia_usuario" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_pendente" (
  "id" text,
  "data_criacao" timestamp,
  "obra_versao" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "nivel_hierarquia" bigint,
  "aprovacao_status" bigint,
  "aprovacao_data" timestamp
);
create index if not exists "ix_con_aprovacao_comercial_pendente" on "topcon_sys"."con_aprovacao_comercial_pendente" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_pendente" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_pendente_bomba" (
  "id" text,
  "id_aprovacao" text,
  "obra_versao" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "obra_seq" bigint,
  "nivel_hierarquia" bigint,
  "aprovacao_status" bigint,
  "aprovacao_data" timestamp,
  "aprovacao_usuario" text,
  "aprovacao_sequencia" bigint
);
create index if not exists "ix_con_aprovacao_comercial_pendente_bomba" on "topcon_sys"."con_aprovacao_comercial_pendente_bomba" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_pendente_bomba" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_pendente_cond_pagto" (
  "id" text,
  "id_aprovacao" text,
  "obra_versao" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "nivel_hierarquia" bigint,
  "aprovacao_status" bigint,
  "aprovacao_data" timestamp,
  "aprovacao_usuario" text,
  "aprovacao_sequencia" bigint
);
create index if not exists "ix_con_aprovacao_comercial_pendente_cond_pagto" on "topcon_sys"."con_aprovacao_comercial_pendente_cond_pagto" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_pendente_cond_pagto" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_pendente_traco" (
  "id" text,
  "id_aprovacao" text,
  "obra_versao" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "obra_seq" bigint,
  "nivel_hierarquia" bigint,
  "aprovacao_status" bigint,
  "aprovacao_data" timestamp,
  "aprovacao_usuario" text,
  "aprovacao_sequencia" bigint
);
create index if not exists "ix_con_aprovacao_comercial_pendente_traco" on "topcon_sys"."con_aprovacao_comercial_pendente_traco" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_pendente_traco" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_pendente_volume" (
  "id" text,
  "id_aprovacao" text,
  "obra_versao" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "nivel_hierarquia" bigint,
  "aprovacao_status" bigint,
  "aprovacao_data" timestamp,
  "aprovacao_usuario" text,
  "aprovacao_sequencia" bigint
);
create index if not exists "ix_con_aprovacao_comercial_pendente_volume" on "topcon_sys"."con_aprovacao_comercial_pendente_volume" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_pendente_volume" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_tipo_pessoa" (
  "id" text,
  "descricao" text,
  "sigla" text
);
create index if not exists "ix_con_aprovacao_comercial_tipo_pessoa" on "topcon_sys"."con_aprovacao_comercial_tipo_pessoa" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_tipo_pessoa" enable row level security;
create table if not exists "topcon_sys"."con_aprovacao_comercial_usina" (
  "id" text,
  "usina" bigint,
  "ativo" bigint,
  "created_at" timestamp,
  "updated_at" timestamp,
  "fluxo_aprovacao" bigint
);
create index if not exists "ix_con_aprovacao_comercial_usina" on "topcon_sys"."con_aprovacao_comercial_usina" ("id");
alter table "topcon_sys"."con_aprovacao_comercial_usina" enable row level security;
create table if not exists "topcon_sys"."con_aprovacoes" (
  "chave" text,
  "tipo_aprov" text,
  "operacao" text,
  "status" text,
  "usuario_req" text,
  "usuario_aprov" text,
  "dt_hora_solic" timestamp,
  "dt_hora_click" timestamp,
  "dt_hora_exec" timestamp,
  "complemento" text
);
create index if not exists "ix_con_aprovacoes" on "topcon_sys"."con_aprovacoes" ("chave");
alter table "topcon_sys"."con_aprovacoes" enable row level security;
create table if not exists "topcon_sys"."con_at_usina" (
  "usina" bigint,
  "at" bigint
);
create index if not exists "ix_con_at_usina" on "topcon_sys"."con_at_usina" ("usina");
alter table "topcon_sys"."con_at_usina" enable row level security;
create table if not exists "topcon_sys"."con_bandeira" (
  "cod_bandeira" bigint,
  "interv" bigint,
  "portador" bigint,
  "situacao" bigint,
  "dias_1a_parc" bigint,
  "dias_2a_parc" bigint,
  "dias_3a_parc" bigint,
  "dias_4a_parc" bigint,
  "dias_5a_parc" bigint,
  "dias_6a_parc" bigint,
  "dias_7a_parc" bigint,
  "dias_8a_parc" bigint,
  "dias_9a_parc" bigint,
  "dias_10a_parc" bigint,
  "dias_11a_parc" bigint,
  "dias_12a_parc" bigint,
  "dias_float_deb" bigint,
  "id_cadast" text,
  "id_atual" text,
  "cod_estab" text,
  "emp" bigint,
  "cod_banco" bigint,
  "ccusto" bigint,
  "tipo_integracao" text,
  "ativo" text
);
create index if not exists "ix_con_bandeira" on "topcon_sys"."con_bandeira" ("cod_bandeira");
alter table "topcon_sys"."con_bandeira" enable row level security;
create table if not exists "topcon_sys"."con_bandeira_integracoes" (
  "cod_bandeira" bigint,
  "parametro_nome" text,
  "parametro_valor" text
);
create index if not exists "ix_con_bandeira_integracoes" on "topcon_sys"."con_bandeira_integracoes" ("cod_bandeira", "parametro_nome");
alter table "topcon_sys"."con_bandeira_integracoes" enable row level security;
create table if not exists "topcon_sys"."con_bandeira_integracoes_envios" (
  "id" bigint,
  "cod_bandeira" bigint,
  "id_integracao" text,
  "valor_total" numeric,
  "cpf_cnpj" text,
  "nome_cliente" text,
  "tipo_cobranca" text,
  "qtde_parcelas" bigint,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "observacao" text,
  "solicitante" text
);
create index if not exists "ix_con_bandeira_integracoes_envios" on "topcon_sys"."con_bandeira_integracoes_envios" ("id");
alter table "topcon_sys"."con_bandeira_integracoes_envios" enable row level security;
create table if not exists "topcon_sys"."con_bombeamento" (
  "usina_remessa" bigint,
  "usina_ctr" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_programacao" bigint,
  "data_remessa" date,
  "prog_por" text,
  "peca_concret" text,
  "m3_programado" numeric,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "brita" bigint,
  "slump" bigint,
  "uso" bigint,
  "m3_entregue" numeric,
  "m3_bombeado" numeric,
  "bomba" text,
  "bombista" bigint,
  "aux_bomba_1" bigint,
  "aux_bomba_2" bigint,
  "hr_prev_chegada" text,
  "hr_saida_usina" text,
  "hr_cheg_obra" text,
  "hr_bomba_pronta" text,
  "hr_inicio_bomb" text,
  "hr_term_bomb" text,
  "hr_saida_obra" text,
  "hr_cheg_usina" text,
  "odom_saida" bigint,
  "odom_retorno" bigint,
  "mot_atras_ch_ob" bigint,
  "mot_atras_concr" bigint,
  "mot_nao_concret" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "vlr_m3_bomb" numeric,
  "vlr_total_bomb" numeric,
  "autorizacao_cet" text,
  "km_rodado" numeric,
  "tp_bomba_orig" bigint,
  "tp_bomba_atual" bigint,
  "preco_uni_atual" numeric,
  "preco_tot_atual" numeric,
  "dt_nf" date,
  "no_nf_bomba" bigint,
  "aux_bomba_3" bigint,
  "atraso_entrega" bigint,
  "tempo_ida" bigint,
  "tempo_b_pronta" bigint,
  "espera_inic_ob" bigint,
  "espera_said_ob" bigint,
  "tempo_volta" bigint,
  "tempo_obra" bigint,
  "tempo_total" bigint,
  "tempo_bombe" bigint
);
create index if not exists "ix_con_bombeamento" on "topcon_sys"."con_bombeamento" ("usina_remessa", "usina_ctr", "ano_contrato", "num_contrato", "seq_programacao", "data_remessa", "bombista", "aux_bomba_1", "aux_bomba_2", "aux_bomba_3");
alter table "topcon_sys"."con_bombeamento" enable row level security;
create table if not exists "topcon_sys"."con_bombeamento_controle" (
  "usina_remessa" bigint,
  "usina_ctr" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_programacao" bigint,
  "data_remessa" date,
  "prog_por" text,
  "peca_concret" text,
  "m3_programado" numeric,
  "fck" numeric,
  "consumo" bigint,
  "brita" bigint,
  "slump" bigint,
  "uso" bigint,
  "m3_entregue" numeric,
  "m3_bombeado" numeric,
  "bomba" text,
  "bombista" bigint,
  "aux_bomba_1" bigint,
  "aux_bomba_2" bigint,
  "hr_prev_chegada" text,
  "hr_saida_usina" text,
  "hr_cheg_obra" text,
  "hr_bomba_pronta" text,
  "hr_inicio_bomb" text,
  "hr_term_bomb" text,
  "hr_saida_obra" text,
  "hr_cheg_usina" text,
  "odom_saida" bigint,
  "odom_retorno" bigint,
  "mot_atras_ch_ob" bigint,
  "mot_atras_concr" bigint,
  "mot_nao_concret" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "vlr_m3_bomb" numeric,
  "vlr_total_bomb" numeric,
  "autorizacao_cet" text,
  "km_rodado" numeric,
  "tp_bomba_orig" bigint,
  "tp_bomba_atual" bigint,
  "preco_uni_atual" numeric,
  "preco_tot_atual" numeric,
  "dt_nf" date,
  "no_nf_bomba" bigint,
  "aux_bomba_3" bigint,
  "atraso_entrega" bigint,
  "tempo_ida" bigint,
  "tempo_b_pronta" bigint,
  "espera_inic_ob" bigint,
  "espera_said_ob" bigint,
  "tempo_volta" bigint,
  "tempo_obra" bigint,
  "tempo_total" bigint,
  "tempo_bombe" bigint
);
create index if not exists "ix_con_bombeamento_controle" on "topcon_sys"."con_bombeamento_controle" ("usina_remessa", "usina_ctr", "ano_contrato", "num_contrato", "seq_programacao", "data_remessa");
alter table "topcon_sys"."con_bombeamento_controle" enable row level security;
create table if not exists "topcon_sys"."con_cep_faixa_safra" (
  "cep_inicial" text,
  "cep_final" text,
  "municipio" text,
  "id_cadast" text
);
create index if not exists "ix_con_cep_faixa_safra" on "topcon_sys"."con_cep_faixa_safra" ("cep_inicial", "cep_final");
alter table "topcon_sys"."con_cep_faixa_safra" enable row level security;
create table if not exists "topcon_sys"."con_cert_dados" (
  "usina" bigint,
  "usr_sist_eng" text,
  "dados_eng" text,
  "cabecalho" text,
  "observacao" text,
  "nota" text,
  "calibracao" text,
  "id_cadast" text,
  "id_atual" text,
  "endereco_cert" bigint
);
create index if not exists "ix_con_cert_dados" on "topcon_sys"."con_cert_dados" ("usina");
alter table "topcon_sys"."con_cert_dados" enable row level security;
create table if not exists "topcon_sys"."con_cert_fator_cim" (
  "dt_validade" date,
  "insumo" text,
  "fator_3d" numeric,
  "fator_7d" numeric,
  "fator_14d" numeric,
  "fator_21d" numeric,
  "fator_1d" numeric
);
create index if not exists "ix_con_cert_fator_cim" on "topcon_sys"."con_cert_fator_cim" ("dt_validade", "insumo");
alter table "topcon_sys"."con_cert_fator_cim" enable row level security;
create table if not exists "topcon_sys"."con_cert_resist" (
  "no_certificado" bigint,
  "ano_certificado" bigint,
  "usina" bigint,
  "serie" text,
  "nota_fiscal" bigint,
  "tp_doc" bigint,
  "seq_prog" bigint,
  "dt_certificado" date,
  "numero_cp" bigint,
  "dt_moldagem" date,
  "hora_moldagem" text,
  "silo" bigint,
  "moldador" bigint,
  "slump_teorico" bigint,
  "slump_real" numeric,
  "status" bigint,
  "dt_cp_no_lab" date,
  "qualidade_molde" bigint,
  "local_moldagem" bigint,
  "fck" numeric,
  "consumo" bigint,
  "usina_ctr" bigint,
  "no_ctr" bigint,
  "ano_ctr" bigint,
  "cli" bigint,
  "volume_m3" numeric,
  "brita" bigint,
  "cimento" text,
  "aditivo" text,
  "areia" text,
  "peca" text,
  "peca_compl" text,
  "motorista" bigint,
  "betoneira" text,
  "id_cadast" text,
  "id_atual" text,
  "espec_dias" bigint,
  "obs" text,
  "uso" bigint,
  "ignora_calculo" text,
  "resist_baixa" text,
  "fck_nf" numeric,
  "ignora_impress" text,
  "dt_imp_certificado" timestamp,
  "usuario_imp_certificado" text,
  "dt_email_certificado" timestamp,
  "usuario_email_certificado" text
);
create index if not exists "ix_con_cert_resist" on "topcon_sys"."con_cert_resist" ("no_certificado", "ano_certificado", "usina", "serie", "nota_fiscal", "tp_doc");
alter table "topcon_sys"."con_cert_resist" enable row level security;
create table if not exists "topcon_sys"."con_cert_resist_rup" (
  "no_certificado" bigint,
  "ano_certificado" bigint,
  "usina" bigint,
  "serie" text,
  "nota_fiscal" bigint,
  "tp_doc" bigint,
  "ruptura" bigint,
  "ruptura1" bigint,
  "mais_dias" bigint,
  "diamento" bigint,
  "dt_ruptura" date,
  "cp1_carga" bigint,
  "cp1_fck" numeric,
  "cp1_fck_cert" numeric,
  "cp1_no" text,
  "cp1_altura" numeric,
  "ruptura2" bigint,
  "mais_dias2" bigint,
  "dt_ruptura2" date,
  "cp2_carga" bigint,
  "cp2_fck" numeric,
  "cp2_fck_cert" numeric,
  "cp2_no" text,
  "cp2_altura" numeric,
  "projecao" numeric,
  "selecionado" bigint,
  "id_aprov_resist" text,
  "classificacao" bigint,
  "sub_classif" bigint,
  "classif_cp2" bigint,
  "sub_classif_cp2" bigint,
  "hr_ruptura" text,
  "tp_ruptura" text,
  "hr_ruptura2" text,
  "tp_ruptura2" text
);
create index if not exists "ix_con_cert_resist_rup" on "topcon_sys"."con_cert_resist_rup" ("no_certificado", "ano_certificado", "usina", "serie", "nota_fiscal", "tp_doc", "ruptura");
alter table "topcon_sys"."con_cert_resist_rup" enable row level security;
create table if not exists "topcon_sys"."con_chtel" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "dt" date,
  "hora" bigint,
  "vendedor" bigint,
  "represent" bigint,
  "vend_padrinho" bigint,
  "num_tab_preco" bigint,
  "contato" text,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "celular" bigint,
  "cod_cliente" bigint,
  "cliente" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "email" text,
  "id_cadast" text,
  "id_atual" text,
  "obs" text,
  "dt_retorno" date,
  "visita" text,
  "ano_visita" bigint,
  "num_visita" bigint,
  "dt_visita" date,
  "desist" bigint,
  "dt_desist" date,
  "vend_vis" bigint,
  "fis_jur" text,
  "fator_inicio" bigint,
  "fator_contato" bigint,
  "fator_valores" bigint,
  "fator_pgto" bigint,
  "fator_local" bigint,
  "avaliacao" numeric,
  "ganhou" text,
  "dt_retorno_efet" date,
  "hora_retor_efet" text,
  "vlr_concreto" numeric,
  "vlr_bomba" numeric,
  "vlr_extras" numeric,
  "vlr_total_ctr" numeric,
  "total_m3" numeric,
  "id_emissao" text,
  "cond_pag_desist" text,
  "tp_contato" bigint,
  "produto" bigint,
  "tem_obras" text,
  "qtde_obras" bigint,
  "propos_emitida" text,
  "vlr_iss_ret" numeric,
  "aprov_eng" text,
  "id_aprov_eng" text,
  "no_obra" bigint,
  "nome_mae" text,
  "conjuge" text,
  "status" bigint,
  "cnpj_cpf" text,
  "nome_cliente" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "profissao" text,
  "emp_trabalho" text,
  "ddd_com" bigint,
  "tel_com" bigint,
  "faturamento_ac" text,
  "fat_idem_client" text,
  "fat_cnpj_cpf" text,
  "fat_razao" text,
  "fat_nome" text,
  "fat_email" text,
  "fat_cep" text,
  "fat_end" text,
  "fat_num" bigint,
  "fat_compl" text,
  "fat_bairro" text,
  "fat_mun" bigint,
  "fat_ie" text,
  "fat_ccm" text,
  "fat_rg" text,
  "fat_org_uf_emi" text,
  "just_aprov" text,
  "prop_emi_aprov" text,
  "no_obra_pref" text,
  "status_anterior" bigint,
  "ddd_celular" bigint,
  "ccm_obra" text,
  "origem_usina" bigint,
  "origem_obra" bigint,
  "modelo_doc_remessa_concreto" bigint,
  "modelo_doc_remessa_bomba" bigint,
  "modelo_danfe" bigint,
  "dt_ult_versao_gerada" date,
  "condicoes_gerais" text,
  "validade_proposta" date,
  "segmentacao" bigint,
  "ano_visita_cliente" bigint,
  "num_visita_cliente" bigint,
  "ano_lead" bigint,
  "num_lead" bigint,
  "ano_oportunidade" bigint,
  "num_oportunidade" bigint,
  "finalidade_ctr" bigint,
  "aprov_medicao" text,
  "tempo_aprov_medicao" bigint,
  "motivo_perda" bigint,
  "observacao_interna" text
);
create index if not exists "ix_con_chtel" on "topcon_sys"."con_chtel" ("usina", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_chtel" enable row level security;
create table if not exists "topcon_sys"."con_chtel_cobranca" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint
);
create index if not exists "ix_con_chtel_cobranca" on "topcon_sys"."con_chtel_cobranca" ("usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_cobranca" enable row level security;
create table if not exists "topcon_sys"."con_chtel_cobranca_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint
);
create index if not exists "ix_con_chtel_cobranca_versao" on "topcon_sys"."con_chtel_cobranca_versao" ("num_versao", "usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_cobranca_versao" enable row level security;
create table if not exists "topcon_sys"."con_chtel_faturamento" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint
);
create index if not exists "ix_con_chtel_faturamento" on "topcon_sys"."con_chtel_faturamento" ("usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_faturamento" enable row level security;
create table if not exists "topcon_sys"."con_chtel_faturamento_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint
);
create index if not exists "ix_con_chtel_faturamento_versao" on "topcon_sys"."con_chtel_faturamento_versao" ("num_versao", "usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_faturamento_versao" enable row level security;
create table if not exists "topcon_sys"."con_chtel_hist" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "seq" bigint,
  "dt_chamada" date,
  "dt_retorno" date,
  "assunto" text,
  "historico1" text,
  "historico2" text,
  "historico3" text,
  "historico4" text,
  "no_obra" bigint
);
create index if not exists "ix_con_chtel_hist" on "topcon_sys"."con_chtel_hist" ("usina", "ano_chamada", "num_chamada", "no_obra", "seq");
alter table "topcon_sys"."con_chtel_hist" enable row level security;
create table if not exists "topcon_sys"."con_chtel_pag" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "seq" bigint,
  "cond_pgto" bigint,
  "tp_cobranca" bigint,
  "forma" text,
  "valor_fixo" text,
  "valor" numeric,
  "pct" numeric,
  "necessita_aprov" text,
  "id_cadast" text,
  "id_atual" text,
  "no_obra" bigint,
  "id_aprovacao" text,
  "ativo" text
);
create index if not exists "ix_con_chtel_pag" on "topcon_sys"."con_chtel_pag" ("usina", "ano_chamada", "num_chamada", "no_obra", "seq");
alter table "topcon_sys"."con_chtel_pag" enable row level security;
create table if not exists "topcon_sys"."con_chtel_pag_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "seq" bigint,
  "cond_pgto" bigint,
  "tp_cobranca" bigint,
  "forma" text,
  "valor_fixo" text,
  "valor" numeric,
  "pct" numeric,
  "necessita_aprov" text,
  "id_cadast" text,
  "id_atual" text,
  "no_obra" bigint,
  "id_aprovacao" text,
  "ativo" text
);
create index if not exists "ix_con_chtel_pag_versao" on "topcon_sys"."con_chtel_pag_versao" ("num_versao", "usina", "ano_chamada", "num_chamada", "seq", "no_obra");
alter table "topcon_sys"."con_chtel_pag_versao" enable row level security;
create table if not exists "topcon_sys"."con_chtel_resp_solid" (
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "ddd" bigint,
  "telefone" bigint
);
create index if not exists "ix_con_chtel_resp_solid" on "topcon_sys"."con_chtel_resp_solid" ("usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_resp_solid" enable row level security;
create table if not exists "topcon_sys"."con_chtel_resp_solid_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "idem_client" text,
  "cnpj_cpf" text,
  "razao" text,
  "nome" text,
  "email" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "ddd" bigint,
  "telefone" bigint
);
create index if not exists "ix_con_chtel_resp_solid_versao" on "topcon_sys"."con_chtel_resp_solid_versao" ("num_versao", "usina", "ano_chamada", "num_chamada");
alter table "topcon_sys"."con_chtel_resp_solid_versao" enable row level security;
create table if not exists "topcon_sys"."con_chtel_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "dt" date,
  "hora" bigint,
  "vendedor" bigint,
  "represent" bigint,
  "vend_padrinho" bigint,
  "num_tab_preco" bigint,
  "contato" text,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "celular" bigint,
  "cod_cliente" bigint,
  "cliente" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "email" text,
  "id_cadast" text,
  "id_atual" text,
  "obs" text,
  "dt_retorno" date,
  "visita" text,
  "ano_visita" bigint,
  "num_visita" bigint,
  "dt_visita" date,
  "desist" bigint,
  "dt_desist" date,
  "vend_vis" bigint,
  "fis_jur" text,
  "fator_inicio" bigint,
  "fator_contato" bigint,
  "fator_valores" bigint,
  "fator_pgto" bigint,
  "fator_local" bigint,
  "avaliacao" numeric,
  "ganhou" text,
  "dt_retorno_efet" date,
  "hora_retor_efet" text,
  "vlr_concreto" numeric,
  "vlr_bomba" numeric,
  "vlr_extras" numeric,
  "vlr_total_ctr" numeric,
  "total_m3" numeric,
  "id_emissao" text,
  "cond_pag_desist" text,
  "tp_contato" bigint,
  "produto" bigint,
  "tem_obras" text,
  "qtde_obras" bigint,
  "propos_emitida" text,
  "vlr_iss_ret" numeric,
  "aprov_eng" text,
  "id_aprov_eng" text,
  "no_obra" bigint,
  "nome_mae" text,
  "conjuge" text,
  "status" bigint,
  "cnpj_cpf" text,
  "nome_cliente" text,
  "ie" text,
  "ccm" text,
  "rg" text,
  "org_uf_emi" text,
  "profissao" text,
  "emp_trabalho" text,
  "ddd_com" bigint,
  "tel_com" bigint,
  "faturamento_ac" text,
  "fat_idem_client" text,
  "fat_cnpj_cpf" text,
  "fat_razao" text,
  "fat_nome" text,
  "fat_email" text,
  "fat_cep" text,
  "fat_end" text,
  "fat_num" bigint,
  "fat_compl" text,
  "fat_bairro" text,
  "fat_mun" bigint,
  "fat_ie" text,
  "fat_ccm" text,
  "fat_rg" text,
  "fat_org_uf_emi" text,
  "just_aprov" text,
  "prop_emi_aprov" text,
  "no_obra_pref" text,
  "status_anterior" bigint,
  "ddd_celular" bigint,
  "ccm_obra" text,
  "origem_usina" bigint,
  "origem_obra" bigint,
  "modelo_doc_remessa_concreto" bigint,
  "modelo_doc_remessa_bomba" bigint,
  "modelo_danfe" bigint,
  "dt_ult_versao_gerada" date,
  "condicoes_gerais" text,
  "validade_proposta" date,
  "segmentacao" bigint,
  "ano_visita_cliente" bigint,
  "num_visita_cliente" bigint,
  "ano_lead" bigint,
  "num_lead" bigint,
  "ano_oportunidade" bigint,
  "num_oportunidade" bigint,
  "finalidade_ctr" bigint,
  "aprov_medicao" text,
  "tempo_aprov_medicao" bigint,
  "motivo_perda" bigint,
  "observacao_interna" text
);
create index if not exists "ix_con_chtel_versao" on "topcon_sys"."con_chtel_versao" ("num_versao", "usina", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_chtel_versao" enable row level security;
create table if not exists "topcon_sys"."con_ciclos" (
  "usina" bigint,
  "dia_semana" bigint,
  "data" date,
  "ciclo" bigint,
  "tipo" text,
  "bomba" text,
  "hr_inicio" text,
  "hr_fim" text,
  "titulo" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_ciclos" on "topcon_sys"."con_ciclos" ("usina", "dia_semana", "data", "ciclo");
alter table "topcon_sys"."con_ciclos" enable row level security;
create table if not exists "topcon_sys"."con_class_concreto" (
  "peso_m3_de" numeric,
  "peso_m3_ate" numeric,
  "classe_abrev" text,
  "classe_descr" text
);
create index if not exists "ix_con_class_concreto" on "topcon_sys"."con_class_concreto" ("peso_m3_de");
alter table "topcon_sys"."con_class_concreto" enable row level security;
create table if not exists "topcon_sys"."con_class_slump" (
  "slump_de" bigint,
  "slump_ate" bigint,
  "classe" text,
  "especificacao" text
);
create index if not exists "ix_con_class_slump" on "topcon_sys"."con_class_slump" ("slump_de");
alter table "topcon_sys"."con_class_slump" enable row level security;
create table if not exists "topcon_sys"."con_clicksign_envios" (
  "id" text,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "id_clicksign" text,
  "data_envio" timestamp,
  "id_envio" text,
  "data_cancelamento" timestamp,
  "id_cancelamento" text,
  "data_assinatura" timestamp,
  "qtd_assinatura_whatsapp" bigint
);
create index if not exists "ix_con_clicksign_envios" on "topcon_sys"."con_clicksign_envios" ("id");
alter table "topcon_sys"."con_clicksign_envios" enable row level security;
create table if not exists "topcon_sys"."con_cml_parametro" (
  "inicio_validade" date,
  "m3_cheque" numeric,
  "id_cadast" text,
  "id_atual" text,
  "media_m3_bts" numeric,
  "pct_quebra_prog" numeric
);
create index if not exists "ix_con_cml_parametro" on "topcon_sys"."con_cml_parametro" ("inicio_validade");
alter table "topcon_sys"."con_cml_parametro" enable row level security;
create table if not exists "topcon_sys"."con_coleta_cp" (
  "usina" bigint,
  "nota_fiscal" bigint,
  "no_certificado" bigint,
  "ano_certificado" bigint,
  "numero_cp" text,
  "dt_ruptura" date,
  "carga" bigint,
  "id_ruptura" text
);
create index if not exists "ix_con_coleta_cp" on "topcon_sys"."con_coleta_cp" ("usina", "nota_fiscal", "numero_cp");
alter table "topcon_sys"."con_coleta_cp" enable row level security;
create table if not exists "topcon_sys"."con_com_ajuste_rep" (
  "cod_vendedor" bigint,
  "mes_base" date,
  "data_base_idp" date,
  "vlr_com_idp_mes" numeric,
  "aj_vl_com_idp_mes" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_ajuste_rep" on "topcon_sys"."con_com_ajuste_rep" ("cod_vendedor", "mes_base");
alter table "topcon_sys"."con_com_ajuste_rep" enable row level security;
create table if not exists "topcon_sys"."con_com_bombista" (
  "usina" bigint,
  "tipo_bomba" bigint,
  "inicio_validade" date,
  "vlr_m3_bombista" numeric,
  "vlr_m3_aux_bomb" numeric,
  "id_cadast" text,
  "id_atual" text,
  "vlr_m3_bombist1" numeric,
  "vlr_m3_bombist2" numeric,
  "vlr_m3_bombist3" numeric,
  "vlr_m3_bombist4" numeric,
  "vlr_m3_aux_bmb1" numeric,
  "vlr_m3_aux_bmb2" numeric,
  "vlr_m3_aux_bmb3" numeric,
  "vlr_m3_aux_bmb4" numeric,
  "vlr_com_bomb_min" numeric,
  "vlr_com_aux_min" numeric,
  "qtde_acima_m3" bigint,
  "vlr_com_bomb_acima" numeric,
  "vlr_com_aux_acima" numeric,
  "hr_antes_dias_uteis" text,
  "hr_apos_dias_uteis" text,
  "pct_hr_dias_uteis" numeric,
  "pct_dom_fer" numeric
);
create index if not exists "ix_con_com_bombista" on "topcon_sys"."con_com_bombista" ("usina", "tipo_bomba", "inicio_validade");
alter table "topcon_sys"."con_com_bombista" enable row level security;
create table if not exists "topcon_sys"."con_com_bombista_he" (
  "usina" bigint,
  "tipo_bomba" bigint,
  "inicio_validade" date,
  "he_de" bigint,
  "he_ate" bigint,
  "volume_de" numeric,
  "volume_ate" numeric,
  "vlr_bombista" numeric,
  "tp_bombista" text,
  "vlr_auxiliar" numeric,
  "tp_auxiliar" text,
  "desc_he_acima" bigint
);
create index if not exists "ix_con_com_bombista_he" on "topcon_sys"."con_com_bombista_he" ("usina", "tipo_bomba", "inicio_validade", "he_de", "he_ate", "volume_de", "volume_ate");
alter table "topcon_sys"."con_com_bombista_he" enable row level security;
create table if not exists "topcon_sys"."con_com_forn_mat" (
  "usina" bigint,
  "inicio_validade" date,
  "interv" bigint,
  "cod_transp" bigint,
  "tipo_insumo" text,
  "cod_insumo" text,
  "tipo_comis" text,
  "valor" numeric,
  "id_cadast" text,
  "id_atual" text,
  "valor_frete" numeric
);
create index if not exists "ix_con_com_forn_mat" on "topcon_sys"."con_com_forn_mat" ("usina", "inicio_validade", "interv", "cod_transp", "tipo_insumo", "cod_insumo");
alter table "topcon_sys"."con_com_forn_mat" enable row level security;
create table if not exists "topcon_sys"."con_com_media_vol" (
  "usina" bigint,
  "mes_base" date,
  "data_de" date,
  "data_ate" date,
  "media" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_media_vol" on "topcon_sys"."con_com_media_vol" ("usina", "mes_base");
alter table "topcon_sys"."con_com_media_vol" enable row level security;
create table if not exists "topcon_sys"."con_com_mot" (
  "usina" bigint,
  "inicio_validade" date,
  "m3_padrao_viag" numeric,
  "per_calc_viag" bigint,
  "faixa1_m3_trans" numeric,
  "faixa1_vlr_comi" numeric,
  "faixa2_m3_trans" numeric,
  "faixa2_vlr_comi" numeric,
  "faixa3_m3_trans" numeric,
  "faixa3_vlr_comi" numeric,
  "faixa4_m3_trans" numeric,
  "faixa4_vlr_comi" numeric,
  "faixa5_m3_trans" numeric,
  "faixa5_vlr_comi" numeric,
  "id_cadast" text,
  "id_atual" text,
  "tp_comiss" text,
  "hr_antes_dias_uteis" text,
  "hr_apos_dias_uteis" text,
  "hr_prim_viagem" text,
  "pct_hr_dias_uteis" numeric,
  "pct_dom_fer" numeric,
  "ev_prem_reaprov" bigint,
  "ev_ajuste_cep" bigint,
  "faixa6_m3_trans" numeric,
  "faixa6_vlr_comi" numeric,
  "faixa7_m3_trans" numeric,
  "faixa7_vlr_comi" numeric,
  "faixa8_m3_trans" numeric,
  "faixa8_vlr_comi" numeric,
  "faixa9_m3_trans" numeric,
  "faixa9_vlr_comi" numeric,
  "faixa10_m3_trans" numeric,
  "faixa10_vlr_comi" numeric,
  "regra_pag_extra" bigint,
  "hr_ext_apos_ent" bigint,
  "base_cal_faixa_m3" bigint
);
create index if not exists "ix_con_com_mot" on "topcon_sys"."con_com_mot" ("usina", "inicio_validade");
alter table "topcon_sys"."con_com_mot" enable row level security;
create table if not exists "topcon_sys"."con_com_mot_hora_ext" (
  "usina" bigint,
  "dt_inic_valid" date,
  "hr_extra_de" bigint,
  "hr_extra_ate" bigint,
  "vl_motorista" numeric
);
create index if not exists "ix_con_com_mot_hora_ext" on "topcon_sys"."con_com_mot_hora_ext" ("usina", "dt_inic_valid", "hr_extra_de", "hr_extra_ate");
alter table "topcon_sys"."con_com_mot_hora_ext" enable row level security;
create table if not exists "topcon_sys"."con_com_mot_media_vlr" (
  "usina" bigint,
  "inicio_validade" date,
  "vol_de" numeric,
  "vol_ate" numeric,
  "valor" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_mot_media_vlr" on "topcon_sys"."con_com_mot_media_vlr" ("usina", "inicio_validade", "vol_de", "vol_ate");
alter table "topcon_sys"."con_com_mot_media_vlr" enable row level security;
create table if not exists "topcon_sys"."con_com_tipos_bomba" (
  "usina" bigint,
  "inicio_vigencia" date,
  "tipo_bomba" bigint,
  "bmb_pct_com" numeric,
  "bmb_vlr_premio" numeric,
  "bmb_sobre_preco" text,
  "bmb_spreco_pct" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_tipos_bomba" on "topcon_sys"."con_com_tipos_bomba" ("usina", "inicio_vigencia", "tipo_bomba");
alter table "topcon_sys"."con_com_tipos_bomba" enable row level security;
create table if not exists "topcon_sys"."con_com_tracos" (
  "usina" bigint,
  "inicio_vigencia" date,
  "fck_cons" numeric,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "conc_vlr_m3" numeric,
  "conc_pct_com" numeric,
  "conc_sobre_preco" text,
  "conc_spreco_ate_vlr" numeric,
  "conc_spreco_ate_pct" numeric,
  "conc_spreco_acima_pct" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_tracos" on "topcon_sys"."con_com_tracos" ("usina", "inicio_vigencia", "fck_cons", "uso", "pedra", "slump");
alter table "topcon_sys"."con_com_tracos" enable row level security;
create table if not exists "topcon_sys"."con_com_vend_idp" (
  "cod_vendedor" bigint,
  "mes_base" date,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "cli" bigint,
  "dt_vcto" date,
  "saldo" numeric,
  "vlr_comissao" numeric
);
create index if not exists "ix_con_com_vend_idp" on "topcon_sys"."con_com_vend_idp" ("cod_vendedor", "mes_base", "emp", "tp_doc", "ser_doc", "num_doc", "seq", "desdo");
alter table "topcon_sys"."con_com_vend_idp" enable row level security;
create table if not exists "topcon_sys"."con_com_vend_metas" (
  "cod_vendedor" bigint,
  "mes_base" date,
  "data_de" date,
  "data_ate" date,
  "meta_m3" numeric,
  "vol_prod_mes" numeric,
  "vlr_prod_mes" numeric,
  "data_base_idp" date,
  "vol_idp_mes" numeric,
  "vlr_idp_mes" numeric,
  "ajuste_vol_idp_mes" numeric,
  "ajuste_vlr_idp_mes" numeric,
  "vlr_com_prod" numeric,
  "vlr_com_bmb" numeric,
  "vlr_com_vibr" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_vend_metas" on "topcon_sys"."con_com_vend_metas" ("cod_vendedor", "mes_base");
alter table "topcon_sys"."con_com_vend_metas" enable row level security;
create table if not exists "topcon_sys"."con_com_vendedor" (
  "cod_vendedor" bigint,
  "precom_de" numeric,
  "precom_ate" numeric,
  "valor_perc" text,
  "valor" numeric
);
create index if not exists "ix_con_com_vendedor" on "topcon_sys"."con_com_vendedor" ("cod_vendedor", "precom_de", "precom_ate");
alter table "topcon_sys"."con_com_vendedor" enable row level security;
create table if not exists "topcon_sys"."con_com_vlr_fxa_bmb" (
  "inicio_vigencia" date,
  "faixa_de" bigint,
  "faixa_ate" bigint,
  "vlr_premio" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_vlr_fxa_bmb" on "topcon_sys"."con_com_vlr_fxa_bmb" ("inicio_vigencia", "faixa_de", "faixa_ate");
alter table "topcon_sys"."con_com_vlr_fxa_bmb" enable row level security;
create table if not exists "topcon_sys"."con_com_vol_prem_mot" (
  "usina" bigint,
  "inicio_validade" date,
  "capacidade_m3" bigint,
  "vol_prod" numeric,
  "qtde_viagens" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_com_vol_prem_mot" on "topcon_sys"."con_com_vol_prem_mot" ("usina", "inicio_validade", "capacidade_m3", "vol_prod");
alter table "topcon_sys"."con_com_vol_prem_mot" enable row level security;
create table if not exists "topcon_sys"."con_comissao_pagar" (
  "filial" bigint,
  "tp_doc" text,
  "num_nfs" bigint,
  "serie_nfs" text,
  "no_rps" bigint,
  "dt_nfs" date,
  "motorista" bigint,
  "m3_transp" numeric,
  "bombista" bigint,
  "vlr_comis_bomb" numeric,
  "aux_bombista" bigint,
  "vlr_comis_aux_b" numeric,
  "dt_apropr_folha" date,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_comissao_pagar" on "topcon_sys"."con_comissao_pagar" ("filial", "tp_doc", "num_nfs", "serie_nfs");
alter table "topcon_sys"."con_comissao_pagar" enable row level security;
create table if not exists "topcon_sys"."con_compromisso" (
  "codigo" bigint,
  "usuario" text,
  "descricao" text,
  "dia_inteiro" bigint,
  "data_inicio" date,
  "hora_inicio" text,
  "data_fim" date,
  "hora_fim" text,
  "local" text,
  "contato" text,
  "ddd" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text,
  "observacao" text,
  "providencia" text,
  "conclusao" text,
  "usina" bigint,
  "ano_visita" bigint,
  "numero_visita" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "ano_oportunidade" bigint,
  "numero_oportunidade" bigint,
  "data_criacao" timestamp,
  "id_agrupamento" text
);
create index if not exists "ix_con_compromisso" on "topcon_sys"."con_compromisso" ("codigo");
alter table "topcon_sys"."con_compromisso" enable row level security;
create table if not exists "topcon_sys"."con_concorrente" (
  "codigo" bigint,
  "descricao" text,
  "ativo" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_concorrente" on "topcon_sys"."con_concorrente" ("codigo");
alter table "topcon_sys"."con_concorrente" enable row level security;
create table if not exists "topcon_sys"."con_concorrente_filial" (
  "id" bigint,
  "concorrente_codigo" bigint,
  "nome" text,
  "endereco" text,
  "municipio_codigo" bigint,
  "latitude" numeric,
  "longitude" numeric,
  "ativo" text
);
create index if not exists "ix_con_concorrente_filial" on "topcon_sys"."con_concorrente_filial" ("id");
alter table "topcon_sys"."con_concorrente_filial" enable row level security;
create table if not exists "topcon_sys"."con_concorrente_filial_volume_mensal" (
  "filial_id" bigint,
  "ano" bigint,
  "mes" bigint,
  "volume_estimado_m3" numeric
);
create index if not exists "ix_con_concorrente_filial_volume_mensal" on "topcon_sys"."con_concorrente_filial_volume_mensal" ("filial_id", "ano", "mes");
alter table "topcon_sys"."con_concorrente_filial_volume_mensal" enable row level security;
create table if not exists "topcon_sys"."con_cond" (
  "usina" bigint,
  "cod" bigint,
  "texto" text,
  "m3_ate" numeric,
  "valor" numeric,
  "pct_acrescimo" numeric,
  "vlr_acrescimo" numeric,
  "textoformatado" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_cond" on "topcon_sys"."con_cond" ("usina", "cod");
alter table "topcon_sys"."con_cond" enable row level security;
create table if not exists "topcon_sys"."con_cond_pagto" (
  "usina" bigint,
  "dt_inicio" date,
  "cond_pagf" text,
  "cond_pagj" text,
  "id_segmentacao" bigint
);
create index if not exists "ix_con_cond_pagto" on "topcon_sys"."con_cond_pagto" ("usina", "dt_inicio", "id_segmentacao");
alter table "topcon_sys"."con_cond_pagto" enable row level security;
create table if not exists "topcon_sys"."con_cond_pagto_tx" (
  "usina" bigint,
  "cond_pagto" bigint,
  "tipo" text,
  "valor" numeric
);
create index if not exists "ix_con_cond_pagto_tx" on "topcon_sys"."con_cond_pagto_tx" ("usina", "cond_pagto");
alter table "topcon_sys"."con_cond_pagto_tx" enable row level security;
create table if not exists "topcon_sys"."con_config_form_seg" (
  "filial" bigint,
  "data" date,
  "seq" bigint,
  "tipo_validade" bigint,
  "qtde_validade" bigint,
  "qtde_nf" bigint,
  "justificativa" text,
  "usuario" text,
  "ativo" text
);
create index if not exists "ix_con_config_form_seg" on "topcon_sys"."con_config_form_seg" ("filial", "data", "seq");
alter table "topcon_sys"."con_config_form_seg" enable row level security;
create table if not exists "topcon_sys"."con_config_pesagem" (
  "usina" bigint,
  "data" date,
  "seq" bigint,
  "config" bigint,
  "tipo_validade" bigint,
  "qtd_validade" bigint,
  "qtd_nf" bigint,
  "observacao" text,
  "usuario" text,
  "hora_liberacao" text
);
create index if not exists "ix_con_config_pesagem" on "topcon_sys"."con_config_pesagem" ("usina", "data", "seq");
alter table "topcon_sys"."con_config_pesagem" enable row level security;
create table if not exists "topcon_sys"."con_contrato" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "interv" bigint,
  "dt_contrato" date,
  "inicio_vigencia" date,
  "fim_vigencia" date,
  "dt_encer_cont" date,
  "representante" bigint,
  "vendedor" bigint,
  "vend_padrinho" bigint,
  "num_tab_preco" bigint,
  "local_cobranca" bigint,
  "local_fatur" bigint,
  "dt_carta_reajus" date,
  "faturamento_ac" text,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "no_obra" text,
  "fis_jur" text,
  "fechado" text,
  "id_aprov_vend" text,
  "id_aprov_dir" text,
  "id_aprov_cad" text,
  "id_aprov_prog" text,
  "no_ctr_ant" text,
  "vlr_concreto" numeric,
  "vlr_bomba" numeric,
  "vlr_extras" numeric,
  "vlr_total_ctr" numeric,
  "total_m3" numeric,
  "usina_principal" bigint,
  "pag_ant_analis" text,
  "id_analise" text,
  "cad_aprovado" text,
  "cheque_analis" text,
  "id_analise_chq" text,
  "id_aprov_dinh" text,
  "dt_pag_dinh" date,
  "vlr_dinheiro" numeric,
  "aguard_aprov" text,
  "descr_coincid" text,
  "aprov_coincid" text,
  "resp_solidario" bigint,
  "email_enviado" text,
  "aprov_eng" text,
  "id_aprov_eng" text,
  "vlr_iss_ret" numeric,
  "id_pre_cadastro" text,
  "analista" bigint,
  "status" bigint,
  "status_anterior" bigint,
  "inconsistencias" text,
  "modelo_danfe" bigint,
  "fat_pendente" bigint,
  "ccm_obra" text,
  "trib_iss" bigint,
  "produto" bigint,
  "modelo_doc_remessa_concreto" bigint,
  "modelo_doc_remessa_bomba" bigint,
  "retencao_contratual" numeric,
  "mao_obra_propria" text,
  "percentual_locacao" numeric,
  "segmentacao" bigint,
  "finalidade_ctr" bigint,
  "aprov_medicao" text,
  "tempo_aprov_medicao" bigint
);
create index if not exists "ix_con_contrato" on "topcon_sys"."con_contrato" ("usina", "ano_contrato", "num_contrato");
alter table "topcon_sys"."con_contrato" enable row level security;
create table if not exists "topcon_sys"."con_contrato_boleto" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "dt_vcto" date,
  "dt_hr_imp" timestamp,
  "nosso_num" text,
  "linha_dig" text,
  "cod_barra" text,
  "dt_remessa" date,
  "dt_liq" date,
  "vl_orig" numeric,
  "vl_liq" numeric,
  "id_liq" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_contrato_boleto" on "topcon_sys"."con_contrato_boleto" ("usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_boleto" enable row level security;
create table if not exists "topcon_sys"."con_contrato_boleto_atualizou_dt_remessa" (
  "dt_remessa" date
);
alter table "topcon_sys"."con_contrato_boleto_atualizou_dt_remessa" enable row level security;
create table if not exists "topcon_sys"."con_contrato_boleto_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "dt_vcto" date,
  "dt_hr_imp" timestamp,
  "nosso_num" text,
  "linha_dig" text,
  "cod_barra" text,
  "dt_remessa" date,
  "dt_liq" date,
  "vl_orig" numeric,
  "vl_liq" numeric,
  "id_liq" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_contrato_boleto_versao" on "topcon_sys"."con_contrato_boleto_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq_pgto", "ano_chamada", "num_chamada", "no_obra", "seq");
alter table "topcon_sys"."con_contrato_boleto_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_ccredit" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "seq" bigint,
  "bandeira" bigint,
  "no_cartao" bigint,
  "dt_transacao" date,
  "valor" numeric,
  "no_parcelas" bigint,
  "no_autorizacao" text,
  "id_cadast" text,
  "id_atual" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_ccredit" on "topcon_sys"."con_contrato_ccredit" ("usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_ccredit" enable row level security;
create table if not exists "topcon_sys"."con_contrato_ccredit_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "seq" bigint,
  "bandeira" bigint,
  "no_cartao" bigint,
  "dt_transacao" date,
  "valor" numeric,
  "no_parcelas" bigint,
  "no_autorizacao" text,
  "id_cadast" text,
  "id_atual" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_ccredit_versao" on "topcon_sys"."con_contrato_ccredit_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_ccredit_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_cheque" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "bco_cheque" bigint,
  "ag_cheque" bigint,
  "conta_cheque" bigint,
  "dv_conta" bigint,
  "num_cheque" bigint,
  "dt_receb" date,
  "vlr" numeric,
  "bom_para" date,
  "id_cadast" text,
  "id_atual" text,
  "obs" text,
  "seq_pgto" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_cheque" on "topcon_sys"."con_contrato_cheque" ("usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_cheque" enable row level security;
create table if not exists "topcon_sys"."con_contrato_cheque_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "bco_cheque" bigint,
  "ag_cheque" bigint,
  "conta_cheque" bigint,
  "dv_conta" bigint,
  "num_cheque" bigint,
  "dt_receb" date,
  "vlr" numeric,
  "bom_para" date,
  "id_cadast" text,
  "id_atual" text,
  "obs" text,
  "seq_pgto" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_cheque_versao" on "topcon_sys"."con_contrato_cheque_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq", "seq_pgto", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_cheque_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_clausu" (
  "usina" bigint,
  "clausula" text,
  "titulo" text,
  "conteudo" text,
  "id_cadast" text,
  "id_atual" text,
  "id_segmentacao" bigint
);
create index if not exists "ix_con_contrato_clausu" on "topcon_sys"."con_contrato_clausu" ("usina", "clausula");
alter table "topcon_sys"."con_contrato_clausu" enable row level security;
create table if not exists "topcon_sys"."con_contrato_dep" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "dt_deposito" date,
  "portador" bigint,
  "bco_tomad" bigint,
  "agencia_tomad" text,
  "no_terminal" text,
  "no_conta" text,
  "valor_dep" numeric,
  "id_aprovacao" text,
  "seq_pgto" bigint,
  "id_cadast" text,
  "id_atual" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_dep" on "topcon_sys"."con_contrato_dep" ("usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_dep" enable row level security;
create table if not exists "topcon_sys"."con_contrato_dep_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "dt_deposito" date,
  "portador" bigint,
  "bco_tomad" bigint,
  "agencia_tomad" text,
  "no_terminal" text,
  "no_conta" text,
  "valor_dep" numeric,
  "id_aprovacao" text,
  "seq_pgto" bigint,
  "id_cadast" text,
  "id_atual" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_dep_versao" on "topcon_sys"."con_contrato_dep_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq", "seq_pgto", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_dep_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_dinheir" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "seq" bigint,
  "num_recibo" text,
  "dt_pagamento" date,
  "valor" numeric,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_dinheir" on "topcon_sys"."con_contrato_dinheir" ("usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_dinheir" enable row level security;
create table if not exists "topcon_sys"."con_contrato_dinheir_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq_pgto" bigint,
  "seq" bigint,
  "num_recibo" text,
  "dt_pagamento" date,
  "valor" numeric,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint
);
create index if not exists "ix_con_contrato_dinheir_versao" on "topcon_sys"."con_contrato_dinheir_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq_pgto", "seq", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_contrato_dinheir_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_email" (
  "assunto" text,
  "arquivo_email" text,
  "anexo_email" text
);
alter table "topcon_sys"."con_contrato_email" enable row level security;
create table if not exists "topcon_sys"."con_contrato_exc" (
  "tipo_cliente" text,
  "volume_ate" numeric,
  "pct_excedente" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_contrato_exc" on "topcon_sys"."con_contrato_exc" ("tipo_cliente", "volume_ate");
alter table "topcon_sys"."con_contrato_exc" enable row level security;
create table if not exists "topcon_sys"."con_contrato_hist" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "data" date,
  "assunto" text,
  "historico1" text,
  "historico2" text,
  "historico3" text,
  "historico4" text
);
create index if not exists "ix_con_contrato_hist" on "topcon_sys"."con_contrato_hist" ("usina", "ano_contrato", "num_contrato", "seq");
alter table "topcon_sys"."con_contrato_hist" enable row level security;
create table if not exists "topcon_sys"."con_contrato_pag" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "cond_pagto" bigint,
  "tp_cobranca" bigint,
  "forma" text,
  "valor_fixo" text,
  "valor" numeric,
  "pct" numeric,
  "necessita_aprov" text,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "valor_apropriado" numeric
);
create index if not exists "ix_con_contrato_pag" on "topcon_sys"."con_contrato_pag" ("usina", "ano_contrato", "num_contrato", "seq");
alter table "topcon_sys"."con_contrato_pag" enable row level security;
create table if not exists "topcon_sys"."con_contrato_pag_apr" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "seq_aprop" bigint,
  "valor_apropriado" numeric,
  "nfs_filial" bigint,
  "nfs_cli" bigint,
  "nfs_tp_doc" bigint,
  "nfs_ser" text,
  "nfs_num_nf" bigint
);
create index if not exists "ix_con_contrato_pag_apr" on "topcon_sys"."con_contrato_pag_apr" ("usina", "ano_contrato", "num_contrato", "seq", "seq_aprop");
alter table "topcon_sys"."con_contrato_pag_apr" enable row level security;
create table if not exists "topcon_sys"."con_contrato_pag_apr_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "seq_aprop" bigint,
  "valor_apropriado" numeric,
  "nfs_filial" bigint,
  "nfs_cli" bigint,
  "nfs_tp_doc" bigint,
  "nfs_ser" text,
  "nfs_num_nf" bigint
);
create index if not exists "ix_con_contrato_pag_apr_versao" on "topcon_sys"."con_contrato_pag_apr_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq", "seq_aprop");
alter table "topcon_sys"."con_contrato_pag_apr_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_pag_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "cond_pagto" bigint,
  "tp_cobranca" bigint,
  "forma" text,
  "valor_fixo" text,
  "valor" numeric,
  "pct" numeric,
  "necessita_aprov" text,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "valor_apropriado" numeric
);
create index if not exists "ix_con_contrato_pag_versao" on "topcon_sys"."con_contrato_pag_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "seq");
alter table "topcon_sys"."con_contrato_pag_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_pct_com" (
  "usina_contrato" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "vendedor" bigint,
  "represent" bigint,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "num_fatura" bigint,
  "percentual" numeric,
  "com_vend_bomb" numeric,
  "com_repre_bomb" numeric,
  "com_vend_concr" numeric,
  "com_vend_serv" numeric,
  "com_vend_dif" numeric,
  "com_repr_concr" numeric,
  "com_repres_serv" numeric,
  "com_repres_dif" numeric
);
create index if not exists "ix_con_contrato_pct_com" on "topcon_sys"."con_contrato_pct_com" ("usina_contrato", "ano_contrato", "num_contrato", "vendedor", "represent", "filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "num_fatura");
alter table "topcon_sys"."con_contrato_pct_com" enable row level security;
create table if not exists "topcon_sys"."con_contrato_reajuste_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "dt_vigencia" date,
  "tipo" text
);
create index if not exists "ix_con_contrato_reajuste_versao" on "topcon_sys"."con_contrato_reajuste_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "dt_vigencia");
alter table "topcon_sys"."con_contrato_reajuste_versao" enable row level security;
create table if not exists "topcon_sys"."con_contrato_trib" (
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "pct_iss" numeric,
  "pct_iss_retido" numeric,
  "base_calc_iss" bigint,
  "pct_servico" numeric,
  "pct_ded_material" numeric,
  "iss_bomba" text,
  "taxas_trib_integralmente" text
);
create index if not exists "ix_con_contrato_trib" on "topcon_sys"."con_contrato_trib" ("usina_contrato", "num_contrato", "ano_contrato");
alter table "topcon_sys"."con_contrato_trib" enable row level security;
create table if not exists "topcon_sys"."con_contrato_versao" (
  "num_versao" bigint,
  "dt_versao_criada" date,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "interv" bigint,
  "dt_contrato" date,
  "inicio_vigencia" date,
  "fim_vigencia" date,
  "dt_encer_cont" date,
  "representante" bigint,
  "vendedor" bigint,
  "vend_padrinho" bigint,
  "num_tab_preco" bigint,
  "local_cobranca" bigint,
  "local_fatur" bigint,
  "dt_carta_reajus" date,
  "faturamento_ac" text,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "no_obra" text,
  "fis_jur" text,
  "fechado" text,
  "id_aprov_vend" text,
  "id_aprov_dir" text,
  "id_aprov_cad" text,
  "id_aprov_prog" text,
  "no_ctr_ant" text,
  "vlr_concreto" numeric,
  "vlr_bomba" numeric,
  "vlr_extras" numeric,
  "vlr_total_ctr" numeric,
  "total_m3" numeric,
  "usina_principal" bigint,
  "pag_ant_analis" text,
  "id_analise" text,
  "cad_aprovado" text,
  "cheque_analis" text,
  "id_analise_chq" text,
  "id_aprov_dinh" text,
  "dt_pag_dinh" date,
  "vlr_dinheiro" numeric,
  "aguard_aprov" text,
  "descr_coincid" text,
  "aprov_coincid" text,
  "resp_solidario" bigint,
  "email_enviado" text,
  "aprov_eng" text,
  "id_aprov_eng" text,
  "vlr_iss_ret" numeric,
  "id_pre_cadastro" text,
  "analista" bigint,
  "status" bigint,
  "status_anterior" bigint,
  "inconsistencias" text,
  "modelo_danfe" bigint,
  "fat_pendente" bigint,
  "ccm_obra" text,
  "trib_iss" bigint,
  "produto" bigint,
  "modelo_doc_remessa_concreto" bigint,
  "modelo_doc_remessa_bomba" bigint,
  "retencao_contratual" numeric,
  "mao_obra_propria" text,
  "percentual_locacao" numeric,
  "segmentacao" bigint,
  "finalidade_ctr" bigint,
  "aprov_medicao" text,
  "tempo_aprov_medicao" bigint
);
create index if not exists "ix_con_contrato_versao" on "topcon_sys"."con_contrato_versao" ("num_versao", "usina", "ano_contrato", "num_contrato");
alter table "topcon_sys"."con_contrato_versao" enable row level security;
create table if not exists "topcon_sys"."con_corte_agua" (
  "usina" bigint,
  "corte" bigint
);
create index if not exists "ix_con_corte_agua" on "topcon_sys"."con_corte_agua" ("usina");
alter table "topcon_sys"."con_corte_agua" enable row level security;
create table if not exists "topcon_sys"."con_cp_usina_por_volume" (
  "id" text,
  "usina" bigint,
  "ativo" text,
  "quantidade_cps" bigint,
  "intervalo_quantidade_m3" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_cp_usina_por_volume" on "topcon_sys"."con_cp_usina_por_volume" ("usina");
alter table "topcon_sys"."con_cp_usina_por_volume" enable row level security;
create table if not exists "topcon_sys"."con_ctr_equip" (
  "emp" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "interv" bigint,
  "faturam_ac" text,
  "observacao" text,
  "local_cobranca" bigint,
  "local_fatur" bigint,
  "dt_ctr" date,
  "dt_inicio" date,
  "prazo_dias" bigint,
  "dt_termino" date,
  "equipamento" text,
  "descricao" text,
  "vlr_locacao" numeric,
  "qtde_horas" bigint,
  "fat_minimo_dias" bigint,
  "fat_minimo_hora" bigint,
  "pct_excedente" numeric,
  "pct_iss" numeric,
  "custo_km_desmob" numeric,
  "km_livre_obra" bigint,
  "custo_km_obra_e" numeric,
  "dia_fechamento" bigint,
  "prazo_pagamento" bigint,
  "cond_pagto" bigint,
  "cidade_obra" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_ctr_equip" on "topcon_sys"."con_ctr_equip" ("emp", "ano_contrato", "num_contrato");
alter table "topcon_sys"."con_ctr_equip" enable row level security;
create table if not exists "topcon_sys"."con_ctr_equip_clausu" (
  "clausula" text,
  "titulo" text,
  "conteudo" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_ctr_equip_clausu" on "topcon_sys"."con_ctr_equip_clausu" ("clausula");
alter table "topcon_sys"."con_ctr_equip_clausu" enable row level security;
create table if not exists "topcon_sys"."con_ctr_equip_med" (
  "emp" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "dt_medicao" date,
  "qtde_dias" bigint,
  "qtde_horas" bigint,
  "vlr_horas" numeric,
  "vlr_total_horas" numeric,
  "pct_excedente" numeric,
  "vlr_excedente" numeric,
  "km_rod_obra" bigint,
  "km_excedente" bigint,
  "vlr_km_exced" numeric,
  "vlr_tot_km_exce" numeric,
  "km_desmob" bigint,
  "vlr_km_desmob" numeric,
  "vlr_desmob" numeric,
  "pct_iss" numeric,
  "vlr_iss" numeric,
  "total_geral" numeric
);
create index if not exists "ix_con_ctr_equip_med" on "topcon_sys"."con_ctr_equip_med" ("emp", "ano_contrato", "num_contrato", "seq");
alter table "topcon_sys"."con_ctr_equip_med" enable row level security;
create table if not exists "topcon_sys"."con_custo_conc_hist" (
  "tab_custo" date,
  "usina" bigint,
  "sigla_compos" text,
  "dt_inic_valid" date,
  "uso" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "pedra" bigint,
  "slump" bigint,
  "custo_p" numeric,
  "custo_a" numeric,
  "dt_calc_custo" date,
  "custo_recal" numeric,
  "dt_recal" date,
  "pct_variacao" numeric,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "vlr_servico" numeric,
  "vlr_custo_outro" numeric,
  "markup" numeric,
  "external_id" text
);
create index if not exists "ix_con_custo_conc_hist" on "topcon_sys"."con_custo_conc_hist" ("usina", "tab_custo", "sigla_compos", "dt_inic_valid", "uso", "tp_resist", "fck", "consumo", "pedra", "slump");
alter table "topcon_sys"."con_custo_conc_hist" enable row level security;
create table if not exists "topcon_sys"."con_custo_concreto" (
  "usina" bigint,
  "sigla_compos" text,
  "dt_inic_valid" date,
  "uso" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "pedra" bigint,
  "slump" bigint,
  "custo_p" numeric,
  "custo_a" numeric,
  "dt_calc_custo" date,
  "custo_recal" numeric,
  "dt_recal" date,
  "pct_variacao" numeric,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "vlr_servico" numeric,
  "vlr_custo_outro" numeric,
  "markup" numeric,
  "external_id" text
);
create index if not exists "ix_con_custo_concreto" on "topcon_sys"."con_custo_concreto" ("usina", "sigla_compos", "dt_inic_valid", "uso", "tp_resist", "fck", "consumo", "pedra", "slump");
alter table "topcon_sys"."con_custo_concreto" enable row level security;
create table if not exists "topcon_sys"."con_custo_insumo" (
  "usina" bigint,
  "dt_preco" date,
  "insumo" text,
  "forn" bigint,
  "unid_compra" text,
  "massa_unitaria" numeric,
  "peso_especifico" numeric,
  "mpa" numeric,
  "vlr_insumo" numeric,
  "vlr_frete" numeric,
  "custo_unit_comp" numeric,
  "base_calc_custo" text,
  "dt_inicio_vigen" date,
  "cond_pag" bigint,
  "status" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_custo_insumo" on "topcon_sys"."con_custo_insumo" ("usina", "dt_preco", "insumo", "forn");
alter table "topcon_sys"."con_custo_insumo" enable row level security;
create table if not exists "topcon_sys"."con_custo_serv" (
  "usina" bigint,
  "dt_inicio_valid" date,
  "vlr_custo_combu" numeric,
  "vlr_custo_impos" numeric,
  "vlr_custo_lubri" numeric,
  "vlr_custo_manut" numeric,
  "vlr_custo_mo" numeric,
  "vlr_lucro" numeric,
  "vlr_custo_outro" numeric,
  "vlr_custo_serv" numeric,
  "vlr_custo_trans" numeric,
  "vlr_custo_prod" numeric,
  "vlr_custo_bombagem" numeric,
  "vlr_custo_lab" numeric,
  "vlr_custo_comer" numeric,
  "vlr_custo_adm" numeric,
  "usina_tab_preco" bigint,
  "id_cadast" text,
  "id_atual" text,
  "markup" numeric,
  "medida_aditivo" bigint,
  "imposto_aplicado_estadual" numeric,
  "imposto_aplicado_federal" numeric,
  "impostos_aplicados_servico" numeric,
  "impostos_aplicados_faturamento" numeric
);
create index if not exists "ix_con_custo_serv" on "topcon_sys"."con_custo_serv" ("usina", "dt_inicio_valid");
alter table "topcon_sys"."con_custo_serv" enable row level security;
create table if not exists "topcon_sys"."con_def_familia" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "cod_insumo1" text,
  "descr_insumo1" text,
  "cod_insumo2" text,
  "descr_insumo2" text,
  "cod_insumo3" text,
  "descr_insumo3" text,
  "cod_insumo4" text,
  "descr_insumo4" text,
  "grupo_mat" text,
  "descr_conjunto" text,
  "slumps" text,
  "versao" text
);
create index if not exists "ix_con_def_familia" on "topcon_sys"."con_def_familia" ("usina", "uso", "pedra", "cod_insumo1", "cod_insumo2", "cod_insumo3", "cod_insumo4");
alter table "topcon_sys"."con_def_familia" enable row level security;
create table if not exists "topcon_sys"."con_def_familia_dc" (
  "usina" bigint,
  "especificacao" text,
  "insumo" text,
  "fornecedor" bigint,
  "vlr_insumo" numeric,
  "vlr_frete" numeric,
  "custo_unit_comp" numeric,
  "fator_perda" numeric,
  "coef_risco_forn" numeric,
  "peso_especifico" numeric,
  "massa_unitaria" numeric,
  "mpa" numeric
);
create index if not exists "ix_con_def_familia_dc" on "topcon_sys"."con_def_familia_dc" ("usina", "especificacao", "insumo", "fornecedor");
alter table "topcon_sys"."con_def_familia_dc" enable row level security;
create table if not exists "topcon_sys"."con_def_familia_resist" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "mpa" numeric,
  "consumo" bigint,
  "especificacao" text,
  "external_id" text
);
create index if not exists "ix_con_def_familia_resist" on "topcon_sys"."con_def_familia_resist" ("usina", "uso", "pedra", "slump", "versao", "tp_resist", "mpa", "consumo", "especificacao");
alter table "topcon_sys"."con_def_familia_resist" enable row level security;
create table if not exists "topcon_sys"."con_def_familiacusto" (
  "usina" bigint,
  "especificacao" text,
  "dt_preco" date,
  "insumo" text,
  "forn" bigint,
  "fator_conversao" numeric,
  "unid_compra" text
);
create index if not exists "ix_con_def_familiacusto" on "topcon_sys"."con_def_familiacusto" ("usina", "especificacao", "dt_preco", "insumo", "forn");
alter table "topcon_sys"."con_def_familiacusto" enable row level security;
create table if not exists "topcon_sys"."con_def_familiar" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "status" bigint,
  "g1_cod1" text,
  "g1_cod2" text,
  "g1_cod3" text,
  "g1_descr" text,
  "g2_cod1" text,
  "g2_cod2" text,
  "g2_descr" text,
  "g3_cod1" text,
  "g3_cod2" text,
  "g3_cod3" text,
  "g3_descr" text,
  "g4_cod1" text,
  "g4_cod2" text,
  "g4_cod3" text,
  "g4_cod4" text,
  "g4_descr" text,
  "g5_cod1" text,
  "g5_cod2" text,
  "g5_descr" text,
  "fcks" text,
  "consumos" text,
  "especificacao" text,
  "exp_dt_inicio" date,
  "exp_dt_termino" date,
  "exp_por" text,
  "exp_historico" text,
  "hom_dt" date,
  "hom_vig_inicio" date,
  "hom_vig_termino" date,
  "hom_por" text,
  "arq_data" date,
  "arq_por" text,
  "arq_motivo" text,
  "dt_criacao" date,
  "criado_por" text,
  "origem" text,
  "tab_custo" date,
  "temp_lanc" bigint,
  "desvio_dias" bigint,
  "desvio_horas" bigint,
  "obs" text,
  "g6_cod1" text,
  "g6_cod2" text,
  "g6_descr" text,
  "fib_pct" bigint,
  "aditivo_peso" bigint,
  "pct_alm_nf" numeric,
  "manual" bigint,
  "vlr_servico" numeric,
  "vlr_custo_outro" numeric,
  "markup" numeric,
  "fatorac" text,
  "fator_ac_ativo" text,
  "tipo_info_dt" bigint,
  "slump_inicial" bigint,
  "external_id" text,
  "numeracao_familia" bigint
);
create index if not exists "ix_con_def_familiar" on "topcon_sys"."con_def_familiar" ("usina", "uso", "pedra", "slump", "versao", "especificacao");
alter table "topcon_sys"."con_def_familiar" enable row level security;
create table if not exists "topcon_sys"."con_demais_servicos" (
  "cod" bigint,
  "usina" bigint,
  "merc" text,
  "unid_cobranca" text,
  "casas_decimais" bigint,
  "preco_sugerido" numeric,
  "preco_minimo" numeric,
  "frequencia_cobranca" text,
  "forma_cobranca" text,
  "atualiza_estoque" bigint
);
create index if not exists "ix_con_demais_servicos" on "topcon_sys"."con_demais_servicos" ("cod");
alter table "topcon_sys"."con_demais_servicos" enable row level security;
create table if not exists "topcon_sys"."con_dept_enc" (
  "cod_dept" bigint,
  "cod_encarregado" bigint
);
create index if not exists "ix_con_dept_enc" on "topcon_sys"."con_dept_enc" ("cod_dept", "cod_encarregado");
alter table "topcon_sys"."con_dept_enc" enable row level security;
create table if not exists "topcon_sys"."con_desc_usuario" (
  "usuario" text,
  "pct_desc" numeric
);
create index if not exists "ix_con_desc_usuario" on "topcon_sys"."con_desc_usuario" ("usuario");
alter table "topcon_sys"."con_desc_usuario" enable row level security;
create table if not exists "topcon_sys"."con_descr_vlr_avulso" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_descr_vlr_avulso" on "topcon_sys"."con_descr_vlr_avulso" ("cod");
alter table "topcon_sys"."con_descr_vlr_avulso" enable row level security;
create table if not exists "topcon_sys"."con_desvio_padrao" (
  "usina" bigint,
  "desvio_padrao" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_desvio_padrao" on "topcon_sys"."con_desvio_padrao" ("usina");
alter table "topcon_sys"."con_desvio_padrao" enable row level security;
create table if not exists "topcon_sys"."con_dist_usina_cep" (
  "usina_entrega" bigint,
  "cep" text,
  "distancia_km" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_aprov" text
);
create index if not exists "ix_con_dist_usina_cep" on "topcon_sys"."con_dist_usina_cep" ("usina_entrega", "cep");
alter table "topcon_sys"."con_dist_usina_cep" enable row level security;
create table if not exists "topcon_sys"."con_dsr" (
  "usina" bigint,
  "mes_ano" date,
  "dias" bigint,
  "dias_uteis" bigint,
  "dsr" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_dsr" on "topcon_sys"."con_dsr" ("usina", "mes_ano");
alter table "topcon_sys"."con_dsr" enable row level security;
create table if not exists "topcon_sys"."con_email_template" (
  "tipo_aprov" bigint,
  "assunto" text,
  "html" text
);
create index if not exists "ix_con_email_template" on "topcon_sys"."con_email_template" ("tipo_aprov");
alter table "topcon_sys"."con_email_template" enable row level security;
create table if not exists "topcon_sys"."con_equip_combust" (
  "cod_combustivel" bigint,
  "cod_equipamento" text
);
create index if not exists "ix_con_equip_combust" on "topcon_sys"."con_equip_combust" ("cod_combustivel", "cod_equipamento");
alter table "topcon_sys"."con_equip_combust" enable row level security;
create table if not exists "topcon_sys"."con_equip_funcionand" (
  "data" date,
  "cod_equip" text,
  "funcionando" text,
  "motivo" bigint,
  "obs" text,
  "id_cadast" text,
  "motorista" bigint
);
create index if not exists "ix_con_equip_funcionand" on "topcon_sys"."con_equip_funcionand" ("data", "cod_equip");
alter table "topcon_sys"."con_equip_funcionand" enable row level security;
create table if not exists "topcon_sys"."con_equip_historico" (
  "usina" bigint,
  "equipamento" text,
  "data" date,
  "status" text
);
create index if not exists "ix_con_equip_historico" on "topcon_sys"."con_equip_historico" ("usina", "equipamento", "data");
alter table "topcon_sys"."con_equip_historico" enable row level security;
create table if not exists "topcon_sys"."con_equip_locacao" (
  "equipamento" text,
  "descricao" text,
  "vlr_locacao" numeric,
  "qtde_horas" bigint,
  "fat_minimo_dias" bigint,
  "fat_minimo_hora" bigint,
  "pct_excedente" numeric,
  "custo_km_desmob" numeric,
  "km_livre_obra" bigint,
  "custo_km_obra_e" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_equip_locacao" on "topcon_sys"."con_equip_locacao" ("equipamento");
alter table "topcon_sys"."con_equip_locacao" enable row level security;
create table if not exists "topcon_sys"."con_equip_rastrin" (
  "tipo" bigint,
  "tipo_rastrin" text
);
create index if not exists "ix_con_equip_rastrin" on "topcon_sys"."con_equip_rastrin" ("tipo");
alter table "topcon_sys"."con_equip_rastrin" enable row level security;
create table if not exists "topcon_sys"."con_equipamento" (
  "cod" text,
  "tipo" bigint,
  "betoneira" text,
  "bomba" text,
  "placa" text,
  "descr" text,
  "capacidade_m3" bigint,
  "mtr_bomb_usina" bigint,
  "mtr_bomb_codigo" bigint,
  "ajudande_usina" bigint,
  "ajudande_codigo" bigint,
  "ajudante_codigo2" bigint,
  "ajudante_codigo3" bigint,
  "usina_alocada" bigint,
  "id_cadast" text,
  "id_atual" text,
  "marca" text,
  "modelo" text,
  "chassis" text,
  "ano" bigint,
  "status" bigint,
  "dt_ocorrencia" date,
  "tp_processo" bigint,
  "ativo" text,
  "possui_gps" text,
  "dt_inst_gps" date,
  "gps" text,
  "no_processo" text,
  "obs" text,
  "grupo" bigint,
  "sub_grupo" bigint,
  "item" bigint,
  "grupo2" bigint,
  "sub_grupo2" bigint,
  "item2" bigint,
  "ano_modelo" bigint,
  "renavam" text,
  "combustivel" bigint,
  "capac_pot_cil" text,
  "faixa_ipva" text,
  "proprietario" bigint,
  "tacografo_quebr" text,
  "uf" text,
  "final_placa" text,
  "cap_lit_comb" bigint,
  "peso_equip" numeric,
  "controla_km" bigint,
  "controla_horim" bigint,
  "horim_quebr" text,
  "dt_subst_tac" date,
  "dt_subst_hori" date,
  "cc" bigint,
  "max_km_abast" bigint,
  "max_litros_abast" numeric,
  "km_inicial" bigint,
  "horimetro_inicial" numeric,
  "seguro_resp_seg" bigint,
  "seguro_cnpj_cpf_responsavel" text,
  "seguro_nome_seguradora" text,
  "seguro_cnpj_seguradora" text,
  "seguro_num_apolice" text,
  "seguro_num_averbacao" text,
  "tipo_rodado" bigint,
  "tipo_carroceria" bigint,
  "rntrc" text,
  "tipo_proprietario" bigint,
  "id_external" text,
  "integra_abast" bigint,
  "capkg" bigint,
  "external_id" text
);
create index if not exists "ix_con_equipamento" on "topcon_sys"."con_equipamento" ("cod");
alter table "topcon_sys"."con_equipamento" enable row level security;
create table if not exists "topcon_sys"."con_etq_campos" (
  "seq" bigint,
  "seqcampo" bigint,
  "nome" text,
  "formato" text,
  "fonte" text,
  "tamanhofonte" bigint,
  "italico" text,
  "negrito" text,
  "campotabela" text,
  "poshoriz" numeric,
  "posvert" numeric,
  "poscampode" bigint,
  "poscampoate" bigint,
  "seqconcat" bigint,
  "caractconcat" text
);
create index if not exists "ix_con_etq_campos" on "topcon_sys"."con_etq_campos" ("seq", "seqcampo");
alter table "topcon_sys"."con_etq_campos" enable row level security;
create table if not exists "topcon_sys"."con_etq_folha" (
  "seq" bigint,
  "descricao" text,
  "qtdelin" bigint,
  "qtdecol" bigint,
  "margemesq" numeric,
  "margemsup" numeric,
  "disthoriz" numeric,
  "distvert" numeric,
  "altura" numeric,
  "largura" numeric,
  "sel" text
);
create index if not exists "ix_con_etq_folha" on "topcon_sys"."con_etq_folha" ("seq");
alter table "topcon_sys"."con_etq_folha" enable row level security;
create table if not exists "topcon_sys"."con_faixa_hr_bomba" (
  "usina" bigint,
  "seq" bigint,
  "hr_inicio" text,
  "hr_fim" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_faixa_hr_bomba" on "topcon_sys"."con_faixa_hr_bomba" ("usina", "seq");
alter table "topcon_sys"."con_faixa_hr_bomba" enable row level security;
create table if not exists "topcon_sys"."con_fase_lead" (
  "codigo" bigint,
  "descricao" text
);
create index if not exists "ix_con_fase_lead" on "topcon_sys"."con_fase_lead" ("codigo");
alter table "topcon_sys"."con_fase_lead" enable row level security;
create table if not exists "topcon_sys"."con_fase_oportunidade" (
  "codigo" bigint,
  "descricao" text,
  "cor" text
);
create index if not exists "ix_con_fase_oportunidade" on "topcon_sys"."con_fase_oportunidade" ("codigo");
alter table "topcon_sys"."con_fase_oportunidade" enable row level security;
create table if not exists "topcon_sys"."con_fat_controle" (
  "id" bigint,
  "filial" bigint,
  "num_faturamento" bigint,
  "id_faturamento" text,
  "status" text
);
create index if not exists "ix_con_fat_controle" on "topcon_sys"."con_fat_controle" ("id");
alter table "topcon_sys"."con_fat_controle" enable row level security;
create table if not exists "topcon_sys"."con_fat_email_hist" (
  "id" text,
  "tipo_registro" text,
  "chave" text,
  "dt_hr" timestamp,
  "usuario" text,
  "email_destino" text,
  "id_arquivo" text
);
create index if not exists "ix_con_fat_email_hist" on "topcon_sys"."con_fat_email_hist" ("id");
alter table "topcon_sys"."con_fat_email_hist" enable row level security;
create table if not exists "topcon_sys"."con_fat_envio_email" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" text,
  "dt_hr_envio" timestamp,
  "usuario" text,
  "email_destino" text
);
create index if not exists "ix_con_fat_envio_email" on "topcon_sys"."con_fat_envio_email" ("filial", "cli", "tp_doc", "num_nf", "ser", "sub_ser");
alter table "topcon_sys"."con_fat_envio_email" enable row level security;
create table if not exists "topcon_sys"."con_fat_parcial" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "filial_faturamento" bigint,
  "num_faturamento" bigint,
  "fatura" bigint,
  "tp_fatura" text
);
create index if not exists "ix_con_fat_parcial" on "topcon_sys"."con_fat_parcial" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "tp_fatura");
alter table "topcon_sys"."con_fat_parcial" enable row level security;
create table if not exists "topcon_sys"."con_fator_risco" (
  "usina" bigint,
  "insumo" text,
  "coef_risco_forn" numeric,
  "coef_perda" numeric,
  "id_cadast" text,
  "id_atual" text,
  "data_vigencia" date
);
create index if not exists "ix_con_fator_risco" on "topcon_sys"."con_fator_risco" ("usina", "data_vigencia", "insumo");
alter table "topcon_sys"."con_fator_risco" enable row level security;
create table if not exists "topcon_sys"."con_fatura_email" (
  "emp" bigint,
  "aplicativo" text,
  "num" bigint,
  "email_mensagem" text,
  "email_assinatura" text,
  "email_copia" text,
  "email_remetente" text,
  "email_assunto" text
);
create index if not exists "ix_con_fatura_email" on "topcon_sys"."con_fatura_email" ("emp", "aplicativo", "num");
alter table "topcon_sys"."con_fatura_email" enable row level security;
create table if not exists "topcon_sys"."con_faturamento" (
  "filial" bigint,
  "num_faturamento" bigint,
  "data_faturamento" timestamp,
  "id_faturamento" text,
  "data_remessa" timestamp,
  "id_remessa" text,
  "data_retorno" timestamp,
  "id_retorno" text
);
create index if not exists "ix_con_faturamento" on "topcon_sys"."con_faturamento" ("filial", "num_faturamento");
alter table "topcon_sys"."con_faturamento" enable row level security;
create table if not exists "topcon_sys"."con_fech_com_vend" (
  "vendedor_repres" bigint,
  "data_base" date,
  "grupo" text,
  "usina" bigint,
  "filial_emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "no_doc" bigint,
  "seq" text,
  "cliente" bigint,
  "dt_oper" date,
  "dt_vcto" date,
  "dt_rec" date,
  "volume" numeric,
  "vlr_doc" numeric,
  "vlr_com_total" numeric,
  "bomba_concr" text,
  "comis_conc" numeric,
  "comis_bomba" numeric,
  "obs" text,
  "id_geracao_cap" text,
  "no_lanc_cap" bigint,
  "bomba" bigint
);
create index if not exists "ix_con_fech_com_vend" on "topcon_sys"."con_fech_com_vend" ("vendedor_repres", "data_base", "grupo", "usina", "filial_emp", "tp_doc", "ser_doc", "no_doc", "seq", "bomba_concr");
alter table "topcon_sys"."con_fech_com_vend" enable row level security;
create table if not exists "topcon_sys"."con_finalidade_ctr" (
  "codigo" bigint,
  "descricao" text
);
create index if not exists "ix_con_finalidade_ctr" on "topcon_sys"."con_finalidade_ctr" ("codigo");
alter table "topcon_sys"."con_finalidade_ctr" enable row level security;
create table if not exists "topcon_sys"."con_formula_conc_hist" (
  "tab_custo" date,
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "dt_inic_valid" date,
  "insumo" text,
  "qtde_p_m3" numeric,
  "fator_ac" numeric,
  "peso_total" bigint,
  "custo_p_m3" numeric,
  "custo_a_m3" numeric,
  "dt_calc_custo" date,
  "custo_p_recal" numeric,
  "custo_a_recal" numeric,
  "dt_recal" date,
  "id_cadast" text,
  "id_atual" text,
  "especificacao" text,
  "custo_unitario" numeric,
  "massa_unitaria" numeric,
  "custo_fp_m3" numeric,
  "pct_alm_nf" numeric,
  "external_id" text,
  "numeracao_caracteristica" bigint
);
create index if not exists "ix_con_formula_conc_hist" on "topcon_sys"."con_formula_conc_hist" ("especificacao", "usina", "tab_custo", "uso", "pedra", "slump", "versao", "tp_resist", "fck", "consumo", "insumo");
alter table "topcon_sys"."con_formula_conc_hist" enable row level security;
create table if not exists "topcon_sys"."con_formula_concreto" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "dt_inic_valid" date,
  "insumo" text,
  "qtde_p_m3" numeric,
  "fator_ac" numeric,
  "peso_total" bigint,
  "custo_p_m3" numeric,
  "custo_a_m3" numeric,
  "dt_calc_custo" date,
  "custo_p_recal" numeric,
  "custo_a_recal" numeric,
  "dt_recal" date,
  "id_cadast" text,
  "id_atual" text,
  "especificacao" text,
  "custo_unitario" numeric,
  "massa_unitaria" numeric,
  "custo_fp_m3" numeric,
  "pct_alm_nf" numeric,
  "external_id" text,
  "numeracao_caracteristica" bigint
);
create index if not exists "ix_con_formula_concreto" on "topcon_sys"."con_formula_concreto" ("especificacao", "usina", "uso", "pedra", "slump", "versao", "tp_resist", "fck", "consumo", "insumo");
alter table "topcon_sys"."con_formula_concreto" enable row level security;
create table if not exists "topcon_sys"."con_formula_dt" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "insumo_form" text,
  "valor" numeric,
  "especificacao" text,
  "valor_original" numeric
);
create index if not exists "ix_con_formula_dt" on "topcon_sys"."con_formula_dt" ("especificacao", "tp_resist", "fck", "consumo", "insumo_form");
alter table "topcon_sys"."con_formula_dt" enable row level security;
create table if not exists "topcon_sys"."con_formula_dt_especificacao" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "sigla_compos" text,
  "especificacao" text
);
create index if not exists "ix_con_formula_dt_especificacao" on "topcon_sys"."con_formula_dt_especificacao" ("usina", "uso", "pedra", "slump", "versao", "tp_resist", "fck", "consumo", "sigla_compos");
alter table "topcon_sys"."con_formula_dt_especificacao" enable row level security;
create table if not exists "topcon_sys"."con_formula_volume" (
  "usina" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "versao" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "insumo" text,
  "qtde" numeric,
  "especificacao" text
);
create index if not exists "ix_con_formula_volume" on "topcon_sys"."con_formula_volume" ("especificacao", "tp_resist", "fck", "consumo", "insumo");
alter table "topcon_sys"."con_formula_volume" enable row level security;
create table if not exists "topcon_sys"."con_funcionario" (
  "usina" bigint,
  "cod" bigint,
  "nome" text,
  "nome_reduzido" text,
  "funcao" bigint,
  "re" bigint,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "status" bigint,
  "usuario_sist" text,
  "departamento" bigint,
  "hr_entrada_padr" text,
  "hr_saida_padr" text,
  "hr_entrada_sab" text,
  "hr_saida_sab" text,
  "interv" bigint,
  "vlr_hora" numeric,
  "email" text,
  "comprador" text,
  "transp_mp" text,
  "external_id" text
);
create index if not exists "ix_con_funcionario" on "topcon_sys"."con_funcionario" ("cod");
alter table "topcon_sys"."con_funcionario" enable row level security;
create table if not exists "topcon_sys"."con_hist_equip" (
  "cod_equip" text,
  "data" date,
  "usina" bigint,
  "rodando" text,
  "transf" bigint
);
create index if not exists "ix_con_hist_equip" on "topcon_sys"."con_hist_equip" ("cod_equip", "data", "usina");
alter table "topcon_sys"."con_hist_equip" enable row level security;
create table if not exists "topcon_sys"."con_hist_func" (
  "data" date,
  "cod_func" bigint,
  "usina" bigint,
  "trabalhou" text,
  "motivo" bigint
);
create index if not exists "ix_con_hist_func" on "topcon_sys"."con_hist_func" ("data", "cod_func", "usina");
alter table "topcon_sys"."con_hist_func" enable row level security;
create table if not exists "topcon_sys"."con_inconst_contrato" (
  "cod" bigint,
  "desc" text
);
create index if not exists "ix_con_inconst_contrato" on "topcon_sys"."con_inconst_contrato" ("cod");
alter table "topcon_sys"."con_inconst_contrato" enable row level security;
create table if not exists "topcon_sys"."con_insumo" (
  "nivel1" bigint,
  "nivel2" bigint,
  "nivel3" bigint,
  "nivel4" bigint,
  "nivel5" bigint,
  "nivel6" bigint,
  "descr" text,
  "cod_insumo" text,
  "coef_perda" numeric,
  "cor" text,
  "id_cadast" text,
  "id_atual" text,
  "external_id" text,
  "tipo_insumo" text,
  "id_tech" text
);
create index if not exists "ix_con_insumo" on "topcon_sys"."con_insumo" ("nivel1", "nivel2", "nivel3", "nivel4", "nivel5", "nivel6");
alter table "topcon_sys"."con_insumo" enable row level security;
create table if not exists "topcon_sys"."con_insumo_ajuste" (
  "cod_insumo" text,
  "percentual" numeric,
  "usina" bigint,
  "usuario" text,
  "dt_ajuste" timestamp
);
alter table "topcon_sys"."con_insumo_ajuste" enable row level security;
create table if not exists "topcon_sys"."con_insumo_forn" (
  "cod_insumo" text,
  "cod_forn" bigint,
  "peso_especifico" numeric,
  "massa_unit" numeric,
  "mpa" numeric,
  "unid_compra" text,
  "dias_reposicao" bigint,
  "id_cadast" text,
  "id_atual" text,
  "dens_material" numeric,
  "nota_debito" bigint,
  "external_id" text
);
create index if not exists "ix_con_insumo_forn" on "topcon_sys"."con_insumo_forn" ("cod_insumo", "cod_forn");
alter table "topcon_sys"."con_insumo_forn" enable row level security;
create table if not exists "topcon_sys"."con_insumo_umidade_contratada" (
  "usina" bigint,
  "cod_insumo" text,
  "cod_fornecedor" bigint,
  "data_vigencia" date,
  "umidade" numeric
);
create index if not exists "ix_con_insumo_umidade_contratada" on "topcon_sys"."con_insumo_umidade_contratada" ("usina", "cod_insumo", "cod_fornecedor", "data_vigencia");
alter table "topcon_sys"."con_insumo_umidade_contratada" enable row level security;
create table if not exists "topcon_sys"."con_integra_pendente" (
  "usina" bigint,
  "cod_integracao" text,
  "data" date,
  "observacao" text,
  "dt_ultima_verif" timestamp
);
create index if not exists "ix_con_integra_pendente" on "topcon_sys"."con_integra_pendente" ("usina", "cod_integracao", "data");
alter table "topcon_sys"."con_integra_pendente" enable row level security;
create table if not exists "topcon_sys"."con_integracao_clicksign" (
  "id" text,
  "corpo_email" text,
  "obriga_documento_oficial" bigint,
  "obriga_selfie" bigint,
  "obriga_assinatura_manuscrita" bigint,
  "obriga_reconhecimento_facial" bigint,
  "notifica_cliente_confirmacao_assinatura" bigint,
  "id_atual" text,
  "envia_assinatura_contratada" bigint,
  "envia_assinatura_responsavel_solidario" bigint,
  "email_contratada" text,
  "ddd_wpp_contratada" bigint,
  "telefone_wpp_contratada" bigint,
  "metodo_envio_assinatura_contratada" bigint,
  "metodo_autenticacao_contratada" bigint,
  "permite_assinatura_whatsapp" bigint,
  "primeira_testemunha" bigint,
  "segunda_testemunha" bigint,
  "assina_aditivo" bigint,
  "exigir_assinatura_aprovacao" bigint,
  "prazo_limite_assinatura" bigint
);
create index if not exists "ix_con_integracao_clicksign" on "topcon_sys"."con_integracao_clicksign" ("id");
alter table "topcon_sys"."con_integracao_clicksign" enable row level security;
create table if not exists "topcon_sys"."con_integracoes" (
  "integracao_tipo" text,
  "parametro_nome" text,
  "parametro_valor" text
);
create index if not exists "ix_con_integracoes" on "topcon_sys"."con_integracoes" ("integracao_tipo", "parametro_nome");
alter table "topcon_sys"."con_integracoes" enable row level security;
create table if not exists "topcon_sys"."con_item_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "dt_op" date,
  "trans" bigint,
  "cfop" bigint,
  "seq_cfop" bigint,
  "tp_estq" bigint,
  "merc" text,
  "qt" numeric,
  "preco_un" numeric,
  "vl_tot" numeric,
  "vl_desc" numeric,
  "vl_frete" numeric,
  "vl_seg" numeric,
  "vl_o_desp" numeric,
  "custo_tot_item" numeric,
  "peso" numeric,
  "id_cadast" text,
  "id_atual" text,
  "traco_concreto" text,
  "volume" numeric,
  "qtd_estoque" numeric,
  "interv_estq" bigint,
  "umidade" numeric,
  "local_insumo" bigint,
  "qtde_comis" numeric,
  "local_estoque" text,
  "dt_hr_ult_atual" timestamp,
  "qt_teorica" numeric,
  "percentual_ajuste" numeric,
  "umidade_contratada" numeric
);
create index if not exists "ix_con_item_nf" on "topcon_sys"."con_item_nf" ("filial", "interv", "tp_doc", "ser", "num_nf", "seq_nf", "num_seq_item_nf");
alter table "topcon_sys"."con_item_nf" enable row level security;
create table if not exists "topcon_sys"."con_lay_cob_bco" (
  "id_layout" bigint,
  "cod_oficial" text,
  "cnab" bigint,
  "descr" text,
  "dt_vigencia" date,
  "cod_reg_header" bigint,
  "cod_reg_detalhe" bigint,
  "cod_reg_pos_inicial" bigint,
  "cod_reg_tamanho" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_lay_cob_bco" on "topcon_sys"."con_lay_cob_bco" ("id_layout");
alter table "topcon_sys"."con_lay_cob_bco" enable row level security;
create table if not exists "topcon_sys"."con_lay_cob_bco_det" (
  "id_layout" bigint,
  "tp_registro" bigint,
  "seq" bigint,
  "pos_inicial" bigint,
  "tamanho" bigint,
  "qt_decimal" bigint
);
create index if not exists "ix_con_lay_cob_bco_det" on "topcon_sys"."con_lay_cob_bco_det" ("id_layout", "tp_registro", "seq");
alter table "topcon_sys"."con_lay_cob_bco_det" enable row level security;
create table if not exists "topcon_sys"."con_lay_cob_bco_fixo" (
  "tp_registro" bigint,
  "seq" bigint,
  "campo" text,
  "conteudo" text
);
create index if not exists "ix_con_lay_cob_bco_fixo" on "topcon_sys"."con_lay_cob_bco_fixo" ("tp_registro", "seq");
alter table "topcon_sys"."con_lay_cob_bco_fixo" enable row level security;
create table if not exists "topcon_sys"."con_lead" (
  "usina" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "ano_visita" bigint,
  "numero_visita" bigint,
  "ano_oportunidade" bigint,
  "numero_oportunidade" bigint,
  "data" date,
  "cliente" text,
  "ddd" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text,
  "vendedor" bigint,
  "via_captacao" bigint,
  "fase" bigint,
  "classificacao" bigint,
  "proxima_etapa" text,
  "obra_nome" text,
  "cep" text,
  "endereco" text,
  "numero" bigint,
  "complemento" text,
  "bairro" text,
  "municipio" bigint,
  "motivo_perda" bigint,
  "observacao_interna" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_lead" on "topcon_sys"."con_lead" ("usina", "ano_lead", "numero_lead");
alter table "topcon_sys"."con_lead" enable row level security;
create table if not exists "topcon_sys"."con_lead_anexo" (
  "id" text,
  "usina" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "descricao" text,
  "nome" text,
  "usuario" text,
  "data" date,
  "data_hora" timestamp
);
create index if not exists "ix_con_lead_anexo" on "topcon_sys"."con_lead_anexo" ("id");
alter table "topcon_sys"."con_lead_anexo" enable row level security;
create table if not exists "topcon_sys"."con_lead_contato" (
  "usina" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "sequencia" bigint,
  "nome" text,
  "funcao" bigint,
  "ddd" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text
);
create index if not exists "ix_con_lead_contato" on "topcon_sys"."con_lead_contato" ("usina", "ano_lead", "numero_lead", "sequencia");
alter table "topcon_sys"."con_lead_contato" enable row level security;
create table if not exists "topcon_sys"."con_lead_hist" (
  "id" text,
  "usina" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "tipo" text,
  "descricao" text,
  "data" date,
  "hora" text,
  "data_retorno" date,
  "hora_retorno" text,
  "id_cadast" text
);
create index if not exists "ix_con_lead_hist" on "topcon_sys"."con_lead_hist" ("id");
alter table "topcon_sys"."con_lead_hist" enable row level security;
create table if not exists "topcon_sys"."con_lev_obra" (
  "usina" bigint,
  "ano_levto" bigint,
  "no_levto" bigint,
  "dt" date,
  "anotador" bigint,
  "atividade" bigint,
  "emp" text,
  "ender_escritor" text,
  "contato" text,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "celular" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "cep" text,
  "mun" bigint,
  "compl" text,
  "num" bigint,
  "bairro" text,
  "fis_jur" text
);
create index if not exists "ix_con_lev_obra" on "topcon_sys"."con_lev_obra" ("usina", "ano_levto", "no_levto");
alter table "topcon_sys"."con_lev_obra" enable row level security;
create table if not exists "topcon_sys"."con_local_insumo" (
  "usina" bigint,
  "inicio_validade" date,
  "balanca" bigint,
  "insumo" text,
  "tipo" text,
  "local" bigint,
  "local2" bigint,
  "local3" bigint,
  "id_cadast" text,
  "id_atual" text,
  "cod_automacao" text
);
create index if not exists "ix_con_local_insumo" on "topcon_sys"."con_local_insumo" ("usina", "inicio_validade", "balanca", "insumo");
alter table "topcon_sys"."con_local_insumo" enable row level security;
create table if not exists "topcon_sys"."con_marmita" (
  "usina" bigint,
  "data" date,
  "funcionario" bigint,
  "equipamento" text,
  "usina_contrato" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "nf" bigint,
  "hr_saida" text,
  "id_aprov" text,
  "motivo_inclusao" text
);
create index if not exists "ix_con_marmita" on "topcon_sys"."con_marmita" ("usina", "data", "funcionario");
alter table "topcon_sys"."con_marmita" enable row level security;
create table if not exists "topcon_sys"."con_mat_pesado" (
  "usina" bigint,
  "ponto_carga" bigint,
  "data_validade" date,
  "ativo" text,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "mat_traco" text,
  "pct_mat_traco" numeric,
  "mat_pesagem" text,
  "pct_mat_pesagem" numeric
);
create index if not exists "ix_con_mat_pesado" on "topcon_sys"."con_mat_pesado" ("usina", "ponto_carga", "data_validade", "ativo", "uso", "pedra", "slump", "mat_traco", "mat_pesagem");
alter table "topcon_sys"."con_mat_pesado" enable row level security;
create table if not exists "topcon_sys"."con_mdfe" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_mdfe" bigint,
  "chave_acesso" text,
  "serie" text,
  "chave_nfe" text,
  "dt_emissao" timestamp,
  "tp_emit" bigint,
  "tp_transp" bigint,
  "tp_emis" bigint,
  "tp_rod" bigint,
  "tp_car" bigint,
  "tp_prop" bigint,
  "seguro_resp_seg" bigint,
  "seguro_cnpj_cpf_responsavel" text,
  "seguro_nome_seguradora" text,
  "seguro_cnpj_seguradora" text,
  "seguro_num_apolice" text,
  "seguro_num_averbacao" text,
  "rntrc" text,
  "status_sefaz" text,
  "id_reboque1" text,
  "id_reboque2" text,
  "id_reboque3" text,
  "tp_rod_reboque1" text,
  "tp_car_reboque1" text,
  "tp_prop_reboque1" text,
  "rntrc_reboque1" text,
  "tp_rod_reboque2" text,
  "tp_car_reboque2" text,
  "tp_prop_reboque2" text,
  "rntrc_reboque2" text,
  "tp_rod_reboque3" text,
  "tp_car_reboque3" text,
  "tp_prop_reboque3" text,
  "rntrc_reboque3" text
);
create index if not exists "ix_con_mdfe" on "topcon_sys"."con_mdfe" ("filial", "tp_doc", "serie", "num_mdfe");
alter table "topcon_sys"."con_mdfe" enable row level security;
create table if not exists "topcon_sys"."con_mdfe_terceiros" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "dt_nf" date,
  "hr_emissao" bigint,
  "chave_nfe" text,
  "num_lacre" bigint,
  "ident_veic" text,
  "vl_cont_nf" numeric,
  "loc_ent" bigint,
  "transp" bigint,
  "qt_vol" bigint,
  "esp_vol" text,
  "peso_bruto" numeric,
  "peso_liq" numeric,
  "id_reboque1" text,
  "id_reboque2" text,
  "id_reboque3" text
);
create index if not exists "ix_con_mdfe_terceiros" on "topcon_sys"."con_mdfe_terceiros" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."con_mdfe_terceiros" enable row level security;
create table if not exists "topcon_sys"."con_mdfe_xml" (
  "chave_acesso" text,
  "xml_mdfe" text
);
create index if not exists "ix_con_mdfe_xml" on "topcon_sys"."con_mdfe_xml" ("chave_acesso");
alter table "topcon_sys"."con_mdfe_xml" enable row level security;
create table if not exists "topcon_sys"."con_med_cons_equip" (
  "tp_equip" bigint,
  "tp_bloq" bigint,
  "qtd_litros" bigint,
  "media_calc" numeric
);
create index if not exists "ix_con_med_cons_equip" on "topcon_sys"."con_med_cons_equip" ("tp_equip");
alter table "topcon_sys"."con_med_cons_equip" enable row level security;
create table if not exists "topcon_sys"."con_mens_padrao" (
  "cod" bigint,
  "produto" bigint,
  "mens" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_mens_padrao" on "topcon_sys"."con_mens_padrao" ("cod");
alter table "topcon_sys"."con_mens_padrao" enable row level security;
create table if not exists "topcon_sys"."con_meta_vendedor" (
  "vendedor" bigint,
  "ano_mes" text,
  "volume_meta_m3" numeric,
  "observacao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_meta_vendedor" on "topcon_sys"."con_meta_vendedor" ("vendedor", "ano_mes");
alter table "topcon_sys"."con_meta_vendedor" enable row level security;
create table if not exists "topcon_sys"."con_modelo_contrato_usina" (
  "usina" bigint,
  "segmento" bigint,
  "valor" text
);
create index if not exists "ix_con_modelo_contrato_usina" on "topcon_sys"."con_modelo_contrato_usina" ("usina", "segmento");
alter table "topcon_sys"."con_modelo_contrato_usina" enable row level security;
create table if not exists "topcon_sys"."con_motivo_nfunc" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_motivo_nfunc" on "topcon_sys"."con_motivo_nfunc" ("cod");
alter table "topcon_sys"."con_motivo_nfunc" enable row level security;
create table if not exists "topcon_sys"."con_motivo_perda" (
  "codigo" bigint,
  "descricao" text,
  "ativo" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_motivo_perda" on "topcon_sys"."con_motivo_perda" ("codigo");
alter table "topcon_sys"."con_motivo_perda" enable row level security;
create table if not exists "topcon_sys"."con_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "num_fatura" bigint,
  "dt_fatura" date,
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "seq_prog" bigint,
  "traco_concreto" text,
  "cimento" text,
  "qtde_m3_bt" numeric,
  "motivo_cancel" bigint,
  "respon_cliente" text,
  "comis_motorista" text,
  "comis_bombista" text,
  "comis_aj_bomba" text,
  "comis_vendedor" text,
  "comis_represent" text,
  "represent" bigint,
  "bomba" bigint,
  "bombista" bigint,
  "aux_bombista" bigint,
  "motorista" bigint,
  "num_lacre" bigint,
  "m3_faltantes" numeric,
  "adic_he" numeric,
  "adic_feriado" numeric,
  "tp_cobranca" bigint,
  "dt_vcto_1_parc" date,
  "pos_venda" text,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "usina" bigint,
  "m3_bombeado" numeric,
  "no_betoneira" text,
  "slump" bigint,
  "hr_solicitada" text,
  "hr_saida_usina" text,
  "hr_cheg_obra" text,
  "hr_desc_inic" text,
  "hr_desc_final" text,
  "minutos_desc" bigint,
  "vlr_venda_m3" numeric,
  "vlr_venda_total" numeric,
  "material_m3" numeric,
  "material_total" numeric,
  "no_faturamento" bigint,
  "data_remessa" date,
  "vlr_m3_fal" numeric,
  "com_vend_concr" numeric,
  "com_repr_concr" numeric,
  "vlr_com_motoris" numeric,
  "vlr_com_bombist" numeric,
  "vlr_com_aux1" numeric,
  "vlr_com_aux2" numeric,
  "aux_bombista2" bigint,
  "vlr_vend_tb_tot" numeric,
  "com_vend_bomb" numeric,
  "com_repre_bomb" numeric,
  "vendedor" bigint,
  "pct_adic_he" numeric,
  "pct_adic_feriad" numeric,
  "terc_bomba" bigint,
  "inconsistencias" text,
  "id_aprov_dir" text,
  "cod_inconsist" bigint,
  "com_vend_serv" numeric,
  "com_vend_dif" numeric,
  "com_repres_serv" numeric,
  "com_repres_dif" numeric,
  "vol_entreg_bomb" numeric,
  "dt_prog" date,
  "pendente" bigint,
  "obs_traco" text,
  "hr_saida_obra" text,
  "hr_cheg_usina" text,
  "hr_saida_func" text,
  "traco_concreto_pesado" text,
  "velocimento" bigint,
  "hr_prevista" text,
  "cp" text,
  "slump_real" bigint,
  "adicao_agua" bigint,
  "atraso_entrega" bigint,
  "espera_usina" bigint,
  "tempo_ida" bigint,
  "espera_inicio" bigint,
  "espera_saida_ob" bigint,
  "tempo_volta" bigint,
  "tempo_total" bigint,
  "tempo_entre_via" bigint,
  "tempo_vg_saida" bigint,
  "km_rodado" bigint,
  "motivo_atraso_concr" text,
  "motivo_atraso" text,
  "velocimento_final" bigint,
  "obs_entrega" text,
  "hr_saida_usina_efet" text,
  "tempo_na_obra" bigint,
  "vlr_bomba_unit" numeric,
  "vlr_bomba_total" numeric,
  "valor_tx_comis" numeric,
  "comis_ger" text,
  "balanca" bigint,
  "status_km_limit" text,
  "aux_bombista3" bigint,
  "vlr_com_aux3" numeric,
  "obs_cancel" text,
  "obs_aprov_km" text,
  "especificacao_traco" text,
  "desvio" text,
  "pct_desvio_pesagem" numeric,
  "corte_agua_pm3" numeric,
  "peso_rodoviario" bigint,
  "horimetro_inicial" bigint,
  "horimetro_final" bigint,
  "horimetro_rodado" bigint,
  "chave_familia" text,
  "vl_desco" numeric,
  "vl_bomba_calc" numeric,
  "qtde_cp" bigint,
  "dt_coleta_cp" date,
  "id_coleta_cp" text,
  "descartado_cp" text,
  "codigos_cps" text,
  "usado_na_nf" bigint,
  "importou_da_nf" bigint,
  "cod_integracao" text,
  "obs_pesagem" text,
  "motivo_incons" text,
  "mao_obra_prop" text,
  "dt_prorrog_pend" date,
  "vibr_qtde" bigint,
  "vibr_vlr_unit" numeric,
  "vibr_vlr_total" numeric,
  "vibr_vendedor" bigint,
  "qtde_pausa_pes" bigint,
  "qtde_manual_pes" bigint,
  "hr_recomend_utl" text,
  "ag_colocada_usi" bigint,
  "ag_colocar_obr" bigint,
  "import_rfid" bigint,
  "import_gps" bigint,
  "com_vend_tx_extra" numeric,
  "com_vend_vibr" numeric,
  "com_vend_padr" numeric,
  "filial_estoque" bigint,
  "cod_transp_mp" bigint,
  "com_transp_mp" numeric,
  "id_aprov_lab" text,
  "dt_base_comis" date,
  "custo_conc_pes" numeric,
  "hora_ini_carga" text,
  "hora_fim_carga" text,
  "m3_bomb_cob" numeric,
  "usina_fat" bigint,
  "filial_fat" bigint,
  "atualizado_em" timestamp
);
create index if not exists "ix_con_nf" on "topcon_sys"."con_nf" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."con_nf" enable row level security;
create table if not exists "topcon_sys"."con_nf_aplicacao_taxa_extra" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "taxa_extra" text,
  "justificativa" text,
  "cobra_taxa_orig" text,
  "cobra_taxa_atual" text,
  "qt_original" numeric,
  "qt_atual" numeric,
  "vlr_original" numeric,
  "vlr_atual" numeric,
  "id_cadast" text,
  "id_atual" text,
  "id_exclusao" text,
  "id_aprov" text
);
create index if not exists "ix_con_nf_aplicacao_taxa_extra" on "topcon_sys"."con_nf_aplicacao_taxa_extra" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "taxa_extra");
alter table "topcon_sys"."con_nf_aplicacao_taxa_extra" enable row level security;
create table if not exists "topcon_sys"."con_nf_complemento" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "qt_tx_perm" bigint,
  "tx_permanencia" numeric,
  "mot_mud_tx_perm" text,
  "vlr_adicionais" numeric,
  "vlr_desconto" numeric,
  "qt_adic_km" bigint,
  "vl_unit_adic_km" numeric,
  "vlr_tot_adic_km" numeric,
  "qt_adic_ret_con" numeric,
  "vl_unit_ret_con" numeric,
  "vlr_tot_ret_con" numeric,
  "hora_trabalhada" numeric,
  "vlr_venda_h" numeric,
  "vlr_venda_total_h" numeric,
  "equip_transp_mp" text,
  "vlr_hora_trabalhada" numeric,
  "hora_bomb_inicio" text,
  "hora_bomb_fim" text,
  "adic_he_vlr_unit" numeric,
  "qtd_adic_he" numeric,
  "adic_feriado_vlr_unit" numeric,
  "qtd_adic_feriado" numeric,
  "hora_trab_efetiva" numeric,
  "vlr_demais_servicos" numeric,
  "vlr_total_cobranca" numeric,
  "reaproveitamento_prog" numeric,
  "lote_emissao" bigint,
  "hora_bomba_pronta" text,
  "temp_cob_ociosid_bomb" numeric,
  "tx_perm_bomb_vlr_unit" numeric,
  "tx_permanencia_bomba" numeric,
  "id_usuario_mold_remota" text,
  "confirm_mold_remota" text,
  "obs_mold_remota" text,
  "versao_contrato" bigint,
  "ordem_bt" bigint,
  "just_ordem_bt" text,
  "id_dispatch" text,
  "qtde_tub_extra" numeric,
  "vlr_unit_tub" numeric,
  "vlr_total_tub_extra" numeric,
  "adic_zmrc" numeric,
  "pct_adic_zmrc" numeric,
  "vlr_prev_ibscbs" numeric,
  "coletado_cp" text,
  "numeracao_produto" bigint,
  "vlr_total_material_serv" numeric,
  "aprov_medicao" text,
  "idade_cps" text,
  "num_romaneio_newdispatch" bigint,
  "integra_terceiros" bigint
);
create index if not exists "ix_con_nf_complemento" on "topcon_sys"."con_nf_complemento" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf");
alter table "topcon_sys"."con_nf_complemento" enable row level security;
create table if not exists "topcon_sys"."con_nf_integracao_terceiros" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "processado" bigint,
  "external_id" text,
  "integration_type" text
);
create index if not exists "ix_con_nf_integracao_terceiros" on "topcon_sys"."con_nf_integracao_terceiros" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "integration_type");
alter table "topcon_sys"."con_nf_integracao_terceiros" enable row level security;
create table if not exists "topcon_sys"."con_nf_rmd" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "rmd" bigint
);
create index if not exists "ix_con_nf_rmd" on "topcon_sys"."con_nf_rmd" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf");
alter table "topcon_sys"."con_nf_rmd" enable row level security;
create table if not exists "topcon_sys"."con_nf_servicos" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "seq_serv_obra" bigint,
  "merc" text,
  "quantidade" numeric,
  "valor_unitario" numeric,
  "valor_total" numeric,
  "valor_cobrado" numeric
);
create index if not exists "ix_con_nf_servicos" on "topcon_sys"."con_nf_servicos" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "seq_serv_obra");
alter table "topcon_sys"."con_nf_servicos" enable row level security;
create table if not exists "topcon_sys"."con_obras" (
  "usina" bigint,
  "numero" bigint,
  "ano_levto" bigint,
  "no_levto" bigint,
  "ano_visita" bigint,
  "no_visita" bigint,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "ano_proposta" bigint,
  "no_proposta" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "obra_nome" text,
  "obra_cep" text,
  "obra_end" text,
  "obra_num" bigint,
  "obra_compl" text,
  "obra_bairro" text,
  "obra_mun" bigint,
  "email" text,
  "obra_usina" bigint,
  "obra_km_usina" bigint,
  "obra_km_usina_via_google" bigint,
  "obra_prev_inic" date,
  "obra_prev_term" date,
  "obra_prazo" bigint,
  "obra_tipo" bigint,
  "obra_porte" bigint,
  "obra_fase" bigint,
  "fase_concorrenc" bigint,
  "obra_topografia" bigint,
  "obra_acesso" bigint,
  "obra_vl_pedagio" numeric,
  "obra_zrmc" text,
  "obra_proib_est" text,
  "obra_fio_tensao" text,
  "obra_zona_azul" text,
  "obra_nova" text,
  "obra_inic_conc" text,
  "obra_contato" text,
  "obra_cont_func" bigint,
  "obra_cont_fone" bigint,
  "obra_cont_cel" bigint,
  "obra_contato1" text,
  "obra_cont1_func" bigint,
  "obra_cont1_fone" bigint,
  "obra_cont1_cel" bigint,
  "obra_captado_v" bigint,
  "obra_refer_aces" text,
  "obra_pct_rp_cim" numeric,
  "obra_pct_rp_ped" numeric,
  "obra_pct_rp_are" numeric,
  "obra_pct_rp_obr" numeric,
  "obra_pct_rp_die" numeric,
  "concorrente" bigint,
  "id_cadast" text,
  "id_atual" text,
  "obra_resultado" bigint,
  "obra_desist" bigint,
  "obra_dt_desist" date,
  "obra_usina_sec" bigint,
  "obra_km_usina_s" bigint,
  "volume_concreto" numeric,
  "cond_pgto" bigint,
  "tipo_cobranca" bigint,
  "ganhou" text,
  "reaj_id_solic" text,
  "reaj_aprov_verb" text,
  "reaj_id_aprov" text,
  "obs" text,
  "bco_cobranca" bigint,
  "reaj_sts_aprov" text,
  "reaj_cien_aprov" text,
  "cp_prv_tipo" text,
  "cp_prv_qtde" bigint,
  "cp_prv_intvl_m3" bigint,
  "intinerante" text,
  "seq" bigint,
  "obra_cont_ddd" bigint,
  "obra_cont_ddd1" bigint,
  "vibr_qtde" bigint,
  "vibr_vlr_unit" numeric,
  "volume_pcarga" numeric,
  "obra_cel_ddd" bigint,
  "obra_cel_ddd1" bigint,
  "obra_radio" text,
  "temp_ate_a_obra" bigint,
  "temp_bt_na_obra" bigint,
  "url_mapa_obra" text,
  "status_comercial" bigint,
  "status_cadastro" bigint,
  "status_financeiro" bigint,
  "status_engenharia" bigint,
  "vlr_demais_servicos" numeric,
  "obra_cei" text,
  "obra_obs" text,
  "tempo_ciclo_prev" bigint,
  "custo_proje_trans" numeric,
  "obra_benef_fiscal" text,
  "rota_padrao" text,
  "email_resp_tecnico" text,
  "tribcontrib_nfs" text,
  "id_imp_is" bigint,
  "id_imp_cbs" bigint,
  "id_imp_ibs" bigint,
  "volume_status_comercial" bigint,
  "usa_adicional_zmrc" text,
  "necessita_aprov_zmrc" text,
  "condicao_pagamento_status_comercial" bigint,
  "tempo_descarga" bigint,
  "codigo_cib" text,
  "construcao_civil_tipo_alvara" bigint,
  "observacao_carteira" text
);
create index if not exists "ix_con_obras" on "topcon_sys"."con_obras" ("usina", "numero", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_obras" enable row level security;
create table if not exists "topcon_sys"."con_obras_dem_serv" (
  "usina" bigint,
  "obra" bigint,
  "seq" bigint,
  "cod" bigint,
  "usina_entrega" bigint,
  "merc" text,
  "unid_cobranca" text,
  "casas_decimais" bigint,
  "preco_sugerido" numeric,
  "preco_minimo" numeric,
  "frequencia_cobranca" text,
  "forma_cobranca" text,
  "atualiza_estoque" bigint,
  "preco_proposto" numeric,
  "quantidade" numeric
);
create index if not exists "ix_con_obras_dem_serv" on "topcon_sys"."con_obras_dem_serv" ("usina", "obra", "seq");
alter table "topcon_sys"."con_obras_dem_serv" enable row level security;
create table if not exists "topcon_sys"."con_obras_dem_serv_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "seq" bigint,
  "cod" bigint,
  "usina_entrega" bigint,
  "merc" text,
  "unid_cobranca" text,
  "casas_decimais" bigint,
  "preco_sugerido" numeric,
  "preco_minimo" numeric,
  "frequencia_cobranca" text,
  "forma_cobranca" text,
  "atualiza_estoque" bigint,
  "preco_proposto" numeric,
  "quantidade" numeric
);
create index if not exists "ix_con_obras_dem_serv_versao" on "topcon_sys"."con_obras_dem_serv_versao" ("num_versao", "usina", "obra", "seq");
alter table "topcon_sys"."con_obras_dem_serv_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_frente" (
  "id" text,
  "obra_usina" bigint,
  "obra_numero" bigint,
  "obra_sequencia" bigint,
  "obra_nome" text,
  "obra_cep" text,
  "obra_end" text,
  "obra_num" bigint,
  "obra_compl" text,
  "obra_bairro" text
);
create index if not exists "ix_con_obras_frente" on "topcon_sys"."con_obras_frente" ("id");
alter table "topcon_sys"."con_obras_frente" enable row level security;
create table if not exists "topcon_sys"."con_obras_indicador" (
  "obra_usina" bigint,
  "obra_numero" bigint,
  "interveniente" bigint,
  "vendedor" bigint
);
create index if not exists "ix_con_obras_indicador" on "topcon_sys"."con_obras_indicador" ("obra_usina", "obra_numero");
alter table "topcon_sys"."con_obras_indicador" enable row level security;
create table if not exists "topcon_sys"."con_obras_indicador_versao" (
  "obra_usina" bigint,
  "obra_numero" bigint,
  "obra_versao" bigint,
  "interveniente" bigint,
  "vendedor" bigint
);
create index if not exists "ix_con_obras_indicador_versao" on "topcon_sys"."con_obras_indicador_versao" ("obra_usina", "obra_numero", "obra_versao");
alter table "topcon_sys"."con_obras_indicador_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_log_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "dt_hora_evento" timestamp,
  "usuario" text,
  "evento" text,
  "complemento" text,
  "obs" text,
  "envia_email" text,
  "email_enviado" text,
  "dt_hora_email" text,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "seq_log" bigint
);
create index if not exists "ix_con_obras_log_versao" on "topcon_sys"."con_obras_log_versao" ("num_versao", "usina", "obra", "dt_hora_evento", "usuario", "evento", "ano_chamada", "no_chamada", "seq_log");
alter table "topcon_sys"."con_obras_log_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_mp" (
  "usina" bigint,
  "obra" bigint,
  "cod" bigint,
  "seleciona" text,
  "id_solic" text,
  "aprov_desc" text,
  "id_aprov" text,
  "ciente" text
);
create index if not exists "ix_con_obras_mp" on "topcon_sys"."con_obras_mp" ("usina", "obra", "cod");
alter table "topcon_sys"."con_obras_mp" enable row level security;
create table if not exists "topcon_sys"."con_obras_mp_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "cod" bigint,
  "seleciona" text,
  "id_solic" text,
  "aprov_desc" text,
  "id_aprov" text,
  "ciente" text
);
create index if not exists "ix_con_obras_mp_versao" on "topcon_sys"."con_obras_mp_versao" ("num_versao", "usina", "obra", "cod");
alter table "topcon_sys"."con_obras_mp_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_projecao" (
  "usina" bigint,
  "no_obra" bigint,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "periodo" date,
  "volume_m3" numeric,
  "saldo_m3" numeric
);
create index if not exists "ix_con_obras_projecao" on "topcon_sys"."con_obras_projecao" ("usina", "no_obra", "ano_chamada", "no_chamada", "periodo");
alter table "topcon_sys"."con_obras_projecao" enable row level security;
create table if not exists "topcon_sys"."con_obras_reajuste" (
  "usina" bigint,
  "obra" bigint,
  "men_reajuste" text
);
create index if not exists "ix_con_obras_reajuste" on "topcon_sys"."con_obras_reajuste" ("usina", "obra");
alter table "topcon_sys"."con_obras_reajuste" enable row level security;
create table if not exists "topcon_sys"."con_obras_reajuste_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "men_reajuste" text
);
create index if not exists "ix_con_obras_reajuste_versao" on "topcon_sys"."con_obras_reajuste_versao" ("num_versao", "usina", "obra");
alter table "topcon_sys"."con_obras_reajuste_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_trib_mun" (
  "usina_contrato" bigint,
  "no_obra" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "usina" bigint,
  "no_obra_pref" text,
  "ccm_obra" text,
  "trib_iss" bigint,
  "ret_iss" text
);
create index if not exists "ix_con_obras_trib_mun" on "topcon_sys"."con_obras_trib_mun" ("usina_contrato", "no_obra", "num_contrato", "ano_contrato", "usina");
alter table "topcon_sys"."con_obras_trib_mun" enable row level security;
create table if not exists "topcon_sys"."con_obras_trib_mun_versao" (
  "num_versao" bigint,
  "usina_contrato" bigint,
  "no_obra" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "usina" bigint,
  "no_obra_pref" text,
  "ccm_obra" text,
  "trib_iss" bigint,
  "ret_iss" text
);
create index if not exists "ix_con_obras_trib_mun_versao" on "topcon_sys"."con_obras_trib_mun_versao" ("usina_contrato", "no_obra", "num_contrato", "ano_contrato", "usina");
alter table "topcon_sys"."con_obras_trib_mun_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_tx" (
  "usina" bigint,
  "obra" bigint,
  "seq" bigint,
  "seq_obra" bigint,
  "selecionado" text,
  "id_solic" text,
  "aprov_desc" text,
  "id_aprov" text,
  "ciente" text
);
create index if not exists "ix_con_obras_tx" on "topcon_sys"."con_obras_tx" ("usina", "obra", "seq");
alter table "topcon_sys"."con_obras_tx" enable row level security;
create table if not exists "topcon_sys"."con_obras_tx_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "seq" bigint,
  "seq_obra" bigint,
  "selecionado" text,
  "id_solic" text,
  "aprov_desc" text,
  "id_aprov" text,
  "ciente" text
);
create index if not exists "ix_con_obras_tx_versao" on "topcon_sys"."con_obras_tx_versao" ("num_versao", "usina", "obra", "seq");
alter table "topcon_sys"."con_obras_tx_versao" enable row level security;
create table if not exists "topcon_sys"."con_obras_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "numero" bigint,
  "ano_levto" bigint,
  "no_levto" bigint,
  "ano_visita" bigint,
  "no_visita" bigint,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "ano_proposta" bigint,
  "no_proposta" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "obra_nome" text,
  "obra_cep" text,
  "obra_end" text,
  "obra_num" bigint,
  "obra_compl" text,
  "obra_bairro" text,
  "obra_mun" bigint,
  "email" text,
  "obra_usina" bigint,
  "obra_km_usina" bigint,
  "obra_km_usina_via_google" bigint,
  "obra_prev_inic" date,
  "obra_prev_term" date,
  "obra_prazo" bigint,
  "obra_tipo" bigint,
  "obra_porte" bigint,
  "obra_fase" bigint,
  "fase_concorrenc" bigint,
  "obra_topografia" bigint,
  "obra_acesso" bigint,
  "obra_vl_pedagio" numeric,
  "obra_zrmc" text,
  "obra_proib_est" text,
  "obra_fio_tensao" text,
  "obra_zona_azul" text,
  "obra_nova" text,
  "obra_inic_conc" text,
  "obra_contato" text,
  "obra_cont_func" bigint,
  "obra_cont_fone" bigint,
  "obra_cont_cel" bigint,
  "obra_contato1" text,
  "obra_cont1_func" bigint,
  "obra_cont1_fone" bigint,
  "obra_cont1_cel" bigint,
  "obra_captado_v" bigint,
  "obra_refer_aces" text,
  "obra_pct_rp_cim" numeric,
  "obra_pct_rp_ped" numeric,
  "obra_pct_rp_are" numeric,
  "obra_pct_rp_obr" numeric,
  "obra_pct_rp_die" numeric,
  "concorrente" bigint,
  "id_cadast" text,
  "id_atual" text,
  "obra_resultado" bigint,
  "obra_desist" bigint,
  "obra_dt_desist" date,
  "obra_usina_sec" bigint,
  "obra_km_usina_s" bigint,
  "volume_concreto" numeric,
  "cond_pgto" bigint,
  "tipo_cobranca" bigint,
  "ganhou" text,
  "reaj_id_solic" text,
  "reaj_aprov_verb" text,
  "reaj_id_aprov" text,
  "obs" text,
  "bco_cobranca" bigint,
  "reaj_sts_aprov" text,
  "reaj_cien_aprov" text,
  "cp_prv_tipo" text,
  "cp_prv_qtde" bigint,
  "cp_prv_intvl_m3" bigint,
  "intinerante" text,
  "seq" bigint,
  "obra_cont_ddd" bigint,
  "obra_cont_ddd1" bigint,
  "vibr_qtde" bigint,
  "vibr_vlr_unit" numeric,
  "volume_pcarga" numeric,
  "obra_cel_ddd" bigint,
  "obra_cel_ddd1" bigint,
  "obra_radio" text,
  "temp_ate_a_obra" bigint,
  "temp_bt_na_obra" bigint,
  "url_mapa_obra" text,
  "status_comercial" bigint,
  "status_cadastro" bigint,
  "status_financeiro" bigint,
  "status_engenharia" bigint,
  "vlr_demais_servicos" numeric,
  "obra_cei" text,
  "obra_obs" text,
  "tempo_ciclo_prev" bigint,
  "custo_proje_trans" numeric,
  "obra_benef_fiscal" text,
  "rota_padrao" text,
  "email_resp_tecnico" text,
  "tribcontrib_nfs" text,
  "id_imp_is" bigint,
  "id_imp_cbs" bigint,
  "id_imp_ibs" bigint,
  "volume_status_comercial" bigint,
  "usa_adicional_zmrc" text,
  "necessita_aprov_zmrc" text,
  "condicao_pagamento_status_comercial" bigint,
  "tempo_descarga" bigint,
  "codigo_cib" text,
  "construcao_civil_tipo_alvara" bigint,
  "observacao_carteira" text
);
create index if not exists "ix_con_obras_versao" on "topcon_sys"."con_obras_versao" ("num_versao", "usina", "numero", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_obras_versao" enable row level security;
create table if not exists "topcon_sys"."con_oportunidade" (
  "usina" bigint,
  "ano_oportunidade" bigint,
  "num_oportunidade" bigint,
  "oportunidade_nome" text,
  "interveniente" bigint,
  "cliente" text,
  "obra_nome" text,
  "ddd_telefone" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text,
  "data" date,
  "vendedor" bigint,
  "segmentacao" bigint,
  "tipo_oportunidade" bigint,
  "via_captacao" bigint,
  "fase" bigint,
  "classificacao" bigint,
  "proxima_etapa" text,
  "previsao_fechamento" date,
  "motivo_perda" bigint,
  "concorrente" bigint,
  "obra_porte" bigint,
  "obra_fase" bigint,
  "obra_volume_estimado" numeric,
  "obra_valor_estimado" numeric,
  "obra_refer_acesso" text,
  "previsao_inicio" date,
  "previsao_termino" date,
  "cep" text,
  "endereco" text,
  "numero" bigint,
  "complemento" text,
  "bairro" text,
  "municipio" bigint,
  "obs_interna" text,
  "ano_lead" bigint,
  "num_lead" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "usina_entrega" bigint,
  "distancia_usina" bigint
);
create index if not exists "ix_con_oportunidade" on "topcon_sys"."con_oportunidade" ("usina", "ano_oportunidade", "num_oportunidade");
alter table "topcon_sys"."con_oportunidade" enable row level security;
create table if not exists "topcon_sys"."con_oportunidade_anexo" (
  "usina" bigint,
  "ano_oportunidade" bigint,
  "num_oportunidade" bigint,
  "interv" bigint,
  "nome" text,
  "data_hora" timestamp
);
create index if not exists "ix_con_oportunidade_anexo" on "topcon_sys"."con_oportunidade_anexo" ("interv", "nome", "data_hora");
alter table "topcon_sys"."con_oportunidade_anexo" enable row level security;
create table if not exists "topcon_sys"."con_oportunidade_contato" (
  "usina" bigint,
  "ano_oportunidade" bigint,
  "num_oportunidade" bigint,
  "seq" bigint,
  "funcao" bigint,
  "nome" text,
  "ddd_telefone" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text
);
create index if not exists "ix_con_oportunidade_contato" on "topcon_sys"."con_oportunidade_contato" ("usina", "ano_oportunidade", "num_oportunidade", "seq");
alter table "topcon_sys"."con_oportunidade_contato" enable row level security;
create table if not exists "topcon_sys"."con_oportunidade_hist" (
  "id" text,
  "usina" bigint,
  "ano_oportunidade" bigint,
  "numero_oportunidade" bigint,
  "tipo" text,
  "descricao" text,
  "data" date,
  "hora" text,
  "data_retorno" date,
  "hora_retorno" text,
  "id_cadast" text
);
create index if not exists "ix_con_oportunidade_hist" on "topcon_sys"."con_oportunidade_hist" ("id");
alter table "topcon_sys"."con_oportunidade_hist" enable row level security;
create table if not exists "topcon_sys"."con_parametro" (
  "fator_markup" numeric,
  "pct_desc_limite" numeric,
  "dt_ult_calc_cus" date,
  "dt_ult_recl_cus" date,
  "dt_ult_calc_tab" date,
  "dt_ult_recl_tab" date,
  "prx_tab_prc" bigint,
  "comp_atual" date,
  "id_cadast" text,
  "id_atual" text,
  "tempo_min_retor" bigint,
  "mens_alt_pedra" text,
  "mens_alt_slump" text,
  "data_vigencia" date,
  "prox_faturam" bigint,
  "dia_base_com_mt" bigint,
  "dia_base_com_vend" bigint,
  "dia_base_com_rep" bigint,
  "dia_base_com_transp" bigint,
  "versao_vigente" bigint,
  "desvio_max_pesagem" numeric,
  "tp_item" text,
  "apv_dig_ignora" bigint,
  "apv_dig_divisao" bigint,
  "nf_pend_servico" bigint,
  "prev_ent_mat" bigint,
  "ap_dist_usina" bigint,
  "permitevendrep" bigint,
  "obriga_profissa" bigint,
  "ger_ctr_analise" bigint,
  "ncm_traco_concr" text,
  "perc_acresc_cim" numeric,
  "endereco_web" text,
  "gtin_traco_conc" text,
  "obriga_email_pf" bigint,
  "blq_imp_p_aprov" bigint,
  "bx_mat_pri_s_umid" bigint,
  "inf_cim_danfe" bigint,
  "obs_obra_no_danfe" bigint,
  "util_perc_reaproveitamento" text,
  "endereco_api" text,
  "obs_prop_web" text,
  "slump_em_cm" text,
  "end_sinc_abast" text,
  "end_inf_sinc" text,
  "info_usina_prop" bigint,
  "ocultar_taxa_proposta" bigint,
  "obriga_tipo_obra" bigint,
  "obriga_porte_obra" bigint,
  "informa_hora_prevista" bigint,
  "validade_proposta" bigint,
  "men_reajuste_padrao" text,
  "lim_aumento_valor_mcc" numeric,
  "lim_aumento_percentual_mcc" numeric,
  "encerra_contrato_auto" bigint,
  "informar_bomba_terc" bigint,
  "obriga_fim_vigencia" bigint,
  "obriga_num_ctr_anterior" bigint
);
create index if not exists "ix_con_parametro" on "topcon_sys"."con_parametro" ("data_vigencia");
alter table "topcon_sys"."con_parametro" enable row level security;
create table if not exists "topcon_sys"."con_peca_concretar" (
  "cod" bigint,
  "descricao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_peca_concretar" on "topcon_sys"."con_peca_concretar" ("cod");
alter table "topcon_sys"."con_peca_concretar" enable row level security;
create table if not exists "topcon_sys"."con_pedra" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text,
  "external_id" text,
  "id_tech" text
);
create index if not exists "ix_con_pedra" on "topcon_sys"."con_pedra" ("cod");
alter table "topcon_sys"."con_pedra" enable row level security;
create table if not exists "topcon_sys"."con_pendenc_cobranca" (
  "vendedor" bigint,
  "representante" bigint,
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "dt_pendencia" date,
  "vlr_comis_vend" numeric,
  "vlr_comis_repre" numeric,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "usina" bigint,
  "liq_lot_bx" bigint
);
create index if not exists "ix_con_pendenc_cobranca" on "topcon_sys"."con_pendenc_cobranca" ("vendedor", "representante", "ano_contrato", "num_contrato", "usina_contrato", "dt_pendencia");
alter table "topcon_sys"."con_pendenc_cobranca" enable row level security;
create table if not exists "topcon_sys"."con_pesagem" (
  "id" text,
  "usina" bigint,
  "ponto_carga" bigint,
  "tipo" text,
  "id_automacao" bigint,
  "data" date,
  "hora_inicio" timestamp,
  "hora_fim" timestamp,
  "volume" numeric,
  "status" text,
  "info" text,
  "cod_integracao" text
);
create index if not exists "ix_con_pesagem" on "topcon_sys"."con_pesagem" ("id");
alter table "topcon_sys"."con_pesagem" enable row level security;
create table if not exists "topcon_sys"."con_pesagem_descarte" (
  "id" text,
  "id_pesagem_item" text,
  "id_descarte" text,
  "data_hora_descarte" timestamp,
  "observacao" text
);
create index if not exists "ix_con_pesagem_descarte" on "topcon_sys"."con_pesagem_descarte" ("id");
alter table "topcon_sys"."con_pesagem_descarte" enable row level security;
create table if not exists "topcon_sys"."con_pesagem_desdobramento" (
  "id_pesagem" text,
  "id_item" text,
  "id_original" text,
  "id_item_original" text,
  "volume" numeric,
  "quantidade" numeric
);
create index if not exists "ix_con_pesagem_desdobramento" on "topcon_sys"."con_pesagem_desdobramento" ("id_pesagem", "id_item");
alter table "topcon_sys"."con_pesagem_desdobramento" enable row level security;
create table if not exists "topcon_sys"."con_pesagem_item" (
  "id" text,
  "id_pesagem" text,
  "id_automacao" bigint,
  "tipo_insumo" text,
  "local_insumo" bigint,
  "local_estoque" text,
  "material" text,
  "quantidade" numeric,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "seq_item_nf" bigint,
  "id_vinculo" text,
  "justificativa" text,
  "inconsistencia_vinculo" text,
  "umidade_efetiva" numeric
);
create index if not exists "ix_con_pesagem_item" on "topcon_sys"."con_pesagem_item" ("id");
alter table "topcon_sys"."con_pesagem_item" enable row level security;
create table if not exists "topcon_sys"."con_pesagem_nf" (
  "id" text,
  "id_pesagem" text,
  "quantidade_m3" numeric,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "usuario_vinculo" text,
  "dt_hr_vinculo" timestamp
);
create index if not exists "ix_con_pesagem_nf" on "topcon_sys"."con_pesagem_nf" ("id");
alter table "topcon_sys"."con_pesagem_nf" enable row level security;
create table if not exists "topcon_sys"."con_ponto_carga" (
  "usina" bigint,
  "codigo" bigint,
  "descr" text,
  "ip_maquina" text,
  "caminho_arq" text,
  "usuario_bd" text,
  "tipo_automacao" bigint,
  "caminho_ret" text,
  "tempo_bt_usina" bigint,
  "cam_ret_pes_man" text,
  "url_base_api" text
);
create index if not exists "ix_con_ponto_carga" on "topcon_sys"."con_ponto_carga" ("usina", "codigo");
alter table "topcon_sys"."con_ponto_carga" enable row level security;
create table if not exists "topcon_sys"."con_ponto_cod_traco" (
  "usina" bigint,
  "ponto_carga" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "tp_resist" bigint,
  "mpa" numeric,
  "consumo" bigint,
  "cod_automacao" text,
  "desc_automacao" text
);
alter table "topcon_sys"."con_ponto_cod_traco" enable row level security;
create table if not exists "topcon_sys"."con_ponto_compto" (
  "usina" bigint,
  "balanca" bigint,
  "tipo" text,
  "numero" bigint,
  "descr" text,
  "local_estoque" text
);
create index if not exists "ix_con_ponto_compto" on "topcon_sys"."con_ponto_compto" ("usina", "balanca", "tipo", "numero");
alter table "topcon_sys"."con_ponto_compto" enable row level security;
create table if not exists "topcon_sys"."con_ponto_layout" (
  "cod" bigint,
  "descr" text,
  "posi_usina" bigint,
  "tam_usina" bigint,
  "posi_dt" bigint,
  "tam_dt" bigint,
  "posi_hr" bigint,
  "tam_hr" bigint,
  "posi_re" bigint,
  "tam_re" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_ponto_layout" on "topcon_sys"."con_ponto_layout" ("cod");
alter table "topcon_sys"."con_ponto_layout" enable row level security;
create table if not exists "topcon_sys"."con_ponto_relogio" (
  "id_ponto" bigint,
  "usina" bigint,
  "ip" text,
  "porta" bigint,
  "intervalo" bigint,
  "ultimo_nsr" bigint,
  "qtd_registros" bigint,
  "atualiza" text,
  "id_modelo" bigint,
  "login" text,
  "id_relogio" text,
  "ultimo_nsr_data" timestamp
);
create index if not exists "ix_con_ponto_relogio" on "topcon_sys"."con_ponto_relogio" ("id_ponto", "usina");
alter table "topcon_sys"."con_ponto_relogio" enable row level security;
create table if not exists "topcon_sys"."con_ponto_relogio_modelo" (
  "id_modelo" bigint,
  "marca" text,
  "modelo" text
);
create index if not exists "ix_con_ponto_relogio_modelo" on "topcon_sys"."con_ponto_relogio_modelo" ("id_modelo");
alter table "topcon_sys"."con_ponto_relogio_modelo" enable row level security;
create table if not exists "topcon_sys"."con_prazo_rup_cp" (
  "qtde_cp" bigint,
  "prazos_rupturas" text
);
create index if not exists "ix_con_prazo_rup_cp" on "topcon_sys"."con_prazo_rup_cp" ("qtde_cp");
alter table "topcon_sys"."con_prazo_rup_cp" enable row level security;
create table if not exists "topcon_sys"."con_preco_bomba" (
  "usina" bigint,
  "tipo_bomba" bigint,
  "inicio_validade" date,
  "tipo_calc" bigint,
  "taxa_minima" numeric,
  "m3_ate" bigint,
  "pr_m3_bombedado" numeric,
  "taxa_minima_des" numeric,
  "m3_atem" bigint,
  "pr_m3_bombm" numeric,
  "id_cadast" text,
  "id_atual" text,
  "tipo_calc_hora" bigint,
  "vlr_tx_min_h_tab" numeric,
  "tempo_min_tab" numeric,
  "vlr_hora_tab" numeric,
  "vlr_tx_hora_min" numeric,
  "tempo_min" numeric,
  "vlr_hora_min" numeric,
  "pct_desc_tx" numeric,
  "pct_desc_m3" numeric
);
create index if not exists "ix_con_preco_bomba" on "topcon_sys"."con_preco_bomba" ("usina", "tipo_bomba", "inicio_validade");
alter table "topcon_sys"."con_preco_bomba" enable row level security;
create table if not exists "topcon_sys"."con_preco_bomba_terc" (
  "bombista" bigint,
  "tipo_bomba" bigint,
  "inicio_validade" date,
  "m3_ate" bigint,
  "taxa_minima" numeric,
  "pr_m3_bombedado" numeric,
  "id_cadast" text,
  "id_atual" text,
  "pct_desc_tx" numeric,
  "taxa_minima_des" numeric,
  "pct_desc_m3" numeric,
  "pr_m3_bombm" numeric,
  "m3_atem" bigint,
  "cond_pagto" bigint,
  "operacao" bigint,
  "tipo_calc" bigint,
  "tp_cobranca" bigint,
  "tp_doc_cap" bigint
);
create index if not exists "ix_con_preco_bomba_terc" on "topcon_sys"."con_preco_bomba_terc" ("bombista", "tipo_bomba", "inicio_validade");
alter table "topcon_sys"."con_preco_bomba_terc" enable row level security;
create table if not exists "topcon_sys"."con_preco_bomba_tub" (
  "usina" bigint,
  "tipo_bomba" bigint,
  "dist_tub_de" bigint,
  "dist_tub_ate" bigint,
  "permitido" text,
  "vlr_adic_tub" numeric,
  "id_cadast" text,
  "id_atual" text,
  "cod" bigint
);
create index if not exists "ix_con_preco_bomba_tub" on "topcon_sys"."con_preco_bomba_tub" ("usina", "tipo_bomba", "dist_tub_de", "dist_tub_ate");
alter table "topcon_sys"."con_preco_bomba_tub" enable row level security;
create table if not exists "topcon_sys"."con_preco_concorrent" (
  "concorrente" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "data_tabela" date,
  "fck" numeric,
  "consumo" bigint,
  "valor_venda" numeric
);
create index if not exists "ix_con_preco_concorrent" on "topcon_sys"."con_preco_concorrent" ("concorrente", "uso", "pedra", "slump", "data_tabela", "fck", "consumo");
alter table "topcon_sys"."con_preco_concorrent" enable row level security;
create table if not exists "topcon_sys"."con_prensa" (
  "codigo" bigint,
  "prensa_nome" text,
  "integracao" bigint
);
create index if not exists "ix_con_prensa" on "topcon_sys"."con_prensa" ("codigo");
alter table "topcon_sys"."con_prensa" enable row level security;
create table if not exists "topcon_sys"."con_prensa_carga" (
  "prensa_nome" text,
  "carga" text
);
create index if not exists "ix_con_prensa_carga" on "topcon_sys"."con_prensa_carga" ("prensa_nome");
alter table "topcon_sys"."con_prensa_carga" enable row level security;
create table if not exists "topcon_sys"."con_prensa_integracao" (
  "codigo" bigint,
  "nome" text
);
create index if not exists "ix_con_prensa_integracao" on "topcon_sys"."con_prensa_integracao" ("codigo");
alter table "topcon_sys"."con_prensa_integracao" enable row level security;
create table if not exists "topcon_sys"."con_prensa_operador" (
  "prensa" bigint,
  "operador" text
);
create index if not exists "ix_con_prensa_operador" on "topcon_sys"."con_prensa_operador" ("prensa", "operador");
alter table "topcon_sys"."con_prensa_operador" enable row level security;
create table if not exists "topcon_sys"."con_prensa_usina" (
  "prensa" bigint,
  "usina" bigint
);
create index if not exists "ix_con_prensa_usina" on "topcon_sys"."con_prensa_usina" ("prensa", "usina");
alter table "topcon_sys"."con_prensa_usina" enable row level security;
create table if not exists "topcon_sys"."con_prog_layout_bomb" (
  "nome_campo" text,
  "campo_prog" text,
  "ordem" bigint,
  "texto_format" text
);
create index if not exists "ix_con_prog_layout_bomb" on "topcon_sys"."con_prog_layout_bomb" ("nome_campo", "campo_prog");
alter table "topcon_sys"."con_prog_layout_bomb" enable row level security;
create table if not exists "topcon_sys"."con_prog_layout_conv" (
  "campo_prog" text,
  "ordem" bigint,
  "texto_format" text
);
create index if not exists "ix_con_prog_layout_conv" on "topcon_sys"."con_prog_layout_conv" ("campo_prog");
alter table "topcon_sys"."con_prog_layout_conv" enable row level security;
create table if not exists "topcon_sys"."con_programacao" (
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint,
  "id_dispatch" bigint,
  "fax" text,
  "usina_entrega" bigint,
  "solicitante" text,
  "obra_nome" text,
  "obra_cep" text,
  "obra_end" text,
  "obra_no" bigint,
  "obra_compl" text,
  "obra_bairro" text,
  "obra_mun" bigint,
  "pendencia" bigint,
  "libera_entrega" text,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "pedra" bigint,
  "slump" bigint,
  "uso" bigint,
  "seq_item_cont" bigint,
  "qtde_m3" numeric,
  "qtde_entregue" numeric,
  "qtde_bt" numeric,
  "slump_nf" text,
  "dt_concretagem" date,
  "horario" text,
  "intervalo" bigint,
  "dt_hr_confirmar" text,
  "peca_concretar" text,
  "andar" text,
  "tipo_bomba" bigint,
  "cp_prv_tipo" text,
  "cp_prv_qtde" bigint,
  "cp_prv_intvl_m3" bigint,
  "cp_moldador" bigint,
  "acres_feriado" text,
  "acres_he" text,
  "he_viagens" bigint,
  "m3_faltante" text,
  "obs" text,
  "cprova_acum_m3" numeric,
  "taxa_ja_impress" text,
  "id_nf" text,
  "id_cadast" text,
  "id_atual" text,
  "mot_bloq_progr" bigint,
  "dt_hr_solic" text,
  "pend_tp_aprov" text,
  "pend_id_aprov" text,
  "pend_sts_aprov" text,
  "numero_obra" bigint,
  "vlr_venda" numeric,
  "custo_material" numeric,
  "horario_bomba" text,
  "ptp_resist" bigint,
  "pfck" numeric,
  "pconsumo" bigint,
  "puso" bigint,
  "ppedra" bigint,
  "pslump" bigint,
  "at" bigint,
  "cancelada" text,
  "dt_hr_cancel" timestamp,
  "perdeu_p_terc" text,
  "cancelado_por" bigint,
  "motivo_cancel" text,
  "vistoria" text,
  "dt_vistoria" date,
  "cod_mt_canc_prg" bigint,
  "status" bigint,
  "finalizada" text,
  "cod_equip_bomba" text,
  "vibr_qtde" bigint,
  "vibr_vlr_unit" numeric,
  "vibr_vendedor" bigint,
  "vibr_aprovacao" text,
  "vibr_id_aprov" text,
  "dist_tub_bomba" bigint,
  "vlr_adic_tub" numeric,
  "qtde_liberada" numeric,
  "bomb_aplicacao" text,
  "fiscal" bigint,
  "cod_bombista" bigint,
  "cod_ajudante" bigint,
  "cod_ajudante2" bigint,
  "cod_ajudante3" bigint,
  "vlr_concreto" numeric,
  "vlr_bomba" numeric,
  "vlr_extras" numeric,
  "vlr_total_vib" numeric,
  "vlr_total_prog" numeric,
  "continua_seq" bigint,
  "vlr_demais_servicos" numeric,
  "perc_reaproveitamento" numeric,
  "obs_interna" text,
  "cp_moldagem_remota" text,
  "dt_inicio" timestamp,
  "dt_fim" timestamp,
  "obra_frente_sequencia" bigint,
  "external_id" text,
  "temp_ate_a_obra" bigint,
  "temp_bt_na_obra" bigint,
  "tempo_descarga" bigint
);
create index if not exists "ix_con_programacao" on "topcon_sys"."con_programacao" ("usina", "ano_contrato", "no_contrato", "seq_prog", "ano_chamada", "num_chamada", "no_obra", "id_dispatch");
alter table "topcon_sys"."con_programacao" enable row level security;
create table if not exists "topcon_sys"."con_programacao_dem_serv" (
  "usina" bigint,
  "obra" bigint,
  "seq_prog" bigint,
  "seq" bigint,
  "quantidade" numeric,
  "valor_total" numeric,
  "valor_cobrado" numeric
);
create index if not exists "ix_con_programacao_dem_serv" on "topcon_sys"."con_programacao_dem_serv" ("usina", "obra", "seq_prog", "seq");
alter table "topcon_sys"."con_programacao_dem_serv" enable row level security;
create table if not exists "topcon_sys"."con_programacao_dem_serv_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "obra" bigint,
  "seq_prog" bigint,
  "seq" bigint,
  "quantidade" numeric,
  "valor_total" numeric,
  "valor_cobrado" numeric
);
create index if not exists "ix_con_programacao_dem_serv_versao" on "topcon_sys"."con_programacao_dem_serv_versao" ("num_versao", "usina", "obra", "seq_prog", "seq");
alter table "topcon_sys"."con_programacao_dem_serv_versao" enable row level security;
create table if not exists "topcon_sys"."con_programacao_hora" (
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint,
  "horario" text,
  "volume_prog" numeric,
  "qtde_cp" bigint,
  "status" text,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "volume_entregue" numeric,
  "id_dispatch" text,
  "cod_betoneira" text
);
create index if not exists "ix_con_programacao_hora" on "topcon_sys"."con_programacao_hora" ("usina", "ano_contrato", "no_contrato", "seq_prog", "horario");
alter table "topcon_sys"."con_programacao_hora" enable row level security;
create table if not exists "topcon_sys"."con_programacao_obs" (
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint,
  "seq_msg" bigint,
  "dt_hr_msg" timestamp,
  "usuario" text,
  "mensagem" text
);
create index if not exists "ix_con_programacao_obs" on "topcon_sys"."con_programacao_obs" ("usina", "ano_contrato", "no_contrato", "seq_prog", "seq_msg");
alter table "topcon_sys"."con_programacao_obs" enable row level security;
create table if not exists "topcon_sys"."con_programacao_solicitacao" (
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint,
  "ano_chamada" bigint,
  "num_chamada" bigint,
  "no_obra" bigint,
  "external_id" text
);
create index if not exists "ix_con_programacao_solicitacao" on "topcon_sys"."con_programacao_solicitacao" ("usina", "ano_contrato", "no_contrato", "seq_prog", "ano_chamada", "num_chamada", "no_obra");
alter table "topcon_sys"."con_programacao_solicitacao" enable row level security;
create table if not exists "topcon_sys"."con_prop_bomba" (
  "usina" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "tipo_bomba" bigint,
  "m3_pr_tab" bigint,
  "taxa_minima_tab" numeric,
  "pr_m3_tab" numeric,
  "m3_pr_prop" bigint,
  "txa_min_pr_prop" numeric,
  "pr_m3_bomb_pr_p" numeric,
  "taxa_reajust_ant" numeric,
  "m3_pr_reajust_ant" bigint,
  "pr_m3_reajust_ant" numeric,
  "taxa_reajustada" numeric,
  "m3_pr_reajustada" bigint,
  "pr_m3_reajustada" numeric,
  "dt_ult_reajuste" date,
  "pct_descto" numeric,
  "aprovacao" text,
  "aprovado" text,
  "id_aprovacao" text,
  "aprov_verbal" text,
  "obs_aprov" text,
  "bomba_propria" text,
  "terceiro" bigint,
  "fat_direto" text,
  "pr_concorrente" numeric,
  "id_cadast" text,
  "id_atual" text,
  "status_aprov" text,
  "ciente_aprov" text,
  "alugadapcliente" text,
  "tipo_calc" bigint,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "dist_tub_bomba" bigint,
  "vlr_adic_tub" numeric,
  "complex_bomb" text,
  "just_aprov" text,
  "tipo_calc_hora" bigint,
  "tx_min_hora_tab" numeric,
  "tempo_min_h_tab" numeric,
  "vlr_hora_exc_tab" numeric,
  "tx_min_hora_prop" numeric,
  "tempo_min_h_prop" numeric,
  "vlr_hora_exc_prop" numeric,
  "pct_descto_hora" numeric,
  "imposto_aplicado_estadual" numeric,
  "imposto_aplicado_federal" numeric,
  "iss_aplicado" numeric,
  "ebitda" numeric,
  "ativo" text
);
create index if not exists "ix_con_prop_bomba" on "topcon_sys"."con_prop_bomba" ("usina", "no_obra", "seq", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_prop_bomba" enable row level security;
create table if not exists "topcon_sys"."con_prop_bomba_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "tipo_bomba" bigint,
  "m3_pr_tab" bigint,
  "taxa_minima_tab" numeric,
  "pr_m3_tab" numeric,
  "m3_pr_prop" bigint,
  "txa_min_pr_prop" numeric,
  "pr_m3_bomb_pr_p" numeric,
  "taxa_reajust_ant" numeric,
  "m3_pr_reajust_ant" bigint,
  "pr_m3_reajust_ant" numeric,
  "taxa_reajustada" numeric,
  "m3_pr_reajustada" bigint,
  "pr_m3_reajustada" numeric,
  "dt_ult_reajuste" date,
  "pct_descto" numeric,
  "aprovacao" text,
  "aprovado" text,
  "id_aprovacao" text,
  "aprov_verbal" text,
  "obs_aprov" text,
  "bomba_propria" text,
  "terceiro" bigint,
  "fat_direto" text,
  "pr_concorrente" numeric,
  "id_cadast" text,
  "id_atual" text,
  "status_aprov" text,
  "ciente_aprov" text,
  "alugadapcliente" text,
  "tipo_calc" bigint,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "dist_tub_bomba" bigint,
  "vlr_adic_tub" numeric,
  "complex_bomb" text,
  "just_aprov" text,
  "tipo_calc_hora" bigint,
  "tx_min_hora_tab" numeric,
  "tempo_min_h_tab" numeric,
  "vlr_hora_exc_tab" numeric,
  "tx_min_hora_prop" numeric,
  "tempo_min_h_prop" numeric,
  "vlr_hora_exc_prop" numeric,
  "pct_descto_hora" numeric,
  "imposto_aplicado_estadual" numeric,
  "imposto_aplicado_federal" numeric,
  "iss_aplicado" numeric,
  "ebitda" numeric,
  "ativo" text
);
create index if not exists "ix_con_prop_bomba_versao" on "topcon_sys"."con_prop_bomba_versao" ("num_versao", "usina", "no_obra", "seq", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_prop_bomba_versao" enable row level security;
create table if not exists "topcon_sys"."con_propaganda" (
  "id" text,
  "data" date,
  "data_hora" timestamp,
  "nome" text,
  "usuario" text,
  "ativa" bigint
);
create index if not exists "ix_con_propaganda" on "topcon_sys"."con_propaganda" ("id");
alter table "topcon_sys"."con_propaganda" enable row level security;
create table if not exists "topcon_sys"."con_proposta" (
  "usina" bigint,
  "ano_proposta" bigint,
  "num_proposta" bigint,
  "dt" date,
  "representante" bigint,
  "vendedor" bigint,
  "num_tab_preco" bigint,
  "cli_cod" bigint,
  "cli_razao" text,
  "cli_cep" text,
  "cli_end" text,
  "cli_num" bigint,
  "cli_compl" text,
  "cli_bairro" text,
  "cli_mun" bigint,
  "cli_contato" text,
  "cli_ddd" bigint,
  "cli_tel" bigint,
  "cli_ramal" bigint,
  "cli_celular" bigint,
  "cli_email" text,
  "cli_destinat" text,
  "cli_obs" text,
  "fator_inicio" bigint,
  "fator_contato" bigint,
  "fator_valores" bigint,
  "fator_pgto" bigint,
  "fator_local" bigint,
  "avaliacao" numeric,
  "dt_contrato" date,
  "resultado" bigint,
  "desist" bigint,
  "dt_desist" date,
  "id_cadast" text,
  "id_atual" text,
  "fis_jur" text,
  "ganhou" text
);
create index if not exists "ix_con_proposta" on "topcon_sys"."con_proposta" ("usina", "ano_proposta", "num_proposta");
alter table "topcon_sys"."con_proposta" enable row level security;
create table if not exists "topcon_sys"."con_proposta_clausu" (
  "clausula" text,
  "titulo" text,
  "conteudo" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_proposta_clausu" on "topcon_sys"."con_proposta_clausu" ("clausula");
alter table "topcon_sys"."con_proposta_clausu" enable row level security;
create table if not exists "topcon_sys"."con_proposta_item" (
  "usina" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "qtde_m3" numeric,
  "preco_unit_tab" numeric,
  "preco_unit_prop" numeric,
  "pct_descto" numeric,
  "descto_aprovado" text,
  "id_aprov_descto" text,
  "aprov_verbal" text,
  "obs_aprov" text,
  "preco_concorren" numeric,
  "peca_concretar" text,
  "id_cadast" text,
  "id_atual" text,
  "custo_servico" numeric,
  "status_aprov" text,
  "ciente_aprov" text,
  "tipo_aprov" text,
  "m3_entregue" numeric,
  "dt_ult_entrega" date,
  "num_ult_nf_ent" bigint,
  "pr_reajust_ant" numeric,
  "dt_ult_reajuste" date,
  "pr_reajustado_a" numeric,
  "slump_nominal" bigint,
  "custo_serv_ant" numeric,
  "custo_serv_a" numeric,
  "obs_traco" text,
  "ptp_resist" bigint,
  "pfck" numeric,
  "pconsumo" bigint,
  "puso" bigint,
  "ppedra" bigint,
  "pslump" bigint,
  "vl_ressarc" numeric,
  "id_aprov_ressarc" text,
  "vl_rel_agua_cim" numeric,
  "qtde_cim_p_m3" numeric,
  "temp_lanc" bigint,
  "obs_familiar" text,
  "cod_concorrente" bigint,
  "desvio_dias" bigint,
  "id_alt_traco_p" text,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "just_aprov" text,
  "pedido" text,
  "pedido_item" bigint,
  "preco_ajustado" numeric,
  "qtde_m3_bombeado" numeric,
  "margem_pos_transporte" numeric,
  "ebitda" numeric,
  "iss_aplicado" numeric,
  "imposto_aplicado_estadual" numeric,
  "imposto_aplicado_federal" numeric,
  "custo_bombagem" numeric,
  "imposto_aplicado_servico" numeric,
  "imposto_aplicado_faturamento" numeric,
  "custo_transporte" numeric,
  "ativo" text,
  "numeracao_familia" bigint,
  "numeracao_produto" bigint
);
create index if not exists "ix_con_proposta_item" on "topcon_sys"."con_proposta_item" ("usina", "no_obra", "seq", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_proposta_item" enable row level security;
create table if not exists "topcon_sys"."con_proposta_item_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "no_obra" bigint,
  "seq" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "qtde_m3" numeric,
  "preco_unit_tab" numeric,
  "preco_unit_prop" numeric,
  "pct_descto" numeric,
  "descto_aprovado" text,
  "id_aprov_descto" text,
  "aprov_verbal" text,
  "obs_aprov" text,
  "preco_concorren" numeric,
  "peca_concretar" text,
  "id_cadast" text,
  "id_atual" text,
  "custo_servico" numeric,
  "status_aprov" text,
  "ciente_aprov" text,
  "tipo_aprov" text,
  "m3_entregue" numeric,
  "dt_ult_entrega" date,
  "num_ult_nf_ent" bigint,
  "pr_reajust_ant" numeric,
  "dt_ult_reajuste" date,
  "pr_reajustado_a" numeric,
  "slump_nominal" bigint,
  "custo_serv_ant" numeric,
  "custo_serv_a" numeric,
  "obs_traco" text,
  "ptp_resist" bigint,
  "pfck" numeric,
  "pconsumo" bigint,
  "puso" bigint,
  "ppedra" bigint,
  "pslump" bigint,
  "vl_ressarc" numeric,
  "id_aprov_ressarc" text,
  "vl_rel_agua_cim" numeric,
  "qtde_cim_p_m3" numeric,
  "temp_lanc" bigint,
  "obs_familiar" text,
  "cod_concorrente" bigint,
  "desvio_dias" bigint,
  "id_alt_traco_p" text,
  "ano_chamada" bigint,
  "no_chamada" bigint,
  "just_aprov" text,
  "pedido" text,
  "pedido_item" bigint,
  "preco_ajustado" numeric,
  "qtde_m3_bombeado" numeric,
  "margem_pos_transporte" numeric,
  "ebitda" numeric,
  "iss_aplicado" numeric,
  "imposto_aplicado_estadual" numeric,
  "imposto_aplicado_federal" numeric,
  "custo_bombagem" numeric,
  "imposto_aplicado_servico" numeric,
  "imposto_aplicado_faturamento" numeric,
  "custo_transporte" numeric,
  "ativo" text,
  "numeracao_familia" bigint,
  "numeracao_produto" bigint
);
create index if not exists "ix_con_proposta_item_versao" on "topcon_sys"."con_proposta_item_versao" ("num_versao", "usina", "no_obra", "seq", "ano_chamada", "no_chamada");
alter table "topcon_sys"."con_proposta_item_versao" enable row level security;
create table if not exists "topcon_sys"."con_reaj_bomba" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "dt_vigencia" date,
  "seq" bigint,
  "tipo_bomba" bigint,
  "tx_min_atual" numeric,
  "vol_min" bigint,
  "vlr_m3_atual" numeric,
  "tx_min_recalc" numeric,
  "vol_min_recalc" bigint,
  "vlr_m3_recalc" numeric,
  "pct_reajuste" numeric,
  "emite_carta" text,
  "data_carta" date,
  "id_cadast" text,
  "id_atual" text,
  "dt_confirmacao" date,
  "dt_calculo" date,
  "id_aprov_versao" text,
  "id_reprovacao" text
);
create index if not exists "ix_con_reaj_bomba" on "topcon_sys"."con_reaj_bomba" ("usina", "ano_contrato", "num_contrato", "dt_vigencia", "seq");
alter table "topcon_sys"."con_reaj_bomba" enable row level security;
create table if not exists "topcon_sys"."con_reaj_bomba_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "dt_vigencia" date,
  "seq" bigint,
  "tipo_bomba" bigint,
  "tx_min_atual" numeric,
  "vol_min" bigint,
  "vlr_m3_atual" numeric,
  "tx_min_recalc" numeric,
  "vol_min_recalc" bigint,
  "vlr_m3_recalc" numeric,
  "pct_reajuste" numeric,
  "emite_carta" text,
  "data_carta" date,
  "id_cadast" text,
  "id_atual" text,
  "dt_confirmacao" date,
  "dt_calculo" date,
  "id_aprov_versao" text,
  "id_reprovacao" text
);
create index if not exists "ix_con_reaj_bomba_versao" on "topcon_sys"."con_reaj_bomba_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "dt_vigencia", "seq");
alter table "topcon_sys"."con_reaj_bomba_versao" enable row level security;
create table if not exists "topcon_sys"."con_reajuste_item" (
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "dt_vigencia" date,
  "item_contrato" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "preco_vigente" numeric,
  "custo_vigente" numeric,
  "servico_vigente" numeric,
  "preco_recalc" numeric,
  "custo_recalc" numeric,
  "servico_recalc" numeric,
  "pct_reajuste" numeric,
  "emite_carta" text,
  "usina_principal" bigint,
  "data_carta" date,
  "id_cadast" text,
  "id_atual" text,
  "dt_confirmacao" date,
  "dt_calculo" date,
  "tab_custo" bigint,
  "id_aprov_versao" text,
  "id_reprovacao" text
);
create index if not exists "ix_con_reajuste_item" on "topcon_sys"."con_reajuste_item" ("usina", "ano_contrato", "num_contrato", "dt_vigencia", "item_contrato");
alter table "topcon_sys"."con_reajuste_item" enable row level security;
create table if not exists "topcon_sys"."con_reajuste_item_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "dt_vigencia" date,
  "item_contrato" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "preco_vigente" numeric,
  "custo_vigente" numeric,
  "servico_vigente" numeric,
  "preco_recalc" numeric,
  "custo_recalc" numeric,
  "servico_recalc" numeric,
  "pct_reajuste" numeric,
  "emite_carta" text,
  "usina_principal" bigint,
  "data_carta" date,
  "id_cadast" text,
  "id_atual" text,
  "dt_confirmacao" date,
  "dt_calculo" date,
  "tab_custo" bigint,
  "id_aprov_versao" text,
  "id_reprovacao" text
);
create index if not exists "ix_con_reajuste_item_versao" on "topcon_sys"."con_reajuste_item_versao" ("num_versao", "usina", "ano_contrato", "num_contrato", "dt_vigencia", "item_contrato");
alter table "topcon_sys"."con_reajuste_item_versao" enable row level security;
create table if not exists "topcon_sys"."con_reaprov" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "bt_reaprov" text,
  "usina" bigint,
  "data_remessa" date,
  "sb_temperatura" numeric,
  "sb_vol_retorno" numeric,
  "sb_status" bigint,
  "sb_adic_adt_mot" numeric,
  "sb_adic_adt_usina" numeric,
  "sb_adic_agua_mot" bigint,
  "sb_adic_agua_usina" bigint,
  "sb_observacao" text,
  "ap_filial" bigint,
  "ap_interv" bigint,
  "ap_tp_doc" bigint,
  "ap_num_nf" bigint,
  "ap_serie" text,
  "ap_seq_nf" bigint,
  "ap_usina" bigint,
  "id_cadast" text,
  "id_atual" text,
  "sb_temperatura_amb" numeric
);
create index if not exists "ix_con_reaprov" on "topcon_sys"."con_reaprov" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "bt_reaprov");
alter table "topcon_sys"."con_reaprov" enable row level security;
create table if not exists "topcon_sys"."con_reaprov_itens" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "bt_reaprov" text,
  "num_seq_item_nf" bigint,
  "insumo" text,
  "qtde" numeric
);
create index if not exists "ix_con_reaprov_itens" on "topcon_sys"."con_reaprov_itens" ("filial", "interv", "tp_doc", "num_nf", "serie", "seq_nf", "bt_reaprov", "num_seq_item_nf");
alter table "topcon_sys"."con_reaprov_itens" enable row level security;
create table if not exists "topcon_sys"."con_reclamacao" (
  "id_atend" bigint,
  "empresa" bigint,
  "ano" bigint,
  "numero" bigint,
  "atendente" bigint,
  "status" bigint,
  "usina_contrato" bigint,
  "ano_contrato" bigint,
  "num_contrato" bigint,
  "reclamante" text,
  "cargo" bigint,
  "vol_reclamado" numeric,
  "fck_reclamado" numeric,
  "descr_reclam" text,
  "providencia" text,
  "conclusao" text,
  "dt_concretagem" date,
  "resp_obra" text,
  "ddd" bigint,
  "tel" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_fechamento" text,
  "dt_abertura" date,
  "responsavel" bigint,
  "ddd2" bigint,
  "tel2" bigint,
  "cpf_cnpj" text,
  "seq_prog" bigint
);
create index if not exists "ix_con_reclamacao" on "topcon_sys"."con_reclamacao" ("id_atend");
alter table "topcon_sys"."con_reclamacao" enable row level security;
create table if not exists "topcon_sys"."con_regiao_mercado" (
  "codigo" bigint,
  "nome" text,
  "ativo" text
);
create index if not exists "ix_con_regiao_mercado" on "topcon_sys"."con_regiao_mercado" ("codigo");
alter table "topcon_sys"."con_regiao_mercado" enable row level security;
create table if not exists "topcon_sys"."con_regiao_mercado_municipio" (
  "regiao_codigo" bigint,
  "municipio_codigo" bigint
);
create index if not exists "ix_con_regiao_mercado_municipio" on "topcon_sys"."con_regiao_mercado_municipio" ("regiao_codigo", "municipio_codigo");
alter table "topcon_sys"."con_regiao_mercado_municipio" enable row level security;
create table if not exists "topcon_sys"."con_regra_iss_munic" (
  "cod_mun_usina" bigint,
  "cod_mun_obra" bigint,
  "fisica" text,
  "juridica" text,
  "construtora" text,
  "org_publico" text,
  "id_cadast" text,
  "id_atual" text,
  "cod_mun_tomador" bigint,
  "nao_reter_iss" bigint,
  "isenta_nf_serv" text
);
create index if not exists "ix_con_regra_iss_munic" on "topcon_sys"."con_regra_iss_munic" ("cod_mun_usina", "cod_mun_obra", "cod_mun_tomador");
alter table "topcon_sys"."con_regra_iss_munic" enable row level security;
create table if not exists "topcon_sys"."con_repas_reajuste" (
  "dt_inicio_valid" date,
  "produto" bigint,
  "cimento" numeric,
  "pedra" numeric,
  "areia" numeric,
  "mao_obra" numeric,
  "diesel" numeric
);
create index if not exists "ix_con_repas_reajuste" on "topcon_sys"."con_repas_reajuste" ("dt_inicio_valid", "produto");
alter table "topcon_sys"."con_repas_reajuste" enable row level security;
create table if not exists "topcon_sys"."con_reserva_bomba" (
  "cod_bomba" text,
  "dt_hr_inclusao" timestamp,
  "data" date,
  "hora" text,
  "observacao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_reserva_bomba" on "topcon_sys"."con_reserva_bomba" ("cod_bomba", "dt_hr_inclusao");
alter table "topcon_sys"."con_reserva_bomba" enable row level security;
create table if not exists "topcon_sys"."con_resist_consumo" (
  "consumo" bigint,
  "fck" numeric,
  "tab_preco" text,
  "uso" bigint,
  "pedra1" bigint,
  "pedra2" bigint,
  "slump1" bigint,
  "slump2" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_resist_consumo" on "topcon_sys"."con_resist_consumo" ("consumo", "fck");
alter table "topcon_sys"."con_resist_consumo" enable row level security;
create table if not exists "topcon_sys"."con_rfid_importacao" (
  "id" bigint,
  "usina" bigint,
  "data" date,
  "hora" text,
  "equipamento" text,
  "motorista" bigint,
  "tipo_registro" bigint,
  "nf" bigint,
  "importado" bigint,
  "justificativa" text,
  "id_aprov_incons" text
);
create index if not exists "ix_con_rfid_importacao" on "topcon_sys"."con_rfid_importacao" ("id");
alter table "topcon_sys"."con_rfid_importacao" enable row level security;
create table if not exists "topcon_sys"."con_rota" (
  "id" text,
  "rota" bigint,
  "descricao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_rota" on "topcon_sys"."con_rota" ("id");
alter table "topcon_sys"."con_rota" enable row level security;
create table if not exists "topcon_sys"."con_rota_programacoes" (
  "id" text,
  "id_rota" text,
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint
);
create index if not exists "ix_con_rota_programacoes" on "topcon_sys"."con_rota_programacoes" ("id");
alter table "topcon_sys"."con_rota_programacoes" enable row level security;
create table if not exists "topcon_sys"."con_segmentacao" (
  "id" bigint,
  "nome" text,
  "nome_abreviado" text,
  "external_id" text
);
create index if not exists "ix_con_segmentacao" on "topcon_sys"."con_segmentacao" ("id");
alter table "topcon_sys"."con_segmentacao" enable row level security;
create table if not exists "topcon_sys"."con_slump" (
  "cod" bigint,
  "variavao" bigint,
  "amplitude_de" bigint,
  "amplitude_ate" bigint,
  "id_cadast" text,
  "id_atual" text,
  "external_id" text,
  "id_tech" text
);
create index if not exists "ix_con_slump" on "topcon_sys"."con_slump" ("cod");
alter table "topcon_sys"."con_slump" enable row level security;
create table if not exists "topcon_sys"."con_socios" (
  "interv" bigint,
  "cpf_cnpj" text,
  "nome" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_socios" on "topcon_sys"."con_socios" ("interv", "cpf_cnpj");
alter table "topcon_sys"."con_socios" enable row level security;
create table if not exists "topcon_sys"."con_status_email" (
  "endereco" text
);
create index if not exists "ix_con_status_email" on "topcon_sys"."con_status_email" ("endereco");
alter table "topcon_sys"."con_status_email" enable row level security;
create table if not exists "topcon_sys"."con_status_equipamentos" (
  "cod" bigint,
  "permite_alocacao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_status_equipamentos" on "topcon_sys"."con_status_equipamentos" ("cod");
alter table "topcon_sys"."con_status_equipamentos" enable row level security;
create table if not exists "topcon_sys"."con_status_usina" (
  "usina" bigint,
  "dt_ult_acesso" timestamp,
  "atualizacao_ok" bigint,
  "replicacao_ok" bigint,
  "vtopusina" text,
  "vtopcon" text,
  "vtopcompras" text,
  "vtopfinan" text,
  "vatservidor" text,
  "atualizando" bigint,
  "replicacao_2" bigint
);
create index if not exists "ix_con_status_usina" on "topcon_sys"."con_status_usina" ("usina");
alter table "topcon_sys"."con_status_usina" enable row level security;
create table if not exists "topcon_sys"."con_status_usina2" (
  "usina" bigint,
  "dt_ult_acesso" timestamp,
  "replicacao_ok" bigint,
  "atualizando" bigint,
  "replicacao_2" bigint
);
create index if not exists "ix_con_status_usina2" on "topcon_sys"."con_status_usina2" ("usina");
alter table "topcon_sys"."con_status_usina2" enable row level security;
create table if not exists "topcon_sys"."con_tab_preco" (
  "num_tab" bigint,
  "usina_base" bigint,
  "vend_repres" bigint,
  "uso" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "pedra" bigint,
  "slump" bigint,
  "preco_m3" numeric,
  "dt_inic_tab" date,
  "dt_fim_tab" date,
  "pr_m3_recal" numeric,
  "pct_variacao" numeric,
  "dt_recal" date,
  "custo_servico" numeric,
  "markup" numeric,
  "id_cadast" text,
  "id_atual" text,
  "espec_familia" text,
  "comis_pct_servico" numeric,
  "comis_pct_spreco" numeric,
  "comis_serv_spreco" text,
  "comis_smaior" text,
  "usina_ref" bigint,
  "external_id" text,
  "numeracao_produto" bigint
);
create index if not exists "ix_con_tab_preco" on "topcon_sys"."con_tab_preco" ("num_tab", "usina_base", "vend_repres", "uso", "tp_resist", "fck", "consumo", "pedra", "slump", "dt_inic_tab");
alter table "topcon_sys"."con_tab_preco" enable row level security;
create table if not exists "topcon_sys"."con_tab_preco_cep" (
  "usina_entrega" bigint,
  "cep_de" text,
  "cep_de_logr" text,
  "cep_de_bairro" text,
  "cep_de_munic" text,
  "cep_de_uf" text,
  "cep_ate" text,
  "cep_ate_logr" text,
  "cep_ate_bairro" text,
  "cep_ate_munic" text,
  "cep_ate_uf" text,
  "atende" text,
  "vlr_adic_m3" numeric,
  "pct_ajus_comis" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tab_preco_cep" on "topcon_sys"."con_tab_preco_cep" ("usina_entrega", "cep_de", "cep_ate");
alter table "topcon_sys"."con_tab_preco_cep" enable row level security;
create table if not exists "topcon_sys"."con_tab_preco_pre" (
  "id" text,
  "usina" bigint,
  "uso" bigint,
  "tp_resist" bigint,
  "fck" numeric,
  "consumo" bigint,
  "pedra" bigint,
  "slump" bigint,
  "custo_material" numeric,
  "valor_servico" numeric,
  "markup" numeric,
  "preco_m3" numeric,
  "id_ciencia" text,
  "data_ciencia" timestamp,
  "espec_familia" text,
  "external_id" text,
  "created_at" timestamp,
  "updated_at" timestamp,
  "numeracao_produto" bigint
);
create index if not exists "ix_con_tab_preco_pre" on "topcon_sys"."con_tab_preco_pre" ("id");
alter table "topcon_sys"."con_tab_preco_pre" enable row level security;
create table if not exists "topcon_sys"."con_tab_preco_repres" (
  "num_tabela" bigint,
  "usina_base" bigint,
  "repres" bigint,
  "inicio_tab" date,
  "custo_servico" numeric,
  "markup" numeric,
  "tab_custo" date,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tab_preco_repres" on "topcon_sys"."con_tab_preco_repres" ("repres", "inicio_tab", "usina_base", "num_tabela");
alter table "topcon_sys"."con_tab_preco_repres" enable row level security;
create table if not exists "topcon_sys"."con_tab_venda_km" (
  "usina_entrega" bigint,
  "dist_km_inicial" bigint,
  "dist_km_final" bigint,
  "atende" text,
  "valor" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tab_venda_km" on "topcon_sys"."con_tab_venda_km" ("usina_entrega", "dist_km_inicial", "dist_km_final");
alter table "topcon_sys"."con_tab_venda_km" enable row level security;
create table if not exists "topcon_sys"."con_tab_vlr_m3_adic" (
  "usina_entrega" bigint,
  "qt_m3_inicial" numeric,
  "qt_m3_final" numeric,
  "valor" numeric,
  "tipo" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tab_vlr_m3_adic" on "topcon_sys"."con_tab_vlr_m3_adic" ("usina_entrega", "qt_m3_inicial", "qt_m3_final");
alter table "topcon_sys"."con_tab_vlr_m3_adic" enable row level security;
create table if not exists "topcon_sys"."con_tarefa" (
  "codigo" bigint,
  "usuario" text,
  "descricao" text,
  "dia_inteiro" bigint,
  "data" date,
  "horario" text,
  "contato" text,
  "ddd" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text,
  "finalizado" bigint,
  "observacao" text,
  "providencia" text,
  "conclusao" text,
  "usina" bigint,
  "ano_visita" bigint,
  "numero_visita" bigint,
  "ano_lead" bigint,
  "numero_lead" bigint,
  "ano_oportunidade" bigint,
  "numero_oportunidade" bigint,
  "data_criacao" timestamp,
  "id_agrupamento" text
);
create index if not exists "ix_con_tarefa" on "topcon_sys"."con_tarefa" ("codigo");
alter table "topcon_sys"."con_tarefa" enable row level security;
create table if not exists "topcon_sys"."con_taxa_extra" (
  "usina" bigint,
  "seq" bigint,
  "dt_inicio_valid" date,
  "data_inicio" date,
  "data_fim" date,
  "cod_mun_obra" bigint,
  "obra" bigint,
  "taxa_adicional" text,
  "quando_de" text,
  "quando_oper" text,
  "quando_ate" text,
  "horario_antes" text,
  "horario" text,
  "cobrar_volume" text,
  "volume" text,
  "tipo_valor" text,
  "tipo_pessoa" text,
  "valor" numeric,
  "valor_por" text,
  "da_pedra" text,
  "para_pedra" text,
  "da_resistenc" text,
  "para_resistenc" text,
  "do_slump" bigint,
  "para_slump" bigint,
  "texto" text,
  "texto_mesclado" text,
  "id_cadast" text,
  "id_atual" text,
  "acima_de" bigint,
  "antecedencia" text,
  "quantidade" bigint,
  "external_id" text,
  "id_segmentacao" bigint,
  "prazo_tolerancia_de" bigint
);
create index if not exists "ix_con_taxa_extra" on "topcon_sys"."con_taxa_extra" ("usina", "seq", "obra");
alter table "topcon_sys"."con_taxa_extra" enable row level security;
create table if not exists "topcon_sys"."con_taxa_extra_versao" (
  "num_versao" bigint,
  "usina" bigint,
  "seq" bigint,
  "dt_inicio_valid" date,
  "data_inicio" date,
  "data_fim" date,
  "cod_mun_obra" bigint,
  "obra" bigint,
  "taxa_adicional" text,
  "quando_de" text,
  "quando_oper" text,
  "quando_ate" text,
  "horario_antes" text,
  "horario" text,
  "cobrar_volume" text,
  "volume" text,
  "tipo_valor" text,
  "tipo_pessoa" text,
  "valor" numeric,
  "valor_por" text,
  "da_pedra" text,
  "para_pedra" text,
  "da_resistenc" text,
  "para_resistenc" text,
  "do_slump" bigint,
  "para_slump" bigint,
  "texto" text,
  "texto_mesclado" text,
  "id_cadast" text,
  "id_atual" text,
  "acima_de" bigint,
  "antecedencia" text,
  "quantidade" bigint,
  "external_id" text,
  "id_segmentacao" bigint,
  "prazo_tolerancia_de" bigint
);
create index if not exists "ix_con_taxa_extra_versao" on "topcon_sys"."con_taxa_extra_versao" ("num_versao", "usina", "seq", "obra");
alter table "topcon_sys"."con_taxa_extra_versao" enable row level security;
create table if not exists "topcon_sys"."con_tipo_aprov" (
  "cod" bigint,
  "descr" text
);
create index if not exists "ix_con_tipo_aprov" on "topcon_sys"."con_tipo_aprov" ("cod");
alter table "topcon_sys"."con_tipo_aprov" enable row level security;
create table if not exists "topcon_sys"."con_tipo_bomba_pedra" (
  "tipo_bomba" bigint,
  "pedra" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tipo_bomba_pedra" on "topcon_sys"."con_tipo_bomba_pedra" ("tipo_bomba", "pedra");
alter table "topcon_sys"."con_tipo_bomba_pedra" enable row level security;
create table if not exists "topcon_sys"."con_tipo_cobranca" (
  "tipo_cobranca" bigint,
  "forma" text,
  "portador" bigint,
  "situacao" bigint,
  "obrigatorio" text,
  "aprovacao" text,
  "id_atual" text,
  "fixo" text,
  "util_cap" text
);
create index if not exists "ix_con_tipo_cobranca" on "topcon_sys"."con_tipo_cobranca" ("tipo_cobranca");
alter table "topcon_sys"."con_tipo_cobranca" enable row level security;
create table if not exists "topcon_sys"."con_tipo_oportunidade" (
  "codigo" bigint,
  "descricao" text,
  "ativo" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tipo_oportunidade" on "topcon_sys"."con_tipo_oportunidade" ("codigo");
alter table "topcon_sys"."con_tipo_oportunidade" enable row level security;
create table if not exists "topcon_sys"."con_tipo_resist_vinc" (
  "tp_resist" bigint,
  "consumo" bigint,
  "mpa" numeric
);
create index if not exists "ix_con_tipo_resist_vinc" on "topcon_sys"."con_tipo_resist_vinc" ("tp_resist", "consumo", "mpa");
alter table "topcon_sys"."con_tipo_resist_vinc" enable row level security;
create table if not exists "topcon_sys"."con_tipo_resistencia" (
  "cod" bigint,
  "descr" text,
  "abrev" text,
  "mpa_cons" bigint,
  "unidade" text,
  "id_cadast" text,
  "id_atual" text,
  "external_id" text,
  "id_tech" text
);
create index if not exists "ix_con_tipo_resistencia" on "topcon_sys"."con_tipo_resistencia" ("cod");
alter table "topcon_sys"."con_tipo_resistencia" enable row level security;
create table if not exists "topcon_sys"."con_tipo_visita" (
  "codigo" bigint,
  "descricao" text,
  "ativo" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_tipo_visita" on "topcon_sys"."con_tipo_visita" ("codigo");
alter table "topcon_sys"."con_tipo_visita" enable row level security;
create table if not exists "topcon_sys"."con_tp_reclamacao" (
  "id_atend" bigint,
  "tp_reclama" bigint
);
create index if not exists "ix_con_tp_reclamacao" on "topcon_sys"."con_tp_reclamacao" ("id_atend", "tp_reclama");
alter table "topcon_sys"."con_tp_reclamacao" enable row level security;
create table if not exists "topcon_sys"."con_track_compl" (
  "usina" bigint,
  "data_remessa" date,
  "placa" text,
  "id_viagem" bigint,
  "id_descarga" bigint,
  "url_viagem" text,
  "inconsistencias" text,
  "latitude" numeric,
  "longitude" numeric,
  "endereco" text,
  "numero" text,
  "bairro" text,
  "cidade" text,
  "estado" text,
  "cep" text,
  "pais" text
);
create index if not exists "ix_con_track_compl" on "topcon_sys"."con_track_compl" ("usina", "data_remessa", "placa", "id_viagem", "id_descarga");
alter table "topcon_sys"."con_track_compl" enable row level security;
create table if not exists "topcon_sys"."con_track_config" (
  "db" text,
  "userpass" text,
  "uadfilter" bigint,
  "adfilter" bigint
);
alter table "topcon_sys"."con_track_config" enable row level security;
create table if not exists "topcon_sys"."con_track_email" (
  "endereco" text
);
create index if not exists "ix_con_track_email" on "topcon_sys"."con_track_email" ("endereco");
alter table "topcon_sys"."con_track_email" enable row level security;
create table if not exists "topcon_sys"."con_track_imp" (
  "usina" bigint,
  "data_remessa" date,
  "placa" text,
  "id_viagem" bigint,
  "tp_registro" text,
  "valor" text,
  "importado" bigint
);
create index if not exists "ix_con_track_imp" on "topcon_sys"."con_track_imp" ("usina", "data_remessa", "placa", "id_viagem", "tp_registro");
alter table "topcon_sys"."con_track_imp" enable row level security;
create table if not exists "topcon_sys"."con_track_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "usina" bigint,
  "data_remessa" date,
  "placa" text,
  "id_viagem" bigint
);
create index if not exists "ix_con_track_nf" on "topcon_sys"."con_track_nf" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf", "usina", "data_remessa", "placa", "id_viagem");
alter table "topcon_sys"."con_track_nf" enable row level security;
create table if not exists "topcon_sys"."con_track_sem_nf" (
  "usina" bigint,
  "data_remessa" date,
  "placa" text,
  "id_viagem" bigint,
  "km_rodado" bigint,
  "hr_saida_usina" text,
  "hr_cheg_obra" text,
  "hr_desc_inic" text,
  "hr_desc_final" text,
  "hr_saida_obra" text,
  "hr_cheg_usina" text
);
create index if not exists "ix_con_track_sem_nf" on "topcon_sys"."con_track_sem_nf" ("usina", "data_remessa", "placa", "id_viagem");
alter table "topcon_sys"."con_track_sem_nf" enable row level security;
create table if not exists "topcon_sys"."con_track_sem_rast" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "serie" text,
  "seq_nf" bigint,
  "usina_aloc" bigint,
  "hr_solicitada" text,
  "hr_saida_usina" text,
  "hr_cheg_obra" text,
  "hr_desc_inic" text,
  "hr_desc_final" text,
  "hr_saida_obra" text,
  "hr_cheg_usina" text,
  "km_rodado" bigint
);
create index if not exists "ix_con_track_sem_rast" on "topcon_sys"."con_track_sem_rast" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."con_track_sem_rast" enable row level security;
create table if not exists "topcon_sys"."con_traco_nf" (
  "usina" bigint,
  "dt_inicio_valid" date,
  "uso" bigint,
  "uso_nf" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_traco_nf" on "topcon_sys"."con_traco_nf" ("usina", "dt_inicio_valid", "uso");
alter table "topcon_sys"."con_traco_nf" enable row level security;
create table if not exists "topcon_sys"."con_traco_repres" (
  "repres" bigint,
  "usina_base" bigint,
  "uso" bigint,
  "pedra" bigint,
  "fck_de" numeric,
  "fck_ate" numeric,
  "consumo_de" bigint,
  "consumo_ate" bigint,
  "slump_de" bigint,
  "slump_ate" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_traco_repres" on "topcon_sys"."con_traco_repres" ("repres", "usina_base", "uso", "pedra");
alter table "topcon_sys"."con_traco_repres" enable row level security;
create table if not exists "topcon_sys"."con_umidade_areia" (
  "usina" bigint,
  "dt" date,
  "hora" bigint,
  "umidade" numeric,
  "id_cadast" text,
  "id_atual" text,
  "insumo" text
);
create index if not exists "ix_con_umidade_areia" on "topcon_sys"."con_umidade_areia" ("usina", "dt", "hora", "insumo");
alter table "topcon_sys"."con_umidade_areia" enable row level security;
create table if not exists "topcon_sys"."con_usina" (
  "cod" bigint,
  "nome" text,
  "sigla" text,
  "emp_filial" bigint,
  "int_pos_vend_pj" bigint,
  "int_pos_vend_pf" bigint,
  "entrega_acum_pj" numeric,
  "entrega_acum_pf" numeric,
  "id_cadast" text,
  "id_atual" text,
  "ativo" text,
  "cod_c_custo" bigint,
  "cod_filial" bigint,
  "port_cobranca" bigint,
  "prox_boleto" bigint,
  "c_custo_bomba" bigint,
  "km_max_viagem" bigint,
  "km_min_viagem" bigint,
  "km_max_dia" bigint,
  "bloq_pesag_dias" bigint,
  "bloq_pesag_hora" text,
  "balanca_entrada" text,
  "hr_func_inicio" bigint,
  "hr_func_final" bigint,
  "qtd_dias_marmit" bigint,
  "bloq_func_hr_ex" text,
  "hr_saida_abaixo" bigint,
  "monitora" text,
  "hr_marmita" bigint,
  "hr_min_toleranc" bigint,
  "dig_cod_obra" text,
  "dias_bloq_req_p" bigint,
  "bloq_dias_pesagem" bigint,
  "min_pesagem" bigint,
  "min_guia_rem" bigint,
  "analise_almox" text,
  "intervalo_carga" bigint,
  "gera_cred_cli" text,
  "obriga_canc_obs" text,
  "bloq_pesag_nf" text,
  "bloq_pes_s_abast" text,
  "dias_blq_lanc_h" bigint,
  "temp_bt_na_obra" bigint,
  "pct_retorn_obra" numeric,
  "mov_est_sem_aut" text,
  "cfop_mov_est" bigint,
  "sq_cfop_mov_est" bigint,
  "dias_blq_pes_sv" bigint,
  "qt_dias_bloq_pes" bigint,
  "cons_peso_equip" text,
  "inf_peso_nfe" text,
  "bloq_fat_pesagem_pendente" text,
  "valida_m3_vinc_pesagem" text,
  "cod_empresa_cta" text,
  "temp_ate_a_obra" bigint,
  "obg_info_umidade_pesagem" text,
  "hr_obriga_ajuste_material" bigint,
  "dt_ultimo_acesso_ajuste_material" timestamp,
  "fuso_horario" text,
  "valida_remessa_sem_codigo_integracao" text,
  "definicao_silo_pesagem" bigint,
  "moldagem_remota" text,
  "external_id" text,
  "diametro_padrao_cp" numeric,
  "altura_padrao_cp" numeric,
  "id_tech" text,
  "id_batch" text,
  "jornada_segunda_sexta" text,
  "jornada_sabado" text,
  "gravidade" numeric,
  "medida_forca" bigint,
  "modelo_mapa_producao" text,
  "show_demais_cond_pagamento" text,
  "clicksign_config_id" bigint
);
create index if not exists "ix_con_usina" on "topcon_sys"."con_usina" ("cod");
alter table "topcon_sys"."con_usina" enable row level security;
create table if not exists "topcon_sys"."con_usina_ruptura_cp" (
  "cod" bigint,
  "id_segmentacao" bigint,
  "medida_forca" bigint,
  "gravidade" numeric,
  "diametro_padrao_cp" numeric,
  "altura_padrao_cp" numeric,
  "atualiza_idade_cp" bigint
);
create index if not exists "ix_con_usina_ruptura_cp" on "topcon_sys"."con_usina_ruptura_cp" ("cod", "id_segmentacao");
alter table "topcon_sys"."con_usina_ruptura_cp" enable row level security;
create table if not exists "topcon_sys"."con_uso" (
  "cod" bigint,
  "descr" text,
  "abrev" text,
  "id_cadast" text,
  "id_atual" text,
  "generico" text,
  "ac_ativo" bigint,
  "prio_cimento1" bigint,
  "prio_cimento2" bigint,
  "prio_cimento3" bigint,
  "ag_clcar_obr_m3" bigint,
  "min_recomend_ut" bigint,
  "neces_aprov_lab" text,
  "ativo" text,
  "external_id" text,
  "id_tech" text,
  "tipo_produto" text,
  "id_segmentacao" bigint
);
create index if not exists "ix_con_uso" on "topcon_sys"."con_uso" ("cod");
alter table "topcon_sys"."con_uso" enable row level security;
create table if not exists "topcon_sys"."con_uso_desc_person" (
  "uso" bigint,
  "descr" text
);
create index if not exists "ix_con_uso_desc_person" on "topcon_sys"."con_uso_desc_person" ("uso");
alter table "topcon_sys"."con_uso_desc_person" enable row level security;
create table if not exists "topcon_sys"."con_usr_usina" (
  "usuario" text,
  "usina" bigint
);
create index if not exists "ix_con_usr_usina" on "topcon_sys"."con_usr_usina" ("usuario", "usina");
alter table "topcon_sys"."con_usr_usina" enable row level security;
create table if not exists "topcon_sys"."con_veiculo_localizacao_fleet" (
  "cod" text,
  "usina" bigint,
  "localizacao" text
);
create index if not exists "ix_con_veiculo_localizacao_fleet" on "topcon_sys"."con_veiculo_localizacao_fleet" ("cod");
alter table "topcon_sys"."con_veiculo_localizacao_fleet" enable row level security;
create table if not exists "topcon_sys"."con_vend_regr_com" (
  "codigo" bigint,
  "descricao" text,
  "tx_extras_pct" numeric,
  "pct_com_meta" numeric,
  "pct_com_conc" numeric,
  "conc_vlr_m3" numeric,
  "conc_sobre_preco" text,
  "conc_spreco_ate_vlr" numeric,
  "conc_spreco_ate_pct" numeric,
  "conc_spreco_acima_pct" numeric,
  "pct_com_vend_padr" numeric,
  "abaixo_preco" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_vend_regr_com" on "topcon_sys"."con_vend_regr_com" ("codigo");
alter table "topcon_sys"."con_vend_regr_com" enable row level security;
create table if not exists "topcon_sys"."con_vendedor" (
  "cod" bigint,
  "nome" text,
  "razao_social" text,
  "funcao" text,
  "vend_padrinho" bigint,
  "tp_com_concreto" bigint,
  "pct_com_serv" numeric,
  "pct_sobre_proco" numeric,
  "tp_com_bomba" bigint,
  "pct_sobre_bombe" numeric,
  "vlr_fixo_bombe" numeric,
  "usina_folha" bigint,
  "re" bigint,
  "cep" text,
  "endereco" text,
  "num" bigint,
  "compl" text,
  "mun" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "interv" bigint,
  "usuario_sist" text,
  "ddd" bigint,
  "celular" bigint,
  "ativo" text,
  "pct_sobre_venda" numeric,
  "cond_pag" bigint,
  "email" text,
  "cod_comissao" bigint,
  "calc_com_tx_ext" text,
  "external_id" text
);
create index if not exists "ix_con_vendedor" on "topcon_sys"."con_vendedor" ("cod");
alter table "topcon_sys"."con_vendedor" enable row level security;
create table if not exists "topcon_sys"."con_versao_execs" (
  "aplicativo" text,
  "versao_atual" text
);
alter table "topcon_sys"."con_versao_execs" enable row level security;
create table if not exists "topcon_sys"."con_vibrador" (
  "usina" bigint,
  "dt_validade" date,
  "valor" numeric,
  "vibr_vlr_premio" numeric,
  "vibr_sobre_preco" text,
  "vibr_spreco_pct" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_con_vibrador" on "topcon_sys"."con_vibrador" ("usina", "dt_validade");
alter table "topcon_sys"."con_vibrador" enable row level security;
create table if not exists "topcon_sys"."con_visita" (
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "dt_visita" date,
  "vendedor" bigint,
  "tipo_visita" bigint,
  "cod_cliente" bigint,
  "cliente" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "contato" text,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "celular" bigint,
  "qte_obra" bigint,
  "obs" text,
  "resultado_cod" bigint,
  "dt_retorno" date,
  "desistencia" bigint,
  "dt_desistencia" date,
  "tem_obras" text,
  "qtde_obras" bigint,
  "propos_emitida" text,
  "fator_inicio" bigint,
  "fator_contato" bigint,
  "fator_valores" bigint,
  "fator_pgto" bigint,
  "fator_local" bigint,
  "avaliacao" numeric,
  "id_cadast" text,
  "id_atual" text,
  "fis_jur" text,
  "ganhou" text,
  "num_tab_preco" bigint
);
create index if not exists "ix_con_visita" on "topcon_sys"."con_visita" ("usina", "ano_visita", "num_visita");
alter table "topcon_sys"."con_visita" enable row level security;
create table if not exists "topcon_sys"."con_visita_anexo" (
  "id" text,
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "descricao" text,
  "nome" text,
  "usuario" text,
  "data" date,
  "data_hora" timestamp
);
create index if not exists "ix_con_visita_anexo" on "topcon_sys"."con_visita_anexo" ("id");
alter table "topcon_sys"."con_visita_anexo" enable row level security;
create table if not exists "topcon_sys"."con_visita_cliente" (
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "data_visita" date,
  "hora_visita" text,
  "cliente" text,
  "obra_nome" text,
  "ddd_telefone" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text,
  "vendedor" bigint,
  "tipo_visita" bigint,
  "cep" text,
  "endereco" text,
  "numero" bigint,
  "complemento" text,
  "bairro" text,
  "municipio" bigint,
  "obs_interna" text,
  "ano_lead" bigint,
  "num_lead" bigint,
  "status" bigint
);
create index if not exists "ix_con_visita_cliente" on "topcon_sys"."con_visita_cliente" ("usina", "ano_visita", "num_visita");
alter table "topcon_sys"."con_visita_cliente" enable row level security;
create table if not exists "topcon_sys"."con_visita_cliente_hist" (
  "id" text,
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "tipo" text,
  "descricao" text,
  "data" date,
  "hora" text,
  "data_retorno" date,
  "hora_retorno" text,
  "id_cadast" text
);
create index if not exists "ix_con_visita_cliente_hist" on "topcon_sys"."con_visita_cliente_hist" ("id");
alter table "topcon_sys"."con_visita_cliente_hist" enable row level security;
create table if not exists "topcon_sys"."con_visita_contato" (
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "seq" bigint,
  "funcao" bigint,
  "nome" text,
  "ddd_telefone" bigint,
  "telefone" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "email" text
);
create index if not exists "ix_con_visita_contato" on "topcon_sys"."con_visita_contato" ("usina", "ano_visita", "num_visita", "seq");
alter table "topcon_sys"."con_visita_contato" enable row level security;
create table if not exists "topcon_sys"."con_visita_hist" (
  "usina" bigint,
  "ano_visita" bigint,
  "num_visita" bigint,
  "seq" bigint,
  "dt_visita" date,
  "dt_retorno" date,
  "assunto" text,
  "historico1" text,
  "historico2" text,
  "historico3" text,
  "historico4" text
);
create index if not exists "ix_con_visita_hist" on "topcon_sys"."con_visita_hist" ("usina", "ano_visita", "num_visita", "seq");
alter table "topcon_sys"."con_visita_hist" enable row level security;
create table if not exists "topcon_sys"."con_viw_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" bigint,
  "num_nf" bigint,
  "seq_nf" bigint,
  "dt_nf" bigint,
  "dt_oper" bigint,
  "dt_emi_nf" bigint,
  "hr_emissao" bigint,
  "dt_lcto_cancela" bigint,
  "cancelada" bigint,
  "ind_oper" bigint,
  "ind_emitente" bigint,
  "trans" bigint,
  "mod_doc_fiscal" bigint,
  "sit_fiscal" bigint,
  "cfop" bigint,
  "seq_cfop" bigint,
  "nf_compl" bigint,
  "nf_entr" bigint,
  "num_ped" bigint,
  "faturamento_ac" bigint,
  "vend" bigint,
  "loc_fat" bigint,
  "loc_ent" bigint,
  "loc_cobr" bigint,
  "cond_pgto" bigint,
  "uf_orig_dest" bigint,
  "vl_merc" bigint,
  "vl_desc" bigint,
  "vl_frete" bigint,
  "vl_seg" bigint,
  "vl_o_desp" bigint,
  "vl_cont_nf" bigint,
  "vl_base_icms" bigint,
  "aliq_icms" bigint,
  "vl_icms" bigint,
  "vl_base_icms_su" bigint,
  "vl_icms_sub" bigint,
  "vl_ipi" bigint,
  "vl_fisc_1_icms" bigint,
  "vl_fisc_2_icms" bigint,
  "vl_fisc_3_icms" bigint,
  "vl_fisc_1_ipi" bigint,
  "vl_fisc_2_ipi" bigint,
  "vl_fisc_3_ipi" bigint,
  "vl_obs" bigint,
  "leg_fisc1" bigint,
  "leg_fisc2" bigint,
  "via_transp" bigint,
  "transp" bigint,
  "qt_vol" bigint,
  "esp_vol" bigint,
  "peso_bruto" bigint,
  "peso_liq" bigint,
  "ind_frete" bigint,
  "ident_veic" bigint,
  "in86" bigint,
  "fat_v_p" bigint,
  "obs_fisc_nf" bigint,
  "obs_lf" bigint,
  "id_cadast" bigint,
  "id_atual" bigint,
  "filial_destino" bigint,
  "mens_fiscais" bigint,
  "uf_veic" bigint,
  "embarque_local" bigint,
  "embarque_uf" bigint,
  "mens_fiscal_nfe" bigint,
  "forn_iss" bigint,
  "requis_interna" bigint,
  "dif_pedido_just" bigint,
  "dif_pedido_anls" bigint,
  "balanca" bigint,
  "vlr_pis" bigint,
  "vlr_cofins" bigint,
  "vl_desc_icms" bigint,
  "mot_nentrega" bigint,
  "num_fatura" bigint,
  "dt_fatura" bigint,
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "seq_prog" bigint,
  "traco_concreto" bigint,
  "cimento" bigint,
  "qtde_m3_bt" bigint,
  "motivo_cancel" bigint,
  "respon_cliente" bigint,
  "comis_motorista" bigint,
  "comis_bombista" bigint,
  "comis_aj_bomba" bigint,
  "comis_vendedor" bigint,
  "comis_represent" bigint,
  "represent" bigint,
  "bomba" bigint,
  "bombista" bigint,
  "aux_bombista" bigint,
  "motorista" bigint,
  "num_lacre" bigint,
  "m3_faltantes" bigint,
  "adic_he" bigint,
  "adic_feriado" bigint,
  "tp_cobranca" bigint,
  "dt_vcto_1_parc" bigint,
  "pos_venda" bigint
);
alter table "topcon_sys"."con_viw_nf" enable row level security;
create table if not exists "topcon_sys"."con_vlr_avulso" (
  "filial" bigint,
  "seq_vlr_avulso" bigint,
  "dt_oper" date,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "seq_prog" bigint,
  "interv" bigint,
  "cod_descr" text,
  "vlr" numeric,
  "num_fatura" bigint,
  "dt_fatura" date,
  "id_cadast" text,
  "id_atual" text,
  "usina_remessa" bigint,
  "no_faturamento" bigint,
  "usina_ctr" bigint,
  "obs" text,
  "taxa_cancelamento_prog" text,
  "id_dispatch" text,
  "versao_contrato" bigint
);
create index if not exists "ix_con_vlr_avulso" on "topcon_sys"."con_vlr_avulso" ("usina_remessa", "seq_vlr_avulso");
alter table "topcon_sys"."con_vlr_avulso" enable row level security;
create table if not exists "topcon_sys"."con_vlr_avulso_parcial" (
  "usina_remessa" bigint,
  "seq_vlr_avulso" bigint,
  "tp_fatura" text,
  "vlr" numeric,
  "num_fatura" bigint,
  "filial" bigint,
  "no_faturamento" bigint
);
create index if not exists "ix_con_vlr_avulso_parcial" on "topcon_sys"."con_vlr_avulso_parcial" ("usina_remessa", "seq_vlr_avulso", "tp_fatura");
alter table "topcon_sys"."con_vlr_avulso_parcial" enable row level security;
create table if not exists "topcon_sys"."con_webhook_events" (
  "evento" text,
  "url" text,
  "alertemails" text,
  "dtcriacao" timestamp,
  "dtatualizacao" timestamp
);
create index if not exists "ix_con_webhook_events" on "topcon_sys"."con_webhook_events" ("evento");
alter table "topcon_sys"."con_webhook_events" enable row level security;
create table if not exists "topcon_sys"."con_webhooks" (
  "evento" text,
  "url" text,
  "payload" text,
  "filepath" text,
  "alertemails" text,
  "dtsendafter" timestamp,
  "headers" text,
  "id" bigint,
  "localguid" text,
  "attempt" bigint,
  "dtlastattempt" timestamp,
  "status" text,
  "dtenvio" timestamp,
  "httpresult" bigint,
  "error" text,
  "webhookid" text,
  "dtcriacao" timestamp
);
create index if not exists "ix_con_webhooks" on "topcon_sys"."con_webhooks" ("id");
alter table "topcon_sys"."con_webhooks" enable row level security;
create table if not exists "topcon_sys"."fat_motivo_cancelamento" (
  "id" bigint,
  "filial" bigint,
  "faturamento" bigint,
  "fatura" bigint,
  "data_cancelamento" timestamp,
  "cod_cancelamento" bigint,
  "cod_interv" bigint,
  "usuario" text
);
create index if not exists "ix_fat_motivo_cancelamento" on "topcon_sys"."fat_motivo_cancelamento" ("id");
alter table "topcon_sys"."fat_motivo_cancelamento" enable row level security;
create table if not exists "topcon_sys"."fin_ajuste_fluxo" (
  "empresa" bigint,
  "data" date,
  "sub_sist" text,
  "seq" bigint,
  "descricao" text,
  "valor" numeric
);
create index if not exists "ix_fin_ajuste_fluxo" on "topcon_sys"."fin_ajuste_fluxo" ("empresa", "data", "sub_sist", "seq");
alter table "topcon_sys"."fin_ajuste_fluxo" enable row level security;
create table if not exists "topcon_sys"."fin_cad_ocorrencias" (
  "cod_ocorrencia" bigint,
  "sub_sistema" text,
  "desc_ocorrencia" text,
  "aprovacao" text,
  "campo_tab_relac" text,
  "campo_nome" text,
  "campo_tipo" text,
  "campo_tamanho" bigint,
  "campo_decimais" bigint,
  "campo_sinal" text,
  "campo_obrig" text
);
create index if not exists "ix_fin_cad_ocorrencias" on "topcon_sys"."fin_cad_ocorrencias" ("cod_ocorrencia");
alter table "topcon_sys"."fin_cad_ocorrencias" enable row level security;
create table if not exists "topcon_sys"."fin_cap" (
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "forn_retido" bigint,
  "id_inc" text,
  "dt_op" date,
  "dt_vcto" date,
  "dt_emi" date,
  "dt_vcto_orig" date,
  "vl" numeric,
  "soma_pgto" numeric,
  "sal" numeric,
  "op" bigint,
  "hist" bigint,
  "fluxo_finan" bigint,
  "port" bigint,
  "sit" bigint,
  "cc" bigint,
  "dt_rat" date,
  "num_ord_pagto" bigint,
  "obs" text,
  "id_alt" text,
  "liq_dt" date,
  "liq_op_bx" bigint,
  "liq_num_doc" bigint,
  "liq_juros" numeric,
  "liq_desco" numeric,
  "liq_desp" numeric,
  "liq_vl_pg" numeric,
  "liq_emp" bigint,
  "liq_bco" bigint,
  "pgto_comp" text,
  "fav" text,
  "num_cheq_pre" bigint,
  "dt_bom_p" date,
  "id_liq" text,
  "at_bco" bigint,
  "id_mov_bco" bigint,
  "emprd" bigint,
  "grp_movto" bigint,
  "liq_multa" numeric,
  "num_cheq_prop" bigint,
  "id_pagfor" bigint,
  "id_aprov_inc" text,
  "id_reprov_inc" text,
  "vl_multa" numeric,
  "vl_juros" numeric,
  "vl_desco" numeric,
  "alocado" text,
  "obs_reprov" text,
  "ciencia_reprov" text,
  "tp_corr_monet" bigint,
  "vl_original" numeric,
  "emp_contrato" bigint,
  "num_contrato" bigint,
  "vlr_juros_calc" numeric,
  "vlr_multa_calc" numeric,
  "id_aprov_pag" text,
  "dt_lancamento" date,
  "caminho_imagem" text,
  "natureza_finan" bigint,
  "dt_rec_boleto" date,
  "ret_irrf" numeric,
  "ret_pis" numeric,
  "ret_iss" numeric,
  "ret_cofins" numeric,
  "ret_csll" numeric,
  "ret_inss" numeric,
  "vlr_bruto" numeric,
  "id_aprov_liqped" text,
  "historico" text,
  "no_lancamento" bigint,
  "ret_irpj" numeric,
  "data_aprov_inc" date,
  "requisitante" bigint,
  "requis_interna" text,
  "id_aprov_compras" text,
  "id_aprov_contabil" text,
  "previsao_bomba" text,
  "no_ctr_fornec" text,
  "data_contrato" date,
  "observacao" text,
  "num_inscricao" text,
  "interessado" bigint,
  "id_tributos" bigint,
  "tp_aprov_inc" text,
  "veiculo_equip" text,
  "tp_cobranca" bigint,
  "tp_liq" text,
  "lote_baixa_car" bigint,
  "devolucao" text,
  "lote_bx_cred" bigint,
  "id_mov_bco_orig" bigint,
  "aprovnaoliq_usr" text,
  "aprovnaoliq_dt" date,
  "guid_vinc_compe" text,
  "num_solic_pgto" bigint,
  "vl_cbs" numeric,
  "vl_ibs" numeric,
  "vl_is" numeric,
  "totaliza_fin_reform_trib" text
);
create index if not exists "ix_fin_cap" on "topcon_sys"."fin_cap" ("emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "desdo", "forn_retido");
alter table "topcon_sys"."fin_cap" enable row level security;
create table if not exists "topcon_sys"."fin_cap_aut_inc" (
  "id" bigint
);
create index if not exists "ix_fin_cap_aut_inc" on "topcon_sys"."fin_cap_aut_inc" ("id");
alter table "topcon_sys"."fin_cap_aut_inc" enable row level security;
create table if not exists "topcon_sys"."fin_cap_cc" (
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "forn_retido" bigint,
  "cc" bigint,
  "valor" numeric,
  "percentual" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_cap_cc" on "topcon_sys"."fin_cap_cc" ("emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "forn_retido", "cc");
alter table "topcon_sys"."fin_cap_cc" enable row level security;
create table if not exists "topcon_sys"."fin_cap_juncao" (
  "empf" bigint,
  "fornf" bigint,
  "tp_docf" bigint,
  "ser_docf" text,
  "num_docf" bigint,
  "seqf" text,
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "forn_retido" bigint,
  "id_inc" text,
  "valor" numeric
);
create index if not exists "ix_fin_cap_juncao" on "topcon_sys"."fin_cap_juncao" ("empf", "fornf", "tp_docf", "ser_docf", "num_docf", "seqf", "emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "forn_retido");
alter table "topcon_sys"."fin_cap_juncao" enable row level security;
create table if not exists "topcon_sys"."fin_cap_juncao_pagfor" (
  "id" text,
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "forn_retido" bigint,
  "id_pagfor" bigint
);
create index if not exists "ix_fin_cap_juncao_pagfor" on "topcon_sys"."fin_cap_juncao_pagfor" ("id");
alter table "topcon_sys"."fin_cap_juncao_pagfor" enable row level security;
create table if not exists "topcon_sys"."fin_cap_ocorrencias" (
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "forn_retido" bigint,
  "seq_ocorrencia" bigint,
  "cod_ocorrencia" bigint,
  "data_ocorrencia" date,
  "vlr_anterior" text,
  "vlr_novo" text,
  "vlr_novo_descr" text,
  "obs" text,
  "aprovacao" text,
  "atualizado" text,
  "id_solicitacao" text,
  "id_aprovacao" text,
  "vlr_ant_descr" text,
  "id_reprovacao" text
);
create index if not exists "ix_fin_cap_ocorrencias" on "topcon_sys"."fin_cap_ocorrencias" ("emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "forn_retido", "seq_ocorrencia");
alter table "topcon_sys"."fin_cap_ocorrencias" enable row level security;
create table if not exists "topcon_sys"."fin_cap_pagfor" (
  "id_pagfor_agrupamento" bigint,
  "id_pagfor" bigint,
  "tributo" text
);
create index if not exists "ix_fin_cap_pagfor" on "topcon_sys"."fin_cap_pagfor" ("id_pagfor_agrupamento", "id_pagfor", "tributo");
alter table "topcon_sys"."fin_cap_pagfor" enable row level security;
create table if not exists "topcon_sys"."fin_cap_vinc_filial" (
  "filial" bigint,
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "forn_retido" bigint
);
create index if not exists "ix_fin_cap_vinc_filial" on "topcon_sys"."fin_cap_vinc_filial" ("filial", "emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "desdo", "forn_retido");
alter table "topcon_sys"."fin_cap_vinc_filial" enable row level security;
create table if not exists "topcon_sys"."fin_car" (
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "desdo" bigint,
  "cli" bigint,
  "dt_emi" date,
  "dt_oper" date,
  "dt_vcto" date,
  "dt_vencto_orig" date,
  "vl" numeric,
  "soma_recbtos" numeric,
  "sal" numeric,
  "oper" bigint,
  "cc" bigint,
  "fluxo_finan" bigint,
  "sit" bigint,
  "dt_sit" date,
  "bco_port" bigint,
  "bco_port_orig" bigint,
  "nosso_num" text,
  "noss_num_interm" text,
  "dt_rem_cobr_bco" date,
  "lote_rem" bigint,
  "vend" bigint,
  "vl_comis_vend" numeric,
  "local_cobr" bigint,
  "obs" text,
  "liq_dt" date,
  "liq_oper" bigint,
  "liq_doc" bigint,
  "liq_juros" numeric,
  "liq_desc" numeric,
  "liq_desp" numeric,
  "liq_vl_rec" numeric,
  "liq_bco" bigint,
  "liq_cheque" text,
  "id_liq" text,
  "liq_lot_bx" bigint,
  "barra" text,
  "dt_entrega" date,
  "linha_dig" text,
  "no_faturamento" bigint,
  "qtde" numeric,
  "vl_bruto" numeric,
  "vl_retencoes" numeric,
  "vlr_pis_ret" numeric,
  "vlr_cofins_ret" numeric,
  "vl_abatimento" numeric,
  "multa_mora_calc" numeric,
  "juros_mora_calc" numeric,
  "vlr_receber" numeric,
  "pct_multa" numeric,
  "pct_juros_dia" numeric,
  "vlr_mora_n_liq" numeric,
  "dt_base_mora" date,
  "vl_des_acr_efet" numeric,
  "mora_des_acr_ef" numeric,
  "at_bco" bigint,
  "id_mov_bco" bigint,
  "id_cadast" text,
  "id_atual" text,
  "dt_util_vencto" date,
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "id_aprovacao" text,
  "liq_dt_cli" date,
  "dt_solicit_cart" date,
  "dt_adia_cart" date,
  "just_bloq_cart" text,
  "dt_aprov_cart" date,
  "id_solicitacao" text,
  "id_aprov_cart" text,
  "dt_envio" date,
  "liq_dt_comi" date,
  "emprd" bigint,
  "grp_movto" bigint,
  "dt_solic_cobr" date,
  "id_solic_cobr" text,
  "dt_aprov_cobr" date,
  "id_aprov_cobr" text,
  "dt_envio_cobr" date,
  "natureza_finan" bigint,
  "cobrador" bigint,
  "num_autorizacao" text,
  "conc_cartao" text,
  "lote_conc" bigint,
  "nsu_oper_cartao" text,
  "lote_origem" bigint,
  "devolucao" text,
  "id_reprov_cred" text,
  "obs_reprov" text,
  "vcto_bol_atual" date,
  "aprovnaoliq_usr" text,
  "aprovnaoliq_dt" date,
  "meio_pagamento" bigint,
  "alocado" bigint,
  "vl_cbs" numeric,
  "vl_ibs" numeric,
  "vl_is" numeric,
  "totaliza_fin_reform_trib" text,
  "atualizado_em" timestamp,
  "versao_contrato" bigint
);
create index if not exists "ix_fin_car" on "topcon_sys"."fin_car" ("emp", "tp_doc", "ser_doc", "num_doc", "seq", "cod_banco_band", "num_agencia", "num_conta", "dv_conta", "desdo");
alter table "topcon_sys"."fin_car" enable row level security;
create table if not exists "topcon_sys"."fin_car_juncao" (
  "id" text,
  "empj" bigint,
  "tp_docj" bigint,
  "ser_docj" text,
  "num_docj" bigint,
  "seqj" text,
  "cod_banco_bandj" bigint,
  "num_agenciaj" bigint,
  "num_contaj" bigint,
  "dv_contaj" bigint,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "valor" numeric
);
create index if not exists "ix_fin_car_juncao" on "topcon_sys"."fin_car_juncao" ("id");
alter table "topcon_sys"."fin_car_juncao" enable row level security;
create table if not exists "topcon_sys"."fin_car_mov_cc" (
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "desdo" bigint,
  "cc" bigint,
  "pct_rat_ven" numeric,
  "pct_rat_manut" numeric,
  "vlr" numeric
);
create index if not exists "ix_fin_car_mov_cc" on "topcon_sys"."fin_car_mov_cc" ("emp", "tp_doc", "ser_doc", "num_doc", "seq", "cod_banco_band", "num_agencia", "num_conta", "dv_conta", "desdo", "cc");
alter table "topcon_sys"."fin_car_mov_cc" enable row level security;
create table if not exists "topcon_sys"."fin_car_ocorrencias" (
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "seq_ocorrencia" bigint,
  "cod_ocorrencia" bigint,
  "data_ocorrencia" date,
  "vlr_anterior" text,
  "vlr_novo" text,
  "vlr_novo_descr" text,
  "obs" text,
  "aprovacao" text,
  "atualizado" text,
  "id_solicitacao" text,
  "id_aprovacao" text,
  "vlr_ant_descr" text,
  "usr_data_hora" text,
  "id_reprovacao" text,
  "dt_rem_cobr_bco" date,
  "nosso_num_ocor" text,
  "motivo_ocor" bigint
);
create index if not exists "ix_fin_car_ocorrencias" on "topcon_sys"."fin_car_ocorrencias" ("emp", "tp_doc", "ser_doc", "num_doc", "seq", "cod_banco_band", "num_agencia", "num_conta", "dv_conta", "seq_ocorrencia");
alter table "topcon_sys"."fin_car_ocorrencias" enable row level security;
create table if not exists "topcon_sys"."fin_car_titulo_concreserv" (
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "desdo" bigint,
  "codigo_central" text,
  "numero_documento" text,
  "tipo" text,
  "parcela" bigint
);
create index if not exists "ix_fin_car_titulo_concreserv" on "topcon_sys"."fin_car_titulo_concreserv" ("emp", "tp_doc", "ser_doc", "num_doc", "seq", "cod_banco_band", "num_agencia", "num_conta", "dv_conta", "desdo", "codigo_central", "numero_documento", "tipo", "parcela");
alter table "topcon_sys"."fin_car_titulo_concreserv" enable row level security;
create table if not exists "topcon_sys"."fin_ccusto" (
  "cod" bigint,
  "descr" text,
  "unid_negocio" bigint,
  "id_cadast" text,
  "id_atual" text,
  "reg_fixo" text,
  "ativo" text,
  "external_id" text
);
create index if not exists "ix_fin_ccusto" on "topcon_sys"."fin_ccusto" ("cod");
alter table "topcon_sys"."fin_ccusto" enable row level security;
create table if not exists "topcon_sys"."fin_cheque" (
  "emp" bigint,
  "bco" bigint,
  "num_cheq" bigint,
  "dt_cad" date,
  "dt_emi" date,
  "dt_canc" date,
  "vl" numeric,
  "benef" text,
  "dt_deb" date,
  "obs" text,
  "dt_bom_p" date,
  "forn" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_doc" bigint,
  "seq" text,
  "id_cad" text,
  "id_emi" text,
  "id_alt" text
);
create index if not exists "ix_fin_cheque" on "topcon_sys"."fin_cheque" ("emp", "bco", "num_cheq");
alter table "topcon_sys"."fin_cheque" enable row level security;
create table if not exists "topcon_sys"."fin_cheque3" (
  "emp" bigint,
  "bco_of" bigint,
  "num_ag" bigint,
  "num_cta" bigint,
  "cta_dv" text,
  "num_cheq" bigint,
  "ser_cheq" text,
  "seq" bigint,
  "orig" bigint,
  "fluxo_finan" bigint,
  "cli_resp" bigint,
  "tp_doc_venda" bigint,
  "num_doc_venda" bigint,
  "ser_doc_venda" text,
  "seq_doc_venda" bigint,
  "vl_cheq" numeric,
  "dt_ent_cheq" date,
  "sit" bigint,
  "dt_sit" date,
  "dt_dep_orig" date,
  "dt_dep_repro" date,
  "port" bigint,
  "dt_1_dep" date,
  "emp_dep" bigint,
  "bco_dep" bigint,
  "dt_dev_1_dep" date,
  "dt_2_dep" date,
  "dt_dev_2_dep" date,
  "dt_bx" date,
  "op_bx" bigint,
  "dt_tr_cheq" date,
  "vl_cheq_tr" numeric,
  "vl_juros" numeric,
  "vl_desc" numeric,
  "obs" text,
  "lote_baixa" bigint,
  "id_cadast" text,
  "id_atual" text,
  "fornecedor" bigint
);
create index if not exists "ix_fin_cheque3" on "topcon_sys"."fin_cheque3" ("emp", "bco_of", "num_ag", "num_cta", "cta_dv", "num_cheq", "ser_cheq", "seq");
alter table "topcon_sys"."fin_cheque3" enable row level security;
create table if not exists "topcon_sys"."fin_cobrador" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_cobrador" on "topcon_sys"."fin_cobrador" ("cod");
alter table "topcon_sys"."fin_cobrador" enable row level security;
create table if not exists "topcon_sys"."fin_conc_bco_lanc" (
  "emp" bigint,
  "bco" bigint,
  "dt_lanc" date,
  "cat_lancamento" bigint,
  "cod_lancamento" text,
  "num_doc" text,
  "valor" numeric,
  "ident_dc" text,
  "hist_complem" text,
  "tp_lancamento" bigint,
  "conc" text,
  "dt_conc" date,
  "id_conc" text,
  "controle" bigint,
  "lote_conc" bigint,
  "cod_of_bco" text,
  "controle_conc" bigint,
  "dt_arquivo" date
);
create index if not exists "ix_fin_conc_bco_lanc" on "topcon_sys"."fin_conc_bco_lanc" ("controle");
alter table "topcon_sys"."fin_conc_bco_lanc" enable row level security;
create table if not exists "topcon_sys"."fin_conc_bco_sal" (
  "emp" bigint,
  "bco" bigint,
  "dt_saldo" date,
  "saldo" numeric,
  "ident_dc" text,
  "tp_saldo" text,
  "conc" text,
  "dt_conc" date,
  "id_conc" text,
  "status_saldo" text,
  "sal_simulado" numeric,
  "lote_conc" bigint,
  "cod_of_bco" text,
  "dt_arquivo" date,
  "id_import" text
);
create index if not exists "ix_fin_conc_bco_sal" on "topcon_sys"."fin_conc_bco_sal" ("emp", "bco", "dt_saldo", "tp_saldo", "dt_arquivo");
alter table "topcon_sys"."fin_conc_bco_sal" enable row level security;
create table if not exists "topcon_sys"."fin_conc_categoria" (
  "cod_bco" text,
  "cod" bigint,
  "cnab" bigint,
  "descr" text,
  "tipo_dc" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_conc_categoria" on "topcon_sys"."fin_conc_categoria" ("cod_bco", "cod", "cnab");
alter table "topcon_sys"."fin_conc_categoria" enable row level security;
create table if not exists "topcon_sys"."fin_conc_manual" (
  "lote_conc" bigint,
  "data_conc" date,
  "controle" bigint,
  "tp_controle" text,
  "sub_lote" bigint,
  "emp" bigint,
  "bco" bigint
);
create index if not exists "ix_fin_conc_manual" on "topcon_sys"."fin_conc_manual" ("lote_conc", "controle", "tp_controle", "sub_lote");
alter table "topcon_sys"."fin_conc_manual" enable row level security;
create table if not exists "topcon_sys"."fin_conta_trans" (
  "cta_contabil" text,
  "descr" text,
  "fechamento" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_conta_trans" on "topcon_sys"."fin_conta_trans" ("cta_contabil");
alter table "topcon_sys"."fin_conta_trans" enable row level security;
create table if not exists "topcon_sys"."fin_contr_cobr" (
  "num_contrato" bigint,
  "dt_ult_ger" date,
  "lote_ger" bigint,
  "id_geracao" text,
  "emp" bigint
);
create index if not exists "ix_fin_contr_cobr" on "topcon_sys"."fin_contr_cobr" ("emp", "num_contrato", "dt_ult_ger");
alter table "topcon_sys"."fin_contr_cobr" enable row level security;
create table if not exists "topcon_sys"."fin_contrato" (
  "emp" bigint,
  "num_contrato" bigint,
  "no_ctr_fornec" text,
  "data_contrato" date,
  "fornecedor" bigint,
  "operacao" bigint,
  "centro_custo" bigint,
  "portador" bigint,
  "periodic_pagto" bigint,
  "tipo_reajuste" bigint,
  "cond_pag" bigint,
  "data_inicial" date,
  "data_final" date,
  "tipo_corr_monet" bigint,
  "period_reaj" bigint,
  "mes_ano_base" date,
  "pct_multa" numeric,
  "pct_juros" numeric,
  "ult_cobr_gerada" date,
  "valor_parcela" numeric,
  "vlr_ult_cobr" numeric,
  "observacao" text,
  "id_aprov" text,
  "id_cadast" text,
  "id_atual" text,
  "status_ctr" text,
  "dt_encer_susp" date,
  "id_reprov" text,
  "id_cienc_reprov" text,
  "obs_reprov" text,
  "tp_contrato" bigint,
  "equipamento" text,
  "inscricao" text,
  "proprietario" bigint,
  "incricao" text,
  "end_imovel" text,
  "mun_imovel" bigint,
  "tp_pag" bigint,
  "mes_ano_base_orig" date,
  "cod_servico" text,
  "nec_aprov_ret" text,
  "conta_contabil" text,
  "tp_cobranca" bigint,
  "port" bigint,
  "vl_ult_par_reaj" numeric
);
create index if not exists "ix_fin_contrato" on "topcon_sys"."fin_contrato" ("emp", "num_contrato");
alter table "topcon_sys"."fin_contrato" enable row level security;
create table if not exists "topcon_sys"."fin_contrato_obs" (
  "emp" bigint,
  "num_contrato" bigint,
  "seq" bigint,
  "dt" date,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_contrato_obs" on "topcon_sys"."fin_contrato_obs" ("emp", "num_contrato", "seq");
alter table "topcon_sys"."fin_contrato_obs" enable row level security;
create table if not exists "topcon_sys"."fin_contrato_parcela" (
  "emp" bigint,
  "num_contrato" bigint,
  "seq_parcela" bigint,
  "qtd_parcelas" bigint,
  "valor_parc" numeric,
  "data_1a_parcela" date,
  "periodicidade" bigint,
  "qtd_parc_gerada" bigint,
  "tp_cobranca" bigint,
  "port" bigint
);
create index if not exists "ix_fin_contrato_parcela" on "topcon_sys"."fin_contrato_parcela" ("emp", "num_contrato", "seq_parcela");
alter table "topcon_sys"."fin_contrato_parcela" enable row level security;
create table if not exists "topcon_sys"."fin_controle" (
  "prox_lote_baixa" bigint
);
alter table "topcon_sys"."fin_controle" enable row level security;
create table if not exists "topcon_sys"."fin_ctr_hist_reajust" (
  "emp" bigint,
  "num_contrato" bigint,
  "mes_base" date,
  "periodicidade" bigint,
  "vlr_anterior" numeric,
  "vlr_sugerido" numeric,
  "vlr_novo" numeric,
  "tp_reajuste" bigint,
  "id_geracao" text,
  "id_aprovacao" text,
  "id_reprovacao" text,
  "seq_parc_especi" bigint
);
create index if not exists "ix_fin_ctr_hist_reajust" on "topcon_sys"."fin_ctr_hist_reajust" ("emp", "num_contrato", "mes_base", "seq_parc_especi");
alter table "topcon_sys"."fin_ctr_hist_reajust" enable row level security;
create table if not exists "topcon_sys"."fin_ctr_ocorrencias" (
  "emp" bigint,
  "num_contrato" bigint,
  "seq_ocorrencia" bigint,
  "cod_ocorrencia" bigint,
  "data_ocorrencia" date,
  "vlr_anterior" text,
  "vlr_novo" text,
  "vlr_novo_descr" text,
  "obs" text,
  "aprovacao" text,
  "atualizado" text,
  "id_solicitacao" text,
  "id_aprovacao" text,
  "vlr_ant_descr" text,
  "id_reprovacao" text
);
create index if not exists "ix_fin_ctr_ocorrencias" on "topcon_sys"."fin_ctr_ocorrencias" ("emp", "num_contrato", "seq_ocorrencia");
alter table "topcon_sys"."fin_ctr_ocorrencias" enable row level security;
create table if not exists "topcon_sys"."fin_diverso" (
  "cod" bigint,
  "descr" text
);
alter table "topcon_sys"."fin_diverso" enable row level security;
create table if not exists "topcon_sys"."fin_dre_totalizador" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text,
  "formula" text
);
create index if not exists "ix_fin_dre_totalizador" on "topcon_sys"."fin_dre_totalizador" ("cod");
alter table "topcon_sys"."fin_dre_totalizador" enable row level security;
create table if not exists "topcon_sys"."fin_fluxo_financeiro" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_fluxo_financeiro" on "topcon_sys"."fin_fluxo_financeiro" ("cod");
alter table "topcon_sys"."fin_fluxo_financeiro" enable row level security;
create table if not exists "topcon_sys"."fin_hist_bco" (
  "cod_banco" text,
  "cod_lancamento" text,
  "hist_lancamento" text,
  "oper" bigint,
  "obs" text,
  "informa_cc" bigint,
  "ccusto" bigint,
  "p_cria_mov_bco" text,
  "id_cadast" text,
  "id_atual" text,
  "hist_n_cons" bigint
);
create index if not exists "ix_fin_hist_bco" on "topcon_sys"."fin_hist_bco" ("cod_banco", "cod_lancamento");
alter table "topcon_sys"."fin_hist_bco" enable row level security;
create table if not exists "topcon_sys"."fin_historico" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_historico" on "topcon_sys"."fin_historico" ("cod");
alter table "topcon_sys"."fin_historico" enable row level security;
create table if not exists "topcon_sys"."fin_imp_cartao" (
  "num_arquivo" text,
  "seq_reg_arquivo" bigint,
  "cod_estab" text,
  "dt_venda" date,
  "vlr_bruto" numeric,
  "vlr_liquido" numeric,
  "dt_credito" date,
  "num_parcela" bigint,
  "tp_produto" text,
  "cod_rede" bigint,
  "cod_banco" text,
  "cod_agencia" text,
  "num_cc" text,
  "vlr_taxa" numeric,
  "perc_taxa" numeric,
  "cod_autorizacao" text,
  "cod_bandeira" bigint,
  "dt_conciliacao" date,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "id_imp" bigint,
  "lote_conc" bigint,
  "nsu" text,
  "cod_autor_orig" text,
  "num_rv" text
);
create index if not exists "ix_fin_imp_cartao" on "topcon_sys"."fin_imp_cartao" ("id_imp", "num_arquivo", "seq_reg_arquivo");
alter table "topcon_sys"."fin_imp_cartao" enable row level security;
create table if not exists "topcon_sys"."fin_indice" (
  "cod_indice" bigint,
  "mes_ano" date,
  "indice_mes_pct" numeric,
  "indice_acumul" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_indice" on "topcon_sys"."fin_indice" ("cod_indice", "mes_ano");
alter table "topcon_sys"."fin_indice" enable row level security;
create table if not exists "topcon_sys"."fin_lay_bco" (
  "cod_oficial" text,
  "cnab" bigint,
  "descr" text,
  "dt_vigencia" date,
  "cod_reg_header" bigint,
  "pos_cod_bco" bigint,
  "tam_cod_bco" bigint,
  "id_cadast" text,
  "id_atual" text,
  "identificador" bigint
);
create index if not exists "ix_fin_lay_bco" on "topcon_sys"."fin_lay_bco" ("identificador");
alter table "topcon_sys"."fin_lay_bco" enable row level security;
create table if not exists "topcon_sys"."fin_lay_bco_det" (
  "id_layout" bigint,
  "tp_registro" bigint,
  "seq" bigint,
  "pos_inicial" bigint,
  "tamanho" bigint,
  "qt_decimal" bigint
);
create index if not exists "ix_fin_lay_bco_det" on "topcon_sys"."fin_lay_bco_det" ("id_layout", "tp_registro", "seq");
alter table "topcon_sys"."fin_lay_bco_det" enable row level security;
create table if not exists "topcon_sys"."fin_lay_bco_fixo" (
  "tp_registro" bigint,
  "seq" bigint,
  "campo" text,
  "conteudo" text
);
create index if not exists "ix_fin_lay_bco_fixo" on "topcon_sys"."fin_lay_bco_fixo" ("tp_registro", "seq");
alter table "topcon_sys"."fin_lay_bco_fixo" enable row level security;
create table if not exists "topcon_sys"."fin_mot_des_acr" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_mot_des_acr" on "topcon_sys"."fin_mot_des_acr" ("cod");
alter table "topcon_sys"."fin_mot_des_acr" enable row level security;
create table if not exists "topcon_sys"."fin_motivo_cobra" (
  "banco" bigint,
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_motivo_cobra" on "topcon_sys"."fin_motivo_cobra" ("banco", "cod");
alter table "topcon_sys"."fin_motivo_cobra" enable row level security;
create table if not exists "topcon_sys"."fin_mov_alocacao" (
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "valor" numeric,
  "data_aloc" date,
  "operacao" bigint,
  "num_aloca" bigint,
  "aloc_comp" text,
  "emp_aloc" bigint,
  "forn_aloc" bigint,
  "tp_doc_aloc" bigint,
  "ser_doc_aloc" text,
  "num_doc_aloc" bigint,
  "seq_aloc" text,
  "guid_vinc_compe" text
);
create index if not exists "ix_fin_mov_alocacao" on "topcon_sys"."fin_mov_alocacao" ("emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "desdo", "guid_vinc_compe");
alter table "topcon_sys"."fin_mov_alocacao" enable row level security;
create table if not exists "topcon_sys"."fin_mov_banco" (
  "controle" bigint,
  "emp" bigint,
  "bco" bigint,
  "dt_op" date,
  "tp_doc" bigint,
  "num_doc" text,
  "es" text,
  "op" bigint,
  "vl" numeric,
  "cc" bigint,
  "fluxo_finan" bigint,
  "hist" bigint,
  "bco_dest" bigint,
  "emp_dest" bigint,
  "bco_orig" bigint,
  "emp_orig" bigint,
  "fav" text,
  "obs" text,
  "id_at" text,
  "lote_baixa" bigint,
  "id_cadast" text,
  "dt_debito" date,
  "emprd" bigint,
  "grp_movto" bigint,
  "orig" text,
  "conc" text,
  "dt_conc" date,
  "natureza_finan" bigint,
  "lote_conc" bigint
);
create index if not exists "ix_fin_mov_banco" on "topcon_sys"."fin_mov_banco" ("controle");
alter table "topcon_sys"."fin_mov_banco" enable row level security;
create table if not exists "topcon_sys"."fin_mov_banco_aut_inc" (
  "id" bigint
);
create index if not exists "ix_fin_mov_banco_aut_inc" on "topcon_sys"."fin_mov_banco_aut_inc" ("id");
alter table "topcon_sys"."fin_mov_banco_aut_inc" enable row level security;
create table if not exists "topcon_sys"."fin_mov_banco_guid" (
  "guid" text,
  "emp" bigint,
  "bco" bigint,
  "saldo" numeric,
  "dt_geracao" timestamp
);
create index if not exists "ix_fin_mov_banco_guid" on "topcon_sys"."fin_mov_banco_guid" ("emp", "bco", "guid");
alter table "topcon_sys"."fin_mov_banco_guid" enable row level security;
create table if not exists "topcon_sys"."fin_mud_plano_cartao" (
  "num_rv" text,
  "cod_autorizacao" text,
  "total_parcelas" bigint,
  "dt_ajuste" date
);
alter table "topcon_sys"."fin_mud_plano_cartao" enable row level security;
create table if not exists "topcon_sys"."fin_nat_finan" (
  "cod" bigint,
  "cod_format" text,
  "descr" text,
  "nivel" bigint,
  "tipo" text,
  "idcadast" text,
  "idatual" text
);
create index if not exists "ix_fin_nat_finan" on "topcon_sys"."fin_nat_finan" ("cod");
alter table "topcon_sys"."fin_nat_finan" enable row level security;
create table if not exists "topcon_sys"."fin_ocorr_cobra" (
  "banco" bigint,
  "cod" bigint,
  "descr" text,
  "situacao_car" bigint,
  "liquid_car" text,
  "oper_baixa" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_ocorr_cobra" on "topcon_sys"."fin_ocorr_cobra" ("banco", "cod");
alter table "topcon_sys"."fin_ocorr_cobra" enable row level security;
create table if not exists "topcon_sys"."fin_op_liquidacao" (
  "emp" bigint,
  "forma_pgto" bigint,
  "op" bigint,
  "id_cadast" text
);
create index if not exists "ix_fin_op_liquidacao" on "topcon_sys"."fin_op_liquidacao" ("emp", "forma_pgto", "op");
alter table "topcon_sys"."fin_op_liquidacao" enable row level security;
create table if not exists "topcon_sys"."fin_oper_cta_contab" (
  "cod" bigint,
  "emp" bigint,
  "cta_deb" text,
  "cta_cred" text,
  "cta_cred_bomba" text,
  "cta_juro" text,
  "cta_desc" text,
  "cta_desp" text,
  "cta_cred_icms" text,
  "cta_deb_icms" text,
  "hist_contabil" text
);
create index if not exists "ix_fin_oper_cta_contab" on "topcon_sys"."fin_oper_cta_contab" ("cod", "emp");
alter table "topcon_sys"."fin_oper_cta_contab" enable row level security;
create table if not exists "topcon_sys"."fin_operacao" (
  "cod" bigint,
  "descr" text,
  "sub_sist" text,
  "ib" text,
  "s_mov_fin" text,
  "fluxo_finan" bigint,
  "op_bx" bigint,
  "at_bco" bigint,
  "op_bco" bigint,
  "rec_desp" bigint,
  "cta_deb" text,
  "cta_cred" text,
  "cta_juro" text,
  "cta_desc" text,
  "cta_desp" text,
  "hist_contabil" text,
  "fixo" text,
  "id_cadast" text,
  "id_atual" text,
  "cta_cred_bomba" text,
  "bco_padrao" bigint,
  "inativa" text,
  "prod_serv" text,
  "ccustos" text,
  "pct_pis" numeric,
  "pct_cofins" numeric,
  "pct_iss" numeric,
  "pct_irrf" numeric,
  "pct_inss" numeric,
  "pct_irpj" numeric,
  "pct_csll" numeric,
  "fixa_mensal" text,
  "nat_finan" bigint,
  "p_cria_mov_bco" text,
  "vinc_lancamento" text,
  "op_est_pag_elet" bigint,
  "gera_contab" text,
  "gera_fluxo_finan" text,
  "external_id" text
);
create index if not exists "ix_fin_operacao" on "topcon_sys"."fin_operacao" ("cod");
alter table "topcon_sys"."fin_operacao" enable row level security;
create table if not exists "topcon_sys"."fin_pag_for" (
  "id_pgto" bigint,
  "status" text,
  "num_lista_deb" bigint,
  "modalidade" bigint,
  "dt_efetivacao" date,
  "tipo_movimento" bigint,
  "cod_movimento" bigint,
  "dt_h_cons_saldo" timestamp,
  "cod_lancamento" bigint,
  "num_cta_cli" bigint,
  "cod_barra" text,
  "sit_agendamento" bigint,
  "tipo_conta" text,
  "bco" bigint,
  "oper_liq" bigint,
  "finalidade" bigint,
  "num_rem_cap" bigint,
  "dt_hora_remessa" timestamp,
  "qr_code" text,
  "tx_id" text
);
create index if not exists "ix_fin_pag_for" on "topcon_sys"."fin_pag_for" ("id_pgto");
alter table "topcon_sys"."fin_pag_for" enable row level security;
create table if not exists "topcon_sys"."fin_pagfor_inf_ret" (
  "banco_oficial" bigint,
  "cnab" bigint,
  "codigo" text,
  "mensagem" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_pagfor_inf_ret" on "topcon_sys"."fin_pagfor_inf_ret" ("banco_oficial", "cnab", "codigo");
alter table "topcon_sys"."fin_pagfor_inf_ret" enable row level security;
create table if not exists "topcon_sys"."fin_parametro" (
  "emp" bigint,
  "inicio_validade" date,
  "pct_multa" numeric,
  "pct_multa_efet" numeric,
  "pct_juros_dia" numeric,
  "pct_juros_efet" numeric,
  "vlr_min_mora" numeric,
  "mes_ano_compet" date,
  "id_fech_mes" text,
  "id_cadast" text,
  "id_atual" text,
  "oper_mora_n_liq" bigint,
  "dias_atraso" bigint,
  "oper_cred_cli" bigint,
  "desc_max" numeric,
  "dt_fech_comi" date,
  "pct_multa_cap" numeric,
  "pct_juros_cap" numeric,
  "tp_corr_monet" bigint,
  "marg_alt_valor" numeric,
  "marg_alt_data" bigint,
  "media_prev1" bigint,
  "media_prev2" bigint,
  "media_prev3" bigint,
  "local_ger_pagfo" text,
  "mes_gerado_reaj" date,
  "oper_cap_cred" bigint,
  "cap_jun_op_liq" bigint,
  "cap_jun_op_inc" bigint,
  "pct_limite_dif" numeric,
  "dif_dias_nf" bigint,
  "ret_irrf" text,
  "ret_pis" text,
  "ret_cofins" text,
  "ret_csll" text,
  "dias_bloq_1302" bigint,
  "dias_prorrog_nf" bigint,
  "oper_bx_desc" bigint,
  "oper_cartao" bigint,
  "port_complement" bigint,
  "oper_mov_bco_ad" bigint,
  "oper_liq_cartao" bigint,
  "bloq_fec_filial" text,
  "op_taxa_adm_cc" bigint,
  "op_tarifa_cc" bigint,
  "op_cancelado_cc" bigint,
  "op_desag_cc" bigint,
  "op_aluguel_cc" bigint,
  "op_ajust_deb_cc" bigint,
  "op_ajust_cre_cc" bigint,
  "bloq_sol_pagto" bigint,
  "dias_lib_cred" bigint,
  "oper_pad_incl_chq" bigint,
  "port_padrao_chq" bigint,
  "sit_padrao_chq" bigint,
  "obrig_inf_emit_chq" text,
  "tp_doc_mov_bco" bigint,
  "oper_pad_chq_dev" bigint,
  "op_liq_car_ccap" bigint,
  "tip_dif_sol_pag" text,
  "aprov_cap_cred" text,
  "op_cred_cli_vmo" bigint,
  "op_liq_vinc_mov" bigint,
  "obg_tp_cob_port" text,
  "aprov_cap_imp" text,
  "cons_val_liq" text,
  "op_liq_cred_des" bigint,
  "obr_comp_cap_ad" text,
  "tp_doc_adiant" bigint,
  "op_pad_cap_ad" bigint,
  "op_pad_cap_deb" bigint,
  "car_liq_dt_inf" text,
  "op_deb_desp_dev" bigint,
  "op_pad_cap_dev" bigint,
  "op_bx_deb_adia" bigint,
  "op_bx_cred_adia" bigint,
  "per_mov_bco_man" text,
  "op_bx_deb_comp" bigint,
  "op_bx_cred_comp" bigint,
  "cta_cheque" text,
  "impress_cheq" bigint,
  "nat_fin_jur_rec" bigint,
  "nat_fin_dsc_con" bigint,
  "nat_fin_jur_pag" bigint,
  "nat_fin_dsc_obt" bigint,
  "nat_fin_iss_ret" bigint,
  "perm_alt_dt_venc_cap" text,
  "ger_cp_sp_aprov" text,
  "blq_fch_car_vcd" text,
  "blq_fch_cap_vcd" text,
  "cta_cap_ret_pis" text,
  "cta_cap_ret_cof" text,
  "cta_cap_ret_csl" text,
  "cta_cap_ret_irf" text,
  "cta_cap_ret_iss" text,
  "cta_cap_ret_inss" text,
  "dias_minimos_vencimento" bigint,
  "valida_dias_minimos_vencimento" text,
  "agrup_car_liq_oper" text,
  "gera_fluxo_tit_orig_juncao" text,
  "car_jun_op_inc" bigint,
  "car_jun_op_liq" bigint,
  "car_fat_op_liq" bigint
);
create index if not exists "ix_fin_parametro" on "topcon_sys"."fin_parametro" ("emp");
alter table "topcon_sys"."fin_parametro" enable row level security;
create table if not exists "topcon_sys"."fin_portador" (
  "cod" bigint,
  "descr" text,
  "emite_cob" text,
  "num_ced" text,
  "esp_doc" text,
  "1o_inst" bigint,
  "2o_inst" bigint,
  "num_dias_prot" bigint,
  "prox_rem_cobr" text,
  "cnab_cobranca" bigint,
  "prox_nosso_num" bigint,
  "sit" bigint,
  "emp" bigint,
  "bco" bigint,
  "dias_cobr" bigint,
  "taxa_cobranca" numeric,
  "oper_taxa_cobr" bigint,
  "num_cont" text,
  "id_cadast" text,
  "id_atual" text,
  "cart" bigint,
  "cobrador" bigint,
  "fixo" text,
  "sigla_cart" text,
  "cod_bco_enc_cob" bigint,
  "agen_enc_cob" bigint,
  "env_ocor_rem_cb" text,
  "esp_doc_rem" text,
  "prazo_baixa_dev" bigint,
  "num_var_cart" bigint,
  "cons_par_cad_bc" bigint,
  "operacao" bigint,
  "tipo_cobranca" text,
  "variacao_cart" bigint,
  "env_cob_email_ant" text,
  "sigla" text,
  "env_cob_email" text,
  "beneficiario_cob" bigint,
  "prox_nosso_num_cor" bigint,
  "num_ced_cor" text,
  "desc_comp_imp_fatura" text,
  "local_pagamento" text,
  "instrucao1" text,
  "instrucao2" text,
  "instrucao3" text,
  "instrucao4" text,
  "instrucao5" text,
  "utiliza_ws" text,
  "utiliza_trans_aut" text,
  "especie_doc_tecnospeed" text,
  "prox_nosso_num_final" bigint,
  "prox_nosso_num_cor_final" bigint,
  "num_dias_negativ" bigint
);
create index if not exists "ix_fin_portador" on "topcon_sys"."fin_portador" ("cod");
alter table "topcon_sys"."fin_portador" enable row level security;
create table if not exists "topcon_sys"."fin_ret_cartao" (
  "num_arquivo" text,
  "seq_reg_arquivo" bigint,
  "cod_estab" text,
  "dt_venda" date,
  "vlr_bruto" numeric,
  "vlr_tx_adm" numeric,
  "vlr_tx_antec" numeric,
  "num_antec" bigint,
  "vlr_liquido" numeric,
  "dt_credito" date,
  "num_parcela" bigint,
  "cod_autorizacao" text,
  "ret_status" bigint,
  "tp_produto" text,
  "operadora" text,
  "cod_banco" text,
  "cod_agencia" text,
  "num_cc" text,
  "num_lote" bigint,
  "tipo_reg" bigint,
  "dt_liquidacao" date,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "id_imp" bigint,
  "lote_bx" bigint,
  "nsu" text,
  "cod_autor_orig" text,
  "aceleracao" text,
  "antecipacao" text
);
create index if not exists "ix_fin_ret_cartao" on "topcon_sys"."fin_ret_cartao" ("id_imp", "num_arquivo", "seq_reg_arquivo");
alter table "topcon_sys"."fin_ret_cartao" enable row level security;
create table if not exists "topcon_sys"."fin_saldo_database" (
  "emp" bigint,
  "bco" bigint,
  "data_base" date,
  "saldo" numeric
);
create index if not exists "ix_fin_saldo_database" on "topcon_sys"."fin_saldo_database" ("emp", "bco", "data_base");
alter table "topcon_sys"."fin_saldo_database" enable row level security;
create table if not exists "topcon_sys"."fin_situacao" (
  "cod" bigint,
  "descr" text,
  "oper_baixa" bigint,
  "fixo" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_situacao" on "topcon_sys"."fin_situacao" ("cod");
alter table "topcon_sys"."fin_situacao" enable row level security;
create table if not exists "topcon_sys"."fin_solic_pgto" (
  "emp" bigint,
  "ano" bigint,
  "num_solic" bigint,
  "forn" bigint,
  "cod_cta_cli" bigint,
  "nun_cta" bigint,
  "dg_cta" text,
  "num_ag" bigint,
  "dg_ag" text,
  "cnpj_cpf" text,
  "nome" text,
  "cod_of_bco" bigint,
  "dt_operacao" date,
  "operacao" bigint,
  "cc" bigint,
  "valor" numeric,
  "dt_vcto" date,
  "num_tit_gerado" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "id_aprov" text,
  "id_reprov" text,
  "id_ciencia_repr" text,
  "obs_reprovacao" text,
  "requisitante" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "interessado" bigint,
  "id_aprov_contab" text,
  "id_contas_pagar" text,
  "analis_contab" text,
  "num_doc" bigint,
  "tp_conta" text,
  "tp_cobranca" bigint,
  "port" bigint,
  "id_tributos" bigint
);
create index if not exists "ix_fin_solic_pgto" on "topcon_sys"."fin_solic_pgto" ("emp", "ano", "num_solic");
alter table "topcon_sys"."fin_solic_pgto" enable row level security;
create table if not exists "topcon_sys"."fin_solic_pgto_item" (
  "emp" bigint,
  "ano" bigint,
  "num_solic" bigint,
  "seq" bigint,
  "cod_prod" text,
  "vl" numeric,
  "cod_equip" text,
  "cod_oper" bigint,
  "analis_contab" text,
  "id_aprov_contab" text,
  "grupo" bigint,
  "subgrupo" bigint,
  "item" bigint,
  "subitem" bigint
);
create index if not exists "ix_fin_solic_pgto_item" on "topcon_sys"."fin_solic_pgto_item" ("emp", "ano", "num_solic", "seq");
alter table "topcon_sys"."fin_solic_pgto_item" enable row level security;
create table if not exists "topcon_sys"."fin_tp_indice" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fin_tp_indice" on "topcon_sys"."fin_tp_indice" ("cod");
alter table "topcon_sys"."fin_tp_indice" enable row level security;
create table if not exists "topcon_sys"."fin_tributos" (
  "id_tributos" bigint,
  "tipo_tributo" text,
  "dt_efetivacao" date,
  "codigo_receita" bigint,
  "grupo_receita" text,
  "periodo_apura" date,
  "percentual" numeric,
  "referencia" text,
  "vl_receita_brut" numeric,
  "mes_ano" date,
  "ins_est_cod_mun" text,
  "ins_div_at_etiq" text,
  "aiim_di" text,
  "cnae" text,
  "placa" text,
  "vl_inss" numeric,
  "vl_outras_entid" numeric,
  "tipo_identifica" text,
  "id_gps" text,
  "codigo_barra" text,
  "id_fgts" text,
  "num_inscricao" text,
  "vl_atuali_monet" numeric,
  "bco" bigint,
  "oper_liq" bigint,
  "status" text,
  "id_atual" text,
  "lacre_conect" bigint,
  "dig_lacre" bigint,
  "num_rem_cap" bigint
);
create index if not exists "ix_fin_tributos" on "topcon_sys"."fin_tributos" ("id_tributos");
alter table "topcon_sys"."fin_tributos" enable row level security;
create table if not exists "topcon_sys"."fin_vinc_cap_adiant" (
  "emp_cap" bigint,
  "forn_cap" bigint,
  "tp_doc_cap" bigint,
  "ser_doc_cap" text,
  "num_doc_cap" bigint,
  "seq_cap" text,
  "emp_adiant" bigint,
  "forn_adiant" bigint,
  "tp_doc_adiant" bigint,
  "ser_doc_adiant" text,
  "num_doc_adiant" bigint,
  "seq_adiant" text,
  "valor" numeric
);
create index if not exists "ix_fin_vinc_cap_adiant" on "topcon_sys"."fin_vinc_cap_adiant" ("emp_cap", "forn_cap", "tp_doc_cap", "ser_doc_cap", "num_doc_cap", "seq_cap", "emp_adiant", "forn_adiant", "tp_doc_adiant", "ser_doc_adiant", "num_doc_adiant", "seq_adiant");
alter table "topcon_sys"."fin_vinc_cap_adiant" enable row level security;
create table if not exists "topcon_sys"."fin_vinc_cap_mov_bco" (
  "id_mov_bco" bigint,
  "emp" bigint,
  "forn" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "desdo" bigint,
  "forn_retido" bigint,
  "valor" numeric
);
create index if not exists "ix_fin_vinc_cap_mov_bco" on "topcon_sys"."fin_vinc_cap_mov_bco" ("id_mov_bco", "emp", "forn", "tp_doc", "ser_doc", "num_doc", "seq", "desdo", "forn_retido");
alter table "topcon_sys"."fin_vinc_cap_mov_bco" enable row level security;
create table if not exists "topcon_sys"."fin_vinc_car_mov_bco" (
  "id_mov_bco" bigint,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "desdo" bigint,
  "valor" numeric
);
create index if not exists "ix_fin_vinc_car_mov_bco" on "topcon_sys"."fin_vinc_car_mov_bco" ("id_mov_bco", "emp", "tp_doc", "ser_doc", "num_doc", "seq", "cod_banco_band", "num_agencia", "num_conta", "dv_conta", "desdo");
alter table "topcon_sys"."fin_vinc_car_mov_bco" enable row level security;
create table if not exists "topcon_sys"."fin_vinc_cob_port_cc" (
  "cobrador" bigint,
  "portador" bigint,
  "cc" bigint
);
create index if not exists "ix_fin_vinc_cob_port_cc" on "topcon_sys"."fin_vinc_cob_port_cc" ("cobrador", "portador", "cc");
alter table "topcon_sys"."fin_vinc_cob_port_cc" enable row level security;
create table if not exists "topcon_sys"."fis_ajusteapur" (
  "ger_empresa_cod" bigint,
  "fis_ajusteapur_data" date,
  "fix_ajbenefinc_cod" text,
  "fis_ajusteapur_uf" text,
  "fis_ajusteapur_valor" numeric,
  "fis_ajusteapur_idcadast" text,
  "fis_ajusteapur_idatual" text,
  "fis_ajusteapur_compl" text
);
create index if not exists "ix_fis_ajusteapur" on "topcon_sys"."fis_ajusteapur" ("ger_empresa_cod", "fis_ajusteapur_data", "fix_ajbenefinc_cod");
alter table "topcon_sys"."fis_ajusteapur" enable row level security;
create table if not exists "topcon_sys"."fis_ajusteapurinf" (
  "ger_empresa_cod" bigint,
  "fis_ajusteapur_data" date,
  "fix_ajbenefinc_cod" text,
  "fis_ajusteapurinf_seq" bigint,
  "fis_ajusteapurinf_nda" text,
  "fis_ajusteapurinf_nproc" text,
  "fis_ajusteapurinf_origproc" text,
  "fis_ajusteapurinf_proc" text,
  "fis_ajusteapurinf_compl" text
);
create index if not exists "ix_fis_ajusteapurinf" on "topcon_sys"."fis_ajusteapurinf" ("ger_empresa_cod", "fis_ajusteapur_data", "fix_ajbenefinc_cod", "fis_ajusteapurinf_seq");
alter table "topcon_sys"."fis_ajusteapurinf" enable row level security;
create table if not exists "topcon_sys"."fis_ajusteapuritem" (
  "ger_empresa_cod" bigint,
  "fis_ajusteapur_data" date,
  "fix_ajbenefinc_cod" text,
  "fis_ajusteapuritem_seq" bigint,
  "ger_pessoa_cod" bigint,
  "fix_moddocfiscal_cod" text,
  "fis_ajusteapuritem_ser" text,
  "fis_ajusteapuritem_subser" text,
  "fis_ajusteapuritem_nnf" bigint,
  "ger_prod_cod" text,
  "fis_ajusteapuritem_data" date,
  "fis_ajusteapuritem_vlr" numeric
);
create index if not exists "ix_fis_ajusteapuritem" on "topcon_sys"."fis_ajusteapuritem" ("ger_empresa_cod", "fis_ajusteapur_data", "fix_ajbenefinc_cod", "fis_ajusteapuritem_seq");
alter table "topcon_sys"."fis_ajusteapuritem" enable row level security;
create table if not exists "topcon_sys"."fis_apur_guias" (
  "filial" bigint,
  "dt_apur" date,
  "tp_imp" bigint,
  "tp_guia" text,
  "uf" text,
  "seq" bigint,
  "nguia" text,
  "dt" date,
  "vl" numeric,
  "org_loc" text
);
create index if not exists "ix_fis_apur_guias" on "topcon_sys"."fis_apur_guias" ("filial", "dt_apur", "tp_imp", "tp_guia", "uf", "seq");
alter table "topcon_sys"."fis_apur_guias" enable row level security;
create table if not exists "topcon_sys"."fis_apuracao" (
  "filial" bigint,
  "dt" date,
  "tp_imp" bigint,
  "linha_apur" bigint,
  "seq" bigint,
  "descr" text,
  "vl" numeric,
  "id_cadast" text,
  "id_atual" text,
  "uf" text
);
create index if not exists "ix_fis_apuracao" on "topcon_sys"."fis_apuracao" ("filial", "dt", "tp_imp", "linha_apur", "seq");
alter table "topcon_sys"."fis_apuracao" enable row level security;
create table if not exists "topcon_sys"."fis_apuricms" (
  "ger_empresa_cod" bigint,
  "fis_apuricms_data" date,
  "fis_apuricms_vlrtotdeb" numeric,
  "fis_apuricms_vlrajdebdoc" numeric,
  "fis_apuricms_vlrajustedeb" numeric,
  "fis_apuricms_vlrestcred" numeric,
  "fis_apuricms_vlrtotcred" numeric,
  "fis_apuricms_vlrajucreddoc" numeric,
  "fis_apuricms_vlrajustecred" numeric,
  "fis_apuricms_vlrestdeb" numeric,
  "fis_apuricms_sdocredant" numeric,
  "fis_apuricms_vlrsdoapur" numeric,
  "fis_apuricms_vlrtotded" numeric,
  "fis_apuricms_vlrrec" numeric,
  "fis_apuricms_sdocredtransp" numeric,
  "fis_apuricms_debesp" numeric,
  "fis_apuricms_idcadast" text,
  "fis_apuricms_debespajdoc" numeric,
  "fis_apuricms_debespdoc" numeric,
  "fis_apuricms_vlrtotdeddoc" numeric,
  "fis_apuricms_idtual" text
);
create index if not exists "ix_fis_apuricms" on "topcon_sys"."fis_apuricms" ("ger_empresa_cod", "fis_apuricms_data");
alter table "topcon_sys"."fis_apuricms" enable row level security;
create table if not exists "topcon_sys"."fis_apuricmsobrrec" (
  "ger_empresa_cod" bigint,
  "fis_apuricmsobrrec_data" date,
  "fis_apuricmsobrrec_uf" text,
  "fix_obricmsrec_cod" text,
  "fis_apuricmsobrrec_valor" numeric,
  "fis_apuricmsobrrec_dtvencto" date,
  "fix_codrecicms_uf" text,
  "fix_codrecicms_cod" text,
  "fis_apuricmsobrrec_nproc" text,
  "fis_apuricmsobrrec_origproc" text,
  "fis_apuricmsobrrec_proc" text,
  "fis_apuricmsobrrec_compl" text,
  "fis_apuricmsobrrec_mesref" date,
  "fis_apuricmsobrrec_idcadast" text,
  "fis_apuricmsobrrec_idatual" text,
  "fis_apuricmsobrrec_tpicms" text
);
create index if not exists "ix_fis_apuricmsobrrec" on "topcon_sys"."fis_apuricmsobrrec" ("ger_empresa_cod", "fis_apuricmsobrrec_tpicms", "fis_apuricmsobrrec_data", "fis_apuricmsobrrec_uf", "fix_obricmsrec_cod");
alter table "topcon_sys"."fis_apuricmsobrrec" enable row level security;
create table if not exists "topcon_sys"."fis_apuricmsst" (
  "ger_empresa_cod" bigint,
  "fis_apuricmsst_data" date,
  "fis_apuricmsst_uf" text,
  "fis_apuricmsst_sdocredant" numeric,
  "fis_apuricmsst_vlrdevol" numeric,
  "fis_apuricmsst_vlrressarc" numeric,
  "fis_apuricmsst_vlroutcreddoc" numeric,
  "fis_apuricmsst_vlroutcredapur" numeric,
  "fis_apuricmsst_vlrajcred" numeric,
  "fis_apuricmsst_vlrretencao" numeric,
  "fis_apuricmsst_vlroutdeb" numeric,
  "fis_apuricmsst_vlrajdeb" numeric,
  "fis_apuricmsst_vlrsdodevedor" numeric,
  "fis_apuricmsst_vlrdedapur" numeric,
  "fis_apuricmsst_vlrdeddoc" numeric,
  "fis_apuricmsst_vlrrecolher" numeric,
  "fis_apuricmsst_sdotransp" numeric,
  "fis_apuricmsst_debespdoc" numeric,
  "fis_apuricmsst_dbespajdoc" numeric,
  "fis_apuricmsst_debespapu" numeric,
  "fis_apuricmsst_idcadast" text
);
create index if not exists "ix_fis_apuricmsst" on "topcon_sys"."fis_apuricmsst" ("ger_empresa_cod", "fis_apuricmsst_data", "fis_apuricmsst_uf");
alter table "topcon_sys"."fis_apuricmsst" enable row level security;
create table if not exists "topcon_sys"."fis_apurvlrdecl" (
  "ger_empresa_cod" bigint,
  "fis_apurvlrdecl_data" date,
  "fix_infadicapur_cod" text,
  "fis_apurvlrdecl_valor" numeric,
  "fis_apurvlrdecl_compl" text,
  "fis_apurvlrdecl_idcadast" text,
  "fis_apurvlrdecl_idatual" text
);
create index if not exists "ix_fis_apurvlrdecl" on "topcon_sys"."fis_apurvlrdecl" ("ger_empresa_cod", "fis_apurvlrdecl_data", "fix_infadicapur_cod");
alter table "topcon_sys"."fis_apurvlrdecl" enable row level security;
create table if not exists "topcon_sys"."fis_bc_reform_trib" (
  "emp_filial" bigint,
  "tot_prod" text,
  "tot_serv" text,
  "tot_frete" text,
  "tot_seguro" text,
  "tot_outros" text,
  "tot_ii" text,
  "tot_is" text,
  "tot_desc" text,
  "tot_pis" text,
  "tot_cofins" text,
  "tot_icms" text,
  "tot_issqn" text,
  "tot_pis_ret" text,
  "tot_cofins_ret" text
);
create index if not exists "ix_fis_bc_reform_trib" on "topcon_sys"."fis_bc_reform_trib" ("emp_filial");
alter table "topcon_sys"."fis_bc_reform_trib" enable row level security;
create table if not exists "topcon_sys"."fis_benef_fiscal" (
  "cfop" bigint,
  "seq" bigint,
  "uf" text,
  "cod_beneficio_fiscal" text
);
create index if not exists "ix_fis_benef_fiscal" on "topcon_sys"."fis_benef_fiscal" ("cfop", "seq", "uf");
alter table "topcon_sys"."fis_benef_fiscal" enable row level security;
create table if not exists "topcon_sys"."fis_cf_prest_serv" (
  "cod" bigint,
  "descr" text,
  "denom" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_cf_prest_serv" on "topcon_sys"."fis_cf_prest_serv" ("cod");
alter table "topcon_sys"."fis_cf_prest_serv" enable row level security;
create table if not exists "topcon_sys"."fis_cfop" (
  "cod" bigint,
  "denom" text,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_cfop" on "topcon_sys"."fis_cfop" ("cod");
alter table "topcon_sys"."fis_cfop" enable row level security;
create table if not exists "topcon_sys"."fis_cfop_remanufatura" (
  "cfop" bigint,
  "tipo" text,
  "seq_cfop" bigint
);
create index if not exists "ix_fis_cfop_remanufatura" on "topcon_sys"."fis_cfop_remanufatura" ("cfop", "seq_cfop", "tipo");
alter table "topcon_sys"."fis_cfop_remanufatura" enable row level security;
create table if not exists "topcon_sys"."fis_cfop_xml_sem_ped" (
  "cfop" bigint
);
create index if not exists "ix_fis_cfop_xml_sem_ped" on "topcon_sys"."fis_cfop_xml_sem_ped" ("cfop");
alter table "topcon_sys"."fis_cfop_xml_sem_ped" enable row level security;
create table if not exists "topcon_sys"."fis_csosn" (
  "codigo" bigint,
  "descricao_csosn" text,
  "descricao_compl" text
);
create index if not exists "ix_fis_csosn" on "topcon_sys"."fis_csosn" ("codigo");
alter table "topcon_sys"."fis_csosn" enable row level security;
create table if not exists "topcon_sys"."fis_cst_icms" (
  "codigo" text,
  "descricao" text
);
create index if not exists "ix_fis_cst_icms" on "topcon_sys"."fis_cst_icms" ("codigo");
alter table "topcon_sys"."fis_cst_icms" enable row level security;
create table if not exists "topcon_sys"."fis_cst_pis_cofins" (
  "codigo" text,
  "descricao" text
);
create index if not exists "ix_fis_cst_pis_cofins" on "topcon_sys"."fis_cst_pis_cofins" ("codigo");
alter table "topcon_sys"."fis_cst_pis_cofins" enable row level security;
create table if not exists "topcon_sys"."fis_declexp" (
  "ger_empresa_cod" bigint,
  "fis_declexp_cod" bigint,
  "fis_declexp_tipodoc" text,
  "fis_declexp_descr" text,
  "fis_declexp_num" bigint,
  "fis_declexp_dt" date,
  "fis_declexp_natur" text,
  "fis_declexp_dtreg" date,
  "fis_declexp_numchcemb" text,
  "fis_declexp_dtchcemb" date,
  "fis_declexp_dtaverb" date,
  "fis_declexp_tipochcemb" bigint,
  "fis_declexp_paissiscomex" bigint,
  "fis_declexp_idcadast" text,
  "fis_declexp_idatual" text,
  "fis_declexp_numreg" bigint
);
create index if not exists "ix_fis_declexp" on "topcon_sys"."fis_declexp" ("ger_empresa_cod", "fis_declexp_cod");
alter table "topcon_sys"."fis_declexp" enable row level security;
create table if not exists "topcon_sys"."fis_discriminacao_nf" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint,
  "template_discri" bigint,
  "discriminacao" text,
  "observacao" text
);
create index if not exists "ix_fis_discriminacao_nf" on "topcon_sys"."fis_discriminacao_nf" ("filial", "cli", "tp_doc", "num_nf", "ser", "sub_ser");
alter table "topcon_sys"."fis_discriminacao_nf" enable row level security;
create table if not exists "topcon_sys"."fis_equipecf" (
  "fis_equipecf_num" bigint,
  "fis_equipecf_modelo" text,
  "fis_equipecf_numserie" text,
  "fis_equipecf_idcadast" text,
  "fis_equipecf_idatual" text,
  "empresacod" bigint
);
create index if not exists "ix_fis_equipecf" on "topcon_sys"."fis_equipecf" ("fis_equipecf_num");
alter table "topcon_sys"."fis_equipecf" enable row level security;
create table if not exists "topcon_sys"."fis_estoque" (
  "filial" bigint,
  "tp_estq" bigint,
  "merc" text,
  "proprietario" bigint,
  "fisico_contabil" text,
  "pa_qt_estq" numeric,
  "pa_custo_tot" numeric,
  "pa_custo_medio_un" numeric
);
create index if not exists "ix_fis_estoque" on "topcon_sys"."fis_estoque" ("filial", "tp_estq", "merc", "proprietario", "fisico_contabil");
alter table "topcon_sys"."fis_estoque" enable row level security;
create table if not exists "topcon_sys"."fis_estoque_local" (
  "filial" bigint,
  "local" text,
  "merc" text,
  "pa_qt_estq" numeric,
  "pa_custo_tot" numeric,
  "pa_custo_medio_un" numeric
);
create index if not exists "ix_fis_estoque_local" on "topcon_sys"."fis_estoque_local" ("filial", "local", "merc");
alter table "topcon_sys"."fis_estoque_local" enable row level security;
create table if not exists "topcon_sys"."fis_estoque_medicao" (
  "cod" bigint,
  "usina" bigint,
  "local" text,
  "material" text,
  "unidade" text,
  "dt_hr_medicao" timestamp,
  "qtde_estoque" numeric,
  "qtde_estoque_atual" numeric,
  "filial_mov" bigint,
  "interv_mov" bigint,
  "tp_doc_mov" bigint,
  "num_nf_mov" bigint,
  "serie_mov" text,
  "seq_nf_mov" bigint,
  "id_aprov" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_estoque_medicao" on "topcon_sys"."fis_estoque_medicao" ("cod", "usina");
alter table "topcon_sys"."fis_estoque_medicao" enable row level security;
create table if not exists "topcon_sys"."fis_estoque_mf" (
  "filial" bigint,
  "tp_estq" bigint,
  "merc" text,
  "interv" bigint,
  "data_fecham" date,
  "fisico_contabil" text,
  "qt_estq" numeric,
  "custo_total" numeric
);
create index if not exists "ix_fis_estoque_mf" on "topcon_sys"."fis_estoque_mf" ("filial", "tp_estq", "merc", "interv", "data_fecham", "fisico_contabil");
alter table "topcon_sys"."fis_estoque_mf" enable row level security;
create table if not exists "topcon_sys"."fis_estoque_mf_local" (
  "filial" bigint,
  "local" text,
  "merc" text,
  "data_fecham" date,
  "qt_estq" numeric,
  "custo_total" numeric
);
create index if not exists "ix_fis_estoque_mf_local" on "topcon_sys"."fis_estoque_mf_local" ("filial", "local", "merc", "data_fecham");
alter table "topcon_sys"."fis_estoque_mf_local" enable row level security;
create table if not exists "topcon_sys"."fis_estoque_mov" (
  "filial" bigint,
  "tp_estq" bigint,
  "merc" text,
  "interv" bigint,
  "data" date,
  "fisico_contabil" text,
  "qtd_movimento" numeric,
  "custo_total" numeric
);
create index if not exists "ix_fis_estoque_mov" on "topcon_sys"."fis_estoque_mov" ("filial", "tp_estq", "merc", "interv", "data", "fisico_contabil");
alter table "topcon_sys"."fis_estoque_mov" enable row level security;
create table if not exists "topcon_sys"."fis_estq_mov_local" (
  "filial" bigint,
  "local" text,
  "merc" text,
  "data" date,
  "qtd_movimento" numeric,
  "custo_total" numeric
);
create index if not exists "ix_fis_estq_mov_local" on "topcon_sys"."fis_estq_mov_local" ("filial", "local", "merc", "data");
alter table "topcon_sys"."fis_estq_mov_local" enable row level security;
create table if not exists "topcon_sys"."fis_faturamento" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "filial_faturamento" bigint,
  "num_faturamento" bigint,
  "fatura" bigint
);
create index if not exists "ix_fis_faturamento" on "topcon_sys"."fis_faturamento" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."fis_faturamento" enable row level security;
create table if not exists "topcon_sys"."fis_filial" (
  "emp_filial" bigint,
  "nome" text,
  "razao_social" text,
  "cep" text,
  "endereco" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "cnpj" text,
  "ie" text,
  "ccm" text,
  "c_custo" bigint,
  "prox_livro_serv" bigint,
  "prox_folha_serv" bigint,
  "prox_livro_entr" bigint,
  "prox_folha_entr" bigint,
  "prox_livro_said" bigint,
  "prox_folha_said" bigint,
  "prox_livro_apur" bigint,
  "prox_folha_apur" bigint,
  "prox_nf" bigint,
  "prox_nf_serv" bigint,
  "prox_nf_serv_seq" bigint,
  "id_cadast" text,
  "id_atual" text,
  "ser_nf" text,
  "ser_nf_serv" text,
  "prox_rps" bigint,
  "nfs_pfilial" text,
  "ddd" bigint,
  "fone" bigint,
  "dt_env_nfp" date,
  "interv" bigint,
  "tipo_ambiente" bigint,
  "cnae" text,
  "tp_doc" bigint,
  "cfop_padrao" bigint,
  "seq_cfop_padrao" bigint,
  "serie_compras" text,
  "nfs_sem_pedido" text,
  "km_max_viagem" bigint,
  "km_max_dia" bigint,
  "contador_nome" text,
  "contador_cpf" text,
  "contador_crc" text,
  "contador_ddd" bigint,
  "contador_telefo" bigint,
  "contador_email" text,
  "junta_cml_cart" text,
  "num_reg" text,
  "dt_reg" date,
  "prox_lote_nfs" bigint,
  "cfop_transf" bigint,
  "seq_cfop_transf" bigint,
  "serie_dev" text,
  "cfop_bomba" bigint,
  "seq_cfop_bomba" bigint,
  "tribcontrib_con" text,
  "tribcontrib_bom" text,
  "tribcontrib_nfs" text,
  "dpec" text,
  "tribcont_bomret" text,
  "class_cons_ee" bigint,
  "tipo_ligacao" bigint,
  "grupo_tensao" bigint,
  "tipo_assinante" bigint,
  "pct_aprox_ibpt" numeric,
  "obriga_ret_pref" text,
  "prox_fatura" bigint,
  "cod_trib_mun" text,
  "iss_bomba" text,
  "serie_transf" text,
  "msg_fis_nfes" text,
  "ser_nf_serv_obr" text,
  "qt_dia_perm_nf" bigint,
  "dt_ult_fech_fis" date,
  "ser_transf_estq" text,
  "insc_sequencial" bigint,
  "interv_dest_nf" bigint,
  "tp_desc_nf_serv" bigint,
  "nome_prefeitura" text,
  "cnpj_prefeitura" text,
  "tp_fret_remessa" bigint,
  "ser_dev_compras" text,
  "vlr_danfe" bigint,
  "prox_recibo" bigint,
  "endereco_ws" text,
  "verif_xml_auto" text,
  "dias_dif_emi_op" bigint,
  "dias_lim_inc_nf" bigint,
  "chave_validacao" text,
  "tp_doc_cecam" bigint,
  "tipo_amb_pref" bigint,
  "usuario_ws" text,
  "frase_secr_ws" text,
  "ser_nf_premold" text,
  "ser_nf_pedra" text,
  "gera_res_val_nf" text,
  "cont_estq_local" text,
  "pctaproxtribdan" numeric,
  "ct_est_cons_loc" text,
  "opt_simpl_nac" text,
  "dt_ad_simpl_nac" date,
  "aliq_simpl_nac" numeric,
  "regime_trib" text,
  "tp_doc_bomba" bigint,
  "msg_fiscal_rem" text,
  "ind_presenca" bigint,
  "mod_danfe_rem" text,
  "mod_danfe_compras" text,
  "gera_fatura_pes" text,
  "gera_dados_veiculo" text,
  "template_discri" bigint,
  "endereco_ws_ret" text,
  "templ_dis_rec_loc" bigint,
  "sistema_nfse" bigint,
  "dif_dt_atual_op" bigint,
  "pct_inss" numeric,
  "base_calc_inss" numeric,
  "ret_minima_federal" numeric,
  "valida_os_req" text,
  "ded_iss_bcpis" text,
  "cod_serv_sp" text,
  "end_impressao_nfse" text,
  "anexo_simpl_nac" bigint,
  "filial_fiscal_ativa" text,
  "dt_inativacao" date,
  "forma_faturamento" bigint,
  "complemento_atividade" text,
  "cod_transportador_remessa_concreto" bigint,
  "tipo_arredondamento_iss" bigint,
  "pct_irrf" numeric,
  "pct_csll" numeric,
  "pct_pis" numeric,
  "pct_cofins" numeric,
  "permite_doc_diferente_padrao_rem" text,
  "permite_doc_diferente_padrao_bomba" text,
  "url_base_oobj" text,
  "usuario_oobj" text,
  "num_tentativas_oobj" bigint,
  "url_monitor_oobj" text,
  "resp_envia_oobj" text,
  "resp_xcontato_oobj" text,
  "resp_ddd_oobj" bigint,
  "resp_fone_oobj" bigint,
  "resp_cnpj_oobj" text,
  "resp_email_oobj" text,
  "tipo_transportador" bigint,
  "tipo_emissao" bigint,
  "emissao_mdfe" bigint,
  "port_retencao_contratual" bigint,
  "oper_retencao_contratual" bigint,
  "regime_recolhimento" bigint,
  "responsavel_distribuicao" bigint,
  "codigo_uf_responsavel_distribuicao" bigint,
  "ultimo_lote_evento_manifestacao" bigint,
  "ultima_data_hora_dfe_consultado" timestamp,
  "ultima_data_hora_evento_consultado" timestamp,
  "ret_aplic" bigint,
  "tipo_frete" bigint,
  "natureza_frete" bigint,
  "limite_dias_consulta_status_dfe" bigint,
  "consulta_lancamento_dfe_6218" text,
  "integra_xml_desta_filial" text,
  "detalha_aprop_fatura" text,
  "serie_mdfe" text,
  "external_id" text,
  "opta_ref_trib" text,
  "codigo_nbs_nfse" text,
  "certificado_nfse" text,
  "limiterpsporlote" bigint,
  "pct_aprox_trib_federal" numeric,
  "pct_aprox_trib_estadual" numeric,
  "pct_aprox_trib_municipal" numeric,
  "tipodeducaoreforma" text,
  "ultimo_nsu_dl_sefin" bigint,
  "cfop_venda" bigint,
  "seq_cfop_venda" bigint,
  "serie_venda" text,
  "msg_fiscal_venda" text,
  "tribcontrib_venda" text,
  "fat_car_juncao" text,
  "templ_dis_venda" bigint,
  "fat_car_liq" text,
  "cfop_venda_fora" bigint,
  "seq_cfop_venda_fora" bigint,
  "cfop_dev_venda_fora" bigint,
  "seq_cfop_dev_venda_fora" bigint,
  "cfop_dev_venda" bigint,
  "seq_cfop_dev_venda" bigint,
  "serie_dev_venda" text,
  "msg_fiscal_dev_venda" text,
  "tribcontrib_dev_venda" text,
  "templ_dis_dev_venda" bigint
);
create index if not exists "ix_fis_filial" on "topcon_sys"."fis_filial" ("emp_filial");
alter table "topcon_sys"."fis_filial" enable row level security;
create table if not exists "topcon_sys"."fis_filial_complemento" (
  "emp_filial" bigint,
  "id_imp_cbs" bigint,
  "id_imp_ibs" bigint,
  "id_imp_is" bigint,
  "tot_fin_reform_trib" text,
  "cindop_nfse" text,
  "tipo_arredondamento_rt" bigint,
  "opta_ref_trib_serv" text,
  "ultima_data_hora_cte_consultado" timestamp,
  "valida_parametros_integrador_dfe" bigint,
  "fechar_ate" date,
  "dt_ultima_exec" timestamp
);
create index if not exists "ix_fis_filial_complemento" on "topcon_sys"."fis_filial_complemento" ("emp_filial");
alter table "topcon_sys"."fis_filial_complemento" enable row level security;
create table if not exists "topcon_sys"."fis_filial_documentos_distribuicao" (
  "emp_filial" bigint,
  "tp_doc" bigint,
  "descricao" text,
  "integra" text
);
create index if not exists "ix_fis_filial_documentos_distribuicao" on "topcon_sys"."fis_filial_documentos_distribuicao" ("emp_filial", "tp_doc");
alter table "topcon_sys"."fis_filial_documentos_distribuicao" enable row level security;
create table if not exists "topcon_sys"."fis_gnre" (
  "filial" bigint,
  "cnpj" text,
  "ie" text,
  "dt_guia" date,
  "uf_subs" text,
  "uf_dest" text,
  "bco" bigint,
  "num_ag" bigint,
  "num_auten" text,
  "vl_gnre" numeric,
  "dt_vencto_gnre" date,
  "fato_gerador" date,
  "campo_15_gnre" text
);
alter table "topcon_sys"."fis_gnre" enable row level security;
create table if not exists "topcon_sys"."fis_invent" (
  "ger_empresa_cod" bigint,
  "fis_invent_dt" date,
  "fis_invent_tipoestoque" text,
  "fis_invent_idcadast" text,
  "fis_invent_idatual" text
);
create index if not exists "ix_fis_invent" on "topcon_sys"."fis_invent" ("ger_empresa_cod", "fis_invent_dt", "fis_invent_tipoestoque");
alter table "topcon_sys"."fis_invent" enable row level security;
create table if not exists "topcon_sys"."fis_inventitem" (
  "ger_empresa_cod" bigint,
  "fis_invent_dt" date,
  "fis_invent_tipoestoque" text,
  "ger_prod_cod" text,
  "ger_pessoa_cod" bigint,
  "fis_inventitem_qtde" numeric,
  "fis_inventitem_vlrunit" numeric,
  "fis_inventitem_vlrtotal" numeric,
  "fis_inventitem_descrcompl" text,
  "fis_inventitem_ctactb" text,
  "undcompra_cod" text
);
create index if not exists "ix_fis_inventitem" on "topcon_sys"."fis_inventitem" ("ger_empresa_cod", "fis_invent_dt", "fis_invent_tipoestoque", "ger_prod_cod", "ger_pessoa_cod");
alter table "topcon_sys"."fis_inventitem" enable row level security;
create table if not exists "topcon_sys"."fis_item_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "dt_op" date,
  "trans" bigint,
  "cfop" bigint,
  "seq_cfop" bigint,
  "ind_mvto_produt" bigint,
  "tp_estq" bigint,
  "merc" text,
  "qt" numeric,
  "preco_un" numeric,
  "vl_tot" numeric,
  "vl_desc" numeric,
  "vl_frete" numeric,
  "vl_seg" numeric,
  "vl_o_desp" numeric,
  "sit_trib" text,
  "base_calc_icms" numeric,
  "aliq_icms" numeric,
  "vl_icms" numeric,
  "base_icms_sub_t" numeric,
  "aliq_icms_sub" numeric,
  "vl_icms_sub_tri" numeric,
  "base_calc_ipi" numeric,
  "aliq_ipi" numeric,
  "vl_ipi" numeric,
  "vl_pis_n_cum" numeric,
  "vl_cofins_n_cum" numeric,
  "custo_tot_item" numeric,
  "proprietario" bigint,
  "peso" numeric,
  "id_cadast" text,
  "id_atual" text,
  "traco_concreto" text,
  "volume" numeric,
  "qtde_estoque" numeric,
  "cst_pis" text,
  "cst_cofins" text,
  "vl_fisc_1_icms" numeric,
  "vl_fisc_2_icms" numeric,
  "vl_fisc_3_icms" numeric,
  "vl_fisc_1_ipi" numeric,
  "vl_fisc_2_ipi" numeric,
  "vl_fisc_3_ipi" numeric,
  "pct_pis_n_cum" numeric,
  "pct_cofins_ncum" numeric,
  "ref_forn" bigint,
  "vl_obs" numeric,
  "ref_tp_doc" bigint,
  "ref_serie" text,
  "ref_num_nf" bigint,
  "ref_item" bigint,
  "qtde_dev" numeric,
  "vlr_bc_pis" numeric,
  "pct_pis" numeric,
  "vlr_pis" numeric,
  "vlr_bc_cofins" numeric,
  "pct_cofins" numeric,
  "vlr_cofins" numeric,
  "mva" numeric,
  "interv_estq" bigint,
  "umidade" numeric,
  "piscst" text,
  "pisbc" numeric,
  "pispct" numeric,
  "pisvalor" numeric,
  "cofinscst" text,
  "cofinsbc" numeric,
  "cofinspct" numeric,
  "cofinsvalor" numeric,
  "tribcontrib" text,
  "inivigtribcont" date,
  "oper" bigint,
  "ipi_cst" text,
  "unidade" text,
  "vcredicmssn" numeric,
  "pcredsn" numeric,
  "csosn" bigint,
  "base_calc_icmssn" numeric
);
create index if not exists "ix_fis_item_nf" on "topcon_sys"."fis_item_nf" ("filial", "interv", "tp_doc", "ser", "num_nf", "seq_nf", "num_seq_item_nf");
alter table "topcon_sys"."fis_item_nf" enable row level security;
create table if not exists "topcon_sys"."fis_item_nf_complemento" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "cc" bigint,
  "base_calc_icms_na" numeric,
  "aliq_icms_na" numeric,
  "vl_icms_na" numeric,
  "id_imp_cbs" bigint,
  "id_imp_is" bigint,
  "id_imp_ibs" bigint,
  "cst_cbs_ibs" text,
  "clas_trib_cbs_ibs" text,
  "cst_is" text,
  "clas_trib_is" text,
  "base_ibscbs" numeric,
  "aliq_cbs_efet" numeric,
  "aliq_cbs" numeric,
  "p_redcbs" numeric,
  "vl_cbs" numeric,
  "aliq_ibs_mun_efet" numeric,
  "aliq_ibs_mun" numeric,
  "p_redibs_mun" numeric,
  "vl_ibs_mun" numeric,
  "aliq_ibs_uf_efet" numeric,
  "aliq_ibs_uf" numeric,
  "p_redibs_uf" numeric,
  "vl_ibs_uf" numeric,
  "vl_ibs" numeric,
  "base_is" numeric,
  "aliq_is" numeric,
  "vl_is" numeric,
  "seq_dfe_ref" bigint,
  "chnfe_dfe_ref" text
);
create index if not exists "ix_fis_item_nf_complemento" on "topcon_sys"."fis_item_nf_complemento" ("filial", "interv", "tp_doc", "ser", "num_nf", "seq_nf", "num_seq_item_nf");
alter table "topcon_sys"."fis_item_nf_complemento" enable row level security;
create table if not exists "topcon_sys"."fis_item_nf_serv" (
  "filial" bigint,
  "cli" bigint,
  "tp_docs" bigint,
  "num_nfs" bigint,
  "serie_nfs" text,
  "sub_series" bigint,
  "num_rps" bigint,
  "num_nf_serv_seq" bigint,
  "seq_item" bigint,
  "filial_nf" bigint,
  "tp_doc_nf" bigint,
  "num_nf" bigint,
  "serie_nf" text,
  "dt_nf" date,
  "prod_serv" text,
  "unidade" text,
  "qt" numeric,
  "preco_unit" numeric,
  "preco_tot" numeric,
  "vlr_material" numeric,
  "vl_serv_bruto" numeric,
  "vlr_servico" numeric,
  "vl_desco" numeric,
  "vl_liq" numeric,
  "id_cadast" text,
  "id_atual" text,
  "piscst" text,
  "pisbc" numeric,
  "pispct" numeric,
  "pisvalor" numeric,
  "cofinscst" text,
  "cofinsbc" numeric,
  "cofinspct" numeric,
  "cofinsvalor" numeric,
  "tribcontrib" text,
  "inivigtribcont" date,
  "oper" bigint,
  "vlr_pis_ret" numeric,
  "vlr_cofins_ret" numeric,
  "vlr_irrf" numeric,
  "vlr_csll_ret" numeric,
  "iss_bc" numeric,
  "iss_pct" numeric,
  "iss_vlr" numeric,
  "iss_vlr_ret" numeric,
  "num_recibo" bigint,
  "num_protocolo" text,
  "ccusto" bigint,
  "id_imp_cbs" bigint,
  "id_imp_ibs" bigint,
  "cst_cbs_ibs" text,
  "clas_trib_cbs_ibs" text,
  "base_ibscbs" numeric,
  "aliq_cbs_efet" numeric,
  "aliq_cbs" numeric,
  "p_redcbs" numeric,
  "vl_cbs" numeric,
  "aliq_ibs_mun_efet" numeric,
  "aliq_ibs_mun" numeric,
  "p_redibs_mun" numeric,
  "vl_ibs_mun" numeric,
  "aliq_ibs_uf_efet" numeric,
  "aliq_ibs_uf" numeric,
  "p_redibs_uf" numeric,
  "vl_ibs_uf" numeric,
  "vl_ibs" numeric
);
create index if not exists "ix_fis_item_nf_serv" on "topcon_sys"."fis_item_nf_serv" ("filial", "tp_docs", "num_nfs", "serie_nfs", "sub_series", "seq_item", "cli");
alter table "topcon_sys"."fis_item_nf_serv" enable row level security;
create table if not exists "topcon_sys"."fis_leg_fiscal" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_leg_fiscal" on "topcon_sys"."fis_leg_fiscal" ("cod");
alter table "topcon_sys"."fis_leg_fiscal" enable row level security;
create table if not exists "topcon_sys"."fis_loteimp" (
  "fis_loteimp_cod" bigint,
  "fis_loteimp_usuario" text,
  "fis_loteimp_datahora" timestamp,
  "fis_loteimp_empresa" text,
  "fis_loteimp_dtfinal" date,
  "fis_loteimp_dtini" date
);
create index if not exists "ix_fis_loteimp" on "topcon_sys"."fis_loteimp" ("fis_loteimp_cod");
alter table "topcon_sys"."fis_loteimp" enable row level security;
create table if not exists "topcon_sys"."fis_mat_xml_forn" (
  "interv" bigint,
  "cod_mat_xml" text,
  "desc_mat_xml" text,
  "unidade_mat_xml" text,
  "fator_conv" numeric,
  "material" text
);
create index if not exists "ix_fis_mat_xml_forn" on "topcon_sys"."fis_mat_xml_forn" ("interv", "cod_mat_xml", "unidade_mat_xml");
alter table "topcon_sys"."fis_mat_xml_forn" enable row level security;
create table if not exists "topcon_sys"."fis_mat_xml_oper" (
  "interv" bigint,
  "cod_mat_xml" text,
  "unidade_mat_xml" text,
  "cfop_mat_xml" bigint,
  "cfop_op_fiscal" bigint,
  "seq_op_fiscal" bigint
);
create index if not exists "ix_fis_mat_xml_oper" on "topcon_sys"."fis_mat_xml_oper" ("interv", "cod_mat_xml", "unidade_mat_xml", "cfop_mat_xml");
alter table "topcon_sys"."fis_mat_xml_oper" enable row level security;
create table if not exists "topcon_sys"."fis_mensfiscal" (
  "fis_mensfiscal_cod" bigint,
  "fis_mensfiscal_descr" text,
  "fis_mensfiscal_idcadast" text,
  "fis_mensfiscal_idatual" text
);
create index if not exists "ix_fis_mensfiscal" on "topcon_sys"."fis_mensfiscal" ("fis_mensfiscal_cod");
alter table "topcon_sys"."fis_mensfiscal" enable row level security;
create table if not exists "topcon_sys"."fis_merc_trib_mun" (
  "material" text,
  "mun_oficial" bigint,
  "lista_servico" bigint
);
create index if not exists "ix_fis_merc_trib_mun" on "topcon_sys"."fis_merc_trib_mun" ("material", "mun_oficial");
alter table "topcon_sys"."fis_merc_trib_mun" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria" (
  "cod" text,
  "denom" text,
  "descr" text,
  "abrev" text,
  "unid_consumo" text,
  "cimento" text,
  "forn" bigint,
  "fiscal_mercosul" text,
  "estoque_minimo" numeric,
  "dias_reposicao" bigint,
  "fator_conversao" numeric,
  "id_cadast" text,
  "id_atual" text,
  "un_emb" text,
  "qt_pc_emb" bigint,
  "peso_liq_emb" numeric,
  "peso_bruto_emb" numeric,
  "fator_un_comp" numeric,
  "fab" text,
  "grupo" bigint,
  "sub_grupo" bigint,
  "sit_trib" text,
  "pct_red_calc_icms" numeric,
  "dt_cad" date,
  "dt_ult_venda" date,
  "dt_ult_comp" date,
  "qt_comp" numeric,
  "preco_un_liq" numeric,
  "custo_un" numeric,
  "preco_tab1" numeric,
  "preco_tab2" numeric,
  "preco_tab3" numeric,
  "preco_tab4" numeric,
  "preco_tab5" numeric,
  "preco_tab6" numeric,
  "preco_tab7" numeric,
  "preco_tab8" numeric,
  "preco_tab9" numeric,
  "preco_tab10" numeric,
  "pct_comis_vend" numeric,
  "prod_serv" text,
  "cod_of_serv" bigint,
  "reg_fixo" text,
  "codigoa" bigint,
  "descr_nf" text,
  "cesta_basica" text,
  "cst_cestab" text,
  "referencia" text,
  "localizacao" text,
  "aprov_contab" text,
  "mva" numeric,
  "analise_almoxar" text,
  "cean" text,
  "cod_atividade" text,
  "tp_item" text,
  "aliq_icms_inter" numeric,
  "lista_servico" bigint,
  "familia" bigint,
  "id_aprov_contab" text,
  "inativo" text,
  "pct_aprox_ibpt" numeric,
  "frete" text,
  "fator_transf" numeric,
  "unid_transf" text,
  "sub_item_serv" bigint,
  "isento_iss" text,
  "cod_servico" text,
  "estoque_maximo" numeric,
  "gera_incons_pes" text,
  "cest" text,
  "cod_anp" bigint,
  "external_id" text,
  "tpop" bigint,
  "id_tech" text,
  "numeracao_produto" bigint,
  "id_imp_cbs" bigint,
  "id_imp_is" bigint,
  "id_imp_ibs" bigint,
  "cindop" text,
  "codigo_nbs" text,
  "lista_servico_nacional" text
);
create index if not exists "ix_fis_mercadoria" on "topcon_sys"."fis_mercadoria" ("cod");
alter table "topcon_sys"."fis_mercadoria" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_anp" (
  "cod_anp" bigint,
  "descr" text
);
create index if not exists "ix_fis_mercadoria_anp" on "topcon_sys"."fis_mercadoria_anp" ("cod_anp");
alter table "topcon_sys"."fis_mercadoria_anp" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_cest" (
  "cest" text,
  "ncm" text,
  "descricao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_mercadoria_cest" on "topcon_sys"."fis_mercadoria_cest" ("cest", "ncm");
alter table "topcon_sys"."fis_mercadoria_cest" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_de_para" (
  "id" bigint,
  "de_cod" text,
  "para_cod" text,
  "ajustado" bigint,
  "created_at" timestamp
);
create index if not exists "ix_fis_mercadoria_de_para" on "topcon_sys"."fis_mercadoria_de_para" ("id");
alter table "topcon_sys"."fis_mercadoria_de_para" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_forn" (
  "cod_produto" text,
  "cod_fornecedor" bigint,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "contato_default" bigint,
  "custo_ult_ent" numeric,
  "data_ult_ent" date
);
create index if not exists "ix_fis_mercadoria_forn" on "topcon_sys"."fis_mercadoria_forn" ("cod_produto", "cod_fornecedor");
alter table "topcon_sys"."fis_mercadoria_forn" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_goper" (
  "grupo" bigint,
  "sub_grupo" bigint,
  "item" bigint,
  "sub_item" bigint,
  "operacao" bigint,
  "id_cadast" text,
  "id_atual" text,
  "uf" text,
  "iniciovigencia" date,
  "cfop" bigint,
  "seqcfop" bigint,
  "tribcontrib" text,
  "ativo" text,
  "analis_contab" text,
  "id_aprov_contab" text
);
create index if not exists "ix_fis_mercadoria_goper" on "topcon_sys"."fis_mercadoria_goper" ("grupo", "sub_grupo", "item", "sub_item", "operacao", "uf", "iniciovigencia");
alter table "topcon_sys"."fis_mercadoria_goper" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_grupm" (
  "mercadoria" text,
  "grupo" bigint,
  "subgrupo" bigint,
  "item" bigint,
  "subitem" bigint,
  "analis_contab" text,
  "id_aprov_contab" text
);
create index if not exists "ix_fis_mercadoria_grupm" on "topcon_sys"."fis_mercadoria_grupm" ("mercadoria", "grupo", "subgrupo", "item", "subitem");
alter table "topcon_sys"."fis_mercadoria_grupm" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_grupo" (
  "nivel1" bigint,
  "nivel2" bigint,
  "nivel3" bigint,
  "nivel4" bigint,
  "descricao" text,
  "abrev" text,
  "especificacao" text,
  "operacao" bigint,
  "passa_almox" text,
  "ccustos" text,
  "toppedra" text,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "fck" numeric,
  "consumo" bigint,
  "obriga_os" text
);
create index if not exists "ix_fis_mercadoria_grupo" on "topcon_sys"."fis_mercadoria_grupo" ("nivel1", "nivel2", "nivel3", "nivel4");
alter table "topcon_sys"."fis_mercadoria_grupo" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_img" (
  "cod_material" text
);
create index if not exists "ix_fis_mercadoria_img" on "topcon_sys"."fis_mercadoria_img" ("cod_material");
alter table "topcon_sys"."fis_mercadoria_img" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_integracao_terceiros" (
  "cod" text,
  "external_id" text,
  "integration_type" text
);
create index if not exists "ix_fis_mercadoria_integracao_terceiros" on "topcon_sys"."fis_mercadoria_integracao_terceiros" ("cod", "integration_type");
alter table "topcon_sys"."fis_mercadoria_integracao_terceiros" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_local" (
  "mercadoria" text,
  "filial" bigint,
  "localizacao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_mercadoria_local" on "topcon_sys"."fis_mercadoria_local" ("mercadoria", "filial");
alter table "topcon_sys"."fis_mercadoria_local" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_oper" (
  "cod_mercadoria" text,
  "cod_oper" bigint,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "analis_contab" text
);
create index if not exists "ix_fis_mercadoria_oper" on "topcon_sys"."fis_mercadoria_oper" ("cod_mercadoria", "cod_oper");
alter table "topcon_sys"."fis_mercadoria_oper" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_ref" (
  "cod" text,
  "fabricante" bigint,
  "referencia" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_mercadoria_ref" on "topcon_sys"."fis_mercadoria_ref" ("cod", "fabricante");
alter table "topcon_sys"."fis_mercadoria_ref" enable row level security;
create table if not exists "topcon_sys"."fis_mercadoria_trib" (
  "cod_produto" text,
  "operacao" bigint,
  "uf" text,
  "iniciovigencia" date,
  "cfop" bigint,
  "seqcfop" bigint,
  "tribcontrib" text,
  "ativo" text,
  "id_cadast" text,
  "id_atual" text,
  "analis_contab" text,
  "id_aprov_contab" text
);
create index if not exists "ix_fis_mercadoria_trib" on "topcon_sys"."fis_mercadoria_trib" ("cod_produto", "operacao", "uf", "iniciovigencia");
alter table "topcon_sys"."fis_mercadoria_trib" enable row level security;
create table if not exists "topcon_sys"."fis_mod_doc" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_mod_doc" on "topcon_sys"."fis_mod_doc" ("cod");
alter table "topcon_sys"."fis_mod_doc" enable row level security;
create table if not exists "topcon_sys"."fis_movcomb" (
  "ger_empresa_cod" bigint,
  "fis_movcomb_data" date,
  "ger_tanqcomb_num" bigint,
  "fis_movcomb_estqabert" numeric,
  "fis_movcomb_volentr" numeric,
  "fis_movcomb_volsaida" numeric,
  "fis_movcomb_volajuste" numeric,
  "fis_movcomb_estqfech" numeric,
  "fis_movcomb_idcadast" text,
  "fis_movcomb_idatual" text
);
create index if not exists "ix_fis_movcomb" on "topcon_sys"."fis_movcomb" ("ger_empresa_cod", "fis_movcomb_data", "ger_tanqcomb_num");
alter table "topcon_sys"."fis_movcomb" enable row level security;
create table if not exists "topcon_sys"."fis_movcombtanq" (
  "ger_empresa_cod" bigint,
  "fis_movcomb_data" date,
  "ger_tanqcomb_num" bigint
);
create index if not exists "ix_fis_movcombtanq" on "topcon_sys"."fis_movcombtanq" ("ger_empresa_cod", "fis_movcomb_data", "ger_tanqcomb_num");
alter table "topcon_sys"."fis_movcombtanq" enable row level security;
create table if not exists "topcon_sys"."fis_movcombu" (
  "ger_empresa_cod" bigint,
  "fis_movcombu_data" date,
  "ger_tanqcomb_num" bigint,
  "fis_movcombu_estqabert" numeric,
  "fis_movcombu_volentr" numeric,
  "fis_movcombu_volsaida" numeric,
  "fis_movcombu_volajuste" numeric,
  "fis_movcombu_estqfech" numeric,
  "fis_movcombu_idcadast" text,
  "fis_movcombu_idatual" text
);
create index if not exists "ix_fis_movcombu" on "topcon_sys"."fis_movcombu" ("ger_empresa_cod", "fis_movcombu_data", "ger_tanqcomb_num");
alter table "topcon_sys"."fis_movcombu" enable row level security;
create table if not exists "topcon_sys"."fis_movcombuvolbico" (
  "ger_empresa_cod" bigint,
  "fis_movcombu_data" date,
  "ger_tanqcomb_num" bigint,
  "ger_bombacomb_num" bigint,
  "ger_bombacombbico_num" bigint,
  "fis_movcombuvolbico_contabert" numeric,
  "fis_movcombuvolbico_contfech" numeric,
  "fis_movcombuvolbico_contaferi" numeric
);
create index if not exists "ix_fis_movcombuvolbico" on "topcon_sys"."fis_movcombuvolbico" ("ger_empresa_cod", "fis_movcombu_data", "ger_tanqcomb_num", "ger_bombacomb_num", "ger_bombacombbico_num");
alter table "topcon_sys"."fis_movcombuvolbico" enable row level security;
create table if not exists "topcon_sys"."fis_movcombvolbico" (
  "ger_empresa_cod" bigint,
  "fis_movcomb_data" date,
  "ger_bombacomb_num" bigint,
  "ger_bombacombbico_num" bigint,
  "fis_movcombvolbico_contabert" numeric,
  "fis_movcombvolbico_contfech" numeric,
  "fis_movcombvolbico_contaferi" numeric
);
create index if not exists "ix_fis_movcombvolbico" on "topcon_sys"."fis_movcombvolbico" ("ger_empresa_cod", "fis_movcomb_data", "ger_bombacomb_num", "ger_bombacombbico_num");
alter table "topcon_sys"."fis_movcombvolbico" enable row level security;
create table if not exists "topcon_sys"."fis_movtocartao" (
  "ger_empresa_cod" bigint,
  "fis_movtocartao_data" date,
  "ger_pessoa_cod" bigint,
  "fis_movtocartao_vlrtotdeb" numeric,
  "fis_movtocartao_vlrtotcred" numeric,
  "fis_movtocartao_idcadast" text,
  "fis_movtocartao_idatual" text
);
create index if not exists "ix_fis_movtocartao" on "topcon_sys"."fis_movtocartao" ("ger_empresa_cod", "fis_movtocartao_data", "ger_pessoa_cod");
alter table "topcon_sys"."fis_movtocartao" enable row level security;
create table if not exists "topcon_sys"."fis_nf" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "dt_nf" date,
  "dt_oper" date,
  "dt_emi_nf" date,
  "hr_emissao" bigint,
  "dt_lcto_cancela" date,
  "cancelada" text,
  "ind_oper" bigint,
  "ind_emitente" bigint,
  "trans" bigint,
  "mod_doc_fiscal" text,
  "sit_fiscal" bigint,
  "cfop" bigint,
  "seq_cfop" bigint,
  "nf_compl" text,
  "nf_entr" text,
  "num_ped" bigint,
  "faturamento_ac" text,
  "vend" bigint,
  "loc_fat" bigint,
  "loc_ent" bigint,
  "loc_cobr" bigint,
  "cond_pgto" bigint,
  "uf_orig_dest" text,
  "vl_merc" numeric,
  "vl_desc" numeric,
  "vl_frete" numeric,
  "vl_seg" numeric,
  "vl_o_desp" numeric,
  "vl_cont_nf" numeric,
  "vl_base_icms" numeric,
  "aliq_icms" numeric,
  "vl_icms" numeric,
  "vl_base_icms_su" numeric,
  "vl_icms_sub" numeric,
  "vl_ipi" numeric,
  "vl_fisc_1_icms" numeric,
  "vl_fisc_2_icms" numeric,
  "vl_fisc_3_icms" numeric,
  "vl_fisc_1_ipi" numeric,
  "vl_fisc_2_ipi" numeric,
  "vl_fisc_3_ipi" numeric,
  "vl_obs" numeric,
  "leg_fisc1" bigint,
  "leg_fisc2" bigint,
  "via_transp" text,
  "transp" bigint,
  "qt_vol" bigint,
  "esp_vol" text,
  "peso_bruto" numeric,
  "peso_liq" numeric,
  "ind_frete" bigint,
  "ident_veic" text,
  "in86" text,
  "fat_v_p" bigint,
  "obs_fisc_nf" text,
  "obs_lf" text,
  "id_cadast" text,
  "id_atual" text,
  "filial_destino" bigint,
  "mens_fiscais" text,
  "uf_veic" text,
  "vlr_pis" numeric,
  "vlr_cofins" numeric,
  "embarque_local" text,
  "embarque_uf" text,
  "mens_fiscal_nfe" text,
  "forn_iss" bigint,
  "balanca" bigint,
  "requis_interna" text,
  "dif_pedido_just" bigint,
  "dif_pedido_anls" text,
  "sit_doc" text,
  "total_base_pis" numeric,
  "total_pis" numeric,
  "total_base_cofins" numeric,
  "total_cofins" numeric,
  "chave_nfe" text,
  "oper" bigint,
  "vl_serv" numeric,
  "cc" bigint,
  "requisitante" bigint,
  "class_cons_ee" bigint,
  "tipo_ligacao" bigint,
  "grupo_tensao" bigint,
  "tipo_assinante" bigint,
  "tipo_frete" bigint,
  "dt_pedido_just" date,
  "dt_lancamento" date,
  "natureza_frete" bigint,
  "filial_estoque" bigint,
  "num_req" bigint,
  "ano_req" bigint,
  "emp_req" bigint,
  "importado_xml" text,
  "leg_fisc_nf_ref" bigint,
  "atualizado_em" timestamp
);
create index if not exists "ix_fis_nf" on "topcon_sys"."fis_nf" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."fis_nf" enable row level security;
create table if not exists "topcon_sys"."fis_nf_complemento" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "ind_presenca" bigint,
  "meio_pagamento" bigint,
  "placa_transportador" text,
  "forma_insercao" text,
  "trans_seq" bigint,
  "p_red_gov" numeric,
  "tp_ente_gov" bigint,
  "tp_oper_gov" bigint,
  "base_ibscbs" numeric,
  "vl_cbs" numeric,
  "vl_ibs" numeric,
  "vl_ibs_mun" numeric,
  "vl_ibs_uf" numeric,
  "base_is" numeric,
  "vl_is" numeric,
  "tp_nf_debito" bigint,
  "tp_nf_credito" bigint,
  "totaliza_fin_reform_trib" text
);
create index if not exists "ix_fis_nf_complemento" on "topcon_sys"."fis_nf_complemento" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."fis_nf_complemento" enable row level security;
create table if not exists "topcon_sys"."fis_nf_ctrc" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "cod_mun_dest" bigint,
  "cod_mun_orig" bigint
);
create index if not exists "ix_fis_nf_ctrc" on "topcon_sys"."fis_nf_ctrc" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf");
alter table "topcon_sys"."fis_nf_ctrc" enable row level security;
create table if not exists "topcon_sys"."fis_nf_historico" (
  "filial" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "emitida" bigint
);
create index if not exists "ix_fis_nf_historico" on "topcon_sys"."fis_nf_historico" ("filial", "tp_doc", "serie", "num_nf");
alter table "topcon_sys"."fis_nf_historico" enable row level security;
create table if not exists "topcon_sys"."fis_nf_municipio" (
  "fis_nf_idnf" bigint,
  "ger_empresa_cod" bigint,
  "ger_tipodoc_cod" bigint,
  "fis_nf_ser" text,
  "fis_nf_num" bigint,
  "pessoa_cod" bigint,
  "fis_nf_dtoper" date,
  "fix_municorigem_cod" bigint,
  "municorigembase" bigint,
  "fix_municdestino_cod" bigint,
  "municdestinobase" bigint,
  "fornecedor" bigint
);
alter table "topcon_sys"."fis_nf_municipio" enable row level security;
create table if not exists "topcon_sys"."fis_nf_obsfis" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "seq" bigint,
  "obsfiscal_cod" text,
  "complobsfis" text,
  "codajuste" text,
  "complajuste" text,
  "itemnf" text,
  "vlrbcicms" numeric,
  "pcticms" numeric,
  "vlricms" numeric,
  "vlroutrosicms" numeric
);
create index if not exists "ix_fis_nf_obsfis" on "topcon_sys"."fis_nf_obsfis" ("filial", "interv", "tp_doc", "ser", "num_nf", "seq_nf", "seq");
alter table "topcon_sys"."fis_nf_obsfis" enable row level security;
create table if not exists "topcon_sys"."fis_nf_serv_vinc_sub" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint,
  "filial_sub" bigint,
  "cli_sub" bigint,
  "tp_doc_sub" bigint,
  "num_nf_sub" bigint,
  "ser_sub" text,
  "sub_ser_sub" bigint
);
create index if not exists "ix_fis_nf_serv_vinc_sub" on "topcon_sys"."fis_nf_serv_vinc_sub" ("filial", "cli", "tp_doc", "num_nf", "ser", "sub_ser", "filial_sub", "cli_sub", "tp_doc_sub", "num_nf_sub", "ser_sub", "sub_ser_sub");
alter table "topcon_sys"."fis_nf_serv_vinc_sub" enable row level security;
create table if not exists "topcon_sys"."fis_nf_servico" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint,
  "num_rps" bigint,
  "num_nf_serv_seq" bigint,
  "dt_nf" date,
  "ind_oper" bigint,
  "ind_emitente" bigint,
  "sit_fiscal" bigint,
  "cod_fisc_pserv" bigint,
  "munic_pserv" bigint,
  "nat_prestacao" bigint,
  "usina_contrato" bigint,
  "num_contrato" bigint,
  "ano_contrato" bigint,
  "faturamento_ac" text,
  "local_faturamen" bigint,
  "local_cobranca" bigint,
  "cond_pgto" bigint,
  "ind_pgto" bigint,
  "cancelada" text,
  "motivo_cancelam" bigint,
  "vl_serv_bruto" numeric,
  "vl_desco" numeric,
  "vl_serv" numeric,
  "vlr_mat_prop_ut" numeric,
  "vlr_mat_3os_ut" numeric,
  "desp_acessorias" numeric,
  "vlr_subcontrata" numeric,
  "valor_total" numeric,
  "base_calc_iss" numeric,
  "pct_iss" numeric,
  "vl_iss" numeric,
  "obs_fisc_nf" text,
  "base_calc_reten" numeric,
  "pct_iss_retido" numeric,
  "vlr_iss_retido" numeric,
  "base_cal_irrf" numeric,
  "pct_irrf" numeric,
  "vlr_irrf" numeric,
  "pct_pis" numeric,
  "vlr_pis" numeric,
  "pct_cofins" numeric,
  "vlr_cofins" numeric,
  "base_cal_inss_ret" numeric,
  "vlr_inss_retido" numeric,
  "representante" bigint,
  "vlr_comis_repre" numeric,
  "vendedor" bigint,
  "vlr_comis_vende" numeric,
  "qtde_parcelas" bigint,
  "in86" text,
  "id_cadast" text,
  "id_atual" text,
  "no_faturamento" bigint,
  "valor_total_bomba" numeric,
  "base_calc_iss_bomba" numeric,
  "vl_iss_bomba" numeric,
  "vlr_iss_retido_bomba" numeric,
  "pct_inss_retido" numeric,
  "base_calc_pis" numeric,
  "base_cal_cofins" numeric,
  "base_calc_irpj" numeric,
  "pct_irpj" numeric,
  "vlr_irpj" numeric,
  "base_calc_csll" numeric,
  "pct_csll" numeric,
  "vlr_csll" numeric,
  "cod_verfic_nfse" text,
  "requis_interna" text,
  "requisitante" bigint,
  "forn_iss" bigint,
  "total_base_pis" numeric,
  "total_pis" numeric,
  "total_base_cofins" numeric,
  "total_cofins" numeric,
  "oper" bigint,
  "dt_lancamento" date,
  "pendente" bigint,
  "bc_retencoes" numeric,
  "cc" bigint,
  "num_recibo" bigint,
  "encapsulamento" bigint,
  "num_protocolo" text,
  "num_protocolo_orig" text,
  "pct_inss" numeric,
  "vlr_inss" numeric,
  "base_cal_inss" numeric,
  "versao_contrato" bigint,
  "trans_seq" bigint,
  "p_red_gov" numeric,
  "tp_ente_gov" bigint,
  "tp_oper_gov" bigint,
  "base_ibscbs" numeric,
  "vl_cbs" numeric,
  "vl_ibs" numeric,
  "vl_ibs_mun" numeric,
  "vl_ibs_uf" numeric,
  "totaliza_fin_reform_trib" text,
  "finalidade_nfse" text,
  "atualizado_em" timestamp
);
create index if not exists "ix_fis_nf_servico" on "topcon_sys"."fis_nf_servico" ("filial", "tp_doc", "num_nf", "ser", "sub_ser", "cli");
alter table "topcon_sys"."fis_nf_servico" enable row level security;
create table if not exists "topcon_sys"."fis_nf_servico_integracao_terceiros" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint,
  "external_id" text,
  "integration_type" text
);
create index if not exists "ix_fis_nf_servico_integracao_terceiros" on "topcon_sys"."fis_nf_servico_integracao_terceiros" ("filial", "cli", "tp_doc", "num_nf", "ser", "sub_ser", "integration_type");
alter table "topcon_sys"."fis_nf_servico_integracao_terceiros" enable row level security;
create table if not exists "topcon_sys"."fis_nf_servico_qrcode" (
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint,
  "cod_verfic_nfse" text
);
create index if not exists "ix_fis_nf_servico_qrcode" on "topcon_sys"."fis_nf_servico_qrcode" ("filial", "tp_doc", "num_nf", "ser", "sub_ser", "cli");
alter table "topcon_sys"."fis_nf_servico_qrcode" enable row level security;
create table if not exists "topcon_sys"."fis_nf_servico_vinc_sefin" (
  "id" bigint,
  "nfse_principal_id" bigint,
  "chave_nfse_xml" text,
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint
);
create index if not exists "ix_fis_nf_servico_vinc_sefin" on "topcon_sys"."fis_nf_servico_vinc_sefin" ("id");
alter table "topcon_sys"."fis_nf_servico_vinc_sefin" enable row level security;
create table if not exists "topcon_sys"."fis_nffat" (
  "fis_nf_idnf" bigint,
  "tipodoc_cod" text,
  "fis_nffat_numtit" text,
  "fis_nffat_numparc" bigint,
  "operadora_cod" bigint,
  "fis_nffat_indemit" text,
  "fis_nffat_vlr" numeric,
  "fis_nffat_dtvencto" date
);
create index if not exists "ix_fis_nffat" on "topcon_sys"."fis_nffat" ("fis_nf_idnf", "tipodoc_cod", "fis_nffat_numtit", "fis_nffat_numparc");
alter table "topcon_sys"."fis_nffat" enable row level security;
create table if not exists "topcon_sys"."fis_nfimport" (
  "fis_nf_idnf" bigint,
  "fis_nfimport_tpdoc" text,
  "fis_nfimport_numdoc" text,
  "fis_nfimport_vlrbcpis" numeric,
  "fis_nfimport_vlrpis" numeric,
  "fis_nfimport_dtpagtopis" date,
  "fis_nfimport_vlrbccofins" numeric,
  "fis_nfimport_vlrcofins" numeric,
  "fis_nfimport_dtpagtocofins" date,
  "fis_nfimport_numacdraw" text,
  "fis_nfimport_localexec" text
);
create index if not exists "ix_fis_nfimport" on "topcon_sys"."fis_nfimport" ("fis_nf_idnf", "fis_nfimport_tpdoc", "fis_nfimport_numdoc");
alter table "topcon_sys"."fis_nfimport" enable row level security;
create table if not exists "topcon_sys"."fis_nfitem" (
  "fis_nf_idnf" bigint,
  "fis_nfitem_item" bigint,
  "produto_emp" bigint,
  "produto_cod" text,
  "fis_nfitem_qt" numeric,
  "fis_nfitem_vlritem" numeric,
  "fis_nfitem_vlritemserv" numeric,
  "fis_nfitem_vlrdesc" numeric,
  "fis_nfitem_vlrdespac" numeric,
  "fis_nfitem_vlrtotal" numeric,
  "operfiscal_cfop" bigint,
  "operfiscal_seq" bigint,
  "fix_cstipi_cod" text,
  "fis_nfitem_qttribipi" numeric,
  "fis_nfitem_vlripiunid" numeric,
  "fis_nfitem_vlrbcipi" numeric,
  "fis_nfitem_pctipi" numeric,
  "fis_nfitem_vlripi" numeric,
  "fis_nfitem_qtseloipi" bigint,
  "fis_nfitem_perapuripi" text,
  "fis_nfitem_vlrbcicms" numeric,
  "fis_nfitem_pcticms" numeric,
  "fis_nfitem_vlricms" numeric,
  "fis_nfitem_vlrbcreduz" numeric,
  "fis_nfitem_vlrbcicmsst" numeric,
  "fis_nfitem_pcticmsst" numeric,
  "fis_nfitem_vlricmsst" numeric,
  "cstpis_cod" text,
  "fis_nfitem_qttribpis" numeric,
  "fis_nfitem_pctpis" numeric,
  "fis_nfitem_vlrbcpis" numeric,
  "fis_nfitem_vlrpis" numeric,
  "cstcofins_cod" text,
  "fis_nfitem_qttribcofins" numeric,
  "fis_nfitem_pctcofins" numeric,
  "fis_nfitem_vlrbccofins" numeric,
  "fis_nfitem_vlrcofins" numeric,
  "fix_basecalccontrib_cod" bigint,
  "fix_tipocredcontrib_cod" bigint,
  "fix_codcontribapurada_cod" bigint,
  "fis_nfitem_vlrbciss" numeric,
  "fis_nfitem_pctiss" numeric,
  "fis_nfitem_vlriss" numeric,
  "fis_nfitem_vlrissret" numeric,
  "fis_nfitem_indtotal" text,
  "fis_nfitem_movfisica" text,
  "fis_nfitem_tpestoque" text,
  "fis_nfitem_qtestoque" numeric,
  "terceiroestq_cod" bigint,
  "fis_nfitem_numbomba" bigint,
  "fis_nfitem_numbico" bigint,
  "fis_nfitem_numtanque" bigint,
  "fis_nfitem_ctacontabil" text,
  "fis_nfitem_ccusto" text,
  "fis_nfitem_cancel" text,
  "fis_nfitem_descrcompl" text,
  "fis_nfitem_tipoarma" text,
  "fis_nfitem_numserarma" text,
  "transacao_cod" bigint,
  "undcompra_cod" text,
  "undestoque_cod" text,
  "fis_nfitem_csticms" text,
  "fis_nfitem_tottribecf" text,
  "fis_nfitem_medpreco" numeric,
  "fis_nfitem_medindbase" text,
  "fis_nfitem_meddtvalid" date,
  "fis_nfitem_meddtfabr" date,
  "fis_nfitem_medqt" numeric,
  "fis_nfitem_mednumlote" text,
  "fis_nfitem_vlrterc" numeric,
  "fis_nfitem_vlrseguro" numeric,
  "fis_nfitem_vlrfrete" numeric,
  "fis_nfitem_vlrabatnt" numeric
);
create index if not exists "ix_fis_nfitem" on "topcon_sys"."fis_nfitem" ("fis_nf_idnf", "fis_nfitem_item");
alter table "topcon_sys"."fis_nfitem" enable row level security;
create table if not exists "topcon_sys"."fis_nfmsgfis" (
  "fis_nf_idnf" bigint,
  "fis_mensfiscal_cod" bigint,
  "fis_nfmsgfis_descrcompl" text
);
create index if not exists "ix_fis_nfmsgfis" on "topcon_sys"."fis_nfmsgfis" ("fis_nf_idnf", "fis_mensfiscal_cod");
alter table "topcon_sys"."fis_nfmsgfis" enable row level security;
create table if not exists "topcon_sys"."fis_nfmsgfiscfref" (
  "fis_nf_idnf" bigint,
  "fis_mensfiscal_cod" bigint,
  "fis_nfmsgfiscfref_moddoc" text,
  "fis_nfmsgfiscfref_numfabecf" text,
  "fis_nfmsgfiscfref_numcxecf" bigint,
  "fis_nfmsgfiscfref_numdoc" bigint,
  "fis_nfmsgfiscfref_dtdoc" date
);
create index if not exists "ix_fis_nfmsgfiscfref" on "topcon_sys"."fis_nfmsgfiscfref" ("fis_nf_idnf", "fis_mensfiscal_cod", "fis_nfmsgfiscfref_moddoc", "fis_nfmsgfiscfref_numfabecf", "fis_nfmsgfiscfref_numcxecf", "fis_nfmsgfiscfref_numdoc");
alter table "topcon_sys"."fis_nfmsgfiscfref" enable row level security;
create table if not exists "topcon_sys"."fis_nfmsgfisdocarref" (
  "fis_nf_idnf" bigint,
  "fis_mensfiscal_cod" bigint,
  "fis_nfmsgfisdocarref_cod" text,
  "fis_nfmsgfisdocarref_uf" text,
  "fis_nfmsgfisdocarref_num" text,
  "fis_nfmsgfisdocarref_codaut" text,
  "fis_nfmsgfisdocarref_vlr" numeric,
  "fis_nfmsgfisdocarref_dtpagto" date,
  "fis_nfmsgfisdocarref_dtvecto" date
);
create index if not exists "ix_fis_nfmsgfisdocarref" on "topcon_sys"."fis_nfmsgfisdocarref" ("fis_nf_idnf", "fis_mensfiscal_cod", "fis_nfmsgfisdocarref_cod", "fis_nfmsgfisdocarref_uf", "fis_nfmsgfisdocarref_num");
alter table "topcon_sys"."fis_nfmsgfisdocarref" enable row level security;
create table if not exists "topcon_sys"."fis_nfmsgfisdocref" (
  "fis_nf_idnf" bigint,
  "fis_mensfiscal_cod" bigint,
  "fis_nfmsgfisdocref_moddoc" text,
  "fis_nfmsgfisdocref_serdoc" text,
  "fis_nfmsgfisdocref_subserdoc" text,
  "fis_nfmsgfisdocref_numdoc" bigint,
  "fis_nfmsgfisdocref_interv" bigint,
  "fis_nfmsgfisdocref_dtdoc" date,
  "fis_nfmsgfisdocref_indoper" text,
  "fis_nfmsgfisdocref_indemit" text
);
create index if not exists "ix_fis_nfmsgfisdocref" on "topcon_sys"."fis_nfmsgfisdocref" ("fis_nf_idnf", "fis_mensfiscal_cod", "fis_nfmsgfisdocref_moddoc", "fis_nfmsgfisdocref_serdoc", "fis_nfmsgfisdocref_subserdoc", "fis_nfmsgfisdocref_numdoc", "fis_nfmsgfisdocref_interv");
alter table "topcon_sys"."fis_nfmsgfisdocref" enable row level security;
create table if not exists "topcon_sys"."fis_nfmsgfisprocref" (
  "fis_nf_idnf" bigint,
  "fis_mensfiscal_cod" bigint,
  "fis_nfmsgfisprocref_num" text,
  "fis_nfmsgfisprocref_orig" text
);
create index if not exists "ix_fis_nfmsgfisprocref" on "topcon_sys"."fis_nfmsgfisprocref" ("fis_nf_idnf", "fis_mensfiscal_cod", "fis_nfmsgfisprocref_num");
alter table "topcon_sys"."fis_nfmsgfisprocref" enable row level security;
create table if not exists "topcon_sys"."fis_nfobsfisc" (
  "fis_nf_idnf" bigint,
  "fis_nfobsfisc_seq" bigint,
  "obsfiscal_cod" text,
  "fis_nfobsfisc_complemento" text,
  "ajdocfiscal_cod" text,
  "fis_nfobsfisc_complaj" text,
  "itemprodnf" text,
  "fis_nfobsfisc_vlrbcicms" numeric,
  "fis_nfobsfisc_pcticms" numeric,
  "fis_nfobsfisc_vlricms" numeric,
  "fis_nfobsfisc_vlroutrosicms" numeric
);
create index if not exists "ix_fis_nfobsfisc" on "topcon_sys"."fis_nfobsfisc" ("fis_nf_idnf", "fis_nfobsfisc_seq");
alter table "topcon_sys"."fis_nfobsfisc" enable row level security;
create table if not exists "topcon_sys"."fis_nfvol" (
  "fis_nf_idnf" bigint,
  "fis_nfvol_seq" bigint,
  "fis_nfvol_esq" text,
  "fis_nfvol_qtvol" bigint,
  "fis_nfvol_marca" text,
  "fis_nfvol_nrovol" text,
  "fis_nfvol_pesol" numeric,
  "fis_nfvol_pesob" numeric,
  "fis_nfvol_nrolacre" text
);
create index if not exists "ix_fis_nfvol" on "topcon_sys"."fis_nfvol" ("fis_nf_idnf", "fis_nfvol_seq");
alter table "topcon_sys"."fis_nfvol" enable row level security;
create table if not exists "topcon_sys"."fis_obs_fiscal" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_obs_fiscal" on "topcon_sys"."fis_obs_fiscal" ("cod");
alter table "topcon_sys"."fis_obs_fiscal" enable row level security;
create table if not exists "topcon_sys"."fis_obsfiscal" (
  "fis_obsfiscal_cod" text,
  "fis_obsfiscal_descr" text,
  "fix_ajdocfiscal_cod" text,
  "fis_obsfiscal_idcadast" text,
  "fis_obsfiscal_idatual" text
);
create index if not exists "ix_fis_obsfiscal" on "topcon_sys"."fis_obsfiscal" ("fis_obsfiscal_cod");
alter table "topcon_sys"."fis_obsfiscal" enable row level security;
create table if not exists "topcon_sys"."fis_oper_fiscal" (
  "cfop" bigint,
  "seq" bigint,
  "denom" text,
  "descr" text,
  "operacao" bigint,
  "vlr_fis_icms" bigint,
  "vlr_fis_ipi" bigint,
  "aliq_icms" numeric,
  "pct_rc_icms" numeric,
  "contr" text,
  "petr_ener" text,
  "mens_fiscal1" bigint,
  "mens_fiscal2" bigint,
  "icms_cst" text,
  "pis_cst" text,
  "pis_aliquota" numeric,
  "cofins_cst" text,
  "cofins_aliquota" numeric,
  "id_cadast" text,
  "id_atual" text,
  "atul_tp_estoque" bigint,
  "cfop_dev" bigint,
  "seq_dev" bigint,
  "tipo_operacao" bigint,
  "mod_bc_icms" bigint,
  "mod_bc_icms_st" bigint,
  "ipi_cst" text,
  "gera_financeiro" text,
  "form_base_icms" text,
  "obrig_nf_ref" bigint,
  "msg_fisc_nf_ref" bigint,
  "csosn" bigint,
  "csosn_nao_contrib" bigint,
  "icms_na" text
);
create index if not exists "ix_fis_oper_fiscal" on "topcon_sys"."fis_oper_fiscal" ("cfop", "seq");
alter table "topcon_sys"."fis_oper_fiscal" enable row level security;
create table if not exists "topcon_sys"."fis_redz" (
  "ger_empresa_cod" bigint,
  "fis_equipecf_num" bigint,
  "fis_redz_dt" date,
  "fis_redz_cro" bigint,
  "fis_redz_crz" bigint,
  "fis_redz_coo" bigint,
  "fis_redz_gtfinal" numeric,
  "fis_redz_vlrvendabruto" numeric,
  "fis_redz_idcadast" text,
  "fis_redz_idatual" text,
  "fis_loteimp_cod" bigint
);
create index if not exists "ix_fis_redz" on "topcon_sys"."fis_redz" ("ger_empresa_cod", "fis_equipecf_num", "fis_redz_dt");
alter table "topcon_sys"."fis_redz" enable row level security;
create table if not exists "topcon_sys"."fis_redztotal" (
  "ger_empresa_cod" bigint,
  "fis_equipecf_num" bigint,
  "fis_redz_dt" date,
  "fis_redztotal_codtotpar" text,
  "fis_redztotal_vlracumtot" numeric,
  "fis_redztotal_numtot" bigint,
  "fis_redztotal_descrnumtot" text
);
create index if not exists "ix_fis_redztotal" on "topcon_sys"."fis_redztotal" ("ger_empresa_cod", "fis_equipecf_num", "fis_redz_dt", "fis_redztotal_codtotpar");
alter table "topcon_sys"."fis_redztotal" enable row level security;
create table if not exists "topcon_sys"."fis_sit_trib" (
  "orig" text,
  "trib_icms" text,
  "descr_org" text,
  "descr_trib" text,
  "id_cadast" text,
  "id_atual" text,
  "codigo" text
);
create index if not exists "ix_fis_sit_trib" on "topcon_sys"."fis_sit_trib" ("codigo");
alter table "topcon_sys"."fis_sit_trib" enable row level security;
create table if not exists "topcon_sys"."fis_template_discrim" (
  "cod" bigint,
  "descr" text,
  "layout_discrimi" text,
  "layout_obs" text
);
create index if not exists "ix_fis_template_discrim" on "topcon_sys"."fis_template_discrim" ("cod");
alter table "topcon_sys"."fis_template_discrim" enable row level security;
create table if not exists "topcon_sys"."fis_transacao" (
  "cod" bigint,
  "descr" text,
  "at_estq" text,
  "tp_estq" bigint,
  "cesta_bas" text,
  "inc_z_franca" text,
  "cfop" bigint,
  "seq_cfop" bigint,
  "op_cp_comp" bigint,
  "op_cp_dev_comp" bigint,
  "op_cp_frete3" bigint,
  "op_cp_suframa" bigint,
  "op_cp_sefaz" bigint,
  "op_cr_venda" bigint,
  "op_cr_dev_venda" bigint,
  "vl_cont_cta_deb" bigint,
  "vl_cont_cta_cred" bigint,
  "vl_cont_hist" bigint,
  "vl_icms_cta_deb" bigint,
  "vl_icms_cta_cred" bigint,
  "vl_icms_hist" bigint,
  "vl_ipi_cta_deb" bigint,
  "vl_ipi_cta_cred" bigint,
  "vl_ipi_hist" bigint,
  "vl_sefaz_cta_deb" bigint,
  "vl_sefaz_cta_cred" bigint,
  "vl_sefaz_hist" bigint
);
create index if not exists "ix_fis_transacao" on "topcon_sys"."fis_transacao" ("cod");
alter table "topcon_sys"."fis_transacao" enable row level security;
create table if not exists "topcon_sys"."fis_trib_issqn" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_fis_trib_issqn" on "topcon_sys"."fis_trib_issqn" ("cod");
alter table "topcon_sys"."fis_trib_issqn" enable row level security;
create table if not exists "topcon_sys"."fis_vinc_nf" (
  "filial_compra" bigint,
  "interv_compra" bigint,
  "tp_doc_compra" bigint,
  "serie_compra" text,
  "num_nf_compra" bigint,
  "seq_nf_compra" bigint,
  "filial_transf" bigint,
  "interv_transf" bigint,
  "tp_doc_transf" bigint,
  "serie_transf" text,
  "num_nf_transf" bigint,
  "seq_nf_transf" bigint,
  "cancelada" text
);
create index if not exists "ix_fis_vinc_nf" on "topcon_sys"."fis_vinc_nf" ("filial_compra", "interv_compra", "tp_doc_compra", "serie_compra", "num_nf_compra", "seq_nf_compra", "filial_transf", "interv_transf", "tp_doc_transf", "serie_transf", "num_nf_transf", "seq_nf_transf");
alter table "topcon_sys"."fis_vinc_nf" enable row level security;
create table if not exists "topcon_sys"."fis_vinc_nfe_ref" (
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "serie" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "filial_ref" bigint,
  "interv_ref" bigint,
  "tp_doc_ref" bigint,
  "serie_ref" text,
  "num_nf_ref" bigint,
  "seq_nf_ref" bigint,
  "chave_nfe_ref" text
);
create index if not exists "ix_fis_vinc_nfe_ref" on "topcon_sys"."fis_vinc_nfe_ref" ("filial", "interv", "tp_doc", "serie", "num_nf", "seq_nf", "filial_ref", "interv_ref", "tp_doc_ref", "serie_ref", "num_nf_ref", "seq_nf_ref", "chave_nfe_ref");
alter table "topcon_sys"."fis_vinc_nfe_ref" enable row level security;
create table if not exists "topcon_sys"."fis_vinc_pre_nf" (
  "lote_pre_nota" bigint,
  "num_pre_nota" bigint,
  "cod_validacao" text,
  "filial" bigint,
  "cli" bigint,
  "tp_doc" bigint,
  "num_nf" bigint,
  "ser" text,
  "sub_ser" bigint
);
create index if not exists "ix_fis_vinc_pre_nf" on "topcon_sys"."fis_vinc_pre_nf" ("lote_pre_nota", "num_pre_nota");
alter table "topcon_sys"."fis_vinc_pre_nf" enable row level security;
create table if not exists "topcon_sys"."fis_xml_envio" (
  "filial" bigint,
  "nro_lote_nfse" text,
  "xml_envio_nfse" text
);
alter table "topcon_sys"."fis_xml_envio" enable row level security;
create table if not exists "topcon_sys"."fis_xml_prazo_lanc" (
  "filial" bigint,
  "interv" bigint,
  "dias_dif_emi_op" bigint,
  "dias_lim_inc_nf" bigint
);
create index if not exists "ix_fis_xml_prazo_lanc" on "topcon_sys"."fis_xml_prazo_lanc" ("filial", "interv");
alter table "topcon_sys"."fis_xml_prazo_lanc" enable row level security;
create table if not exists "topcon_sys"."fis_xml_retorno" (
  "filial" bigint,
  "nro_lote_nfse" text,
  "xml_retorn_nfse" text
);
alter table "topcon_sys"."fis_xml_retorno" enable row level security;
create table if not exists "topcon_sys"."ger_anex_img" (
  "aplic" text,
  "num_prog" bigint,
  "chave" text,
  "seq" bigint,
  "caminho_img" text
);
create index if not exists "ix_ger_anex_img" on "topcon_sys"."ger_anex_img" ("aplic", "num_prog", "chave", "seq");
alter table "topcon_sys"."ger_anex_img" enable row level security;
create table if not exists "topcon_sys"."ger_atividade" (
  "codigo" bigint,
  "descricao" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_atividade" on "topcon_sys"."ger_atividade" ("codigo");
alter table "topcon_sys"."ger_atividade" enable row level security;
create table if not exists "topcon_sys"."ger_banco" (
  "emp" bigint,
  "bco" bigint,
  "nome" text,
  "razao" text,
  "bco_of" bigint,
  "num_ag" bigint,
  "dv_ag" text,
  "num_cta" bigint,
  "dv_cta" text,
  "cta_cont" text,
  "flu_finan" text,
  "sal_atual" numeric,
  "sal_umf" numeric,
  "id_cadast" text,
  "id_atual" text,
  "leiaute_imp_che" text,
  "sdo_conc_mf" numeric,
  "prx_num_rem_cap" bigint,
  "emp_proprietaria" bigint,
  "num_ctr_pag_ele" text,
  "dt_ult_conc" date,
  "_port" bigint,
  "unid_negocio" bigint,
  "prazo_conc_banc" bigint,
  "dt_prorrog_conc" date,
  "cta_cheque" text,
  "opt_pag_eletr" bigint,
  "num_ag_bco_corr" bigint,
  "dv_ag_bco_corr" text,
  "num_cta_bco_cor" bigint,
  "dv_cta_bco_corr" text,
  "cod_compromisso" bigint,
  "par_transmissao" text,
  "oper_conta" bigint,
  "tp_amb_pag_elet" text,
  "cod_inst_mov" text,
  "ocor_tit_desc" text,
  "tipo_conta" text,
  "ocor_ret_cart" text,
  "tipo_arredondamento_perc" bigint,
  "cedente" bigint,
  "envia_emp_propriet" text,
  "normaliza_saldo" bigint,
  "inativo" text
);
create index if not exists "ix_ger_banco" on "topcon_sys"."ger_banco" ("emp", "bco");
alter table "topcon_sys"."ger_banco" enable row level security;
create table if not exists "topcon_sys"."ger_banco_ispb" (
  "id" bigint,
  "bco_of" bigint,
  "bco_ispb" bigint
);
create index if not exists "ix_ger_banco_ispb" on "topcon_sys"."ger_banco_ispb" ("id");
alter table "topcon_sys"."ger_banco_ispb" enable row level security;
create table if not exists "topcon_sys"."ger_banco_nn_usinas" (
  "port" bigint,
  "usina" bigint,
  "prox_nosso_num" bigint
);
create index if not exists "ix_ger_banco_nn_usinas" on "topcon_sys"."ger_banco_nn_usinas" ("port", "usina");
alter table "topcon_sys"."ger_banco_nn_usinas" enable row level security;
create table if not exists "topcon_sys"."ger_banco_tp_prod" (
  "cod_bandeira" bigint,
  "emp" bigint,
  "bco" bigint,
  "cod_oper" bigint,
  "cod_tp_prod" bigint
);
create index if not exists "ix_ger_banco_tp_prod" on "topcon_sys"."ger_banco_tp_prod" ("cod_bandeira", "emp", "bco", "cod_oper", "cod_tp_prod");
alter table "topcon_sys"."ger_banco_tp_prod" enable row level security;
create table if not exists "topcon_sys"."ger_bancos_segunda_via" (
  "cod_banco" bigint,
  "link" text
);
create index if not exists "ix_ger_bancos_segunda_via" on "topcon_sys"."ger_bancos_segunda_via" ("cod_banco");
alter table "topcon_sys"."ger_bancos_segunda_via" enable row level security;
create table if not exists "topcon_sys"."ger_bloq_programa" (
  "num_prog" bigint,
  "usuario" text,
  "maquina" text,
  "data_hora" timestamp,
  "id_conexao" text
);
create index if not exists "ix_ger_bloq_programa" on "topcon_sys"."ger_bloq_programa" ("num_prog");
alter table "topcon_sys"."ger_bloq_programa" enable row level security;
create table if not exists "topcon_sys"."ger_bloq_programa_id_cnx" (
  "num_prog" bigint,
  "usuario" text,
  "maquina" text,
  "data_hora" timestamp,
  "id_conexao" text
);
create index if not exists "ix_ger_bloq_programa_id_cnx" on "topcon_sys"."ger_bloq_programa_id_cnx" ("num_prog", "id_conexao");
alter table "topcon_sys"."ger_bloq_programa_id_cnx" enable row level security;
create table if not exists "topcon_sys"."ger_bombacomb" (
  "ger_empresa_cod" bigint,
  "ger_bombacomb_num" bigint,
  "ger_bombacomb_serie" text,
  "ger_bombacomb_fabr" text,
  "ger_bombacomb_mod" text,
  "ger_bombacomb_tpmed" text,
  "ger_bombacomb_idcadast" text,
  "ger_bombacomb_idatual" text
);
create index if not exists "ix_ger_bombacomb" on "topcon_sys"."ger_bombacomb" ("ger_empresa_cod", "ger_bombacomb_num");
alter table "topcon_sys"."ger_bombacomb" enable row level security;
create table if not exists "topcon_sys"."ger_bombacombbico" (
  "ger_empresa_cod" bigint,
  "ger_bombacomb_num" bigint,
  "ger_bombacombbico_num" bigint
);
create index if not exists "ix_ger_bombacombbico" on "topcon_sys"."ger_bombacombbico" ("ger_empresa_cod", "ger_bombacomb_num", "ger_bombacombbico_num");
alter table "topcon_sys"."ger_bombacombbico" enable row level security;
create table if not exists "topcon_sys"."ger_bombacomblacre" (
  "ger_empresa_cod" bigint,
  "ger_bombacomb_num" bigint,
  "ger_bombacomblacre_num" text,
  "ger_bombacomblacre_data" date,
  "ger_bombacomblacre_idcadast" text,
  "ger_bombacomblacre_idatual" text
);
create index if not exists "ix_ger_bombacomblacre" on "topcon_sys"."ger_bombacomblacre" ("ger_empresa_cod", "ger_bombacomb_num", "ger_bombacomblacre_num");
alter table "topcon_sys"."ger_bombacomblacre" enable row level security;
create table if not exists "topcon_sys"."ger_cartao_operadora" (
  "codigo" bigint,
  "nome" text
);
create index if not exists "ix_ger_cartao_operadora" on "topcon_sys"."ger_cartao_operadora" ("codigo");
alter table "topcon_sys"."ger_cartao_operadora" enable row level security;
create table if not exists "topcon_sys"."ger_cartao_tp_prod" (
  "codigo" bigint,
  "cod_oper" bigint,
  "descr" text
);
create index if not exists "ix_ger_cartao_tp_prod" on "topcon_sys"."ger_cartao_tp_prod" ("codigo", "cod_oper");
alter table "topcon_sys"."ger_cartao_tp_prod" enable row level security;
create table if not exists "topcon_sys"."ger_cep" (
  "logradouro" text,
  "estado" text,
  "bairro" text,
  "cidade" text,
  "tipo" text,
  "cep" text,
  "tipon" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_cep" on "topcon_sys"."ger_cep" ("cep");
alter table "topcon_sys"."ger_cep" enable row level security;
create table if not exists "topcon_sys"."ger_cliente" (
  "ger_pessoacli_cod" bigint,
  "ger_cliente_consfinal" text,
  "ger_cliente_naturretencao" bigint,
  "ger_cliente_datacad" date,
  "ger_cliente_dataalt" date,
  "ger_cliente_idcadast" text,
  "ger_cliente_idatual" text,
  "ctb_plcontas_cod" text
);
create index if not exists "ix_ger_cliente" on "topcon_sys"."ger_cliente" ("ger_pessoacli_cod");
alter table "topcon_sys"."ger_cliente" enable row level security;
create table if not exists "topcon_sys"."ger_cond_pag" (
  "cod" bigint,
  "descr" text,
  "base_nf" text,
  "dia_decend_fixo" text,
  "dia_semana_fixo" bigint,
  "qtde_parcelas" bigint,
  "dias_1a_parc" bigint,
  "dias_2a_parc" bigint,
  "dias_3a_parc" bigint,
  "dias_4a_parc" bigint,
  "dias_5a_parc" bigint,
  "dias_6a_parc" bigint,
  "dias_7a_parc" bigint,
  "dias_8a_parc" bigint,
  "dias_9a_parc" bigint,
  "dias_10a_parc" bigint,
  "dias_11a_parc" bigint,
  "dias_12a_parc" bigint,
  "id_cadast" text,
  "id_atual" text,
  "descrc" text,
  "tipo_cobranca" bigint,
  "tipos_de_cobran" text,
  "analise_fraude" text,
  "ativo" text,
  "mes_30_dias_fix" text,
  "dia_util_vcto" bigint,
  "iss_ret_1a_parc" text,
  "cod_integracao" text,
  "media_dias" numeric
);
create index if not exists "ix_ger_cond_pag" on "topcon_sys"."ger_cond_pag" ("cod");
alter table "topcon_sys"."ger_cond_pag" enable row level security;
create table if not exists "topcon_sys"."ger_cond_pag_parc" (
  "cond_pag" bigint,
  "dias_parc" bigint,
  "pct_parc" numeric
);
create index if not exists "ix_ger_cond_pag_parc" on "topcon_sys"."ger_cond_pag_parc" ("cond_pag", "dias_parc");
alter table "topcon_sys"."ger_cond_pag_parc" enable row level security;
create table if not exists "topcon_sys"."ger_consumo_estoque_integracao_terceiros" (
  "id" bigint,
  "filial" bigint,
  "interv" bigint,
  "tp_doc" bigint,
  "ser" text,
  "num_nf" bigint,
  "seq_nf" bigint,
  "num_seq_item_nf" bigint,
  "mercadoria" text,
  "qtd_estoque" numeric,
  "qtd_estoque_anterior" numeric,
  "evento" text,
  "retorno" text,
  "mensagem_retorno" text,
  "sucesso_requisicao" bigint,
  "arquivo_enviado" text,
  "data_hora_insercao" timestamp,
  "data_hora_envio" timestamp,
  "data_hora_retorno" timestamp
);
create index if not exists "ix_ger_consumo_estoque_integracao_terceiros" on "topcon_sys"."ger_consumo_estoque_integracao_terceiros" ("id");
alter table "topcon_sys"."ger_consumo_estoque_integracao_terceiros" enable row level security;
create table if not exists "topcon_sys"."ger_contador" (
  "emp" bigint,
  "nome" text,
  "cnpj_cpf" text,
  "no_crc" text,
  "uf_crc" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "ddd" bigint,
  "tel" bigint,
  "fax" bigint,
  "email" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_contador" on "topcon_sys"."ger_contador" ("emp");
alter table "topcon_sys"."ger_contador" enable row level security;
create table if not exists "topcon_sys"."ger_contato" (
  "interv" bigint,
  "seq" bigint,
  "nome" text,
  "seq_local" bigint,
  "nome_contato" text,
  "funcao" bigint,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "mun" bigint,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "celular" bigint,
  "email" text,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "fax" bigint
);
create index if not exists "ix_ger_contato" on "topcon_sys"."ger_contato" ("interv", "seq");
alter table "topcon_sys"."ger_contato" enable row level security;
create table if not exists "topcon_sys"."ger_contato_depart" (
  "interv" bigint,
  "seq" bigint,
  "departamento" bigint
);
create index if not exists "ix_ger_contato_depart" on "topcon_sys"."ger_contato_depart" ("interv", "seq", "departamento");
alter table "topcon_sys"."ger_contato_depart" enable row level security;
create table if not exists "topcon_sys"."ger_deduz_iss" (
  "cod_insumo" text,
  "cod_forn" bigint,
  "cod_mun" bigint,
  "deduz_iss" text
);
create index if not exists "ix_ger_deduz_iss" on "topcon_sys"."ger_deduz_iss" ("cod_insumo", "cod_forn", "cod_mun");
alter table "topcon_sys"."ger_deduz_iss" enable row level security;
create table if not exists "topcon_sys"."ger_diverso" (
  "aplic" text,
  "prog" bigint,
  "campo" text,
  "cod" text,
  "descr" text
);
create index if not exists "ix_ger_diverso" on "topcon_sys"."ger_diverso" ("aplic", "prog", "campo", "cod");
alter table "topcon_sys"."ger_diverso" enable row level security;
create table if not exists "topcon_sys"."ger_emp_parm" (
  "ger_emp_parm_cod" bigint,
  "ger_emp_parm_ultnsu" bigint
);
create index if not exists "ix_ger_emp_parm" on "topcon_sys"."ger_emp_parm" ("ger_emp_parm_cod");
alter table "topcon_sys"."ger_emp_parm" enable row level security;
create table if not exists "topcon_sys"."ger_empresa" (
  "emp" bigint,
  "nome" text,
  "razao" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "cnpj_cpf" text,
  "ccm" text,
  "cei" text,
  "caixa_postal" bigint,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "fax" bigint,
  "email" text,
  "cpf_responsavel" text,
  "rg_responsavel" text,
  "expedidor_rg" text,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "ie" text,
  "junta_cml_cart" text,
  "num_reg" text,
  "dt_reg" date,
  "repr" text,
  "cargo" text,
  "pct_pis" numeric,
  "pct_cofins" numeric,
  "cod_com_banco" bigint,
  "engenheiro_resp" text,
  "tipo_atividade" bigint,
  "url_servidor" text,
  "emp_int_contab" text,
  "opt_simpl_nac" text,
  "dt_ad_simpl_nac" date,
  "aliq_simpl_nac" numeric,
  "regime_trib" text
);
create index if not exists "ix_ger_empresa" on "topcon_sys"."ger_empresa" ("emp");
alter table "topcon_sys"."ger_empresa" enable row level security;
create table if not exists "topcon_sys"."ger_empresaie" (
  "ger_empresa_cod" bigint,
  "uf" text,
  "ger_empresaie_ie" text
);
create index if not exists "ix_ger_empresaie" on "topcon_sys"."ger_empresaie" ("ger_empresa_cod", "uf");
alter table "topcon_sys"."ger_empresaie" enable row level security;
create table if not exists "topcon_sys"."ger_endereco_geo" (
  "hash_endereco" text,
  "cep" text,
  "logradouro" text,
  "numero" text,
  "bairro" text,
  "municipio" text,
  "uf" text,
  "latitude" numeric,
  "longitude" numeric,
  "precisao" text,
  "provider" text,
  "raw_response" text,
  "data_consulta" timestamp
);
create index if not exists "ix_ger_endereco_geo" on "topcon_sys"."ger_endereco_geo" ("hash_endereco");
alter table "topcon_sys"."ger_endereco_geo" enable row level security;
create table if not exists "topcon_sys"."ger_estado" (
  "sigla" text,
  "nome" text,
  "codigo_uf" bigint
);
create index if not exists "ix_ger_estado" on "topcon_sys"."ger_estado" ("sigla");
alter table "topcon_sys"."ger_estado" enable row level security;
create table if not exists "topcon_sys"."ger_fabricante" (
  "cod" bigint,
  "nome" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_fabricante" on "topcon_sys"."ger_fabricante" ("cod");
alter table "topcon_sys"."ger_fabricante" enable row level security;
create table if not exists "topcon_sys"."ger_feriado" (
  "municipio" bigint,
  "data" date,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_feriado" on "topcon_sys"."ger_feriado" ("data", "municipio");
alter table "topcon_sys"."ger_feriado" enable row level security;
create table if not exists "topcon_sys"."ger_forn" (
  "ger_pessoaforn_cod" bigint,
  "ctb_plcontas_cod" text,
  "ger_forn_idcadast" text,
  "ger_forn_idatual" text
);
create index if not exists "ix_ger_forn" on "topcon_sys"."ger_forn" ("ger_pessoaforn_cod");
alter table "topcon_sys"."ger_forn" enable row level security;
create table if not exists "topcon_sys"."ger_geral" (
  "cod" bigint,
  "descr" text,
  "descr_reduzida" text,
  "id_cadast" text,
  "id_atual" text,
  "fixo" text,
  "external_id" text
);
create index if not exists "ix_ger_geral" on "topcon_sys"."ger_geral" ("cod");
alter table "topcon_sys"."ger_geral" enable row level security;
create table if not exists "topcon_sys"."ger_geral_captacao" (
  "cod" bigint,
  "ativo" text,
  "captacao_tipo_indicador" bigint
);
create index if not exists "ix_ger_geral_captacao" on "topcon_sys"."ger_geral_captacao" ("cod");
alter table "topcon_sys"."ger_geral_captacao" enable row level security;
create table if not exists "topcon_sys"."ger_geral_tp" (
  "cod" bigint,
  "descricao" text
);
create index if not exists "ix_ger_geral_tp" on "topcon_sys"."ger_geral_tp" ("cod");
alter table "topcon_sys"."ger_geral_tp" enable row level security;
create table if not exists "topcon_sys"."ger_grupo_economico" (
  "codigo" bigint,
  "descricao" text,
  "limite_cred" numeric,
  "lim_cred_val" date,
  "bloq" bigint,
  "obs_bloq" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_grupo_economico" on "topcon_sys"."ger_grupo_economico" ("codigo");
alter table "topcon_sys"."ger_grupo_economico" enable row level security;
create table if not exists "topcon_sys"."ger_grupo_interv" (
  "cod" bigint,
  "nome" text
);
create index if not exists "ix_ger_grupo_interv" on "topcon_sys"."ger_grupo_interv" ("cod");
alter table "topcon_sys"."ger_grupo_interv" enable row level security;
create table if not exists "topcon_sys"."ger_hist_interv" (
  "interv" bigint,
  "seq" bigint,
  "dt" date,
  "hora" text,
  "descr" text,
  "data_prev_ret" date,
  "hora_prev_ret" text,
  "data_retorno" date,
  "hora_retorno" text,
  "id_cadast" text,
  "id_atual" text,
  "vinculo" text,
  "emp" bigint,
  "tp_doc" bigint,
  "ser_doc" text,
  "num_doc" bigint,
  "seq_doc" text,
  "cod_banco_band" bigint,
  "num_agencia" bigint,
  "num_conta" bigint,
  "dv_conta" bigint,
  "desdo" bigint,
  "forn_retido" bigint
);
create index if not exists "ix_ger_hist_interv" on "topcon_sys"."ger_hist_interv" ("interv", "seq");
alter table "topcon_sys"."ger_hist_interv" enable row level security;
create table if not exists "topcon_sys"."ger_imp_tribut_reforma" (
  "id_imp" bigint,
  "tp_imp" text,
  "uf_dest" text,
  "cod_trans" bigint,
  "cod_trans_seq" bigint,
  "cod_mun_ibge_dest" bigint,
  "dt_ini_vigencia" date,
  "dt_fim_vigencia" date,
  "cst" text,
  "clas_trib" text,
  "obs" text,
  "dt_inclusao" timestamp,
  "dt_alteracao" timestamp,
  "id_cadast" text,
  "id_atual" text,
  "aliq" numeric,
  "aliq_municipio" numeric,
  "aliq_uf" numeric,
  "ativo" bigint
);
create index if not exists "ix_ger_imp_tribut_reforma" on "topcon_sys"."ger_imp_tribut_reforma" ("id_imp", "tp_imp", "cod_trans", "cod_trans_seq", "uf_dest", "cod_mun_ibge_dest", "dt_ini_vigencia", "dt_fim_vigencia");
alter table "topcon_sys"."ger_imp_tribut_reforma" enable row level security;
create table if not exists "topcon_sys"."ger_impressora" (
  "cod" bigint,
  "nome_impressora" text,
  "nome_compar" text,
  "padrao" bigint
);
create index if not exists "ix_ger_impressora" on "topcon_sys"."ger_impressora" ("cod");
alter table "topcon_sys"."ger_impressora" enable row level security;
create table if not exists "topcon_sys"."ger_interv" (
  "cod" bigint,
  "nome" text,
  "razao" text,
  "cli" text,
  "forn" text,
  "transpo" text,
  "prest_serv" text,
  "org_publ" text,
  "outro" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "cod_munic" bigint,
  "cnpj_cpf" text,
  "ie" text,
  "rg" text,
  "org_uf_emi" text,
  "ccm" text,
  "cei" text,
  "ddd" bigint,
  "tel" bigint,
  "ramal" bigint,
  "ddd_celular" bigint,
  "celular" bigint,
  "ddd_fax" bigint,
  "fax" bigint,
  "email" text,
  "email_cobranca" text,
  "contato" text,
  "ativ" bigint,
  "tp_cobranca" bigint,
  "bloq" bigint,
  "vend" bigint,
  "limite_cred" numeric,
  "sal_atual" numeric,
  "maior_sal" numeric,
  "dt_maior_sal" date,
  "pct_desco" numeric,
  "dt_ult_op" date,
  "cond_pag" bigint,
  "obs" text,
  "in86" text,
  "ctb_cta_contab" text,
  "id_cadast" text,
  "id_atual" text,
  "bombista" text,
  "forn_mp" text,
  "regiao" bigint,
  "rot" bigint,
  "seq_rot" bigint,
  "transp" bigint,
  "tp_cliente" text,
  "ret_iss" text,
  "local_entrega" text,
  "especificacao" text,
  "nome_mae" text,
  "conjuge" text,
  "id_aprov_iss" text,
  "port_cobranca" bigint,
  "func" text,
  "mala_direta" text,
  "site" text,
  "aprov_eng" text,
  "profissao" text,
  "ddd_com" bigint,
  "tel_com" bigint,
  "emp_trabalho" text,
  "lim_cred_val" date,
  "obs_bloq" text,
  "tp_cob_cap" bigint,
  "tx_bomb_c_conc" bigint,
  "simpl_nacional" text,
  "ret_inss" text,
  "contrib_icms" bigint,
  "fat_bomb_c_conc" bigint,
  "forma_faturamento" bigint,
  "inativado" text,
  "external_id" text,
  "tin" text,
  "ret_irrf" text,
  "ret_cofins" text,
  "ret_csll" text,
  "ret_pis" text,
  "id_tech" text,
  "p_red_gov" numeric,
  "tp_ente_gov" bigint,
  "tp_oper_gov" bigint,
  "ind_final" text,
  "atualizado_em" timestamp,
  "grupo_economico" bigint,
  "situacao_cadastral_cnpj" text,
  "dt_consulta_receita" timestamp
);
create index if not exists "ix_ger_interv" on "topcon_sys"."ger_interv" ("cod");
alter table "topcon_sys"."ger_interv" enable row level security;
create table if not exists "topcon_sys"."ger_interv_anex" (
  "interv" bigint,
  "descricao" text,
  "nome" text,
  "usuario" text,
  "data" date,
  "data_hora" timestamp,
  "ano_chamada" bigint,
  "num_chamada" bigint
);
create index if not exists "ix_ger_interv_anex" on "topcon_sys"."ger_interv_anex" ("interv", "nome", "data_hora");
alter table "topcon_sys"."ger_interv_anex" enable row level security;
create table if not exists "topcon_sys"."ger_interv_atividade" (
  "interv" bigint,
  "atividade" bigint,
  "id_cadast" text
);
create index if not exists "ix_ger_interv_atividade" on "topcon_sys"."ger_interv_atividade" ("interv", "atividade");
alter table "topcon_sys"."ger_interv_atividade" enable row level security;
create table if not exists "topcon_sys"."ger_interv_ciclo_fat" (
  "interv" bigint,
  "seq" bigint,
  "dia_inicio" bigint,
  "dia_final" bigint
);
create index if not exists "ix_ger_interv_ciclo_fat" on "topcon_sys"."ger_interv_ciclo_fat" ("interv", "seq");
alter table "topcon_sys"."ger_interv_ciclo_fat" enable row level security;
create table if not exists "topcon_sys"."ger_interv_conta" (
  "interv" bigint,
  "cod_conta" bigint,
  "bco_oficial" bigint,
  "num_ag" text,
  "dv_ag" text,
  "num_cta" text,
  "dv_cta" text,
  "sacador" text,
  "cnpj_cpf" text,
  "rg" text,
  "tipo_conta" text,
  "id_cadast" text,
  "id_atual" text,
  "ativo" text
);
create index if not exists "ix_ger_interv_conta" on "topcon_sys"."ger_interv_conta" ("interv", "cod_conta");
alter table "topcon_sys"."ger_interv_conta" enable row level security;
create table if not exists "topcon_sys"."ger_interv_cta_contb" (
  "cod" bigint,
  "emp" bigint,
  "ctb_cta_contab" text,
  "tipo_cliente" text
);
create index if not exists "ix_ger_interv_cta_contb" on "topcon_sys"."ger_interv_cta_contb" ("cod", "emp", "tipo_cliente");
alter table "topcon_sys"."ger_interv_cta_contb" enable row level security;
create table if not exists "topcon_sys"."ger_interv_inf_adic" (
  "interv_cod" bigint,
  "pct_juros_cap" numeric,
  "pct_multa_cap" numeric,
  "tp_corr_monet" bigint
);
create index if not exists "ix_ger_interv_inf_adic" on "topcon_sys"."ger_interv_inf_adic" ("interv_cod");
alter table "topcon_sys"."ger_interv_inf_adic" enable row level security;
create table if not exists "topcon_sys"."ger_interv_trib_mun" (
  "interv" bigint,
  "pct_iss" numeric,
  "pct_iss_retido" numeric,
  "base_calc_iss" bigint,
  "pct_servico" numeric,
  "pct_ded_material" numeric,
  "iss_bomba" text,
  "taxas_trib_integralmente" text
);
create index if not exists "ix_ger_interv_trib_mun" on "topcon_sys"."ger_interv_trib_mun" ("interv");
alter table "topcon_sys"."ger_interv_trib_mun" enable row level security;
create table if not exists "topcon_sys"."ger_interv_trib_reg" (
  "interv" bigint,
  "cod_oficial" bigint,
  "cod_tributacao" bigint,
  "opt_simples_nac" text
);
create index if not exists "ix_ger_interv_trib_reg" on "topcon_sys"."ger_interv_trib_reg" ("interv", "cod_oficial");
alter table "topcon_sys"."ger_interv_trib_reg" enable row level security;
create table if not exists "topcon_sys"."ger_interv_veiculo" (
  "interv" bigint,
  "placa_veiculo" text,
  "seq" bigint,
  "qtde_cub" bigint,
  "comprimento" bigint,
  "largura" bigint,
  "ativo" text
);
create index if not exists "ix_ger_interv_veiculo" on "topcon_sys"."ger_interv_veiculo" ("interv", "placa_veiculo", "seq");
alter table "topcon_sys"."ger_interv_veiculo" enable row level security;
create table if not exists "topcon_sys"."ger_limite_credito_integracao_terceiros" (
  "interv" bigint,
  "usina" bigint,
  "ano_contrato" bigint,
  "no_contrato" bigint,
  "seq_prog" bigint,
  "saldo_limite_credito" numeric,
  "inadimplencia" text,
  "resultado_analise" text,
  "mensagem_retorno" text,
  "data_hora_retorno" timestamp,
  "sucesso_na_requisicao" bigint
);
create index if not exists "ix_ger_limite_credito_integracao_terceiros" on "topcon_sys"."ger_limite_credito_integracao_terceiros" ("interv", "usina", "ano_contrato", "no_contrato", "seq_prog", "data_hora_retorno");
alter table "topcon_sys"."ger_limite_credito_integracao_terceiros" enable row level security;
create table if not exists "topcon_sys"."ger_local" (
  "interv" bigint,
  "seq" bigint,
  "nome" text,
  "razao" text,
  "cep" text,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "cnpj_cpf" text,
  "rg" text,
  "emissor" text,
  "ie" text,
  "ccm" text,
  "cei" text,
  "obs" text,
  "loc_cobr" text,
  "loc_entrega" text,
  "loc_fatur" text,
  "id_cadast" text,
  "id_atual" text,
  "email" text,
  "ret_iss" text,
  "ind_final" text
);
create index if not exists "ix_ger_local" on "topcon_sys"."ger_local" ("interv", "seq");
alter table "topcon_sys"."ger_local" enable row level security;
create table if not exists "topcon_sys"."ger_logotipo" (
  "emp" bigint,
  "caminho" text
);
create index if not exists "ix_ger_logotipo" on "topcon_sys"."ger_logotipo" ("emp");
alter table "topcon_sys"."ger_logotipo" enable row level security;
create table if not exists "topcon_sys"."ger_logotipo_filial" (
  "filial" bigint
);
create index if not exists "ix_ger_logotipo_filial" on "topcon_sys"."ger_logotipo_filial" ("filial");
alter table "topcon_sys"."ger_logotipo_filial" enable row level security;
create table if not exists "topcon_sys"."ger_mot_bloqueio" (
  "cod" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_mot_bloqueio" on "topcon_sys"."ger_mot_bloqueio" ("cod");
alter table "topcon_sys"."ger_mot_bloqueio" enable row level security;
create table if not exists "topcon_sys"."ger_munic" (
  "ger_munic_codoficial" bigint,
  "ger_munic_iss" bigint,
  "ger_munic_pctiss" numeric,
  "ger_munic_basecalciss" bigint,
  "ger_munic_pctservico" numeric,
  "ger_munic_issretido" text,
  "ger_munic_idcadast" text,
  "ger_munic_idatual" text
);
create index if not exists "ix_ger_munic" on "topcon_sys"."ger_munic" ("ger_munic_codoficial");
alter table "topcon_sys"."ger_munic" enable row level security;
create table if not exists "topcon_sys"."ger_municipio" (
  "cod" bigint,
  "mun" text,
  "uf" text,
  "nome_reduzido" text,
  "iss" bigint,
  "pct_iss" numeric,
  "base_calc_iss" bigint,
  "pct_iss_retido" numeric,
  "pct_servico" numeric,
  "iss_retido" text,
  "oficial" bigint,
  "interv" bigint,
  "pais" bigint,
  "oficial_siafi" bigint,
  "id_cadast" text,
  "id_atual" text,
  "iss_bomba" text,
  "msg_fis_nfes" text,
  "cod_integracao" text,
  "pct_ded_material" numeric,
  "dem_serv_trib_integralmente" text,
  "taxas_trib_integralmente" text,
  "vlr_min_retencao_iss" numeric,
  "tipo_do_desconto" bigint,
  "deduz_desconto_da_bc_iss" text,
  "cod_oficial_goiania" bigint,
  "cod_trib_mun_nacional" text,
  "ident_benef_fiscal_nacional" text,
  "pct_benef_fiscal_nacional" numeric,
  "tipo_deducao_sefin" bigint,
  "tipo_benef_fiscal" bigint,
  "cod_trib_mun_nacional_completo" text,
  "trib_mun_nacional_completo" text,
  "convenio_municipio" text
);
create index if not exists "ix_ger_municipio" on "topcon_sys"."ger_municipio" ("cod");
alter table "topcon_sys"."ger_municipio" enable row level security;
create table if not exists "topcon_sys"."ger_municipio_crav" (
  "cod" bigint,
  "mun" text,
  "uf" text
);
create index if not exists "ix_ger_municipio_crav" on "topcon_sys"."ger_municipio_crav" ("cod");
alter table "topcon_sys"."ger_municipio_crav" enable row level security;
create table if not exists "topcon_sys"."ger_municipio_nfsenet" (
  "cod" bigint,
  "mun" text,
  "uf" text
);
create index if not exists "ix_ger_municipio_nfsenet" on "topcon_sys"."ger_municipio_nfsenet" ("cod");
alter table "topcon_sys"."ger_municipio_nfsenet" enable row level security;
create table if not exists "topcon_sys"."ger_municipio_trib" (
  "cod_oficial" bigint,
  "cod_trib" bigint,
  "descr" text
);
create index if not exists "ix_ger_municipio_trib" on "topcon_sys"."ger_municipio_trib" ("cod_oficial", "cod_trib");
alter table "topcon_sys"."ger_municipio_trib" enable row level security;
create table if not exists "topcon_sys"."ger_nat_oper_publica" (
  "codigo" bigint,
  "oficial" bigint,
  "nat_operacao" bigint,
  "descricao" text
);
create index if not exists "ix_ger_nat_oper_publica" on "topcon_sys"."ger_nat_oper_publica" ("codigo", "oficial");
alter table "topcon_sys"."ger_nat_oper_publica" enable row level security;
create table if not exists "topcon_sys"."ger_parametro" (
  "grupo" text,
  "chave" text,
  "valor" text
);
create index if not exists "ix_ger_parametro" on "topcon_sys"."ger_parametro" ("grupo", "chave");
alter table "topcon_sys"."ger_parametro" enable row level security;
create table if not exists "topcon_sys"."ger_parametro_email" (
  "emp" bigint,
  "user_autenticacao" text,
  "smtp" text,
  "porta_smtp" bigint,
  "email_remetente" text,
  "usa_ssl" text,
  "confirma_entrega" text,
  "usa_tls" text
);
create index if not exists "ix_ger_parametro_email" on "topcon_sys"."ger_parametro_email" ("emp");
alter table "topcon_sys"."ger_parametro_email" enable row level security;
create table if not exists "topcon_sys"."ger_parametro_sist_pref" (
  "sistema_nfse" bigint,
  "cod_mun_usina" bigint,
  "cod_mun_obra" bigint,
  "retencao_iss" bigint,
  "deducao_bc" bigint,
  "org_publico" bigint,
  "sit_tributaria" text,
  "serie_rps" text,
  "inclui_codigo_atv_economica" bigint,
  "inclui_item_lei_atv_economica" bigint,
  "inclui_cnae_atv_economica" bigint,
  "inclui_item_lei" bigint,
  "inclui_codigo_cnae" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_parametro_sist_pref" on "topcon_sys"."ger_parametro_sist_pref" ("sistema_nfse", "cod_mun_usina", "cod_mun_obra", "retencao_iss", "deducao_bc", "org_publico");
alter table "topcon_sys"."ger_parametro_sist_pref" enable row level security;
create table if not exists "topcon_sys"."ger_periodicidade" (
  "cod" bigint,
  "descr" text
);
create index if not exists "ix_ger_periodicidade" on "topcon_sys"."ger_periodicidade" ("cod");
alter table "topcon_sys"."ger_periodicidade" enable row level security;
create table if not exists "topcon_sys"."ger_pessoa" (
  "ger_pessoa_cod" bigint,
  "ger_pessoa_nome" text,
  "ger_pessoa_razao" text,
  "fix_paises_cod" bigint,
  "fix_cep_cod" bigint,
  "ger_pessoa_logr" text,
  "ger_pessoa_ender" text,
  "ger_pessoa_num" bigint,
  "ger_pessoa_compl" text,
  "ger_pessoa_bairro" text,
  "fix_municipio_codoficial" bigint,
  "ger_pessoa_cnpjcpf" text,
  "ger_pessoa_ie" text,
  "ger_pessoa_suframa" text,
  "chavegeralcod" bigint
);
create index if not exists "ix_ger_pessoa" on "topcon_sys"."ger_pessoa" ("ger_pessoa_cod");
alter table "topcon_sys"."ger_pessoa" enable row level security;
create table if not exists "topcon_sys"."ger_pessoaalter" (
  "ger_pessoa_cod" bigint,
  "ger_pessoaalter_dtalteracao" date,
  "ger_pessoaalter_nrocampo" bigint,
  "ger_pessoaalter_contanterior" text,
  "ger_pessoaalter_idcadast" text
);
create index if not exists "ix_ger_pessoaalter" on "topcon_sys"."ger_pessoaalter" ("ger_pessoa_cod", "ger_pessoaalter_dtalteracao", "ger_pessoaalter_nrocampo");
alter table "topcon_sys"."ger_pessoaalter" enable row level security;
create table if not exists "topcon_sys"."ger_prod" (
  "ger_empresa_cod" bigint,
  "ger_prod_cod" text,
  "ger_prod_descr" text,
  "ger_prod_descrcompl" text,
  "ger_prod_codbarra" text,
  "ger_prod_tipo" text,
  "ger_prod_origem" text,
  "ger_prod_estoqminimo" numeric,
  "ger_prod_diasreposicao" bigint,
  "ger_prod_pesobruto" numeric,
  "ger_prod_pesoliquido" numeric,
  "fix_ncm_cod" text,
  "fix_ncm_exipi" text,
  "fix_genprodserv_cod" text,
  "fix_listaserv_cod" bigint,
  "ger_prod_codseloipi" text,
  "ger_prod_aliqinterna" numeric,
  "ger_prod_basecalcmedic" text,
  "ger_prod_tipomedic" text,
  "ger_prod_precotabmedic" numeric,
  "ger_prod_bebcodtabela" text,
  "ger_prod_bebcodgrupo" text,
  "ger_prod_bebmarcacoml" text,
  "fix_prodcombanp_cod" text,
  "ger_prod_tipoarma" text,
  "ger_prod_dtcadastro" date,
  "ger_prod_dtultalter" date,
  "ger_prod_codisbn" text,
  "ger_prod_ctacontabil" text,
  "ger_prod_obs" text,
  "ger_prod_idcadast" text,
  "ger_prod_idatual" text,
  "tribcontrib_cod" text,
  "fix_clenqipi_cod" text,
  "tribipi_cod" bigint,
  "unidmedida_cod" text,
  "unidmedida_cod2" text
);
create index if not exists "ix_ger_prod" on "topcon_sys"."ger_prod" ("ger_empresa_cod", "ger_prod_cod");
alter table "topcon_sys"."ger_prod" enable row level security;
create table if not exists "topcon_sys"."ger_prodalter" (
  "ger_empresa_cod" bigint,
  "ger_prod_cod" text,
  "ger_prodalter_datainicial" date,
  "ger_prodalter_datafinal" date,
  "ger_prodalter_descranterior" text,
  "ger_prodalter_dataefd" date,
  "ger_prodalter_dataspedcontrb" date,
  "ger_prodalter_idatual" text
);
create index if not exists "ix_ger_prodalter" on "topcon_sys"."ger_prodalter" ("ger_empresa_cod", "ger_prod_cod", "ger_prodalter_datainicial");
alter table "topcon_sys"."ger_prodalter" enable row level security;
create table if not exists "topcon_sys"."ger_prodtrib" (
  "ger_empresa_cod" bigint,
  "ger_prod_cod" text,
  "fix_estado_sigla" text,
  "ger_prodtrib_aliqinterna" numeric,
  "ger_prodtrib_pctredbcicms" numeric,
  "ger_prodtrib_aliqicmsst" numeric,
  "ger_prodtrib_pctredbcicmsst" numeric,
  "ger_prodtrib_mvaicmsst" numeric,
  "ger_prodtrib_precotabst" numeric,
  "ger_prodtrib_inicvig" date
);
create index if not exists "ix_ger_prodtrib" on "topcon_sys"."ger_prodtrib" ("ger_empresa_cod", "ger_prod_cod", "fix_estado_sigla", "ger_prodtrib_inicvig");
alter table "topcon_sys"."ger_prodtrib" enable row level security;
create table if not exists "topcon_sys"."ger_produndconv" (
  "ger_empresa_cod" bigint,
  "ger_prod_cod" text,
  "unidmedida_cod3" text,
  "ger_produndconv_fatorconv" numeric
);
create index if not exists "ix_ger_produndconv" on "topcon_sys"."ger_produndconv" ("ger_empresa_cod", "ger_prod_cod", "unidmedida_cod3");
alter table "topcon_sys"."ger_produndconv" enable row level security;
create table if not exists "topcon_sys"."ger_relacao_grupo_interv" (
  "cod_grupo" bigint,
  "cod_interv" bigint
);
create index if not exists "ix_ger_relacao_grupo_interv" on "topcon_sys"."ger_relacao_grupo_interv" ("cod_grupo", "cod_interv");
alter table "topcon_sys"."ger_relacao_grupo_interv" enable row level security;
create table if not exists "topcon_sys"."ger_respon_tecnico" (
  "cod" bigint,
  "nome" text,
  "cnpj_emp_respon" text,
  "cpf_respon_gera" text,
  "ddd" bigint,
  "tel" bigint,
  "fax" bigint,
  "email" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_ger_respon_tecnico" on "topcon_sys"."ger_respon_tecnico" ("cod");
alter table "topcon_sys"."ger_respon_tecnico" enable row level security;
create table if not exists "topcon_sys"."ger_responsavel_distribuicao" (
  "id_servico" bigint,
  "descricao" text
);
create index if not exists "ix_ger_responsavel_distribuicao" on "topcon_sys"."ger_responsavel_distribuicao" ("id_servico");
alter table "topcon_sys"."ger_responsavel_distribuicao" enable row level security;
create table if not exists "topcon_sys"."ger_sistema_nfse" (
  "codigo" bigint,
  "descricao" text,
  "emite_via_servico" bigint,
  "cancela_via_servico" bigint,
  "substitui_via_servico" bigint,
  "consulta_via_servico" bigint
);
create index if not exists "ix_ger_sistema_nfse" on "topcon_sys"."ger_sistema_nfse" ("codigo");
alter table "topcon_sys"."ger_sistema_nfse" enable row level security;
create table if not exists "topcon_sys"."ger_sub_classif_cp" (
  "codigo" bigint,
  "descr" text,
  "id_cadast" text,
  "id_atual" text,
  "codigo_barra" text
);
create index if not exists "ix_ger_sub_classif_cp" on "topcon_sys"."ger_sub_classif_cp" ("codigo");
alter table "topcon_sys"."ger_sub_classif_cp" enable row level security;
create table if not exists "topcon_sys"."ger_tanqcomb" (
  "ger_empresa_cod" bigint,
  "ger_tanqcomb_num" bigint,
  "ger_tanqcomb_capacidade" bigint,
  "ger_prod_cod" text,
  "ger_tanqcomb_idcadast" text,
  "ger_tanqcomb_idatual" text
);
create index if not exists "ix_ger_tanqcomb" on "topcon_sys"."ger_tanqcomb" ("ger_empresa_cod", "ger_tanqcomb_num");
alter table "topcon_sys"."ger_tanqcomb" enable row level security;
create table if not exists "topcon_sys"."ger_tanqcombbombabico" (
  "ger_empresa_cod" bigint,
  "ger_tanqcomb_num" bigint,
  "ger_bombacomb_num" bigint,
  "ger_bombacombbico_num" bigint
);
create index if not exists "ix_ger_tanqcombbombabico" on "topcon_sys"."ger_tanqcombbombabico" ("ger_empresa_cod", "ger_tanqcomb_num", "ger_bombacomb_num", "ger_bombacombbico_num");
alter table "topcon_sys"."ger_tanqcombbombabico" enable row level security;
create table if not exists "topcon_sys"."ger_tipodoc" (
  "ger_tipodoc_cod" text,
  "ger_tipodoc_descr" text,
  "fix_moddocfiscal_cod" text,
  "ger_tipodoc_idcadast" text,
  "ger_tipodoc_idatual" text,
  "ger_tipodoc_tipotitcred" text
);
create index if not exists "ix_ger_tipodoc" on "topcon_sys"."ger_tipodoc" ("ger_tipodoc_cod");
alter table "topcon_sys"."ger_tipodoc" enable row level security;
create table if not exists "topcon_sys"."ger_tp_doc" (
  "cod" bigint,
  "abrev" text,
  "descr" text,
  "mod_doc" text,
  "tp_doc_serv" bigint,
  "nfse" text,
  "id_cadast" text,
  "id_atual" text,
  "fixo" text,
  "external_id" text
);
create index if not exists "ix_ger_tp_doc" on "topcon_sys"."ger_tp_doc" ("cod");
alter table "topcon_sys"."ger_tp_doc" enable row level security;
create table if not exists "topcon_sys"."ger_tpentegov" (
  "cod" bigint,
  "descr" text,
  "id_atual" text,
  "id_cadast" text,
  "ativo" bigint
);
create index if not exists "ix_ger_tpentegov" on "topcon_sys"."ger_tpentegov" ("cod");
alter table "topcon_sys"."ger_tpentegov" enable row level security;
create table if not exists "topcon_sys"."ger_tpopergov" (
  "cod" bigint,
  "descr" text,
  "id_atual" text,
  "id_cadast" text,
  "ativo" bigint
);
create index if not exists "ix_ger_tpopergov" on "topcon_sys"."ger_tpopergov" ("cod");
alter table "topcon_sys"."ger_tpopergov" enable row level security;
create table if not exists "topcon_sys"."ger_transacao_second" (
  "cod_trans" bigint,
  "cod_trans_seq" bigint,
  "descr_seq" text,
  "id_atual" text,
  "id_cadast" text,
  "ativo" bigint
);
create index if not exists "ix_ger_transacao_second" on "topcon_sys"."ger_transacao_second" ("cod_trans", "cod_trans_seq");
alter table "topcon_sys"."ger_transacao_second" enable row level security;
create table if not exists "topcon_sys"."ger_tribcontrib" (
  "cod" text,
  "descr" text,
  "idcadast" text,
  "idatual" text,
  "deduz_descto_bc" text,
  "inclui_encargos" text,
  "inclui_honor" text,
  "inclui_frete_na_bc" text,
  "inclui_outras_desp_na_bc" text,
  "inclui_seguro_na_bc" text,
  "inclui_icmsst_na_bc" text,
  "inclui_ipi_na_bc" text,
  "inclui_icmsst_pag_ant_na_bc" text,
  "inclui_icms_bc" text,
  "exc_icms_na" text
);
create index if not exists "ix_ger_tribcontrib" on "topcon_sys"."ger_tribcontrib" ("cod");
alter table "topcon_sys"."ger_tribcontrib" enable row level security;
create table if not exists "topcon_sys"."ger_tribcontribitem" (
  "cod" text,
  "dtiniciovig" date,
  "cstcontrib_cod" text,
  "pispct" numeric,
  "cofinspct" numeric,
  "bcalccontr_cod" bigint,
  "tpcredcontr_cod" bigint,
  "contrapur_cod" bigint,
  "opernaotrib" bigint
);
create index if not exists "ix_ger_tribcontribitem" on "topcon_sys"."ger_tribcontribitem" ("cod", "dtiniciovig");
alter table "topcon_sys"."ger_tribcontribitem" enable row level security;
create table if not exists "topcon_sys"."ger_unidade" (
  "unidade" text,
  "descr" text,
  "id_cadast" text,
  "id_atual" text,
  "tipo" bigint
);
create index if not exists "ix_ger_unidade" on "topcon_sys"."ger_unidade" ("unidade");
alter table "topcon_sys"."ger_unidade" enable row level security;
create table if not exists "topcon_sys"."ger_unidade_terceiros" (
  "unidade" text,
  "unidade_terceiro" text
);
create index if not exists "ix_ger_unidade_terceiros" on "topcon_sys"."ger_unidade_terceiros" ("unidade", "unidade_terceiro");
alter table "topcon_sys"."ger_unidade_terceiros" enable row level security;
create table if not exists "topcon_sys"."ger_unidademedida" (
  "ger_unidademedida_cod" text,
  "ger_unidademedida_descr" text,
  "ger_unidademedida_idcadast" text,
  "ger_unidademedida_idatual" text
);
create index if not exists "ix_ger_unidademedida" on "topcon_sys"."ger_unidademedida" ("ger_unidademedida_cod");
alter table "topcon_sys"."ger_unidademedida" enable row level security;
create table if not exists "topcon_sys"."ger_usr_assinatura" (
  "usuario" text,
  "obs" text
);
create index if not exists "ix_ger_usr_assinatura" on "topcon_sys"."ger_usr_assinatura" ("usuario");
alter table "topcon_sys"."ger_usr_assinatura" enable row level security;
create table if not exists "topcon_sys"."ger_vendedor" (
  "cod" bigint,
  "func" text,
  "nome" text,
  "razao" text,
  "cep" bigint,
  "end" text,
  "num" bigint,
  "compl" text,
  "bairro" text,
  "mun" bigint,
  "cnpj_cpf" text,
  "pct_comis" numeric,
  "pct_comis_fat" numeric,
  "pct_comis_liq" numeric,
  "num_prox_ped_ve" bigint
);
create index if not exists "ix_ger_vendedor" on "topcon_sys"."ger_vendedor" ("cod");
alter table "topcon_sys"."ger_vendedor" enable row level security;
create table if not exists "topcon_sys"."ger_versao" (
  "aplicativo" text,
  "versao1" bigint,
  "versao2" bigint,
  "versao3" bigint
);
create index if not exists "ix_ger_versao" on "topcon_sys"."ger_versao" ("aplicativo");
alter table "topcon_sys"."ger_versao" enable row level security;
create table if not exists "topcon_sys"."ger_versao_script" (
  "id" bigint,
  "script" text
);
create index if not exists "ix_ger_versao_script" on "topcon_sys"."ger_versao_script" ("id");
alter table "topcon_sys"."ger_versao_script" enable row level security;
create table if not exists "topcon_sys"."ger_versao_usina" (
  "id" bigint
);
create index if not exists "ix_ger_versao_usina" on "topcon_sys"."ger_versao_usina" ("id");
alter table "topcon_sys"."ger_versao_usina" enable row level security;
create table if not exists "topcon_sys"."integracao_fleetcom" (
  "id" bigint,
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "data" date,
  "hora_abast" text,
  "veiculo_equip" text,
  "placa_equip" text,
  "km_equip" bigint,
  "horimetro_equip" numeric,
  "volume_abast" numeric,
  "valor_abast" numeric,
  "cpf_motorista" text,
  "nome_motorista" text,
  "cnpj_posto" text,
  "razao_posto" text,
  "endereco_posto" text,
  "cidade_posto" text,
  "uf_posto" text,
  "cep_posto" text,
  "combustivel" text,
  "local" text,
  "tipo_abast" text,
  "acao" text,
  "data_inclusao" date
);
create index if not exists "ix_integracao_fleetcom" on "topcon_sys"."integracao_fleetcom" ("id");
alter table "topcon_sys"."integracao_fleetcom" enable row level security;
create table if not exists "topcon_sys"."integracao_fleetcom_equipamento" (
  "cod" text,
  "tipo" bigint,
  "betoneira" text,
  "bomba" text,
  "placa" text,
  "descr" text,
  "capacidade_m3" bigint,
  "mtr_bomb_usina" bigint,
  "mtr_bomb_codigo" bigint,
  "ajudande_usina" bigint,
  "ajudande_codigo" bigint,
  "ajudante_codigo2" bigint,
  "ajudante_codigo3" bigint,
  "usina_alocada" bigint,
  "id_cadast" text,
  "id_atual" text,
  "marca" text,
  "modelo" text,
  "chassis" text,
  "ano" bigint,
  "status" bigint,
  "dt_ocorrencia" date,
  "tp_processo" bigint,
  "ativo" text,
  "possui_gps" text,
  "dt_inst_gps" date,
  "gps" text,
  "no_processo" text,
  "obs" text,
  "grupo" bigint,
  "sub_grupo" bigint,
  "item" bigint,
  "grupo2" bigint,
  "sub_grupo2" bigint,
  "item2" bigint,
  "ano_modelo" bigint,
  "renavam" text,
  "combustivel" bigint,
  "capac_pot_cil" text,
  "faixa_ipva" text,
  "proprietario" bigint,
  "tacografo_quebr" text,
  "uf" text,
  "final_placa" text,
  "cap_lit_comb" bigint,
  "peso_equip" numeric,
  "controla_km" bigint,
  "controla_horim" bigint,
  "horim_quebr" text,
  "dt_subst_tac" date,
  "dt_subst_hori" date,
  "acao" text,
  "data_inclusao" date
);
create index if not exists "ix_integracao_fleetcom_equipamento" on "topcon_sys"."integracao_fleetcom_equipamento" ("cod");
alter table "topcon_sys"."integracao_fleetcom_equipamento" enable row level security;
create table if not exists "topcon_sys"."integracao_fleetcom_ordem_servico" (
  "empresa" bigint,
  "ordem_servico" bigint,
  "equipamento" text,
  "dt_ini_manut" date,
  "dt_fim_manut" date,
  "status" bigint
);
create index if not exists "ix_integracao_fleetcom_ordem_servico" on "topcon_sys"."integracao_fleetcom_ordem_servico" ("empresa", "ordem_servico", "equipamento");
alter table "topcon_sys"."integracao_fleetcom_ordem_servico" enable row level security;
create table if not exists "topcon_sys"."integracao_fleetcom_requisicao" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "data" date,
  "requisitante" bigint,
  "observacao" text,
  "resp_p_compra" bigint,
  "status" bigint,
  "fornecedor" bigint,
  "dt_prox_aprov" date,
  "centro_custo" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_aprovacao" text,
  "departamento" bigint,
  "dep_usuario" bigint,
  "filial_solic" bigint,
  "acao" text,
  "data_inclusao" date
);
create index if not exists "ix_integracao_fleetcom_requisicao" on "topcon_sys"."integracao_fleetcom_requisicao" ("empresa", "ano_requisicao", "no_requisicao");
alter table "topcon_sys"."integracao_fleetcom_requisicao" enable row level security;
create table if not exists "topcon_sys"."integracao_fleetcom_requisicao_item" (
  "empresa" bigint,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "sequencia" bigint,
  "material" text,
  "descr_material" text,
  "especificacao" text,
  "quantidade" numeric,
  "unidade" text,
  "veiculo_equip" text,
  "operacao" bigint,
  "observacao" text,
  "ano_cotacao" bigint,
  "no_cotacao" bigint,
  "seq_cotacao" bigint,
  "id_cadast" text,
  "id_atual" text,
  "id_aprov_contab" text,
  "status" bigint,
  "dt_prox_aprov" date,
  "dt_prev_entrega" date,
  "qtd_atendida" numeric,
  "id_aprov" text,
  "grupo" bigint,
  "subgrupo" bigint,
  "item" bigint,
  "subitem" bigint,
  "qtd_compra" numeric,
  "urgencia" text,
  "passar_almox" text,
  "analis_contab" text,
  "qtd_original" numeric,
  "filial" bigint,
  "filial_nf" bigint,
  "interv_nf" bigint,
  "tp_doc_nf" bigint,
  "serie_nf" text,
  "num_nf" bigint,
  "seq_item_nf" bigint,
  "obs_reprovacao" text,
  "dt_atendimento" date,
  "km_equip" bigint,
  "ciencia_reprov" text,
  "horimetro_equip" numeric,
  "dt_ult_atual" date,
  "qtd_entreg_forn" numeric,
  "vlr_unit" numeric,
  "vlr_total" numeric,
  "dt_prorrog_bloq" date,
  "hora_abast" text,
  "km_rodado" bigint,
  "local_estoque" text,
  "id_solic_compra" text,
  "horas_trabalhad" numeric,
  "ordem_servico" text,
  "acao" text,
  "data_inclusao" date
);
create index if not exists "ix_integracao_fleetcom_requisicao_item" on "topcon_sys"."integracao_fleetcom_requisicao_item" ("empresa", "ano_requisicao", "no_requisicao", "sequencia");
alter table "topcon_sys"."integracao_fleetcom_requisicao_item" enable row level security;
create table if not exists "topcon_sys"."man_atividade" (
  "cod" bigint,
  "descr" text,
  "ponto_manut" bigint,
  "especif" text,
  "tempo_medio" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_man_atividade" on "topcon_sys"."man_atividade" ("cod");
alter table "topcon_sys"."man_atividade" enable row level security;
create table if not exists "topcon_sys"."man_manut_ativ" (
  "empresa" bigint,
  "ordem_servico" bigint,
  "equipamento" text,
  "atividade" bigint,
  "seq_atividade" bigint,
  "plano_manut" bigint,
  "seq" bigint,
  "mecanico" bigint,
  "status" text,
  "tempo_gasto" bigint,
  "obs" text
);
create index if not exists "ix_man_manut_ativ" on "topcon_sys"."man_manut_ativ" ("empresa", "ordem_servico", "equipamento", "atividade", "seq_atividade");
alter table "topcon_sys"."man_manut_ativ" enable row level security;
create table if not exists "topcon_sys"."man_manut_pecas" (
  "empresa" bigint,
  "ordem_servico" bigint,
  "equipamento" text,
  "item" bigint,
  "atividade" bigint,
  "seq_atividade" bigint,
  "plano_manut" bigint,
  "seq" bigint,
  "prod" text,
  "qtde" numeric,
  "ano_requisicao" bigint,
  "no_requisicao" bigint,
  "seq_requisicao" bigint,
  "operacao" bigint,
  "grupo" bigint,
  "subgrupo" bigint,
  "item_estrutura" bigint,
  "subitem_estrut" bigint
);
create index if not exists "ix_man_manut_pecas" on "topcon_sys"."man_manut_pecas" ("empresa", "ordem_servico", "equipamento", "item", "atividade", "seq_atividade");
alter table "topcon_sys"."man_manut_pecas" enable row level security;
create table if not exists "topcon_sys"."man_manutencoes" (
  "empresa" bigint,
  "ordem_servico" bigint,
  "equipamento" text,
  "plano_manut" bigint,
  "seq" bigint,
  "dt" date,
  "valor_crit" bigint,
  "valor_crit_man" bigint,
  "tp_manut" bigint,
  "status" bigint,
  "dt_ini_manut" date,
  "hr_ini_manut" text,
  "dt_fim_manut" date,
  "hr_fim_manut" text,
  "dt_liberacao" date,
  "encarregado" bigint,
  "tempo_previsto" bigint,
  "tempo_realizado" bigint,
  "obs" text,
  "id_cadast" text,
  "id_atual" text,
  "faltam" bigint
);
create index if not exists "ix_man_manutencoes" on "topcon_sys"."man_manutencoes" ("empresa", "ordem_servico", "equipamento");
alter table "topcon_sys"."man_manutencoes" enable row level security;
create table if not exists "topcon_sys"."man_plano_equip" (
  "equipamento" text,
  "plano_manut" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_man_plano_equip" on "topcon_sys"."man_plano_equip" ("equipamento", "plano_manut");
alter table "topcon_sys"."man_plano_equip" enable row level security;
create table if not exists "topcon_sys"."man_plano_man" (
  "cod" bigint,
  "descr" text,
  "ativo" text,
  "criterio" bigint,
  "valor" bigint,
  "id_cadast" text,
  "id_atual" text,
  "valor_crit_not" bigint
);
create index if not exists "ix_man_plano_man" on "topcon_sys"."man_plano_man" ("cod");
alter table "topcon_sys"."man_plano_man" enable row level security;
create table if not exists "topcon_sys"."man_plano_man_item" (
  "cod" bigint,
  "atividade" bigint
);
create index if not exists "ix_man_plano_man_item" on "topcon_sys"."man_plano_man_item" ("cod", "atividade");
alter table "topcon_sys"."man_plano_man_item" enable row level security;
create table if not exists "topcon_sys"."pdr_custos_estrutura" (
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "inicio_vigencia" date,
  "tipo_custo" bigint,
  "valor" numeric
);
create index if not exists "ix_pdr_custos_estrutura" on "topcon_sys"."pdr_custos_estrutura" ("n1", "n2", "n3", "n4", "inicio_vigencia", "tipo_custo");
alter table "topcon_sys"."pdr_custos_estrutura" enable row level security;
create table if not exists "topcon_sys"."pdr_def_familia" (
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "coef_risc_resis" numeric,
  "coef_dif_ent" numeric
);
create index if not exists "ix_pdr_def_familia" on "topcon_sys"."pdr_def_familia" ("n1", "n2", "n3", "n4");
alter table "topcon_sys"."pdr_def_familia" enable row level security;
create table if not exists "topcon_sys"."pdr_def_familia_item" (
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "tamanho" text,
  "coef_risc_bloco" numeric,
  "coef_risc_resis" numeric,
  "coef_dif_ent" numeric,
  "ativo" text
);
create index if not exists "ix_pdr_def_familia_item" on "topcon_sys"."pdr_def_familia_item" ("n1", "n2", "n3", "n4", "tamanho");
alter table "topcon_sys"."pdr_def_familia_item" enable row level security;
create table if not exists "topcon_sys"."pdr_descr_largura" (
  "largura" numeric,
  "descricao" text
);
create index if not exists "ix_pdr_descr_largura" on "topcon_sys"."pdr_descr_largura" ("largura");
alter table "topcon_sys"."pdr_descr_largura" enable row level security;
create table if not exists "topcon_sys"."pdr_fam_versao" (
  "usina" bigint,
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "versao" bigint,
  "status" bigint,
  "dt_inicio_valid" date,
  "uso" bigint,
  "pedra" bigint,
  "slump" bigint,
  "fck" numeric,
  "consumo" bigint,
  "versao_traco" text,
  "tab_custo_traco" date,
  "custo_ton" numeric,
  "outros_custos" numeric,
  "tipo_carga" bigint,
  "markup" numeric,
  "vigen_frete_reg" date
);
create index if not exists "ix_pdr_fam_versao" on "topcon_sys"."pdr_fam_versao" ("usina", "n1", "n2", "n3", "n4", "versao");
alter table "topcon_sys"."pdr_fam_versao" enable row level security;
create table if not exists "topcon_sys"."pdr_fam_versao_custo" (
  "usina" bigint,
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "versao" bigint,
  "n1_vigencia" bigint,
  "n2_vigencia" bigint,
  "n3_vigencia" bigint,
  "n4_vigencia" bigint,
  "inicio_vigencia" date,
  "tipo_custo" bigint,
  "valor" numeric
);
create index if not exists "ix_pdr_fam_versao_custo" on "topcon_sys"."pdr_fam_versao_custo" ("usina", "n1", "n2", "n3", "n4", "versao", "tipo_custo");
alter table "topcon_sys"."pdr_fam_versao_custo" enable row level security;
create table if not exists "topcon_sys"."pdr_fam_versao_item" (
  "usina" bigint,
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "versao" bigint,
  "tamanho" text,
  "n1_fab" bigint,
  "n2_fab" bigint,
  "n3_fab" bigint,
  "n4_fab" bigint,
  "tamanho_fab" text,
  "peso_real" numeric,
  "coef_risc_resis" numeric,
  "coef_risc_bloco" numeric,
  "coef_retira" numeric,
  "coef_dif_ent" numeric,
  "markup" numeric
);
create index if not exists "ix_pdr_fam_versao_item" on "topcon_sys"."pdr_fam_versao_item" ("usina", "n1", "n2", "n3", "n4", "versao", "tamanho");
alter table "topcon_sys"."pdr_fam_versao_item" enable row level security;
create table if not exists "topcon_sys"."pdr_frete_reg" (
  "usina" bigint,
  "dt_inicio_valid" date,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_frete_reg" on "topcon_sys"."pdr_frete_reg" ("usina", "dt_inicio_valid");
alter table "topcon_sys"."pdr_frete_reg" enable row level security;
create table if not exists "topcon_sys"."pdr_frete_reg_item" (
  "usina" bigint,
  "dt_inicio_valid" date,
  "cod_regiao" bigint,
  "preco" numeric,
  "ativo" text
);
create index if not exists "ix_pdr_frete_reg_item" on "topcon_sys"."pdr_frete_reg_item" ("usina", "dt_inicio_valid", "cod_regiao");
alter table "topcon_sys"."pdr_frete_reg_item" enable row level security;
create table if not exists "topcon_sys"."pdr_param_premold" (
  "usina" bigint,
  "comp_cod_prod" text,
  "markup_pad" numeric,
  "coef_retira" numeric,
  "pct_desc_limite" numeric,
  "ncm_pad" text,
  "tp_item" text,
  "unidade_uso" text,
  "comp_desc_prod" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_param_premold" on "topcon_sys"."pdr_param_premold" ("usina");
alter table "topcon_sys"."pdr_param_premold" enable row level security;
create table if not exists "topcon_sys"."pdr_param_prod" (
  "produto" bigint,
  "estr_padrao_n1" bigint,
  "nivel_resist" bigint,
  "valida_placa_nf" text,
  "perm_nf_sem_ctr" text,
  "cod_obs_fiscal" bigint,
  "vl_aprox_trib" numeric,
  "mx_desc_nf_sctr" numeric,
  "boleto_auto_nf" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_param_prod" on "topcon_sys"."pdr_param_prod" ("produto");
alter table "topcon_sys"."pdr_param_prod" enable row level security;
create table if not exists "topcon_sys"."pdr_regiao" (
  "codigo" bigint,
  "descricao" text,
  "especificacao" text,
  "tipo" bigint,
  "distancia_de" bigint,
  "distancia_ate" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_regiao" on "topcon_sys"."pdr_regiao" ("codigo");
alter table "topcon_sys"."pdr_regiao" enable row level security;
create table if not exists "topcon_sys"."pdr_tab_preco" (
  "num_tab" bigint,
  "vend_repres" bigint,
  "usina" bigint,
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "tamanho" text,
  "dt_inic_tab" date,
  "inic_vig_fam" date,
  "cod_produto" text,
  "custo" numeric,
  "preco" numeric,
  "preco_retira" numeric,
  "vlr_adic" numeric,
  "markup" numeric,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_tab_preco" on "topcon_sys"."pdr_tab_preco" ("num_tab", "vend_repres", "usina", "n1", "n2", "n3", "n4", "tamanho");
alter table "topcon_sys"."pdr_tab_preco" enable row level security;
create table if not exists "topcon_sys"."pdr_tab_preco_frete" (
  "num_tab" bigint,
  "vend_repres" bigint,
  "usina" bigint,
  "n1" bigint,
  "n2" bigint,
  "n3" bigint,
  "n4" bigint,
  "tamanho" text,
  "tipo_carga" bigint,
  "regiao" bigint,
  "valor" numeric
);
create index if not exists "ix_pdr_tab_preco_frete" on "topcon_sys"."pdr_tab_preco_frete" ("num_tab", "vend_repres", "usina", "n1", "n2", "n3", "n4", "tamanho", "tipo_carga", "regiao");
alter table "topcon_sys"."pdr_tab_preco_frete" enable row level security;
create table if not exists "topcon_sys"."pdr_tamanho_prod" (
  "codigo" text,
  "largura" numeric,
  "comprimento" numeric,
  "altura1" numeric,
  "altura2" numeric,
  "ativo" text
);
create index if not exists "ix_pdr_tamanho_prod" on "topcon_sys"."pdr_tamanho_prod" ("codigo");
alter table "topcon_sys"."pdr_tamanho_prod" enable row level security;
create table if not exists "topcon_sys"."pdr_tipo_carga" (
  "codigo" bigint,
  "descricao" text,
  "peso" numeric,
  "qtd_paletes" bigint,
  "padrao" text
);
create index if not exists "ix_pdr_tipo_carga" on "topcon_sys"."pdr_tipo_carga" ("codigo");
alter table "topcon_sys"."pdr_tipo_carga" enable row level security;
create table if not exists "topcon_sys"."pdr_tipo_custo" (
  "codigo" bigint,
  "descricao" text
);
create index if not exists "ix_pdr_tipo_custo" on "topcon_sys"."pdr_tipo_custo" ("codigo");
alter table "topcon_sys"."pdr_tipo_custo" enable row level security;
create table if not exists "topcon_sys"."pdr_transp_terc" (
  "interv" bigint,
  "tipo_carga" bigint,
  "ini_validade" date,
  "cond_pagto" bigint,
  "operacao" bigint,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_transp_terc" on "topcon_sys"."pdr_transp_terc" ("interv", "tipo_carga", "ini_validade");
alter table "topcon_sys"."pdr_transp_terc" enable row level security;
create table if not exists "topcon_sys"."pdr_usr_rest" (
  "usuario" text,
  "id_cadast" text,
  "id_atual" text
);
create index if not exists "ix_pdr_usr_rest" on "topcon_sys"."pdr_usr_rest" ("usuario");
alter table "topcon_sys"."pdr_usr_rest" enable row level security;
create table if not exists "topcon_sys"."pdr_usr_rest_usina" (
  "usuario" text,
  "usina" bigint
);
create index if not exists "ix_pdr_usr_rest_usina" on "topcon_sys"."pdr_usr_rest_usina" ("usuario", "usina");
alter table "topcon_sys"."pdr_usr_rest_usina" enable row level security;
create table if not exists "topcon_geral"."fis_operfiscal" (
  "fix_cfop_cod" bigint,
  "fis_operfiscal_seq" bigint,
  "fis_operfiscal_descr" text,
  "fis_operfiscal_descrred" text,
  "fix_csticms_cod" text,
  "fis_operfiscal_modbcicms" text,
  "fis_operfiscal_difaliqicms" text,
  "fis_operfiscal_incfretebcicms" text,
  "fis_operfiscal_incsegurobcicms" text,
  "fis_operfiscal_incdespacbcicms" text,
  "fis_operfiscal_incipibcicms" text,
  "fis_operfiscal_modbcicmsst" text,
  "fis_operfiscal_operst" text,
  "ger_tribipi_cod" bigint,
  "ger_tribcontrib_cod" text,
  "fis_obsfiscal_cod" text,
  "fis_mensfiscal_cod1" bigint,
  "fis_mensfiscal_cod2" bigint,
  "fis_mensfiscal_cod3" bigint,
  "fis_operfiscal_indtotal" text,
  "fis_operfiscal_movfisica" text,
  "fis_operfiscal_tipoestoque" bigint,
  "fis_operfiscal_idcadast" text,
  "fis_operfiscal_idatual" text
);
create index if not exists "ix_fis_operfiscal" on "topcon_geral"."fis_operfiscal" ("fix_cfop_cod", "fis_operfiscal_seq");
alter table "topcon_geral"."fis_operfiscal" enable row level security;
create table if not exists "topcon_geral"."ger_chavegeral" (
  "ger_chavegeral_cod" bigint
);
create index if not exists "ix_ger_chavegeral" on "topcon_geral"."ger_chavegeral" ("ger_chavegeral_cod");
alter table "topcon_geral"."ger_chavegeral" enable row level security;
create table if not exists "topcon_geral"."ger_contador" (
  "ger_contador_cod" bigint,
  "ger_contador_nome" text,
  "ger_contador_cpf" text,
  "ger_contador_cnpjescrctb" text,
  "ger_contador_nocrc" text,
  "fix_cep_cod" bigint,
  "ger_contador_logradouro" text,
  "ger_contador_endereco" text,
  "ger_contador_num" bigint,
  "ger_contador_complend" text,
  "ger_contador_bairro" text,
  "fix_municipio_codoficial" bigint,
  "ger_contador_telefone" text,
  "ger_contador_fax" text,
  "ger_contador_email" text,
  "ger_contador_ufcrc" text,
  "ger_contador_seqcrc" text,
  "ger_contador_validcrc" date,
  "ger_contador_idcadast" text,
  "ger_contador_idatual" text
);
create index if not exists "ix_ger_contador" on "topcon_geral"."ger_contador" ("ger_contador_cod");
alter table "topcon_geral"."ger_contador" enable row level security;
create table if not exists "topcon_geral"."ger_default" (
  "usr_aplicativo_sigla" text,
  "ger_default_campo" text,
  "ger_default_valor" text,
  "ger_default_tpcampo" text,
  "ger_default_tamcampo" bigint,
  "ger_default_decimais" bigint
);
create index if not exists "ix_ger_default" on "topcon_geral"."ger_default" ("usr_aplicativo_sigla", "ger_default_campo");
alter table "topcon_geral"."ger_default" enable row level security;
create table if not exists "topcon_geral"."ger_diretorio" (
  "ger_diretorio_nomebd" text,
  "ger_diretorio_descrdir" text,
  "ger_diretorio_idcadast" text,
  "ger_diretorio_idatual" text
);
create index if not exists "ix_ger_diretorio" on "topcon_geral"."ger_diretorio" ("ger_diretorio_nomebd");
alter table "topcon_geral"."ger_diretorio" enable row level security;
create table if not exists "topcon_geral"."ger_feriado" (
  "ger_feriado_data" date,
  "fix_municipio_codoficial" bigint,
  "ger_feriado_descr" text,
  "ger_feriado_idcadast" text,
  "ger_feriado_idatual" text
);
create index if not exists "ix_ger_feriado" on "topcon_geral"."ger_feriado" ("ger_feriado_data", "fix_municipio_codoficial");
alter table "topcon_geral"."ger_feriado" enable row level security;
create table if not exists "topcon_geral"."ger_fundlegal" (
  "ger_fundlegal_cod" text,
  "ger_fundlegal_descr" text,
  "ger_tipoatolegal_cod" text,
  "ger_fundlegal_natolegal" bigint,
  "ger_fundlegal_datolegal" date,
  "ger_fundlegal_idcadast" text,
  "ger_fundlegal_idatual" text
);
create index if not exists "ix_ger_fundlegal" on "topcon_geral"."ger_fundlegal" ("ger_fundlegal_cod");
alter table "topcon_geral"."ger_fundlegal" enable row level security;
create table if not exists "topcon_geral"."ger_menserro" (
  "ger_menserro_aplic" text,
  "ger_menserro_nummens" bigint,
  "ger_menserro_descr" text,
  "ger_menserro_tpmens" text,
  "ger_menserro_ajuda" text,
  "ger_menserro_ajudasuporte" text
);
create index if not exists "ix_ger_menserro" on "topcon_geral"."ger_menserro" ("ger_menserro_aplic", "ger_menserro_nummens");
alter table "topcon_geral"."ger_menserro" enable row level security;
create table if not exists "topcon_geral"."ger_tipoatolegal" (
  "ger_tipoatolegal_cod" text,
  "ger_tipoatolegal_descr" text,
  "ger_tipoatolegal_idcadast" text,
  "ger_tipoatolegal_idatual" text
);
create index if not exists "ix_ger_tipoatolegal" on "topcon_geral"."ger_tipoatolegal" ("ger_tipoatolegal_cod");
alter table "topcon_geral"."ger_tipoatolegal" enable row level security;
create table if not exists "topcon_geral"."ger_transacao" (
  "ger_transacao_cod" bigint,
  "ger_transacao_descr" text,
  "ctb_codint_cod" bigint,
  "ger_transacao_idcadast" text,
  "ger_transacao_idatual" text
);
create index if not exists "ix_ger_transacao" on "topcon_geral"."ger_transacao" ("ger_transacao_cod");
alter table "topcon_geral"."ger_transacao" enable row level security;
create table if not exists "topcon_geral"."ger_tribcontrib" (
  "ger_tribcontrib_cod" text,
  "ger_tribcontrib_descr" text,
  "ger_tribcontrib_idcadast" text,
  "ger_tribcontrib_idatual" text,
  "ger_tribcontrib_inclipibc" text,
  "ger_tribcontrib_inclicmsstbc" text,
  "ger_tribcontrib_inclsegbc" text,
  "ger_tribcontrib_inclodesbc" text,
  "ger_tribcontrib_inclfrtbc" text
);
create index if not exists "ix_ger_tribcontrib" on "topcon_geral"."ger_tribcontrib" ("ger_tribcontrib_cod");
alter table "topcon_geral"."ger_tribcontrib" enable row level security;
create table if not exists "topcon_geral"."ger_tribcontribent" (
  "ger_tribcontrib_cod" text,
  "ger_tribcontribent_codativid" text,
  "ger_tribcontribent_regtribfed" bigint,
  "ger_tribcontribent_dtinivig" date,
  "fix_cstcontrib_cod" text,
  "ger_tribcontribent_pispct" numeric,
  "ger_tribcontribent_cofinspct" numeric,
  "fix_basecalccontrib_cod" bigint,
  "fix_tipocredcontrib_cod" bigint,
  "ger_fundlegal_cod" text
);
create index if not exists "ix_ger_tribcontribent" on "topcon_geral"."ger_tribcontribent" ("ger_tribcontrib_cod", "ger_tribcontribent_codativid", "ger_tribcontribent_regtribfed", "ger_tribcontribent_dtinivig");
alter table "topcon_geral"."ger_tribcontribent" enable row level security;
create table if not exists "topcon_geral"."ger_tribcontribitem" (
  "ger_tribcontrib_cod" text,
  "ger_tribcontribitem_dtinicvig" date,
  "ger_tribcontribitem_tpativ" text,
  "ger_tribcontribitem_regtribfed" bigint,
  "fix_cstcontrib_cod" text,
  "ger_tribcontribitem_pispct" numeric,
  "ger_tribcontribitem_cofinspct" numeric,
  "fix_basecalccontrib_cod" bigint,
  "fix_tipocredcontrib_cod" bigint,
  "fix_codcontribapurada_cod" bigint,
  "ger_fundlegal_cod" text,
  "fix_opntribcontr_cst" text,
  "fix_opntribcontritem_cod" bigint
);
create index if not exists "ix_ger_tribcontribitem" on "topcon_geral"."ger_tribcontribitem" ("ger_tribcontrib_cod", "ger_tribcontribitem_dtinicvig", "ger_tribcontribitem_tpativ", "ger_tribcontribitem_regtribfed");
alter table "topcon_geral"."ger_tribcontribitem" enable row level security;
create table if not exists "topcon_geral"."ger_tribcontribsda" (
  "ger_tribcontrib_cod" text,
  "ger_tribcontribsda_codativid" text,
  "ger_tribcontribsda_regtribfed" bigint,
  "ger_tribcontribsda_dtinivig" date,
  "codcstcontrib" text,
  "ger_tribcontribsda_pispct" numeric,
  "ger_tribcontribsda_cofinspct" numeric,
  "fix_codcontribapurada_cod" bigint,
  "codfundlegal" text,
  "ger_tribcontribsda_natreceita" text
);
create index if not exists "ix_ger_tribcontribsda" on "topcon_geral"."ger_tribcontribsda" ("ger_tribcontrib_cod", "ger_tribcontribsda_codativid", "ger_tribcontribsda_regtribfed", "ger_tribcontribsda_dtinivig");
alter table "topcon_geral"."ger_tribcontribsda" enable row level security;
create table if not exists "topcon_geral"."ger_tribipi" (
  "ger_tribipi_cod" bigint,
  "ger_tribipi_descr" text,
  "ger_tribipi_tribaliqzero" text,
  "ger_tribipi_aliqpct" numeric,
  "ger_tribipi_aliqvlr" numeric,
  "ger_tribipi_tribmonof" text,
  "ger_tribipi_tribsubtrib" text,
  "ger_tribipi_perapuripi" text,
  "ger_tribipi_idcadast" text,
  "ger_tribipi_idatual" text
);
create index if not exists "ix_ger_tribipi" on "topcon_geral"."ger_tribipi" ("ger_tribipi_cod");
alter table "topcon_geral"."ger_tribipi" enable row level security;
create table if not exists "topcon_geral"."ger_tribipient" (
  "ger_tribipi_cod" bigint,
  "ger_tribipient_codatividade" text,
  "ger_tribipient_regimetribfed" bigint,
  "ger_tribipient_dtiniciovig" date,
  "cstipi_cod" text,
  "cstipi_cod2" text,
  "ger_fundlegal_cod" text
);
create index if not exists "ix_ger_tribipient" on "topcon_geral"."ger_tribipient" ("ger_tribipi_cod", "ger_tribipient_codatividade", "ger_tribipient_regimetribfed", "ger_tribipient_dtiniciovig");
alter table "topcon_geral"."ger_tribipient" enable row level security;
create table if not exists "topcon_geral"."ger_tribiss" (
  "fix_municipio_codoficial" bigint,
  "fix_listaserv_cod" bigint,
  "ger_tribiss_fatorbasecalciss" numeric,
  "ger_tribiss_pctiss" numeric,
  "ger_tribiss_retencaoiss" text,
  "ger_tribiss_idcadast" text,
  "ger_tribiss_idatual" text
);
create index if not exists "ix_ger_tribiss" on "topcon_geral"."ger_tribiss" ("fix_municipio_codoficial", "fix_listaserv_cod");
alter table "topcon_geral"."ger_tribiss" enable row level security;
create table if not exists "topcon_geral"."ger_tribncm" (
  "ncm_cod" text,
  "ncm_exipi" text
);
create index if not exists "ix_ger_tribncm" on "topcon_geral"."ger_tribncm" ("ncm_cod", "ncm_exipi");
alter table "topcon_geral"."ger_tribncm" enable row level security;
create table if not exists "topcon_geral"."ger_tribncmcontrib" (
  "ncm_cod" text,
  "ncm_exipi" text,
  "ger_tribncmcontrib_dtinivig" date,
  "ger_tribcontrib_cod" text,
  "codfundlegal2" text,
  "ger_tribncmcontrib_idcadast" text,
  "ger_tribncmcontrib_idatual" text
);
create index if not exists "ix_ger_tribncmcontrib" on "topcon_geral"."ger_tribncmcontrib" ("ncm_cod", "ncm_exipi", "ger_tribncmcontrib_dtinivig");
alter table "topcon_geral"."ger_tribncmcontrib" enable row level security;
create table if not exists "topcon_geral"."ger_tribncmipi" (
  "ncm_cod" text,
  "ncm_exipi" text,
  "ger_tribncmipi_dtinivig" date,
  "fix_clenqipi_cod" text,
  "codfundlegal" text,
  "ger_tribncmipi_idcadast" text,
  "ger_tribncmipi_idatual" text,
  "ger_tribipi_cod" bigint
);
create index if not exists "ix_ger_tribncmipi" on "topcon_geral"."ger_tribncmipi" ("ncm_cod", "ncm_exipi", "ger_tribncmipi_dtinivig");
alter table "topcon_geral"."ger_tribncmipi" enable row level security;
create table if not exists "topcon_geral"."ger_versao" (
  "ger_versao_ano" bigint,
  "ger_versao_mes" bigint,
  "ger_versao_numversao" bigint
);
create index if not exists "ix_ger_versao" on "topcon_geral"."ger_versao" ("ger_versao_ano", "ger_versao_mes", "ger_versao_numversao");
alter table "topcon_geral"."ger_versao" enable row level security;
create table if not exists "topcon_geral"."usr_empresa" (
  "usr_usuario_id" text,
  "ger_empresa_cod" bigint
);
create index if not exists "ix_usr_empresa" on "topcon_geral"."usr_empresa" ("usr_usuario_id", "ger_empresa_cod");
alter table "topcon_geral"."usr_empresa" enable row level security;
create table if not exists "topcon_fixo"."fix_cep" (
  "fix_cep_cod" bigint,
  "fix_cep_logradouro" text,
  "fix_cep_uf" text,
  "fix_cep_bairro" text,
  "fix_cep_cidade" text,
  "fix_cep_tipo" text,
  "fix_cep_tipon" text
);
create index if not exists "ix_fix_cep" on "topcon_fixo"."fix_cep" ("fix_cep_cod");
alter table "topcon_fixo"."fix_cep" enable row level security;
create table if not exists "topcon_fixo"."fix_cfop" (
  "fix_cfop_cod" bigint,
  "fix_cfop_descr" text,
  "fix_cfop_descrred" text,
  "fix_cfop_dtinicio" date,
  "fix_cfop_versao" text,
  "fix_cfop_idcadast" text,
  "fix_cfop_idatual" text
);
create index if not exists "ix_fix_cfop" on "topcon_fixo"."fix_cfop" ("fix_cfop_cod");
alter table "topcon_fixo"."fix_cfop" enable row level security;
create table if not exists "topcon_fixo"."fix_estado" (
  "fix_estado_sigla" text,
  "fix_estado_nome" text
);
create index if not exists "ix_fix_estado" on "topcon_fixo"."fix_estado" ("fix_estado_sigla");
alter table "topcon_fixo"."fix_estado" enable row level security;
create table if not exists "topcon_fixo"."fix_municipio" (
  "fix_municipio_codoficial" bigint,
  "fix_municipio_nome" text,
  "fix_municipio_uf" text,
  "fix_municipio_codseq" bigint
);
create index if not exists "ix_fix_municipio" on "topcon_fixo"."fix_municipio" ("fix_municipio_codoficial");
alter table "topcon_fixo"."fix_municipio" enable row level security;
create table if not exists "topcon_fixo"."fix_ncm" (
  "fix_ncm_cod" text,
  "fix_ncm_exipi" text,
  "fix_ncm_descr" text,
  "fix_ncm_idcadast" text,
  "fix_ncm_idatual" text,
  "fix_ncm_inicio" date,
  "fix_ncm_fim" date,
  "fix_ncm_ato" text,
  "fix_ncm_numero" text,
  "fix_ncm_ano" bigint
);
create index if not exists "ix_fix_ncm" on "topcon_fixo"."fix_ncm" ("fix_ncm_cod", "fix_ncm_exipi");
alter table "topcon_fixo"."fix_ncm" enable row level security;
create table if not exists "topcon_fixo"."fix_paises" (
  "chavegeralcod" bigint,
  "fix_paises_cod" bigint,
  "fix_paises_descr" text,
  "fix_paises_idcadast" text,
  "fix_paises_idatual" text,
  "fix_paises_cod_iso" text
);
create index if not exists "ix_fix_paises" on "topcon_fixo"."fix_paises" ("chavegeralcod", "fix_paises_cod");
alter table "topcon_fixo"."fix_paises" enable row level security;

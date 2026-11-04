-- Correção: lpad corta números maiores que o tamanho pedido (114 virava "11").
-- A abertura de OS passa a manter todos os dígitos: 2026-09, 2026-114, 2026-1002.
-- (O arquivo 20261104000000 já foi corrigido; esta migração existe para o banco que rodou a versão antiga.)
create or replace function public.abrir_os(p_usina uuid, p_ano int, p_dados jsonb)
returns public.ordem_servico
language plpgsql security invoker set search_path = public as $$
declare
  v_seq int;
  v_os  public.ordem_servico;
begin
  v_seq := public.proxima_os(p_usina, p_ano);
  insert into public.ordem_servico (
    usina_id, ano, seq, numero, ativo_id, ativo_texto, classe, tipo, status, abertura,
    checklist, descricao, colaborador, oficina, nome_oficina, encarregado, obs, lote_obs,
    criado_por, criado_por_nome, atualizado_por_nome, origem
  ) values (
    p_usina, p_ano, v_seq, p_ano || '-' || lpad(v_seq::text, greatest(2, length(v_seq::text)), '0'),
    nullif(p_dados ->> 'ativo_id', '')::uuid,
    nullif(p_dados ->> 'ativo_texto', ''),
    nullif(p_dados ->> 'classe', ''),
    nullif(p_dados ->> 'tipo', ''),
    'Aberta',
    coalesce(nullif(p_dados ->> 'abertura', '')::date, current_date),
    nullif(p_dados ->> 'checklist', '')::date,
    nullif(p_dados ->> 'descricao', ''),
    nullif(p_dados ->> 'colaborador', ''),
    nullif(p_dados ->> 'oficina', ''),
    nullif(p_dados ->> 'nome_oficina', ''),
    nullif(p_dados ->> 'encarregado', ''),
    nullif(p_dados ->> 'obs', ''),
    nullif(p_dados ->> 'lote_obs', ''),
    auth.uid(),
    nullif(p_dados ->> 'por_nome', ''),
    nullif(p_dados ->> 'por_nome', ''),
    'lancado'
  ) returning * into v_os;
  return v_os;
end $$;

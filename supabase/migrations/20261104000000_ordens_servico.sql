-- =====================================================================
-- Plataforma MAC — Ordens de serviço
--  * campos que o artefato usava e faltavam: tipo de serviço, motivo do cancelamento, anexos
--  * abertura numerada numa transação só (o número não pula se a gravação falhar)
--  * OS concluída ou cancelada só muda pela gestão da usina; OS nunca é apagada
--  * fotos e PDFs (notas, orçamentos) num bucket privado, separado por usina
-- =====================================================================

alter table public.ordem_servico add column if not exists tipo          text;
alter table public.ordem_servico add column if not exists motivo_cancel text;
alter table public.ordem_servico add column if not exists anexos        jsonb not null default '[]'::jsonb;  -- [{caminho, nome, tipo, em}]
alter table public.ordem_servico add column if not exists nf_arquivos   jsonb not null default '[]'::jsonb;  -- nota do serviço de terceiro
alter table public.ordem_servico add column if not exists criado_por    uuid references public.pessoa(id);

-- Investimento existia no artefato (melhoria, peça nova que não é conserto)
alter table public.ordem_servico drop constraint if exists ordem_servico_classe_check;
alter table public.ordem_servico add constraint ordem_servico_classe_check
  check (classe in ('Preventiva', 'Corretiva', 'Investimento'));

alter table public.ordem_servico drop constraint if exists ordem_servico_status_check;
alter table public.ordem_servico add constraint ordem_servico_status_check
  check (status in ('Aberta', 'Em execução', 'Aguardando peça', 'Concluída', 'Cancelada'));

alter table public.ordem_servico drop constraint if exists ordem_servico_cancel_check;
alter table public.ordem_servico add constraint ordem_servico_cancel_check
  check (status <> 'Cancelada' or coalesce(btrim(motivo_cancel), '') <> '');

create index if not exists ordem_servico_status_idx on public.ordem_servico (usina_id, status);

-- ---------- abrir OS: numera e grava junto ----------
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
    p_usina, p_ano, v_seq, p_ano || '-' || lpad(v_seq::text, greatest(2, length(v_seq::text)), '0'),  -- lpad corta acima de 2 dígitos
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
revoke execute on function public.abrir_os(uuid, int, jsonb) from public, anon;
grant execute on function public.abrir_os(uuid, int, jsonb) to authenticated;

-- ---------- OS fechada só muda pela gestão; importada também ----------
create or replace function public.proteger_os()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then return new; end if;          -- manutenção feita pelo painel do Supabase
  if public.tem_papel(old.usina_id, array['gerente_usina']::public.papel[]) then return new; end if;
  if old.status in ('Concluída', 'Cancelada') then
    raise exception 'OS % já está %: só a gestão da usina altera', old.numero, lower(old.status);
  end if;
  if old.origem = 'importado' then
    raise exception 'OS % veio do sistema antigo: só a gestão da usina altera', old.numero;
  end if;
  if new.usina_id <> old.usina_id or new.numero <> old.numero or new.ano <> old.ano or new.seq <> old.seq then
    raise exception 'Número e usina da OS não mudam';
  end if;
  return new;
end $$;
revoke execute on function public.proteger_os() from public, anon, authenticated;

drop trigger if exists proteger_os on public.ordem_servico;
create trigger proteger_os before update on public.ordem_servico
  for each row execute function public.proteger_os();

-- ---------- anexos: bucket privado, primeira pasta = id da usina ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('anexos', 'anexos', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do update set file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

create or replace function public.usina_da_pasta(p_nome text)
returns uuid language sql immutable set search_path = public as $$
  select case when split_part(p_nome, '/', 1) ~ '^[0-9a-f-]{36}$' then split_part(p_nome, '/', 1)::uuid end
$$;

drop policy if exists anexos_ler on storage.objects;
create policy anexos_ler on storage.objects for select to authenticated
  using (bucket_id = 'anexos' and public.usina_da_pasta(name) in (select public.usinas_visiveis()));

drop policy if exists anexos_enviar on storage.objects;
create policy anexos_enviar on storage.objects for insert to authenticated
  with check (bucket_id = 'anexos'
              and public.tem_papel(public.usina_da_pasta(name), array['gerente_usina', 'lancador', 'administrativo']::public.papel[]));
-- sem update/delete: anexo enviado fica guardado

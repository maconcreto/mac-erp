-- =====================================================================
-- Plataforma MAC — Fase 1 — Frota e manutenção
-- Boletim diário (abastecimento, horímetro, hodômetro, produção), ordens de
-- serviço, consumo mensal e leitura atual de cada ativo.
-- Regras: cada registro pertence a uma usina; permissão garantida no banco (RLS);
-- nada se apaga sem ficar na auditoria.
-- =====================================================================

-- ---------- ativo: campos da frota ----------
alter table public.ativo
  add column if not exists grupo          text    not null default 'frota' check (grupo in ('frota', 'usina')),
  add column if not exists capacidade_m3  numeric,
  add column if not exists usa_hora       boolean not null default true,    -- controla horímetro
  add column if not exists usa_km         boolean not null default true,    -- controla hodômetro
  add column if not exists regra_consumo  boolean not null default true,    -- entra nos limites de L/m³
  add column if not exists fora_operacao  boolean not null default false,   -- ainda não opera
  add column if not exists betobomba      boolean not null default false,   -- carrega bomba acoplada
  add column if not exists bomba_id       uuid references public.ativo(id), -- bomba acoplada a este caminhão
  add column if not exists data_inicio    date,
  add column if not exists marcos         jsonb   not null default '[]'::jsonb, -- ex.: volume acumulado da usina por data
  add column if not exists obs            text;

-- ---------- atualizado_em automático ----------
create or replace function public.tocar_atualizado_em()
returns trigger language plpgsql set search_path = public as $$
begin
  new.atualizado_em := now();
  return new;
end $$;
revoke execute on function public.tocar_atualizado_em() from public, anon, authenticated;

-- ---------- boletim diário ----------
create table public.boletim (
  id               uuid primary key default gen_random_uuid(),
  usina_id         uuid not null references public.usina(id),
  data             date not null,
  status           text not null default 'aberto' check (status in ('aberto', 'fechado')),
  origem           text not null default 'lancado' check (origem in ('lancado', 'importado')),
  fonte            text,
  lancado_por      uuid references public.pessoa(id),
  lancado_por_nome text,
  criado_em        timestamptz not null default now(),
  atualizado_em    timestamptz not null default now(),
  unique (usina_id, data),
  unique (id, usina_id)
);

-- uma linha por ativo no dia (parado ou rodando)
create table public.boletim_item (
  id            uuid primary key default gen_random_uuid(),
  boletim_id    uuid not null,
  usina_id      uuid not null,
  ativo_id      uuid not null references public.ativo(id),
  parado        boolean not null default false,
  h0            numeric,        -- horímetro inicial / final
  h1            numeric,
  km0           numeric,        -- hodômetro inicial / final
  km1           numeric,
  hb0           numeric,        -- horímetro da bomba acoplada
  hb1           numeric,
  litros        numeric,
  preco         numeric,        -- R$ por litro
  valor         numeric,        -- R$ do abastecimento
  posto         text,
  cupom         text,           -- identificação da foto do cupom
  motorista     text,
  viagens       numeric,
  vb            numeric,        -- viagens da bomba acoplada
  m3            numeric,
  m3b           numeric,        -- m³ bombeados pela bomba acoplada
  justificativa text,
  sem_prod      text,           -- motivo de rodar sem produzir
  sit           text,
  obs           text,
  foreign key (boletim_id, usina_id) references public.boletim(id, usina_id) on delete cascade,
  unique (boletim_id, ativo_id)
);

-- ---------- ordens de serviço ----------
create table public.ordem_servico (
  id                  uuid primary key default gen_random_uuid(),
  usina_id            uuid not null references public.usina(id),
  ano                 int  not null,
  seq                 int  not null,
  numero              text not null,                 -- 2026-113
  numero_antigo       text,
  ativo_id            uuid references public.ativo(id),
  ativo_texto         text,                          -- quando o ativo não está no cadastro
  classe              text check (classe in ('Preventiva', 'Corretiva')),
  status              text not null default 'Aberta',
  abertura            date,
  inicio              date,
  termino             date,
  recebimento         date,
  checklist           date,                          -- data do check-list que originou a OS
  h_inicio            time,
  h_termino           time,
  horas               numeric,                       -- horímetro no serviço
  km                  numeric,
  m3                  numeric,                       -- produção acumulada no serviço
  oficina             text,                          -- Local / Externa
  nome_oficina        text,
  descricao           text,
  servicos            text,
  pecas               text,
  colaborador         text,
  encarregado         text,
  valor               numeric,
  nf                  text,
  pagamento           text,
  meses               numeric,
  lote_obs            text,
  obs                 text,
  compras             jsonb not null default '[]'::jsonb,  -- peças compradas (fornecedor, itens, NF, valor, anexos)
  origem              text not null default 'lancado' check (origem in ('lancado', 'importado')),
  criado_por_nome     text,
  atualizado_por_nome text,
  criado_em           timestamptz not null default now(),
  atualizado_em       timestamptz not null default now(),
  unique (usina_id, numero),
  unique (usina_id, ano, seq)
);

-- numeração sequencial por usina e ano
create table public.os_contador (
  usina_id uuid not null references public.usina(id),
  ano      int  not null,
  ultimo   int  not null default 0,
  primary key (usina_id, ano)
);

-- ---------- consumo e produção mensal por ativo ----------
create table public.consumo_mensal (
  id            uuid primary key default gen_random_uuid(),
  usina_id      uuid not null references public.usina(id),
  mes           date not null check (extract(day from mes) = 1),
  ativo_id      uuid not null references public.ativo(id),
  dias          int,
  horas         numeric,
  km            numeric,
  litros        numeric,
  viagens       numeric,
  volume_m3     numeric,
  motorista     text,
  capacidade_m3 numeric,
  faturamento   numeric,
  fonte         text,
  sobrescrito   boolean not null default false,   -- valor corrigido à mão sobre o calculado
  origem        text not null default 'lancado' check (origem in ('lancado', 'importado')),
  criado_em     timestamptz not null default now(),
  unique (usina_id, mes, ativo_id)
);

-- última leitura de horímetro/hodômetro de cada ativo
create table public.leitura_ativo (
  ativo_id      uuid primary key references public.ativo(id),
  usina_id      uuid not null references public.usina(id),
  data          date not null,
  horas         numeric,
  km            numeric,
  atualizado_em timestamptz not null default now()
);

create index on public.boletim (usina_id, data desc);
create index on public.boletim_item (ativo_id);
create index on public.boletim_item (usina_id);
create index on public.ordem_servico (usina_id, abertura desc);
create index on public.ordem_servico (ativo_id);
create index on public.consumo_mensal (usina_id, mes);
create index on public.consumo_mensal (ativo_id);
create index on public.leitura_ativo (usina_id);

create trigger boletim_atualizado before update on public.boletim
  for each row execute function public.tocar_atualizado_em();
create trigger os_atualizada before update on public.ordem_servico
  for each row execute function public.tocar_atualizado_em();
create trigger leitura_atualizada before update on public.leitura_ativo
  for each row execute function public.tocar_atualizado_em();

-- ---------- próximo número de OS (único jeito de mexer no contador) ----------
create or replace function public.proxima_os(p_usina uuid, p_ano int)
returns int language plpgsql security definer set search_path = public as $$
declare v int;
begin
  if not public.tem_papel(p_usina, array['gerente_usina', 'lancador']::public.papel[]) then
    raise exception 'Sem permissão para numerar OS desta usina';
  end if;
  insert into public.os_contador (usina_id, ano, ultimo) values (p_usina, p_ano, 1)
  on conflict (usina_id, ano) do update set ultimo = public.os_contador.ultimo + 1
  returning ultimo into v;
  return v;
end $$;
revoke execute on function public.proxima_os(uuid, int) from public, anon;
grant execute on function public.proxima_os(uuid, int) to authenticated;

-- ---------- auditoria ----------
do $$
declare t text;
begin
  foreach t in array array['boletim', 'boletim_item', 'ordem_servico', 'consumo_mensal', 'leitura_ativo'] loop
    execute format('create trigger aud_%1$s after insert or update or delete on public.%1$I
                    for each row execute function public.registrar_auditoria()', t);
  end loop;
end $$;

-- ---------- RLS ----------
alter table public.boletim        enable row level security;
alter table public.boletim_item   enable row level security;
alter table public.ordem_servico  enable row level security;
alter table public.os_contador    enable row level security;
alter table public.consumo_mensal enable row level security;
alter table public.leitura_ativo  enable row level security;

-- boletim: gerente e lançador lançam; todos da usina leem
create policy boletim_ler on public.boletim for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy boletim_criar on public.boletim for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));
create policy boletim_editar on public.boletim for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));

create policy boletim_item_ler on public.boletim_item for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy boletim_item_criar on public.boletim_item for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));
create policy boletim_item_editar on public.boletim_item for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));
create policy boletim_item_remover on public.boletim_item for delete to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));

-- ordens de serviço
create policy os_ler on public.ordem_servico for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy os_criar on public.ordem_servico for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));
create policy os_editar on public.ordem_servico for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));

-- contador: só leitura; quem numera é a função proxima_os
create policy os_contador_ler on public.os_contador for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));

-- consumo mensal: gestão da usina
create policy consumo_ler on public.consumo_mensal for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy consumo_criar on public.consumo_mensal for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));
create policy consumo_editar on public.consumo_mensal for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));

-- leitura atual
create policy leitura_ler on public.leitura_ativo for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy leitura_criar on public.leitura_ativo for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));
create policy leitura_editar on public.leitura_ativo for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina', 'lancador']::public.papel[]));

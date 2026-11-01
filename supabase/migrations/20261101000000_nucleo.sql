-- =====================================================================
-- Plataforma MAC — Fase 0 — Núcleo
-- empresa → usina → pessoas, acessos, ativos, materiais, parâmetros
-- Regras: tudo pertence a uma usina; permissão garantida no banco (RLS);
-- nada se apaga (situacao/ativo) e toda alteração vai para a auditoria.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------- tipos ----------
create type public.papel as enum (
  'diretoria',        -- vê e configura tudo
  'gerente_usina',    -- tudo da(s) sua(s) usina(s)
  'financeiro',       -- caixa e vencimentos das usinas liberadas
  'administrativo',   -- lançamentos administrativos da usina
  'comercial',        -- obras e propostas
  'lancador'          -- chão da usina: só as tarefas do seu setor
);

create type public.setor as enum (
  'operacao', 'balanca', 'laboratorio', 'administrativo', 'financeiro', 'comercial'
);

-- ---------- tabelas ----------
create table public.empresa (
  id         uuid primary key default gen_random_uuid(),
  nome       text not null,
  criado_em  timestamptz not null default now()
);

create table public.usina (
  id         uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresa(id),
  codigo     text not null check (codigo ~ '^[A-Z0-9]{2,6}$'),
  nome       text not null,
  cidade     text,
  uf         char(2),
  ativa      boolean not null default true,
  criado_em  timestamptz not null default now(),
  unique (empresa_id, codigo)
);

create table public.pessoa (
  id         uuid primary key references auth.users(id) on delete cascade,
  empresa_id uuid not null references public.empresa(id),
  nome       text not null default '',
  email      text,
  telefone   text,
  ativo      boolean not null default true,
  criado_em  timestamptz not null default now()
);

-- usina_id nulo = todas as usinas da empresa (só faz sentido para diretoria/financeiro)
create table public.pessoa_acesso (
  id         uuid primary key default gen_random_uuid(),
  pessoa_id  uuid not null references public.pessoa(id) on delete cascade,
  usina_id   uuid references public.usina(id),
  papel      public.papel not null,
  setores    public.setor[] not null default '{}',
  criado_em  timestamptz not null default now(),
  unique nulls not distinct (pessoa_id, usina_id, papel)
);

create table public.ativo (
  id         uuid primary key default gen_random_uuid(),
  usina_id   uuid not null references public.usina(id),
  codigo     text not null,               -- CB14, BL21, PC03…
  tipo       text not null,               -- Caminhão betoneira, Bomba lança…
  descricao  text,
  placa      text,
  ativo      boolean not null default true,
  criado_em  timestamptz not null default now(),
  unique (usina_id, codigo)
);

create table public.material (
  id          uuid primary key default gen_random_uuid(),
  empresa_id  uuid not null references public.empresa(id),
  grupo       text not null,              -- Cimento, Areia, Brita, Aditivo, Água…
  nome        text not null,
  unidade     text not null check (unidade in ('t','kg','m3','L','un','viagem')),
  densidade   numeric,                    -- t/m³, usado na cubagem
  ativo       boolean not null default true,
  criado_em   timestamptz not null default now(),
  unique (empresa_id, nome)
);

create table public.material_usina (
  usina_id    uuid not null references public.usina(id),
  material_id uuid not null references public.material(id),
  preco       numeric,                    -- R$ por unidade
  frete_t     numeric,                    -- R$ por tonelada
  tolerancia  numeric,                    -- fração, ex.: 0.02 = ±2%
  primary key (usina_id, material_id)
);

-- usina_id nulo = valor padrão do grupo; valor da usina prevalece
create table public.parametro (
  id         uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresa(id),
  usina_id   uuid references public.usina(id),
  chave      text not null,
  valor      jsonb not null,
  descricao  text,
  unique nulls not distinct (empresa_id, usina_id, chave)
);

create table public.auditoria (
  id          bigint generated always as identity primary key,
  tabela      text not null,
  registro_id text,
  acao        text not null,              -- INSERT / UPDATE / DELETE
  antes       jsonb,
  depois      jsonb,
  por         uuid,
  em          timestamptz not null default now()
);

create index on public.usina (empresa_id);
create index on public.pessoa_acesso (pessoa_id);
create index on public.pessoa_acesso (usina_id);
create index on public.ativo (usina_id);
create index on public.auditoria (tabela, registro_id);

-- ---------- funções de permissão (security definer: leem sem RLS) ----------
create or replace function public.minha_empresa()
returns uuid language sql stable security definer set search_path = public as $$
  select empresa_id from public.pessoa where id = auth.uid() and ativo
$$;

create or replace function public.e_diretoria()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.pessoa_acesso a join public.pessoa p on p.id = a.pessoa_id
    where a.pessoa_id = auth.uid() and p.ativo and a.papel = 'diretoria'
  )
$$;

-- usinas que a pessoa pode ver
create or replace function public.usinas_visiveis()
returns setof uuid language sql stable security definer set search_path = public as $$
  select u.id from public.usina u
  join public.pessoa p on p.id = auth.uid() and p.ativo and p.empresa_id = u.empresa_id
  where exists (
    select 1 from public.pessoa_acesso a
    where a.pessoa_id = p.id and (a.usina_id is null or a.usina_id = u.id)
  )
$$;

-- a pessoa tem um destes papéis nesta usina (ou em todas)?
create or replace function public.tem_papel(p_usina uuid, p_papeis public.papel[])
returns boolean language sql stable security definer set search_path = public as $$
  select public.e_diretoria() or exists (
    select 1 from public.pessoa_acesso a join public.pessoa p on p.id = a.pessoa_id
    where a.pessoa_id = auth.uid() and p.ativo
      and (a.usina_id is null or a.usina_id = p_usina)
      and a.papel = any (p_papeis)
  )
$$;

-- ---------- auditoria genérica ----------
create or replace function public.registrar_auditoria()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_id text;
begin
  v_id := coalesce(
    to_jsonb(coalesce(new, old)) ->> 'id',
    (to_jsonb(coalesce(new, old)) ->> 'usina_id') || ':' || (to_jsonb(coalesce(new, old)) ->> 'material_id')
  );
  insert into public.auditoria (tabela, registro_id, acao, antes, depois, por)
  values (tg_table_name, v_id, tg_op,
          case when tg_op <> 'INSERT' then to_jsonb(old) end,
          case when tg_op <> 'DELETE' then to_jsonb(new) end,
          auth.uid());
  return coalesce(new, old);
end $$;

do $$
declare t text;
begin
  foreach t in array array['usina','pessoa','pessoa_acesso','ativo','material','material_usina','parametro'] loop
    execute format('create trigger aud_%1$s after insert or update or delete on public.%1$I
                    for each row execute function public.registrar_auditoria()', t);
  end loop;
end $$;

-- ---------- quem não é diretoria não muda campos sensíveis do próprio cadastro ----------
create or replace function public.proteger_pessoa()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is not null and not public.e_diretoria() then
    if new.empresa_id is distinct from old.empresa_id
       or new.ativo is distinct from old.ativo
       or new.email is distinct from old.email then
      raise exception 'Somente a diretoria altera empresa, e-mail ou situação do cadastro';
    end if;
  end if;
  return new;
end $$;

create trigger proteger_pessoa before update on public.pessoa
  for each row execute function public.proteger_pessoa();

-- ---------- novo usuário: cria o cadastro; o primeiro vira diretoria ----------
create or replace function public.novo_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_empresa uuid;
begin
  select id into v_empresa from public.empresa order by criado_em limit 1;
  if v_empresa is null then
    insert into public.empresa (nome) values ('Marcos Andrade Concreto') returning id into v_empresa;
  end if;

  insert into public.pessoa (id, empresa_id, nome, email)
  values (new.id, v_empresa,
          coalesce(nullif(new.raw_user_meta_data ->> 'nome', ''), split_part(new.email, '@', 1)),
          new.email);

  if not exists (select 1 from public.pessoa_acesso where papel = 'diretoria') then
    insert into public.pessoa_acesso (pessoa_id, usina_id, papel, setores)
    values (new.id, null, 'diretoria',
            array['operacao','balanca','laboratorio','administrativo','financeiro','comercial']::public.setor[]);
  end if;
  return new;
end $$;

create trigger ao_criar_usuario after insert on auth.users
  for each row execute function public.novo_usuario();

-- ---------- RLS ----------
alter table public.empresa        enable row level security;
alter table public.usina          enable row level security;
alter table public.pessoa         enable row level security;
alter table public.pessoa_acesso  enable row level security;
alter table public.ativo          enable row level security;
alter table public.material       enable row level security;
alter table public.material_usina enable row level security;
alter table public.parametro      enable row level security;
alter table public.auditoria      enable row level security;

-- empresa
create policy empresa_ler on public.empresa for select to authenticated
  using (id = public.minha_empresa());
create policy empresa_editar on public.empresa for update to authenticated
  using (id = public.minha_empresa() and public.e_diretoria());

-- usina
create policy usina_ler on public.usina for select to authenticated
  using (id in (select public.usinas_visiveis()));
create policy usina_criar on public.usina for insert to authenticated
  with check (public.e_diretoria() and empresa_id = public.minha_empresa());
create policy usina_editar on public.usina for update to authenticated
  using (public.e_diretoria() and empresa_id = public.minha_empresa())
  with check (empresa_id = public.minha_empresa());

-- pessoa: cada um se vê; diretoria vê todos; gerente vê quem tem acesso às suas usinas
create policy pessoa_ler on public.pessoa for select to authenticated
  using (
    id = auth.uid()
    or (empresa_id = public.minha_empresa() and public.e_diretoria())
    or exists (
      select 1 from public.pessoa_acesso a
      where a.pessoa_id = pessoa.id and a.usina_id is not null
        and public.tem_papel(a.usina_id, array['gerente_usina']::public.papel[])
    )
  );
create policy pessoa_editar on public.pessoa for update to authenticated
  using (id = auth.uid() or (empresa_id = public.minha_empresa() and public.e_diretoria()))
  with check (empresa_id = public.minha_empresa());

-- acessos: só a diretoria concede; cada um vê os seus
create policy acesso_ler on public.pessoa_acesso for select to authenticated
  using (pessoa_id = auth.uid() or public.e_diretoria());
create policy acesso_criar on public.pessoa_acesso for insert to authenticated
  with check (public.e_diretoria());
create policy acesso_editar on public.pessoa_acesso for update to authenticated
  using (public.e_diretoria()) with check (public.e_diretoria());
create policy acesso_remover on public.pessoa_acesso for delete to authenticated
  using (public.e_diretoria() and pessoa_id <> auth.uid());

-- ativos
create policy ativo_ler on public.ativo for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy ativo_criar on public.ativo for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));
create policy ativo_editar on public.ativo for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));

-- materiais (catálogo do grupo) e valores por usina
create policy material_ler on public.material for select to authenticated
  using (empresa_id = public.minha_empresa());
create policy material_criar on public.material for insert to authenticated
  with check (public.e_diretoria() and empresa_id = public.minha_empresa());
create policy material_editar on public.material for update to authenticated
  using (public.e_diretoria() and empresa_id = public.minha_empresa())
  with check (empresa_id = public.minha_empresa());

create policy mu_ler on public.material_usina for select to authenticated
  using (usina_id in (select public.usinas_visiveis()));
create policy mu_criar on public.material_usina for insert to authenticated
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));
create policy mu_editar on public.material_usina for update to authenticated
  using (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]))
  with check (public.tem_papel(usina_id, array['gerente_usina']::public.papel[]));

-- parâmetros
create policy parametro_ler on public.parametro for select to authenticated
  using (empresa_id = public.minha_empresa()
         and (usina_id is null or usina_id in (select public.usinas_visiveis())));
create policy parametro_criar on public.parametro for insert to authenticated
  with check (public.e_diretoria() and empresa_id = public.minha_empresa());
create policy parametro_editar on public.parametro for update to authenticated
  using (public.e_diretoria() and empresa_id = public.minha_empresa())
  with check (empresa_id = public.minha_empresa());

-- auditoria: só leitura, só diretoria
create policy auditoria_ler on public.auditoria for select to authenticated
  using (public.e_diretoria());

-- sem DELETE nas tabelas de cadastro: desativa-se (ativo/ativa = false)

-- ---------- dados iniciais ----------
insert into public.empresa (nome) values ('Marcos Andrade Concreto');

insert into public.usina (empresa_id, codigo, nome, cidade, uf)
select id, 'VDC', 'Central Vitória da Conquista', 'Vitória da Conquista', 'BA' from public.empresa;

-- limites de consumo já validados no artefato (L/m³)
insert into public.parametro (empresa_id, chave, valor, descricao)
select id, k, v, d from public.empresa,
  (values
    ('limite_consumo_betoneira', '3.0'::jsonb, 'L/m³ acima do qual o boletim exige justificativa'),
    ('limite_consumo_bomba',     '1.5'::jsonb, 'L/m³ para bombas (horímetro do caminhão e da bomba)'),
    ('limite_consumo_implemento','1.0'::jsonb, 'L/m³ para o implemento da bomba'),
    ('preco_diesel_referencia',  '7.25'::jsonb, 'R$/L usado quando não há nota do posto')
  ) as p(k, v, d);

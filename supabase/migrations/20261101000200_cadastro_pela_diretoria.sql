-- Cadastro de usuários feito pela diretoria (com senha definida por ela).
-- O auto-cadastro só fica aberto enquanto não existir nenhuma Diretoria.

alter table public.pessoa add column if not exists cargo text;
alter table public.pessoa add column if not exists matricula text;

-- Ao criar o usuário, copia os dados informados pela diretoria para o cadastro.
create or replace function public.novo_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_empresa uuid;
  m jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  select id into v_empresa from public.empresa order by criado_em limit 1;
  if v_empresa is null then
    insert into public.empresa (nome) values ('Marcos Andrade Concreto') returning id into v_empresa;
  end if;

  insert into public.pessoa (id, empresa_id, nome, email, telefone, cargo, matricula)
  values (new.id, v_empresa,
          coalesce(nullif(m ->> 'nome', ''), split_part(new.email, '@', 1)),
          new.email,
          nullif(m ->> 'telefone', ''),
          nullif(m ->> 'cargo', ''),
          nullif(m ->> 'matricula', ''));

  if not exists (select 1 from public.pessoa_acesso where papel = 'diretoria') then
    insert into public.pessoa_acesso (pessoa_id, usina_id, papel, setores)
    values (new.id, null, 'diretoria',
            array['operacao','balanca','laboratorio','administrativo','financeiro','comercial']::public.setor[]);
  end if;
  return new;
end $$;

revoke execute on function public.novo_usuario() from public, anon, authenticated;

-- A tela de login pergunta se ainda pode mostrar "Criar conta" (só no primeiro acesso do sistema).
create or replace function public.cadastro_aberto()
returns boolean language sql stable security definer set search_path = public as $$
  select not exists (select 1 from public.pessoa_acesso where papel = 'diretoria')
$$;

revoke execute on function public.cadastro_aberto() from public;
grant execute on function public.cadastro_aberto() to anon, authenticated;

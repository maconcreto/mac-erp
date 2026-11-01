import { cache } from "react";
import { criarClienteServidor } from "./supabase/server";
import { PAPEIS_GESTAO, SETORES, type Acesso, type Pessoa, type Setor, type Usina } from "./tipos";

export type Sessao = {
  pessoa: Pessoa;
  acessos: Acesso[];
  usinas: Usina[];
  diretoria: boolean;
  gestor: boolean;
  setores: Setor[];
};

/** Carrega quem está logado, o que pode ver e as usinas visíveis. Uma vez por requisição. */
export const carregarSessao = cache(async (): Promise<Sessao | null> => {
  const supabase = await criarClienteServidor();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [pessoaRes, acessosRes, usinasRes] = await Promise.all([
    supabase.from("pessoa").select("id, nome, email, telefone, cargo, matricula, ativo").eq("id", user.id).maybeSingle(),
    supabase.from("pessoa_acesso").select("id, usina_id, papel, setores").eq("pessoa_id", user.id),
    supabase.from("usina").select("id, codigo, nome, cidade, uf, ativa").order("codigo"),
  ]);

  const pessoa: Pessoa = (pessoaRes.data as Pessoa | null) ?? {
    id: user.id,
    nome: user.email?.split("@")[0] ?? "",
    email: user.email ?? null,
    telefone: null,
    cargo: null,
    matricula: null,
    ativo: true,
  };
  const acessos = (acessosRes.data ?? []) as Acesso[];
  const usinas = (usinasRes.data ?? []) as Usina[];

  const diretoria = acessos.some((a) => a.papel === "diretoria");
  const gestor = acessos.some((a) => PAPEIS_GESTAO.includes(a.papel));
  const setores = diretoria
    ? [...SETORES]
    : SETORES.filter((s) => acessos.some((a) => a.setores?.includes(s)));

  return { pessoa, acessos, usinas, diretoria, gestor, setores };
});

export function primeiroNome(nome: string) {
  const p = nome.trim().split(/\s+/)[0] ?? "";
  return p.charAt(0).toUpperCase() + p.slice(1).toLowerCase();
}

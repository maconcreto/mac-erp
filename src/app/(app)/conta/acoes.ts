"use server";

import { revalidatePath } from "next/cache";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";

export type Resultado = { erro?: string; ok?: string };

export async function salvarMeusDados(_: Resultado, dados: FormData): Promise<Resultado> {
  const s = await carregarSessao();
  if (!s) return { erro: "Entre de novo no sistema." };
  const nome = String(dados.get("nome") ?? "").trim();
  if (!nome) return { erro: "Informe seu nome." };
  const supabase = await criarClienteServidor();
  const { error } = await supabase
    .from("pessoa")
    .update({ nome, telefone: String(dados.get("telefone") ?? "").trim() || null })
    .eq("id", s.pessoa.id);
  if (error) return { erro: "Não foi possível salvar." };
  revalidatePath("/", "layout");
  return { ok: "Dados salvos." };
}

export async function trocarMinhaSenha(_: Resultado, dados: FormData): Promise<Resultado> {
  const senha = String(dados.get("senha") ?? "");
  const confirma = String(dados.get("confirma") ?? "");
  if (senha.length < 8 || !/[A-Za-z]/.test(senha) || !/\d/.test(senha)) {
    return { erro: "A senha precisa ter 8 ou mais caracteres, com letras e números." };
  }
  if (senha !== confirma) return { erro: "As duas senhas não são iguais." };
  const supabase = await criarClienteServidor();
  const { error } = await supabase.auth.updateUser({ password: senha });
  if (error) {
    if (/same|different/i.test(error.message)) return { erro: "A nova senha precisa ser diferente da atual." };
    return { erro: "Não foi possível trocar a senha. Saia e entre de novo, depois tente outra vez." };
  }
  return { ok: "Senha trocada. Use a nova senha no próximo acesso." };
}

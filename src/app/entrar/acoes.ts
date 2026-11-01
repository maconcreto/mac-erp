"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { criarClienteServidor } from "@/lib/supabase/server";

export type EstadoEntrar = { erro?: string; ok?: string };

function traduzir(msg: string) {
  if (/invalid login credentials/i.test(msg)) return "E-mail ou senha incorretos.";
  if (/email not confirmed/i.test(msg)) return "Confirme seu e-mail antes de entrar. Veja a caixa de entrada.";
  if (/already registered/i.test(msg)) return "Este e-mail já tem conta. Use Entrar.";
  if (/password/i.test(msg)) return "A senha precisa ter pelo menos 6 caracteres.";
  return "Não foi possível concluir. Tente de novo.";
}

export async function entrar(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const email = String(dados.get("email") ?? "").trim();
  const senha = String(dados.get("senha") ?? "");
  if (!email || !senha) return { erro: "Preencha e-mail e senha." };

  const supabase = await criarClienteServidor();
  const { error } = await supabase.auth.signInWithPassword({ email, password: senha });
  if (error) return { erro: traduzir(error.message) };
  redirect("/");
}

export async function criarConta(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const nome = String(dados.get("nome") ?? "").trim();
  const email = String(dados.get("email") ?? "").trim();
  const senha = String(dados.get("senha") ?? "");
  if (!nome || !email || senha.length < 6) return { erro: "Preencha nome, e-mail e uma senha de 6 ou mais caracteres." };

  const h = await headers();
  const origem = h.get("origin") ?? `https://${h.get("host")}`;
  const supabase = await criarClienteServidor();
  const { data, error } = await supabase.auth.signUp({
    email,
    password: senha,
    options: { data: { nome }, emailRedirectTo: `${origem}/auth/callback` },
  });
  if (error) return { erro: traduzir(error.message) };
  if (data.session) redirect("/");
  return { ok: "Conta criada. Abra o e-mail que enviamos e toque no link para confirmar." };
}

export async function sair() {
  const supabase = await criarClienteServidor();
  await supabase.auth.signOut();
  redirect("/entrar");
}

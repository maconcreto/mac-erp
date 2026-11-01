"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { criarClienteServidor } from "@/lib/supabase/server";

export type EstadoEntrar = { erro?: string; ok?: string; etapa?: "codigo" };

function traduzir(msg: string) {
  if (/invalid login credentials/i.test(msg)) return "E-mail ou senha incorretos.";
  if (/email not confirmed/i.test(msg)) return "Confirme seu e-mail antes de entrar. Veja a caixa de entrada.";
  if (/banned|blocked/i.test(msg)) return "Seu acesso está desativado. Fale com o gestor.";
  if (/already registered/i.test(msg)) return "Este e-mail já tem conta. Use Entrar.";
  if (/rate limit|too many/i.test(msg)) return "Muitas tentativas. Aguarde alguns minutos.";
  if (/expired|invalid/i.test(msg)) return "Código inválido ou vencido. Peça outro.";
  if (/password/i.test(msg)) return "A senha precisa ter pelo menos 8 caracteres, com letras e números.";
  return "Não foi possível concluir. Tente de novo.";
}

async function origem() {
  const h = await headers();
  return h.get("origin") ?? `https://${h.get("host")}`;
}

export async function entrar(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const email = String(dados.get("email") ?? "").trim().toLowerCase();
  const senha = String(dados.get("senha") ?? "");
  if (!email || !senha) return { erro: "Preencha e-mail e senha." };

  const supabase = await criarClienteServidor();
  const { error } = await supabase.auth.signInWithPassword({ email, password: senha });
  if (error) return { erro: traduzir(error.message) };
  redirect("/");
}

/** Só funciona enquanto o sistema não tem nenhuma Diretoria (primeiro acesso). */
export async function criarConta(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const nome = String(dados.get("nome") ?? "").trim();
  const email = String(dados.get("email") ?? "").trim().toLowerCase();
  const senha = String(dados.get("senha") ?? "");
  if (!nome || !email || senha.length < 8) return { erro: "Preencha nome, e-mail e uma senha de 8 ou mais caracteres." };

  const supabase = await criarClienteServidor();
  const { data: aberto } = await supabase.rpc("cadastro_aberto");
  if (!aberto) return { erro: "O cadastro é feito pela diretoria. Peça seu acesso ao gestor." };

  const { data, error } = await supabase.auth.signUp({
    email,
    password: senha,
    options: { data: { nome }, emailRedirectTo: `${await origem()}/auth/callback` },
  });
  if (error) return { erro: traduzir(error.message) };
  if (data.session) redirect("/");
  return { ok: "Conta criada. Abra o e-mail que enviamos e toque no link para confirmar." };
}

/** Envia o e-mail de recuperação (link + código). Responde igual exista ou não o e-mail. */
export async function enviarRecuperacao(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const email = String(dados.get("email") ?? "").trim().toLowerCase();
  if (!/^\S+@\S+\.\S+$/.test(email)) return { erro: "Informe seu e-mail." };
  const supabase = await criarClienteServidor();
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${await origem()}/auth/callback?next=${encodeURIComponent("/conta?nova_senha=1")}`,
  });
  if (error && /rate limit|too many/i.test(error.message)) return { erro: traduzir(error.message) };
  return { etapa: "codigo", ok: "Se o e-mail estiver cadastrado, você vai receber um link e um código em instantes." };
}

/** Recupera com o código do e-mail (funciona mesmo abrindo o e-mail em outro aparelho). */
export async function redefinirComCodigo(_: EstadoEntrar, dados: FormData): Promise<EstadoEntrar> {
  const email = String(dados.get("email") ?? "").trim().toLowerCase();
  const codigo = String(dados.get("codigo") ?? "").replace(/\D/g, "");
  const senha = String(dados.get("senha") ?? "");
  if (codigo.length < 6) return { etapa: "codigo", erro: "Digite o código que chegou no e-mail." };
  if (senha.length < 8 || !/[A-Za-z]/.test(senha) || !/\d/.test(senha)) {
    return { etapa: "codigo", erro: "A nova senha precisa ter 8 ou mais caracteres, com letras e números." };
  }

  const supabase = await criarClienteServidor();
  const { error } = await supabase.auth.verifyOtp({ email, token: codigo, type: "recovery" });
  if (error) return { etapa: "codigo", erro: traduzir(error.message) };
  const { error: erroSenha } = await supabase.auth.updateUser({ password: senha });
  if (erroSenha) return { etapa: "codigo", erro: traduzir(erroSenha.message) };
  redirect("/");
}

export async function sair() {
  const supabase = await criarClienteServidor();
  await supabase.auth.signOut();
  redirect("/entrar");
}

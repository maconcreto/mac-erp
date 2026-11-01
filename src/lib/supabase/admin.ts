import { createClient } from "@supabase/supabase-js";
import { SUPABASE_URL } from "./config";

/*
 * Cliente com a chave de serviço do Supabase. Só pode ser usado em código de servidor
 * (server actions e rotas), nunca importado por componente "use client".
 * Serve para a diretoria criar usuários, definir senhas e bloquear acessos.
 */
const CHAVE_SERVICO = process.env.SUPABASE_SERVICE_ROLE_KEY ?? process.env.SUPABASE_SECRET_KEY ?? "";

export const adminConfigurado = Boolean(SUPABASE_URL && CHAVE_SERVICO);

export function criarClienteAdmin() {
  if (!adminConfigurado) throw new Error("Chave de serviço do Supabase não configurada na Vercel.");
  return createClient(SUPABASE_URL, CHAVE_SERVICO, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

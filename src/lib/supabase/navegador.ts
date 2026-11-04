"use client";

import { createBrowserClient } from "@supabase/ssr";
import { SUPABASE_KEY, SUPABASE_URL } from "./config";

/** Cliente do navegador: usado só para enviar fotos e PDFs direto ao armazenamento (as regras do banco valem igual). */
let cliente: ReturnType<typeof createBrowserClient> | null = null;
export function clienteNavegador() {
  if (!cliente) cliente = createBrowserClient(SUPABASE_URL, SUPABASE_KEY);
  return cliente;
}

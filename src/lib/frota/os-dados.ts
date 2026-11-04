import type { SupabaseClient } from "@supabase/supabase-js";
import { CAMPOS_OS, type Arquivo, type AtivoOS, type Compra, type LeituraOS, type OS } from "./os";

export const BUCKET = "anexos";

function lista<T>(v: unknown): T[] {
  return Array.isArray(v) ? (v as T[]) : [];
}

export function normalizarOS(r: Record<string, unknown>): OS {
  return {
    ...(r as unknown as OS),
    compras: lista<Compra>(r.compras).map((c) => ({ ...c, arquivos: lista<Arquivo>(c.arquivos) })),
    anexos: lista<Arquivo>(r.anexos),
    nf_arquivos: lista<Arquivo>(r.nf_arquivos),
  };
}

export async function ativosDaUsina(supabase: SupabaseClient, usinaId: string): Promise<AtivoOS[]> {
  const { data } = await supabase
    .from("ativo")
    .select("id, codigo, tipo, grupo, usa_km, usa_hora")
    .eq("usina_id", usinaId)
    .eq("ativo", true);
  return ((data ?? []) as AtivoOS[]).sort(
    (a, b) => Number(a.grupo !== "frota") - Number(b.grupo !== "frota") || a.codigo.localeCompare(b.codigo, "pt-BR", { numeric: true }),
  );
}

export async function leituraDe(supabase: SupabaseClient, ativoId: string | null): Promise<LeituraOS | null> {
  if (!ativoId) return null;
  const { data } = await supabase.from("leitura_ativo").select("km, horas, data").eq("ativo_id", ativoId).maybeSingle();
  return (data as LeituraOS | null) ?? null;
}

export async function carregarOS(supabase: SupabaseClient, id: string): Promise<OS | null> {
  if (!/^[0-9a-f-]{36}$/.test(id)) return null;
  const { data } = await supabase.from("ordem_servico").select(CAMPOS_OS).eq("id", id).maybeSingle();
  return data ? normalizarOS(data as unknown as Record<string, unknown>) : null;
}

/** Endereços temporários (1 h) para ver os anexos guardados no bucket privado. */
export async function enderecosAnexos(supabase: SupabaseClient, os: OS): Promise<Record<string, string>> {
  const caminhos = [
    ...os.anexos,
    ...os.nf_arquivos,
    ...os.compras.flatMap((c) => c.arquivos),
  ]
    .map((a) => a.caminho)
    .filter((c): c is string => !!c);
  if (!caminhos.length) return {};
  const { data } = await supabase.storage.from(BUCKET).createSignedUrls(caminhos, 3600);
  const out: Record<string, string> = {};
  for (const d of data ?? []) if (d.path && d.signedUrl) out[d.path] = d.signedUrl;
  return out;
}

"use client";

import { clienteNavegador } from "./supabase/navegador";

export type ArquivoEnviado = { caminho: string; nome: string; tipo: string; em: string };

const LADO_MAX = 1800;

/** Reduz a foto do celular (5–8 MB) para ~300 KB antes de enviar. PDF e formatos que o navegador não abre vão como estão. */
async function reduzir(arq: File): Promise<Blob> {
  if (!arq.type.startsWith("image/") || arq.type === "image/gif") return arq;
  try {
    const bmp = await createImageBitmap(arq);
    const escala = Math.min(1, LADO_MAX / Math.max(bmp.width, bmp.height));
    if (escala === 1 && arq.size < 900_000) return arq;
    const c = document.createElement("canvas");
    c.width = Math.round(bmp.width * escala);
    c.height = Math.round(bmp.height * escala);
    c.getContext("2d")!.drawImage(bmp, 0, 0, c.width, c.height);
    const blob = await new Promise<Blob | null>((ok) => c.toBlob(ok, "image/jpeg", 0.8));
    return blob ?? arq;
  } catch {
    return arq; // HEIC em navegador que não abre: segue o original
  }
}

/** Envia para o bucket privado `anexos`, na pasta da usina. As regras do banco conferem a permissão. */
export async function enviarAnexo(usinaId: string, pasta: string, arq: File): Promise<ArquivoEnviado> {
  const corpo = await reduzir(arq);
  const tipo = corpo.type || arq.type || "application/octet-stream";
  const ext = tipo === "application/pdf" ? "pdf" : tipo === "image/png" ? "png" : tipo === "image/heic" ? "heic" : "jpg";
  const caminho = `${usinaId}/${pasta}/${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const { error } = await clienteNavegador().storage.from("anexos").upload(caminho, corpo, { contentType: tipo, upsert: false });
  if (error) {
    if (/mime|type/i.test(error.message)) throw new Error("Tipo de arquivo não aceito. Envie foto (JPG, PNG) ou PDF.");
    if (/size|large/i.test(error.message)) throw new Error("Arquivo grande demais (máximo 10 MB).");
    throw new Error("Não foi possível enviar o arquivo. Confira a internet e tente de novo.");
  }
  return { caminho, nome: arq.name || "foto.jpg", tipo, em: new Date().toISOString() };
}

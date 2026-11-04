"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { carregarSessao } from "@/lib/sessao";
import { COOKIE_USINA, TODAS, podeVerTodas, usinasAtivas } from "@/lib/usina-atual";

/** codigo = código da usina, ou "TODAS" para a visão consolidada. */
export async function escolherUsina(codigo: string) {
  const s = await carregarSessao();
  if (!s) return;
  const valido = codigo === TODAS ? podeVerTodas(s) : usinasAtivas(s).some((u) => u.codigo === codigo);
  if (!valido) return;
  (await cookies()).set(COOKIE_USINA, codigo, {
    path: "/",
    maxAge: 60 * 60 * 24 * 365,
    sameSite: "lax",
    secure: true,
    httpOnly: true,
  });
  revalidatePath("/", "layout");
}

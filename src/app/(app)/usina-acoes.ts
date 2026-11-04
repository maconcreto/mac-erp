"use server";

import { cookies } from "next/headers";
import { revalidatePath } from "next/cache";
import { carregarSessao } from "@/lib/sessao";
import { COOKIE_USINA, usinasAtivas } from "@/lib/usina-atual";

export async function escolherUsina(codigo: string) {
  const s = await carregarSessao();
  if (!s || !usinasAtivas(s).some((u) => u.codigo === codigo)) return;
  (await cookies()).set(COOKIE_USINA, codigo, {
    path: "/",
    maxAge: 60 * 60 * 24 * 365,
    sameSite: "lax",
    secure: true,
    httpOnly: true,
  });
  revalidatePath("/", "layout");
}

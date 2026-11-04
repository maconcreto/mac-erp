import { cache } from "react";
import { cookies } from "next/headers";
import type { Sessao } from "./sessao";
import type { Usina } from "./tipos";

/** A usina em que a pessoa está trabalhando. Escolhida no cabeçalho e lembrada no aparelho. */
export const COOKIE_USINA = "mac_usina";

export const usinasAtivas = (s: Sessao) => s.usinas.filter((u) => u.ativa);

export const usinaAtual = cache(async (s: Sessao): Promise<Usina | null> => {
  const ativas = usinasAtivas(s);
  if (!ativas.length) return null;
  const codigo = (await cookies()).get(COOKIE_USINA)?.value;
  return ativas.find((u) => u.codigo === codigo) ?? ativas[0];
});

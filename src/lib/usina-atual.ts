import { cache } from "react";
import { cookies } from "next/headers";
import type { Sessao } from "./sessao";
import type { Usina } from "./tipos";

/** A usina em que a pessoa está trabalhando. Escolhida no cabeçalho e lembrada no aparelho. */
export const COOKIE_USINA = "mac_usina";
/** Valor do cookie para a visão consolidada (só para quem vê mais de uma usina). */
export const TODAS = "TODAS";

export const usinasAtivas = (s: Sessao) => s.usinas.filter((u) => u.ativa);
export const podeVerTodas = (s: Sessao) => usinasAtivas(s).length > 1;

export type Escolha = { todas: true; usina: null; usinas: Usina[] } | { todas: false; usina: Usina; usinas: Usina[] };

/** O que está escolhido no topo: uma usina, ou todas (visão consolidada). */
export const escolhaUsina = cache(async (s: Sessao): Promise<Escolha | null> => {
  const ativas = usinasAtivas(s);
  if (!ativas.length) return null;
  const valor = (await cookies()).get(COOKIE_USINA)?.value;
  if (valor === TODAS && ativas.length > 1) return { todas: true, usina: null, usinas: ativas };
  return { todas: false, usina: ativas.find((u) => u.codigo === valor) ?? ativas[0], usinas: ativas };
});

/** Para telas de lançamento, que trabalham numa usina só. Com "Todas" escolhido, devolve null. */
export async function usinaAtual(s: Sessao): Promise<Usina | null> {
  return (await escolhaUsina(s))?.usina ?? null;
}

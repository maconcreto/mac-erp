import type { Sessao } from "@/lib/sessao";

/** Diretoria e gerente da usina podem lançar fora de ordem e corrigir dias fechados. */
export function gestorDaUsina(s: Sessao, usinaId: string) {
  return s.acessos.some((a) => a.papel === "diretoria" || (a.papel === "gerente_usina" && (a.usina_id === null || a.usina_id === usinaId)));
}

/** Quem pode abrir o boletim: gestão da usina ou setor de operação. */
export function podeLancarBoletim(s: Sessao, usinaId: string) {
  return (
    gestorDaUsina(s, usinaId) ||
    s.acessos.some((a) => (a.usina_id === null || a.usina_id === usinaId) && a.setores?.includes("operacao"))
  );
}

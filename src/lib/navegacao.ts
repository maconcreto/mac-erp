import type { Sessao } from "./sessao";
import { TAREFAS, type IconeTarefa } from "./tarefas";
import { NOME_SETOR, SETORES, type Setor } from "./tipos";

/** Telas que já existem no sistema novo. As demais aparecem como "Em breve" (só para a gestão). */
export const PRONTAS = new Set(["boletim", "os"]);

export type ItemMenu = { href: string; titulo: string; icone: IconeTarefa | "inicio" | "painel" | "usinas" | "equipe"; emBreve?: boolean };
export type GrupoMenu = { titulo: string; itens: ItemMenu[] };

export function hrefTarefa(slug: string) {
  return `/tarefa/${slug}`;
}

/**
 * Menu montado a partir do que a pessoa pode fazer.
 * Lançador vê só o que já funciona no setor dele; a gestão vê também o que está a caminho.
 */
export function montarMenu(s: Sessao) {
  const principal: ItemMenu[] = [{ href: "/", titulo: "Início", icone: "inicio" }];
  if (s.gestor) principal.push({ href: "/gestao", titulo: "Painel de Gestão", icone: "painel" });

  const modulos: GrupoMenu[] = [];
  const emBreve: ItemMenu[] = [];
  for (const setor of SETORES as readonly Setor[]) {
    if (!s.setores.includes(setor)) continue;
    const doSetor = TAREFAS.filter((t) => t.setor === setor);
    const prontas = doSetor.filter((t) => PRONTAS.has(t.slug));
    if (prontas.length) modulos.push({ titulo: NOME_SETOR[setor], itens: prontas.map((t) => ({ href: hrefTarefa(t.slug), titulo: t.titulo, icone: t.icone })) });
    if (s.gestor) emBreve.push(...doSetor.filter((t) => !PRONTAS.has(t.slug)).map((t) => ({ href: hrefTarefa(t.slug), titulo: t.titulo, icone: t.icone, emBreve: true })));
  }

  const configuracoes: ItemMenu[] = s.diretoria
    ? [
        { href: "/cadastros/usinas", titulo: "Usinas", icone: "usinas" },
        { href: "/cadastros/pessoas", titulo: "Equipe e acessos", icone: "equipe" },
      ]
    : [];

  return { principal, modulos, emBreve, configuracoes };
}

export type Menu = ReturnType<typeof montarMenu>;

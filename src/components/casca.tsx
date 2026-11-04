"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { ChevronDown, Clock, Factory, Home, LayoutDashboard, LogOut, Menu as IconeMenu, Settings, Users, X } from "lucide-react";
import { sair } from "@/app/entrar/acoes";
import type { ItemMenu, Menu } from "@/lib/navegacao";
import { IconeTarefaSvg } from "./icone-tarefa";
import { Logo } from "./ui";

type Pessoa = { nome: string; papel: string; inicial: string };
type Props = { menu: Menu; pessoa: Pessoa; seletor: ReactNode; children: ReactNode };

/**
 * Estrutura de todas as telas logadas.
 * Topo: usina de trabalho à esquerda, logo no centro, ☰ à direita.
 * O menu (com o perfil) abre pela direita, por cima da tela, no celular e no computador.
 */
export function Casca({ menu, pessoa, seletor, children }: Props) {
  const [aberto, setAberto] = useState(false);
  const caminho = usePathname();

  useEffect(() => setAberto(false), [caminho]);
  useEffect(() => {
    if (!aberto) return;
    const esc = (e: KeyboardEvent) => e.key === "Escape" && setAberto(false);
    document.addEventListener("keydown", esc);
    const antes = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", esc);
      document.body.style.overflow = antes;
    };
  }, [aberto]);

  return (
    <div className="min-h-dvh">
      {/* ---------- menu: gaveta que abre pela direita, em qualquer tela ---------- */}
      {aberto ? (
        <div className="fixed inset-0 z-40" role="dialog" aria-modal="true" aria-label="Menu">
          <button type="button" aria-label="Fechar menu" onClick={() => setAberto(false)} className="absolute inset-0 bg-black/55" />
          <div className="absolute inset-y-0 right-0 w-[min(340px,88vw)] shadow-2xl">
            <Lateral menu={menu} pessoa={pessoa} caminho={caminho} aoFechar={() => setAberto(false)} />
          </div>
        </div>
      ) : null}

      {/* ---------- topo: usina à esquerda, logo no centro, menu à direita ---------- */}
      <header className="sticky top-0 z-20 border-b-[3px] border-marca bg-marca-preto pt-[env(safe-area-inset-top)] text-[#f2f5ee]">
        {/* 3 colunas: as laterais têm a mesma largura, então a logo fica sempre no meio exato */}
        <div className="mx-auto grid max-w-6xl grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)] items-center gap-2 py-2.5 pl-[max(12px,env(safe-area-inset-left))] pr-[max(12px,env(safe-area-inset-right))] sm:gap-4">
          <div className="flex min-w-0 justify-start">{seletor}</div>
          <Link href="/" aria-label="Início" className="flex min-h-12 items-center justify-center">
            <Logo variante="simbolo" className="w-10 sm:hidden" />
            <Logo variante="horizontal" className="hidden w-44 sm:block" />
          </Link>
          <div className="flex justify-end">
            <button
              type="button"
              onClick={() => setAberto(true)}
              aria-label="Abrir menu"
              aria-expanded={aberto}
              className="flex size-12 shrink-0 items-center justify-center rounded-xl hover:bg-white/10"
            >
              <IconeMenu className="size-7" />
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-6xl px-4 pb-16 pt-6 lg:px-8">{children}</main>
    </div>
  );
}

function ativo(caminho: string, href: string) {
  return href === "/" ? caminho === "/" : caminho === href || caminho.startsWith(href + "/");
}

function Icone({ item, className }: { item: ItemMenu; className: string }) {
  if (item.icone === "inicio") return <Home className={className} aria-hidden />;
  if (item.icone === "painel") return <LayoutDashboard className={className} aria-hidden />;
  if (item.icone === "usinas") return <Factory className={className} aria-hidden />;
  if (item.icone === "equipe") return <Users className={className} aria-hidden />;
  return <IconeTarefaSvg nome={item.icone} className={className} />;
}

function Item({ item, caminho, recuo = false }: { item: ItemMenu; caminho: string; recuo?: boolean }) {
  const marcado = ativo(caminho, item.href);
  if (item.emBreve) {
    return (
      <li>
        <span className={`flex min-h-11 items-center gap-3 rounded-xl px-3 text-[15px] text-[#8d9686] ${recuo ? "pl-10" : ""}`}>
          <Icone item={item} className="size-5 shrink-0" />
          <span className="min-w-0 flex-1 truncate">{item.titulo}</span>
        </span>
      </li>
    );
  }
  return (
    <li>
      <Link
        href={item.href}
        aria-current={marcado ? "page" : undefined}
        className={`flex min-h-12 items-center gap-3 rounded-xl px-3 text-[15px] font-semibold transition ${recuo ? "pl-10" : ""} ${
          marcado ? "bg-marca text-marca-preto" : "text-[#e9eee3] hover:bg-white/8"
        }`}
      >
        <Icone item={item} className="size-5 shrink-0" />
        <span className="min-w-0 flex-1 truncate">{item.titulo}</span>
      </Link>
    </li>
  );
}

function Grupo({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-1">
      <h2 className="px-3 pb-1 pt-3 text-[11px] font-bold uppercase tracking-[.14em] text-[#8d9686]">{titulo}</h2>
      <ul className="flex flex-col gap-0.5">{children}</ul>
    </div>
  );
}

function Lateral({ menu, pessoa, caminho, aoFechar }: { menu: Menu; pessoa: Pessoa; caminho: string; aoFechar?: () => void }) {
  const naConfig = menu.configuracoes.some((i) => ativo(caminho, i.href)) || caminho === "/cadastros";
  const [config, setConfig] = useState(naConfig);
  const [breve, setBreve] = useState(false);

  return (
    <nav aria-label="Menu principal" className="flex h-full flex-col bg-marca-preto pb-[env(safe-area-inset-bottom)] pt-[env(safe-area-inset-top)] text-[#e9eee3]">
      <div className="flex items-center justify-between gap-2 border-b border-white/10 px-4 py-4">
        <span className="font-display text-xl font-extrabold">Menu</span>
        {aoFechar ? (
          <button type="button" onClick={aoFechar} aria-label="Fechar menu" className="flex size-11 items-center justify-center rounded-xl hover:bg-white/10">
            <X className="size-6" />
          </button>
        ) : null}
      </div>

      <div className="flex min-h-0 flex-1 flex-col gap-2 overflow-y-auto px-3 py-3">
        {/* perfil */}
        <Link
          href="/conta"
          aria-current={ativo(caminho, "/conta") ? "page" : undefined}
          className={`flex min-h-16 items-center gap-3 rounded-2xl border px-3 py-2 ${
            ativo(caminho, "/conta") ? "border-marca bg-white/8" : "border-white/10 hover:bg-white/5"
          }`}
        >
          <span className="flex size-11 shrink-0 items-center justify-center rounded-full bg-marca font-display text-lg font-extrabold text-marca-preto">{pessoa.inicial}</span>
          <span className="flex min-w-0 flex-col">
            <span className="truncate font-semibold">{pessoa.nome}</span>
            <span className="truncate text-sm text-[#a9b2a2]">{pessoa.papel} · Perfil</span>
          </span>
        </Link>

        <ul className="flex flex-col gap-0.5 pt-1">
          {menu.principal.map((i) => (
            <Item key={i.href} item={i} caminho={caminho} />
          ))}
        </ul>

        {menu.modulos.map((g) => (
          <Grupo key={g.titulo} titulo={g.titulo}>
            {g.itens.map((i) => (
              <Item key={i.href} item={i} caminho={caminho} />
            ))}
          </Grupo>
        ))}

        {menu.emBreve.length ? (
          <div className="flex flex-col gap-1 pt-2">
            <button
              type="button"
              onClick={() => setBreve(!breve)}
              aria-expanded={breve}
              className="flex min-h-11 items-center gap-3 rounded-xl px-3 text-left text-[15px] font-semibold text-[#a9b2a2] hover:bg-white/5"
            >
              <Clock className="size-5 shrink-0" aria-hidden />
              <span className="flex-1">Em breve ({menu.emBreve.length})</span>
              <ChevronDown className={`size-4 transition ${breve ? "rotate-180" : ""}`} aria-hidden />
            </button>
            {breve ? (
              <ul className="flex flex-col gap-0.5">
                {menu.emBreve.map((i) => (
                  <Item key={i.href} item={i} caminho={caminho} recuo />
                ))}
              </ul>
            ) : null}
          </div>
        ) : null}

        {menu.configuracoes.length ? (
          <div className="mt-auto flex flex-col gap-1 border-t border-white/10 pt-3">
            <button
              type="button"
              onClick={() => setConfig(!config)}
              aria-expanded={config}
              className="flex min-h-12 items-center gap-3 rounded-xl px-3 text-left text-[15px] font-semibold hover:bg-white/8"
            >
              <Settings className="size-5 shrink-0" aria-hidden />
              <span className="flex-1">Configurações</span>
              <ChevronDown className={`size-4 transition ${config ? "rotate-180" : ""}`} aria-hidden />
            </button>
            {config ? (
              <div className="flex flex-col gap-0.5">
                <p className="pl-10 pt-1 text-[11px] font-bold uppercase tracking-[.14em] text-[#8d9686]">Cadastros</p>
                <ul className="flex flex-col gap-0.5">
                  {menu.configuracoes.map((i) => (
                    <Item key={i.href} item={i} caminho={caminho} recuo />
                  ))}
                </ul>
              </div>
            ) : null}
          </div>
        ) : null}
      </div>

      <form action={sair} className="border-t border-white/10 p-3">
        <button type="submit" className="flex min-h-12 w-full items-center gap-3 rounded-xl px-3 text-left text-[15px] font-semibold text-[#f5a59d] hover:bg-white/8">
          <LogOut className="size-5 shrink-0" aria-hidden /> Sair
        </button>
      </form>
    </nav>
  );
}

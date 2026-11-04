"use client";

import { useRouter } from "next/navigation";
import { useEffect, useRef, useState, useTransition } from "react";
import { Check, ChevronDown, Factory, Layers } from "lucide-react";
import { escolherUsina } from "@/app/(app)/usina-acoes";

type U = { codigo: string; nome: string; cidade: string | null };
const TODAS = "TODAS";

/**
 * Usina de trabalho, sempre visível no topo.
 * `atual` null = "Todas as usinas" (visão consolidada). Com uma usina só, mostra o nome sem opção de trocar.
 */
export function SeletorUsina({ atual, usinas }: { atual: U | null; usinas: U[] }) {
  const router = useRouter();
  const [aberto, setAberto] = useState(false);
  const [trocando, iniciar] = useTransition();
  const caixa = useRef<HTMLDivElement>(null);
  const todas = atual === null;

  useEffect(() => {
    if (!aberto) return;
    const fora = (e: MouseEvent | TouchEvent) => {
      if (caixa.current && !caixa.current.contains(e.target as Node)) setAberto(false);
    };
    const esc = (e: KeyboardEvent) => e.key === "Escape" && setAberto(false);
    document.addEventListener("mousedown", fora);
    document.addEventListener("touchstart", fora);
    document.addEventListener("keydown", esc);
    return () => {
      document.removeEventListener("mousedown", fora);
      document.removeEventListener("touchstart", fora);
      document.removeEventListener("keydown", esc);
    };
  }, [aberto]);

  function escolher(codigo: string, marcada: boolean) {
    setAberto(false);
    if (marcada) return;
    iniciar(async () => {
      await escolherUsina(codigo);
      router.refresh();
    });
  }

  const Icone = todas ? Layers : Factory;
  const etiqueta = (
    <>
      <Icone className="hidden size-5 shrink-0 text-marca sm:block" aria-hidden />
      <span className="flex min-w-0 flex-col items-start leading-tight">
        <span className="font-display text-lg font-extrabold tracking-wide text-marca">{trocando ? "…" : todas ? "Todas" : atual.codigo}</span>
        <span className="hidden max-w-48 truncate text-[11px] font-semibold uppercase tracking-wider text-[#c9d0c2] md:block">
          {todas ? `${usinas.length} usinas juntas` : atual.nome}
        </span>
      </span>
    </>
  );

  if (usinas.length < 2 && atual) {
    return (
      <span className="flex min-h-12 min-w-0 max-w-full items-center gap-2 rounded-xl border border-white/15 px-2.5 sm:px-3" title={atual.nome}>
        {etiqueta}
      </span>
    );
  }

  const opcao = (codigo: string, marcada: boolean, titulo: string, sub: string | null, rotulo: React.ReactNode) => (
    <li key={codigo}>
      <button
        type="button"
        role="option"
        aria-selected={marcada}
        disabled={trocando}
        onClick={() => escolher(codigo, marcada)}
        className={`flex min-h-16 w-full items-center gap-3 px-4 py-2 text-left hover:bg-afundado ${marcada ? "bg-destaque-fundo" : ""}`}
      >
        <span className="flex w-14 shrink-0 items-center font-display text-xl font-extrabold">{rotulo}</span>
        <span className="flex min-w-0 flex-1 flex-col">
          <span className="truncate font-semibold">{titulo}</span>
          {sub ? <span className="truncate text-sm text-suave">{sub}</span> : null}
        </span>
        {marcada ? <Check className="size-5 shrink-0 text-destaque" aria-hidden /> : null}
      </button>
    </li>
  );

  return (
    <div ref={caixa} className="relative">
      <button
        type="button"
        onClick={() => setAberto(!aberto)}
        aria-haspopup="listbox"
        aria-expanded={aberto}
        aria-label={`Usina: ${todas ? "todas" : atual.nome}. Trocar usina`}
        className="flex min-h-12 min-w-0 max-w-full items-center gap-1.5 rounded-xl border border-marca/50 bg-white/5 px-2.5 hover:border-marca sm:gap-2 sm:px-3"
      >
        {etiqueta}
        <ChevronDown className={`size-4 shrink-0 text-marca transition ${aberto ? "rotate-180" : ""}`} aria-hidden />
      </button>

      {aberto ? (
        <div className="fixed inset-x-4 top-[calc(env(safe-area-inset-top)+76px)] z-30 overflow-hidden rounded-2xl border border-linha bg-superficie text-tinta shadow-xl sm:absolute sm:inset-x-auto sm:left-0 sm:top-full sm:mt-2 sm:w-80">
          <p className="border-b border-linha px-4 py-3 text-xs font-bold uppercase tracking-wider text-suave">Trabalhar na usina</p>
          <ul role="listbox" aria-label="Usinas" className="divide-y divide-linha">
            {opcao(TODAS, todas, "Todas as usinas", "Consolidado, para consulta e resultados", <Layers className="size-6" aria-hidden />)}
            {usinas.map((u) => opcao(u.codigo, u.codigo === atual?.codigo, u.nome, u.cidade, u.codigo))}
          </ul>
        </div>
      ) : null}
    </div>
  );
}

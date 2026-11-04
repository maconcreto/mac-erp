import { Factory } from "lucide-react";
import { escolherUsina } from "@/app/(app)/usina-acoes";
import type { Usina } from "@/lib/tipos";

/**
 * Telas de lançamento (boletim, abrir OS…) trabalham numa usina só.
 * Com "Todas" escolhido no topo, pedem a usina com botões grandes; a escolha muda o topo também.
 */
export function EscolhaUmaUsina({ titulo, usinas }: { titulo: string; usinas: Usina[] }) {
  return (
    <div className="mx-auto flex max-w-xl flex-col gap-5 py-6">
      <div>
        <h1 className="text-3xl font-extrabold">{titulo}</h1>
        <p className="mt-1 text-lg text-suave">Esta tela é de uma usina só. Em qual você vai lançar?</p>
      </div>
      <div className="grid gap-2 sm:grid-cols-2">
        {usinas.map((u) => (
          <form key={u.id} action={escolherUsina.bind(null, u.codigo)}>
            <button
              type="submit"
              className="flex min-h-20 w-full items-center gap-4 rounded-2xl border border-linha bg-superficie px-4 text-left transition hover:border-suave active:scale-[.98]"
            >
              <span className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-marca-preto text-marca">
                <Factory className="size-6" aria-hidden />
              </span>
              <span className="flex min-w-0 flex-col">
                <span className="font-display text-2xl font-extrabold leading-tight">{u.codigo}</span>
                <span className="truncate text-sm text-suave">{u.nome}</span>
              </span>
            </button>
          </form>
        ))}
      </div>
    </div>
  );
}

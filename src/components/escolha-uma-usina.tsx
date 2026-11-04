import { ArrowUp, Layers } from "lucide-react";
import type { Usina } from "@/lib/tipos";

/**
 * Telas de lançamento (boletim, abrir OS…) trabalham numa usina só.
 * Com "Todas" escolhido no topo, pedem para escolher a usina lá — o seletor do topo é o único da aplicação.
 */
export function EscolhaUmaUsina({ titulo, usinas }: { titulo: string; usinas: Usina[] }) {
  return (
    <div className="mx-auto flex max-w-xl flex-col items-center gap-4 py-10 text-center">
      <span className="flex size-16 items-center justify-center rounded-2xl bg-marca-preto text-marca">
        <Layers className="size-8" aria-hidden />
      </span>
      <h1 className="text-3xl font-extrabold">{titulo}</h1>
      <p className="text-lg">
        Você está vendo <b>todas as usinas</b>. Para lançar, escolha uma usina no seletor do topo da tela.
      </p>
      <p className="flex items-center gap-2 text-base text-suave">
        <ArrowUp className="size-5" aria-hidden />
        Disponível para você: {usinas.map((u) => u.codigo).join(", ")}
      </p>
    </div>
  );
}

import type { ReactNode } from "react";
import { Logo } from "./ui";

/** Moldura das telas sem login: logo sobre preto, cartão claro embaixo. */
export function TelaMarca({ children }: { children: ReactNode }) {
  return (
    <main className="flex min-h-dvh flex-col bg-marca-preto">
      <div className="flex justify-center px-6 pb-8 pt-[max(40px,env(safe-area-inset-top))]">
        <Logo variante="vertical" className="w-44 sm:w-52" />
      </div>
      <div className="flex flex-1 justify-center rounded-t-3xl bg-fundo px-5 pb-10 pt-8">
        <div className="w-full max-w-sm">{children}</div>
      </div>
    </main>
  );
}

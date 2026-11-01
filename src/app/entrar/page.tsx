import type { Metadata } from "next";
import { Logo } from "@/components/ui";
import { supabaseConfigurado } from "@/lib/supabase/config";
import { FormEntrar } from "./form";

export const metadata: Metadata = { title: "Entrar" };

export default function PaginaEntrar() {
  return (
    <main className="flex min-h-dvh flex-col bg-marca-preto">
      <div className="flex justify-center px-6 pb-8 pt-[max(48px,env(safe-area-inset-top))]">
        <Logo />
      </div>
      <div className="flex flex-1 justify-center rounded-t-3xl bg-fundo px-5 pb-10 pt-8">
        <div className="w-full max-w-sm">
          {supabaseConfigurado ? (
            <FormEntrar />
          ) : (
            <p className="text-base">
              O banco de dados ainda não está ligado a este endereço. Configure as variáveis do Supabase na Vercel.
            </p>
          )}
        </div>
      </div>
    </main>
  );
}

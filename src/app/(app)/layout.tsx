import Link from "next/link";
import { redirect } from "next/navigation";
import { LogOut, UserRound } from "lucide-react";
import { Logo } from "@/components/ui";
import { sair } from "@/app/entrar/acoes";
import { carregarSessao, primeiroNome } from "@/lib/sessao";
import { supabaseConfigurado } from "@/lib/supabase/config";

export default async function LayoutApp({ children }: { children: React.ReactNode }) {
  if (!supabaseConfigurado) {
    return (
      <main className="mx-auto max-w-xl p-6 text-base">
        <h1 className="mb-3 text-2xl font-extrabold">Plataforma MAC</h1>
        <p>
          Falta ligar o banco: configure <code>NEXT_PUBLIC_SUPABASE_URL</code> e{" "}
          <code>NEXT_PUBLIC_SUPABASE_ANON_KEY</code> nas variáveis de ambiente da Vercel e publique de novo.
        </p>
      </main>
    );
  }

  const sessao = await carregarSessao();
  if (!sessao) redirect("/entrar");

  const usinaUnica = sessao.usinas.length === 1 ? sessao.usinas[0] : null;

  return (
    <div className="flex min-h-dvh flex-col">
      <header className="sticky top-0 z-20 border-b-[3px] border-marca bg-marca-preto pt-[env(safe-area-inset-top)] text-[#f2f5ee]">
        <div className="mx-auto flex max-w-6xl items-center gap-3 px-4 py-3">
          <Link href="/" aria-label="Início" className="flex min-h-12 items-center">
            <Logo variante="simbolo" className="w-11 sm:hidden" />
            <Logo variante="horizontal" className="hidden w-[168px] sm:block" />
          </Link>
          {usinaUnica ? (
            <span className="border-l border-white/25 pl-3 text-xs font-semibold uppercase tracking-wider opacity-70">
              {usinaUnica.codigo}
            </span>
          ) : null}

          <nav className="ml-auto flex items-center gap-1 text-sm font-semibold">
            {sessao.gestor ? (
              <>
                <Link href="/" className="hidden min-h-12 items-center rounded-lg px-3 opacity-80 hover:opacity-100 sm:flex">
                  Painel
                </Link>
                <Link href="/?modo=campo" className="hidden min-h-12 items-center rounded-lg px-3 opacity-80 hover:opacity-100 sm:flex">
                  Modo Campo
                </Link>
              </>
            ) : null}
            {sessao.diretoria ? (
              <Link href="/cadastros" className="flex min-h-12 items-center rounded-lg px-3 opacity-80 hover:opacity-100">
                Cadastros
              </Link>
            ) : null}
            <Link
              href="/conta"
              aria-label="Minha conta"
              className="flex min-h-12 min-w-12 items-center justify-center gap-2 rounded-lg px-2 text-marca hover:opacity-90"
            >
              <UserRound className="size-5" />
              <span className="hidden md:inline">{primeiroNome(sessao.pessoa.nome)}</span>
            </Link>
            <form action={sair}>
              <button
                type="submit"
                aria-label="Sair"
                className="flex min-h-12 min-w-12 items-center justify-center rounded-lg opacity-80 hover:opacity-100"
              >
                <LogOut className="size-5" />
              </button>
            </form>
          </nav>
        </div>
      </header>
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 pb-16 pt-6">{children}</main>
    </div>
  );
}

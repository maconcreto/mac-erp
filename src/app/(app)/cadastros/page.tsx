import Link from "next/link";
import { redirect } from "next/navigation";
import { ChevronRight, Factory, Users } from "lucide-react";
import { carregarSessao } from "@/lib/sessao";

export const metadata = { title: "Cadastros" };

const ITENS = [
  { href: "/cadastros/usinas", titulo: "Usinas", texto: "Centrais de concreto e seus códigos", Icone: Factory },
  { href: "/cadastros/pessoas", titulo: "Equipe", texto: "Criar usuários, senhas e acessos", Icone: Users },
];

export default async function Cadastros() {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");
  return (
    <div className="flex flex-col gap-5">
      <h1 className="text-3xl font-extrabold">Cadastros</h1>
      <div className="grid gap-3 sm:grid-cols-2">
        {ITENS.map(({ href, titulo, texto, Icone }) => (
          <Link key={href} href={href} className="flex min-h-20 items-center gap-4 rounded-2xl border border-linha bg-superficie p-4 hover:border-suave">
            <span className="flex size-12 items-center justify-center rounded-xl bg-marca-preto text-marca">
              <Icone className="size-6" />
            </span>
            <span className="flex flex-col">
              <span className="font-display text-lg font-bold">{titulo}</span>
              <span className="text-sm text-suave">{texto}</span>
            </span>
            <ChevronRight className="ml-auto size-5 text-suave" />
          </Link>
        ))}
      </div>
    </div>
  );
}

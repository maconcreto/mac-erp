import Link from "next/link";
import { redirect } from "next/navigation";
import { ChevronRight, UserPlus } from "lucide-react";
import { BotaoLink, Etiqueta } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { NOME_PAPEL, type Acesso, type Pessoa } from "@/lib/tipos";

export const metadata = { title: "Equipe" };

export default async function Pessoas() {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");

  const supabase = await criarClienteServidor();
  const [pessoasRes, acessosRes] = await Promise.all([
    supabase.from("pessoa").select("id, nome, email, telefone, cargo, matricula, ativo").order("nome"),
    supabase.from("pessoa_acesso").select("id, pessoa_id, usina_id, papel, setores"),
  ]);
  const pessoas = (pessoasRes.data ?? []) as Pessoa[];
  const acessos = (acessosRes.data ?? []) as (Acesso & { pessoa_id: string })[];
  const codigo = new Map(s.usinas.map((u) => [u.id, u.codigo]));

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-3xl font-extrabold">Equipe</h1>
        <div className="flex gap-2">
          <BotaoLink href="/cadastros" variante="secundario">Cadastros</BotaoLink>
          <BotaoLink href="/cadastros/pessoas/nova">
            <UserPlus className="size-5" /> Novo usuário
          </BotaoLink>
        </div>
      </div>

      <ul className="flex flex-col gap-2">
        {pessoas.map((p) => {
          const meus = acessos.filter((a) => a.pessoa_id === p.id);
          return (
            <li key={p.id}>
              <Link
                href={`/cadastros/pessoas/${p.id}`}
                className={`flex min-h-16 items-center gap-4 rounded-2xl border border-linha bg-superficie p-4 hover:border-suave ${p.ativo ? "" : "opacity-60"}`}
              >
                <span className="flex size-11 shrink-0 items-center justify-center rounded-full bg-marca-preto font-display text-lg font-bold text-marca">
                  {p.nome.trim().charAt(0).toUpperCase() || "?"}
                </span>
                <span className="flex min-w-0 flex-1 flex-col gap-1">
                  <span className="flex flex-wrap items-baseline gap-x-2">
                    <b className="text-base">{p.nome}</b>
                    {p.cargo ? <span className="text-sm text-suave">{p.cargo}</span> : null}
                  </span>
                  <span className="flex flex-wrap gap-1.5">
                    {!p.ativo ? <Etiqueta>Desativado</Etiqueta> : null}
                    {meus.length === 0 && p.ativo ? <Etiqueta>Sem acesso</Etiqueta> : null}
                    {meus.map((a) => (
                      <Etiqueta key={a.id} tom={a.papel === "diretoria" ? "marca" : "neutro"}>
                        {(a.usina_id ? codigo.get(a.usina_id) ?? "?" : "Todas") + " · " + NOME_PAPEL[a.papel]}
                      </Etiqueta>
                    ))}
                  </span>
                </span>
                <ChevronRight className="size-5 shrink-0 text-suave" />
              </Link>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

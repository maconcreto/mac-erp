import { redirect } from "next/navigation";
import { Etiqueta, Painel } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { alternarUsina } from "../acoes";
import { FormUsina } from "./form";

export const metadata = { title: "Usinas" };

export default async function Usinas() {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-sm font-bold uppercase tracking-wider text-suave">Configurações › Cadastros</p>
          <h1 className="text-3xl font-extrabold">Usinas</h1>
        </div>
      </div>

      <Painel>
        <ul className="flex flex-col divide-y divide-linha">
          {s.usinas.map((u) => (
            <li key={u.id} className="flex flex-wrap items-center gap-3 py-3">
              <span className="w-16 font-display text-xl font-extrabold">{u.codigo}</span>
              <span className="flex min-w-0 flex-1 flex-col">
                <span className="font-semibold">{u.nome}</span>
                <span className="text-sm text-suave">{[u.cidade, u.uf].filter(Boolean).join(" / ") || "—"}</span>
              </span>
              {u.ativa ? <Etiqueta tom="ok">Ativa</Etiqueta> : <Etiqueta>Inativa</Etiqueta>}
              <form action={alternarUsina}>
                <input type="hidden" name="id" value={u.id} />
                <input type="hidden" name="ativa" value={String(u.ativa)} />
                <button type="submit" className="min-h-12 rounded-lg px-3 text-sm font-semibold text-suave hover:text-tinta">
                  {u.ativa ? "Desativar" : "Reativar"}
                </button>
              </form>
            </li>
          ))}
        </ul>
      </Painel>

      <Painel titulo="Nova usina">
        <FormUsina />
      </Painel>
    </div>
  );
}

import { redirect } from "next/navigation";
import { X } from "lucide-react";
import { BotaoLink, Etiqueta, Painel } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { NOME_PAPEL, NOME_SETOR, type Acesso, type Pessoa } from "@/lib/tipos";
import { removerAcesso } from "../acoes";
import { FormAcesso } from "./form";

export const metadata = { title: "Pessoas e acessos" };

export default async function Pessoas() {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");

  const supabase = await criarClienteServidor();
  const [pessoasRes, acessosRes] = await Promise.all([
    supabase.from("pessoa").select("id, nome, email, telefone, ativo").order("nome"),
    supabase.from("pessoa_acesso").select("id, pessoa_id, usina_id, papel, setores"),
  ]);
  const pessoas = (pessoasRes.data ?? []) as Pessoa[];
  const acessos = (acessosRes.data ?? []) as (Acesso & { pessoa_id: string })[];
  const codigo = new Map(s.usinas.map((u) => [u.id, u.codigo]));
  const semAcesso = pessoas.filter((p) => !acessos.some((a) => a.pessoa_id === p.id));

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-3xl font-extrabold">Pessoas e acessos</h1>
        <BotaoLink href="/cadastros" variante="secundario">Cadastros</BotaoLink>
      </div>

      {semAcesso.length > 0 ? (
        <Painel titulo={`Aguardando liberação (${semAcesso.length})`} className="border-alerta/40">
          <ul className="flex flex-col gap-1">
            {semAcesso.map((p) => (
              <li key={p.id} className="text-base">
                <b>{p.nome}</b> <span className="text-suave">· {p.email}</span>
              </li>
            ))}
          </ul>
        </Painel>
      ) : null}

      <Painel titulo="Liberar acesso">
        <FormAcesso
          pessoas={pessoas.map((p) => ({ id: p.id, nome: p.nome || p.email || p.id }))}
          usinas={s.usinas.filter((u) => u.ativa).map((u) => ({ id: u.id, codigo: u.codigo, nome: u.nome }))}
          pessoaInicial={semAcesso[0]?.id}
        />
      </Painel>

      <Painel titulo="Equipe">
        <ul className="flex flex-col divide-y divide-linha">
          {pessoas.map((p) => (
            <li key={p.id} className="flex flex-col gap-2 py-3">
              <span className="flex flex-wrap items-baseline gap-x-2">
                <b className="text-base">{p.nome}</b>
                <span className="text-sm text-suave">{p.email}</span>
              </span>
              <div className="flex flex-wrap gap-2">
                {acessos
                  .filter((a) => a.pessoa_id === p.id)
                  .map((a) => (
                    <span key={a.id} className="inline-flex items-center gap-1 rounded-xl border border-linha bg-afundado py-1 pl-3 pr-1 text-sm">
                      <b>{a.usina_id ? codigo.get(a.usina_id) ?? "?" : "Todas"}</b>
                      <span>· {NOME_PAPEL[a.papel]}</span>
                      {a.papel !== "diretoria" && a.setores.length ? (
                        <span className="text-suave">· {a.setores.map((x) => NOME_SETOR[x]).join(", ")}</span>
                      ) : null}
                      {p.id !== s.pessoa.id ? (
                        <form action={removerAcesso}>
                          <input type="hidden" name="id" value={a.id} />
                          <button type="submit" aria-label="Remover acesso" className="flex size-9 items-center justify-center rounded-lg text-suave hover:text-erro">
                            <X className="size-4" />
                          </button>
                        </form>
                      ) : null}
                    </span>
                  ))}
                {!acessos.some((a) => a.pessoa_id === p.id) ? <Etiqueta>Sem acesso</Etiqueta> : null}
              </div>
            </li>
          ))}
        </ul>
      </Painel>
    </div>
  );
}

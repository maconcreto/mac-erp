import { notFound, redirect } from "next/navigation";
import { X } from "lucide-react";
import { Aviso, BotaoLink, Etiqueta, Painel } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { NOME_PAPEL, NOME_SETOR, type Acesso, type Pessoa } from "@/lib/tipos";
import { alternarPessoa, removerAcesso } from "../../acoes";
import { FormDados, FormNovoAcesso, FormSenha } from "./forms";

export const metadata = { title: "Usuário" };

export default async function PaginaPessoa({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ novo?: string; sem_acesso?: string }>;
}) {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");
  const { id } = await params;
  const { novo, sem_acesso } = await searchParams;

  const supabase = await criarClienteServidor();
  const [pessoaRes, acessosRes] = await Promise.all([
    supabase.from("pessoa").select("id, nome, email, telefone, cargo, matricula, ativo").eq("id", id).maybeSingle(),
    supabase.from("pessoa_acesso").select("id, usina_id, papel, setores").eq("pessoa_id", id),
  ]);
  const pessoa = pessoaRes.data as Pessoa | null;
  if (!pessoa) notFound();
  const acessos = (acessosRes.data ?? []) as Acesso[];
  const codigo = new Map(s.usinas.map((u) => [u.id, u.codigo]));
  const usinas = s.usinas.filter((u) => u.ativa).map((u) => ({ id: u.id, codigo: u.codigo, nome: u.nome }));
  const souEu = pessoa.id === s.pessoa.id;

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-3xl font-extrabold">{pessoa.nome}</h1>
          <p className="text-base text-suave">
            {[pessoa.cargo, pessoa.email].filter(Boolean).join(" · ")}
          </p>
        </div>
        <BotaoLink href="/cadastros/pessoas" variante="secundario">Equipe</BotaoLink>
      </div>

      {novo ? <Aviso tipo="ok">Usuário criado. Passe o e-mail e a senha para a pessoa entrar no app.</Aviso> : null}
      {sem_acesso ? <Aviso tipo="alerta">Usuário criado, mas o acesso não foi gravado. Adicione abaixo.</Aviso> : null}
      {!pessoa.ativo ? <Aviso tipo="erro">Usuário desativado: não consegue entrar no sistema.</Aviso> : null}

      <Painel titulo="Dados">
        <FormDados pessoa={pessoa} />
      </Painel>

      <Painel titulo="Acessos">
        {acessos.length ? (
          <ul className="flex flex-wrap gap-2">
            {acessos.map((a) => (
              <li key={a.id} className="inline-flex items-center gap-1 rounded-xl border border-linha bg-afundado py-1 pl-3 pr-1 text-sm">
                <b>{a.usina_id ? codigo.get(a.usina_id) ?? "?" : "Todas"}</b>
                <span>· {NOME_PAPEL[a.papel]}</span>
                {a.papel !== "diretoria" && a.setores.length ? (
                  <span className="text-suave">· {a.setores.map((x) => NOME_SETOR[x]).join(", ")}</span>
                ) : null}
                {!souEu ? (
                  <form action={removerAcesso}>
                    <input type="hidden" name="id" value={a.id} />
                    <input type="hidden" name="pessoa_id" value={pessoa.id} />
                    <button type="submit" aria-label="Remover acesso" className="flex size-10 items-center justify-center rounded-lg text-suave hover:text-erro">
                      <X className="size-4" />
                    </button>
                  </form>
                ) : null}
              </li>
            ))}
          </ul>
        ) : (
          <Etiqueta>Sem acesso</Etiqueta>
        )}
        <div className="border-t border-linha pt-4">
          <FormNovoAcesso pessoaId={pessoa.id} usinas={usinas} />
        </div>
      </Painel>

      <Painel titulo="Senha">
        <FormSenha pessoaId={pessoa.id} />
      </Painel>

      {!souEu ? (
        <Painel titulo="Situação">
          <p className="text-base">
            {pessoa.ativo
              ? "Desativar bloqueia o login na hora. O histórico da pessoa continua guardado."
              : "Reativar libera o login de novo, com a mesma senha."}
          </p>
          <form action={alternarPessoa}>
            <input type="hidden" name="id" value={pessoa.id} />
            <input type="hidden" name="ativo" value={String(pessoa.ativo)} />
            <button
              type="submit"
              className={`min-h-12 rounded-xl border px-5 font-semibold ${pessoa.ativo ? "border-linha text-erro hover:border-erro" : "border-linha text-ok hover:border-ok"}`}
            >
              {pessoa.ativo ? "Desativar usuário" : "Reativar usuário"}
            </button>
          </form>
        </Painel>
      ) : null}
    </div>
  );
}

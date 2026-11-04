import Link from "next/link";
import { redirect } from "next/navigation";
import { Clock3 } from "lucide-react";
import { IconeTarefaSvg } from "@/components/icone-tarefa";
import { BotaoLink, Etiqueta, Painel } from "@/components/ui";
import { carregarSessao, primeiroNome, type Sessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { tarefasDe } from "@/lib/tarefas";
import { usinaAtual } from "@/lib/usina-atual";
import { escolherUsina } from "./usina-acoes";
import { NOME_SETOR } from "@/lib/tipos";

export default async function Inicio({ searchParams }: { searchParams: Promise<{ modo?: string }> }) {
  const sessao = await carregarSessao();
  if (!sessao) redirect("/entrar");
  const { modo } = await searchParams;

  if (sessao.acessos.length === 0) return <SemAcesso nome={sessao.pessoa.nome} />;
  if (!sessao.gestor || modo === "campo") return <ModoCampo sessao={sessao} />;
  return <PainelGestao sessao={sessao} />;
}

function hojeExtenso() {
  return new Intl.DateTimeFormat("pt-BR", { weekday: "long", day: "numeric", month: "long", timeZone: "America/Bahia" }).format(new Date());
}

/* ---------- Modo Campo: só cartões grandes, uma tarefa por toque ---------- */
function ModoCampo({ sessao }: { sessao: Sessao }) {
  const tarefas = tarefasDe(sessao.setores);
  const variosSetores = new Set(tarefas.map((t) => t.setor)).size > 1;
  const setores = [...new Set(tarefas.map((t) => t.setor))];

  return (
    <div className="flex flex-col gap-6">
      <div>
        <p className="text-base capitalize text-suave">{hojeExtenso()}</p>
        <h1 className="text-3xl font-extrabold">Olá, {primeiroNome(sessao.pessoa.nome)}</h1>
      </div>

      {setores.map((setor) => (
        <section key={setor} className="flex flex-col gap-3">
          {variosSetores ? <h2 className="text-sm font-bold uppercase tracking-wider text-suave">{NOME_SETOR[setor]}</h2> : null}
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
            {tarefas
              .filter((t) => t.setor === setor)
              .map((t) => (
                <Link
                  key={t.slug}
                  href={`/tarefa/${t.slug}`}
                  className="flex min-h-36 flex-col justify-between gap-4 rounded-2xl border border-linha bg-superficie p-4 transition active:scale-[.98] hover:border-suave"
                >
                  <span className="flex size-14 items-center justify-center rounded-xl bg-marca-preto text-marca">
                    <IconeTarefaSvg nome={t.icone} className="size-7" />
                  </span>
                  <span className="font-display text-lg font-bold leading-tight">{t.titulo}</span>
                </Link>
              ))}
          </div>
        </section>
      ))}

      {sessao.gestor ? (
        <BotaoLink href="/" variante="secundario" className="self-start">
          Voltar ao painel
        </BotaoLink>
      ) : null}
    </div>
  );
}

function SemAcesso({ nome }: { nome: string }) {
  return (
    <div className="mx-auto flex max-w-md flex-col items-center gap-4 py-12 text-center">
      <span className="flex size-16 items-center justify-center rounded-full bg-alerta-fundo text-alerta">
        <Clock3 className="size-8" />
      </span>
      <h1 className="text-2xl font-extrabold">Olá, {primeiroNome(nome)}</h1>
      <p className="text-lg">Seu cadastro chegou. Falta o gestor liberar suas tarefas.</p>
    </div>
  );
}

/* ---------- Painel de gestão ---------- */
const FASES = [
  { n: 0, nome: "Fundação", itens: "Login, papéis, usinas e pessoas" },
  { n: 1, nome: "Operação (piloto VDC)", itens: "Boletim, check-list, OS e frota" },
  { n: 2, nome: "Balança, estoque e qualidade", itens: "Cubagem, pipa, recebimento, fechamentos, laudos" },
  { n: 3, nome: "Financeiro e comercial", itens: "Caixa, cartões, vencimentos, licenças, obras" },
  { n: 4, nome: "Expansão", itens: "IOS, LEM, usina móvel e consolidado" },
];
const FASE_ATUAL = 0;

async function PainelGestao({ sessao }: { sessao: Sessao }) {
  const supabase = await criarClienteServidor();
  const atual = await usinaAtual(sessao);
  const [ativos, acessos] = await Promise.all([
    supabase.from("ativo").select("usina_id").eq("ativo", true),
    sessao.diretoria ? supabase.from("pessoa_acesso").select("pessoa_id, usina_id") : Promise.resolve({ data: [] as { pessoa_id: string; usina_id: string | null }[] }),
  ]);

  const ativosPorUsina = new Map<string, number>();
  for (const a of (ativos.data ?? []) as { usina_id: string }[]) ativosPorUsina.set(a.usina_id, (ativosPorUsina.get(a.usina_id) ?? 0) + 1);
  const pessoasPorUsina = new Map<string, Set<string>>();
  for (const a of (acessos.data ?? []) as { pessoa_id: string; usina_id: string | null }[]) {
    if (!a.usina_id) continue;
    if (!pessoasPorUsina.has(a.usina_id)) pessoasPorUsina.set(a.usina_id, new Set());
    pessoasPorUsina.get(a.usina_id)!.add(a.pessoa_id);
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-base capitalize text-suave">{hojeExtenso()}</p>
          <h1 className="text-3xl font-extrabold">Painel</h1>
        </div>
        <BotaoLink href="/?modo=campo" variante="secundario">
          Ver como lançador
        </BotaoLink>
      </div>

      <Painel titulo="Usinas" acao={sessao.diretoria ? <BotaoLink href="/cadastros/usinas" variante="secundario">Gerenciar</BotaoLink> : null}>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {sessao.usinas.map((u) => (
            <div
              key={u.id}
              className={`flex flex-col gap-2 rounded-xl border p-4 ${u.id === atual?.id ? "border-marca-preto bg-destaque-fundo" : "border-linha bg-afundado"}`}
            >
              <div className="flex items-center justify-between gap-2">
                <span className="font-display text-2xl font-extrabold">{u.codigo}</span>
                {u.id === atual?.id ? <Etiqueta tom="marca">Em uso</Etiqueta> : u.ativa ? <Etiqueta tom="ok">Ativa</Etiqueta> : <Etiqueta>Inativa</Etiqueta>}
              </div>
              <span className="text-base">{u.nome}</span>
              <span className="text-sm text-suave">
                {ativosPorUsina.get(u.id) ?? 0} ativos
                {sessao.diretoria ? ` · ${pessoasPorUsina.get(u.id)?.size ?? 0} pessoas` : ""}
              </span>
              {u.ativa && u.id !== atual?.id ? (
                <form action={escolherUsina.bind(null, u.codigo)}>
                  <button type="submit" className="min-h-12 w-full rounded-xl border border-linha bg-superficie px-4 font-semibold hover:border-suave">
                    Trabalhar na {u.codigo}
                  </button>
                </form>
              ) : null}
            </div>
          ))}
        </div>
      </Painel>

      <Painel titulo="Andamento da implantação">
        <ol className="flex flex-col gap-2">
          {FASES.map((f) => (
            <li key={f.n} className="flex items-start gap-3 rounded-xl border border-linha p-3">
              <span
                className={`flex size-9 shrink-0 items-center justify-center rounded-full font-display font-bold ${
                  f.n === FASE_ATUAL ? "bg-marca text-marca-preto" : f.n < FASE_ATUAL ? "bg-ok-fundo text-ok" : "bg-afundado text-suave"
                }`}
              >
                {f.n}
              </span>
              <span className="flex flex-col">
                <span className="font-semibold">{f.nome}</span>
                <span className="text-sm text-suave">{f.itens}</span>
              </span>
              {f.n === FASE_ATUAL ? <span className="ml-auto"><Etiqueta tom="marca">Em andamento</Etiqueta></span> : null}
            </li>
          ))}
        </ol>
      </Painel>
    </div>
  );
}

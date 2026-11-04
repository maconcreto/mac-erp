import Link from "next/link";
import { redirect } from "next/navigation";
import { AlertTriangle, ArrowRight, CheckCircle2, ChevronRight, CircleDashed, Clock3, LayoutDashboard, Plus, Wrench } from "lucide-react";
import { IconeTarefaSvg } from "@/components/icone-tarefa";
import { Etiqueta } from "@/components/ui";
import { dataBr } from "@/lib/frota/consumo";
import { COR_SITUACAO } from "@/lib/frota/os";
import { podeLancarBoletim, podeUsarOS } from "@/lib/frota/permissao";
import { PRONTAS, hrefTarefa } from "@/lib/navegacao";
import { osEmAberto, situacaoBoletins, type BoletimHoje } from "@/lib/resumo";
import { carregarSessao, primeiroNome } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { tarefasDe } from "@/lib/tarefas";
import { escolhaUsina } from "@/lib/usina-atual";

export default async function Inicio() {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  if (s.acessos.length === 0) return <SemAcesso nome={s.pessoa.nome} />;

  const escolha = await escolhaUsina(s);
  const escopo = escolha ? (escolha.todas ? escolha.usinas : [escolha.usina]) : [];
  const usinasBoletim = escopo.filter((u) => podeLancarBoletim(s, u.id));
  const usinasOS = escopo.filter((u) => podeUsarOS(s, u.id));

  const supabase = await criarClienteServidor();
  const [boletins, os] = await Promise.all([situacaoBoletins(supabase, usinasBoletim), osEmAberto(supabase, usinasOS, 4)]);
  const atalhos = tarefasDe(s.setores).filter((t) => PRONTAS.has(t.slug));
  const codigo = new Map(escopo.map((u) => [u.id, u.codigo]));

  const hoje = new Intl.DateTimeFormat("pt-BR", { weekday: "long", day: "numeric", month: "long", timeZone: "America/Bahia" }).format(new Date());

  return (
    <div className="flex flex-col gap-6">
      <div>
        <p className="text-base capitalize text-suave">{hoje}</p>
        <h1 className="text-3xl font-extrabold">Olá, {primeiroNome(s.pessoa.nome)}</h1>
        <p className="mt-1 text-base text-suave">{escolha?.todas ? "Vendo todas as usinas" : escolha?.usina?.nome}</p>
      </div>

      {/* ---------- para hoje ---------- */}
      {boletins.length || usinasOS.length ? (
        <section className="flex flex-col gap-3">
          <h2 className="text-sm font-bold uppercase tracking-wider text-suave">Para hoje</h2>
          <div className="grid gap-3 md:grid-cols-2">
            {boletins.length ? <CartaoBoletim boletins={boletins} /> : null}
            {usinasOS.length ? (
              <Link href="/tarefa/os" className="group flex flex-col gap-3 rounded-2xl border border-linha bg-superficie p-4 hover:border-suave">
                <div className="flex items-center gap-3">
                  <span className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-marca-preto text-marca">
                    <Wrench className="size-6" />
                  </span>
                  <span className="flex min-w-0 flex-1 flex-col">
                    <span className="font-display text-lg font-bold">Ordens de serviço</span>
                    <span className="text-base text-suave">
                      {os.total === 0 ? "Nenhuma em aberto" : `${os.total} em aberto${os.aguardandoPeca ? ` · ${os.aguardandoPeca} aguardando peça` : ""}`}
                    </span>
                  </span>
                  <ChevronRight className="size-5 text-suave transition group-hover:translate-x-0.5" />
                </div>
                {os.lista.length ? (
                  <ul className="flex flex-col divide-y divide-linha rounded-xl border border-linha">
                    {os.lista.map((o) => (
                      <li key={o.id} className="flex items-center gap-3 px-3 py-2.5">
                        <span className="w-20 shrink-0 font-display font-bold tabular-nums">{o.numero}</span>
                        <span className="min-w-0 flex-1 truncate">
                          {escolha?.todas ? `${codigo.get(o.usina_id)} · ` : ""}
                          <b>{o.ativo}</b> · {o.descricao}
                        </span>
                        <Etiqueta tom={COR_SITUACAO[o.status]}>{o.status}</Etiqueta>
                      </li>
                    ))}
                  </ul>
                ) : null}
              </Link>
            ) : null}
          </div>
        </section>
      ) : null}

      {/* ---------- lançar ---------- */}
      {atalhos.length ? (
        <section className="flex flex-col gap-3">
          <h2 className="text-sm font-bold uppercase tracking-wider text-suave">Lançar</h2>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
            {atalhos.map((t) => (
              <Link
                key={t.slug}
                href={hrefTarefa(t.slug)}
                className="flex min-h-32 flex-col justify-between gap-4 rounded-2xl border border-linha bg-superficie p-4 transition hover:border-suave active:scale-[.98]"
              >
                <span className="flex size-12 items-center justify-center rounded-xl bg-marca-preto text-marca">
                  <IconeTarefaSvg nome={t.icone} className="size-6" />
                </span>
                <span className="font-display text-lg font-bold leading-tight">{t.titulo}</span>
              </Link>
            ))}
            {usinasOS.length ? (
              <Link
                href="/tarefa/os/nova"
                className="flex min-h-32 flex-col justify-between gap-4 rounded-2xl border border-marca-preto bg-marca p-4 text-marca-preto transition hover:brightness-105 active:scale-[.98]"
              >
                <span className="flex size-12 items-center justify-center rounded-xl bg-marca-preto text-marca">
                  <Plus className="size-6" />
                </span>
                <span className="font-display text-lg font-bold leading-tight">Abrir OS</span>
              </Link>
            ) : null}
          </div>
        </section>
      ) : null}

      {s.gestor ? (
        <Link href="/gestao" className="group flex min-h-16 items-center gap-3 rounded-2xl border border-linha bg-superficie p-4 hover:border-suave">
          <span className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-marca-preto text-marca">
            <LayoutDashboard className="size-6" />
          </span>
          <span className="flex min-w-0 flex-1 flex-col">
            <span className="font-display text-lg font-bold">Painel de Gestão</span>
            <span className="text-base text-suave">Produção, diesel e manutenção do mês</span>
          </span>
          <ArrowRight className="size-5 text-suave transition group-hover:translate-x-0.5" />
        </Link>
      ) : null}
    </div>
  );
}

function CartaoBoletim({ boletins }: { boletins: BoletimHoje[] }) {
  const algumAtraso = boletins.some((b) => b.atrasados.length);
  return (
    <Link
      href="/tarefa/boletim"
      className={`group flex flex-col gap-3 rounded-2xl border bg-superficie p-4 hover:border-suave ${algumAtraso ? "border-erro/50" : "border-linha"}`}
    >
      <div className="flex items-center gap-3">
        <span className="flex size-12 shrink-0 items-center justify-center rounded-xl bg-marca-preto text-marca">
          <IconeTarefaSvg nome="caminhao" className="size-6" />
        </span>
        <span className="flex min-w-0 flex-1 flex-col">
          <span className="font-display text-lg font-bold">Boletim do dia</span>
          <span className="text-base text-suave">Produção e abastecimento</span>
        </span>
        <ChevronRight className="size-5 text-suave transition group-hover:translate-x-0.5" />
      </div>
      <ul className="flex flex-col gap-2">
        {boletins.map((b) => (
          <li key={b.usina.id} className="flex flex-col gap-1 rounded-xl border border-linha px-3 py-2.5">
            <span className="flex items-center gap-2">
              {boletins.length > 1 ? <b className="w-12 shrink-0 font-display">{b.usina.codigo}</b> : null}
              {b.hoje === "fechado" ? (
                <span className="flex items-center gap-1.5 font-semibold text-ok">
                  <CheckCircle2 className="size-5" /> Hoje fechado
                </span>
              ) : b.hoje === "aberto" ? (
                <span className="flex items-center gap-1.5 font-semibold text-alerta">
                  <CircleDashed className="size-5" /> Hoje salvo, falta fechar
                </span>
              ) : (
                <span className="flex items-center gap-1.5 font-semibold text-tinta">
                  <CircleDashed className="size-5 text-suave" /> Hoje ainda não lançado
                </span>
              )}
            </span>
            {b.atrasados.length ? (
              <span className="flex items-start gap-1.5 text-sm font-semibold text-erro">
                <AlertTriangle className="mt-0.5 size-4 shrink-0" />
                {b.atrasados.length === 1
                  ? `Dia ${dataBr(b.atrasados[0])} sem fechar`
                  : `${b.atrasados.length} dias sem fechar, desde ${dataBr(b.atrasados[0])}`}
              </span>
            ) : null}
          </li>
        ))}
      </ul>
    </Link>
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

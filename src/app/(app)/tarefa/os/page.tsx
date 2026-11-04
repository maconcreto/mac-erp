import Link from "next/link";
import { redirect } from "next/navigation";
import { ChevronRight, Plus, Search } from "lucide-react";
import { Aviso, BotaoLink, Etiqueta, Painel, estiloEntrada } from "@/components/ui";
import { brl, dataBr } from "@/lib/frota/consumo";
import { COR_SITUACAO, EM_ABERTO, semNota, totalOS, type OS } from "@/lib/frota/os";
import { ativosDaUsina, normalizarOS } from "@/lib/frota/os-dados";
import { gestorDaUsina, podeUsarOS } from "@/lib/frota/permissao";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";

export const metadata = { title: "Ordens de serviço" };

const FILTROS = [
  { k: "abertas", l: "Em aberto" },
  { k: "concluidas", l: "Concluídas" },
  { k: "todas", l: "Todas" },
] as const;

type SP = { usina?: string; filtro?: string; ativo?: string; q?: string };

export default async function ListaOS({ searchParams }: { searchParams: Promise<SP> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const sp = await searchParams;

  const usinas = s.usinas.filter((u) => u.ativa && podeUsarOS(s, u.id));
  if (!usinas.length) {
    return (
      <Painel titulo="Ordens de serviço">
        <Aviso>Você não tem acesso às OS de nenhuma usina. Peça à diretoria para liberar o setor Operação.</Aviso>
      </Painel>
    );
  }
  const usina = usinas.find((u) => u.codigo === sp.usina) ?? usinas[0];
  const gestor = gestorDaUsina(s, usina.id);
  const filtro = FILTROS.some((f) => f.k === sp.filtro) ? sp.filtro! : "abertas";
  const q = (sp.q ?? "").trim();

  const supabase = await criarClienteServidor();
  const ativos = await ativosDaUsina(supabase, usina.id);
  const codigo = new Map(ativos.map((a) => [a.id, a.codigo]));

  let consulta = supabase
    .from("ordem_servico")
    .select("id, usina_id, numero, ativo_id, ativo_texto, classe, tipo, status, abertura, termino, oficina, nome_oficina, descricao, valor, compras, anexos, nf_arquivos, origem")
    .eq("usina_id", usina.id)
    .order("ano", { ascending: false })
    .order("seq", { ascending: false })
    .limit(200);
  if (filtro === "abertas") consulta = consulta.in("status", EM_ABERTO);
  if (filtro === "concluidas") consulta = consulta.eq("status", "Concluída");
  if (sp.ativo && codigo.has(sp.ativo)) consulta = consulta.eq("ativo_id", sp.ativo);
  if (q) {
    const t = q.replace(/[%,()]/g, " ");
    consulta = consulta.or(`numero.ilike.%${t}%,descricao.ilike.%${t}%,servicos.ilike.%${t}%,nome_oficina.ilike.%${t}%,colaborador.ilike.%${t}%,ativo_texto.ilike.%${t}%`);
  }
  const [{ data }, contagem] = await Promise.all([
    consulta,
    supabase.from("ordem_servico").select("id", { count: "exact", head: true }).eq("usina_id", usina.id).in("status", EM_ABERTO),
  ]);
  const lista = ((data ?? []) as unknown as Record<string, unknown>[]).map(normalizarOS);
  const nAbertas = contagem.count ?? 0;
  const total = lista.reduce((t, o) => t + totalOS(o), 0);

  const link = (mudar: Partial<SP>) => {
    const p = new URLSearchParams();
    const v = { usina: usina.codigo, filtro, ativo: sp.ativo, q, ...mudar };
    Object.entries(v).forEach(([k, x]) => x && p.set(k, x));
    return `/tarefa/os?${p}`;
  };

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-sm font-bold uppercase tracking-wider text-suave">{usina.nome}</p>
          <h1 className="text-3xl font-extrabold">Ordens de serviço</h1>
        </div>
        <BotaoLink href={`/tarefa/os/nova?usina=${usina.codigo}`} tamanho="lg" className="sm:w-auto">
          <Plus className="size-6" /> Abrir OS
        </BotaoLink>
      </div>

      {usinas.length > 1 ? (
        <nav className="flex flex-wrap gap-2" aria-label="Usina">
          {usinas.map((u) => (
            <Link
              key={u.id}
              href={`/tarefa/os?usina=${u.codigo}&filtro=${filtro}`}
              className={`inline-flex min-h-12 items-center rounded-xl border px-4 font-semibold ${u.id === usina.id ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie"}`}
            >
              {u.codigo}
            </Link>
          ))}
        </nav>
      ) : null}

      <div className="flex flex-col gap-3">
        <nav className="grid grid-cols-3 gap-1 rounded-2xl border border-linha bg-superficie p-1" aria-label="Situação">
          {FILTROS.map((f) => (
            <Link
              key={f.k}
              href={link({ filtro: f.k })}
              aria-current={f.k === filtro ? "page" : undefined}
              className={`flex min-h-12 items-center justify-center rounded-xl px-2 text-center text-base font-semibold ${f.k === filtro ? "bg-marca-preto text-marca" : "text-suave hover:text-tinta"}`}
            >
              {f.l}
              {f.k === "abertas" ? ` (${nAbertas})` : ""}
            </Link>
          ))}
        </nav>

        <form action="/tarefa/os" className="flex flex-wrap gap-2">
          <input type="hidden" name="usina" value={usina.codigo} />
          <input type="hidden" name="filtro" value={filtro} />
          <select name="ativo" defaultValue={sp.ativo ?? ""} className={`${estiloEntrada} w-auto min-w-32 flex-none`} aria-label="Veículo">
            <option value="">Todos os veículos</option>
            {ativos.map((a) => (
              <option key={a.id} value={a.id}>
                {a.codigo}
              </option>
            ))}
          </select>
          <label className="relative min-w-0 flex-1">
            <span className="sr-only">Buscar</span>
            <Search className="pointer-events-none absolute left-4 top-1/2 size-5 -translate-y-1/2 text-suave" />
            <input name="q" type="search" defaultValue={q} placeholder="Número, serviço, oficina…" className={`${estiloEntrada} pl-12`} />
          </label>
          <button type="submit" className="min-h-12 rounded-xl border border-linha bg-superficie px-5 font-semibold hover:border-suave">
            Filtrar
          </button>
        </form>
      </div>

      {lista.length === 0 ? (
        <div className="flex flex-col items-center gap-3 rounded-2xl border border-dashed border-linha bg-superficie px-6 py-12 text-center">
          <p className="text-lg font-semibold">{filtro === "abertas" ? "Nenhuma OS em aberto." : "Nenhuma OS encontrada."}</p>
          <p className="text-suave">Quando um veículo ou equipamento precisar de serviço, toque em Abrir OS.</p>
        </div>
      ) : (
        <ul className="flex flex-col gap-2">
          {lista.map((o) => (
            <li key={o.id}>
              <CartaoOS o={o} ativo={(o.ativo_id && codigo.get(o.ativo_id)) || o.ativo_texto || "—"} />
            </li>
          ))}
        </ul>
      )}

      {gestor && lista.length ? (
        <p className="text-right text-sm text-suave">
          {lista.length} OS{lista.length === 200 ? " (mostrando as 200 mais recentes)" : ""} · total{" "}
          <b className="text-tinta tabular-nums">{brl(total)}</b>
        </p>
      ) : null}
    </div>
  );
}

function CartaoOS({ o, ativo }: { o: OS; ativo: string }) {
  const nota = semNota(o);
  const valor = totalOS(o);
  return (
    <Link
      href={`/tarefa/os/${o.id}`}
      className="flex min-h-20 items-center gap-4 rounded-2xl border border-linha bg-superficie p-4 transition hover:border-suave active:scale-[.99]"
    >
      <span className="flex w-16 shrink-0 flex-col items-center justify-center rounded-xl bg-marca-preto px-2 py-2 text-center">
        <span className="font-display text-[11px] font-bold leading-none text-[#c9d0c2]">{o.numero.slice(0, 4)}</span>
        <span className="font-display text-xl font-extrabold leading-tight text-marca tabular-nums">{o.numero.slice(5)}</span>
      </span>
      <span className="flex min-w-0 flex-1 flex-col gap-1">
        <span className="flex flex-wrap items-center gap-x-2 gap-y-1">
          <b className="font-display text-lg">{ativo}</b>
          <Etiqueta tom={COR_SITUACAO[o.status]}>{o.status}</Etiqueta>
          {nota ? <Etiqueta tom="alerta">Falta nota</Etiqueta> : null}
        </span>
        <span className="line-clamp-2 text-base">{o.descricao || "Sem descrição"}</span>
        <span className="text-sm text-suave">
          {[o.classe, o.oficina === "Terceiro" ? o.nome_oficina || "Terceiro" : o.oficina ? "Oficina local" : null, o.abertura ? `aberta ${dataBr(o.abertura)}` : null]
            .filter(Boolean)
            .join(" · ")}
          {valor ? ` · ${brl(valor)}` : ""}
        </span>
      </span>
      <ChevronRight className="size-5 shrink-0 text-suave" />
    </Link>
  );
}

"use client";

import Link from "next/link";
import { useState, useTransition } from "react";
import { ArrowLeft, Building2, Check, CircleCheckBig, Hammer, Lightbulb, Wrench } from "lucide-react";
import { AreaTexto, Aviso, Botao, BotaoLink, Campo, Entrada } from "@/components/ui";
import { abrirOS, type Retorno } from "../acoes";

type Ativo = { id: string; codigo: string; tipo: string; grupo: "frota" | "usina" };
type Props = { usina: { id: string; codigo: string; nome: string }; ativos: Ativo[]; ativoInicial: string | null };

const CLASSES = [
  { k: "Corretiva", titulo: "Conserto", texto: "Quebrou ou está com defeito", Icone: Wrench },
  { k: "Preventiva", titulo: "Preventiva", texto: "Revisão, troca de óleo, troca programada", Icone: Hammer },
  { k: "Investimento", titulo: "Melhoria", texto: "Peça nova ou adaptação, sem defeito", Icone: Lightbulb },
] as const;

const PASSOS = ["Veículo", "Problema", "Oficina", "Conferir"] as const;

export function AssistenteOS({ usina, ativos, ativoInicial }: Props) {
  const [passo, setPasso] = useState(ativoInicial ? 1 : 0);
  const [varios, setVarios] = useState(false);
  const [sel, setSel] = useState<string[]>(ativoInicial ? [ativoInicial] : []);
  const [outro, setOutro] = useState(false);
  const [ativoTexto, setAtivoTexto] = useState("");
  const [classe, setClasse] = useState<string>("Corretiva");
  const [descricao, setDescricao] = useState("");
  const [colaborador, setColaborador] = useState("");
  const [oficina, setOficina] = useState<"Local" | "Terceiro">("Local");
  const [nomeOficina, setNomeOficina] = useState("");
  const [erros, setErros] = useState<string[]>([]);
  const [feito, setFeito] = useState<Retorno | null>(null);
  const [salvando, iniciar] = useTransition();

  const nomes = outro ? [ativoTexto || "Outro"] : sel.map((id) => ativos.find((a) => a.id === id)?.codigo ?? "?");

  function tocar(id: string) {
    setOutro(false);
    if (!varios) {
      setSel([id]);
      setErros([]);
      setPasso(1);
      return;
    }
    setSel(sel.includes(id) ? sel.filter((x) => x !== id) : [...sel, id]);
  }

  function avancar() {
    const e: string[] = [];
    if (passo === 0 && !sel.length && !(outro && ativoTexto.trim())) e.push(outro ? "Escreva qual é o equipamento." : "Toque no veículo ou equipamento.");
    if (passo === 1 && !descricao.trim()) e.push("Conte o que aconteceu.");
    setErros(e);
    if (!e.length) setPasso(passo + 1);
  }

  function salvar() {
    setErros([]);
    iniciar(async () => {
      const r = await abrirOS({
        usinaId: usina.id,
        ativos: outro ? [] : sel,
        ativoTexto: outro ? ativoTexto : "",
        classe,
        tipo: "",
        descricao,
        colaborador,
        oficina,
        nomeOficina,
      });
      if (r.erros?.length) setErros(r.erros);
      if (r.abertas?.length) setFeito(r);
    });
  }

  /* ---------- OS aberta: confirmação forte ---------- */
  if (feito?.abertas?.length) {
    const um = feito.abertas.length === 1 ? feito.abertas[0] : null;
    return (
      <div className="mx-auto flex max-w-md flex-col items-center gap-5 py-8 text-center">
        <span className="flex size-20 items-center justify-center rounded-full bg-ok-fundo text-ok">
          <CircleCheckBig className="size-11" />
        </span>
        <h1 className="text-3xl font-extrabold">{um ? `OS ${um.numero} aberta` : `${feito.abertas.length} OS abertas`}</h1>
        <ul className="flex w-full flex-col gap-2">
          {feito.abertas.map((o) => (
            <li key={o.id}>
              <Link href={`/tarefa/os/${o.id}`} className="flex min-h-14 items-center justify-between rounded-xl border border-linha bg-superficie px-4 font-semibold">
                <span className="font-display text-lg">{o.numero}</span>
                <span className="text-suave">{o.ativo}</span>
              </Link>
            </li>
          ))}
        </ul>
        {feito.erros?.length ? <Aviso tipo="erro">{feito.erros[0]}</Aviso> : null}
        <div className="flex w-full flex-col gap-2">
          {um ? (
            <BotaoLink href={`/tarefa/os/${um.id}`} tamanho="lg">
              Ver a OS
            </BotaoLink>
          ) : null}
          <BotaoLink href={`/tarefa/os?usina=${usina.codigo}`} tamanho="lg" variante="secundario">
            Voltar para as OS
          </BotaoLink>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto flex w-full max-w-2xl flex-col gap-5 pb-28">
      {/* cabeçalho com voltar + passos */}
      <div className="flex items-center gap-3">
        {passo > 0 ? (
          <button
            type="button"
            onClick={() => {
              setErros([]);
              setPasso(passo - 1);
            }}
            aria-label="Voltar um passo"
            className="flex size-12 shrink-0 items-center justify-center rounded-xl border border-linha bg-superficie"
          >
            <ArrowLeft className="size-6" />
          </button>
        ) : (
          <Link href={`/tarefa/os?usina=${usina.codigo}`} aria-label="Voltar para as OS" className="flex size-12 shrink-0 items-center justify-center rounded-xl border border-linha bg-superficie">
            <ArrowLeft className="size-6" />
          </Link>
        )}
        <ol className="flex flex-1 gap-1.5" aria-label="Passos">
          {PASSOS.map((p, i) => (
            <li key={p} className="flex flex-1 flex-col gap-1">
              <span className={`h-1.5 rounded-full ${i <= passo ? "bg-marca-preto dark:bg-marca" : "bg-linha"}`} />
              <span className={`text-xs font-semibold ${i === passo ? "text-tinta" : "text-suave"}`}>{p}</span>
            </li>
          ))}
        </ol>
      </div>

      {erros.length ? (
        <Aviso tipo="erro">
          {erros.map((e) => (
            <span key={e} className="block">
              {e}
            </span>
          ))}
        </Aviso>
      ) : null}

      {/* ---------- 1. veículo ---------- */}
      {passo === 0 ? (
        <section className="flex flex-col gap-4">
          <h1 className="text-3xl font-extrabold">Qual veículo ou equipamento?</h1>
          <label className="flex min-h-12 cursor-pointer items-center gap-3 rounded-xl border border-linha bg-superficie px-4 text-base font-semibold">
            <input
              type="checkbox"
              checked={varios}
              onChange={(e) => {
                setVarios(e.target.checked);
                if (!e.target.checked) setSel(sel.slice(0, 1));
              }}
              className="size-5 accent-[var(--destaque)]"
            />
            Mesmo serviço em vários veículos
          </label>
          {(["frota", "usina"] as const).map((g) => {
            const grupo = ativos.filter((a) => a.grupo === g);
            if (!grupo.length) return null;
            return (
              <div key={g} className="flex flex-col gap-2">
                <h2 className="text-sm font-bold uppercase tracking-wider text-suave">{g === "frota" ? "Frota" : "Usina e equipamentos"}</h2>
                <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
                  {grupo.map((a) => {
                    const marcado = sel.includes(a.id) && !outro;
                    return (
                      <button
                        key={a.id}
                        type="button"
                        onClick={() => tocar(a.id)}
                        aria-pressed={marcado}
                        className={`flex min-h-20 flex-col items-start justify-center gap-0.5 rounded-2xl border px-4 py-3 text-left transition active:scale-[.98] ${
                          marcado ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie hover:border-suave"
                        }`}
                      >
                        <span className="flex w-full items-center justify-between gap-2">
                          <span className="font-display text-xl font-extrabold leading-tight">{a.codigo}</span>
                          {marcado && varios ? <Check className="size-5" /> : null}
                        </span>
                        <span className={`text-sm ${marcado ? "text-marca-preto/80" : "text-suave"}`}>{a.tipo}</span>
                      </button>
                    );
                  })}
                </div>
              </div>
            );
          })}
          <button
            type="button"
            onClick={() => {
              setOutro(true);
              setSel([]);
              setVarios(false);
            }}
            aria-pressed={outro}
            className={`flex min-h-14 items-center gap-3 rounded-2xl border px-4 text-left text-base font-semibold ${outro ? "border-marca-preto bg-marca text-marca-preto" : "border-dashed border-linha bg-superficie"}`}
          >
            <Building2 className="size-5" /> Outro (prédio, ferramenta, geral)
          </button>
          {outro ? (
            <Campo rotulo="Qual?">
              <Entrada value={ativoTexto} onChange={(e) => setAtivoTexto(e.target.value)} placeholder="Ex.: portão do pátio, compressor" autoFocus />
            </Campo>
          ) : null}
        </section>
      ) : null}

      {/* ---------- 2. problema ---------- */}
      {passo === 1 ? (
        <section className="flex flex-col gap-4">
          <h1 className="text-3xl font-extrabold">O que aconteceu?</h1>
          <p className="-mt-2 text-lg text-suave">{nomes.join(", ")}</p>
          <div className="grid gap-2 sm:grid-cols-3">
            {CLASSES.map(({ k, titulo, texto, Icone }) => (
              <button
                key={k}
                type="button"
                onClick={() => setClasse(k)}
                aria-pressed={classe === k}
                className={`flex min-h-16 items-center gap-3 rounded-2xl border p-4 text-left sm:flex-col sm:items-start ${
                  classe === k ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie"
                }`}
              >
                <Icone className="size-7 shrink-0" />
                <span className="flex flex-col">
                  <span className="font-display text-lg font-bold">{titulo}</span>
                  <span className={`text-sm ${classe === k ? "text-marca-preto/80" : "text-suave"}`}>{texto}</span>
                </span>
              </button>
            ))}
          </div>
          <Campo rotulo="Descreva o problema">
            <AreaTexto value={descricao} onChange={(e) => setDescricao(e.target.value)} placeholder="Ex.: vazamento de óleo no balão" rows={4} />
          </Campo>
          <Campo rotulo="Quem relatou (motorista ou operador)">
            <Entrada value={colaborador} onChange={(e) => setColaborador(e.target.value)} autoComplete="off" />
          </Campo>
        </section>
      ) : null}

      {/* ---------- 3. oficina ---------- */}
      {passo === 2 ? (
        <section className="flex flex-col gap-4">
          <h1 className="text-3xl font-extrabold">Onde vai ser feito?</h1>
          <div className="grid grid-cols-2 gap-2">
            {(["Local", "Terceiro"] as const).map((o) => (
              <button
                key={o}
                type="button"
                onClick={() => setOficina(o)}
                aria-pressed={oficina === o}
                className={`flex min-h-24 flex-col justify-center rounded-2xl border p-4 text-left ${oficina === o ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie"}`}
              >
                <span className="font-display text-xl font-bold">{o === "Local" ? "Na usina" : "Oficina de fora"}</span>
                <span className={`text-sm ${oficina === o ? "text-marca-preto/80" : "text-suave"}`}>{o === "Local" ? "Equipe própria" : "Vai precisar da nota fiscal"}</span>
              </button>
            ))}
          </div>
          {oficina === "Terceiro" ? (
            <Campo rotulo="Nome da oficina (se já souber)">
              <Entrada value={nomeOficina} onChange={(e) => setNomeOficina(e.target.value)} />
            </Campo>
          ) : null}
        </section>
      ) : null}

      {/* ---------- 4. conferir ---------- */}
      {passo === 3 ? (
        <section className="flex flex-col gap-4">
          <h1 className="text-3xl font-extrabold">Confira e abra</h1>
          <dl className="flex flex-col divide-y divide-linha rounded-2xl border border-linha bg-superficie">
            {[
              ["Veículo", nomes.join(", ")],
              ["Tipo", CLASSES.find((c) => c.k === classe)?.titulo ?? classe],
              ["Problema", descricao],
              ["Relatou", colaborador || "—"],
              ["Oficina", oficina === "Local" ? "Na usina" : nomeOficina || "Oficina de fora"],
            ].map(([k, v]) => (
              <div key={k} className="flex gap-4 px-4 py-3">
                <dt className="w-24 shrink-0 text-sm font-semibold text-suave">{k}</dt>
                <dd className="min-w-0 flex-1 whitespace-pre-line break-words text-base">{v}</dd>
              </div>
            ))}
          </dl>
          {sel.length > 1 ? <p className="text-base text-suave">Serão abertas {sel.length} OS, uma para cada veículo, com números em sequência.</p> : null}
        </section>
      ) : null}

      {/* barra fixa de ação */}
      <div className="fixed inset-x-0 bottom-0 z-10 border-t border-linha bg-superficie/95 pb-[max(12px,env(safe-area-inset-bottom))] pt-3 backdrop-blur">
        <div className="mx-auto max-w-2xl px-[max(16px,env(safe-area-inset-left))]">
          {passo < 3 ? (
            passo === 0 && !varios && !outro ? (
              <p className="flex min-h-14 items-center justify-center text-base text-suave">Toque no veículo para continuar</p>
            ) : (
              <Botao tamanho="lg" type="button" onClick={avancar}>
                Continuar{passo === 0 && sel.length > 1 ? ` com ${sel.length} veículos` : ""}
              </Botao>
            )
          ) : (
            <Botao tamanho="lg" type="button" onClick={salvar} disabled={salvando}>
              {salvando ? "Abrindo…" : sel.length > 1 ? `Abrir ${sel.length} OS` : "Abrir OS"}
            </Botao>
          )}
        </div>
      </div>
    </div>
  );
}

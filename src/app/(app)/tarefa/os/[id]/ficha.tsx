"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState, useTransition, type ReactNode } from "react";
import { ArrowLeft, Camera, ChevronDown, FileText, Lock, Plus, Trash2 } from "lucide-react";
import { AreaTexto, Aviso, Botao, Campo, Entrada, Etiqueta, Selecao } from "@/components/ui";
import { enviarAnexo } from "@/lib/anexos";
import { brl, dataBr, lerNumero } from "@/lib/frota/consumo";
import {
  CLASSES, COR_SITUACAO, SITUACOES, TIPOS_SERVICO, pendenciasOS, totalOS,
  type Arquivo, type AtivoOS, type Compra, type LeituraOS, type OS, type Situacao,
} from "@/lib/frota/os";
import { salvarOS } from "../acoes";

type Props = {
  os: OS;
  usina: { id: string; codigo: string };
  ativos: AtivoOS[];
  leitura: LeituraOS | null;
  urls: Record<string, string>;
  gestor: boolean;
  travada: boolean;
};

const txt = (v: unknown) => (v == null ? "" : String(v));
const num = (v: number | null) => (v == null ? "" : String(v).replace(".", ","));
const NOME_CLASSE: Record<string, string> = { Corretiva: "Conserto", Preventiva: "Preventiva", Investimento: "Melhoria" };

type CompraF = { fornecedor: string; nf: string; valor: string; itens: string; arquivos: Arquivo[] };

export function FichaOS({ os, usina, ativos, leitura, urls, gestor, travada }: Props) {
  const router = useRouter();
  const [f, setF] = useState(() => ({
    status: os.status as Situacao,
    motivo_cancel: txt(os.motivo_cancel),
    ativo_id: os.ativo_id ?? (os.ativo_texto ? "_outro" : ""),
    ativo_texto: txt(os.ativo_texto),
    classe: txt(os.classe),
    tipo: txt(os.tipo),
    descricao: txt(os.descricao),
    colaborador: txt(os.colaborador),
    checklist: txt(os.checklist),
    oficina: (os.oficina ?? "Local") as "Local" | "Terceiro",
    nome_oficina: txt(os.nome_oficina),
    encarregado: txt(os.encarregado),
    inicio: txt(os.inicio),
    h_inicio: txt(os.h_inicio).slice(0, 5),
    termino: txt(os.termino),
    h_termino: txt(os.h_termino).slice(0, 5),
    servicos: txt(os.servicos),
    pecas: txt(os.pecas),
    km: num(os.km),
    horas: num(os.horas),
    valor: num(os.valor),
    nf: txt(os.nf),
    recebimento: txt(os.recebimento),
    pagamento: txt(os.pagamento),
    obs: txt(os.obs),
  }));
  const [compras, setCompras] = useState<CompraF[]>(() =>
    os.compras.map((c) => ({ fornecedor: c.fornecedor ?? "", nf: c.nf ?? "", valor: num(c.valor), itens: c.itens ?? "", arquivos: c.arquivos ?? [] })),
  );
  const [anexos, setAnexos] = useState<Arquivo[]>(os.anexos);
  const [nfArq, setNfArq] = useState<Arquivo[]>(os.nf_arquivos);
  const [enviando, setEnviando] = useState<string | null>(null);
  const [msg, setMsg] = useState<{ ok?: string; erros?: string[] }>({});
  const [salvando, iniciar] = useTransition();
  const [tentou, setTentou] = useState(false);

  const mudar = <K extends keyof typeof f>(k: K, v: (typeof f)[K]) => setF((x) => ({ ...x, [k]: v }));
  const ativo = ativos.find((a) => a.id === f.ativo_id) ?? null;
  const nomeAtivo = ativo?.codigo ?? (f.ativo_texto || "—");

  // Mesma conferência do servidor, para mostrar o que falta antes de tocar em Salvar.
  const montado: OS = useMemo(
    () => ({
      ...os,
      ...f,
      ativo_id: ativo?.id ?? null,
      ativo_texto: ativo ? null : f.ativo_texto,
      classe: (f.classe || null) as OS["classe"],
      oficina: f.oficina,
      km: lerNumero(f.km),
      horas: lerNumero(f.horas),
      valor: lerNumero(f.valor),
      compras: compras.map((c): Compra => ({ ...c, valor: lerNumero(c.valor) })),
      anexos,
      nf_arquivos: nfArq,
    }),
    [os, f, ativo, compras, anexos, nfArq],
  );
  const pend = useMemo(() => (os.origem === "importado" ? [] : pendenciasOS(montado, ativo, leitura)), [montado, ativo, leitura, os.origem]);
  const total = totalOS(montado);
  const concluindo = f.status === "Concluída" && os.status !== "Concluída";

  async function anexar(arqs: FileList | null, destino: "anexo" | "nf" | number) {
    if (!arqs?.length) return;
    setEnviando(String(destino));
    setMsg({});
    try {
      for (const a of Array.from(arqs)) {
        const novo = await enviarAnexo(usina.id, `os/${os.numero}`, a);
        if (destino === "anexo") setAnexos((x) => [...x, novo]);
        else if (destino === "nf") setNfArq((x) => [...x, novo]);
        else setCompras((cs) => cs.map((c, i) => (i === destino ? { ...c, arquivos: [...c.arquivos, novo] } : c)));
      }
    } catch (e) {
      setMsg({ erros: [(e as Error).message] });
    } finally {
      setEnviando(null);
    }
  }

  function salvar() {
    setTentou(true);
    setMsg({});
    if (pend.length) {
      setMsg({ erros: pend });
      window.scrollTo({ top: 0, behavior: "smooth" });
      return;
    }
    iniciar(async () => {
      const r = await salvarOS(os.id, {
        ...f,
        ativo_id: ativo?.id ?? "",
        ativo_texto: ativo ? "" : f.ativo_texto,
        compras,
        anexos,
        nf_arquivos: nfArq,
      });
      setMsg(r);
      if (r.erros?.length) window.scrollTo({ top: 0, behavior: "smooth" });
      if (r.ok) router.refresh();
    });
  }

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4 pb-36">
      {/* ---------- cabeçalho ---------- */}
      <div className="flex items-start gap-3">
        <Link href={`/tarefa/os?usina=${usina.codigo}`} aria-label="Voltar para as OS" className="flex size-12 shrink-0 items-center justify-center rounded-xl border border-linha bg-superficie">
          <ArrowLeft className="size-6" />
        </Link>
        <div className="min-w-0 flex-1">
          <p className="text-sm font-bold uppercase tracking-wider text-suave">
            OS {os.numero}
            {os.numero_antigo ? ` · antiga ${os.numero_antigo}` : ""}
          </p>
          <h1 className="text-3xl font-extrabold leading-tight">{nomeAtivo}</h1>
          <p className="mt-1 flex flex-wrap items-center gap-2 text-sm text-suave">
            <Etiqueta tom={COR_SITUACAO[os.status]}>{os.status}</Etiqueta>
            {os.classe ? <span>{NOME_CLASSE[os.classe] ?? os.classe}</span> : null}
            {os.abertura ? <span>aberta em {dataBr(os.abertura)}</span> : null}
            {os.criado_por_nome ? <span>por {os.criado_por_nome}</span> : null}
          </p>
        </div>
      </div>

      {travada ? (
        <Aviso tipo="alerta">
          <span className="flex items-center gap-2">
            <Lock className="size-4 shrink-0" />
            {os.origem === "importado" ? "OS do sistema antigo." : `OS ${os.status.toLowerCase()}.`} Só a gestão da usina altera.
          </span>
        </Aviso>
      ) : null}
      {msg.ok ? <Aviso tipo="ok">{msg.ok}</Aviso> : null}
      {msg.erros?.length ? (
        <Aviso tipo="erro">
          <b className="block">{f.status === "Concluída" ? "Falta para concluir:" : "Corrija antes de salvar:"}</b>
          {msg.erros.map((e) => (
            <span key={e} className="block">
              · {e}
            </span>
          ))}
        </Aviso>
      ) : null}
      {os.lote_obs ? <Aviso tipo="alerta">{os.lote_obs}</Aviso> : null}

      <fieldset disabled={travada} className="flex min-w-0 flex-col gap-4">
        {/* ---------- situação ---------- */}
        <section className="flex flex-col gap-3 rounded-2xl border border-linha bg-superficie p-4">
          <h2 className="text-lg font-bold">Situação</h2>
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-5">
            {SITUACOES.map((st) => (
              <button
                key={st}
                type="button"
                onClick={() => mudar("status", st)}
                aria-pressed={f.status === st}
                className={`min-h-14 rounded-xl border px-3 text-base font-semibold transition ${
                  f.status === st ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-fundo text-tinta"
                } ${st === "Concluída" ? "col-span-2 sm:col-span-1" : ""}`}
              >
                {st}
              </button>
            ))}
          </div>
          {f.status === "Cancelada" ? (
            <Campo rotulo="Motivo do cancelamento">
              <AreaTexto value={f.motivo_cancel} onChange={(e) => mudar("motivo_cancel", e.target.value)} />
            </Campo>
          ) : null}
          {f.status === "Concluída" && os.status !== "Concluída" && pend.length ? (
            <p className="text-sm text-alerta">
              Faltam {pend.length} {pend.length === 1 ? "item" : "itens"} para concluir. Eles aparecem ao tocar em Concluir.
            </p>
          ) : null}
        </section>

        {/* ---------- problema ---------- */}
        <Secao titulo="Problema" resumo={[NOME_CLASSE[f.classe] ?? f.classe, f.descricao].filter(Boolean).join(" · ")} aberta={!f.descricao}>
          <div className="grid gap-4 sm:grid-cols-2">
            <Campo rotulo="Veículo ou equipamento">
              <Selecao value={f.ativo_id} onChange={(e) => mudar("ativo_id", e.target.value)}>
                <option value="">Escolha…</option>
                {ativos.map((a) => (
                  <option key={a.id} value={a.id}>
                    {a.codigo} · {a.tipo}
                  </option>
                ))}
                <option value="_outro">Outro / geral</option>
              </Selecao>
            </Campo>
            {f.ativo_id === "_outro" ? (
              <Campo rotulo="Qual?">
                <Entrada value={f.ativo_texto} onChange={(e) => mudar("ativo_texto", e.target.value)} />
              </Campo>
            ) : (
              <Campo rotulo="Tipo de serviço">
                <Selecao value={f.tipo} onChange={(e) => mudar("tipo", e.target.value)}>
                  <option value="">—</option>
                  {TIPOS_SERVICO.map((t) => (
                    <option key={t}>{t}</option>
                  ))}
                </Selecao>
              </Campo>
            )}
          </div>
          <div className="grid grid-cols-3 gap-2">
            {CLASSES.map((c) => (
              <button
                key={c}
                type="button"
                onClick={() => mudar("classe", c)}
                aria-pressed={f.classe === c}
                className={`min-h-12 rounded-xl border px-2 font-semibold ${f.classe === c ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-fundo"}`}
              >
                {NOME_CLASSE[c]}
              </button>
            ))}
          </div>
          <Campo rotulo="Descrição do problema">
            <AreaTexto value={f.descricao} onChange={(e) => mudar("descricao", e.target.value)} />
          </Campo>
          <div className="grid gap-4 sm:grid-cols-2">
            <Campo rotulo="Quem relatou (motorista ou operador)">
              <Entrada value={f.colaborador} onChange={(e) => mudar("colaborador", e.target.value)} />
            </Campo>
            <Campo rotulo="Veio do check-list do dia">
              <Entrada type="date" value={f.checklist} onChange={(e) => mudar("checklist", e.target.value)} />
            </Campo>
          </div>
        </Secao>

        {/* ---------- oficina ---------- */}
        <Secao
          titulo="Oficina e prazo"
          resumo={[f.oficina === "Local" ? "Na usina" : f.nome_oficina || "Oficina de fora", f.inicio && `início ${dataBr(f.inicio)}`, f.termino && `fim ${dataBr(f.termino)}`]
            .filter(Boolean)
            .join(" · ")}
        >
          <div className="grid grid-cols-2 gap-2">
            {(["Local", "Terceiro"] as const).map((o) => (
              <button
                key={o}
                type="button"
                onClick={() => mudar("oficina", o)}
                aria-pressed={f.oficina === o}
                className={`min-h-12 rounded-xl border px-3 font-semibold ${f.oficina === o ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-fundo"}`}
              >
                {o === "Local" ? "Na usina" : "Oficina de fora"}
              </button>
            ))}
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <Campo rotulo="Nome da oficina">
              <Entrada value={f.nome_oficina} onChange={(e) => mudar("nome_oficina", e.target.value)} />
            </Campo>
            <Campo rotulo="Encarregado de manutenção">
              <Entrada value={f.encarregado} onChange={(e) => mudar("encarregado", e.target.value)} />
            </Campo>
          </div>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <Campo rotulo="Início">
              <Entrada type="date" value={f.inicio} onChange={(e) => mudar("inicio", e.target.value)} />
            </Campo>
            <Campo rotulo="Hora">
              <Entrada type="time" value={f.h_inicio} onChange={(e) => mudar("h_inicio", e.target.value)} />
            </Campo>
            <Campo rotulo="Término">
              <Entrada type="date" value={f.termino} onChange={(e) => mudar("termino", e.target.value)} />
            </Campo>
            <Campo rotulo="Hora">
              <Entrada type="time" value={f.h_termino} onChange={(e) => mudar("h_termino", e.target.value)} />
            </Campo>
          </div>
        </Secao>

        {/* ---------- serviço feito ---------- */}
        <Secao titulo="Serviço feito" resumo={f.servicos} aberta={f.status === "Concluída" || !!f.servicos}>
          <Campo rotulo="O que foi feito">
            <AreaTexto value={f.servicos} onChange={(e) => mudar("servicos", e.target.value)} />
          </Campo>
          <Campo rotulo="Peças e materiais usados" dica="Uma por linha: quantidade e descrição.">
            <AreaTexto value={f.pecas} onChange={(e) => mudar("pecas", e.target.value)} />
          </Campo>
          {ativo?.grupo === "frota" && (ativo.usa_km || ativo.usa_hora) ? (
            <div className="grid grid-cols-2 gap-4">
              {ativo.usa_km ? (
                <Campo rotulo="Km no dia do serviço" dica={leitura?.km != null ? `Última leitura: ${leitura.km.toLocaleString("pt-BR")} km` : undefined}>
                  <Entrada inputMode="numeric" value={f.km} onChange={(e) => mudar("km", e.target.value)} className="tabular-nums" />
                </Campo>
              ) : null}
              {ativo.usa_hora ? (
                <Campo rotulo="Horímetro no dia" dica={leitura?.horas != null ? `Última leitura: ${leitura.horas.toLocaleString("pt-BR")} h` : undefined}>
                  <Entrada inputMode="decimal" value={f.horas} onChange={(e) => mudar("horas", e.target.value)} className="tabular-nums" />
                </Campo>
              ) : null}
            </div>
          ) : null}
        </Secao>

        {/* ---------- valores e nota ---------- */}
        <Secao
          titulo={f.oficina === "Terceiro" ? "Valor e nota da oficina" : "Mão de obra"}
          resumo={[f.valor && brl(lerNumero(f.valor)), f.nf && `NF ${f.nf}`].filter(Boolean).join(" · ")}
          aberta={f.oficina === "Terceiro" && f.status === "Concluída"}
        >
          <div className="grid gap-4 sm:grid-cols-3">
            <Campo rotulo={f.oficina === "Terceiro" ? "Valor do serviço (R$)" : "Mão de obra (R$), se houver"}>
              <Entrada inputMode="decimal" value={f.valor} onChange={(e) => mudar("valor", e.target.value)} className="tabular-nums" />
            </Campo>
            <Campo rotulo="Nº da nota fiscal">
              <Entrada value={f.nf} onChange={(e) => mudar("nf", e.target.value)} />
            </Campo>
            <Campo rotulo="Recebido em">
              <Entrada type="date" value={f.recebimento} onChange={(e) => mudar("recebimento", e.target.value)} />
            </Campo>
          </div>
          <Campo rotulo="Dados para pagamento (Pix, banco)">
            <Entrada value={f.pagamento} onChange={(e) => mudar("pagamento", e.target.value)} />
          </Campo>
          {f.oficina === "Terceiro" ? (
            <Arquivos
              titulo="Nota fiscal da oficina"
              lista={nfArq}
              urls={urls}
              enviando={enviando === "nf"}
              rotulo="Foto ou PDF da nota"
              aoEscolher={(a) => anexar(a, "nf")}
              aoRemover={(i) => setNfArq(nfArq.filter((_, j) => j !== i))}
              podeRemover={!travada}
            />
          ) : null}
        </Secao>

        {/* ---------- compras ---------- */}
        <Secao
          titulo="Material comprado fora"
          resumo={compras.length ? `${compras.length} ${compras.length === 1 ? "compra" : "compras"} · ${brl(compras.reduce((t, c) => t + (lerNumero(c.valor) ?? 0), 0))}` : "Nenhuma"}
          aberta={compras.length > 0 && f.status === "Concluída"}
        >
          <p className="text-sm text-suave">Peça ou material comprado em loja. Cada compra precisa de fornecedor, nota, valor e foto da nota para concluir a OS.</p>
          {compras.map((c, i) => (
            <div key={i} className="flex flex-col gap-3 rounded-xl border border-linha bg-afundado p-3">
              <div className="flex items-center justify-between gap-2">
                <b>Compra {i + 1}</b>
                {!travada ? (
                  <button type="button" onClick={() => setCompras(compras.filter((_, j) => j !== i))} className="flex min-h-11 items-center gap-1 rounded-lg px-2 text-sm font-semibold text-erro">
                    <Trash2 className="size-4" /> Remover
                  </button>
                ) : null}
              </div>
              <div className="grid gap-3 sm:grid-cols-3">
                <Campo rotulo="Fornecedor">
                  <Entrada value={c.fornecedor} onChange={(e) => setCompras(compras.map((x, j) => (j === i ? { ...x, fornecedor: e.target.value } : x)))} />
                </Campo>
                <Campo rotulo="Nº da nota">
                  <Entrada value={c.nf} onChange={(e) => setCompras(compras.map((x, j) => (j === i ? { ...x, nf: e.target.value } : x)))} />
                </Campo>
                <Campo rotulo="Valor (R$)">
                  <Entrada inputMode="decimal" value={c.valor} onChange={(e) => setCompras(compras.map((x, j) => (j === i ? { ...x, valor: e.target.value } : x)))} className="tabular-nums" />
                </Campo>
              </div>
              <Campo rotulo="Itens comprados">
                <Entrada value={c.itens} onChange={(e) => setCompras(compras.map((x, j) => (j === i ? { ...x, itens: e.target.value } : x)))} placeholder="Ex.: 2 mangueiras 1/2, abraçadeiras" />
              </Campo>
              <Arquivos
                titulo="Nota da compra"
                lista={c.arquivos}
                urls={urls}
                enviando={enviando === String(i)}
                rotulo="Foto da nota"
                aoEscolher={(a) => anexar(a, i)}
                aoRemover={(k) => setCompras(compras.map((x, j) => (j === i ? { ...x, arquivos: x.arquivos.filter((_, m) => m !== k) } : x)))}
                podeRemover={!travada}
              />
            </div>
          ))}
          {!travada ? (
            <button
              type="button"
              onClick={() => setCompras([...compras, { fornecedor: "", nf: "", valor: "", itens: "", arquivos: [] }])}
              className="flex min-h-12 items-center justify-center gap-2 rounded-xl border border-dashed border-linha font-semibold hover:border-suave"
            >
              <Plus className="size-5" /> Adicionar compra
            </button>
          ) : null}
        </Secao>

        {/* ---------- fotos e observações ---------- */}
        <Secao titulo="Fotos e documentos" resumo={anexos.length ? `${anexos.length} anexo(s)` : "Nenhum"}>
          <Arquivos
            titulo="Orçamento, recibo, laudo ou foto do serviço"
            lista={anexos}
            urls={urls}
            enviando={enviando === "anexo"}
            rotulo="Anexar foto ou PDF"
            aoEscolher={(a) => anexar(a, "anexo")}
            aoRemover={(i) => setAnexos(anexos.filter((_, j) => j !== i))}
            podeRemover={!travada}
          />
          <Campo rotulo="Observações">
            <AreaTexto value={f.obs} onChange={(e) => mudar("obs", e.target.value)} />
          </Campo>
        </Secao>
      </fieldset>

      {os.atualizado_por_nome ? (
        <p className="text-sm text-suave">
          Última alteração por {os.atualizado_por_nome} em {new Date(os.atualizado_em).toLocaleString("pt-BR", { timeZone: "America/Bahia", dateStyle: "short", timeStyle: "short" })}.
          {gestor ? " OS não se apaga: para anular, use Cancelada." : ""}
        </p>
      ) : null}

      {/* ---------- barra fixa ---------- */}
      {!travada ? (
        <div className="fixed inset-x-0 bottom-0 z-10 border-t border-linha bg-superficie/95 pb-[max(12px,env(safe-area-inset-bottom))] pt-3 backdrop-blur">
          <div className="mx-auto flex max-w-3xl items-center gap-3 px-[max(16px,env(safe-area-inset-left))]">
            <span className="flex flex-col leading-tight">
              <span className="text-xs font-semibold uppercase tracking-wider text-suave">Total</span>
              <b className="font-display text-xl tabular-nums">{brl(total)}</b>
            </span>
            <Botao tamanho="lg" type="button" onClick={salvar} disabled={salvando || !!enviando} className="flex-1">
              {salvando ? "Salvando…" : enviando ? "Enviando arquivo…" : concluindo ? (tentou && pend.length ? `Concluir (faltam ${pend.length})` : "Concluir OS") : "Salvar"}
            </Botao>
          </div>
        </div>
      ) : null}
    </div>
  );
}

/* Seção recolhível: no celular só uma parte aparece por vez; o resumo diz o que já foi preenchido. */
function Secao({ titulo, resumo, aberta = false, children }: { titulo: string; resumo?: string; aberta?: boolean; children: ReactNode }) {
  // Só decide na entrada da tela: depois quem abre e fecha é a pessoa (não fecha enquanto ela digita).
  const [inicial] = useState(aberta);
  return (
    <details open={inicial} className="group rounded-2xl border border-linha bg-superficie">
      <summary className="flex min-h-16 cursor-pointer list-none items-center gap-3 px-4 py-3 [&::-webkit-details-marker]:hidden">
        <span className="flex min-w-0 flex-1 flex-col">
          <span className="text-lg font-bold">{titulo}</span>
          {resumo ? <span className="truncate text-sm text-suave">{resumo}</span> : null}
        </span>
        <ChevronDown className="size-5 shrink-0 text-suave transition group-open:rotate-180" />
      </summary>
      <div className="flex flex-col gap-4 border-t border-linha px-4 pb-4 pt-4">{children}</div>
    </details>
  );
}

function Arquivos({
  titulo, lista, urls, enviando, rotulo, aoEscolher, aoRemover, podeRemover,
}: {
  titulo: string;
  lista: Arquivo[];
  urls: Record<string, string>;
  enviando: boolean;
  rotulo: string;
  aoEscolher: (a: FileList | null) => void;
  aoRemover: (i: number) => void;
  podeRemover: boolean;
}) {
  return (
    <div className="flex flex-col gap-2">
      <span className="text-sm font-semibold text-suave">{titulo}</span>
      {lista.length ? (
        <ul className="flex flex-wrap gap-2">
          {lista.map((a, i) => {
            const url = a.caminho ? urls[a.caminho] : undefined;
            const imagem = a.tipo?.startsWith("image/");
            return (
              <li key={(a.caminho ?? a.id ?? "") + i} className="relative">
                {url ? (
                  <a href={url} target="_blank" rel="noopener" className="flex size-24 items-center justify-center overflow-hidden rounded-xl border border-linha bg-afundado">
                    {imagem ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img src={url} alt={a.nome} className="size-full object-cover" />
                    ) : (
                      <span className="flex flex-col items-center gap-1 text-xs font-semibold text-suave">
                        <FileText className="size-7" /> PDF
                      </span>
                    )}
                  </a>
                ) : (
                  <span className="flex size-24 flex-col items-center justify-center gap-1 rounded-xl border border-dashed border-linha p-2 text-center text-xs text-suave">
                    <FileText className="size-6" />
                    {a.caminho ? "Enviado" : "No sistema antigo"}
                  </span>
                )}
                {podeRemover ? (
                  <button
                    type="button"
                    onClick={() => aoRemover(i)}
                    aria-label={`Tirar ${a.nome}`}
                    className="absolute -right-2 -top-2 flex size-8 items-center justify-center rounded-full border border-linha bg-superficie text-erro shadow-sm"
                  >
                    <Trash2 className="size-4" />
                  </button>
                ) : null}
              </li>
            );
          })}
        </ul>
      ) : null}
      {podeRemover ? (
        <label className={`flex min-h-12 cursor-pointer items-center justify-center gap-2 rounded-xl border border-linha bg-fundo px-4 font-semibold ${enviando ? "opacity-60" : "hover:border-suave"}`}>
          <Camera className="size-5" />
          {enviando ? "Enviando…" : rotulo}
          <input
            type="file"
            accept="image/*,application/pdf"
            multiple
            className="sr-only"
            disabled={enviando}
            onChange={(e) => {
              aoEscolher(e.target.files);
              e.target.value = "";
            }}
          />
        </label>
      ) : null}
    </div>
  );
}

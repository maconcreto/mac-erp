"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState, useTransition, type ReactNode } from "react";
import { Aviso, Botao, Entrada, Etiqueta } from "@/components/ui";
import {
  AUTOVOL, BOMBAS, PRODUZ, avaliar, brl, dataBr, lerNumero, n, somaHoje,
  type Acumulado, type Ativo, type Leitura, type Limites, type Linha,
} from "@/lib/frota/consumo";
import { normalizar } from "@/lib/frota/regras";
import { salvarDia, type Modo } from "./acoes";

type Derivado = { ant: Leitura; acum: Acumulado; ultMotorista: string };
type Boletim = { id: string; status: "aberto" | "fechado"; origem: "lancado" | "importado"; sem_producao: boolean; atualizado_em: string } | null;

type Props = {
  usina: { id: string; codigo: string };
  data: string;
  hoje: string;
  proximoLiberado: boolean;
  gestor: boolean;
  veiculos: Ativo[];
  central: Ativo | null;
  derivados: Record<string, Derivado>;
  linhas: Record<string, Linha>;
  boletim: Boletim;
  lim: Limites;
  postoPadrao: string;
  pendentes: string[];
  abertos: string[];
  osAbertas: { numero: string; descricao: string | null; ativo_id: string | null }[];
  volAcum: number | null;
};

/* Tudo que o usuário digita fica como texto; a conversão acontece nos cálculos. */
type F = {
  parado: boolean; sit: "" | "servico" | "manut"; sem_prod: string; os_ref: string; motorista: string;
  viagens: string; m3: string; vb: string; m3b: string;
  km0: string; km1: string; h0: string; h1: string; hb0: string; hb1: string;
  litros: string; preco: string; posto: string; justificativa: string; obs: string;
};
type Texto = Exclude<keyof F, "parado" | "sit">;

const fmtIn = (v: number | null | undefined) => (v == null ? "" : String(v).replace(".", ","));
const vazioF = (): F => ({
  parado: false, sit: "", sem_prod: "", os_ref: "", motorista: "", viagens: "", m3: "", vb: "", m3b: "",
  km0: "", km1: "", h0: "", h1: "", hb0: "", hb1: "", litros: "", preco: "", posto: "", justificativa: "", obs: "",
});
function deLinha(l: Linha): F {
  const f = vazioF();
  f.parado = l.parado;
  f.sit = l.sit === "servico" || l.sit === "manut" ? l.sit : "";
  (["sem_prod", "os_ref", "motorista", "posto", "justificativa", "obs"] as const).forEach((k) => (f[k] = l[k] ?? ""));
  (["viagens", "m3", "vb", "m3b", "km0", "km1", "h0", "h1", "hb0", "hb1", "litros"] as const).forEach((k) => (f[k] = fmtIn(l[k])));
  f.preco = fmtIn(l.preco ?? (l.valor && l.litros ? Math.round((l.valor / l.litros) * 1000) / 1000 : null));
  return f;
}

export function FormBoletim(p: Props) {
  const router = useRouter();
  const [salvando, iniciar] = useTransition();
  const chave = `rascunho:${p.usina.id}:${p.data}`;

  const inicial = useMemo(() => {
    const itens: Record<string, F> = {};
    for (const v of p.veiculos) {
      const l = p.linhas[v.id];
      itens[v.id] = l ? deLinha(l) : { ...vazioF(), parado: v.fora_operacao };
    }
    return { itens, usinaM3: fmtIn(p.central ? p.linhas[p.central.id]?.m3 : null) };
  }, [p.veiculos, p.linhas, p.central]);

  const [itens, setItens] = useState<Record<string, F>>(inicial.itens);
  const [usinaM3, setUsinaM3] = useState(inicial.usinaM3);
  const [erros, setErros] = useState<string[]>([]);
  const [aviso, setAviso] = useState<string | null>(null);
  const [recuperado, setRecuperado] = useState<string | null>(null);

  const dirty = JSON.stringify({ itens, usinaM3 }) !== JSON.stringify(inicial);
  const jaMontou = useRef(false);

  // Rascunho no aparelho: se a energia/sinal cair, o que foi digitado volta.
  useEffect(() => {
    try {
      const r = JSON.parse(localStorage.getItem(chave) ?? "null");
      if (r?.itens && String(r.em) > (p.boletim?.atualizado_em ?? "")) {
        setItens(r.itens);
        setUsinaM3(r.usinaM3 ?? "");
        setRecuperado(r.em);
      } else if (r) localStorage.removeItem(chave);
    } catch {}
    jaMontou.current = true;
  }, [chave, p.boletim?.atualizado_em]);
  useEffect(() => {
    if (!jaMontou.current) return;
    const t = setTimeout(() => {
      try {
        if (dirty) localStorage.setItem(chave, JSON.stringify({ itens, usinaM3, em: new Date().toISOString() }));
      } catch {}
    }, 400);
    return () => clearTimeout(t);
  }, [itens, usinaM3, dirty, chave]);

  const set = (id: string, campo: keyof F, valor: string | boolean) =>
    setItens((a) => ({ ...a, [id]: { ...a[id], [campo]: valor } }));
  const setSit = (id: string, k: "" | "servico" | "manut" | "parado") =>
    setItens((a) => ({ ...a, [id]: { ...a[id], parado: k === "parado", sit: k === "parado" ? "" : k } }));

  const bloqueado = !p.gestor && p.pendentes.length > 0;
  const importado = p.boletim?.origem === "importado";
  const existe = !!p.boletim && (Object.values(p.linhas).length > 0 || p.boletim.sem_producao);
  const usinaM3n = lerNumero(usinaM3);

  let pend = 0, pendLeit = 0, lancados = 0;
  const cartoes = p.veiculos.map((v) => {
    const f = itens[v.id];
    const d = p.derivados[v.id];
    const l = normalizar(f);
    const bomba = BOMBAS.has(v.tipo);
    const lit = l.litros ?? null;
    const abast = (lit ?? 0) > 0;
    const hojeL = { ...l, m3: AUTOVOL.has(v.tipo) ? (usinaM3n ?? 0) : l.m3 };
    const A = somaHoje(d.acum, hojeL, d.ant);
    const ev = abast ? avaliar(v, lit, A, p.lim) : null;
    const ativoHoje = (l.m3 ?? 0) > 0 || (l.viagens ?? 0) > 0 || abast;
    const over = !!ev?.over;
    if (over && !f.justificativa.trim()) pend++;
    const leit = bomba && !f.parado && ativoHoje && !(l.km1 != null && l.h1 != null && l.hb1 != null);
    if (leit) pendLeit++;
    const preenchido = ativoHoje || f.parado || !!f.sit || l.km1 != null;
    if (preenchido) lancados++;
    return { v, f, d, l, bomba, abast, A, ev, ativoHoje, over, leit, preenchido };
  });

  function ir(data: string) {
    router.push(`/tarefa/boletim?data=${data}`);
  }
  const dia = (delta: number) => {
    const d = new Date(p.data + "T12:00:00Z");
    d.setUTCDate(d.getUTCDate() + delta);
    return d.toISOString().slice(0, 10);
  };

  function gravar(modo: Modo) {
    setErros([]);
    setAviso(null);
    iniciar(async () => {
      const r = await salvarDia({ usinaId: p.usina.id, data: p.data, modo, linhas: itens, usinaM3 });
      if (r.erros?.length) {
        setErros(r.erros);
        return;
      }
      try { localStorage.removeItem(chave); } catch {}
      setAviso(r.ok ?? "Salvo.");
      router.refresh();
    });
  }

  return (
    <div className="flex flex-col gap-4 pb-28">
      {/* data */}
      <div className="flex flex-wrap items-end gap-3 rounded-2xl border border-linha bg-superficie p-4">
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-semibold text-suave">Data</span>
          <Entrada type="date" value={p.data} max={p.hoje} onChange={(e) => e.target.value && ir(e.target.value)} className="w-auto" />
        </label>
        <div className="flex gap-2">
          <Botao variante="secundario" onClick={() => ir(dia(-1))} aria-label="Dia anterior">‹</Botao>
          <Botao variante="secundario" onClick={() => ir(p.hoje)}>Hoje</Botao>
          <Botao variante="secundario" onClick={() => ir(dia(1))} disabled={!p.proximoLiberado} aria-label="Próximo dia">›</Botao>
        </div>
        <p className="min-w-56 flex-1 text-sm text-suave">
          Lance as viagens e os m³ do relatório de faturamento do dia. Ao abastecer, informe litros, preço e as leituras.
        </p>
      </div>

      {recuperado ? (
        <Aviso tipo="alerta">
          <b>Rascunho recuperado.</b> O que foi digitado em{" "}
          {new Date(recuperado).toLocaleString("pt-BR", { day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit" })} e ainda não tinha sido
          salvo voltou. Confira e toque em Salvar parcial ou Fechar o dia.
        </Aviso>
      ) : null}
      {importado ? (
        <Aviso tipo="alerta">Este dia veio da planilha de controle de combustível. Se você salvar, os valores passam a valer como lançamento da plataforma.</Aviso>
      ) : p.boletim?.sem_producao && !dirty ? (
        <Aviso tipo="alerta">Dia fechado como <b>sem produção</b>. Se houve produção, lance os dados e feche de novo.</Aviso>
      ) : p.boletim?.status === "aberto" ? (
        <Aviso tipo="alerta">
          <b>Dia em aberto.</b> Salvo parcialmente às {new Date(p.boletim.atualizado_em).toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}. Continue
          lançando ao longo do dia e toque em <b>Fechar o dia</b> quando a produção terminar (pode ser no dia seguinte).
        </Aviso>
      ) : existe && !dirty ? (
        <Aviso tipo="ok">Boletim deste dia já foi fechado. Você pode corrigir e fechar de novo.</Aviso>
      ) : null}
      {bloqueado ? (
        <Aviso tipo="erro">
          <b>Os lançamentos seguem a ordem dos dias.</b> Para lançar {dataBr(p.data)}, feche antes:{" "}
          {p.pendentes.slice(0, 10).map((d) => (
            <Link key={d} href={`/tarefa/boletim?data=${d}`} className="mr-2 inline-block rounded-lg border border-erro/40 px-2 py-1 underline">
              {dataBr(d)}
            </Link>
          ))}
          {p.pendentes.length > 10 ? "…" : ""}
          <br />
          <span className="text-sm">Dia sem produção (domingo, feriado, chuva)? Abra o dia e toque em <b>Dia sem produção</b>.</span>
        </Aviso>
      ) : null}
      {p.abertos.length ? (
        <Aviso tipo="alerta">
          <b>Dias ainda em aberto:</b>{" "}
          {p.abertos.map((d) => (
            <Link key={d} href={`/tarefa/boletim?data=${d}`} className="mr-2 inline-block rounded-lg border border-alerta/40 px-2 py-1 underline">
              {dataBr(d)}
            </Link>
          ))}
        </Aviso>
      ) : null}

      {/* produção total da usina */}
      {p.central ? (
        <section className="flex flex-col gap-3 rounded-2xl border border-linha bg-superficie p-4">
          <div className="flex flex-wrap items-start justify-between gap-2">
            <div>
              <p className="text-sm font-bold uppercase tracking-wider text-suave">Usina · {p.central.codigo}</p>
              <h2 className="text-lg font-bold">Produção total da usina no dia</h2>
              <p className="text-sm text-suave">Total de m³ produzidos no dia, conforme o relatório de faturamento, incluindo as entregas de betoneiras de terceiros.</p>
            </div>
            <div className="text-right text-sm text-suave">
              {p.central.data_inicio ? <div>{mesesDesde(p.central.data_inicio, p.data)} meses de operação</div> : null}
              {p.volAcum != null ? <div>{n(p.volAcum, 1)} m³ acumulados</div> : null}
            </div>
          </div>
          <div className="max-w-xs">
            <Num rotulo="m³ produzidos" valor={usinaM3} onChange={setUsinaM3} />
          </div>
        </section>
      ) : null}

      {/* veículos */}
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        {cartoes.map(({ v, f, d, l, bomba, abast, A, ev, ativoHoje, over, leit, preenchido }) => {
          const sit = f.parado ? "parado" : f.sit;
          const produz = PRODUZ.has(v.tipo);
          const km0 = f.km0 || fmtIn(d.ant.km), h0 = f.h0 || fmtIn(d.ant.h), hb0 = f.hb0 || fmtIn(d.ant.hb);
          const kmr = l.km1 != null && (lerNumero(km0) ?? null) != null ? l.km1 - (lerNumero(km0) as number) : null;
          const hr = l.h1 != null && (lerNumero(h0) ?? null) != null ? l.h1 - (lerNumero(h0) as number) : null;
          const val = l.preco && l.litros ? Math.round(l.litros * l.preco * 100) / 100 : null;
          const osv = p.osAbertas.filter((o) => o.ativo_id === v.id);
          const etiqueta = over ? (
            <span className="rounded-full bg-erro-fundo px-2.5 py-0.5 text-xs font-bold text-erro">{n(ev?.lm3, 2)} L/m³</span>
          ) : f.parado ? <Etiqueta>Parado</Etiqueta>
            : f.sit === "manut" ? <Etiqueta tom="marca">Manutenção</Etiqueta>
            : f.sit === "servico" ? <Etiqueta tom="marca">Serviço s/ produção</Etiqueta>
            : leit ? <span className="rounded-full bg-alerta-fundo px-2.5 py-0.5 text-xs font-bold text-alerta">Leituras pendentes</span>
            : preenchido ? <Etiqueta tom="ok">Lançado</Etiqueta> : <Etiqueta>Pendente</Etiqueta>;

          return (
            <section key={v.id} className={`flex flex-col gap-3 rounded-2xl border bg-superficie p-4 ${over || (leit && preenchido) ? "border-erro" : preenchido ? "border-ok/50" : "border-linha"}`}>
              <div className="flex items-start justify-between gap-2">
                <div>
                  <h3 className="font-display text-xl font-extrabold">{v.codigo}</h3>
                  <p className="text-sm text-suave">
                    {v.tipo}
                    {v.fora_operacao ? " · fora de operação" : ""}
                    {!v.regra_consumo ? " · sem regra de L/m³" : bomba ? ` · limite ${n(ev?.lim ?? p.lim.bomba, 1)} L/m³ total e ${n(p.lim.implemento, 1)} L/m³ implemento` : ""}
                  </p>
                </div>
                {etiqueta}
              </div>

              <div role="group" aria-label="Situação no dia" className="grid grid-cols-2 gap-2 sm:grid-cols-4">
                {([["", "Trabalhou"], ["servico", "Serviço sem produção"], ["manut", "Em manutenção"], ["parado", "Parado"]] as const).map(([k, rot]) => (
                  <button
                    key={k}
                    type="button"
                    aria-pressed={sit === k}
                    onClick={() => setSit(v.id, k)}
                    className={`min-h-12 rounded-xl border px-2 text-[15px] font-semibold leading-tight ${sit === k ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-fundo text-tinta"}`}
                  >
                    {rot}
                  </button>
                ))}
              </div>

              {sit === "manut" ? (
                <Caixa titulo="Em manutenção">
                  <label className="flex flex-col gap-1.5">
                    <span className="text-sm font-semibold text-suave">OS da manutenção</span>
                    <select
                      value={f.os_ref}
                      onChange={(e) => set(v.id, "os_ref", e.target.value)}
                      className="min-h-12 w-full rounded-xl border border-linha bg-fundo px-4 text-base"
                    >
                      <option value="">{osv.length ? "Selecione…" : "Nenhuma OS aberta para este veículo"}</option>
                      {osv.map((o) => (
                        <option key={o.numero} value={o.numero}>{o.numero} · {(o.descricao ?? "").slice(0, 40)}</option>
                      ))}
                    </select>
                  </label>
                  <Txt rotulo="Descrição" valor={f.sem_prod} onChange={(x) => set(v.id, "sem_prod", x)} dica="Ex.: na oficina trocando embreagem" />
                </Caixa>
              ) : null}
              {sit === "servico" ? (
                <Txt obrig rotulo="Qual serviço fez sem produção?" valor={f.sem_prod} onChange={(x) => set(v.id, "sem_prod", x)} dica="Ex.: deslocamento, apoio em obra, locação, transporte interno" />
              ) : null}

              {sit === "" || sit === "servico" || sit === "manut" ? (
                <>
                  {sit === "" && (produz || v.tipo === "Pá carregadeira") ? (
                    <Txt rotulo={v.tipo === "Caminhão betoneira" ? "Motorista" : "Operador"} valor={f.motorista} onChange={(x) => set(v.id, "motorista", x)} dica={d.ultMotorista ? `Último: ${d.ultMotorista}` : undefined} />
                  ) : null}

                  {sit === "" ? (
                    AUTOVOL.has(v.tipo) ? (
                      <p className="rounded-xl bg-afundado px-3 py-2 text-sm">
                        Produção da usina desde o último abastecimento: <b>{n(d.acum.m3 + (usinaM3n ?? 0), 1)} m³</b> (automático)
                      </p>
                    ) : (
                      <div className="grid grid-cols-2 gap-3">
                        {produz ? <Num rotulo={bomba ? "Bombeamentos" : "Viagens"} valor={f.viagens} onChange={(x) => set(v.id, "viagens", x)} inteiro /> : <div />}
                        <Num rotulo={produz ? (bomba ? "m³ bombeados" : "m³ entregues") : "m³ carregados"} valor={f.m3} onChange={(x) => set(v.id, "m3", x)} />
                      </div>
                    )
                  ) : null}

                  {v.betobomba && sit === "" ? (
                    <Caixa titulo="Betobomba acoplada · preencha se bombeou">
                      <div className="grid grid-cols-2 gap-3">
                        <Num rotulo="Bombeamentos" valor={f.vb} onChange={(x) => set(v.id, "vb", x)} inteiro />
                        <Num rotulo="m³ bombeados" valor={f.m3b} onChange={(x) => set(v.id, "m3b", x)} />
                        <Num rotulo="Horím. betobomba anterior" valor={hb0} onChange={(x) => set(v.id, "hb0", x)} />
                        <Num obrig={(l.m3b ?? 0) > 0 || (l.vb ?? 0) > 0} rotulo="Horím. betobomba atual" valor={f.hb1} onChange={(x) => set(v.id, "hb1", x)} />
                      </div>
                    </Caixa>
                  ) : null}

                  {bomba && sit !== "manut" ? (
                    <Caixa titulo="Leituras do dia · obrigatórias quando a bomba trabalhar">
                      <div className="grid grid-cols-2 gap-3">
                        <Num rotulo="Km caminhão anterior" valor={km0} onChange={(x) => set(v.id, "km0", x)} />
                        <Num obrig={ativoHoje} rotulo="Km caminhão atual" valor={f.km1} onChange={(x) => set(v.id, "km1", x)} />
                        <Num rotulo="Horím. caminhão anterior" valor={h0} onChange={(x) => set(v.id, "h0", x)} />
                        <Num obrig={ativoHoje} rotulo="Horím. caminhão atual" valor={f.h1} onChange={(x) => set(v.id, "h1", x)} />
                        <Num rotulo="Horím. bomba anterior" valor={hb0} onChange={(x) => set(v.id, "hb0", x)} />
                        <Num obrig={ativoHoje} rotulo="Horím. bomba atual" valor={f.hb1} onChange={(x) => set(v.id, "hb1", x)} />
                      </div>
                    </Caixa>
                  ) : null}

                  {!bomba && (v.usa_km || v.usa_hora) ? (
                    <Caixa titulo={`Leituras do dia · ${abast ? "obrigatórias porque abasteceu" : "opcional se não abasteceu"}`}>
                      <div className="grid grid-cols-2 gap-3">
                        {v.usa_km ? (
                          <>
                            <Num rotulo="Km anterior" valor={km0} onChange={(x) => set(v.id, "km0", x)} />
                            <Num obrig={abast} rotulo="Km atual" valor={f.km1} onChange={(x) => set(v.id, "km1", x)} />
                          </>
                        ) : null}
                        {v.usa_hora ? (
                          <>
                            <Num rotulo="Horímetro anterior" valor={h0} onChange={(x) => set(v.id, "h0", x)} />
                            <Num obrig={abast} rotulo="Horímetro atual" valor={f.h1} onChange={(x) => set(v.id, "h1", x)} />
                          </>
                        ) : null}
                      </div>
                    </Caixa>
                  ) : null}

                  <Caixa titulo="Abastecimento · preencha se abasteceu hoje">
                    <div className="grid grid-cols-2 gap-3">
                      <Num rotulo="Litros abastecidos" valor={f.litros} onChange={(x) => set(v.id, "litros", x)} />
                      <Num obrig={abast} rotulo="Preço por litro (R$/L)" valor={f.preco} onChange={(x) => set(v.id, "preco", x)} />
                    </div>
                    {abast && (l.preco ?? 0) > 0 ? (
                      <p className="rounded-xl bg-afundado px-3 py-2 text-sm">Valor total do cupom: <b>{brl(val)}</b> · confira com o cupom</p>
                    ) : null}
                    <Txt rotulo="Posto" valor={f.posto} onChange={(x) => set(v.id, "posto", x)} dica={p.postoPadrao ? `Padrão: ${p.postoPadrao}` : undefined} />
                    {abast && ev ? (
                      <div className="flex flex-wrap gap-x-4 gap-y-1 rounded-xl bg-afundado px-3 py-2 text-sm">
                        <span>m³ desde o último abastec.: <b>{n(A.m3, 1)}</b></span>
                        <span className={ev.overT ? "font-bold text-erro" : ""}>L/m³{bomba || v.betobomba ? " total" : ""}: <b>{n(ev.lm3, 2)}</b></span>
                        {v.betobomba ? (
                          <>
                            <span className={ev.overI ? "font-bold text-erro" : ""}>L/m³ betobomba: <b>{n(ev.lm3i, 2)}</b></span>
                            <span>m³ bombeados: <b>{n(A.m3b, 1)}</b></span>
                          </>
                        ) : null}
                        {bomba ? (
                          <>
                            <span className={ev.overI ? "font-bold text-erro" : ""}>L/m³ implemento: <b>{n(ev.lm3i, 2)}</b></span>
                            <span>horas caminhão: <b>{n(A.hr, 1)}</b></span>
                            <span>horas bomba: <b>{n(A.hb, 1)}</b></span>
                          </>
                        ) : null}
                        <span>R$/m³: <b>{val && A.m3 > 0 ? n(val / A.m3, 2) : "—"}</b></span>
                        <span>R$/L: <b>{val && l.litros ? n(val / l.litros, 3) : "—"}</b></span>
                        {!bomba && kmr != null ? <span>km rodado: <b>{n(kmr)}</b></span> : null}
                        {!bomba && kmr != null ? <span>km/L: <b>{l.litros ? n(kmr / l.litros, 2) : "—"}</b></span> : null}
                        {!bomba && hr != null ? <span>horas: <b>{n(hr, 1)}</b></span> : null}
                        {!bomba && hr != null ? <span>L/h: <b>{hr > 0 && l.litros ? n(l.litros / hr, 2) : "—"}</b></span> : null}
                      </div>
                    ) : null}
                    {over && ev ? (
                      <div className="flex flex-col gap-2 rounded-xl border border-erro/40 bg-erro-fundo p-3">
                        <p className="text-sm font-semibold text-erro">
                          Acima do limite:{" "}
                          {[ev.overT ? `consumo total de ${n(ev.lm3, 2)} L/m³ (limite ${n(ev.lim, 1)})` : "", ev.overI ? `implemento com ${n(ev.lm3i, 2)} L/m³ (limite ${n(ev.limI, 1)})` : ""].filter(Boolean).join(" e ")}.
                          Explique o motivo para poder fechar o dia.
                        </p>
                        <textarea
                          value={f.justificativa}
                          onChange={(e) => set(v.id, "justificativa", e.target.value)}
                          placeholder="Ex.: obra distante, retorno sem carga, espera longa na obra…"
                          className="min-h-24 w-full rounded-xl border border-linha bg-fundo p-3 text-base"
                        />
                      </div>
                    ) : null}
                  </Caixa>
                </>
              ) : null}

              <Txt rotulo="Observações" valor={f.obs} onChange={(x) => set(v.id, "obs", x)} />
            </section>
          );
        })}
      </div>

      {erros.length ? (
        <Aviso tipo="erro">
          <b>Corrija antes de salvar:</b>
          <ul className="mt-1 list-disc pl-5">{erros.map((e, i) => <li key={i}>{e}</li>)}</ul>
        </Aviso>
      ) : null}
      {aviso ? <Aviso tipo="ok">{aviso}</Aviso> : null}

      {/* barra de salvar */}
      <div className="fixed inset-x-0 bottom-0 z-10 border-t border-linha bg-superficie/95 px-4 py-3 pb-[max(.75rem,env(safe-area-inset-bottom))] backdrop-blur">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center gap-2">
          <span className="mr-auto text-sm text-suave">
            {lancados} de {p.veiculos.length} veículos lançados
            {pend ? <b className="text-erro"> · {pend} justificativa(s) pendente(s)</b> : null}
            {pendLeit ? <b className="text-erro"> · {pendLeit} bomba(s) sem leituras</b> : null}
          </span>
          {!existe && !dirty && !bloqueado ? (
            <Botao variante="secundario" disabled={salvando} onClick={() => gravar("sem_producao")}>Dia sem produção</Botao>
          ) : null}
          <Botao variante="secundario" disabled={salvando || !dirty} onClick={() => gravar("parcial")}>Salvar parcial</Botao>
          <Botao disabled={salvando || bloqueado || !(dirty || importado || p.boletim?.status === "aberto")} onClick={() => gravar("fechar")}>
            {salvando ? "Salvando…" : `Fechar o dia ${dataBr(p.data).slice(0, 5)}`}
          </Botao>
        </div>
      </div>
    </div>
  );
}

function mesesDesde(ini: string, ate: string) {
  const a = new Date(ini + "T12:00:00Z"), b = new Date(ate + "T12:00:00Z");
  let m = (b.getUTCFullYear() - a.getUTCFullYear()) * 12 + (b.getUTCMonth() - a.getUTCMonth());
  if (b.getUTCDate() < a.getUTCDate()) m--;
  return Math.max(0, m);
}

function Caixa({ titulo, children }: { titulo: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-3 rounded-xl border border-linha bg-afundado/60 p-3">
      <p className="text-xs font-bold uppercase tracking-wider text-suave">{titulo}</p>
      {children}
    </div>
  );
}

function Num({ rotulo, valor, onChange, obrig, inteiro }: { rotulo: string; valor: string; onChange: (v: string) => void; obrig?: boolean; inteiro?: boolean }) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-sm font-semibold text-suave">{rotulo}{obrig ? <b className="text-erro"> *</b> : null}</span>
      <Entrada inputMode={inteiro ? "numeric" : "decimal"} value={valor} onChange={(e) => onChange(e.target.value)} />
    </label>
  );
}

function Txt({ rotulo, valor, onChange, obrig, dica }: { rotulo: string; valor: string; onChange: (v: string) => void; obrig?: boolean; dica?: string }) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-sm font-semibold text-suave">{rotulo}{obrig ? <b className="text-erro"> *</b> : null}</span>
      <Entrada value={valor} onChange={(e) => onChange(e.target.value)} placeholder={dica} />
    </label>
  );
}

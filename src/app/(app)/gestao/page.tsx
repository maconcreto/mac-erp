import Link from "next/link";
import { redirect } from "next/navigation";
import { AlertTriangle, ChevronLeft, ChevronRight, Info } from "lucide-react";
import { GraficoProducao } from "@/components/grafico-producao";
import { Painel } from "@/components/ui";
import { brl, n } from "@/lib/frota/consumo";
import { hojeBahia } from "@/lib/frota/dados";
import { resumoMes } from "@/lib/resumo";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { escolhaUsina } from "@/lib/usina-atual";

export const metadata = { title: "Painel de Gestão" };

const MESES = ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"];
const nomeMes = (ym: string) => `${MESES[Number(ym.slice(5, 7)) - 1]} de ${ym.slice(0, 4)}`;
function somarMes(ym: string, d: number) {
  const [a, m] = ym.split("-").map(Number);
  const t = a * 12 + (m - 1) + d;
  return `${Math.floor(t / 12)}-${String((t % 12) + 1).padStart(2, "0")}`;
}

export default async function PainelGestao({ searchParams }: { searchParams: Promise<{ mes?: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  if (!s.gestor) redirect("/");
  const sp = await searchParams;
  const mesHoje = hojeBahia().slice(0, 7);
  const ym = /^\d{4}-\d{2}$/.test(sp.mes ?? "") && sp.mes! <= mesHoje ? sp.mes! : mesHoje;

  const escolha = await escolhaUsina(s);
  const escopo = escolha ? (escolha.todas ? escolha.usinas : [escolha.usina]) : [];
  const supabase = await criarClienteServidor();
  const r = await resumoMes(supabase, escopo, ym);
  const anterior = MESES[Number(somarMes(ym, -1).slice(5, 7)) - 1];
  const emAndamento = ym === mesHoje;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-sm font-bold uppercase tracking-wider text-suave">{escolha?.todas ? `Todas as usinas · ${escopo.map((u) => u.codigo).join(", ")}` : escolha?.usina?.nome}</p>
          <h1 className="text-3xl font-extrabold">Painel de Gestão</h1>
        </div>
        <nav aria-label="Mês" className="flex items-center gap-1 rounded-2xl border border-linha bg-superficie p-1">
          <Link href={`/gestao?mes=${somarMes(ym, -1)}`} aria-label="Mês anterior" className="flex size-11 items-center justify-center rounded-xl hover:bg-afundado">
            <ChevronLeft className="size-5" />
          </Link>
          <span className="min-w-40 text-center font-semibold capitalize">{nomeMes(ym)}</span>
          {emAndamento ? (
            <span className="flex size-11 items-center justify-center text-linha" aria-hidden>
              <ChevronRight className="size-5" />
            </span>
          ) : (
            <Link href={`/gestao?mes=${somarMes(ym, 1)}`} aria-label="Próximo mês" className="flex size-11 items-center justify-center rounded-xl hover:bg-afundado">
              <ChevronRight className="size-5" />
            </Link>
          )}
        </nav>
      </div>

      {/* ---------- indicadores ---------- */}
      <section className="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-linha bg-linha lg:grid-cols-4" aria-label="Indicadores do mês">
        <Indicador titulo="Concreto produzido" valor={`${n(r.m3, 1)} m³`} nota={`${anterior}: ${n(r.m3Anterior, 1)} m³`} />
        <Indicador titulo="Diesel" valor={`${n(r.litros)} L`} nota={brl(r.diesel)} />
        <Indicador
          titulo="Diesel por m³"
          valor={r.lm3 == null ? "—" : `${n(r.lm3, 2)} L/m³`}
          nota={`${anterior}: ${r.lm3Anterior == null ? "—" : `${n(r.lm3Anterior, 2)} L/m³`}`}
          alerta={r.lm3 != null && r.lm3Anterior != null && r.lm3 > r.lm3Anterior * 1.1}
        />
        <Indicador titulo="Manutenção" valor={brl(r.manutencao)} nota={`${r.osConcluidas} OS concluídas · ${anterior}: ${brl(r.manutencaoAnterior)}`} />
      </section>
      {emAndamento ? <p className="-mt-4 text-sm text-suave">Mês em andamento: os números do mês anterior são do mês inteiro.</p> : null}

      {/* ---------- produção diária ---------- */}
      <Painel titulo="Concreto produzido por dia">
        {r.m3 > 0 ? <GraficoProducao dias={r.dias} /> : <p className="text-base text-suave">Nenhuma produção lançada neste mês.</p>}
      </Painel>

      <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_320px]">
        {/* ---------- consumo por veículo ---------- */}
        <Painel titulo="Diesel por veículo">
          {r.veiculos.length ? (
            <div className="-mx-5 overflow-x-auto px-5">
              <table className="w-full min-w-[520px] text-left text-base">
                <thead>
                  <tr className="border-b border-linha text-xs uppercase tracking-wider text-suave">
                    <th className="py-2 pr-3 font-semibold">Veículo</th>
                    <th className="py-2 pr-3 text-right font-semibold">Litros</th>
                    <th className="py-2 pr-3 text-right font-semibold">m³</th>
                    <th className="py-2 pr-3 text-right font-semibold">L/m³</th>
                    <th className="py-2 text-right font-semibold">Diesel</th>
                  </tr>
                </thead>
                <tbody className="tabular-nums">
                  {r.veiculos.map((v) => (
                    <tr key={v.codigo} className="border-b border-linha/70 last:border-0">
                      <td className="py-2.5 pr-3">
                        <b>{v.codigo}</b>
                        <span className="block text-sm text-suave">{v.tipo}</span>
                      </td>
                      <td className="py-2.5 pr-3 text-right">{n(v.litros)}</td>
                      <td className="py-2.5 pr-3 text-right">{v.m3 ? n(v.m3, 1) : "—"}</td>
                      <td className="py-2.5 pr-3 text-right">{v.lm3 == null ? "—" : n(v.lm3, 2)}</td>
                      <td className="py-2.5 text-right">{brl(v.diesel)}</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="tabular-nums">
                  <tr className="border-t-2 border-linha font-semibold">
                    <td className="py-2.5 pr-3">Total</td>
                    <td className="py-2.5 pr-3 text-right">{n(r.litros)}</td>
                    <td className="py-2.5 pr-3 text-right"></td>
                    <td className="py-2.5 pr-3 text-right"></td>
                    <td className="py-2.5 text-right">{brl(r.diesel)}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          ) : (
            <p className="text-base text-suave">Nenhum abastecimento lançado neste mês.</p>
          )}
        </Painel>

        <div className="flex flex-col gap-6">
          {/* ---------- manutenção ---------- */}
          <Painel titulo="Ordens de serviço">
            <dl className="grid grid-cols-3 gap-2 text-center">
              {[
                ["Em aberto", r.osAbertas],
                ["Aguard. peça", r.aguardandoPeca],
                ["Concluídas", r.osConcluidas],
              ].map(([k, v]) => (
                <div key={k} className="rounded-xl bg-afundado px-2 py-3">
                  <dd className="font-display text-2xl font-extrabold tabular-nums">{v}</dd>
                  <dt className="text-xs font-semibold text-suave">{k}</dt>
                </div>
              ))}
            </dl>
            <Link href="/tarefa/os" className="flex min-h-12 items-center justify-center rounded-xl border border-linha font-semibold hover:border-suave">
              Ver ordens de serviço
            </Link>
          </Painel>

          {/* ---------- por usina ---------- */}
          {escopo.length > 1 ? (
            <Painel titulo="Por usina">
              <table className="w-full text-left text-base tabular-nums">
                <thead>
                  <tr className="border-b border-linha text-xs uppercase tracking-wider text-suave">
                    <th className="py-2 pr-2 font-semibold">Usina</th>
                    <th className="py-2 pr-2 text-right font-semibold">m³</th>
                    <th className="py-2 text-right font-semibold">Manut.</th>
                  </tr>
                </thead>
                <tbody>
                  {r.porUsina.map((u) => (
                    <tr key={u.codigo} className="border-b border-linha/70 last:border-0">
                      <td className="py-2 pr-2 font-display font-bold">{u.codigo}</td>
                      <td className="py-2 pr-2 text-right">{n(u.m3, 1)}</td>
                      <td className="py-2 text-right">{brl(u.manutencao)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </Painel>
          ) : null}
        </div>
      </div>

      {/* ---------- como é calculado (para treinar a equipe) ---------- */}
      <details className="group rounded-2xl border border-linha bg-superficie">
        <summary className="flex min-h-14 cursor-pointer list-none items-center gap-3 px-5 font-semibold [&::-webkit-details-marker]:hidden">
          <Info className="size-5 text-suave" /> Como estes números são calculados
        </summary>
        <ul className="flex list-disc flex-col gap-2 border-t border-linha px-10 py-4 text-base">
          <li><b>Concreto produzido:</b> soma do m³ da central em cada boletim do mês.</li>
          <li><b>Diesel:</b> soma dos litros e valores abastecidos em todos os veículos no boletim.</li>
          <li><b>Diesel por m³:</b> litros do mês divididos pelo concreto produzido. Fica em destaque se passar 10% do mês anterior.</li>
          <li><b>Diesel por veículo, L/m³:</b> litros do veículo divididos pelos m³ que ele transportou ou bombeou.</li>
          <li><b>Manutenção:</b> mão de obra mais compras de material das OS concluídas no mês (pela data de término).</li>
        </ul>
      </details>
    </div>
  );
}

function Indicador({ titulo, valor, nota, alerta = false }: { titulo: string; valor: string; nota: string; alerta?: boolean }) {
  return (
    <div className="flex min-w-0 flex-col gap-1 bg-superficie p-4">
      <span className="text-xs font-bold uppercase tracking-wider text-suave">{titulo}</span>
      <span className={`font-display text-2xl font-extrabold tabular-nums sm:text-3xl ${alerta ? "text-erro" : ""}`}>{valor}</span>
      {alerta ? (
        <span className="flex items-center gap-1 text-sm font-semibold text-erro">
          <AlertTriangle className="size-4" aria-hidden /> Mais de 10% acima do mês anterior
        </span>
      ) : null}
      <span className="text-sm text-suave first-letter:uppercase">{nota}</span>
    </div>
  );
}

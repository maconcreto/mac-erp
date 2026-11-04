"use client";

import { useState } from "react";

type Dia = { data: string; m3: number };
const fmt = (v: number) => v.toLocaleString("pt-BR", { maximumFractionDigits: 1 });
const DIAS_SEMANA = ["dom", "seg", "ter", "qua", "qui", "sex", "sáb"];

/** Concreto produzido por dia no mês. Uma série: barras finas, arredondadas no topo, toque/hover mostra o dia. */
export function GraficoProducao({ dias }: { dias: Dia[] }) {
  const [foco, setFoco] = useState<number | null>(null);
  const W = 720, H = 200, esq = 44, dir = 8, topo = 16, base = 28;
  const max = Math.max(1, ...dias.map((d) => d.m3));
  const passo = niceStep(max / 4);
  const teto = Math.ceil(max / passo) * passo;
  const ticks = Array.from({ length: Math.round(teto / passo) + 1 }, (_, i) => i * passo);
  const larguraUtil = W - esq - dir;
  const coluna = larguraUtil / Math.max(dias.length, 1);
  const barra = Math.max(3, Math.min(18, coluna * 0.62));
  const y = (v: number) => topo + (H - topo - base) * (1 - v / teto);
  const media = dias.filter((d) => d.m3 > 0);
  const mediaDia = media.length ? media.reduce((t, d) => t + d.m3, 0) / media.length : 0;
  const f = foco != null ? dias[foco] : null;

  return (
    <div className="relative">
      <svg viewBox={`0 0 ${W} ${H}`} role="img" aria-label="Concreto produzido por dia no mês" className="block h-auto w-full" onMouseLeave={() => setFoco(null)}>
        {ticks.map((t) => (
          <g key={t}>
            <line x1={esq} x2={W - dir} y1={y(t)} y2={y(t)} stroke="var(--linha)" strokeWidth={t === 0 ? 1.25 : 1} />
            <text x={esq - 8} y={y(t) + 4} textAnchor="end" fontSize="11" fill="var(--suave)" style={{ fontVariantNumeric: "tabular-nums" }}>
              {fmt(t)}
            </text>
          </g>
        ))}
        {mediaDia > 0 ? (
          <g>
            <line x1={esq} x2={W - dir} y1={y(mediaDia)} y2={y(mediaDia)} stroke="var(--suave)" strokeDasharray="4 4" strokeWidth="1" />
            <text x={W - dir} y={y(mediaDia) - 5} textAnchor="end" fontSize="11" fill="var(--suave)">
              média {fmt(mediaDia)} m³/dia
            </text>
          </g>
        ) : null}
        {dias.map((d, i) => {
          const cx = esq + coluna * i + coluna / 2;
          const h = H - base - y(d.m3);
          const dia = Number(d.data.slice(8));
          const semana = new Date(d.data + "T12:00:00Z").getUTCDay();
          const mostrarRotulo = dias.length <= 16 || dia === 1 || semana === 1;
          return (
            <g key={d.data}>
              {h > 0 ? (
                <path
                  d={barraArredondada(cx - barra / 2, y(d.m3), barra, h, Math.min(4, barra / 2, h))}
                  fill="var(--destaque)"
                  opacity={foco == null || foco === i ? 1 : 0.45}
                />
              ) : null}
              {mostrarRotulo ? (
                <text x={cx} y={H - base + 16} textAnchor="middle" fontSize="11" fill={semana === 0 ? "var(--erro)" : "var(--suave)"}>
                  {dia}
                </text>
              ) : null}
              {/* área de toque maior que a barra */}
              <rect
                x={esq + coluna * i}
                y={topo}
                width={coluna}
                height={H - topo - base}
                fill="transparent"
                onMouseEnter={() => setFoco(i)}
                onClick={() => setFoco(foco === i ? null : i)}
              >
                <title>{`${d.data.split("-").reverse().join("/")}: ${fmt(d.m3)} m³`}</title>
              </rect>
            </g>
          );
        })}
      </svg>
      {f ? (
        <div
          className="pointer-events-none absolute top-0 rounded-lg border border-linha bg-superficie px-3 py-2 text-sm shadow-lg"
          style={{ left: `clamp(0px, calc(${(((esq + coluna * (foco ?? 0) + coluna / 2) / W) * 100).toFixed(2)}% - 70px), calc(100% - 140px))`, width: 140 }}
        >
          <span className="block text-suave">
            {DIAS_SEMANA[new Date(f.data + "T12:00:00Z").getUTCDay()]}, {f.data.split("-").reverse().slice(0, 2).join("/")}
          </span>
          <b className="font-display text-lg tabular-nums">{fmt(f.m3)} m³</b>
        </div>
      ) : null}
    </div>
  );
}

function niceStep(v: number) {
  const p = Math.pow(10, Math.floor(Math.log10(Math.max(v, 1))));
  const n = v / p;
  return (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * p;
}

function barraArredondada(x: number, y: number, w: number, h: number, r: number) {
  return `M${x},${y + h} V${y + r} Q${x},${y} ${x + r},${y} H${x + w - r} Q${x + w},${y} ${x + w},${y + r} V${y + h} Z`;
}

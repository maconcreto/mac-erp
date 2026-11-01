import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";

/* Design system mínimo. Regra do Modo Campo: alvo de toque ≥ 48 px, texto ≥ 16 px. */

const base =
  "inline-flex items-center justify-center gap-2 rounded-xl font-semibold transition active:scale-[.98] disabled:opacity-50 disabled:pointer-events-none";
const variantes = {
  primario: "bg-marca text-marca-preto border border-marca-preto/80 hover:brightness-105",
  secundario: "bg-superficie text-tinta border border-linha hover:border-suave",
  perigo: "bg-superficie text-erro border border-linha hover:border-erro",
};
const tamanhos = {
  md: "min-h-12 px-5 text-base",
  lg: "min-h-14 px-6 text-lg w-full",
};

type Var = keyof typeof variantes;
type Tam = keyof typeof tamanhos;

export function Botao({
  variante = "primario",
  tamanho = "md",
  className = "",
  ...p
}: ComponentProps<"button"> & { variante?: Var; tamanho?: Tam }) {
  return <button className={`${base} ${variantes[variante]} ${tamanhos[tamanho]} ${className}`} {...p} />;
}

export function BotaoLink({
  variante = "primario",
  tamanho = "md",
  className = "",
  ...p
}: ComponentProps<typeof Link> & { variante?: Var; tamanho?: Tam }) {
  return <Link className={`${base} ${variantes[variante]} ${tamanhos[tamanho]} ${className}`} {...p} />;
}

export function Campo({ rotulo, dica, children }: { rotulo: string; dica?: string; children: ReactNode }) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-sm font-semibold text-suave">{rotulo}</span>
      {children}
      {dica ? <span className="text-sm text-suave">{dica}</span> : null}
    </label>
  );
}

export const estiloEntrada =
  "min-h-12 w-full rounded-xl border border-linha bg-fundo px-4 text-base text-tinta placeholder:text-suave/70 focus:border-destaque focus:outline-2 focus:outline-destaque";

export function Entrada(p: ComponentProps<"input">) {
  return <input {...p} className={`${estiloEntrada} ${p.className ?? ""}`} />;
}

export function Selecao(p: ComponentProps<"select">) {
  return <select {...p} className={`${estiloEntrada} ${p.className ?? ""}`} />;
}

export function Painel({ titulo, acao, children, className = "" }: { titulo?: string; acao?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={`flex flex-col gap-4 rounded-2xl border border-linha bg-superficie p-5 ${className}`}>
      {titulo || acao ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          {titulo ? <h2 className="text-lg font-bold">{titulo}</h2> : <span />}
          {acao}
        </div>
      ) : null}
      {children}
    </section>
  );
}

export function Aviso({ tipo = "alerta", children }: { tipo?: "ok" | "alerta" | "erro"; children: ReactNode }) {
  const cores = {
    ok: "bg-ok-fundo text-ok border-ok/30",
    alerta: "bg-alerta-fundo text-alerta border-alerta/30",
    erro: "bg-erro-fundo text-erro border-erro/30",
  };
  return <div role="status" className={`rounded-xl border px-4 py-3 text-base font-medium ${cores[tipo]}`}>{children}</div>;
}

export function Etiqueta({ children, tom = "neutro" }: { children: ReactNode; tom?: "neutro" | "ok" | "marca" }) {
  const cores = {
    neutro: "bg-afundado text-suave",
    ok: "bg-ok-fundo text-ok",
    marca: "bg-destaque-fundo text-destaque",
  };
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${cores[tom]}`}>{children}</span>;
}

export function Logo({ compacto = false }: { compacto?: boolean }) {
  return (
    <span className="font-display grid uppercase leading-[.9] text-marca" aria-label="Marcos Andrade Concreto">
      <b className={compacto ? "text-base font-extrabold" : "text-xl font-extrabold"}>MarcosAndrade</b>
      <span className={`${compacto ? "text-[9px]" : "text-[11px]"} font-bold tracking-[.42em] text-[#f2f5ee]`}>Concreto</span>
    </span>
  );
}

"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { enviarRecuperacao, redefinirComCodigo, type EstadoEntrar } from "../acoes";

const inicial: EstadoEntrar = {};

export function FormEsqueci() {
  const [email, setEmail] = useState("");
  const [envio, acaoEnviar, enviando] = useActionState(enviarRecuperacao, inicial);
  const [troca, acaoTrocar, trocando] = useActionState(redefinirComCodigo, inicial);
  const etapaCodigo = envio.etapa === "codigo";

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-3xl font-extrabold">Recuperar senha</h1>

      {!etapaCodigo ? (
        <form action={acaoEnviar} className="flex flex-col gap-4">
          {envio.erro ? <Aviso tipo="erro">{envio.erro}</Aviso> : null}
          <Campo rotulo="Seu e-mail">
            <Entrada
              name="email"
              type="email"
              inputMode="email"
              autoComplete="username"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </Campo>
          <Botao tamanho="lg" type="submit" disabled={enviando}>
            {enviando ? "Enviando…" : "Receber código"}
          </Botao>
        </form>
      ) : (
        <form action={acaoTrocar} className="flex flex-col gap-4">
          {troca.erro ? <Aviso tipo="erro">{troca.erro}</Aviso> : <Aviso tipo="ok">{envio.ok}</Aviso>}
          <p className="text-base">Toque no link do e-mail ou digite o código aqui.</p>
          <input type="hidden" name="email" value={email} />
          <Campo rotulo="Código do e-mail">
            <Entrada
              name="codigo"
              inputMode="numeric"
              autoComplete="one-time-code"
              maxLength={10}
              className="text-center font-mono text-2xl tracking-[.4em]"
              required
            />
          </Campo>
          <Campo rotulo="Nova senha" dica="8 ou mais caracteres, com letras e números.">
            <Entrada name="senha" type="password" autoComplete="new-password" minLength={8} required />
          </Campo>
          <Botao tamanho="lg" type="submit" disabled={trocando}>
            {trocando ? "Salvando…" : "Salvar nova senha"}
          </Botao>
        </form>
      )}

      <Link href="/entrar" className="flex min-h-12 items-center justify-center text-base font-semibold text-destaque underline-offset-4 hover:underline">
        Voltar para entrar
      </Link>
    </div>
  );
}

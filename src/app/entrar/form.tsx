"use client";

import { useActionState, useState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { criarConta, entrar, type EstadoEntrar } from "./acoes";

const inicial: EstadoEntrar = {};

export function FormEntrar() {
  const [modo, setModo] = useState<"entrar" | "criar">("entrar");
  const [estadoEntrar, acaoEntrar, entrando] = useActionState(entrar, inicial);
  const [estadoCriar, acaoCriar, criando] = useActionState(criarConta, inicial);
  const estado = modo === "entrar" ? estadoEntrar : estadoCriar;

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-3xl font-extrabold">{modo === "entrar" ? "Entrar" : "Criar conta"}</h1>

      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}

      <form action={modo === "entrar" ? acaoEntrar : acaoCriar} className="flex flex-col gap-4">
        {modo === "criar" ? (
          <Campo rotulo="Seu nome">
            <Entrada name="nome" autoComplete="name" required />
          </Campo>
        ) : null}
        <Campo rotulo="E-mail">
          <Entrada name="email" type="email" inputMode="email" autoComplete="email" required />
        </Campo>
        <Campo rotulo="Senha">
          <Entrada
            name="senha"
            type="password"
            autoComplete={modo === "entrar" ? "current-password" : "new-password"}
            minLength={6}
            required
          />
        </Campo>
        <Botao tamanho="lg" type="submit" disabled={entrando || criando}>
          {entrando || criando ? "Aguarde…" : modo === "entrar" ? "Entrar" : "Criar conta"}
        </Botao>
      </form>

      <button
        type="button"
        onClick={() => setModo(modo === "entrar" ? "criar" : "entrar")}
        className="min-h-12 text-base font-semibold text-destaque underline-offset-4 hover:underline"
      >
        {modo === "entrar" ? "Primeiro acesso? Criar conta" : "Já tenho conta"}
      </button>
    </div>
  );
}

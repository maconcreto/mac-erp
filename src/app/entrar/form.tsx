"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { criarConta, entrar, type EstadoEntrar } from "./acoes";

const inicial: EstadoEntrar = {};

export function FormEntrar({ cadastroAberto }: { cadastroAberto: boolean }) {
  const [modo, setModo] = useState<"entrar" | "criar">("entrar");
  const [estadoEntrar, acaoEntrar, entrando] = useActionState(entrar, inicial);
  const [estadoCriar, acaoCriar, criando] = useActionState(criarConta, inicial);
  const estado = modo === "entrar" ? estadoEntrar : estadoCriar;
  const criar = cadastroAberto && modo === "criar";

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-3xl font-extrabold">{criar ? "Primeiro acesso" : "Entrar"}</h1>

      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}

      <form action={criar ? acaoCriar : acaoEntrar} className="flex flex-col gap-4">
        {criar ? (
          <Campo rotulo="Seu nome">
            <Entrada name="nome" autoComplete="name" required />
          </Campo>
        ) : null}
        <Campo rotulo="E-mail">
          <Entrada name="email" type="email" inputMode="email" autoComplete="username" required />
        </Campo>
        <Campo rotulo="Senha">
          <Entrada name="senha" type="password" autoComplete={criar ? "new-password" : "current-password"} required />
        </Campo>
        <Botao tamanho="lg" type="submit" disabled={entrando || criando}>
          {entrando || criando ? "Aguarde…" : criar ? "Criar conta" : "Entrar"}
        </Botao>
      </form>

      {!criar ? (
        <Link href="/entrar/esqueci" className="flex min-h-12 items-center justify-center text-base font-semibold text-destaque underline-offset-4 hover:underline">
          Esqueci minha senha
        </Link>
      ) : null}

      {cadastroAberto ? (
        <button
          type="button"
          onClick={() => setModo(modo === "entrar" ? "criar" : "entrar")}
          className="min-h-12 text-base font-semibold text-suave underline-offset-4 hover:underline"
        >
          {modo === "entrar" ? "Primeiro acesso do sistema? Criar conta" : "Já tenho conta"}
        </button>
      ) : (
        <p className="text-center text-sm text-suave">Não tem acesso? Peça ao seu gestor.</p>
      )}
    </div>
  );
}

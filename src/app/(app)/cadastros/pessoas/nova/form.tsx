"use client";

import { useActionState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { criarPessoa, type Resultado } from "../../acoes";
import { CampoSenha, CamposAcesso, type UsinaOpcao } from "../campos";

export function FormNovaPessoa({ usinas }: { usinas: UsinaOpcao[] }) {
  const [estado, acao, salvando] = useActionState(criarPessoa, {} as Resultado);

  return (
    <form action={acao} className="flex flex-col gap-6">
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}

      <Bloco numero={1} titulo="Dados da pessoa">
        <div className="grid gap-4 sm:grid-cols-2">
          <Campo rotulo="Nome completo">
            <Entrada name="nome" autoComplete="off" required />
          </Campo>
          <Campo rotulo="Cargo / função">
            <Entrada name="cargo" placeholder="Balanceiro, motorista…" />
          </Campo>
          <Campo rotulo="Telefone (WhatsApp)">
            <Entrada name="telefone" type="tel" inputMode="tel" placeholder="(77) 9 0000-0000" />
          </Campo>
          <Campo rotulo="Matrícula">
            <Entrada name="matricula" />
          </Campo>
        </div>
      </Bloco>

      <Bloco numero={2} titulo="Login">
        <div className="grid gap-4 sm:grid-cols-2">
          <Campo rotulo="E-mail de login" dica="É com ele que a pessoa entra e recebe os e-mails do sistema.">
            <Entrada name="email" type="email" inputMode="email" autoComplete="off" required />
          </Campo>
          <CampoSenha />
        </div>
      </Bloco>

      <Bloco numero={3} titulo="O que a pessoa vai usar">
        <CamposAcesso usinas={usinas} />
      </Bloco>

      <Botao type="submit" tamanho="lg" disabled={salvando} className="sm:w-auto sm:self-start">
        {salvando ? "Criando…" : "Criar usuário"}
      </Botao>
    </form>
  );
}

function Bloco({ numero, titulo, children }: { numero: number; titulo: string; children: React.ReactNode }) {
  return (
    <section className="flex flex-col gap-4 rounded-2xl border border-linha bg-superficie p-5">
      <h2 className="flex items-center gap-3 text-lg font-bold">
        <span className="flex size-8 items-center justify-center rounded-full bg-marca-preto font-display text-sm text-marca">{numero}</span>
        {titulo}
      </h2>
      {children}
    </section>
  );
}

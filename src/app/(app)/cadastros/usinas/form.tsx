"use client";

import { useActionState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { criarUsina, type Resultado } from "../acoes";

export function FormUsina() {
  const [estado, acao, salvando] = useActionState(criarUsina, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-[120px_1fr]">
        <Campo rotulo="Código">
          <Entrada name="codigo" placeholder="IOS" maxLength={6} autoCapitalize="characters" required />
        </Campo>
        <Campo rotulo="Nome">
          <Entrada name="nome" placeholder="Central Ilhéus" required />
        </Campo>
      </div>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-[1fr_120px]">
        <Campo rotulo="Cidade">
          <Entrada name="cidade" placeholder="Ilhéus" />
        </Campo>
        <Campo rotulo="UF">
          <Entrada name="uf" placeholder="BA" maxLength={2} autoCapitalize="characters" />
        </Campo>
      </div>
      <Botao type="submit" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Cadastrar usina"}
      </Botao>
    </form>
  );
}

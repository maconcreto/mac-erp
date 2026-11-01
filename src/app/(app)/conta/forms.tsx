"use client";

import { useActionState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import { salvarMeusDados, trocarMinhaSenha, type Resultado } from "./acoes";

export function FormMeusDados({ nome, telefone }: { nome: string; telefone: string }) {
  const [estado, acao, salvando] = useActionState(salvarMeusDados, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}
      <Campo rotulo="Nome">
        <Entrada name="nome" defaultValue={nome} autoComplete="name" required />
      </Campo>
      <Campo rotulo="Telefone (WhatsApp)">
        <Entrada name="telefone" type="tel" inputMode="tel" defaultValue={telefone} autoComplete="tel" />
      </Campo>
      <Botao type="submit" variante="secundario" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Salvar"}
      </Botao>
    </form>
  );
}

export function FormMinhaSenha() {
  const [estado, acao, salvando] = useActionState(trocarMinhaSenha, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}
      <Campo rotulo="Nova senha" dica="8 ou mais caracteres, com letras e números.">
        <Entrada name="senha" type="password" autoComplete="new-password" minLength={8} required />
      </Campo>
      <Campo rotulo="Repita a nova senha">
        <Entrada name="confirma" type="password" autoComplete="new-password" minLength={8} required />
      </Campo>
      <Botao type="submit" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Trocar senha"}
      </Botao>
    </form>
  );
}

"use client";

import { useActionState } from "react";
import { Aviso, Botao, Campo, Entrada } from "@/components/ui";
import type { Pessoa } from "@/lib/tipos";
import { definirSenha, liberarAcesso, salvarPessoa, type Resultado } from "../../acoes";
import { CampoSenha, CamposAcesso, type UsinaOpcao } from "../campos";

function Mensagens({ estado }: { estado: Resultado }) {
  return (
    <>
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}
    </>
  );
}

export function FormDados({ pessoa }: { pessoa: Pessoa }) {
  const [estado, acao, salvando] = useActionState(salvarPessoa, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      <Mensagens estado={estado} />
      <input type="hidden" name="id" value={pessoa.id} />
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Campo rotulo="Nome completo">
          <Entrada name="nome" defaultValue={pessoa.nome} required />
        </Campo>
        <Campo rotulo="Cargo / função">
          <Entrada name="cargo" defaultValue={pessoa.cargo ?? ""} />
        </Campo>
        <Campo rotulo="Telefone (WhatsApp)">
          <Entrada name="telefone" type="tel" inputMode="tel" defaultValue={pessoa.telefone ?? ""} />
        </Campo>
        <Campo rotulo="Matrícula">
          <Entrada name="matricula" defaultValue={pessoa.matricula ?? ""} />
        </Campo>
        <Campo rotulo="E-mail de login">
          <Entrada name="email" type="email" inputMode="email" defaultValue={pessoa.email ?? ""} required />
        </Campo>
      </div>
      <Botao type="submit" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Salvar dados"}
      </Botao>
    </form>
  );
}

export function FormSenha({ pessoaId }: { pessoaId: string }) {
  const [estado, acao, salvando] = useActionState(definirSenha, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      <Mensagens estado={estado} />
      <input type="hidden" name="id" value={pessoaId} />
      <CampoSenha rotulo="Nova senha" />
      <Botao type="submit" variante="secundario" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Definir nova senha"}
      </Botao>
    </form>
  );
}

export function FormNovoAcesso({ pessoaId, usinas }: { pessoaId: string; usinas: UsinaOpcao[] }) {
  const [estado, acao, salvando] = useActionState(liberarAcesso, {} as Resultado);
  return (
    <form action={acao} className="flex flex-col gap-4">
      <Mensagens estado={estado} />
      <input type="hidden" name="pessoa_id" value={pessoaId} />
      <CamposAcesso usinas={usinas} />
      <Botao type="submit" variante="secundario" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Adicionar acesso"}
      </Botao>
    </form>
  );
}

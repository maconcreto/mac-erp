"use client";

import { useActionState, useState } from "react";
import { Aviso, Botao, Campo, Selecao } from "@/components/ui";
import { NOME_PAPEL, NOME_SETOR, PAPEIS, SETORES, type Papel } from "@/lib/tipos";
import { liberarAcesso, type Resultado } from "../acoes";

// Setores sugeridos ao escolher o papel; o gestor pode ajustar.
const SUGESTAO: Partial<Record<Papel, string[]>> = {
  financeiro: ["financeiro"],
  administrativo: ["administrativo"],
  comercial: ["comercial"],
  gerente_usina: [...SETORES],
};

type Props = {
  pessoas: { id: string; nome: string }[];
  usinas: { id: string; codigo: string; nome: string }[];
  pessoaInicial?: string;
};

export function FormAcesso({ pessoas, usinas, pessoaInicial }: Props) {
  const [estado, acao, salvando] = useActionState(liberarAcesso, {} as Resultado);
  const [papel, setPapel] = useState<Papel>("lancador");
  const [setores, setSetores] = useState<string[]>([]);

  function trocarPapel(p: Papel) {
    setPapel(p);
    setSetores(SUGESTAO[p] ?? []);
  }

  return (
    <form action={acao} className="flex flex-col gap-4">
      {estado.erro ? <Aviso tipo="erro">{estado.erro}</Aviso> : null}
      {estado.ok ? <Aviso tipo="ok">{estado.ok}</Aviso> : null}

      <div className="grid gap-4 sm:grid-cols-3">
        <Campo rotulo="Pessoa">
          <Selecao name="pessoa_id" defaultValue={pessoaInicial ?? ""} required>
            <option value="" disabled>Escolha…</option>
            {pessoas.map((p) => <option key={p.id} value={p.id}>{p.nome}</option>)}
          </Selecao>
        </Campo>
        <Campo rotulo="Usina">
          <Selecao name="usina_id" defaultValue={usinas[0]?.id ?? "todas"}>
            {usinas.map((u) => <option key={u.id} value={u.id}>{u.codigo} · {u.nome}</option>)}
            <option value="todas">Todas as usinas</option>
          </Selecao>
        </Campo>
        <Campo rotulo="Papel">
          <Selecao name="papel" value={papel} onChange={(e) => trocarPapel(e.target.value as Papel)}>
            {PAPEIS.map((p) => <option key={p} value={p}>{NOME_PAPEL[p]}</option>)}
          </Selecao>
        </Campo>
      </div>

      {papel !== "diretoria" ? (
        <fieldset className="flex flex-col gap-2">
          <legend className="mb-2 text-sm font-semibold text-suave">Setores</legend>
          <div className="flex flex-wrap gap-2">
            {SETORES.map((s) => {
              const marcado = setores.includes(s);
              return (
                <label
                  key={s}
                  className={`flex min-h-12 cursor-pointer items-center gap-2 rounded-xl border px-4 text-base font-semibold ${
                    marcado ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie"
                  }`}
                >
                  <input
                    type="checkbox"
                    name="setores"
                    value={s}
                    checked={marcado}
                    onChange={() => setSetores(marcado ? setores.filter((x) => x !== s) : [...setores, s])}
                    className="sr-only"
                  />
                  {NOME_SETOR[s]}
                </label>
              );
            })}
          </div>
        </fieldset>
      ) : null}

      <Botao type="submit" disabled={salvando} className="self-start">
        {salvando ? "Salvando…" : "Liberar acesso"}
      </Botao>
    </form>
  );
}

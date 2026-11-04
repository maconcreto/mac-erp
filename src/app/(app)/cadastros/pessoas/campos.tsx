"use client";

import { useState } from "react";
import { Eye, EyeOff, RefreshCw } from "lucide-react";
import { Campo, Selecao, estiloEntrada } from "@/components/ui";
import { NOME_PAPEL, NOME_SETOR, PAPEIS, SETORES, type Papel } from "@/lib/tipos";

export type UsinaOpcao = { id: string; codigo: string; nome: string };

// Setores sugeridos ao escolher o papel; o gestor pode ajustar.
const SUGESTAO: Partial<Record<Papel, string[]>> = {
  financeiro: ["financeiro"],
  administrativo: ["administrativo"],
  comercial: ["comercial"],
  gerente_usina: [...SETORES],
};

/** Usina + papel + setores. Os setores viram botões grandes para marcar. */
export function CamposAcesso({ usinas }: { usinas: UsinaOpcao[] }) {
  const [papel, setPapel] = useState<Papel>("lancador");
  const [setores, setSetores] = useState<string[]>([]);

  return (
    <div className="flex flex-col gap-4">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Campo rotulo="Usina">
          <Selecao name="usina_id" defaultValue={usinas[0]?.id ?? "todas"}>
            {usinas.map((u) => (
              <option key={u.id} value={u.id}>
                {u.codigo} · {u.nome}
              </option>
            ))}
            <option value="todas">Todas as usinas</option>
          </Selecao>
        </Campo>
        <Campo rotulo="Papel">
          <Selecao
            name="papel"
            value={papel}
            onChange={(e) => {
              const p = e.target.value as Papel;
              setPapel(p);
              setSetores(SUGESTAO[p] ?? []);
            }}
          >
            {PAPEIS.map((p) => (
              <option key={p} value={p}>
                {NOME_PAPEL[p]}
              </option>
            ))}
          </Selecao>
        </Campo>
      </div>

      {papel !== "diretoria" ? (
        <fieldset className="flex flex-col gap-2">
          <legend className="mb-2 text-sm font-semibold text-suave">Setores que a pessoa lança</legend>
          <div className="flex flex-wrap gap-2">
            {SETORES.map((s) => {
              const marcado = setores.includes(s);
              return (
                <label
                  key={s}
                  className={`flex min-h-12 cursor-pointer items-center rounded-xl border px-4 text-base font-semibold transition ${
                    marcado ? "border-marca-preto bg-marca text-marca-preto" : "border-linha bg-superficie text-tinta"
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
    </div>
  );
}

const LETRAS = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz";
const NUMEROS = "23456789";

/** Senha fácil de ditar: 5 letras + 3 números, sem caracteres que confundem (0/O, 1/l). */
function gerarSenha() {
  const r = new Uint32Array(8);
  crypto.getRandomValues(r);
  const a = Array.from(r.slice(0, 5), (n) => LETRAS[n % LETRAS.length]).join("");
  const b = Array.from(r.slice(5), (n) => NUMEROS[n % NUMEROS.length]).join("");
  return a.charAt(0).toUpperCase() + a.slice(1) + b;
}

/** Campo de senha visível, com botão para gerar uma. A diretoria anota e entrega à pessoa. */
export function CampoSenha({ rotulo = "Senha" }: { rotulo?: string }) {
  const [valor, setValor] = useState("");
  const [visivel, setVisivel] = useState(true);
  return (
    <Campo rotulo={rotulo} dica="Mínimo 8 caracteres, com letras e números. A pessoa pode trocar depois.">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <input
            name="senha"
            type={visivel ? "text" : "password"}
            value={valor}
            onChange={(e) => setValor(e.target.value)}
            autoComplete="new-password"
            minLength={8}
            required
            className={`${estiloEntrada} pr-12 font-mono tracking-wider`}
          />
          <button
            type="button"
            onClick={() => setVisivel(!visivel)}
            aria-label={visivel ? "Ocultar senha" : "Mostrar senha"}
            className="absolute inset-y-0 right-0 flex w-12 items-center justify-center text-suave"
          >
            {visivel ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
          </button>
        </div>
        <button
          type="button"
          onClick={() => {
            setValor(gerarSenha());
            setVisivel(true);
          }}
          className="flex min-h-12 items-center gap-2 rounded-xl border border-linha bg-superficie px-4 font-semibold hover:border-suave"
        >
          <RefreshCw className="size-4" /> Gerar
        </button>
      </div>
    </Campo>
  );
}

import type { Metadata } from "next";
import { TelaMarca } from "@/components/tela-marca";
import { supabaseConfigurado } from "@/lib/supabase/config";
import { criarClienteServidor } from "@/lib/supabase/server";
import { FormEntrar } from "./form";

export const metadata: Metadata = { title: "Entrar" };

export default async function PaginaEntrar() {
  let cadastroAberto = false;
  if (supabaseConfigurado) {
    const supabase = await criarClienteServidor();
    const { data } = await supabase.rpc("cadastro_aberto");
    cadastroAberto = data === true;
  }

  return (
    <TelaMarca>
      {supabaseConfigurado ? (
        <FormEntrar cadastroAberto={cadastroAberto} />
      ) : (
        <p className="text-base">O banco de dados ainda não está ligado a este endereço.</p>
      )}
    </TelaMarca>
  );
}

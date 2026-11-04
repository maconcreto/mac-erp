import { redirect } from "next/navigation";
import { Aviso, Painel } from "@/components/ui";
import { ativosDaUsina } from "@/lib/frota/os-dados";
import { podeUsarOS } from "@/lib/frota/permissao";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { AssistenteOS } from "./form";

export const metadata = { title: "Abrir OS" };

export default async function NovaOS({ searchParams }: { searchParams: Promise<{ usina?: string; ativo?: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const sp = await searchParams;
  const usinas = s.usinas.filter((u) => u.ativa && podeUsarOS(s, u.id));
  if (!usinas.length) {
    return (
      <Painel titulo="Abrir OS">
        <Aviso>Você não tem acesso às OS de nenhuma usina.</Aviso>
      </Painel>
    );
  }
  const usina = usinas.find((u) => u.codigo === sp.usina) ?? usinas[0];
  const supabase = await criarClienteServidor();
  const ativos = await ativosDaUsina(supabase, usina.id);

  return (
    <AssistenteOS
      usina={{ id: usina.id, codigo: usina.codigo, nome: usina.nome }}
      ativos={ativos.map((a) => ({ id: a.id, codigo: a.codigo, tipo: a.tipo, grupo: a.grupo }))}
      ativoInicial={ativos.some((a) => a.id === sp.ativo) ? sp.ativo! : null}
    />
  );
}

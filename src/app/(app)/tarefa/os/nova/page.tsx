import { redirect } from "next/navigation";
import { Aviso, Painel } from "@/components/ui";
import { ativosDaUsina } from "@/lib/frota/os-dados";
import { podeUsarOS } from "@/lib/frota/permissao";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { usinaAtual } from "@/lib/usina-atual";
import { AssistenteOS } from "./form";

export const metadata = { title: "Abrir OS" };

export default async function NovaOS({ searchParams }: { searchParams: Promise<{ ativo?: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const sp = await searchParams;
  const usina = await usinaAtual(s);
  if (!usina || !podeUsarOS(s, usina.id)) {
    return (
      <Painel titulo="Abrir OS">
        <Aviso>{usina ? `Você não tem acesso às OS da ${usina.codigo}. Troque a usina no topo da tela.` : "Você não tem acesso às OS de nenhuma usina."}</Aviso>
      </Painel>
    );
  }
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

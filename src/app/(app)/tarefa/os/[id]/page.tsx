import { notFound, redirect } from "next/navigation";
import { ativosDaUsina, carregarOS, enderecosAnexos, leituraDe } from "@/lib/frota/os-dados";
import { gestorDaUsina, podeUsarOS } from "@/lib/frota/permissao";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { FichaOS } from "./ficha";

export const metadata = { title: "OS" };

export default async function PaginaOS({ params }: { params: Promise<{ id: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const { id } = await params;
  const supabase = await criarClienteServidor();
  const os = await carregarOS(supabase, id);
  if (!os || !podeUsarOS(s, os.usina_id)) notFound();

  const usina = s.usinas.find((u) => u.id === os.usina_id)!;
  const gestor = gestorDaUsina(s, os.usina_id);
  const [ativos, leitura, urls] = await Promise.all([
    ativosDaUsina(supabase, os.usina_id),
    leituraDe(supabase, os.ativo_id),
    enderecosAnexos(supabase, os),
  ]);
  const travada = !gestor && (os.origem === "importado" || os.status === "Concluída" || os.status === "Cancelada");

  return (
    <FichaOS
      key={os.atualizado_em}
      os={os}
      usina={{ id: usina.id, codigo: usina.codigo }}
      ativos={ativos}
      leitura={leitura}
      urls={urls}
      gestor={gestor}
      travada={travada}
    />
  );
}

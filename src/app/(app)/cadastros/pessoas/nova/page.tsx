import { redirect } from "next/navigation";
import { Aviso, BotaoLink } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { adminConfigurado } from "@/lib/supabase/admin";
import { FormNovaPessoa } from "./form";

export const metadata = { title: "Novo usuário" };

export default async function NovaPessoa() {
  const s = await carregarSessao();
  if (!s?.diretoria) redirect("/");

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-3xl font-extrabold">Novo usuário</h1>
        <BotaoLink href="/cadastros/pessoas" variante="secundario">Voltar</BotaoLink>
      </div>
      {!adminConfigurado ? (
        <Aviso tipo="alerta">
          Para criar usuários com senha, falta colocar a chave de serviço do Supabase na Vercel (variável SUPABASE_SERVICE_ROLE_KEY).
        </Aviso>
      ) : null}
      <FormNovaPessoa usinas={s.usinas.filter((u) => u.ativa).map((u) => ({ id: u.id, codigo: u.codigo, nome: u.nome }))} />
    </div>
  );
}

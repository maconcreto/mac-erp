import { redirect } from "next/navigation";
import { Aviso, Painel } from "@/components/ui";
import { carregarSessao } from "@/lib/sessao";
import { FormMeusDados, FormMinhaSenha } from "./forms";

export const metadata = { title: "Perfil" };

export default async function MinhaConta({ searchParams }: { searchParams: Promise<{ nova_senha?: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const { nova_senha } = await searchParams;

  return (
    <div className="mx-auto flex w-full max-w-xl flex-col gap-5">
      <div>
        <h1 className="text-3xl font-extrabold">Perfil</h1>
        <p className="text-base text-suave">{s.pessoa.email}</p>
      </div>
      {nova_senha ? <Aviso tipo="alerta">Defina agora sua nova senha.</Aviso> : null}
      <Painel titulo="Trocar senha">
        <FormMinhaSenha />
      </Painel>
      <Painel titulo="Meus dados">
        <FormMeusDados nome={s.pessoa.nome} telefone={s.pessoa.telefone ?? ""} />
      </Painel>
    </div>
  );
}

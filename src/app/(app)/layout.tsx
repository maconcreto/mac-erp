import { redirect } from "next/navigation";
import { Casca } from "@/components/casca";
import { SeletorUsina } from "@/components/seletor-usina";
import { montarMenu } from "@/lib/navegacao";
import { carregarSessao } from "@/lib/sessao";
import { supabaseConfigurado } from "@/lib/supabase/config";
import { NOME_PAPEL } from "@/lib/tipos";
import { escolhaUsina } from "@/lib/usina-atual";

export default async function LayoutApp({ children }: { children: React.ReactNode }) {
  if (!supabaseConfigurado) {
    return (
      <main className="mx-auto max-w-xl p-6 text-base">
        <h1 className="mb-3 text-2xl font-extrabold">Plataforma MAC</h1>
        <p>
          Falta ligar o banco: configure <code>NEXT_PUBLIC_SUPABASE_URL</code> e <code>NEXT_PUBLIC_SUPABASE_ANON_KEY</code> nas variáveis de ambiente
          da Vercel e publique de novo.
        </p>
      </main>
    );
  }

  const sessao = await carregarSessao();
  if (!sessao) redirect("/entrar");

  const escolha = await escolhaUsina(sessao);
  const ativas = (escolha?.usinas ?? []).map((u) => ({ codigo: u.codigo, nome: u.nome, cidade: u.cidade }));
  const papel = sessao.diretoria ? "Diretoria" : sessao.acessos[0] ? NOME_PAPEL[sessao.acessos[0].papel] : "Sem acesso";
  const nome = sessao.pessoa.nome.trim() || sessao.pessoa.email || "Usuário";

  return (
    <Casca
      menu={montarMenu(sessao)}
      pessoa={{ nome, papel, inicial: nome.charAt(0).toUpperCase() }}
      seletor={
        escolha ? (
          <SeletorUsina
            atual={escolha.usina ? { codigo: escolha.usina.codigo, nome: escolha.usina.nome, cidade: escolha.usina.cidade } : null}
            usinas={ativas}
          />
        ) : null
      }
    >
      {children}
    </Casca>
  );
}

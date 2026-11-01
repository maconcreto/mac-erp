import Link from "next/link";
import { redirect } from "next/navigation";
import { Aviso, Painel } from "@/components/ui";
import { diasPendentes, volumeAcumuladoUsina } from "@/lib/frota/consumo";
import { carregarDia, hojeBahia, somarDias } from "@/lib/frota/dados";
import { gestorDaUsina, podeLancarBoletim } from "@/lib/frota/permissao";
import { derivar, frotaDe, usinaDe } from "@/lib/frota/regras";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { FormBoletim } from "./form";

export const metadata = { title: "Boletim do dia" };

const ehData = (v?: string) => !!v && /^\d{4}-\d{2}-\d{2}$/.test(v);

export default async function PaginaBoletim({ searchParams }: { searchParams: Promise<{ usina?: string; data?: string }> }) {
  const s = await carregarSessao();
  if (!s) redirect("/entrar");
  const sp = await searchParams;

  const usinas = s.usinas.filter((u) => u.ativa && podeLancarBoletim(s, u.id));
  if (usinas.length === 0) {
    return (
      <Painel titulo="Boletim do dia">
        <Aviso>Você não tem acesso ao boletim de nenhuma usina. Peça à diretoria para liberar o setor Operação.</Aviso>
      </Painel>
    );
  }
  const usina = usinas.find((u) => u.codigo === sp.usina) ?? usinas[0];
  const gestor = gestorDaUsina(s, usina.id);
  const supabase = await criarClienteServidor();
  const hoje = hojeBahia();

  // Sem data na URL: quem não é gestor abre o primeiro dia que ficou para trás.
  let data = ehData(sp.data) && sp.data! <= hoje ? sp.data! : hoje;
  let dia = await carregarDia(supabase, usina.id, data);
  if (!ehData(sp.data) && !gestor) {
    const pend = diasPendentes(dia.inicio, hoje, new Set(dia.fechados));
    if (pend.length) {
      data = pend[0];
      dia = await carregarDia(supabase, usina.id, data);
    }
  }

  const pendentes = diasPendentes(dia.inicio, data, new Set(dia.fechados));
  const { ativos } = dia.contexto;
  const veiculos = frotaDe(ativos);
  const central = usinaDe(ativos);
  const por = derivar(dia.contexto);
  const derivados = Object.fromEntries([...por.entries()]);

  let volAcum: number | null = null;
  if (central) {
    const rs = [...(dia.contexto.historico.get(central.id) ?? [])];
    const hojeL = dia.linhas[central.id];
    if (hojeL?.m3 != null) rs.push({ data, origem: "lancado", linha: { m3: hojeL.m3 } });
    volAcum = volumeAcumuladoUsina(central, rs, data);
  }

  const proximo = somarDias(data, 1);
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <p className="text-sm font-bold uppercase tracking-wider text-suave">Boletim diário · {usina.nome}</p>
          <h1 className="text-3xl font-extrabold">Produção e abastecimento</h1>
        </div>
        {usinas.length > 1 ? (
          <nav className="flex gap-2">
            {usinas.map((u) => (
              <Link
                key={u.id}
                href={`/tarefa/boletim?usina=${u.codigo}&data=${data}`}
                className={`inline-flex min-h-12 items-center rounded-xl border px-4 font-semibold ${u.id === usina.id ? "border-marca-preto bg-marca" : "border-linha bg-superficie"}`}
              >
                {u.codigo}
              </Link>
            ))}
          </nav>
        ) : null}
      </div>

      {veiculos.length === 0 ? (
        <Aviso>Nenhum veículo cadastrado nesta usina.</Aviso>
      ) : (
        <FormBoletim
          key={`${usina.id}:${data}:${dia.boletim?.atualizado_em ?? "novo"}`}
          usina={{ id: usina.id, codigo: usina.codigo }}
          data={data}
          hoje={hoje}
          proximoLiberado={proximo <= hoje}
          gestor={gestor}
          veiculos={veiculos}
          central={central ?? null}
          derivados={derivados}
          linhas={dia.linhas}
          boletim={dia.boletim}
          lim={dia.contexto.lim}
          postoPadrao={dia.contexto.postoPadrao}
          pendentes={pendentes}
          abertos={dia.abertos.filter((d) => d !== data)}
          osAbertas={dia.osAbertas}
          volAcum={volAcum}
        />
      )}
    </div>
  );
}

"use server";

import { revalidatePath } from "next/cache";
import { carregarSessao } from "@/lib/sessao";
import { criarClienteServidor } from "@/lib/supabase/server";
import { PAPEIS, SETORES, type Papel, type Setor } from "@/lib/tipos";

export type Resultado = { erro?: string; ok?: string };

async function exigirDiretoria() {
  const s = await carregarSessao();
  if (!s?.diretoria) throw new Error("Somente a diretoria altera cadastros.");
  return s;
}

function mensagem(e: { message: string; code?: string } | null, padrao: string) {
  if (!e) return padrao;
  if (e.code === "23505") return "Já existe um cadastro com esse código.";
  if (e.code === "23514") return "Código inválido: use de 2 a 6 letras maiúsculas ou números (ex.: VDC).";
  return padrao;
}

export async function criarUsina(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  const codigo = String(dados.get("codigo") ?? "").trim().toUpperCase();
  const nome = String(dados.get("nome") ?? "").trim();
  const cidade = String(dados.get("cidade") ?? "").trim() || null;
  const uf = String(dados.get("uf") ?? "").trim().toUpperCase().slice(0, 2) || null;
  if (!codigo || !nome) return { erro: "Informe código e nome." };

  const supabase = await criarClienteServidor();
  const { data: empresa } = await supabase.rpc("minha_empresa");
  const { error } = await supabase.from("usina").insert({ empresa_id: empresa, codigo, nome, cidade, uf });
  if (error) return { erro: mensagem(error, "Não foi possível salvar a usina.") };
  revalidatePath("/", "layout");
  return { ok: `Usina ${codigo} cadastrada.` };
}

export async function alternarUsina(dados: FormData) {
  await exigirDiretoria();
  const id = String(dados.get("id"));
  const ativa = dados.get("ativa") === "true";
  const supabase = await criarClienteServidor();
  await supabase.from("usina").update({ ativa: !ativa }).eq("id", id);
  revalidatePath("/", "layout");
}

export async function liberarAcesso(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  const pessoa_id = String(dados.get("pessoa_id") ?? "");
  const usinaBruta = String(dados.get("usina_id") ?? "");
  const papel = String(dados.get("papel") ?? "") as Papel;
  const setores = dados.getAll("setores").map(String).filter((s): s is Setor => (SETORES as readonly string[]).includes(s));

  if (!pessoa_id) return { erro: "Escolha a pessoa." };
  if (!PAPEIS.includes(papel)) return { erro: "Escolha o papel." };
  const usina_id = usinaBruta === "todas" ? null : usinaBruta;
  if (!usina_id && !["diretoria", "financeiro"].includes(papel)) {
    return { erro: "Só diretoria e financeiro podem ter acesso a todas as usinas. Escolha uma usina." };
  }
  if (papel !== "diretoria" && setores.length === 0) return { erro: "Marque pelo menos um setor." };

  const supabase = await criarClienteServidor();
  const { error } = await supabase.from("pessoa_acesso").insert({ pessoa_id, usina_id, papel, setores });
  if (error) return { erro: error.code === "23505" ? "Essa pessoa já tem esse papel nessa usina." : "Não foi possível liberar o acesso." };
  revalidatePath("/cadastros/pessoas");
  return { ok: "Acesso liberado. A pessoa vê as tarefas ao abrir o app." };
}

export async function removerAcesso(dados: FormData) {
  await exigirDiretoria();
  const supabase = await criarClienteServidor();
  await supabase.from("pessoa_acesso").delete().eq("id", String(dados.get("id")));
  revalidatePath("/cadastros/pessoas");
}

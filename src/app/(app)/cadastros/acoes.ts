"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { carregarSessao } from "@/lib/sessao";
import { adminConfigurado, criarClienteAdmin } from "@/lib/supabase/admin";
import { criarClienteServidor } from "@/lib/supabase/server";
import { PAPEIS, SETORES, type Papel, type Setor } from "@/lib/tipos";

export type Resultado = { erro?: string; ok?: string };

const SEM_CHAVE = "Falta configurar a chave de serviço do Supabase na Vercel (SUPABASE_SERVICE_ROLE_KEY).";

async function exigirDiretoria() {
  const s = await carregarSessao();
  if (!s?.diretoria) throw new Error("Somente a diretoria altera cadastros.");
  return s;
}

function texto(dados: FormData, campo: string) {
  return String(dados.get(campo) ?? "").trim();
}

function mensagem(e: { message: string; code?: string } | null, padrao: string) {
  if (!e) return padrao;
  if (e.code === "23505") return "Já existe um cadastro com esse código.";
  if (e.code === "23514") return "Código inválido: use de 2 a 6 letras maiúsculas ou números (ex.: VDC).";
  return padrao;
}

function validarSenha(senha: string) {
  if (senha.length < 8) return "A senha precisa ter pelo menos 8 caracteres.";
  if (!/[A-Za-z]/.test(senha) || !/\d/.test(senha)) return "Use letras e números na senha.";
  return null;
}

function lerAcesso(dados: FormData): { erro?: string; acesso?: { usina_id: string | null; papel: Papel; setores: Setor[] } } {
  const usinaBruta = texto(dados, "usina_id");
  const papel = texto(dados, "papel") as Papel;
  const setores = dados.getAll("setores").map(String).filter((s): s is Setor => (SETORES as readonly string[]).includes(s));
  if (!PAPEIS.includes(papel)) return { erro: "Escolha o papel." };
  const usina_id = usinaBruta === "todas" || usinaBruta === "" ? null : usinaBruta;
  if (!usina_id && !["diretoria", "financeiro"].includes(papel)) {
    return { erro: "Só diretoria e financeiro podem ter acesso a todas as usinas. Escolha uma usina." };
  }
  if (papel !== "diretoria" && setores.length === 0) return { erro: "Marque pelo menos um setor." };
  return { acesso: { usina_id, papel, setores } };
}

/* ---------------- usinas ---------------- */

export async function criarUsina(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  const codigo = texto(dados, "codigo").toUpperCase();
  const nome = texto(dados, "nome");
  const cidade = texto(dados, "cidade") || null;
  const uf = texto(dados, "uf").toUpperCase().slice(0, 2) || null;
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
  const supabase = await criarClienteServidor();
  await supabase.from("usina").update({ ativa: dados.get("ativa") !== "true" }).eq("id", String(dados.get("id")));
  revalidatePath("/", "layout");
}

/* ---------------- pessoas ---------------- */

export async function criarPessoa(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  if (!adminConfigurado) return { erro: SEM_CHAVE };

  const nome = texto(dados, "nome");
  const email = texto(dados, "email").toLowerCase();
  const senha = String(dados.get("senha") ?? "");
  if (!nome) return { erro: "Informe o nome." };
  if (!/^\S+@\S+\.\S+$/.test(email)) return { erro: "Informe um e-mail válido." };
  const erroSenha = validarSenha(senha);
  if (erroSenha) return { erro: erroSenha };
  const { erro, acesso } = lerAcesso(dados);
  if (erro) return { erro };

  const admin = criarClienteAdmin();
  const { data, error } = await admin.auth.admin.createUser({
    email,
    password: senha,
    email_confirm: true, // a diretoria responde pelo e-mail; não precisa confirmar
    user_metadata: {
      nome,
      telefone: texto(dados, "telefone"),
      cargo: texto(dados, "cargo"),
      matricula: texto(dados, "matricula"),
    },
  });
  if (error || !data.user) {
    if (error && /already|registered|exists/i.test(error.message)) return { erro: "Já existe um usuário com este e-mail." };
    return { erro: "Não foi possível criar o usuário. Tente de novo." };
  }

  // O acesso é gravado com a sessão da diretoria: a regra do banco confere a permissão.
  const supabase = await criarClienteServidor();
  const { error: erroAcesso } = await supabase.from("pessoa_acesso").insert({ pessoa_id: data.user.id, ...acesso });
  revalidatePath("/cadastros/pessoas");
  redirect(`/cadastros/pessoas/${data.user.id}?${erroAcesso ? "sem_acesso=1" : "novo=1"}`);
}

export async function salvarPessoa(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  const id = texto(dados, "id");
  const nome = texto(dados, "nome");
  const email = texto(dados, "email").toLowerCase();
  if (!nome) return { erro: "Informe o nome." };
  if (!/^\S+@\S+\.\S+$/.test(email)) return { erro: "Informe um e-mail válido." };

  const supabase = await criarClienteServidor();
  const { data: atual } = await supabase.from("pessoa").select("email").eq("id", id).maybeSingle();

  if (atual && atual.email !== email) {
    if (!adminConfigurado) return { erro: SEM_CHAVE };
    const { error } = await criarClienteAdmin().auth.admin.updateUserById(id, { email, email_confirm: true });
    if (error) return { erro: /already|registered|exists/i.test(error.message) ? "Este e-mail já é de outro usuário." : "Não foi possível trocar o e-mail." };
  }

  const { error } = await supabase
    .from("pessoa")
    .update({
      nome,
      email,
      telefone: texto(dados, "telefone") || null,
      cargo: texto(dados, "cargo") || null,
      matricula: texto(dados, "matricula") || null,
    })
    .eq("id", id);
  if (error) return { erro: "Não foi possível salvar os dados." };
  revalidatePath(`/cadastros/pessoas/${id}`);
  revalidatePath("/cadastros/pessoas");
  return { ok: "Dados salvos." };
}

export async function definirSenha(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  if (!adminConfigurado) return { erro: SEM_CHAVE };
  const id = texto(dados, "id");
  const senha = String(dados.get("senha") ?? "");
  const erroSenha = validarSenha(senha);
  if (erroSenha) return { erro: erroSenha };
  const { error } = await criarClienteAdmin().auth.admin.updateUserById(id, { password: senha });
  if (error) return { erro: "Não foi possível trocar a senha." };
  return { ok: "Senha nova definida. Passe para a pessoa; ela pode trocar depois em Minha conta." };
}

export async function alternarPessoa(dados: FormData) {
  const s = await exigirDiretoria();
  const id = String(dados.get("id"));
  if (id === s.pessoa.id) return;
  const ativar = dados.get("ativo") !== "true";
  const supabase = await criarClienteServidor();
  await supabase.from("pessoa").update({ ativo: ativar }).eq("id", id);
  // Bloqueia (ou libera) o login, não só as telas.
  if (adminConfigurado) {
    await criarClienteAdmin().auth.admin.updateUserById(id, { ban_duration: ativar ? "none" : "876000h" });
  }
  revalidatePath(`/cadastros/pessoas/${id}`);
  revalidatePath("/cadastros/pessoas");
}

/* ---------------- acessos ---------------- */

export async function liberarAcesso(_: Resultado, dados: FormData): Promise<Resultado> {
  await exigirDiretoria();
  const pessoa_id = texto(dados, "pessoa_id");
  if (!pessoa_id) return { erro: "Escolha a pessoa." };
  const { erro, acesso } = lerAcesso(dados);
  if (erro) return { erro };

  const supabase = await criarClienteServidor();
  const { error } = await supabase.from("pessoa_acesso").insert({ pessoa_id, ...acesso });
  if (error) return { erro: error.code === "23505" ? "Essa pessoa já tem esse papel nessa usina." : "Não foi possível liberar o acesso." };
  revalidatePath(`/cadastros/pessoas/${pessoa_id}`);
  revalidatePath("/cadastros/pessoas");
  return { ok: "Acesso liberado. A pessoa vê as tarefas ao abrir o app." };
}

export async function removerAcesso(dados: FormData) {
  await exigirDiretoria();
  const supabase = await criarClienteServidor();
  await supabase.from("pessoa_acesso").delete().eq("id", String(dados.get("id")));
  revalidatePath(`/cadastros/pessoas/${String(dados.get("pessoa_id") ?? "")}`);
  revalidatePath("/cadastros/pessoas");
}

export const PAPEIS = ["diretoria", "gerente_usina", "financeiro", "administrativo", "comercial", "lancador"] as const;
export type Papel = (typeof PAPEIS)[number];

export const SETORES = ["operacao", "balanca", "laboratorio", "administrativo", "financeiro", "comercial"] as const;
export type Setor = (typeof SETORES)[number];

export const NOME_PAPEL: Record<Papel, string> = {
  diretoria: "Diretoria",
  gerente_usina: "Gerente de usina",
  financeiro: "Financeiro",
  administrativo: "Administrativo",
  comercial: "Comercial",
  lancador: "Lançador",
};

export const NOME_SETOR: Record<Setor, string> = {
  operacao: "Operação",
  balanca: "Balança",
  laboratorio: "Laboratório",
  administrativo: "Administrativo",
  financeiro: "Financeiro",
  comercial: "Comercial",
};

// Papéis que enxergam o Painel; os demais entram direto no Modo Campo.
export const PAPEIS_GESTAO: Papel[] = ["diretoria", "gerente_usina", "financeiro"];

export type Usina = {
  id: string;
  codigo: string;
  nome: string;
  cidade: string | null;
  uf: string | null;
  ativa: boolean;
};

export type Acesso = {
  id: string;
  usina_id: string | null;
  papel: Papel;
  setores: Setor[];
};

export type Pessoa = {
  id: string;
  nome: string;
  email: string | null;
  telefone: string | null;
  ativo: boolean;
};

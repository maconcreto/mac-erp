import type { Setor } from "./tipos";

export type Tarefa = {
  slug: string;
  setor: Setor;
  titulo: string; // curto: aparece no cartão grande do Modo Campo
  icone: IconeTarefa;
  fase: 1 | 2 | 3;
};

export type IconeTarefa =
  | "caminhao" | "checklist" | "chave" | "regua" | "gota" | "armazem" | "frasco" | "pacote"
  | "calendario" | "carteira" | "cartao" | "relogio" | "documento" | "mapa" | "obra" | "proposta";

// Ordem = ordem de exibição. A fase indica quando a tarefa ganha a tela definitiva.
export const TAREFAS: Tarefa[] = [
  { slug: "boletim", setor: "operacao", titulo: "Boletim do dia", icone: "caminhao", fase: 1 },
  { slug: "checklist", setor: "operacao", titulo: "Check-list", icone: "checklist", fase: 1 },
  { slug: "os", setor: "operacao", titulo: "Ordem de serviço", icone: "chave", fase: 1 },
  { slug: "cubagem", setor: "balanca", titulo: "Cubagem de areia", icone: "regua", fase: 2 },
  { slug: "carro-pipa", setor: "balanca", titulo: "Carro-pipa", icone: "gota", fase: 2 },
  { slug: "estoque-dia", setor: "balanca", titulo: "Estoque do dia", icone: "armazem", fase: 2 },
  { slug: "laudos", setor: "laboratorio", titulo: "Laudos de ruptura", icone: "frasco", fase: 2 },
  { slug: "recebimento", setor: "administrativo", titulo: "Recebimento", icone: "pacote", fase: 2 },
  { slug: "fechamento-mes", setor: "administrativo", titulo: "Fechamento do mês", icone: "calendario", fase: 2 },
  { slug: "fluxo-caixa", setor: "financeiro", titulo: "Fluxo de caixa", icone: "carteira", fase: 3 },
  { slug: "cartoes", setor: "financeiro", titulo: "Cartões", icone: "cartao", fase: 3 },
  { slug: "vencimentos", setor: "financeiro", titulo: "Vencimentos", icone: "relogio", fase: 3 },
  { slug: "licencas", setor: "financeiro", titulo: "Licenças e taxas", icone: "documento", fase: 3 },
  { slug: "agenda", setor: "comercial", titulo: "Visitas de hoje", icone: "mapa", fase: 3 },
  { slug: "nova-obra", setor: "comercial", titulo: "Nova obra", icone: "obra", fase: 3 },
  { slug: "proposta", setor: "comercial", titulo: "Proposta", icone: "proposta", fase: 3 },
];

export function tarefasDe(setores: Setor[]) {
  return TAREFAS.filter((t) => setores.includes(t.setor));
}

export function tarefaPorSlug(slug: string) {
  return TAREFAS.find((t) => t.slug === slug);
}

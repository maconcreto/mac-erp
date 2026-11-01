import { notFound } from "next/navigation";
import { IconeTarefaSvg } from "@/components/icone-tarefa";
import { BotaoLink } from "@/components/ui";
import { tarefaPorSlug } from "@/lib/tarefas";

export default async function PaginaTarefa({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const tarefa = tarefaPorSlug(slug);
  if (!tarefa) notFound();

  return (
    <div className="mx-auto flex max-w-md flex-col items-center gap-5 py-10 text-center">
      <span className="flex size-20 items-center justify-center rounded-2xl bg-marca-preto text-marca">
        <IconeTarefaSvg nome={tarefa.icone} className="size-10" />
      </span>
      <h1 className="text-3xl font-extrabold">{tarefa.titulo}</h1>
      <p className="text-lg text-suave">Esta tela chega na Fase {tarefa.fase}.</p>
      <BotaoLink href="/" tamanho="lg">
        Voltar
      </BotaoLink>
    </div>
  );
}

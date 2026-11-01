import {
  Building2, CalendarCheck, CalendarClock, ClipboardCheck, CreditCard, Droplets, FileCheck, FileText,
  FlaskConical, MapPin, PackageCheck, Ruler, Truck, Wallet, Warehouse, Wrench, type LucideIcon,
} from "lucide-react";
import type { IconeTarefa } from "@/lib/tarefas";

const MAPA: Record<IconeTarefa, LucideIcon> = {
  caminhao: Truck,
  checklist: ClipboardCheck,
  chave: Wrench,
  regua: Ruler,
  gota: Droplets,
  armazem: Warehouse,
  frasco: FlaskConical,
  pacote: PackageCheck,
  calendario: CalendarCheck,
  carteira: Wallet,
  cartao: CreditCard,
  relogio: CalendarClock,
  documento: FileCheck,
  mapa: MapPin,
  obra: Building2,
  proposta: FileText,
};

export function IconeTarefaSvg({ nome, className }: { nome: IconeTarefa; className?: string }) {
  const Icone = MAPA[nome];
  return <Icone className={className} strokeWidth={2} aria-hidden />;
}

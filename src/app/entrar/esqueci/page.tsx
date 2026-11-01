import type { Metadata } from "next";
import { TelaMarca } from "@/components/tela-marca";
import { FormEsqueci } from "./form";

export const metadata: Metadata = { title: "Recuperar senha" };

export default function Esqueci() {
  return (
    <TelaMarca>
      <FormEsqueci />
    </TelaMarca>
  );
}

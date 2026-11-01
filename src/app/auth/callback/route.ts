import { NextResponse, type NextRequest } from "next/server";
import { criarClienteServidor } from "@/lib/supabase/server";

// Links dos e-mails (confirmação, convite, recuperação): troca o código por uma sessão e segue.
export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url);
  const codigo = searchParams.get("code");
  const proximo = searchParams.get("next") ?? "/";
  // Só caminhos internos: impede usar o link para mandar a pessoa a outro site.
  const destino = proximo.startsWith("/") && !proximo.startsWith("//") ? proximo : "/";

  if (codigo) {
    const supabase = await criarClienteServidor();
    const { error } = await supabase.auth.exchangeCodeForSession(codigo);
    if (!error) return NextResponse.redirect(`${origin}${destino}`);
  }
  return NextResponse.redirect(`${origin}/entrar/esqueci?link_vencido=1`);
}

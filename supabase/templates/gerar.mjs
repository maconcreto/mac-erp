// Gera os modelos de e-mail do Supabase Auth com a identidade da Marcos Andrade Concreto.
// Uso: node supabase/templates/gerar.mjs  → escreve um .html por modelo nesta pasta.
// Depois, cole cada um em Supabase → Authentication → Emails → Templates (assunto em ASSUNTOS.md).
import { writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const SITE = "https://mac-erp-steel.vercel.app";
const LOGO = `${SITE}/marca/logo-email.png`;
const C = {
  preto: "#0b0d0a", verde: "#b4ff20", fundo: "#edefea", cartao: "#ffffff",
  tinta: "#171b14", texto: "#3a4234", suave: "#5a6253", linha: "#d5d9cf", caixa: "#f4f6f0",
};
const FONTE = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

function layout({ previa, titulo, corpo, botao, codigo, rodape }) {
  const blocoBotao = botao
    ? `<tr><td style="padding:8px 0 4px">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0"><tr>
          <td bgcolor="${C.verde}" style="border-radius:12px;border:1px solid ${C.preto}">
            <a href="${botao.url}" target="_blank" style="display:inline-block;padding:16px 28px;font-family:${FONTE};font-size:17px;font-weight:700;color:${C.preto};text-decoration:none;border-radius:12px">${botao.texto}</a>
          </td></tr></table>
      </td></tr>`
    : "";
  const blocoCodigo = codigo
    ? `<tr><td style="padding:20px 0 4px">
        <p style="margin:0 0 8px;font-family:${FONTE};font-size:14px;font-weight:600;color:${C.suave}">${codigo.rotulo}</p>
        <div style="background:${C.caixa};border:1px solid ${C.linha};border-radius:12px;padding:16px;text-align:center;font-family:'SFMono-Regular',Menlo,Consolas,monospace;font-size:32px;font-weight:700;letter-spacing:8px;color:${C.tinta}">{{ .Token }}</div>
      </td></tr>`
    : "";
  const blocoLink = botao
    ? `<tr><td style="padding:20px 0 0;font-family:${FONTE};font-size:13px;line-height:1.5;color:${C.suave}">
        Se o botão não abrir, copie este endereço no navegador:<br>
        <a href="${botao.url}" style="color:${C.suave};word-break:break-all">${botao.url}</a>
      </td></tr>`
    : "";

  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
<title>${titulo}</title>
</head>
<body style="margin:0;padding:0;background:${C.fundo}">
<div style="display:none;max-height:0;overflow:hidden;opacity:0">${previa}</div>
<table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="${C.fundo}" style="background:${C.fundo}">
<tr><td align="center" style="padding:24px 12px">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:560px">
    <tr><td bgcolor="${C.preto}" align="center" style="background:${C.preto};border-radius:16px 16px 0 0;border-bottom:4px solid ${C.verde};padding:28px 24px">
      <img src="${LOGO}" width="280" height="63" alt="Marcos Andrade Concreto" style="display:block;width:280px;max-width:100%;height:auto;border:0">
    </td></tr>
    <tr><td bgcolor="${C.cartao}" style="background:${C.cartao};border-radius:0 0 16px 16px;padding:32px 28px">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr><td style="font-family:${FONTE};font-size:24px;line-height:1.25;font-weight:800;color:${C.tinta};padding:0 0 12px">${titulo}</td></tr>
        <tr><td style="font-family:${FONTE};font-size:16px;line-height:1.55;color:${C.texto};padding:0 0 16px">${corpo}</td></tr>
        ${blocoBotao}
        ${blocoCodigo}
        ${blocoLink}
      </table>
    </td></tr>
    <tr><td align="center" style="padding:20px 12px 8px;font-family:${FONTE};font-size:13px;line-height:1.5;color:${C.suave}">
      ${rodape ?? "Se você não pediu isto, pode ignorar este e-mail."}<br>
      <b style="color:${C.tinta}">Plataforma MAC</b> · Marcos Andrade Concreto
    </td></tr>
  </table>
</td></tr>
</table>
</body>
</html>
`;
}

export const MODELOS = [
  {
    arquivo: "recuperar-senha.html",
    supabase: "Reset password",
    assunto: "Código para redefinir sua senha · Plataforma MAC",
    html: layout({
      previa: "Use o código ou o botão para criar uma senha nova.",
      titulo: "Redefinir sua senha",
      corpo: "Recebemos um pedido para trocar a senha da sua conta na Plataforma MAC. Toque no botão ou digite o código na tela do app.",
      botao: { texto: "Criar nova senha", url: "{{ .ConfirmationURL }}" },
      codigo: { rotulo: "Ou digite este código no app" },
      rodape: "Se não foi você, ignore: sua senha continua a mesma.",
    }),
  },
  {
    arquivo: "convite.html",
    supabase: "Invite user",
    assunto: "Seu acesso à Plataforma MAC",
    html: layout({
      previa: "Você foi cadastrado na Plataforma MAC.",
      titulo: "Você tem acesso à Plataforma MAC",
      corpo: "A diretoria da Marcos Andrade Concreto criou seu acesso ao sistema das usinas. Toque no botão para entrar e criar sua senha.",
      botao: { texto: "Entrar na plataforma", url: "{{ .ConfirmationURL }}" },
    }),
  },
  {
    arquivo: "confirmar-cadastro.html",
    supabase: "Confirm signup",
    assunto: "Confirme seu e-mail · Plataforma MAC",
    html: layout({
      previa: "Falta um passo para ativar sua conta.",
      titulo: "Confirme seu e-mail",
      corpo: "Falta só confirmar que este e-mail é seu para ativar sua conta na Plataforma MAC.",
      botao: { texto: "Confirmar e-mail", url: "{{ .ConfirmationURL }}" },
      codigo: { rotulo: "Ou use este código" },
    }),
  },
  {
    arquivo: "link-de-acesso.html",
    supabase: "Magic link",
    assunto: "Seu link de acesso · Plataforma MAC",
    html: layout({
      previa: "Entre sem senha com este link.",
      titulo: "Seu link de acesso",
      corpo: "Toque no botão para entrar na Plataforma MAC sem digitar a senha. O link vale por pouco tempo e só uma vez.",
      botao: { texto: "Entrar agora", url: "{{ .ConfirmationURL }}" },
      codigo: { rotulo: "Ou digite este código no app" },
    }),
  },
  {
    arquivo: "trocar-email.html",
    supabase: "Change email address",
    assunto: "Confirme seu novo e-mail · Plataforma MAC",
    html: layout({
      previa: "Confirme a troca do e-mail da sua conta.",
      titulo: "Confirme seu novo e-mail",
      corpo: "Pediram para trocar o e-mail da sua conta de <b>{{ .Email }}</b> para <b>{{ .NewEmail }}</b>. Toque no botão para confirmar.",
      botao: { texto: "Confirmar novo e-mail", url: "{{ .ConfirmationURL }}" },
      rodape: "Se você não pediu essa troca, avise a diretoria.",
    }),
  },
  {
    arquivo: "codigo-de-confirmacao.html",
    supabase: "Reauthentication",
    assunto: "Seu código de confirmação · Plataforma MAC",
    html: layout({
      previa: "Código para confirmar uma ação na sua conta.",
      titulo: "Código de confirmação",
      corpo: "Use o código abaixo para confirmar a ação que você está fazendo na Plataforma MAC.",
      codigo: { rotulo: "Seu código" },
      rodape: "Se não foi você, troque sua senha e avise a diretoria.",
    }),
  },
];

const aqui = dirname(fileURLToPath(import.meta.url));
for (const m of MODELOS) writeFileSync(join(aqui, m.arquivo), m.html);
writeFileSync(
  join(aqui, "ASSUNTOS.md"),
  "# Assuntos dos e-mails\n\nEm Supabase → Authentication → Emails → Templates, cada modelo recebe o assunto abaixo e o HTML do arquivo indicado.\n\n" +
    "| Modelo no Supabase | Assunto | Arquivo |\n| --- | --- | --- |\n" +
    MODELOS.map((m) => `| ${m.supabase} | ${m.assunto} | \`${m.arquivo}\` |`).join("\n") +
    "\n",
);
console.log(MODELOS.length, "modelos gerados");

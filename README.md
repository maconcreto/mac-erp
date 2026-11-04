# Plataforma MAC

Sistema das usinas Marcos Andrade Concreto: um lugar único para a usina lançar o dia e a gestão acompanhar custo, consumo, qualidade e caixa, por usina e consolidado.

O escopo, o roadmap e as regras de alteração estão no documento **Plataforma MAC — Análise e Escopo do Projeto**. Toda mudança começa como uma Issue neste repositório.

## Stack

- **Next.js 15 + TypeScript + Tailwind CSS 4**, hospedado na **Vercel**
- **Supabase**: login (Auth), banco Postgres com Row Level Security, arquivos (Storage)
- **API da Anthropic** (a partir da Fase 2), chamada só pelo servidor, para ler PDFs e fotos

## O que já existe (Fase 0 — Fundação)

- Login por e-mail e senha; a primeira conta criada vira **Diretoria**
- Papéis: diretoria, gerente de usina, financeiro, administrativo, comercial, lançador
- Setores: operação, balança, laboratório, administrativo, financeiro, comercial
- **Modo Campo**: tela inicial com cartões grandes, só com as tarefas do setor da pessoa
- **Painel**: usinas, ativos, pessoas e andamento da implantação
- **Cadastros** (só diretoria): usinas e liberação de acessos
- Banco do Núcleo: empresa → usina → pessoas, acessos, ativos, materiais, parâmetros e auditoria
- Regras no banco: cada usina só enxerga o que é dela; nada é apagado sem ficar registrado na auditoria
- App instalável no celular (PWA)

## Publicar (primeira vez)

1. **Banco de dados (Supabase).** Se a integração GitHub do Supabase estiver aplicando migrações, o arquivo `supabase/migrations/20261101000000_nucleo.sql` roda sozinho a cada envio para a `main`. Se não estiver, abra **Supabase → SQL Editor**, cole o conteúdo desse arquivo e clique em **Run**. Rode só uma vez.
2. **Variáveis na Vercel.** Em **Vercel → Project → Settings → Environment Variables**, confira se existem `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY`. A integração Vercel ↔ Supabase costuma criá-las; se faltar, copie de **Supabase → Project Settings → API**. Depois, publique de novo (**Deployments → Redeploy**).
3. **Endereço do site no Supabase.** Em **Supabase → Authentication → URL Configuration**:
   - **Site URL**: o endereço da Vercel (ex.: `https://mac-erp.vercel.app`)
   - **Redirect URLs**: o mesmo endereço seguido de `/auth/callback`
4. **Primeiro acesso.** Abra o site, toque em **Primeiro acesso? Criar conta** e confirme pelo e-mail. A primeira conta vira Diretoria.
5. **Equipe.** Cada pessoa cria a própria conta. Ela aparece em **Cadastros → Pessoas e acessos → Aguardando liberação**, e a diretoria escolhe usina, papel e setores.

## Usuários

- Só a diretoria cria usuários: **Cadastros → Equipe → Novo usuário** (dados, e-mail de login, senha e acessos).
- A diretoria pode editar dados, trocar a senha e desativar o usuário (o login é bloqueado na hora).
- Cada pessoa troca a própria senha em **Minha conta** (ícone de pessoa no topo) ou em **Esqueci minha senha**.
- Requer a variável `SUPABASE_SERVICE_ROLE_KEY` na Vercel (tipo *Sensitive*). Ela fica só no servidor.

## E-mails (remetente maconcretodev@gmail.com)

1. Na conta Google `maconcretodev@gmail.com`, ative a verificação em duas etapas e crie uma **senha de app**.
2. Em **Supabase → Authentication → Emails → SMTP Settings**, ative o SMTP próprio:
   host `smtp.gmail.com`, porta `465`, usuário e remetente `maconcretodev@gmail.com`, nome `Plataforma MAC`, senha = a senha de app.
3. Em **Supabase → Authentication → Emails → Templates**, cole cada modelo de `supabase/templates/` com o assunto de `supabase/templates/ASSUNTOS.md`.
4. Para mudar o visual, edite `supabase/templates/gerar.mjs` e rode `node supabase/templates/gerar.mjs`.

## Importar o histórico da Frota (do artefato antigo)

1. Publique a migração `20261101000300_frota.sql` (ela cria boletim, ordens de serviço, consumo mensal e leituras).
2. Descompacte o export do artefato (pasta `plataforma-mac_AAAA-MM-DD_HHMM`) na raiz do projeto e gere os SQLs:

```bash
node supabase/importacao/frota.mjs ./plataforma-mac_2026-11-01_1859 ./importar-frota
```

3. No **Supabase → SQL Editor**, rode os 4 arquivos de `importar-frota/`, nesta ordem: `1-ativos-e-parametros.sql`, `2-boletins.sql`, `3-ordens-de-servico.sql`, `4-consumo-mensal.sql`. Pode rodar de novo sem duplicar nada.

A central `maconc` do artefato é ligada à usina `VDC`. Esses arquivos têm dados reais da operação e estão no `.gitignore`.

## Identidade visual

A logo oficial está vetorizada em `public/marca/` (horizontal, vertical e símbolo). O verde `#B4FF20` só aparece sobre preto ou como fundo de botão com texto preto; texto de destaque sobre fundo claro usa `#3F6B00`.

## Desenvolvimento local

```bash
cp .env.example .env.local   # preencha com os dados do Supabase
npm install
npm run dev
```

## Regras para mudanças

1. Toda alteração nasce de uma Issue com usina, setor, papel afetado, exemplo real e critério de pronto.
2. Telas do Modo Campo precisam passar no **teste do balanceiro**: um lançador novo conclui a tarefa sozinho em menos de 2 minutos.
3. Uma fonte de verdade: nada de segundo cadastro para usina, material, pessoa ou ativo.
4. Permissões e validações críticas ficam no banco (RLS e restrições), não só na tela.
5. Nada se apaga: use situação "cancelado", com motivo, autor e data.
6. Toda mudança passa antes pelo endereço de teste da Vercel (Preview) e é validada na VDC.
7. Limites, tolerâncias e preços de referência são parâmetros editáveis, não números no código.
8. A usina de trabalho é escolhida só no cabeçalho (`usinaAtual` em `src/lib/usina-atual.ts`). Nenhuma tela tem seletor de usina próprio.

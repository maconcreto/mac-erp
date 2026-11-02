# Topcon — área de stand by

Cópia crua (somente leitura) das tabelas do Topcon Suite dentro do Supabase, em schemas
`topcon_sys`, `topcon_geral` e `topcon_fixo`. Nenhuma tela do ERP usa isso: é só para
analisar depois o que vale aproveitar. Os schemas são fechados para `anon` e `authenticated`.

- `regras.mjs` — o que entra e o que fica de fora (tabelas temporárias, logs, folha, senhas, cartão, Pix, arquivos).
- `gerar.mjs` — lê o schema do Topcon e gera `tabelas.json` + a migração `20261102000000_topcon_standby.sql`.
- `carregar.mjs` — lê o MySQL restaurado no seu PC (porta 3307) e carrega no Supabase. Sem `--executar` só conta e mostra tamanhos.
- `omitidas.txt` — colunas que não são carregadas.

O carregador recusa a porta 20306 (Topcon de produção) e só escreve em schemas `topcon_*`.
Cada carga apaga e recarrega a tabela inteira, então pode rodar de novo com um backup mais novo.
Dados reais nunca vão para o Git.

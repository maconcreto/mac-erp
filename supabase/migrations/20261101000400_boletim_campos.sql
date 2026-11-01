-- =====================================================================
-- Plataforma MAC — Boletim do dia: dois campos que o artefato usava
--  * boletim.sem_producao  — dia fechado como "sem produção" (domingo, feriado, chuva)
--  * boletim_item.os_ref   — número da OS da manutenção quando o veículo está parado por manutenção
-- =====================================================================
alter table public.boletim      add column if not exists sem_producao boolean not null default false;
alter table public.boletim_item add column if not exists os_ref       text;

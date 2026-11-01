-- Funções internas não podem ser chamadas pela API por quem não entrou no sistema.
-- As de gatilho (trigger) não são chamadas por ninguém diretamente.
revoke execute on function public.novo_usuario() from public, anon, authenticated;
revoke execute on function public.proteger_pessoa() from public, anon, authenticated;
revoke execute on function public.registrar_auditoria() from public, anon, authenticated;

-- As de permissão só respondem sobre a própria pessoa logada; ficam só para quem entrou.
revoke execute on function public.minha_empresa() from public, anon;
revoke execute on function public.e_diretoria() from public, anon;
revoke execute on function public.usinas_visiveis() from public, anon;
revoke execute on function public.tem_papel(uuid, public.papel[]) from public, anon;
grant execute on function public.minha_empresa() to authenticated;
grant execute on function public.e_diretoria() to authenticated;
grant execute on function public.usinas_visiveis() to authenticated;
grant execute on function public.tem_papel(uuid, public.papel[]) to authenticated;

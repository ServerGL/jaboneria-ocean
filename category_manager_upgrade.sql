-- Jaboneria Ocean · gestión avanzada de categorías
-- Ejecutar UNA SOLA VEZ en Supabase SQL Editor.
alter table public.site_settings add column if not exists category_settings jsonb not null default '[]'::jsonb;
insert into public.site_settings (id,category_settings) values (1,'[]'::jsonb) on conflict (id) do nothing;
grant select on public.site_settings to anon, authenticated;
grant insert, update on public.site_settings to authenticated;

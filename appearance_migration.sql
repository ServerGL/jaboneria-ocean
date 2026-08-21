-- JABONERIA OCEAN · MIGRACIÓN DE APARIENCIA
-- Ejecutar UNA sola vez en Supabase SQL Editor. No reemplaza setup.sql.

create table if not exists public.site_settings (
  id integer primary key default 1,
  logo_url text not null default '',
  background_url text not null default '',
  updated_at timestamptz not null default now(),
  constraint site_settings_singleton check (id = 1)
);

insert into public.site_settings (id) values (1)
on conflict (id) do nothing;

alter table public.site_settings enable row level security;

drop policy if exists "site_settings_public_read" on public.site_settings;
create policy "site_settings_public_read"
on public.site_settings
for select
to anon, authenticated
using (true);

drop policy if exists "site_settings_admin_insert" on public.site_settings;
create policy "site_settings_admin_insert"
on public.site_settings
for insert
to authenticated
with check (public.is_admin());

drop policy if exists "site_settings_admin_update" on public.site_settings;
create policy "site_settings_admin_update"
on public.site_settings
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

grant select on public.site_settings to anon, authenticated;
grant insert, update on public.site_settings to authenticated;

-- El bucket product-images ya existe por setup.sql.
-- Las imágenes de apariencia se guardan dentro de appearance/.

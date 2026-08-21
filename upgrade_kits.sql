-- JABONERIA OCEAN · KITS / COMBOS
-- Ejecutar UNA SOLA VEZ en Supabase SQL Editor, después de setup.sql y upgrade_catalog.sql.

create table if not exists public.kits (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  emoji text not null default '🎁',
  price numeric(12,2) not null default 0,
  price_label text not null default 'Consultar',
  old_price numeric(12,2),
  image_url text not null default '',
  sort_order integer not null default 0,
  available boolean not null default true,
  components jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists kits_sort_order_idx on public.kits(sort_order);

create or replace function public.set_kits_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at=now();
  return new;
end;
$$;

drop trigger if exists kits_updated_at on public.kits;
create trigger kits_updated_at before update on public.kits
for each row execute function public.set_kits_updated_at();

alter table public.kits enable row level security;

drop policy if exists "kits_public_read" on public.kits;
create policy "kits_public_read"
on public.kits
for select to anon, authenticated
using (true);

drop policy if exists "kits_admin_insert" on public.kits;
create policy "kits_admin_insert"
on public.kits
for insert to authenticated
with check (public.is_admin());

drop policy if exists "kits_admin_update" on public.kits;
create policy "kits_admin_update"
on public.kits
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "kits_admin_delete" on public.kits;
create policy "kits_admin_delete"
on public.kits
for delete to authenticated
using (public.is_admin());

grant select on public.kits to anon, authenticated;
grant insert, update, delete on public.kits to authenticated;

-- Kits iniciales de ejemplo. Si ya existen kits, no se duplican.
insert into public.kits (name,description,emoji,price_label,sort_order,available,components)
select 'Kit para empezar en jabones',
       'Base + esencia + colorante + molde. Podemos ayudarte a elegir las opciones disponibles.',
       '🧼','Consultar',1,true,'[]'::jsonb
where not exists (select 1 from public.kits where name='Kit para empezar en jabones');

insert into public.kits (name,description,emoji,price_label,sort_order,available,components)
select 'Kit para empezar en velas',
       'Cera o parafina + esencia + envase. Te orientamos según el tipo de vela que quieras hacer.',
       '🕯️','Consultar',2,true,'[]'::jsonb
where not exists (select 1 from public.kits where name='Kit para empezar en velas');

insert into public.kits (name,description,emoji,price_label,sort_order,available,components)
select 'Kit para crear y emprender',
       'Moldes, esencias y complementos para comenzar tus primeros productos.',
       '🎨','Consultar',3,true,'[]'::jsonb
where not exists (select 1 from public.kits where name='Kit para crear y emprender');

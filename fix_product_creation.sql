-- JABONERIA OCEAN · FIX CREACIÓN DE PRODUCTOS
-- Ejecutar UNA SOLA VEZ en Supabase SQL Editor.
-- Esta versión evita el INSERT directo desde el navegador y garantiza que name nunca llegue NULL.

-- Asegura que las columnas usadas por el formulario existan aunque el SQL anterior no se haya ejecutado.
alter table public.products add column if not exists featured boolean not null default false;
alter table public.products add column if not exists is_offer boolean not null default false;
alter table public.products add column if not exists old_price numeric(12,2);

create or replace function public.admin_create_product(
  p_name text,
  p_category text,
  p_presentation text default '',
  p_price numeric default 0,
  p_price_label text default '',
  p_emoji text default '🛍️',
  p_keyword text default '',
  p_available boolean default true,
  p_featured boolean default false,
  p_is_offer boolean default false,
  p_old_price numeric default null
)
returns public.products
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
  v_category text;
  v_order integer;
  v_product public.products;
begin
  if not public.is_admin() then
    raise exception 'No autorizado para crear productos.';
  end if;

  v_name := trim(coalesce(p_name, ''));
  if v_name = '' then
    raise exception 'El nombre del producto es obligatorio.';
  end if;

  v_category := trim(regexp_replace(coalesce(p_category, 'Otros'), '\s+', ' ', 'g'));
  if v_category = '' then
    v_category := 'Otros';
  end if;

  -- Coloca el nuevo producto al final de su categoría y desplaza los siguientes.
  perform pg_advisory_xact_lock(hashtext('jaboneria_ocean_products_order'));
  select coalesce(max(sort_order), 0) + 1
    into v_order
    from public.products
   where lower(trim(category)) = lower(trim(v_category));

  update public.products
     set sort_order = sort_order + 1
   where sort_order >= v_order;

  insert into public.products
    (name, presentation, price, price_label, category, emoji, keyword,
     image_url, sort_order, available, featured, is_offer, old_price)
  values
    (v_name,
     coalesce(p_presentation, ''),
     coalesce(p_price, 0),
     coalesce(p_price_label, ''),
     v_category,
     coalesce(nullif(trim(p_emoji), ''), '🛍️'),
     coalesce(p_keyword, v_name),
     '',
     v_order,
     coalesce(p_available, true),
     coalesce(p_featured, false),
     coalesce(p_is_offer, false),
     p_old_price)
  returning * into v_product;

  return v_product;
end;
$$;

grant execute on function public.admin_create_product(text,text,text,numeric,text,text,text,boolean,boolean,boolean,numeric) to authenticated;

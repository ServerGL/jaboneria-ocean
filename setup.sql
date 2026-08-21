-- JABONERIA OCEAN · SUPABASE SETUP
-- EJECUTAR UNA SOLA VEZ EN SQL EDITOR.
-- Después crea el usuario en Authentication y agrega su UUID a admin_users.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  presentation text default '',
  price numeric(12,2) not null default 0,
  price_label text not null default '',
  category text not null default 'Otros',
  emoji text default '🛍️',
  keyword text default '',
  image_url text default '',
  sort_order integer not null default 0,
  available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  sales_count integer not null default 0
);

create or replace function public.set_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at before update on public.products for each row execute function public.set_updated_at();

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.admin_users where user_id = auth.uid());
$$;

alter table public.admin_users enable row level security;
alter table public.products enable row level security;

drop policy if exists "admin_users_self_select" on public.admin_users;
create policy "admin_users_self_select" on public.admin_users for select to authenticated using (user_id=auth.uid());

drop policy if exists "products_public_read" on public.products;
create policy "products_public_read" on public.products for select to anon, authenticated using (true);

drop policy if exists "products_admin_insert" on public.products;
create policy "products_admin_insert" on public.products for insert to authenticated with check (public.is_admin());

drop policy if exists "products_admin_update" on public.products;
create policy "products_admin_update" on public.products for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "products_admin_delete" on public.products;
create policy "products_admin_delete" on public.products for delete to authenticated using (public.is_admin());

-- Storage: bucket público para que las fotos se vean en la tienda.
insert into storage.buckets (id,name,public) values ('product-images','product-images',true) on conflict (id) do update set public=true;

drop policy if exists "product_images_public_read" on storage.objects;
create policy "product_images_public_read" on storage.objects for select to public using (bucket_id='product-images');

drop policy if exists "product_images_admin_insert" on storage.objects;
create policy "product_images_admin_insert" on storage.objects for insert to authenticated with check (bucket_id='product-images' and public.is_admin());

drop policy if exists "product_images_admin_update" on storage.objects;
create policy "product_images_admin_update" on storage.objects for update to authenticated using (bucket_id='product-images' and public.is_admin()) with check (bucket_id='product-images' and public.is_admin());

drop policy if exists "product_images_admin_delete" on storage.objects;
create policy "product_images_admin_delete" on storage.objects for delete to authenticated using (bucket_id='product-images' and public.is_admin());

-- CATÁLOGO INICIAL. Si vuelves a ejecutar este bloque, borra los productos actuales.
delete from public.products;
insert into public.products (name,presentation,price,price_label,category,emoji,keyword,image_url,sort_order,available) values
('Bases de glicerina','Blanca · 1 kg',26.0,'S/ 26.00','Bases','🧼','Base blanca','./assets/productos/1.jpg',1,true),
('Bases de glicerina','Blanca · 5 kg',25.0,'S/ 25.00 c/u','Bases','🧼','Base blanca','./assets/productos/2.jpg',2,true),
('Bases de glicerina','Blanca · 10 kg',24.5,'S/ 24.50 c/u','Bases','🧼','Base blanca','./assets/productos/3.jpg',3,true),
('Bases de glicerina','Ámbar · 1 kg',26.0,'S/ 26.00','Bases','🧼','Base ámbar','./assets/productos/4.jpg',4,true),
('Bases de glicerina','Ámbar · 5 kg',25.0,'S/ 25.00 c/u','Bases','🧼','Base ámbar','./assets/productos/5.jpg',5,true),
('Bases de glicerina','Ámbar · 10 kg',24.5,'S/ 24.50 c/u','Bases','🧼','Base ámbar','./assets/productos/6.jpg',6,true),
('Bases de glicerina','Transparente cristal · 1 kg',29.0,'S/ 29.00','Bases','✨','Base cristal','./assets/productos/7.jpg',7,true),
('Bases de glicerina','Transparente cristal · 5 kg',28.0,'S/ 28.00 c/u','Bases','✨','Base cristal','./assets/productos/8.jpg',8,true),
('Bases de glicerina','Transparente cristal · 10 kg',27.5,'S/ 27.50 c/u','Bases','✨','Base cristal','./assets/productos/9.jpg',9,true),
('Fragancia Coco','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Coco','./assets/productos/10.jpg',10,true),
('Fragancia Bambú','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Bambú','./assets/productos/11.jpg',11,true),
('Fragancia Maracuyá','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Maracuyá','./assets/productos/12.jpg',12,true),
('Fragancia Naranja','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Naranja','./assets/productos/13.jpg',13,true),
('Fragancia Eucalipto','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Eucalipto','./assets/productos/14.jpg',14,true),
('Fragancia Manzanilla','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Manzanilla','./assets/productos/15.jpg',15,true),
('Fragancia Rosas','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Rosas','./assets/productos/16.jpg',16,true),
('Fragancia Chocolate','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Chocolate','./assets/productos/17.jpg',17,true),
('Fragancia Tutifruti','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Tutifruti','./assets/productos/18.jpg',18,true),
('Fragancia Jazmín','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Jazmín','./assets/productos/19.jpg',19,true),
('Fragancia Café','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Café','./assets/productos/20.jpg',20,true),
('Fragancia Limón','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Limón','./assets/productos/21.jpg',21,true),
('Fragancia Lavanda','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Lavanda','./assets/productos/22.jpg',22,true),
('Fragancia Chicle','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Chicle','./assets/productos/23.jpg',23,true),
('Fragancia Hierba Luisa','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Hierba Luisa','./assets/productos/24.jpg',24,true),
('Fragancia Manzana','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Manzana','./assets/productos/25.jpg',25,true),
('Fragancia Fresas','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Fresas','./assets/productos/26.jpg',26,true),
('Fragancia Almendras','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Almendras','./assets/productos/27.jpg',27,true),
('Fragancia Bebé','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Bebé','./assets/productos/28.jpg',28,true),
('Fragancia Vainilla','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Vainilla','./assets/productos/29.jpg',29,true),
('Fragancia Brisa Marina','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Brisa Marina','./assets/productos/30.jpg',30,true),
('Fragancia Rosa Búlgara','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Rosa Búlgara','./assets/productos/31.jpg',31,true),
('Fragancia Avena','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Avena','./assets/productos/32.jpg',32,true),
('Fragancia Calvin Klein','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Calvin Klein','./assets/productos/33.jpg',33,true),
('Fragancia Manzana Canela','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Manzana Canela','./assets/productos/34.jpg',34,true),
('Fragancia Té Verde','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Té Verde','./assets/productos/35.jpg',35,true),
('Fragancia Paco Rabanne','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Paco Rabanne','./assets/productos/36.jpg',36,true),
('Fragancia Talco BB','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Talco BB','./assets/productos/37.jpg',37,true),
('Fragancia Miel','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Miel','./assets/productos/38.jpg',38,true),
('Fragancia Sábila','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Sábila','./assets/productos/39.jpg',39,true),
('Fragancia Uva','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Uva','./assets/productos/40.jpg',40,true),
('Fragancia Sándalo','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Sándalo','./assets/productos/41.jpg',41,true),
('Fragancia Frutos Rojos','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Frutos Rojos','./assets/productos/42.jpg',42,true),
('Fragancia Leche','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Leche','./assets/productos/43.jpg',43,true),
('Fragancia Pachulí','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Pachulí','./assets/productos/44.jpg',44,true),
('Fragancia Cherry','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Cherry','./assets/productos/45.jpg',45,true),
('Fragancia Algodón','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Algodón','./assets/productos/46.jpg',46,true),
('Fragancia Violeta','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Violeta','./assets/productos/47.jpg',47,true),
('Fragancia Canela','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Canela','./assets/productos/48.jpg',48,true),
('Fragancia Cereza','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Cereza','./assets/productos/49.jpg',49,true),
('Fragancia Channel','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Channel','./assets/productos/50.jpg',50,true),
('Fragancia Durazno','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Durazno','./assets/productos/51.jpg',51,true),
('Fragancia Frambuesa','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Frambuesa','./assets/productos/52.jpg',52,true),
('Fragancia Gardenia','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Gardenia','./assets/productos/53.jpg',53,true),
('Fragancia Mandarina','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Mandarina','./assets/productos/54.jpg',54,true),
('Fragancia Mango','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Mango','./assets/productos/55.jpg',55,true),
('Fragancia Menta','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Menta','./assets/productos/56.jpg',56,true),
('Fragancia Mil Flores','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Mil Flores','./assets/productos/57.jpg',57,true),
('Fragancia Orquídea','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Orquídea','./assets/productos/58.jpg',58,true),
('Fragancia Piña','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Piña','./assets/productos/59.jpg',59,true),
('Fragancia Ruda','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Ruda','./assets/productos/60.jpg',60,true),
('Fragancia Sandía','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Sandía','./assets/productos/61.jpg',61,true),
('Fragancia Romero','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Romero','./assets/productos/62.jpg',62,true),
('Fragancia Avena y Miel','20 ml',18.0,'S/ 18.00','Fragancias','🌸','Avena y Miel','./assets/productos/63.jpg',63,true),
('Aceite esencial Melissa','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Melissa','./assets/productos/64.jpg',64,true),
('Aceite esencial Lavanda','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Lavanda','./assets/productos/65.jpg',65,true),
('Aceite esencial Árbol de té','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Árbol de té','./assets/productos/66.jpg',66,true),
('Aceite esencial Limón','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Limón','./assets/productos/67.jpg',67,true),
('Aceite esencial Menta','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Menta','./assets/productos/68.jpg',68,true),
('Aceite esencial Eucalipto','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Eucalipto','./assets/productos/69.jpg',69,true),
('Aceite esencial Bergamota','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Bergamota','./assets/productos/70.jpg',70,true),
('Aceite esencial Clavo de olor','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Clavo de olor','./assets/productos/71.jpg',71,true),
('Aceite esencial Romero','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Romero','./assets/productos/72.jpg',72,true),
('Aceite esencial Citronela','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Citronela','./assets/productos/73.jpg',73,true),
('Aceite esencial Rosas','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Rosas','./assets/productos/74.jpg',74,true),
('Aceite esencial Ylang Ylang','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Ylang Ylang','./assets/productos/75.jpg',75,true),
('Aceite esencial Mandarina','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Mandarina','./assets/productos/76.jpg',76,true),
('Aceite esencial Jazmín','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Jazmín','./assets/productos/77.jpg',77,true),
('Aceite esencial Naranja','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Naranja','./assets/productos/78.jpg',78,true),
('Aceite esencial Cyprees','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Cyprees','./assets/productos/79.jpg',79,true),
('Aceite esencial Anís','15 ml',28.0,'S/ 28.00','Aceites esenciales','🌿','Anís','./assets/productos/80.jpg',80,true),
('Aceite vegetal Almendras','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Almendras','./assets/productos/81.jpg',81,true),
('Aceite vegetal Semilla de uva','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Semilla de uva','./assets/productos/82.jpg',82,true),
('Aceite vegetal Argán','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Argán','./assets/productos/83.jpg',83,true),
('Aceite vegetal Rosas','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Rosas','./assets/productos/84.jpg',84,true),
('Aceite vegetal Castaña','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Castaña','./assets/productos/85.jpg',85,true),
('Aceite vegetal Coco','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Coco','./assets/productos/86.jpg',86,true),
('Aceite vegetal Eucalipto','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Eucalipto','./assets/productos/87.jpg',87,true),
('Aceite vegetal Maracuyá','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Maracuyá','./assets/productos/88.jpg',88,true),
('Aceite vegetal Rosa mosqueta','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Rosa mosqueta','./assets/productos/89.jpg',89,true),
('Aceite vegetal Aguaje','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Aguaje','./assets/productos/90.jpg',90,true),
('Aceite vegetal Copaiba','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Copaiba','./assets/productos/91.jpg',91,true),
('Aceite vegetal Chía','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Chía','./assets/productos/92.jpg',92,true),
('Aceite vegetal Girasol','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Girasol','./assets/productos/93.jpg',93,true),
('Aceite vegetal Oliva','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Oliva','./assets/productos/94.jpg',94,true),
('Aceite vegetal Jojoba','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Jojoba','./assets/productos/95.jpg',95,true),
('Aceite vegetal Ricino','30 ml',28.0,'S/ 28.00','Aceites vegetales','🥥','Ricino','./assets/productos/96.jpg',96,true),
('Vitamina E','10 ml',18.0,'S/ 18.00','Complementos','💧','Vitamina E','./assets/productos/97.jpg',97,true),
('Conservante Procidé','10 ml',15.0,'S/ 15.00','Complementos','🧪','Conservante','./assets/productos/98.jpg',98,true),
('Vitamina E','30 ml',36.0,'S/ 36.00','Complementos','🧪','Conservante','./assets/productos/99.jpg',99,true),
('Arcilla Blanca','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Arcillas','🪨','Blanca','./assets/productos/100.jpg',100,true),
('Arcilla Verde','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Arcillas','🪨','Verde','./assets/productos/101.jpg',101,true),
('Arcilla Roja','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Arcillas','🪨','Roja','./assets/productos/102.jpg',102,true),
('Arcilla Rosa','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Arcillas','🪨','Rosa','./assets/productos/103.jpg',103,true),
('Extracto natural de Zanahoria','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Zanahoria','./assets/productos/104.jpg',104,true),
('Extracto natural de Menta','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Menta','./assets/productos/105.jpg',105,true),
('Extracto natural de Áloe vera','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Áloe vera','./assets/productos/106.jpg',106,true),
('Extracto natural de Lavanda','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Lavanda','./assets/productos/107.jpg',107,true),
('Extracto natural de Uva','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Uva','./assets/productos/108.jpg',108,true),
('Extracto natural de Avena','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Avena','./assets/productos/109.jpg',109,true),
('Extracto natural de Té verde','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Té verde','./assets/productos/110.jpg',110,true),
('Extracto natural de Manzanilla','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Manzanilla','./assets/productos/111.jpg',111,true),
('Extracto natural de Caléndula','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Caléndula','./assets/productos/112.jpg',112,true),
('Extracto natural de Orégano','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Orégano','./assets/productos/113.jpg',113,true),
('Extracto natural de Hamamelis','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Hamamelis','./assets/productos/114.jpg',114,true),
('Extracto natural de Rosas','30 ml',28.0,'S/ 28.00','Extractos naturales','🌱','Rosas','./assets/productos/115.jpg',115,true),
('Planta pulverizada · Carbón','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Carbón','./assets/productos/116.jpg',116,true),
('Planta pulverizada · Polvo de arroz','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Polvo de arroz','./assets/productos/117.jpg',117,true),
('Planta pulverizada · Manzanilla','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Manzanilla','./assets/productos/118.jpg',118,true),
('Planta pulverizada · Avena orgánica','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Avena orgánica','./assets/productos/119.jpg',119,true),
('Planta pulverizada · Cacao','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Cacao','./assets/productos/120.jpg',120,true),
('Planta pulverizada · Coco','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Coco','./assets/productos/121.jpg',121,true),
('Planta pulverizada · Romero','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Romero','./assets/productos/122.jpg',122,true),
('Planta pulverizada · Lúcuma','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Lúcuma','./assets/productos/123.jpg',123,true),
('Planta pulverizada · Eucalipto','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Eucalipto','./assets/productos/124.jpg',124,true),
('Planta pulverizada · Almendras','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Almendras','./assets/productos/125.jpg',125,true),
('Planta pulverizada · Limón','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Limón','./assets/productos/126.jpg',126,true),
('Planta pulverizada · Flor de jamaica','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Flor de jamaica','./assets/productos/127.jpg',127,true),
('Planta pulverizada · Ruda','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Ruda','./assets/productos/128.jpg',128,true),
('Planta pulverizada · Ortiga','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Ortiga','./assets/productos/129.jpg',129,true),
('Planta pulverizada · Neem','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Neem','./assets/productos/130.jpg',130,true),
('Planta pulverizada · Flor de caléndula','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Flor de caléndula','./assets/productos/131.jpg',131,true),
('Planta pulverizada · Lavanda','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Lavanda','./assets/productos/132.jpg',132,true),
('Planta pulverizada · Menta','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Menta','./assets/productos/133.jpg',133,true),
('Planta pulverizada · Naranja','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Naranja','./assets/productos/134.jpg',134,true),
('Planta pulverizada · Sangre de grado','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Sangre de grado','./assets/productos/135.jpg',135,true),
('Planta pulverizada · Sábila','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Sábila','./assets/productos/136.jpg',136,true),
('Planta pulverizada · Camu camu','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Camu camu','./assets/productos/137.jpg',137,true),
('Planta pulverizada · Beterraga','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Beterraga','./assets/productos/138.jpg',138,true),
('Planta pulverizada · Chía','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Chía','./assets/productos/139.jpg',139,true),
('Planta pulverizada · Hierba luisa','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Hierba luisa','./assets/productos/140.jpg',140,true),
('Planta pulverizada · Manzanilla','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Manzanilla','./assets/productos/141.jpg',141,true),
('Planta pulverizada · Fenogreco','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Fenogreco','./assets/productos/142.jpg',142,true),
('Planta pulverizada · Jengibre','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Jengibre','./assets/productos/143.jpg',143,true),
('Planta pulverizada · Moringa','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Moringa','./assets/productos/144.jpg',144,true),
('Planta pulverizada · Semillas de girasol','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Semillas de girasol','./assets/productos/145.jpg',145,true),
('Planta pulverizada · Muña','50 g / 100 g',11.0,'S/ 11.00 / S/ 23.00','Plantas pulverizadas','🌿','Muña','./assets/productos/146.jpg',146,true),
('Colorante líquido migrante · Rojo','10 ml',10.0,'S/ 10.00','Colorantes','🎨','Rojo','./assets/productos/147.jpg',147,true),
('Colorante líquido migrante · Azul','10 ml',10.0,'S/ 10.00','Colorantes','🎨','Azul','./assets/productos/148.jpg',148,true),
('Colorante líquido migrante · Amarillo','10 ml',10.0,'S/ 10.00','Colorantes','🎨','Amarillo','./assets/productos/149.jpg',149,true),
('Colorante líquido migrante · Verde','10 ml',10.0,'S/ 10.00','Colorantes','🎨','Verde','./assets/productos/150.jpg',150,true),
('Colorante líquido no migrante · Rojo','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Rojo','./assets/productos/151.jpg',151,true),
('Colorante líquido no migrante · Azul','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Azul','./assets/productos/152.jpg',152,true),
('Colorante líquido no migrante · Amarillo','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Amarillo','./assets/productos/153.jpg',153,true),
('Colorante líquido no migrante · Verde','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Verde','./assets/productos/154.jpg',154,true),
('Colorante líquido no migrante · Negro','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Negro','./assets/productos/155.jpg',155,true),
('Colorante líquido no migrante · Marrón','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Marrón','./assets/productos/156.jpg',156,true),
('Colorante líquido no migrante · Morado','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Morado','./assets/productos/157.jpg',157,true),
('Colorante líquido no migrante · Rosa','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Rosa','./assets/productos/158.jpg',158,true),
('Colorante líquido no migrante · Naranja','10 ml',13.5,'S/ 13.50 c/u','Colorantes','🎨','Naranja','./assets/productos/159.jpg',159,true),
('Mica grado cosmético · Azul','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Azul','./assets/productos/160.jpg',160,true),
('Mica grado cosmético · Amarillo','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Amarillo','./assets/productos/161.jpg',161,true),
('Mica grado cosmético · Verde','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Verde','./assets/productos/162.jpg',162,true),
('Mica grado cosmético · Negro','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Negro','./assets/productos/163.jpg',163,true),
('Mica grado cosmético · Marrón','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Marrón','./assets/productos/164.jpg',164,true),
('Mica grado cosmético · Morado','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Morado','./assets/productos/165.jpg',165,true),
('Mica grado cosmético · Dorado','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Dorado','./assets/productos/166.jpg',166,true),
('Mica grado cosmético · Naranja','10 g',10.5,'S/ 10.50 c/u','Micas','✨','Naranja','./assets/productos/167.jpg',167,true),
('Cocobetaina','250 ml',15.0,'S/ 15.00','Espumantes','🫧','Cocobetaina','./assets/productos/168.jpg',168,true),
('Cocobetaina','1/2 litro',26.0,'S/ 26.00','Espumantes','🫧','Cocobetaina','./assets/productos/169.jpg',169,true),
('Cocobetaina','1 litro',50.0,'S/ 50.00','Espumantes','🫧','Cocobetaina','./assets/productos/170.jpg',170,true),
('Glicerina líquida','250 ml',15.0,'S/ 15.00','Espumantes','💧','Glicerina líquida','./assets/productos/171.jpg',171,true),
('Vaselina líquida','250 ml',15.0,'S/ 15.00','Espumantes','💧','Vaselina líquida','./assets/productos/172.jpg',172,true),
('Fijador de aroma','10 ml',15.0,'S/ 15.00','Espumantes','🧴','Fijador','./assets/productos/173.jpg',173,true),
('Manteca de cacao','35 g',18.0,'S/ 18.00','Aditivos','🧈','Manteca de cacao','./assets/productos/174.jpg',174,true),
('Manteca de karité','35 g',16.0,'S/ 16.00','Aditivos','🧈','Manteca de karité','./assets/productos/175.jpg',175,true),
('Manteca de karité','65 g',20.0,'S/ 20.00','Aditivos','🧈','Manteca de karité','./assets/productos/176.jpg',176,true),
('Balanza gramera','Unidad',20.0,'S/ 20.00','Implementos','⚖️','Balanza','./assets/productos/177.jpg',177,true),
('Juego de cortador para jabones','Juego',85.0,'S/ 85.00','Implementos','🔪','Cortador','./assets/productos/178.jpg',178,true),
('Termómetro','Unidad',20.0,'S/ 20.00','Implementos','🌡️','Termómetro','./assets/productos/179.jpg',179,true),
('Cortador de bases','Unidad',18.0,'S/ 18.00','Implementos','🧰','Cortador','./assets/productos/180.jpg',180,true),
('Bolsa de organza N.º 1','7 × 9 cm · unidad',2.0,'S/ 2.00','Bolsas de organza','🎁','Organza 1','./assets/productos/181.jpg',181,true),
('Bolsa de organza N.º 1','12 unidades',18.0,'S/ 18.00','Bolsas de organza','🎁','Organza 1','./assets/productos/182.jpg',182,true),
('Bolsa de organza N.º 1','25 unidades',30.0,'S/ 30.00','Bolsas de organza','🎁','Organza 1','./assets/productos/183.jpg',183,true),
('Bolsa de organza N.º 2','9 × 12 cm · unidad',2.0,'S/ 2.00','Bolsas de organza','🎁','Organza 2','./assets/productos/184.jpg',184,true),
('Bolsa de organza N.º 2','12 unidades',18.0,'S/ 18.00','Bolsas de organza','🎁','Organza 2','./assets/productos/185.jpg',185,true),
('Bolsa de organza N.º 2','25 unidades',30.0,'S/ 30.00','Bolsas de organza','🎁','Organza 2','./assets/productos/186.jpg',186,true),
('Bolsa de organza N.º 3','10 × 16 cm · unidad',2.0,'S/ 2.00','Bolsas de organza','🎁','Organza 3','./assets/productos/187.jpg',187,true),
('Bolsa de organza N.º 3','12 unidades',18.0,'S/ 18.00','Bolsas de organza','🎁','Organza 3','./assets/productos/188.jpg',188,true),
('Bolsa de organza N.º 3','25 unidades',30.0,'S/ 30.00','Bolsas de organza','🎁','Organza 3','./assets/productos/189.jpg',189,true),
('Parafina Premium','1 kg',38.0,'S/ 38.00','Parafinas','🕯️','Parafina Premium','./assets/productos/190.jpg',190,true),
('Parafina en gel','1 kg',68.0,'S/ 68.00','Parafinas','🕯️','Parafina en gel','./assets/productos/191.jpg',191,true),
('Parafina en gel','1/2 kilo',38.0,'S/ 38.00','Parafinas','🕯️','Parafina en gel 1/2 kilo','./assets/productos/192.jpg',192,true),
('Molde 3D Virgen Guadalupe','60 g',35.0,'S/ 35.00','Moldes 3D','🕯️','Virgen Guadalupe','./assets/productos/193.jpg',193,true),
('Molde 3D Osito Sentado 01','30 g',15.0,'S/ 15.00','Moldes 3D','🧸','Osito 01','./assets/productos/194.jpg',194,true),
('Molde 3D Osito Sentado 02','20 g',20.0,'S/ 20.00','Moldes 3D','🧸','Osito 02','./assets/productos/195.jpg',195,true),
('Molde 3D Osito Sentado 03','Unidad',20.0,'S/ 20.00','Moldes 3D','🧸','Osito 03','./assets/productos/196.jpg',196,true),
('Molde 3D Osito Sentado 04','20 g',20.0,'S/ 20.00','Moldes 3D','🧸','Osito 04','./assets/productos/197.jpg',197,true),
('Molde 3D Osito Sentado 05','20 g',20.0,'S/ 20.00','Moldes 3D','🧸','Osito 05','./assets/productos/198.jpg',198,true),
('Molde 3D Osito Corazón 13','Unidad',25.0,'S/ 25.00','Moldes 3D','🧸','Osito Corazón 13','./assets/productos/199.jpg',199,true),
('Molde 3D Osito Winni Pooh','Unidad',32.0,'S/ 32.00','Moldes 3D','🧸','Winni Pooh','./assets/productos/200.jpg',200,true),
('Molde 3D Osito','Unidad',13.0,'S/ 13.00','Moldes 3D','🧸','Osito','./assets/productos/201.jpg',201,true),
('Molde 3D Osito Kawaii','Unidad',20.0,'S/ 20.00 (Agotado)','Moldes 3D','🧸','Osito Kawaii','./assets/productos/202.jpg',202,false),
('Molde 3D Osito Calabaza','Unidad',22.0,'S/ 22.00','Moldes 3D','🧸','Osito Calabaza','./assets/productos/203.jpg',203,true),
('Molde 3D Osito Rosas','Unidad',20.0,'S/ 20.00','Moldes 3D','🧸','Osito Rosas','./assets/productos/204.jpg',204,true),
('Molde 3D Elefante 01','45 g',20.0,'S/ 20.00','Moldes 3D','🐘','Elefante 01','./assets/productos/205.jpg',205,true),
('Molde 3D Elefante 03','45 g',28.5,'S/ 28.50','Moldes 3D','🐘','Elefante 03','./assets/productos/206.jpg',206,true),
('Molde 3D Elefante 04','Unidad',45.0,'S/ 45.00','Moldes 3D','🐘','Elefante 04','./assets/productos/207.jpg',207,true),
('Molde 3D Elefante 05','Unidad',45.0,'S/ 45.00','Moldes 3D','🐘','Elefante 05','./assets/productos/208.jpg',208,true),
('Molde 3D Leoncito','35 g',20.0,'S/ 20.00','Moldes 3D','🦁','Leoncito','./assets/productos/209.jpg',209,true),
('Molde 3D Jirafa','45 g',28.0,'S/ 28.00','Moldes 3D','🦒','Jirafa','./assets/productos/210.jpg',210,true),
('Molde 3D Llamita','Unidad',15.0,'S/ 15.00','Moldes 3D','🦙','Llamita','./assets/productos/211.jpg',211,true),
('Molde 3D Mini Oveja','Unidad',10.0,'S/ 10.00','Moldes 3D','🐑','Mini Oveja','./assets/productos/212.jpg',212,true),
('Molde 3D Gatito','Unidad',18.0,'S/ 18.00','Moldes 3D','🐱','Gatito','./assets/productos/213.jpg',213,true),
('Molde 3D Oveja Kawaii','30 g',24.0,'S/ 24.00','Moldes 3D','🐑','Oveja Kawaii','./assets/productos/214.jpg',214,true),
('Molde 3D Búho','Unidad',20.0,'S/ 20.00','Moldes 3D','🦉','Búho','./assets/productos/215.jpg',215,true),
('Molde 3D Conejita','Unidad',20.0,'S/ 20.00','Moldes 3D','🐰','Conejita','./assets/productos/216.jpg',216,true),
('Molde 3D Chanchito 01','Unidad',22.0,'S/ 22.00','Moldes 3D','🐷','Chanchito 01','./assets/productos/217.jpg',217,true),
('Molde 3D Chanchito 03','Unidad',22.0,'S/ 22.00','Moldes 3D','🐷','Chanchito 03','./assets/productos/218.jpg',218,true),
('Molde 3D Vaca','Unidad',23.0,'S/ 23.00','Moldes 3D','🐮','Vaca','./assets/productos/219.jpg',219,true),
('Molde 3D Bebito 01','Unidad',35.0,'S/ 35.00','Moldes 3D','👶','Bebito 01','./assets/productos/220.jpg',220,true),
('Molde 3D Bebito 02','Unidad',45.0,'S/ 45.00','Moldes 3D','👶','Bebito 02','./assets/productos/221.jpg',221,true),
('Molde 3D Bebito 03','Unidad',45.0,'S/ 45.00','Moldes 3D','👶','Bebito 03','./assets/productos/222.jpg',222,true),
('Molde 3D Bebito 04','Unidad',24.0,'S/ 24.00','Moldes 3D','👶','Bebito 04','./assets/productos/223.jpg',223,true),
('Molde 3D Molde Angelito','38 g',20.0,'S/ 20.00','Moldes 3D','👼','Angelito','./assets/productos/224.jpg',224,true),
('Molde 3D Angelitos','Unidad',28.0,'S/ 28.00','Moldes 3D','👼','Angelitos','./assets/productos/225.jpg',225,true),
('Molde 3D Angelito Pequeño','Unidad',15.0,'S/ 15.00','Moldes 3D','👼','Angelito Pequeño','./assets/productos/226.jpg',226,true),
('Molde 3D Angelitos Grandes','Unidad',32.0,'S/ 32.00 c/u','Moldes 3D','👼','Angelitos Grandes','./assets/productos/227.jpg',227,true),
('Molde 3D Arándano','Unidad',20.0,'S/ 20.00','Moldes 3D','🫐','Arándano','./assets/productos/228.jpg',228,true),
('Molde 3D Frambuesa','Unidad',20.0,'S/ 20.00','Moldes 3D','🍓','Frambuesa','./assets/productos/229.jpg',229,true),
('Molde 3D Margarita','18 g',20.0,'S/ 20.00','Moldes 3D','🌼','Margarita','./assets/productos/230.jpg',230,true),
('Molde 3D Girasol','18 g',20.0,'S/ 20.00','Moldes 3D','🌻','Girasol','./assets/productos/231.jpg',231,true),
('Molde 3D Peonía Pequeña','Unidad',28.0,'S/ 28.00','Moldes 3D','🌸','Peonía Pequeña','./assets/productos/232.jpg',232,true),
('Molde 3D Flor','Unidad',20.0,'S/ 20.00','Moldes 3D','🌸','Flor','./assets/productos/233.jpg',233,true),
('Molde 3D Flor Navideña','Unidad',15.0,'S/ 15.00','Moldes 3D','🌺','Flor Navideña','./assets/productos/234.jpg',234,true),
('Molde 3D Mini Flores de Cerezo','Unidad',15.0,'S/ 15.00','Moldes 3D','🌸','Flores de Cerezo','./assets/productos/235.jpg',235,true),
('Molde 3D Corazón Tejido Pequeño','Unidad',16.0,'S/ 16.00','Moldes 3D','💖','Corazón Tejido','./assets/productos/236.jpg',236,true),
('Molde 3D Virgencita 01','Unidad',20.0,'S/ 20.00','Moldes 3D','🕯️','Virgencita 01','./assets/productos/237.jpg',237,true),
('Molde 3D Virgencita 02','Unidad',20.0,'S/ 20.00','Moldes 3D','🕯️','Virgencita 02','./assets/productos/238.jpg',238,true),
('Molde 3D Cubo Pequeño','45 g',25.0,'S/ 25.00','Moldes 3D','🧊','Cubo Pequeño','./assets/productos/239.jpg',239,true),
('Molde 3D Burbuja x6','120 g',32.0,'S/ 32.00','Moldes 3D','🫧','Burbuja x6','./assets/productos/240.jpg',240,true),
('Molde 3D Burbuja Corazón','140 g',35.0,'S/ 35.00','Moldes 3D','🫧','Burbuja Corazón','./assets/productos/241.jpg',241,true),
('Molde 3D Compromiso','Unidad',26.0,'S/ 26.00','Moldes 3D','💍','Compromiso','./assets/productos/242.jpg',242,true),
('Molde 3D Flor (18 soles)','Unidad',18.0,'S/ 18.00','Moldes 3D','🌸','Flor (18)','./assets/productos/243.jpg',243,true),
('Molde 3D Corazón Floral','Unidad',18.0,'S/ 18.00','Moldes 3D','💖','Corazón Floral','./assets/productos/244.jpg',244,true),
('Molde 3D Flor (60g)','60 g',20.0,'S/ 20.00','Moldes 3D','🌸','Flor (60g)','./assets/productos/245.jpg',245,true),
('Molde 3D Virgen 3D','Unidad',45.0,'S/ 45.00','Moldes 3D','🕯️','Virgen 3D','./assets/productos/246.jpg',246,true),
('Molde 3D Flor (48g)','48 g',20.0,'S/ 20.00 (Agotado)','Moldes 3D','🌸','Flor (48g)','./assets/productos/247.jpg',247,false),
('Molde 3D Cuerpo de Mujer','90 g',28.0,'S/ 28.00','Moldes 3D','🧍‍♀️','Cuerpo de Mujer','./assets/productos/248.jpg',248,true),
('Molde 3D Angel Mujer','80 g',25.0,'S/ 25.00 (Agotado)','Moldes 3D','👼','Angel Mujer','./assets/productos/249.jpg',249,false),
('Molde 3D Cruz','Unidad',22.0,'S/ 22.00','Moldes 3D','✝️','Cruz','./assets/productos/250.jpg',250,true),
('Molde 3D Mini Rosas','Unidad',15.0,'S/ 15.00 (Agotado)','Moldes 3D','🌹','Mini Rosas','./assets/productos/251.jpg',251,false),
('Molde 3D Mini Hojas de Acebo','Unidad',15.0,'S/ 15.00','Moldes 3D','🌿','Hojas de Acebo','./assets/productos/252.jpg',252,true),
('Molde 3D Diosa','Unidad',20.0,'S/ 20.00','Moldes 3D','🗽','Diosa','./assets/productos/253.jpg',253,true),
('Molde 3D Piecito con Mano','Unidad',28.0,'S/ 28.00','Moldes 3D','👣','Piecito con Mano','./assets/productos/254.jpg',254,true),
('Molde 3D Madre y BB','Unidad',28.0,'S/ 28.00','Moldes 3D','👩‍👦','Madre y BB','./assets/productos/255.jpg',255,true),
('Molde 3D Madre con Hija','Unidad',27.0,'S/ 27.00 (Agotada)','Moldes 3D','👩‍👧','Madre con Hija','./assets/productos/256.jpg',256,true),
('Molde 3D Mama y Bebe 2','Unidad',26.0,'S/ 26.00','Moldes 3D','👩‍👦','Mama y Bebe 2','./assets/productos/257.jpg',257,true),
('Molde 3D Rosa Espinal','Unidad',20.0,'S/ 20.00','Moldes 3D','🌹','Rosa Espinal','./assets/productos/258.jpg',258,true),
('Molde 3D Madre e Hijo','Unidad',18.0,'S/ 18.00 / S/ 28.00','Moldes 3D','👩‍👦','Madre e Hijo','./assets/productos/259.jpg',259,true),
('Molde 3D Buda 3D','Unidad',20.0,'S/ 20.00','Moldes 3D','🧘','Buda 3D','./assets/productos/260.jpg',260,true),
('Molde 3D Suculenta','Unidad',28.0,'S/ 28.00 (Agotado)','Moldes 3D','🪴','Suculenta','./assets/productos/261.jpg',261,false),
('Molde 3D Flor 05','Unidad',23.0,'S/ 23.00 (Agotado)','Moldes 3D','🌸','Flor 05','./assets/productos/262.jpg',262,false),
('Molde 3D Flor Cerámico','Unidad',18.0,'S/ 18.00','Moldes 3D','🌸','Flor Cerámico','./assets/productos/263.jpg',263,true),
('Molde 3D Conejito Cerámico','Unidad',24.0,'S/ 24.00','Moldes 3D','🐰','Conejito Cerámico','./assets/productos/264.jpg',264,true),
('Molde 3D Niña Graduada','75 g',45.0,'S/ 45.00','Moldes 3D','🎓','Niña Graduada','./assets/productos/265.jpg',265,true),
('Molde 3D Niño Graduado','75 g',50.0,'S/ 50.00','Moldes 3D','🎓','Niño Graduado','./assets/productos/266.jpg',266,true),
('Molde 3D Pastorcita','Unidad',32.0,'S/ 32.00','Moldes 3D','🐑','Pastorcita','./assets/productos/267.jpg',267,true),
('Molde 3D Niña con Ramo','Unidad',28.0,'S/ 28.00','Moldes 3D','💐','Niña con Ramo','./assets/productos/268.jpg',268,true),
('Molde 3D Taza Macetero','Unidad',25.0,'S/ 25.00','Moldes 3D','☕','Taza Macetero','./assets/productos/269.jpg',269,true),
('Molde 3D Corazón','Unidad',20.0,'S/ 20.00','Moldes 3D','❤️','Corazón','./assets/productos/270.jpg',270,true),
('Molde 3D Familia Navideña','Unidad',45.0,'S/ 45.00','Moldes 3D','🎄','Familia Navideña','./assets/productos/271.jpg',271,true),
('Molde 3D Santa Claus','Unidad',37.0,'S/ 37.00','Moldes 3D','🎅','Santa Claus','./assets/productos/272.jpg',272,true),
('Molde 3D Molde Deseo 2026','Unidad',25.0,'S/ 25.00 c/u','Moldes 3D','✨','Deseo 2026','./assets/productos/273.jpg',273,true),
('Molde 3D Árbol Navideño','65 g',25.0,'S/ 25.00','Moldes 3D','🎄','Árbol Navideño','./assets/productos/274.jpg',274,true),
('Molde 3D Molde Navideño','Unidad',15.0,'S/ 15.00 c/u','Moldes 3D','🎄','Navideño','./assets/productos/275.jpg',275,true),
('Molde 3D Árbol Navideño 03','Unidad',48.0,'S/ 48.00','Moldes 3D','🎄','Árbol Navideño 03','./assets/productos/276.jpg',276,true),
('Molde 3D Árbol Pequeño 01','Unidad',15.0,'S/ 15.00','Moldes 3D','🎄','Árbol Peq 01','./assets/productos/277.jpg',277,true),
('Molde 3D Árbol Geométrico','Unidad',15.0,'S/ 15.00','Moldes 3D','🎄','Árbol Geom','./assets/productos/278.jpg',278,true),
('Molde 3D Árbol Pequeño 02','Unidad',15.0,'S/ 15.00','Moldes 3D','🎄','Árbol Peq 02','./assets/productos/279.jpg',279,true),
('Molde 3D Árbol Geométrico Grande','Unidad',20.0,'S/ 20.00','Moldes 3D','🎄','Árbol Geom Gde','./assets/productos/280.jpg',280,true),
('Molde 3D Deseo x4','Unidad',65.0,'S/ 65.00','Moldes 3D','✨','Deseo x4','./assets/productos/281.jpg',281,true),
('Molde 3D Árbol Pequeño','Unidad',15.0,'S/ 15.00','Moldes 3D','🎄','Árbol Pequeño','./assets/productos/282.jpg',282,true),
('Molde 3D Osito Sentado 08','Unidad',20.0,'S/ 20.00 (Agotado)','Moldes 3D','🧸','Osito 08','./assets/productos/283.jpg',283,false),
('Molde 2D Rectangular x6','90 g',20.0,'S/ 20.00','Moldes 2D','🧼','Rectangular x6','./assets/productos/284.jpg',284,true),
('Molde 2D Rectangular x9','140 g',24.0,'S/ 24.00','Moldes 2D','🧼','Rectangular x9','./assets/productos/285.jpg',285,true),
('Molde 2D Cuadrado x6','Unidad',20.0,'S/ 20.00','Moldes 2D','🧼','Cuadrado x6','./assets/productos/286.jpg',286,true),
('Molde 2D Rectangular x4 con Diseño','Unidad',20.0,'S/ 20.00','Moldes 2D','🧼','Rect x4 Diseño','./assets/productos/287.jpg',287,true),
('Molde 2D Rectangular x6 con Diseño','100 g',22.0,'S/ 22.00','Moldes 2D','🧼','Rect x6 Diseño','./assets/productos/288.jpg',288,true),
('Molde 2D Ovalado x6','100 g',22.0,'S/ 22.00','Moldes 2D','🧼','Ovalado x6','./assets/productos/289.jpg',289,true),
('Molde 2D Oxagonal x6','80 g',22.0,'S/ 22.00','Moldes 2D','🧼','Oxagonal x6','./assets/productos/290.jpg',290,true),
('Molde 2D Árbol de Vida','120 g',23.0,'S/ 23.00','Moldes 2D','🌳','Árbol de Vida','./assets/productos/291.jpg',291,true),
('Molde 2D Angel x4','70 g',22.0,'S/ 22.00','Moldes 2D','👼','Angel x4','./assets/productos/292.jpg',292,true),
('Molde 2D Ovalado x6 (90g)','90 g',20.0,'S/ 20.00','Moldes 2D','🧼','Ovalado x6 90g','./assets/productos/293.jpg',293,true),
('Molde 2D Ovalados x4','100 g',20.0,'S/ 20.00','Moldes 2D','🧼','Ovalados x4','./assets/productos/294.jpg',294,true),
('Molde 2D Ovalados Pequeños','15 g',20.0,'S/ 20.00','Moldes 2D','🧼','Ovalados Pequeños','./assets/productos/295.jpg',295,true),
('Molde 2D Panal de Abeja','Unidad',18.0,'S/ 18.00','Moldes 2D','🍯','Panal de Abeja','./assets/productos/296.jpg',296,true),
('Molde 2D Figuras Variadas x6','Unidad',21.0,'S/ 21.00','Moldes 2D','🟢','Figuras Variadas','./assets/productos/297.jpg',297,true),
('Molde 2D Copo de Nieve','Unidad',19.0,'S/ 19.00','Moldes 2D','❄️','Copo de Nieve','./assets/productos/298.jpg',298,true),
('Molde 2D Figuras x4','80 g',23.0,'S/ 23.00 (Agotado)','Moldes 2D','🟢','Figuras x4','./assets/productos/299.jpg',299,false),
('Molde 2D Marino Variado','Unidad',20.0,'S/ 20.00','Moldes 2D','🌊','Marino Variado','./assets/productos/300.jpg',300,true),
('Molde 2D Rectangulares Pequeños','15 g',19.0,'S/ 19.00','Moldes 2D','🧼','Rectangulares Peq','./assets/productos/301.jpg',301,true),
('Molde 2D Masajeador Ovalado','120 g',22.0,'S/ 22.00','Moldes 2D','💆','Masajeador Ovalado','./assets/productos/302.jpg',302,true),
('Molde 2D Masajeador Redondo','80 g',20.0,'S/ 20.00','Moldes 2D','💆','Masajeador Redondo','./assets/productos/303.jpg',303,true),
('Molde 2D Masajeador Rectangular','100 g',20.0,'S/ 20.00','Moldes 2D','💆','Masajeador Rectangular','./assets/productos/304.jpg',304,true),
('Molde 2D Rosas x6','80 g',19.0,'S/ 19.00','Moldes 2D','🌹','Rosas 6','./assets/productos/305.jpg',305,true),
('Molde 2D Marino Variado (80g)','80 g',19.0,'S/ 19.00','Moldes 2D','🌊','Marino 80g','./assets/productos/306.jpg',306,true),
('Molde 2D Flores Redondas','90 g',19.5,'S/ 19.50','Moldes 2D','🌸','Flores Redondas','./assets/productos/307.jpg',307,true),
('Molde 2D Flores x6','Unidad',19.0,'S/ 19.00','Moldes 2D','🌸','Flores x6','./assets/productos/308.jpg',308,true),
('Molde 2D Flores Variadas','80 g',19.0,'S/ 19.00','Moldes 2D','🌸','Flores Variadas','./assets/productos/309.jpg',309,true),
('Molde 2D Flores k6','Unidad',19.0,'S/ 19.00 (Agotado)','Moldes 2D','🌸','Flores k6','./assets/productos/310.jpg',310,false),
('Molde 2D Rosas x6 (Sin peso)','Unidad',19.0,'S/ 19.00','Moldes 2D','🌹','Rosas x6','./assets/productos/311.jpg',311,true),
('Molde 2D Rosa y Tulipán x6','80 g',19.0,'S/ 19.00','Moldes 2D','🌷','Rosa y Tulipán','./assets/productos/312.jpg',312,true),
('Molde 2D Molde Hojas','Unidad',22.0,'S/ 22.00','Moldes 2D','🍃','Molde Hojas','./assets/productos/313.jpg',313,true),
('Molde 2D Corazones Rosado','Unidad',19.0,'S/ 19.00','Moldes 2D','❤️','Corazones Rosado','./assets/productos/314.jpg',314,true),
('Molde 2D Emojis Boquita','Unidad',18.0,'S/ 18.00','Moldes 2D','💋','Emojis Boquita','./assets/productos/315.jpg',315,true),
('Molde 2D Corazones Ones x6','Unidad',19.0,'S/ 19.00','Moldes 2D','❤️','Corazones Ones','./assets/productos/316.jpg',316,true),
('Molde 2D Corazones 2','Unidad',19.0,'S/ 19.00','Moldes 2D','❤️','Corazones 2','./assets/productos/317.jpg',317,true),
('Molde 2D Corazones con Lazo','Unidad',18.0,'S/ 18.00','Moldes 2D','💝','Corazones Lazo','./assets/productos/318.jpg',318,true),
('Molde 2D Corazones x6','Unidad',20.0,'S/ 20.00','Moldes 2D','❤️','Corazones x6','./assets/productos/319.jpg',319,true),
('Molde 2D Corazones 3','Unidad',19.0,'S/ 19.00 (Agotado)','Moldes 2D','❤️','Corazones 3','./assets/productos/320.jpg',320,false),
('Molde 2D Corazón Diamante','Unidad',20.0,'S/ 20.00','Moldes 2D','💎','Corazón Diamante','./assets/productos/321.jpg',321,true),
('Molde 2D Piñas Pequeñas','Unidad',14.0,'S/ 14.00','Moldes 2D','🍍','Piñas Pequeñas','./assets/productos/322.jpg',322,true),
('Molde 2D Tulipanes','60 g',20.0,'S/ 20.00','Moldes 2D','🌷','Tulipanes','./assets/productos/323.jpg',323,true),
('Molde 2D Manzana','65 g',19.0,'S/ 19.00','Moldes 2D','🍎','Manzana','./assets/productos/324.jpg',324,true),
('Molde 2D Concha x4','Unidad',15.0,'S/ 15.00','Moldes 2D','🐚','Concha x4','./assets/productos/325.jpg',325,true),
('Molde 2D Letras y Números','10 g',19.5,'S/ 19.50','Moldes 2D','🔠','Letras y Números','./assets/productos/326.jpg',326,true),
('Molde 2D Baby Shower','80 g',19.0,'S/ 19.00','Moldes 2D','🍼','Baby Shower','./assets/productos/327.jpg',327,true),
('Molde 2D Cruces','Unidad',19.0,'S/ 19.00','Moldes 2D','✝️','Cruces','./assets/productos/328.jpg',328,true),
('Molde 2D Trofeos','25 g',19.0,'S/ 19.00','Moldes 2D','🏆','Trofeos','./assets/productos/329.jpg',329,true),
('Molde 2D Donas x6','Unidad',17.0,'S/ 17.00','Moldes 2D','🍩','Donas x6','./assets/productos/330.jpg',330,true),
('Molde 2D Frutas Pequeñas','Unidad',14.0,'S/ 14.00','Moldes 2D','🍒','Frutas Pequeñas','./assets/productos/331.jpg',331,true),
('Molde 2D Corazón Diamante (15 soles)','Unidad',15.0,'S/ 15.00','Moldes 2D','💎','Corazón Diamante 15','./assets/productos/332.jpg',332,true),
('Molde 2D Huellitas','Unidad',19.0,'S/ 19.00','Moldes 2D','🐾','Huellitas','./assets/productos/333.jpg',333,true),
('Molde 2D Hello Kitty','Unidad',20.0,'S/ 20.00','Moldes 2D','🐱','Hello Kitty','./assets/productos/334.jpg',334,true),
('Molde 2D Molde Osito x6','Unidad',20.0,'S/ 20.00','Moldes 2D','🧸','Osito x6','./assets/productos/335.jpg',335,true),
('Molde 2D Safari','85 g',19.0,'S/ 19.00','Moldes 2D','🦁','Safari','./assets/productos/336.jpg',336,true),
('Molde 2D Capibara','Unidad',20.0,'S/ 20.00','Moldes 2D','🦦','Capibara','./assets/productos/337.jpg',337,true),
('Molde 2D Insectos','85 g',20.0,'S/ 20.00','Moldes 2D','🐞','Insectos','./assets/productos/338.jpg',338,true),
('Molde 2D Miembro','35 g',18.0,'S/ 18.00','Moldes 2D','🍆','Miembro','./assets/productos/339.jpg',339,true),
('Molde 2D Dinosaurios','Unidad',21.0,'S/ 21.00','Moldes 2D','🦖','Dinosaurios','./assets/productos/340.jpg',340,true),
('Molde 2D Dinosaurios (22 soles)','Unidad',22.0,'S/ 22.00 (Agotado)','Moldes 2D','🦖','Dinosaurios 22','./assets/productos/341.jpg',341,false),
('Molde 2D Abejas Variadas','Unidad',22.0,'S/ 22.00','Moldes 2D','🐝','Abejas Variadas','./assets/productos/342.jpg',342,true),
('Molde 2D Halloween','Unidad',20.0,'S/ 20.00','Moldes 2D','🎃','Halloween','./assets/productos/343.jpg',343,true),
('Molde 2D Calabazas','15 g',20.0,'S/ 20.00','Moldes 2D','🎃','Calabazas','./assets/productos/344.jpg',344,true),
('Molde 2D Fantasmas','15 g',20.0,'S/ 20.00','Moldes 2D','👻','Fantasmas','./assets/productos/345.jpg',345,true),
('Molde 2D Calaberas','Unidad',18.0,'S/ 18.00','Moldes 2D','💀','Calaberas','./assets/productos/346.jpg',346,true),
('Molde 2D Árbol de Navidad','Unidad',19.5,'S/ 19.50 (Agotado)','Moldes 2D','🎄','Árbol de Navidad','./assets/productos/347.jpg',347,false),
('Molde 2D Papanuel','Unidad',19.5,'S/ 19.50','Moldes 2D','🎅','Papanuel','./assets/productos/348.jpg',348,true),
('Molde 2D Molde Navideño','Unidad',19.5,'S/ 19.50','Moldes 2D','🎄','Navideño','./assets/productos/349.jpg',349,true),
('Molde 2D Maceta Oxagonal','60 g',19.5,'S/ 19.50','Macetas','🪴','Maceta Oxagonal','./assets/productos/350.jpg',350,true),
('Molde 2D Maceta Cuadrado','60 g',19.5,'S/ 19.50','Macetas','🪴','Maceta Cuadrado','./assets/productos/351.jpg',351,true),
('Molde 2D Maceta Corazón','60 g',19.5,'S/ 19.50','Macetas','🪴','Maceta Corazón','./assets/productos/352.jpg',352,true),
('Molde 2D Círculo x 6','Unidad',19.5,'S/ 19.50','Macetas','🪴','Círculo x 6','./assets/productos/353.jpg',353,true),
('Molde 2D Maceta Círculo','60 g',19.5,'S/ 19.50','Macetas','🪴','Maceta Círculo','',354,true),
('Molde 2D Flor de Loto','Unidad',38.0,'S/ 38.00','Moldes 2D','🪷','Flor de Loto','',355,true),
('Molde 2D Mano de Buda','80 g',19.5,'S/ 19.50','Moldes 2D','🪬','Mano de Buda','',356,true),
('Molde 2D Mascotas','Unidad',19.5,'S/ 19.50','Moldes 2D','🐶','Mascotas','',357,true),
('Molde 2D Molde Figuras (Aromatizador)','Unidad',23.0,'S/ 23.00','Moldes 2D','🌬️','Molde Figuras','',358,true),
('Moldes para Chocolates','Unidad / 3 unid.',14.0,'S/ 14.00 / S/ 10.00 c/u','Moldes para Chocolates','🍫','Chocolates','',359,true),
('Moldes para Gomita','Unidad / 3 unid.',14.0,'S/ 14.00 / S/ 10.00 c/u','Moldes para Gomita','🍬','Gomitas','',360,true),
('Cera de soja','Alta fusión · 1 kg',42.0,'S/ 42.00','Ceras para velas','🕯️','Soja alta fusión','',361,true),
('Cera de soja','Alta fusión · 500 g',22.0,'S/ 22.00','Ceras para velas','🕯️','Soja alta fusión','',362,true),
('Cera de soja','Baja fusión · 1 kg',40.0,'S/ 40.00','Ceras para velas','🕯️','Soja baja fusión','',363,true),
('Cera de soja','Baja fusión · 500 g',20.0,'S/ 20.00','Ceras para velas','🕯️','Soja baja fusión','',364,true),
('Fragancia 250 ml · Coco','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Coco 250 ml','',365,true),
('Fragancia 250 ml · Jazmín','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Jazmín 250 ml','',366,true),
('Fragancia 250 ml · Vainilla','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Vainilla 250 ml','',367,true),
('Fragancia 250 ml · Rosas','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Rosas 250 ml','',368,true),
('Fragancia 250 ml · Lavanda','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Lavanda 250 ml','',369,true),
('Fragancia 250 ml · Eucalipto','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Eucalipto 250 ml','',370,true),
('Fragancia 250 ml · Miel','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Miel 250 ml','',371,true),
('Fragancia 250 ml · Naranja','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Naranja 250 ml','',372,true),
('Fragancia 250 ml · Maracuyá','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Maracuyá 250 ml','',373,true),
('Fragancia 250 ml · Uva','250 ml · Mayor desde 3 unidades',48.0,'S/ 48.00 · Mayor S/ 41.00','Fragancias 250 ml','🌸','Uva 250 ml','',374,true),
('Envase para vela · 250 ml','Vidrio ámbar · tapa negra · Mayor desde 6',7.5,'S/ 7.50 c/u','Envases para velas','🫙','Envase 250 ml ámbar','',375,true),
('Envase para vela · 220 ml','Colores surtidos · tapa dorada · Mayor desde 6',9.5,'S/ 9.50 c/u','Envases para velas','🫙','Envase 220 ml color','',376,true),
('Envase para vela · 185 ml','Vidrio · tapa dorada · Mayor desde 6',10.0,'S/ 10.00 c/u','Envases para velas','🫙','Envase 185 ml','',377,true),
('Envase para vela · 220 ml','Vidrio surtido · tapa de madera · Mayor desde 6',9.5,'S/ 9.50 c/u','Envases para velas','🫙','Envase 220 ml madera','',378,true),
('Envase para vela · 150 ml','Vidrio ámbar · tapa gris · Mayor desde 6',7.5,'S/ 7.50 c/u','Envases para velas','🫙','Envase 150 ml','',379,true),
('Envase para vela · 315 ml','Vidrio transparente · tapa dorada · Mayor desde 6',10.0,'S/ 10.00 c/u','Envases para velas','🫙','Envase 315 ml dorado','',380,true),
('Envase para vela · 350 ml','Vidrio · tapa bambú · Mayor desde 6',11.0,'S/ 11.00 c/u','Envases para velas','🫙','Envase 350 ml bambú','',381,true),
('Envase para vela · 210 ml','Vidrio con tapa · Mayor desde 6',12.0,'S/ 12.00 c/u','Envases para velas','🫙','Envase 210 ml','',382,true),
('Envase para vela · 250 ml','Vidrio decorativo con tapa · Mayor desde 6',10.0,'S/ 10.00 c/u','Envases para velas','🫙','Envase 250 ml decorativo','',383,true),
('Envase para vela · 80 ml','Vidrio cuadrado · Mayor desde 6',6.5,'S/ 6.50 c/u','Envases para velas','🫙','Envase 80 ml','',384,true),
('Envase para vela · 100 ml','Vidrio ámbar · tapa dorada · Mayor desde 6',6.5,'S/ 6.50 c/u','Envases para velas','🫙','Envase 100 ml dorado','',385,true),
('Envase para vela · 100 ml','Vidrio transparente · tapa corcho · Mayor desde 6',6.5,'S/ 6.50 c/u','Envases para velas','🫙','Envase 100 ml corcho','',386,true),
('Envase para vela · 60 ml','Vidrio · Mayor desde 6',6.5,'S/ 6.50 c/u','Envases para velas','🫙','Envase 60 ml','',387,true),
('Envase para vela · 100 ml','Vidrio transparente · tapa dorada · Mayor desde 6',5.9,'S/ 5.90 c/u','Envases para velas','🫙','Envase 100 ml dorado económico','',388,true),
('Envase para vela · 200 ml','Vidrio transparente · tapa dorada · Mayor desde 6',7.0,'S/ 7.00 c/u','Envases para velas','🫙','Envase 200 ml','',389,true),
('Envase para vela · 400 ml','Vidrio transparente · tapa dorada · Mayor desde 6',11.0,'S/ 11.00 c/u','Envases para velas','🫙','Envase 400 ml','',390,true),
('Envase para vela · 315 ml','Colores surtidos · tapa bambú · Mayor desde 6',10.0,'S/ 10.00 c/u','Envases para velas','🫙','Envase 315 ml color','',391,true);

-- Después de crear tu usuario en Authentication, ejecuta:
-- insert into public.admin_users (user_id) values ('UUID-DEL-USUARIO');


-- JABONERIA OCEAN · MIGRACIÓN DE APARIENCIA
-- Ejecutar UNA sola vez en Supabase SQL Editor. No reemplaza setup.sql.

create table if not exists public.site_settings (
  id integer primary key default 1,
  logo_url text not null default '',
  background_url text not null default '',
  announcement_enabled boolean not null default true,
  announcement_title text not null default 'Formas de pago y envío',
  announcement_subtitle text not null default 'Compra de forma fácil y segura. Coordinamos contigo el método de pago y la agencia de envío.',
  announcement_payments jsonb not null default '["💜 Yape","💙 Plin","🏦 BCP","📱 Banca móvil","💳 Tarjetas"]'::jsonb,
  announcement_shipping jsonb not null default '["📦 Shalom","📦 Marvisur","🤝 Otra agencia previa coordinación"]'::jsonb,
  hero_slides jsonb not null default '[{"image":"./assets/hero/slide1.jpg","eyebrow":"🌸 Aromas y fragancias","title":"El aroma que hace\\nespecial cada creación.","text":"Descubre fragancias para jabones, velas y proyectos artesanales."},{"image":"./assets/hero/slide2.jpg","eyebrow":"🧼 Moldes y accesorios","title":"Todo empieza con\\nun buen molde.","text":"Moldes 2D, 3D y accesorios para crear jabones."},{"image":"./assets/hero/slide3.jpg","eyebrow":"🌿 Aceites y complementos","title":"Crea productos que\\nse sientan increíbles.","text":"Aceites, extractos y complementos para tus fórmulas."}]'::jsonb,
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

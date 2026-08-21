-- JABONERIA OCEAN · V2 HOMEPAGE / ADMIN / ESTADISTICAS
-- Ejecutar UNA VEZ después de setup.sql y upgrade_catalog.sql.

alter table public.products
  add column if not exists sales_count integer not null default 0;

alter table public.site_settings
  add column if not exists announcement_enabled boolean not null default true,
  add column if not exists announcement_title text not null default 'Formas de pago y envío',
  add column if not exists announcement_subtitle text not null default 'Compra de forma fácil y segura. Coordinamos contigo el método de pago y la agencia de envío.',
  add column if not exists announcement_payments jsonb not null default '["💜 Yape","💙 Plin","🏦 BCP","📱 Banca móvil","💳 Tarjetas"]'::jsonb,
  add column if not exists announcement_shipping jsonb not null default '["📦 Shalom","📦 Marvisur","🤝 Otra agencia previa coordinación"]'::jsonb,
  add column if not exists hero_slides jsonb not null default '[{"image":"./assets/hero/slide1.jpg","eyebrow":"🌸 Aromas y fragancias","title":"El aroma que hace\\nespecial cada creación.","text":"Descubre fragancias para jabones, velas y proyectos artesanales. Encuentra aromas florales, frutales, dulces y mucho más."},{"image":"./assets/hero/slide2.jpg","eyebrow":"🧼 Moldes y accesorios","title":"Todo empieza con\\nun buen molde.","text":"Moldes 2D, 3D y accesorios para crear jabones con acabados únicos. Explora nuestro catálogo y encuentra tu próximo diseño."},{"image":"./assets/hero/slide3.jpg","eyebrow":"🌿 Aceites y complementos","title":"Crea productos que\\nse sientan increíbles.","text":"Aceites esenciales, aceites vegetales, extractos y complementos para darle un toque especial a tus fórmulas."}]'::jsonb;

insert into public.site_settings (id) values (1) on conflict (id) do nothing;

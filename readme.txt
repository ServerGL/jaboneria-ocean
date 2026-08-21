JABONERIA OCEAN · VERSIÓN CON ADMIN

Esta carpeta mantiene la tienda actual y añade un panel /admin conectado a Supabase.

ARCHIVOS IMPORTANTES
- index.html: tienda pública.
- admin.html: panel de administración.
- config.js: URL + Publishable/anon key de Supabase.
- supabase-client.js: conexión.
- setup.sql: tablas, seguridad, almacenamiento y catálogo inicial.
- _redirects: permite entrar en /admin.
- assets/: logo, fondo e imágenes del catálogo.

PRIMERO configura Supabase siguiendo README_ADMIN.txt.

ACTUALIZACIÓN 15/08/2026
- El catálogo ya no queda atascado en “Cargando catálogo...”.
- El filtro de categorías tiene selector visible y botones rápidos.
- El número de orden al crear productos fue retirado: el sistema asigna el orden automáticamente.
- Para habilitar Kits/Combos ejecuta una sola vez upgrade_kits.sql en Supabase.

ACTUALIZACIÓN V2 · 19/08/2026
- Las categorías circulares de la portada ahora tienen flechas para desplazarse y ver todas las categorías.
- La portada muestra un anuncio de bienvenida con X para cerrar, incluyendo Yape, Plin, BCP, banca móvil, Shalom y Marvisur.
- Desde Admin puedes editar/activar/desactivar ese anuncio.
- Desde Admin puedes cambiar las 3 imágenes y textos del carrusel de portada.
- Las estadísticas ahora incluyen productos más vendidos. Como los pedidos se confirman por WhatsApp, las ventas confirmadas se registran manualmente con el botón “＋ Venta” del producto.

MIGRACIÓN V2 OBLIGATORIA
1. Abre Supabase → SQL Editor.
2. Ejecuta UNA VEZ el archivo homepage_admin_upgrade.sql.
3. No reemplaza setup.sql ni upgrade_catalog.sql; es una migración adicional.
4. Luego sube esta versión completa de la carpeta a tu sitio.


V7 - WhatsApp: se cambió el enlace de wa.me a api.whatsapp.com/send para evitar el problema de emojis que algunos navegadores/WhatsApp Desktop muestran como � durante la redirección.

JABONERIA OCEAN · PANEL ADMINISTRADOR

IMPORTANTE: esta versión ya contiene el panel, pero debes conectar Supabase antes de usarlo.

1) En Supabase > SQL Editor > New query, pega TODO el contenido de setup.sql y pulsa Run.
2) En Supabase > Authentication > Users, crea el usuario administrador con correo y contraseña.
   Ejemplo de correo: admin@jaboneriaocean.com
3) Copia el UUID de ese usuario.
4) En SQL Editor ejecuta:
   insert into public.admin_users (user_id) values ('UUID-DEL-USUARIO');
5) Abre config.js y coloca la URL del proyecto y la Publishable/anon key.
   NO uses una secret/service_role key.
6) Sube toda esta carpeta a Netlify.
7) El panel estará en: https://TU-SITIO.netlify.app/admin

FUNCIONES DEL PANEL
- Iniciar sesión con Supabase Auth.
- Crear productos.
- Editar nombre, categoría, presentación y precio.
- Cambiar imagen desde PC o celular.
- Marcar disponible/agotado.
- Subir/bajar productos.
- Eliminar productos.
- Buscar productos.

NOTA SOBRE LAS IMÁGENES INICIALES
El catálogo actual conserva las imágenes locales numeradas de la web. Las imágenes nuevas que subas desde el panel se guardan en Supabase Storage.

SEGURIDAD
- No pongas la Secret/service_role key en config.js.
- La tabla products permite lectura pública, pero solo usuarios incluidos en admin_users pueden modificarla.
- El bucket product-images permite lectura pública y escritura solo a administradores.

ADVERTENCIA SQL
setup.sql incluye el catálogo inicial y hace DELETE FROM public.products antes de insertarlo. Ejecuta setup.sql una sola vez sobre un proyecto nuevo o sin productos.


APARIENCIA
----------
En /admin ahora puedes cambiar el logo y el fondo desde el celular o PC.
Antes de usar esta función en un proyecto Supabase ya creado, ejecuta una sola vez appearance_migration.sql en SQL Editor.
Los archivos se guardan en Storage > product-images > appearance y la tienda pública los carga automáticamente.
No necesitas reemplazar logo.png ni fondo.jpg para los cambios nuevos.

KITS Y COMBOS · ACTUALIZACIÓN
- Ejecuta upgrade_kits.sql una sola vez después de setup.sql y upgrade_catalog.sql.
- En Admin aparecerá la sección “Kits y combos”.
- Puedes crear/editar nombre, descripción, emoji, precios, imagen, estado y productos incluidos.
- El orden de los kits también se puede cambiar con ↑ ↓.
- Al crear un producto nuevo ya no tienes que escribir “Orden”; el sistema lo asigna automáticamente al final de su categoría.

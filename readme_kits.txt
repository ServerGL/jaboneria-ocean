JABONERIA OCEAN · KITS Y ORDEN AUTOMÁTICO

1. El catálogo público ya corrige el error que dejaba "Cargando catálogo...".
2. El filtro ahora tiene un selector de categoría visible y botones rápidos.
3. Al crear un producto desde Admin ya NO tienes que colocar número de orden.
   - El sistema lo coloca automáticamente al final de su categoría.
   - Las flechas ↑ ↓ siguen permitiendo cambiar la posición después.
4. Para activar los Kits/Combos, ejecuta una sola vez upgrade_kits.sql en Supabase.
5. Después de ejecutar el SQL, entra a /admin y aparecerá "Kits y combos".
6. Desde allí puedes crear, editar, ocultar, eliminar y reordenar kits.
7. Cada kit puede tener nombre, descripción, emoji, precio, precio anterior,
   imagen, estado y productos incluidos con sus cantidades.

NO vuelvas a ejecutar setup.sql sobre una instalación que ya tiene productos.

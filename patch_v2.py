from pathlib import Path
import json

root=Path('/mnt/data/sitework2')
idx=root/'index.html'
admin=root/'admin.html'
setup=root/'setup.sql'

s=idx.read_text(encoding='utf-8')

# CSS additions before first responsive block.
marker='@media(max-width:900px){.featureGrid{grid-template-columns:repeat(2,1fr)}'
css=r'''
/* ===== V2: CATEGORIAS DESLIZABLES + ANUNCIO + CONFIG DINAMICA ===== */
.categoryViewport{position:relative;padding:0 42px}
.categoryCircles{scroll-behavior:smooth;overscroll-behavior-x:contain}
.categoryNav{position:absolute;top:50%;transform:translateY(-50%);z-index:3;width:38px;height:38px;border-radius:50%;border:1px solid #eadbe5;background:#fff;color:#ef2d8f;box-shadow:0 8px 22px rgba(40,30,45,.12);font-size:25px;line-height:1;cursor:pointer;display:grid;place-items:center}
.categoryNav:hover{background:#fff4fa;transform:translateY(-50%) scale(1.04)}
.categoryNav.prev{left:0}.categoryNav.next{right:0}
.categoryFade{position:absolute;top:0;bottom:0;width:42px;pointer-events:none;z-index:2}.categoryFade.left{left:42px;background:linear-gradient(90deg,#fff,transparent)}.categoryFade.right{right:42px;background:linear-gradient(270deg,#fff,transparent)}
.announcementModal{position:fixed;inset:0;background:rgba(23,19,18,.72);display:none;place-items:center;padding:22px;z-index:100;backdrop-filter:blur(3px)}
.announcementModal.show{display:grid}.announcementBox{position:relative;width:min(920px,100%);border-radius:24px;overflow:hidden;background:linear-gradient(135deg,#f05287,#df4b78);color:#fff;box-shadow:0 30px 90px rgba(0,0,0,.34)}
.announcementClose{position:absolute;right:14px;top:12px;width:38px;height:38px;border:0;border-radius:50%;background:rgba(0,0,0,.24);color:#fff;font-size:25px;z-index:3;cursor:pointer}
.announcementInner{display:grid;grid-template-columns:1.05fr .95fr;min-height:390px}.announcementMain{padding:38px 40px 34px}.announcementMain h2{font-size:34px;line-height:1.05;margin:0 0 10px;letter-spacing:-1px}.announcementMain>p{margin:0 0 22px;color:#fff4f8;line-height:1.55}.announcementSection{background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.22);border-radius:18px;padding:15px 16px;margin-top:12px}.announcementSection h3{margin:0 0 9px;font-size:14px}.announcementItems{display:flex;flex-wrap:wrap;gap:8px}.announcementPill{background:#fff;color:#2c3640;border-radius:999px;padding:8px 11px;font-weight:900;font-size:12px;box-shadow:0 4px 12px rgba(0,0,0,.08)}.announcementAside{background:rgba(255,255,255,.10);padding:38px 32px;display:flex;flex-direction:column;justify-content:center}.announcementAside .payTitle{background:#111;border-radius:12px;padding:10px 15px;display:inline-block;font-weight:1000;letter-spacing:.4px;margin-bottom:14px;align-self:flex-start}.announcementAside .paymentGrid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px}.paymentCard{background:#fff;border-radius:16px;padding:16px;color:#273541;text-align:center;font-weight:900;min-height:74px;display:flex;align-items:center;justify-content:center;box-shadow:0 7px 18px rgba(0,0,0,.10)}.paymentCard strong{font-size:18px}.paymentCard small{display:block;font-size:10px;color:#6d7b85;margin-top:3px}.announcementFooter{font-size:11px;color:#ffe7ef;margin-top:14px}
.adminHeroGrid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}.heroAdminCard{border:1px solid var(--line);border-radius:16px;padding:13px;background:#fbfeff}.heroAdminCard h3{margin:0 0 8px;font-size:14px}.heroAdminPreview{width:100%;height:115px;object-fit:cover;border-radius:12px;border:1px solid var(--line);background:#eef6f9;margin-bottom:10px}.heroAdminCard input,.heroAdminCard textarea{width:100%;border:1px solid var(--line);border-radius:10px;padding:9px;background:#fff;margin-bottom:8px}.heroAdminCard textarea{min-height:66px;resize:vertical}.configGrid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:16px}.configCard{background:#fff;border:1px solid var(--line);border-radius:18px;padding:18px}.configCard h3{margin:0 0 5px}.configCard p{margin:0 0 14px;color:var(--muted);font-size:12px}.announcePreview{background:linear-gradient(135deg,#f05287,#df4b78);color:#fff;border-radius:15px;padding:18px;min-height:160px}.announcePreview h4{margin:0 0 8px;font-size:20px}.announcePreview p{color:#fff4f8;font-size:12px;line-height:1.45}
@media(max-width:800px){.announcementInner{grid-template-columns:1fr}.announcementAside{padding:22px 26px}.adminHeroGrid,.configGrid{grid-template-columns:1fr 1fr}}
@media(max-width:650px){.categoryViewport{padding:0 32px}.categoryNav{width:32px;height:32px;font-size:21px}.categoryFade.left{left:32px;width:28px}.categoryFade.right{right:32px;width:28px}.announcementModal{padding:12px}.announcementMain{padding:28px 22px 22px}.announcementMain h2{font-size:28px}.announcementAside{padding:20px 22px}.announcementBox{max-height:92vh;overflow:auto}.adminHeroGrid{grid-template-columns:1fr}.paymentCard{min-height:64px}.announcementFooter{margin-bottom:3px}}
'''
if marker in s and '/* ===== V2:' not in s:
    s=s.replace(marker,css+'\n'+marker,1)

# Replace category HTML wrapper.
old='<div class="categoryCircles" id="categoryCircles"></div>'
new='''<div class="categoryViewport"><button class="categoryNav prev" onclick="scrollCategories(-1)" aria-label="Ver categorías anteriores">‹</button><div class="categoryFade left"></div><div class="categoryCircles" id="categoryCircles"></div><div class="categoryFade right"></div><button class="categoryNav next" onclick="scrollCategories(1)" aria-label="Ver más categorías">›</button></div>'''
s=s.replace(old,new,1)

# Insert announcement modal immediately after main opening.
anchor='<main id="inicio">'
modal='''<div class="announcementModal" id="announcementModal" role="dialog" aria-modal="true" aria-labelledby="announcementTitle"><div class="announcementBox"><button class="announcementClose" onclick="closeAnnouncement()" aria-label="Cerrar anuncio">×</button><div class="announcementInner"><div class="announcementMain"><h2 id="announcementTitle">Formas de pago y envío</h2><p id="announcementSubtitle">Compra de forma fácil y segura. Coordinamos contigo el método de pago y la agencia de envío.</p><div class="announcementSection"><h3>💳 Formas de pago</h3><div class="announcementItems" id="announcementPayments"><span class="announcementPill">💜 Yape</span><span class="announcementPill">💙 Plin</span><span class="announcementPill">🏦 BCP</span><span class="announcementPill">📱 Banca móvil</span><span class="announcementPill">💳 Tarjetas</span></div></div><div class="announcementSection"><h3>🚚 Formas de envío</h3><div class="announcementItems" id="announcementShipping"><span class="announcementPill">📦 Shalom</span><span class="announcementPill">📦 Marvisur</span><span class="announcementPill">🤝 Otra agencia previa coordinación</span></div></div></div><div class="announcementAside"><span class="payTitle">PAGA COMO PREFIERAS</span><div class="paymentGrid"><div class="paymentCard"><div><strong>Yape</strong><small>Pago móvil</small></div></div><div class="paymentCard"><div><strong>Plin</strong><small>Pago móvil</small></div></div><div class="paymentCard"><div><strong>BCP</strong><small>Transferencia</small></div></div><div class="paymentCard"><div><strong>📱 Banca móvil</strong><small>Desde tu app bancaria</small></div></div></div><div class="announcementFooter">Los datos exactos de pago y el costo de envío se coordinan antes de confirmar tu pedido.</div></div></div></div></div>'''
s=s.replace(anchor,anchor+modal,1)

# Replace category CSS sizes? Keep 94. User asked smaller, already 94; arrows make usable. Reduce desktop slightly to 88.
s=s.replace('.categoryCircle .circleImg{width:94px;height:94px;', '.categoryCircle .circleImg{width:88px;height:88px;',1)
s=s.replace('.categoryCircle{flex:0 0 112px;', '.categoryCircle{flex:0 0 108px;',1)

# Add JS homepage config before hero functions.
anchor_js='/* ===== HERO + CATEGORIAS CIRCULARES ===== */'
config_js=r'''/* ===== HOMEPAGE CONFIG / ANUNCIO ===== */
const DEFAULT_HOMEPAGE_CONFIG={
  announcement_enabled:true,
  announcement_title:'Formas de pago y envío',
  announcement_subtitle:'Compra de forma fácil y segura. Coordinamos contigo el método de pago y la agencia de envío.',
  announcement_payments:['💜 Yape','💙 Plin','🏦 BCP','📱 Banca móvil','💳 Tarjetas'],
  announcement_shipping:['📦 Shalom','📦 Marvisur','🤝 Otra agencia previa coordinación'],
  hero_slides:[
    {image:'./assets/hero/slide1.jpg',eyebrow:'🌸 Aromas y fragancias',title:'El aroma que hace\nespecial cada creación.',text:'Descubre fragancias para jabones, velas y proyectos artesanales. Encuentra aromas florales, frutales, dulces y mucho más.'},
    {image:'./assets/hero/slide2.jpg',eyebrow:'🧼 Moldes y accesorios',title:'Todo empieza con\nun buen molde.',text:'Moldes 2D, 3D y accesorios para crear jabones con acabados únicos. Explora nuestro catálogo y encuentra tu próximo diseño.'},
    {image:'./assets/hero/slide3.jpg',eyebrow:'🌿 Aceites y complementos',title:'Crea productos que\nse sientan increíbles.',text:'Aceites esenciales, aceites vegetales, extractos y complementos para darle un toque especial a tus fórmulas.'}
  ]
};
let homepageConfig=JSON.parse(JSON.stringify(DEFAULT_HOMEPAGE_CONFIG));
function escAttr(v){return escHtml(v).replace(/\\/g,'&#92;').replace(/'/g,'&#39;').replace(/"/g,'&quot;');}
function showAnnouncement(){const m=document.getElementById('announcementModal');if(!m)return;if(homepageConfig.announcement_enabled!==false){m.classList.add('show');document.body.style.overflow='hidden';}}
function closeAnnouncement(){const m=document.getElementById('announcementModal');if(m)m.classList.remove('show');document.body.style.overflow='';sessionStorage.setItem('oceanAnnouncementClosed','1');}
function renderAnnouncement(){
  const title=document.getElementById('announcementTitle'),sub=document.getElementById('announcementSubtitle');
  if(title)title.textContent=homepageConfig.announcement_title||DEFAULT_HOMEPAGE_CONFIG.announcement_title;
  if(sub)sub.textContent=homepageConfig.announcement_subtitle||DEFAULT_HOMEPAGE_CONFIG.announcement_subtitle;
  const pay=document.getElementById('announcementPayments'),ship=document.getElementById('announcementShipping');
  if(pay)pay.innerHTML=(homepageConfig.announcement_payments||[]).map(x=>`<span class="announcementPill">${escHtml(x)}</span>`).join('');
  if(ship)ship.innerHTML=(homepageConfig.announcement_shipping||[]).map(x=>`<span class="announcementPill">${escHtml(x)}</span>`).join('');
}
function applyHeroConfig(){
  const slides=[...document.querySelectorAll('.heroSlide')];
  (homepageConfig.hero_slides||[]).slice(0,3).forEach((cfg,i)=>{const el=slides[i];if(!el)return;const img=cfg.image||DEFAULT_HOMEPAGE_CONFIG.hero_slides[i].image;el.style.backgroundImage=`url("${String(img).replace(/"/g,'\\"')}")`;const eyebrow=el.querySelector('.eyebrow'),h1=el.querySelector('h1'),p=el.querySelector('p');if(eyebrow)eyebrow.textContent=cfg.eyebrow||'';if(h1)h1.innerHTML=escHtml(cfg.title||'').replace(/\n/g,'<br>');if(p)p.textContent=cfg.text||'';});
}
function scrollCategories(direction){const box=document.getElementById('categoryCircles');if(box)box.scrollBy({left:direction*Math.max(260,box.clientWidth*.72),behavior:'smooth'});}
function refreshCategoryArrows(){const box=document.getElementById('categoryCircles');if(!box)return;const wrap=box.parentElement;const prev=wrap?.querySelector('.categoryNav.prev'),next=wrap?.querySelector('.categoryNav.next');const can=box.scrollWidth>box.clientWidth+8;if(prev)prev.style.display=can?'grid':'none';if(next)next.style.display=can?'grid':'none';}
'''
s=s.replace(anchor_js,config_js+'\n'+anchor_js,1)

# Load config with appearance: replace function body.
start=s.index('async function loadSiteAppearance(){')
end=s.index('\n}\n\nasync function loadCloudProducts()',start)+2
new_func=r'''async function loadSiteAppearance(){
  try{
    let data=null;
    if(window.supabaseClient){
      const res=await window.supabaseClient.from('site_settings').select('*').eq('id',1).maybeSingle();
      if(!res.error) data=res.data;
    }
    if(data){
      const logo=data.logo_url;
      if(logo)document.querySelectorAll('img[src*="assets/logo.png"]').forEach(img=>{img.src=logo;});
      if(data.background_url){document.body.style.backgroundImage=`linear-gradient(rgba(232,246,251,.78),rgba(220,239,247,.86)), url("${data.background_url}")`;document.body.style.backgroundPosition='center top';document.body.style.backgroundSize='cover';document.body.style.backgroundAttachment=window.matchMedia('(max-width:650px)').matches?'scroll':'fixed';document.body.style.backgroundRepeat='no-repeat';}
      if(data.hero_slides) homepageConfig.hero_slides=Array.isArray(data.hero_slides)?data.hero_slides:homepageConfig.hero_slides;
      if(typeof data.announcement_enabled==='boolean') homepageConfig.announcement_enabled=data.announcement_enabled;
      if(data.announcement_title) homepageConfig.announcement_title=data.announcement_title;
      if(data.announcement_subtitle) homepageConfig.announcement_subtitle=data.announcement_subtitle;
      if(Array.isArray(data.announcement_payments)) homepageConfig.announcement_payments=data.announcement_payments;
      if(Array.isArray(data.announcement_shipping)) homepageConfig.announcement_shipping=data.announcement_shipping;
    }
  }catch(e){console.warn('No se pudo cargar la configuración de la tienda. Se usan valores locales.',e);}
  renderAnnouncement();applyHeroConfig();
  if(homepageConfig.announcement_enabled!==false && sessionStorage.getItem('oceanAnnouncementClosed')!=='1') setTimeout(showAnnouncement,500);
}'''
s=s[:start]+new_func+s[end:]

# Make category rendering refresh arrows and resize observer.
s=s.replace("  box.innerHTML=ordered.map(c=>{const src=imageMap[c]||'./assets/logo.png';const isActive=categoryKey(c)===categoryKey(active);return `<button", "  box.innerHTML=ordered.map(c=>{const src=imageMap[c]||'./assets/logo.png';const isActive=categoryKey(c)===categoryKey(active);return `<button",1)
s=s.replace("}).join('');\n}\nfunction chooseCategory", "}).join('');\n  requestAnimationFrame(refreshCategoryArrows);\n}\nfunction chooseCategory",1)
s=s.replace("function startHeroExperience(){heroRestart();", "function startHeroExperience(){heroRestart();window.addEventListener('resize',refreshCategoryArrows,{passive:true});",1)

# Add sales_count in product mapping (extra array index 14).
s=s.replace("Number(p.old_price || 0), Number(p.view_count || 0), Number(p.cart_count || 0)", "Number(p.old_price || 0), Number(p.view_count || 0), Number(p.cart_count || 0), Number(p.sales_count || 0)",1)

idx.write_text(s,encoding='utf-8')

# SQL migration.
mig=root/'homepage_admin_upgrade.sql'
mig.write_text(r'''-- JABONERIA OCEAN · V2 HOMEPAGE / ADMIN / ESTADISTICAS
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
''',encoding='utf-8')

# Update setup.sql definitions so fresh installs include V2 fields.
ss=setup.read_text(encoding='utf-8')
ss=ss.replace("  updated_at timestamptz not null default now()\n);", "  updated_at timestamptz not null default now(),\n  sales_count integer not null default 0\n);",1)
# The above replacement likely targets products; site_settings remains later. Add fields there.
old_site="  background_url text not null default '',\n  updated_at timestamptz not null default now(),"
new_site="  background_url text not null default '',\n  announcement_enabled boolean not null default true,\n  announcement_title text not null default 'Formas de pago y envío',\n  announcement_subtitle text not null default 'Compra de forma fácil y segura. Coordinamos contigo el método de pago y la agencia de envío.',\n  announcement_payments jsonb not null default '[\"💜 Yape\",\"💙 Plin\",\"🏦 BCP\",\"📱 Banca móvil\",\"💳 Tarjetas\"]'::jsonb,\n  announcement_shipping jsonb not null default '[\"📦 Shalom\",\"📦 Marvisur\",\"🤝 Otra agencia previa coordinación\"]'::jsonb,\n  hero_slides jsonb not null default '[{\"image\":\"./assets/hero/slide1.jpg\",\"eyebrow\":\"🌸 Aromas y fragancias\",\"title\":\"El aroma que hace\\\\nespecial cada creación.\",\"text\":\"Descubre fragancias para jabones, velas y proyectos artesanales.\"},{\"image\":\"./assets/hero/slide2.jpg\",\"eyebrow\":\"🧼 Moldes y accesorios\",\"title\":\"Todo empieza con\\\\nun buen molde.\",\"text\":\"Moldes 2D, 3D y accesorios para crear jabones.\"},{\"image\":\"./assets/hero/slide3.jpg\",\"eyebrow\":\"🌿 Aceites y complementos\",\"title\":\"Crea productos que\\\\nse sientan increíbles.\",\"text\":\"Aceites, extractos y complementos para tus fórmulas.\"}]'::jsonb,\n  updated_at timestamptz not null default now(),"
ss=ss.replace(old_site,new_site,1)
setup.write_text(ss,encoding='utf-8')

# ADMIN modifications.
a=admin.read_text(encoding='utf-8')
# CSS additions.
admin_css=r'''
/* ===== V2 HOMEPAGE CONFIG + VENTAS ===== */
.salesBtn{color:#087c47!important;font-weight:900}.adminHelp{padding:10px 12px;border-radius:11px;background:#eef8fd;color:#4d6b7d;font-size:11px;line-height:1.45;margin-top:10px}.toggleLine{display:flex;align-items:center;gap:8px;font-size:12px;font-weight:800;margin:10px 0}.configCard .btn{margin-top:4px}
'''
a=a.replace('</style></head>',admin_css+'</style></head>',1)
# Insert config sections after appearance section close (first </section> after appearance).
appearance_end=a.index('</section>',a.index('<section class="appearance">'))+len('</section>')
config_html='''
<section class="appearance"><h2>📢 Anuncio de bienvenida</h2><p>Este anuncio aparece al entrar a la tienda. Puedes activar/desactivar, cambiar el texto y actualizar las formas de pago y envío.</p><div class="configGrid"><div class="configCard"><div class="toggleLine"><input id="announcementEnabled" type="checkbox"> Mostrar anuncio al entrar</div><div class="field"><label>Título</label><input id="announcementTitleInput" placeholder="Formas de pago y envío"></div><div class="field"><label>Texto</label><textarea id="announcementSubtitleInput" rows="3" placeholder="Compra de forma fácil y segura..."></textarea></div><div class="field"><label>Formas de pago · una por línea</label><textarea id="announcementPaymentsInput" rows="5" placeholder="💜 Yape\n💙 Plin\n🏦 BCP\n📱 Banca móvil\n💳 Tarjetas"></textarea></div><div class="field"><label>Formas de envío · una por línea</label><textarea id="announcementShippingInput" rows="4" placeholder="📦 Shalom\n📦 Marvisur\n🤝 Otra agencia previa coordinación"></textarea></div><button class="btn primary" onclick="saveAnnouncementConfig()">💾 Guardar anuncio</button></div><div class="configCard"><h3>Vista previa</h3><div class="announcePreview"><h4 id="announcementPreviewTitle">Formas de pago y envío</h4><p id="announcementPreviewText">Compra de forma fácil y segura.</p><div style="font-weight:900;font-size:12px">💳 Yape · Plin · BCP · Banca móvil</div><div style="font-weight:900;font-size:12px;margin-top:8px">🚚 Shalom · Marvisur</div></div><div id="homepageMsg" class="success"></div></div></div></section>
<section class="appearance"><h2>🖼️ Carrusel principal</h2><p>Administra las 3 imágenes del carrusel que aparece a pantalla completa en la portada. También puedes cambiar el texto de cada slide.</p><div class="adminHeroGrid" id="heroAdminGrid"></div><div style="display:flex;justify-content:flex-end;margin-top:12px"><button class="btn primary" onclick="saveHeroConfig()">💾 Guardar carrusel</button></div></section>
'''
a=a[:appearance_end]+config_html+a[appearance_end:]
# Change analytics cards and top products container.
old_analytics='''<section class="analytics"><h2 style="margin:0 0 5px">📊 Estadísticas</h2><p style="margin:0;color:var(--muted);font-size:12px">Interacciones registradas desde la tienda pública. El historial de búsquedas no se muestra en el panel.</p><div class="analyticsGrid"><div class="analyticsCard"><b id="statVisits">0</b><span>Visitas</span></div><div class="analyticsCard"><b id="statViews">0</b><span>Productos vistos</span></div><div class="analyticsCard"><b id="statCart">0</b><span>Agregados al carrito</span></div><div class="analyticsCard"><b id="statWhats">0</b><span>Clics en WhatsApp</span></div><div class="analyticsCard"><b id="statSearch">0</b><span>Búsquedas</span></div></div><div id="topProducts" class="topProducts"></div></section>'''
new_analytics='''<section class="analytics"><h2 style="margin:0 0 5px">📊 Estadísticas mejoradas</h2><p style="margin:0;color:var(--muted);font-size:12px">Aquí puedes ver el rendimiento de la tienda. “Más vendidos” se actualiza cuando registras ventas confirmadas desde la tabla de productos.</p><div class="analyticsGrid"><div class="analyticsCard"><b id="statVisits">0</b><span>Visitas</span></div><div class="analyticsCard"><b id="statViews">0</b><span>Productos vistos</span></div><div class="analyticsCard"><b id="statCart">0</b><span>Agregados al carrito</span></div><div class="analyticsCard"><b id="statWhats">0</b><span>Clics en WhatsApp</span></div><div class="analyticsCard"><b id="statSearch">0</b><span>Búsquedas</span></div></div><div id="topProducts" class="topProducts"></div><div id="topCartProducts" class="topProducts"></div></section>'''
a=a.replace(old_analytics,new_analytics,1)
# Modify row to include sales button. Find exact actions tail.
old_tail='''<button onclick="toggleAvailable('${p.id}')">${p.available?'🚫 Agotar':'🟢 Activar'}</button><button onclick="deleteProduct('${p.id}')">🗑️</button>'''
new_tail='''<button onclick="toggleAvailable('${p.id}')">${p.available?'🚫 Agotar':'🟢 Activar'}</button><button class="salesBtn" onclick="registerSale('${p.id}')">＋ Venta</button><button onclick="deleteProduct('${p.id}')">🗑️</button>'''
a=a.replace(old_tail,new_tail,1)
# Add sales count in name line.
a=a.replace("${p.featured?'<span class=\"badge badgeFeatured\">⭐ DESTACADO</span>':''}</div>", "${p.featured?'<span class=\"badge badgeFeatured\">⭐ DESTACADO</span>':''}<span class=\"badge\" style=\"background:#e8f8ef;color:#087c47\">🛍️ Ventas: ${Number(p.sales_count||0)}</span></div>",1)
# Replace loadRows function select to include sales already select * no issue. Add render stats via sales count.
# Replace loadAnalytics function.
start=a.index('async function loadAnalytics(){')
end=a.index('\n(async()=>',start)
new_an=r'''async function loadAnalytics(){
  try{
    ensureClient();
    const {data:events,error}=await supabaseClient.from('store_events').select('event_type,product_id,query,created_at');
    if(error)throw error;
    const ev=events||[];
    $('statVisits').textContent=ev.filter(x=>x.event_type==='page_view').length;
    $('statViews').textContent=ev.filter(x=>x.event_type==='product_view').length;
    $('statCart').textContent=ev.filter(x=>x.event_type==='add_to_cart').length;
    $('statWhats').textContent=ev.filter(x=>x.event_type==='whatsapp_click').length;
    $('statSearch').textContent=ev.filter(x=>x.event_type==='search').length;
    const sold=rows.filter(p=>Number(p.sales_count||0)>0).sort((a,b)=>Number(b.sales_count||0)-Number(a.sales_count||0)).slice(0,6);
    $('topProducts').innerHTML='<div style="grid-column:1/-1;font-weight:900;color:#16344b;margin-top:4px">🏆 Más vendidos (ventas confirmadas)</div>'+ (sold.length?sold.map(p=>`<div class="topProduct"><b>${esc(p.name)}</b><span>${Number(p.sales_count||0)} unidades vendidas</span></div>`).join(''):'<div class="empty">Aún no has registrado ventas confirmadas.</div>');
    const counts={};ev.filter(x=>x.event_type==='add_to_cart'&&x.product_id).forEach(x=>counts[x.product_id]=(counts[x.product_id]||0)+1);
    const topCart=Object.entries(counts).sort((a,b)=>b[1]-a[1]).slice(0,6);
    $('topCartProducts').innerHTML='<div style="grid-column:1/-1;font-weight:900;color:#16344b;margin-top:10px">🛒 Más agregados al carrito</div>'+ (topCart.length?topCart.map(([id,n])=>{const p=rows.find(x=>x.id===id);return `<div class="topProduct"><b>${esc(p?p.name:'Producto')}</b><span>${n} veces agregado</span></div>`}).join(''):'<div class="empty">Todavía no hay datos suficientes del carrito.</div>');
  }catch(e){console.warn('analytics',e);}
}
async function registerSale(id){
  try{
    ensureClient();
    const p=rows.find(x=>x.id===id);if(!p)return;
    const qty=Math.max(1,Number(prompt(`¿Cuántas unidades de "${p.name}" se vendieron?`,'1')||0));
    if(!qty)return;
    const {error}=await supabaseClient.from('products').update({sales_count:Number(p.sales_count||0)+qty}).eq('id',id);
    if(error)throw error;
    await loadRows();await loadAnalytics();
  }catch(e){alert(e.message||String(e));}
}
'''
a=a[:start]+new_an+a[end:]
# Add homepage config JS before loadAppearance.
anchor='async function loadAppearance(){'
config_admin=r'''let homepageAdminConfig={announcement_enabled:true,announcement_title:'',announcement_subtitle:'',announcement_payments:[],announcement_shipping:[],hero_slides:[]};
const defaultHeroAdmin=[
 {image:'./assets/hero/slide1.jpg',eyebrow:'🌸 Aromas y fragancias',title:'El aroma que hace\nespecial cada creación.',text:'Descubre fragancias para jabones, velas y proyectos artesanales.'},
 {image:'./assets/hero/slide2.jpg',eyebrow:'🧼 Moldes y accesorios',title:'Todo empieza con\nun buen molde.',text:'Moldes 2D, 3D y accesorios para crear jabones.'},
 {image:'./assets/hero/slide3.jpg',eyebrow:'🌿 Aceites y complementos',title:'Crea productos que\nse sientan increíbles.',text:'Aceites, extractos y complementos para tus fórmulas.'}
];
function renderHomepageAdmin(){
 $('announcementEnabled').checked=homepageAdminConfig.announcement_enabled!==false;
 $('announcementTitleInput').value=homepageAdminConfig.announcement_title||'Formas de pago y envío';
 $('announcementSubtitleInput').value=homepageAdminConfig.announcement_subtitle||'';
 $('announcementPaymentsInput').value=(homepageAdminConfig.announcement_payments||[]).join('\n');
 $('announcementShippingInput').value=(homepageAdminConfig.announcement_shipping||[]).join('\n');
 $('announcementPreviewTitle').textContent=$('announcementTitleInput').value;
 $('announcementPreviewText').textContent=$('announcementSubtitleInput').value;
 const slides=homepageAdminConfig.hero_slides?.length?homepageAdminConfig.hero_slides:defaultHeroAdmin;
 $('heroAdminGrid').innerHTML=slides.slice(0,3).map((h,i)=>`<div class="heroAdminCard"><h3>Slide ${i+1}</h3><img id="heroPreview${i}" class="heroAdminPreview" src="${esc(h.image||defaultHeroAdmin[i].image)}"><input id="heroEyebrow${i}" value="${esc(h.eyebrow||'')}" placeholder="Etiqueta"><input id="heroTitle${i}" value="${esc(h.title||'')}" placeholder="Título (usa salto de línea)"><textarea id="heroText${i}" placeholder="Descripción">${esc(h.text||'')}</textarea><input id="heroFile${i}" type="file" accept="image/*" onchange="previewHeroAdmin(${i},event)"></div>`).join('');
}
function previewHeroAdmin(i,e){const f=e.target.files[0];if(f)$('heroPreview'+i).src=URL.createObjectURL(f);}
async function uploadAdminImage(file,path){const ext=(file.name.split('.').pop()||'jpg').toLowerCase().replace(/[^a-z0-9]/g,'')||'jpg';const final=`homepage/${path}-${Date.now()}.${ext}`;const {error}=await supabaseClient.storage.from('product-images').upload(final,file,{upsert:false,contentType:file.type});if(error)throw error;return supabaseClient.storage.from('product-images').getPublicUrl(final).data.publicUrl;}
async function saveAnnouncementConfig(){try{ensureClient();const payload={id:1,announcement_enabled:$('announcementEnabled').checked,announcement_title:$('announcementTitleInput').value.trim(),announcement_subtitle:$('announcementSubtitleInput').value.trim(),announcement_payments:$('announcementPaymentsInput').value.split(/\n+/).map(x=>x.trim()).filter(Boolean),announcement_shipping:$('announcementShippingInput').value.split(/\n+/).map(x=>x.trim()).filter(Boolean)};const {error}=await supabaseClient.from('site_settings').upsert(payload,{onConflict:'id'});if(error)throw error;homepageAdminConfig={...homepageAdminConfig,...payload};showHomepageMsg('Anuncio guardado correctamente.');}catch(e){showHomepageMsg(e.message,true);}}
async function saveHeroConfig(){try{ensureClient();const base=homepageAdminConfig.hero_slides?.length?homepageAdminConfig.hero_slides:defaultHeroAdmin;const out=[];for(let i=0;i<3;i++){let image=base[i]?.image||defaultHeroAdmin[i].image;const file=$('heroFile'+i).files[0];if(file)image=await uploadAdminImage(file,'hero-'+(i+1));out.push({image,eyebrow:$('heroEyebrow'+i).value.trim(),title:$('heroTitle'+i).value.trim(),text:$('heroText'+i).value.trim()});}const {error}=await supabaseClient.from('site_settings').upsert({id:1,hero_slides:out},{onConflict:'id'});if(error)throw error;homepageAdminConfig.hero_slides=out;showHomepageMsg('Carrusel guardado correctamente.');renderHomepageAdmin();}catch(e){showHomepageMsg(e.message,true);}}
function showHomepageMsg(msg,isError=false){const el=$('homepageMsg');el.style.display='block';el.textContent=msg;el.style.color=isError?'var(--red)':'var(--green)';el.style.background=isError?'#fff0f3':'#e8f8ef';setTimeout(()=>el.style.display='none',4500);}
'''
a=a.replace(anchor,config_admin+anchor,1)
# Replace loadAppearance with more robust config loading; keep logo/bg logic.
start=a.index('async function loadAppearance(){')
end=a.index('\nfunction previewAppearance',start)
new_load=r'''async function loadAppearance(){
  ensureClient();
  const {data,error}=await supabaseClient.from('site_settings').select('*').eq('id',1).maybeSingle();
  if(error)throw error;
  if(data){
    $('logoPreview').src=data.logo_url||'./assets/logo.png';$('bgPreview').src=data.background_url||'./assets/fondo.jpg';
    homepageAdminConfig={announcement_enabled:data.announcement_enabled!==false,announcement_title:data.announcement_title||'Formas de pago y envío',announcement_subtitle:data.announcement_subtitle||'',announcement_payments:Array.isArray(data.announcement_payments)?data.announcement_payments:[],announcement_shipping:Array.isArray(data.announcement_shipping)?data.announcement_shipping:[],hero_slides:Array.isArray(data.hero_slides)?data.hero_slides:defaultHeroAdmin};
    renderHomepageAdmin();
  }else{renderHomepageAdmin();}
}'''
a=a[:start]+new_load+a[end:]
# Ensure loadRows analytics after row load.
a=a.replace('async function loadRows(){ensureClient();const {data,error}=await supabaseClient.from(\'products\').select(\'*\').order(\'sort_order\',{ascending:true});if(error)throw error;rows=data||[];renderRows();fillCategories();}', "async function loadRows(){ensureClient();const {data,error}=await supabaseClient.from('products').select('*').order('sort_order',{ascending:true});if(error)throw error;rows=data||[];renderRows();fillCategories();try{await loadAnalytics();}catch(e){console.warn(e);}}",1)
admin.write_text(a,encoding='utf-8')

print('patched')

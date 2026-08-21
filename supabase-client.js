window.supabaseClient = null;
(function(){
  const c = window.SUPABASE_CONFIG || {};
  if (window.supabase && c.url && c.key && !c.url.includes('TU-PROYECTO') && !c.key.includes('TU_PUBLISHABLE')) {
    window.supabaseClient = window.supabase.createClient(c.url, c.key);
  }
})();

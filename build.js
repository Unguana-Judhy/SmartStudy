// Gera public/index.html a partir de src/index.html, injectando as variáveis de ambiente do Vercel.
const fs = require('fs');
const url = (process.env.SUPABASE_URL || '').trim();
const key = (process.env.SUPABASE_ANON_KEY || '').trim();

const fail = (msg) => { console.error('\nERRO DE CONFIGURAÇÃO: ' + msg + '\n'); process.exit(1); };
if (!/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(url)) fail('SUPABASE_URL em falta ou inválido. Deve ter o formato https://xxxx.supabase.co (Vercel > Settings > Environment Variables).');
if (key.length < 40) fail('SUPABASE_ANON_KEY em falta ou demasiado curta. Use a chave pública "anon" / "publishable" do Supabase.');
if (/service_role/i.test(key)) fail('Esta parece ser a chave service_role. Nunca a use no navegador. Use a chave "anon" / "publishable".');
try {
  const payload = JSON.parse(Buffer.from(key.split('.')[1] || '', 'base64').toString('utf8'));
  if (payload && payload.role === 'service_role') fail('Esta é a chave service_role. Use a chave "anon" / "publishable".');
} catch (e) { /* chaves no formato novo (sb_publishable_...) não são JWT */ }

let html = fs.readFileSync('src/index.html', 'utf8');
const a = "const SUPABASE_URL='COLE_AQUI_O_URL_DO_PROJECTO';";
const b = "const SUPABASE_ANON_KEY='COLE_AQUI_A_CHAVE_ANON';";
if (!html.includes(a) || !html.includes(b)) fail('Não encontrei as linhas de configuração em src/index.html.');
html = html.replace(a, "const SUPABASE_URL=" + JSON.stringify(url.replace(/\/$/, '')) + ";")
           .replace(b, "const SUPABASE_ANON_KEY=" + JSON.stringify(key) + ";");
fs.mkdirSync('public', { recursive: true });
fs.writeFileSync('public/index.html', html);
console.log('OK: public/index.html criado (' + Math.round(html.length / 1024) + ' KB).');

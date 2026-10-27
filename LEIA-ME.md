# SmartStudy no Vercel (com Supabase)

Esta pasta é um projecto pronto para o Vercel. As chaves do Supabase não vão dentro do ficheiro: configura-as no painel do Vercel, e o próprio Vercel monta a página no momento do deploy.

```
smartstudy-vercel/
  src/index.html        a app (modelo, sem chaves)
  build.js              junta as chaves à app durante o deploy e recusa chaves erradas
  vercel.json           configuração do Vercel + cabeçalhos de segurança
  package.json
  supabase_schema.sql   tabelas e regras de privacidade do Supabase
```

## 1. Supabase (uma só vez)
1. Em supabase.com crie um projecto (**New project**).
2. **SQL Editor > New query**: cole o conteúdo de `supabase_schema.sql` e clique em **Run**.
3. **Project Settings > API**: guarde o **Project URL** e a chave pública (**anon** / **publishable**). Nunca use a `service_role`.
4. **Authentication > Providers > Email**: mantenha **Confirm email** ligado e defina a palavra-passe mínima como 8.

## 2. Pôr o código no GitHub
1. Crie uma conta em github.com e um repositório novo (**New repository**), por exemplo `smartstudy`.
2. Clique em **uploading an existing file** e arraste **todo o conteúdo** desta pasta (inclui `src`, `build.js`, `vercel.json`, `package.json`, `.gitignore`). Confirme com **Commit changes**.

## 3. Vercel
1. Em vercel.com entre com o GitHub e clique em **Add New > Project**. Escolha o repositório `smartstudy`.
2. Em **Framework Preset** deixe **Other**. Não mude os comandos: o `vercel.json` já os define.
3. Abra **Environment Variables** e crie duas variáveis (para Production, Preview e Development):
   - `SUPABASE_URL` = o Project URL (por exemplo `https://abcd1234.supabase.co`)
   - `SUPABASE_ANON_KEY` = a chave pública anon / publishable
4. Clique em **Deploy**. No fim recebe um endereço como `https://smartstudy-xxxx.vercel.app`.

Se o deploy falhar com "ERRO DE CONFIGURAÇÃO", a mensagem diz o que falta (variável em falta, URL no formato errado ou chave `service_role`). Corrija a variável em **Settings > Environment Variables** e faça **Redeploy**.

## 4. Dizer ao Supabase qual é o endereço
Em **Authentication > URL Configuration**:
- **Site URL**: o endereço do Vercel (ou o seu domínio próprio).
- **Redirect URLs**: adicione o mesmo endereço. Se quiser que as versões de teste do Vercel também funcionem, adicione também o padrão `https://*.vercel.app/**` (menos restritivo, use por sua conta).

Sem isto, os links dos emails de confirmação e de recuperação não voltam para a app.

## 5. Emails
O envio incluído no Supabase serve só para testes e tem um limite muito baixo. Antes de divulgar, configure um serviço de email em **Authentication > SMTP Settings** (por exemplo Resend ou Brevo). Confirme os limites actuais na documentação.

## 6. Domínio próprio (opcional)
No Vercel, **Settings > Domains > Add**. Depois actualize o **Site URL** e as **Redirect URLs** no Supabase para o novo domínio.

## 7. Testar antes de divulgar
1. Crie uma conta com um email seu e confirme-o pelo link.
2. Preencha o perfil, crie uma disciplina e carregue um material.
3. Saia e entre de novo; abra noutro dispositivo. Os dados devem estar lá.
4. Use "Esqueci a palavra-passe": o email deve chegar e a nova palavra-passe deve funcionar.
5. Crie uma segunda conta e confirme que não vê os dados da primeira.

## Actualizar a app mais tarde
Substitua `src/index.html` no GitHub. O Vercel volta a publicar sozinho.

## Notas
- Fotos e imagens não são lidas automaticamente nesta versão. Excel, CSV e PDF com texto são.
- A página carrega a biblioteca do Supabase de cdn.jsdelivr.net (versão fixa 2.45.4). Os cabeçalhos de segurança do `vercel.json` só permitem esse endereço, o Supabase e as fontes do Google.
- Antes de ir a público, escreva uma nota curta de privacidade e verifique as condições do plano gratuito do Supabase e do Vercel (limites, pausa de projectos inactivos).

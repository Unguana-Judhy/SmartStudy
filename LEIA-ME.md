# SmartStudy no Vercel (com Supabase)

Esta pasta é um projecto pronto para o Vercel. As chaves do Supabase não vão dentro do ficheiro: configura-as no painel do Vercel, e o próprio Vercel monta a página no momento do deploy.

```
smartstudy-vercel/
  src/index.html        a app (modelo, sem chaves)
  api/read.js           leitura de documentos e imagens por IA (função do Vercel)
  build.js              junta as chaves à app durante o deploy e recusa chaves erradas
  vercel.json           configuração do Vercel + cabeçalhos de segurança
  package.json
  supabase_schema.sql   tabelas e regras de privacidade do Supabase
```

## O que há de novo nesta versão
- Cursos com 1 a 20 semestres. Em Disciplinas há o botão **+ Semestre** e a opção de remover o último semestre, se estiver vazio. Em Definições também se altera a duração.
- Em Materiais, todas as disciplinas aparecem na lista, agrupadas por semestre, mesmo sem estarem inscritas.
- Registo: mensagens claras quando o servidor limita pedidos, pausa de 60 segundos e botão para reenviar o email de confirmação.
- Leitura por IA de documentos e imagens em Disciplinas e Horário (ver a secção **Leitura por IA** mais abaixo).

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

### Se o registo de contas falhar com "muitos pedidos"
Isto vem do Supabase, não da app. Há dois limites diferentes:
- **Envio de emails.** O envio incluído no Supabase é só para testes e permite muito poucos emails por hora, para o projecto todo. Cada registo e cada recuperação de palavra-passe gasta um. Solução: configure o seu próprio serviço de email (SMTP) em **Authentication > SMTP Settings** (por exemplo Resend ou Brevo). Depois, em **Authentication > Rate Limits**, pode subir o limite de emails enviados por hora.
- **Pedidos por ligação.** O Supabase limita os registos e entradas por endereço de internet. Se muitas pessoas testam na mesma rede (uma universidade, por exemplo), partilham o mesmo endereço e esgotam o limite. Em **Authentication > Rate Limits** pode aumentar o limite de registos e entradas. Os nomes dos menus podem variar um pouco, e os valores por defeito mudam com o tempo, por isso confira na documentação.
- **Solução rápida, com custo:** em **Authentication > Providers > Email**, desligue **Confirm email**. O registo deixa de enviar email e a pessoa entra logo. O custo é que qualquer pessoa pode registar-se com um email que não é seu, e a recuperação de palavra-passe só funciona se o email estiver certo.

Enquanto o limite estiver esgotado, a app mostra a mensagem e bloqueia o botão durante 60 segundos.

## 6. Domínio próprio (opcional)
No Vercel, **Settings > Domains > Add**. Depois actualize o **Site URL** e as **Redirect URLs** no Supabase para o novo domínio.

## 7. Leitura por IA (opcional)
Com a IA ligada, as páginas Disciplinas e Horário leem também fotos, capturas de ecrã e PDF difíceis. Excel, CSV e PDF com texto continuam a ser lidos primeiro no próprio navegador, de graça. A IA só entra quando isso não chega, ou quando a pessoa clica em **Reconhecer com IA**. O resultado é sempre mostrado para confirmar antes de importar.

Como activar:
1. Crie uma conta em console.anthropic.com e uma **chave de API**. A utilização é paga por leitura. Defina um limite de gasto mensal na própria conta Anthropic.
2. No Vercel, em **Settings > Environment Variables**, crie `ANTHROPIC_API_KEY` com essa chave. Opcional: `ANTHROPIC_MODEL` para escolher o modelo (por omissão `claude-haiku-5-5`, que é o mais barato; se o nome mudar, defina aqui o nome correcto).
3. No Supabase, corra de novo o `supabase_schema.sql` (o bloco 3 cria o contador diário). Por omissão cada pessoa pode fazer **20 leituras por IA por dia**. Para mudar, altere o número 20 no SQL e corra outra vez.
4. No Vercel, faça **Redeploy**.

Como está protegido: a chave fica só no servidor e nunca vai para o navegador. Só quem tem sessão válida pode usar a IA, e o limite diário é aplicado no servidor. Fotos grandes são reduzidas antes de seguirem. Se a chave não estiver definida, a app esconde o botão e funciona sem IA.

## 8. Testar antes de divulgar
1. Crie uma conta com um email seu e confirme-o pelo link.
2. Preencha o perfil, crie uma disciplina e carregue um material.
3. Saia e entre de novo; abra noutro dispositivo. Os dados devem estar lá.
4. Use "Esqueci a palavra-passe": o email deve chegar e a nova palavra-passe deve funcionar.
5. Crie uma segunda conta e confirme que não vê os dados da primeira.
6. Se activou a IA: carregue uma foto de um horário e confirme que as aulas aparecem para confirmar.

## Actualizar a app mais tarde
Substitua `src/index.html` no GitHub. O Vercel volta a publicar sozinho.

## Notas
- Sem a IA activada, as fotos e imagens não são lidas. Excel, CSV e PDF com texto são sempre lidos.
- A página carrega a biblioteca do Supabase de cdn.jsdelivr.net (versão fixa 2.45.4). Os cabeçalhos de segurança do `vercel.json` só permitem esse endereço, o Supabase e as fontes do Google.
- Antes de ir a público, escreva uma nota curta de privacidade e verifique as condições do plano gratuito do Supabase e do Vercel (limites, pausa de projectos inactivos).

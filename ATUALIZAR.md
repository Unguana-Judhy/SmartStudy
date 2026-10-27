# Como actualizar o site sem erros

O Vercel publica o que está no GitHub. Se o GitHub não mudou, o site não muda.

## Estrutura certa no GitHub (raiz do repositório)
    build.js   package.json   vercel.json   supabase_schema.sql   .gitignore   LEIA-ME.md
    src/index.html      <- a aplicação. É ESTE ficheiro que se substitui.

## Substituir a aplicação (pelo site do GitHub)
1. Abra o repositório e clique na pasta **src**.
2. Dentro de `src`: **Add file > Upload files**, arraste o novo `index.html` (o nome tem de ser exactamente `index.html`).
3. Em baixo, **Commit changes** (escolha "Commit directly to the main branch").
4. Confirme: dentro de `src`, o `index.html` deve mostrar "Latest commit … agora/minutos" e o tamanho novo.
   Se o ficheiro foi enviado para a raiz, e não para `src`, o site NÃO muda.

## Confirmar no Vercel
Projecto > **Deployments**: deve aparecer um deploy novo, com o texto do seu commit, no estado **Ready**.
Se falhar, clique nele e leia as linhas acima de `Error:` no log.

## Confirmar que o site é a versão nova
Abra o site, carregue em Ctrl+U (ver código) e procure `smartstudy-versao`.
Versão actual: `2026-10-27-b`. Se vir outra, o site ainda tem uma versão antiga: faça Ctrl+F5.

## Se estragou alguma coisa
No Vercel, em **Deployments**, escolha um deploy antigo que funcionava > ⋯ > **Promote to Production** (ou Instant Rollback).
No GitHub, abra `src/index.html` > **History** e use **...** > "Revert" para voltar a uma versão anterior.

## Criação de contas: "limite de emails"
O Supabase gratuito só envia poucos emails por hora com o serviço incluído. Para muitas contas novas:
- Authentication > **SMTP Settings**: configure um serviço de email (Resend ou Brevo, ambos têm plano gratuito).
- Depois, em Authentication > **Rate Limits**, pode aumentar o limite de emails por hora.
- Para testar sem email: Authentication > Providers > Email > desligue **Confirm email** (contas ficam activas logo; menos seguro, volte a ligar antes de divulgar).

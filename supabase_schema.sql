-- SmartStudy: esquema para o Supabase
-- Como usar: Supabase > SQL Editor > New query > cole tudo > Run.
-- Pode ser executado mais de uma vez sem estragar nada.

-- 1) Dados de cada utilizador (uma linha por conta)
create table if not exists public.app_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;
revoke all on public.app_state from anon;

drop policy if exists "app_state: ler os proprios dados"     on public.app_state;
drop policy if exists "app_state: criar os proprios dados"   on public.app_state;
drop policy if exists "app_state: alterar os proprios dados" on public.app_state;
drop policy if exists "app_state: apagar os proprios dados"  on public.app_state;

create policy "app_state: ler os proprios dados" on public.app_state
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "app_state: criar os proprios dados" on public.app_state
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "app_state: alterar os proprios dados" on public.app_state
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "app_state: apagar os proprios dados" on public.app_state
  for delete to authenticated using ((select auth.uid()) = user_id);

-- 2) Ficheiros dos materiais (pasta privada, maximo 3 MB por ficheiro)
insert into storage.buckets (id, name, public, file_size_limit)
values ('materials', 'materials', false, 3145728)
on conflict (id) do update set public = false, file_size_limit = 3145728;

drop policy if exists "materials: ler os proprios ficheiros"     on storage.objects;
drop policy if exists "materials: enviar os proprios ficheiros"  on storage.objects;
drop policy if exists "materials: alterar os proprios ficheiros" on storage.objects;
drop policy if exists "materials: apagar os proprios ficheiros"  on storage.objects;

-- cada utilizador so acede a ficheiros dentro da pasta com o seu proprio id
create policy "materials: ler os proprios ficheiros" on storage.objects
  for select to authenticated
  using (bucket_id = 'materials' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "materials: enviar os proprios ficheiros" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'materials' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "materials: alterar os proprios ficheiros" on storage.objects
  for update to authenticated
  using (bucket_id = 'materials' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'materials' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "materials: apagar os proprios ficheiros" on storage.objects
  for delete to authenticated
  using (bucket_id = 'materials' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- 3) Limite diário da leitura por IA (usado por api/read.js)
-- Para mudar o limite, altere o número 20 abaixo e volte a correr este bloco.
create table if not exists public.ai_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  day     date not null default ((now() at time zone 'utc')::date),
  n       int  not null default 0,
  primary key (user_id, day)
);
alter table public.ai_usage enable row level security;   -- sem políticas: ninguém lê nem escreve directamente
revoke all on public.ai_usage from anon, authenticated;

create or replace function public.use_ai() returns boolean
language plpgsql security definer set search_path = public as $$
declare
  cur int;
begin
  if auth.uid() is null then return false; end if;
  insert into public.ai_usage (user_id, day, n)
  values (auth.uid(), (now() at time zone 'utc')::date, 1)
  on conflict (user_id, day) do update set n = public.ai_usage.n + 1
    where public.ai_usage.n < 20
  returning n into cur;
  return cur is not null;
end $$;

revoke all on function public.use_ai() from public, anon;
grant execute on function public.use_ai() to authenticated;

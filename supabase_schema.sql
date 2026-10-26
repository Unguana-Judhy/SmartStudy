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

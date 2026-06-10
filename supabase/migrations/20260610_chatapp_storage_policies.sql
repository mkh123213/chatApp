-- ============================================================================
-- Storage policies for the `chatapp` bucket.
--
-- WHY: This app authenticates users with Firebase Auth, NOT Supabase Auth.
-- That means every Storage request reaches Supabase as the `anon` role.
-- For chat image / file / voice / status uploads to work, the `anon` role
-- must be allowed to operate on the `chatapp` bucket.
--
-- SECURITY NOTE: allowing `anon` write means anyone holding the public anon
-- key can write to this bucket. That is an inherent trade-off of using
-- Supabase Storage with Firebase Auth. The more secure long-term fix is to
-- authenticate users with Supabase too (custom JWT / anonymous sign-in) and
-- scope these policies to `auth.uid()`.
--
-- HOW TO APPLY:
--   Option A (Dashboard): Supabase → SQL Editor → paste this file → Run.
--   Option B (CLI):       supabase db push   (from the project root)
-- ============================================================================

-- Ensure the bucket exists and is public (public => getPublicUrl works for reads).
insert into storage.buckets (id, name, public)
values ('chatapp', 'chatapp', true)
on conflict (id) do update set public = true;

-- Remove any previous versions of these policies so this script is re-runnable.
drop policy if exists "chatapp_read"   on storage.objects;
drop policy if exists "chatapp_insert" on storage.objects;
drop policy if exists "chatapp_update" on storage.objects;
drop policy if exists "chatapp_delete" on storage.objects;

-- Read objects in the bucket.
create policy "chatapp_read"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'chatapp');

-- Upload new objects to the bucket.
create policy "chatapp_insert"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'chatapp');

-- Overwrite existing objects (used when upsert: true).
create policy "chatapp_update"
  on storage.objects for update
  to anon, authenticated
  using (bucket_id = 'chatapp')
  with check (bucket_id = 'chatapp');

-- Delete objects (used when a message/status is removed).
create policy "chatapp_delete"
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'chatapp');

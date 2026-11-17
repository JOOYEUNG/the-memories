-- THE MEMORIES starter schema.
-- Run this in Supabase SQL Editor. This creates a private media bucket.
create extension if not exists pgcrypto;

create table if not exists public.memories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  caption text,
  category text not null check (category in ('friends','admiring')),
  visibility text not null check (visibility in ('public','private')),
  media_path text,
  media_type text,
  created_at timestamptz not null default now()
);

create table if not exists public.memory_access (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid not null references public.memories(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  granted_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(memory_id,user_id)
);

alter table public.memories enable row level security;
alter table public.memory_access enable row level security;

create policy "Read public friends and authorized memories"
on public.memories for select to authenticated
using (
  (category = 'friends' and visibility = 'public')
  or user_id = auth.uid()
  or exists (
    select 1 from public.memory_access a
    where a.memory_id = memories.id and a.user_id = auth.uid()
  )
);

create policy "Create own memories"
on public.memories for insert to authenticated
with check (user_id = auth.uid());

create policy "Owner updates own memories"
on public.memories for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Owner deletes own memories"
on public.memories for delete to authenticated
using (user_id = auth.uid());

create policy "Users can view their own access grants"
on public.memory_access for select to authenticated
using (
  user_id = auth.uid()
  or exists (select 1 from public.memories m where m.id = memory_id and m.user_id = auth.uid())
);

create policy "Memory owner grants access"
on public.memory_access for insert to authenticated
with check (
  granted_by = auth.uid()
  and exists (select 1 from public.memories m where m.id = memory_id and m.user_id = auth.uid())
);

create policy "Memory owner revokes access"
on public.memory_access for delete to authenticated
using (
  exists (select 1 from public.memories m where m.id = memory_id and m.user_id = auth.uid())
);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('memory-media', 'memory-media', false, 104857600,
  array['image/jpeg','image/png','image/webp','image/heic','image/gif','video/mp4','video/quicktime','video/webm'])
on conflict (id) do nothing;

-- Storage object names must begin with the memory UUID: <memory-id>/<filename>.
create policy "Read media only for visible memories"
on storage.objects for select to authenticated
using (
  bucket_id = 'memory-media'
  and exists (
    select 1 from public.memories m
    where m.id::text = (storage.foldername(name))[1]
      and (
        (m.category = 'friends' and m.visibility = 'public')
        or m.user_id = auth.uid()
        or exists (select 1 from public.memory_access a where a.memory_id = m.id and a.user_id = auth.uid())
      )
  )
);

create policy "Upload media to own or public friends memory"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'memory-media'
  and exists (
    select 1 from public.memories m
    where m.id::text = (storage.foldername(name))[1]
      and (
        m.user_id = auth.uid()
        or (m.category = 'friends' and m.visibility = 'public')
      )
  )
);

create policy "Owner deletes memory media"
on storage.objects for delete to authenticated
using (
  bucket_id = 'memory-media'
  and exists (
    select 1 from public.memories m
    where m.id::text = (storage.foldername(name))[1]
      and m.user_id = auth.uid()
  )
);

-- Enable realtime updates for the memories table.
alter publication supabase_realtime add table public.memories;

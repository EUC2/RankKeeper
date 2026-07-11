-- RankKeeper Dojo Wall: run once in the Supabase SQL Editor before deploying.
-- Safe to re-run. Policies grant elevated read/write access only to support@euc2.org.
create extension if not exists pgcrypto;

alter table public.profiles add column if not exists plan text default 'trial';
alter table public.profiles add column if not exists purchased_at timestamptz;
alter table public.profiles add column if not exists next_payment_at timestamptz;
alter table public.profiles add column if not exists stripe_customer_id text;
alter table public.profiles add column if not exists rank_system_id uuid;
alter table public.profiles add column if not exists updated_at timestamptz default now();

create table if not exists public.katas (
  id uuid primary key default gen_random_uuid(), name text not null,
  min_level integer not null check (min_level between 1 and 4),
  style text[] not null default '{}', scope text not null default 'global' check (scope in ('global','custom')),
  dojo_id uuid references auth.users(id) on delete cascade, sort_order integer not null default 0,
  active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((scope = 'global' and dojo_id is null) or (scope = 'custom' and dojo_id is not null))
);

create table if not exists public.rank_systems (
  id uuid primary key default gen_random_uuid(), name text not null,
  scope text not null default 'global' check (scope in ('global','custom')),
  dojo_id uuid references auth.users(id) on delete cascade, active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((scope = 'global' and dojo_id is null) or (scope = 'custom' and dojo_id is not null))
);

create table if not exists public.rank_levels (
  id uuid primary key default gen_random_uuid(), system_id uuid not null references public.rank_systems(id) on delete cascade,
  rank_label text not null, belt_color text not null default 'White', belt_hex text not null default '#F5F5F5',
  division text not null default 'Beginner', order_index integer not null default 0,
  active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- Some RankKeeper deployments already have early versions of these tables.
-- CREATE TABLE IF NOT EXISTS does not add new columns to an existing table,
-- so explicitly bring those installations up to this schema before indexing.
alter table public.katas add column if not exists min_level integer;
alter table public.katas add column if not exists style text[] not null default '{}';
alter table public.katas add column if not exists scope text not null default 'global';
alter table public.katas add column if not exists dojo_id uuid references auth.users(id) on delete cascade;
alter table public.katas add column if not exists sort_order integer not null default 0;
alter table public.katas add column if not exists active boolean not null default true;
alter table public.katas add column if not exists created_at timestamptz not null default now();
alter table public.katas add column if not exists updated_at timestamptz not null default now();

alter table public.rank_systems add column if not exists scope text not null default 'global';
alter table public.rank_systems add column if not exists dojo_id uuid references auth.users(id) on delete cascade;
alter table public.rank_systems add column if not exists active boolean not null default true;
alter table public.rank_systems add column if not exists created_at timestamptz not null default now();
alter table public.rank_systems add column if not exists updated_at timestamptz not null default now();

alter table public.rank_levels add column if not exists system_id uuid references public.rank_systems(id) on delete cascade;
alter table public.rank_levels add column if not exists rank_label text;
alter table public.rank_levels add column if not exists belt_color text not null default 'White';
alter table public.rank_levels add column if not exists belt_hex text not null default '#F5F5F5';
alter table public.rank_levels add column if not exists division text not null default 'Beginner';
alter table public.rank_levels add column if not exists order_index integer not null default 0;
alter table public.rank_levels add column if not exists rank_order integer not null default 0;
alter table public.rank_levels add column if not exists active boolean not null default true;
alter table public.rank_levels add column if not exists created_at timestamptz not null default now();
alter table public.rank_levels add column if not exists updated_at timestamptz not null default now();

alter table public.rank_levels alter column rank_order set default 0;
update public.rank_levels set rank_order = order_index where rank_order is null;

do $$
begin
  if not exists (select 1 from public.rank_levels where system_id is null) then
    alter table public.rank_levels alter column system_id set not null;
  end if;
  if not exists (select 1 from public.rank_levels where rank_label is null) then
    alter table public.rank_levels alter column rank_label set not null;
  end if;
end $$;

create unique index if not exists katas_global_name_unique on public.katas (lower(name)) where scope='global';
create unique index if not exists rank_systems_global_name_unique on public.rank_systems (lower(name)) where scope='global';

create or replace function public.is_rankkeeper_admin() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(auth.jwt() ->> 'email', '') = 'support@euc2.org';
$$;

alter table public.katas enable row level security;
alter table public.rank_systems enable row level security;
alter table public.rank_levels enable row level security;

drop policy if exists "admin manages katas" on public.katas;
create policy "admin manages katas" on public.katas for all using (public.is_rankkeeper_admin()) with check (public.is_rankkeeper_admin());
drop policy if exists "admin manages rank systems" on public.rank_systems;
create policy "admin manages rank systems" on public.rank_systems for all using (public.is_rankkeeper_admin()) with check (public.is_rankkeeper_admin());
drop policy if exists "admin manages rank levels" on public.rank_levels;
create policy "admin manages rank levels" on public.rank_levels for all using (public.is_rankkeeper_admin()) with check (public.is_rankkeeper_admin());
drop policy if exists "dojos read effective katas" on public.katas;
create policy "dojos read effective katas" on public.katas for select using (active and (scope = 'global' or dojo_id = auth.uid()));
drop policy if exists "dojos manage custom katas" on public.katas;
create policy "dojos manage custom katas" on public.katas for all using (scope = 'custom' and dojo_id = auth.uid()) with check (scope = 'custom' and dojo_id = auth.uid());
drop policy if exists "dojos read effective rank systems" on public.rank_systems;
create policy "dojos read effective rank systems" on public.rank_systems for select using (active and (scope = 'global' or dojo_id = auth.uid()));
drop policy if exists "dojos manage custom rank systems" on public.rank_systems;
create policy "dojos manage custom rank systems" on public.rank_systems for all using (scope = 'custom' and dojo_id = auth.uid()) with check (scope = 'custom' and dojo_id = auth.uid());
drop policy if exists "dojos read effective rank levels" on public.rank_levels;
create policy "dojos read effective rank levels" on public.rank_levels for select using (active and exists (select 1 from public.rank_systems s where s.id = system_id and s.active and (s.scope = 'global' or s.dojo_id = auth.uid())));
drop policy if exists "admin reads profiles" on public.profiles;
create policy "admin reads profiles" on public.profiles for select using (public.is_rankkeeper_admin());
drop policy if exists "admin updates profiles" on public.profiles;
create policy "admin updates profiles" on public.profiles for update using (public.is_rankkeeper_admin()) with check (public.is_rankkeeper_admin());
drop policy if exists "admin reads students" on public.students;
create policy "admin reads students" on public.students for select using (public.is_rankkeeper_admin());
drop policy if exists "admin reads tests" on public.rank_tests;
create policy "admin reads tests" on public.rank_tests for select using (public.is_rankkeeper_admin());

insert into public.rank_systems (name) values ('JKA'), ('WKF'), ('AAU'), ('USA NKF') on conflict do nothing;

-- The 102-kata roster is intentionally imported from the Dojo Wall's CSV tool;
-- this keeps the seed editable and visible to the administrator before import.

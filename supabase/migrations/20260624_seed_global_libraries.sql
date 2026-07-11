-- RankKeeper global library seed. Safe to re-run: existing rows are retained.

-- Full bootstrap guard: this file can now be run by itself even if the admin
-- tables were never created.
create extension if not exists pgcrypto;

create table if not exists public.rank_systems (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  scope text not null default 'global' check (scope in ('global','custom')),
  dojo_id uuid references auth.users(id) on delete cascade,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((scope = 'global' and dojo_id is null) or (scope = 'custom' and dojo_id is not null))
);

create table if not exists public.rank_levels (
  id uuid primary key default gen_random_uuid(),
  system_id uuid references public.rank_systems(id) on delete cascade,
  rank_label text,
  belt_color text not null default 'White',
  belt_hex text not null default '#F5F5F5',
  division text not null default 'Beginner',
  order_index integer not null default 0,
  rank_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.katas (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  min_level integer check (min_level between 1 and 4),
  style text[] not null default '{}',
  scope text not null default 'global' check (scope in ('global','custom')),
  dojo_id uuid references auth.users(id) on delete cascade,
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((scope = 'global' and dojo_id is null) or (scope = 'custom' and dojo_id is not null))
);

-- Repair early/partial installs before inserting seed rows. Supabase's
-- "create table if not exists" does not add columns to tables that already
-- exist, so this seed is intentionally defensive.
alter table public.rank_levels add column if not exists system_id uuid references public.rank_systems(id) on delete cascade;
alter table public.rank_levels add column if not exists rank_label text;
alter table public.rank_levels add column if not exists belt_color text not null default 'White';
alter table public.rank_levels add column if not exists belt_hex text not null default '#F5F5F5';
alter table public.rank_levels add column if not exists division text not null default 'Beginner';
alter table public.rank_levels add column if not exists order_index integer not null default 0;
alter table public.rank_levels add column if not exists rank_order integer not null default 0;
alter table public.rank_levels add column if not exists active boolean not null default true;
alter table public.rank_levels alter column rank_order set default 0;
update public.rank_levels set rank_order = order_index where rank_order is null;

alter table public.katas add column if not exists min_level integer;
alter table public.katas add column if not exists style text[] not null default '{}';
alter table public.katas add column if not exists scope text not null default 'global';
alter table public.katas add column if not exists sort_order integer not null default 0;
alter table public.katas add column if not exists active boolean not null default true;

create unique index if not exists katas_global_name_unique on public.katas (lower(name)) where scope='global';
create unique index if not exists rank_systems_global_name_unique on public.rank_systems (lower(name)) where scope='global';

insert into public.rank_systems (name, scope, active)
values ('JKA', 'global', true), ('WKF', 'global', true), ('AAU', 'global', true), ('USA NKF', 'global', true)
on conflict do nothing;

-- Standard rank systems. Order is junior → senior. Stripes are derived in the
-- app from belt color, so they are intentionally not stored separately here.
with levels(system_name, rank_label, belt_color, belt_hex, division, order_index) as (
  values
  ('JKA','10th Kyu','White','#F5F5F5','Beginner',10),('JKA','9th Kyu','Orange','#E67E22','Beginner',20),('JKA','8th Kyu','Red','#CC4444','Beginner',30),('JKA','7th Kyu','Yellow','#F4D03F','Beginner',40),('JKA','6th Kyu','Green','#27AE60','Intermediate',50),('JKA','5th Kyu','Blue','#2980B9','Intermediate',60),('JKA','4th Kyu','Purple','#8E44AD','Intermediate',70),('JKA','3rd Kyu','Brown','#7B4B2A','Advanced',80),('JKA','2nd Kyu','Brown','#7B4B2A','Advanced',90),('JKA','1st Kyu','Brown','#7B4B2A','Advanced',100),
  ('WKF','10th Kyu','White','#F5F5F5','Beginner',10),('WKF','9th Kyu','White','#F5F5F5','Beginner',20),('WKF','8th Kyu','Yellow','#F4D03F','Beginner',30),('WKF','7th Kyu','Orange','#E67E22','Beginner',40),('WKF','6th Kyu','Green','#27AE60','Intermediate',50),('WKF','5th Kyu','Green','#27AE60','Intermediate',60),('WKF','4th Kyu','Blue','#2980B9','Intermediate',70),('WKF','3rd Kyu','Purple','#8E44AD','Intermediate',80),('WKF','2nd Kyu','Brown','#7B4B2A','Advanced',90),('WKF','1st Kyu','Brown','#7B4B2A','Advanced',100),
  ('AAU','10th Kyu','White','#F5F5F5','Beginner',10),('AAU','9th Kyu','White','#F5F5F5','Beginner',20),('AAU','8th Kyu','Yellow','#F4D03F','Beginner',30),('AAU','7th Kyu','Orange','#E67E22','Beginner',40),('AAU','6th Kyu','Green','#27AE60','Intermediate',50),('AAU','5th Kyu','Green','#27AE60','Intermediate',60),('AAU','4th Kyu','Blue','#2980B9','Intermediate',70),('AAU','3rd Kyu','Purple','#8E44AD','Intermediate',80),('AAU','2nd Kyu','Brown','#7B4B2A','Advanced',90),('AAU','1st Kyu','Brown','#7B4B2A','Advanced',100),
  ('USA NKF','10th Kyu','White','#F5F5F5','Beginner',10),('USA NKF','9th Kyu','White','#F5F5F5','Beginner',20),('USA NKF','8th Kyu','Yellow','#F4D03F','Beginner',30),('USA NKF','7th Kyu','Orange','#E67E22','Beginner',40),('USA NKF','6th Kyu','Green','#27AE60','Intermediate',50),('USA NKF','5th Kyu','Green','#27AE60','Intermediate',60),('USA NKF','4th Kyu','Blue','#2980B9','Intermediate',70),('USA NKF','3rd Kyu','Purple','#8E44AD','Intermediate',80),('USA NKF','2nd Kyu','Brown','#7B4B2A','Advanced',90),('USA NKF','1st Kyu','Brown','#7B4B2A','Advanced',100)
), dan_levels(system_name, rank_label, order_index) as (
  select s.name, d.label, d.ord from public.rank_systems s cross join (values ('1st Dan (Shodan)',110),('2nd Dan (Nidan)',120),('3rd Dan (Sandan)',130),('4th Dan (Yondan)',140),('5th Dan (Godan)',150),('6th Dan (Rokudan)',160),('7th Dan (Shichidan)',170),('8th Dan (Hachidan)',180),('9th Dan (Kudan)',190)) d(label,ord) where s.name in ('JKA','WKF','AAU','USA NKF')
)
insert into public.rank_levels (system_id, rank_label, belt_color, belt_hex, division, order_index)
select rs.id, l.rank_label, l.belt_color, l.belt_hex, l.division, l.order_index from levels l join public.rank_systems rs on rs.name=l.system_name
where not exists (select 1 from public.rank_levels rl where rl.system_id=rs.id and rl.rank_label=l.rank_label)
union all
select rs.id, d.rank_label, 'Black', '#1A1A1A', 'Advanced', d.order_index from dan_levels d join public.rank_systems rs on rs.name=d.system_name
where not exists (select 1 from public.rank_levels rl where rl.system_id=rs.id and rl.rank_label=d.rank_label);

update public.rank_levels set rank_order = order_index where rank_order = 0 and order_index <> 0;

with seed(name, min_level, sort_order) as (
  values
  ('Chi No Kata',1,10),('Gekisai Daichi',1,20),('Gekisai Daini',1,30),('Fukyu Daichi',1,40),('Fukyu Daini',1,50),('Heian Shodan',1,60),('Heian Nidan',1,70),('Junino',1,80),('Kihon Kata',1,90),('Pinan Shodan',1,100),('Pinan Nidan',1,110),('Taikyoku',1,120),('Taikyoku Shodan',1,130),('Ten No Kata',1,140),
  ('Gekisai Dai San',2,10),('Heian Sandan',2,20),('Heian Yondan',2,30),('Heian Godan',2,40),('Pinan Sandan',2,50),('Pinan Yondan',2,60),('Pinan Godan',2,70),
  ('Ananko',3,10),('Ananku',3,20),('Aoyagi',3,30),('Bassai',3,40),('Bassai Dai',3,50),('Bassai Sho',3,60),('Chinte',3,70),('Enpi',3,80),('Garyu',3,90),('Hangetsu',3,100),('Hauffa',3,110),('Ishimine Bassai',3,120),('Itosu Rohai Shodan',3,130),('Itosu Rohai Nidan',3,140),('Itosu Rohai Sandan',3,150),('Jiin',3,160),('Jion',3,170),('Jitte',3,180),('Juroku',3,190),('Kanku Dai',3,200),('Kousoukun Dai',3,210),('Kusanku',3,220),('Matsukaze',3,230),('Matsumura Rohai',3,240),('Meikyo',3,250),('Myojo',3,260),('Naifanchin Shodan',3,270),('Naifanchin Nidan',3,280),('Naifanchin Sandan',3,290),('Naihanchi',3,300),('Nijushiho',3,310),('Niseishi',3,320),('Pachu',3,330),('Passai',3,340),('Rohai',3,350),('Saifa',3,360),('Sanchin',3,370),('Sanseiru',3,380),('Sanseru',3,390),('Seichin',3,400),('Seienchin',3,410),('Seipai',3,420),('Seiryu',3,430),('Shinpa',3,440),('Shinsei',3,450),('Shisochin',3,460),('Tekki Shodan',3,470),('Tekki Nidan',3,480),('Tekki Sandan',3,490),('Tensho',3,500),('Wankan',3,510),('Wanshu',3,520),('Wanshin',3,530),
  ('Annanko',4,10),('Bassai Dai',4,20),('Chatanyara Kushanku',4,30),('Chinto',4,40),('Gankaku',4,50),('Gojushiho Dai',4,60),('Gojushiho Sho',4,70),('Hakutsuru',4,80),('Jitte',4,90),('Kanku Sho',4,100),('Kururunfa',4,110),('Matsumura Bassai',4,120),('Matsumura Seisan',4,130),('Matsumura Wankan',4,140),('Nipaipo',4,150),('Patsai',4,160),('Seisan',4,170),('Seisan (Uechi)',4,180),('Seipai',4,190),('Shitei',4,200),('Sochin',4,210),('Suparinpei',4,220),('Unsu',4,230),('Kushanku',4,240),('Kanku',4,250),('Oyadomari no Passai',4,260),('Pechurin',4,270),('Sansai',4,280),('Shorin no Kushanku',4,290),('Toryu',4,300),('Tomari Bassai',4,310)
)
insert into public.katas (name, min_level, style, scope, sort_order, active)
select name, min_level, '{}'::text[], 'global', sort_order, true from seed
where not exists (select 1 from public.katas k where lower(k.name)=lower(seed.name) and k.scope='global');

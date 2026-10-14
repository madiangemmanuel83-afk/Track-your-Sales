-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.

create table if not exists shops (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'My shop',
  code text unique not null,
  owner uuid not null references auth.users(id),
  created_at timestamptz default now()
);

create table if not exists members (
  shop_id uuid references shops(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'member',
  display text,
  primary key (shop_id, user_id)
);

create table if not exists records (
  id text not null,
  shop_id uuid not null references shops(id) on delete cascade,
  kind text not null check (kind in ('s','e','p')),   -- s=sale, e=expense, p=product
  data jsonb not null default '{}',
  deleted boolean not null default false,
  by uuid,
  updated_at timestamptz not null default now(),
  primary key (shop_id, id)
);
create index if not exists records_pull on records (shop_id, updated_at);

create or replace function touch_updated() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
drop trigger if exists records_touch on records;
create trigger records_touch before insert or update on records
  for each row execute function touch_updated();

create or replace function is_member(sid uuid) returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from members where shop_id = sid and user_id = auth.uid())
$$;

alter table shops enable row level security;
alter table members enable row level security;
alter table records enable row level security;

drop policy if exists shops_read on shops;
create policy shops_read on shops for select using (is_member(id));
drop policy if exists members_read on members;
create policy members_read on members for select using (is_member(shop_id));
drop policy if exists records_read on records;
create policy records_read on records for select using (is_member(shop_id));
drop policy if exists records_insert on records;
create policy records_insert on records for insert with check (is_member(shop_id));
drop policy if exists records_update on records;
create policy records_update on records for update using (is_member(shop_id)) with check (is_member(shop_id));

create or replace function create_shop(p_name text) returns shops
language plpgsql security definer set search_path = public as $$
declare s shops;
begin
  if auth.uid() is null then raise exception 'Please sign in first'; end if;
  insert into shops(name, code, owner)
    values (coalesce(nullif(p_name,''),'My shop'), upper(substr(md5(random()::text || clock_timestamp()::text),1,6)), auth.uid())
    returning * into s;
  insert into members(shop_id, user_id, role, display)
    values (s.id, auth.uid(), 'owner', auth.jwt() ->> 'email');
  return s;
end $$;

create or replace function join_shop(p_code text) returns shops
language plpgsql security definer set search_path = public as $$
declare s shops;
begin
  if auth.uid() is null then raise exception 'Please sign in first'; end if;
  select * into s from shops where code = upper(trim(p_code));
  if not found then raise exception 'Shop code not found. Check it and try again.'; end if;
  insert into members(shop_id, user_id, role, display)
    values (s.id, auth.uid(), 'member', auth.jwt() ->> 'email')
  on conflict (shop_id, user_id) do nothing;
  return s;
end $$;

revoke all on function create_shop(text), join_shop(text) from public, anon;
grant execute on function create_shop(text), join_shop(text) to authenticated;

-- =====================================================
-- DATABASE + SCHEMA (REQUIRED)
-- =====================================================

-- database: restaurant_db
-- schema: restaurant

create schema if not exists restaurant;
set search_path to restaurant;

-- =====================================================
-- DROP (RE-RUN SAFE HEADER)
-- =====================================================

drop table if exists staff_shifts cascade;
drop table if exists order_details cascade;
drop table if exists orders cascade;
drop table if exists restaurant_tables cascade;
drop table if exists shifts cascade;
drop table if exists menu_items cascade;
drop table if exists staff cascade;
drop table if exists categories cascade;

-- =====================================================
-- PART 2: CREATE TABLES
-- =====================================================

create table if not exists categories (
    category_id serial primary key,
    name varchar(50) unique not null
);

create table if not exists menu_items (
    item_id serial primary key,
    category_id int not null,
    name varchar(150) unique not null,
    price numeric(10,2) not null check(price > 0),
    foreign key (category_id) references categories(category_id)
);

create table if not exists staff (
    staff_id serial primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    full_name varchar(120)
        generated always as (first_name || ' ' || last_name) stored,
    role varchar(50) not null
        check(role in ('Manager','Chef','Waiter')),
    hire_date date not null
        check(hire_date >= date '2026-01-01')
);

create table if not exists shifts (
    shift_id serial primary key,
    shift_date date not null,
    start_time time not null,
    end_time time not null check(end_time > start_time)
);

create table if not exists restaurant_tables (
    table_id serial primary key,
    table_number int unique not null check(table_number > 0),
    capacity int not null check(capacity > 0)
);

create table if not exists orders (
    order_id serial primary key,
    table_id int not null,
    staff_id int not null,
    created_at timestamp not null default now(),
    status varchar(20) not null
        check(status in ('Active','Completed','Cancelled')),
    foreign key (table_id) references restaurant_tables(table_id),
    foreign key (staff_id) references staff(staff_id)
);

create table if not exists order_details (
    order_detail_id serial primary key,
    order_id int not null,
    item_id int not null,
    quantity int not null check(quantity > 0),
    price_at_order numeric(10,2) not null check(price_at_order > 0),
    foreign key (order_id) references orders(order_id) on delete cascade,
    foreign key (item_id) references menu_items(item_id)
);

create table if not exists staff_shifts (
    staff_shift_id serial primary key,
    staff_id int not null,
    shift_id int not null,
    foreign key (staff_id) references staff(staff_id),
    foreign key (shift_id) references shifts(shift_id)
);

-- =====================================================
-- PART 3: ALTER TABLE (5 DIFFERENT OPERATIONS)
-- =====================================================

-- add optional discount column for promotions
alter table menu_items add column discount numeric(5,2) default 0;

-- set default order status to Active
alter table orders alter column status set default 'Active';

-- add email contact for staff communication
alter table staff add column email varchar(120);

-- rename table_number for business rebranding consistency
alter table restaurant_tables rename column table_number to number;

-- add max price validation rule for menu items
alter table menu_items add constraint chk_price_limit check (price <= 1000);

-- =====================================================
-- PART 4: INSERT DATA
-- =====================================================

-- TRUNCATE (REQUIRED)
truncate table staff_shifts, order_details, orders,
restaurant_tables, shifts, menu_items, staff, categories
restart identity cascade;

-- categories (5 rows)
insert into categories (name) values
('Starters'),('Main'),('Desserts'),('Drinks'),('Salads');

-- menu_items (5 rows)
insert into menu_items (category_id, name, price) values
((select category_id from categories where name='Starters'),'Soup',3.50),
((select category_id from categories where name='Main'),'Steak',15.00),
((select category_id from categories where name='Drinks'),'Cola',2.00),
((select category_id from categories where name='Desserts'),'Cake',5.50),
((select category_id from categories where name='Salads'),'Caesar',6.50);

-- staff (5 rows, Atyrau context)
insert into staff (first_name,last_name,role,hire_date,email) values
('Asylai','Zhumakulova','Manager','2026-02-01','asylai@atyrau.kz'),
('Aiken','Amanbai','Chef','2026-03-01','aiken@atyrau.kz'),
('Aruzhan','Tulegenova','Waiter','2026-04-01','aruzhan@atyrau.kz'),
('Dias','Ermekov','Chef','2026-05-01','dias@atyrau.kz'),
('Inabat','Kairakbai','Waiter','2026-06-01','inabat@atyrau.kz');

-- shifts (5 rows)
insert into shifts (shift_date,start_time,end_time) values
('2026-07-01','09:00','17:00'),
('2026-07-02','09:00','17:00'),
('2026-07-03','09:00','17:00'),
('2026-07-04','09:00','17:00'),
('2026-07-05','09:00','17:00');

-- restaurant_tables (5 rows)
insert into restaurant_tables (number,capacity) values
(1,2),(2,4),(3,6),(4,4),(5,8);

-- orders (10 rows)
insert into orders (table_id,staff_id,status) values
((select table_id from restaurant_tables where number=1),(select staff_id from staff where first_name='Asylai'),'Active'),
((select table_id from restaurant_tables where number=2),(select staff_id from staff where first_name='Aiken'),'Completed'),
((select table_id from restaurant_tables where number=3),(select staff_id from staff where first_name='Aruzhan'),'Active'),
((select table_id from restaurant_tables where number=4),(select staff_id from staff where first_name='Dias'),'Cancelled'),
((select table_id from restaurant_tables where number=5),(select staff_id from staff where first_name='Inabat'),'Completed'),
((select table_id from restaurant_tables where number=1),(select staff_id from staff where first_name='Dias'),'Active'),
((select table_id from restaurant_tables where number=2),(select staff_id from staff where first_name='Aiken'),'Completed'),
((select table_id from restaurant_tables where number=3),(select staff_id from staff where first_name='Inabat'),'Active'),
((select table_id from restaurant_tables where number=4),(select staff_id from staff where first_name='Asylai'),'Completed'),
((select table_id from restaurant_tables where number=5),(select staff_id from staff where first_name='Aruzhan'),'Active');

-- order_details (10 rows requirement)
insert into order_details (order_id,item_id,quantity,price_at_order)
select order_id,item_id,1,price
from orders cross join menu_items
limit 10;

-- staff_shifts (5 rows)
insert into staff_shifts (staff_id, shift_id) values
((select staff_id from staff where first_name='Aiken'),
 (select shift_id from shifts where shift_date='2026-07-01')),

((select staff_id from staff where first_name='Aruzhan'),
 (select shift_id from shifts where shift_date='2026-07-02')),

((select staff_id from staff where first_name='Dias'),
 (select shift_id from shifts where shift_date='2026-07-03')),

((select staff_id from staff where first_name='Inabat'),
 (select shift_id from shifts where shift_date='2026-07-04')),

((select staff_id from staff where first_name='Asylai'),
 (select shift_id from shifts where shift_date='2026-07-05'));

-- =====================================================
-- PART 5: UPDATE + DELETE
-- =====================================================

-- business: price increase to 10% due to supplier cost change
update menu_items set price = price * 1.1 where name = 'Cola';

-- business: mark orders completed and update timestamp based on shifts
update orders o
set status = 'Completed'
from staff_shifts ss
where o.staff_id = ss.staff_id
  and o.status = 'Active';
  
begin;
-- "remove cancelled orders older than 90 days"
delete from orders where status = 'Cancelled' returning order_id;

rollback;

-- =====================================================
-- PART 6: GRANT + REVOKE (RE-RUN SAFE)
-- =====================================================

-- safely reset roles to avoid "already exists" error
drop role if exists restaurant_db_readonly;
drop role if exists restaurant_db_writer;

-- create roles for access control
create role restaurant_db_readonly;
create role restaurant_db_writer;

-- allow read-only access to all tables in restaurant schema
grant select on all tables in schema restaurant to restaurant_db_readonly;

-- allow writers to insert and update orders (core business table)
grant insert, update on orders to restaurant_db_writer;

-- business rule: writers should not modify existing order history
revoke update on orders from restaurant_db_writer;


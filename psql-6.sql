--"Задание 1. Выполните горизонтальное партиционирование для таблицы inventory учебной базы dvd-rental:
--
--создайте 2 партиции по значению store_id
--создайте индексы для каждой партиции
--заполните партиции данными из родительской таблицы
--для каждой партиции создайте правила на внесение, обновление, удаление данных. Напишите команды SQL для проверки работы правил.

--Задание 2. Создайте новую базу данных и в ней 2 таблицы для хранения данных по инвентаризации каждого магазина,
-- которые будут наследоваться из таблицы inventory базы dvd-rental.
-- Используя шардирование и модуль postgres_fdw создайте подключение к новой базе данных и необходимые внешние таблицы
-- в родительской базе данных для наследования. Распределите данные по внешним таблицам. Напишите SQL-запросы для проверки работы внешних таблиц.
--
--В качестве ответов на задания пришлите текст команд, использовавшихся для выполнения задания,
-- и скриншоты рабочей области с получившимися партициями, внешними таблицами, SQL-запросами и их результатами."

-----------1------------
select *
from inventory i 

create table inventory_store_1 (check (store_id = 1)) inherits (inventory);

create table inventory_store_2 (check (store_id = 2)) inherits (inventory);

create index inventory_store_1_idx on inventory_store_1 (cast(store_id as smallint));

create index inventory_store_2_idx on inventory_store_2 (cast(store_id as smallint));

insert into inventory_store_1
select *
from inventory 
where store_id = 1

insert into inventory_store_2
select *
from inventory 
where store_id = 2

explain analyze
select *
from inventory i

create rule payment_insert_inventory_store_1 as on insert to inventory 
where (store_id = 1)
do instead insert into inventory_store_1 values (new.*);

create rule payment_insert_inventory_store_2 as on insert to inventory 
where (store_id = 2)
do instead insert into inventory_store_2 values (new.*);

insert into inventory 
values(4582, 9999, 1, now())


create rule update_inventory_store_1 as on update to inventory
where (old.store_id = 1 and new.store_id != 1)
do instead (
	insert into inventory values (new.*); 
	delete from inventory_store_1 where inventory_id = new.inventory_id);

create rule update_inventory_store_2 as on update to inventory
where (old.store_id = 2 and new.store_id != 2)
do instead (
	insert into inventory values (new.*); 
	delete from inventory_store_2 where inventory_id = new.inventory_id);
	

update inventory 
set store_id = 2
where inventory_id = 4582
 
ПРАВИЛО на delete работает автоматически, его создавать не нужно

DELETE FROM inventory WHERE inventory_id = 4582

-----------2------------

--Создайте новую базу данных и в ней 2 таблицы для хранения данных по инвентаризации каждого магазина,
-- которые будут наследоваться из таблицы inventory базы dvd-rental.
-- Используя шардирование и модуль postgres_fdw создайте подключение к новой базе данных и необходимые внешние таблицы
-- в родительской базе данных для наследования. Распределите данные по внешним таблицам. Напишите SQL-запросы для проверки работы внешних таблиц.

create database inventory_db

--Прописываем на другом листи в ДБ inventory_db
CREATE TABLE inventory_store_1 (
	inventory_id int2 NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT null check(store_id = 1),
	last_update timestamp NOT null)
	
--Прописываем на другом листи в ДБ inventory_db
CREATE TABLE inventory_store_2 (
	inventory_id int2 NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT null  check(store_id = 2),
	last_update timestamp NOT null)

create extension postgres_fdw

create server inventory_server
foreign data wrapper postgres_fdw
options (host 'localhost', port '5432', dbname 'inventory_db')

--DROP SERVER inventory_server CASCADE;

create user mapping for postgres
server inventory_server
options (user 'postgres', password '********')

create foreign table inventory_store_1_in (
	inventory_id int NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT null check(store_id = 1),
	last_update timestamp NOT null)
inherits (inventory)
server inventory_server
options (schema_name 'public', table_name 'inventory_store_1')

create foreign table inventory_store_2_in (
	inventory_id int NOT NULL,
	film_id int2 NOT NULL,
	store_id int2 NOT null check(store_id = 2),
	last_update timestamp NOT null)
inherits (inventory)
server inventory_server
options (schema_name 'public', table_name 'inventory_store_2')


create or replace function inventory_tg() returns trigger as $$
begin
	if new.store_id = 1 then    
		insert into inventory_store_1_in values (new.*);
	elsif new.store_id = 2 then  
		insert into inventory_store_2_in values (new.*);
	else raise exception 'автоматизировать поденятие других серверов - та еще задача';
	end if;
	return null;
end; $$ language plpgsql;

create trigger inventory_insert_tg
before insert on inventory
for each row execute function inventory_tg();

create temp table invent as (select * from inventory i) 

delete from inventory 

select * from inventory 

insert into inventory 
select * from invent

select * from only inventory

select * from inventory
where store_id = 1



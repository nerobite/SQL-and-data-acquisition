--Задание 1. Создайте подключение к удаленному облачному серверу базы HR (база данных postgres, схема hr), используя модуль postgres_fdw.
--Напишите SQL-запрос на выборку любых данных используя 2 сторонних таблицы, соединенных с помощью JOIN.
--В качестве ответа на задание пришлите список команд, использовавшихся для настройки подключения, создания внешних таблиц, а также получившийся SQL-запрос.
--
SELECT * FROM pg_available_extensions


create extension postgres_fdw

create server in_pfdw
foreign data wrapper postgres_fdw
options (host '51.250.106.132', port '19001', dbname 'postgres')

create user mapping for postgres
server in_pfdw
options (user 'netology', password 'NetoSQL2019')

create schema test_fdw

import foreign schema hr limit to (employee, person)
from server in_pfdw into test_fdw

select *
from test_fdw.employee e 
join test_fdw.person p on e.person_id = p.person_id 
limit 10


--Задание 2. С помощью модуля tablefunc получите из таблицы projects базы HR таблицу с данными, колонками которой будут:
-- год, месяцы с января по декабрь, общий итог по стоимости всех проектов за год.
--В качестве ответа на задание пришлите получившийся SQL-запрос.
select month
from (
	select distinct date_part('TMMonth',created_at) as month_num,
			to_char(created_at, 'TMMonth') as month
    from projects p
    order by month_num) t

  select month_num::text
  from (
    select distinct date_part('month',created_at) as month_num
      from projects p
      order by month_num) t


create extension tablefunc

SET lc_time = 'ru_RU.UTF-8'

select coalesce(year::text, 'Итого')::text AS "Год",
	coalesce(month::text, 'Итого')::text as month,
	coalesce(sum(sum), 0)::int8 sum
from(
	select extract(year from created_at) as year, date_part('month', p.created_at) as month, sum(amount)
	from projects p 
	group by cube(1, 2)
	order by 1, 2) t
group by 1, 2
order by 1, 2


select "Год", 
	coalesce("1", 0) as "Январь",  
	coalesce("2",0) as "Февраль", 
	coalesce("3",0) as "Март", 
	coalesce("4",0) as "Апрель", 
	coalesce("5",0) as "Май", 
	coalesce("6",0) as "Июнь", 
	coalesce("7",0) as "Июль", 
	coalesce("8",0) as "Август",
	coalesce("9",0) as "Сентябрь",
	coalesce("10",0) as "Октябрь",
	coalesce("11",0) as "Ноябрь",
	coalesce("12",0) as "Декабрь",
	"Итого"
from crosstab ($$
select coalesce(year::text, 'Итого')::text AS "Год",
	coalesce(month::text, 'Итого')::text as month,
	coalesce(sum(sum), 0)::int8 sum
from(
	select extract(year from created_at) as year, date_part('month', p.created_at) as month, sum(amount)
	from projects p 
	group by cube(1, 2)
	order by 1, 2) t
group by 1, 2
order by 1, 2	
$$, $$
select month_num::text
  from (
    select distinct date_part('month',created_at) as month_num
      from projects p
      order by month_num) t
union all 
select 'Итого'
$$) as scb ("Год" text, 
	"1" numeric,  
	"2" numeric, 
	"3" numeric, 
	"4" numeric, 
	"5" numeric, 
	"6" numeric, 
	"7" numeric, 
	"8" numeric,
	"9" numeric,
	"10" numeric,
	"11" numeric,
	"12" numeric,
	"Итого" numeric)
	

create type projects_sum as (
    "Год" text, 
	"1" numeric,  
	"2" numeric, 
	"3" numeric, 
	"4" numeric, 
	"5" numeric, 
	"6" numeric, 
	"7" numeric, 
	"8" numeric,
	"9" numeric,
	"10" numeric,
	"11" numeric,
	"12" numeric,
	"Итого" numeric)
   

	
DROP TYPE projects_sum;
	
DROP FUNCTION projects_otchet(text);

DROP FUNCTION projects_otchet(text, text);
        
create function projects_otchet (text, text) returns setof projects_sum
as '$libdir\tablefunc', 'crosstab_hash' language C stable strict

select "Год", 
	coalesce("1", 0) as "Январь",  
	coalesce("2",0) as "Февраль", 
	coalesce("3",0) as "Март", 
	coalesce("4",0) as "Апрель", 
	coalesce("5",0) as "Май", 
	coalesce("6",0) as "Июнь", 
	coalesce("7",0) as "Июль", 
	coalesce("8",0) as "Август",
	coalesce("9",0) as "Сентябрь",
	coalesce("10",0) as "Октябрь",
	coalesce("11",0) as "Ноябрь",
	coalesce("12",0) as "Декабрь",
	"Итого"
from projects_otchet ($$
select coalesce(year::text, 'Итого')::text AS "Год",
	coalesce(month::text, 'Итого')::text as month,
	coalesce(sum(sum), 0)::numeric sum
from(
	select extract(year from created_at) as year, date_part('month', p.created_at) as month, sum(amount)::numeric
	from projects p 
	group by cube(1, 2)
	order by 1, 2) t
group by 1, 2
order by 1, 2	
$$, $$
select month_num::text
  from (
    select distinct date_part('month',created_at) as month_num
      from projects p
      order by month_num) t
union all 
select 'Итого'
$$)
--
--Задание 3. Настройте модуль pg_stat_statements на локальном сервере PostgresSQL и выполните несколько любых SQL-запросов к базе.
--В качестве ответа на задание пришлите скриншот со статистикой по выполненным запросам

select *
from pg_catalog.pg_extension

create extension pg_stat_statements

select *
from pg_stat_statements

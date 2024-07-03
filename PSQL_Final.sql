--Для реализации функционала по заказу курьера для доставки корреспонденции контрагентам, необходимо реализовать хранение и получение данных по заявкам.
--На данный момент уже реализованы фронтенд и бэкенд.
--
--Задача: 
--1. Используя сервис https://supabase.com/ нужно поднять облачную базу данных PostgreSQL.

--2. Для доступа к данным в базе данных должен быть создан пользователь 
--логин: netocourier
--пароль: NetoSQL2022
--права: полный доступ на схему public, к information_schema и pg_catalog права только на чтение, предусмотреть доступ к иным схемам, если они нужны. 

--Создаем пользователя 
CREATE ROLE netocourier WITH LOGIN PASSWORD 'NetoSQL2022';

--Польный доступ на схему public

GRANT ALL PRIVILEGES ON SCHEMA public TO netocourier;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO netocourier;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO netocourier;

--Права только на чтение для information_schema и pg_catalog

GRANT USAGE ON SCHEMA information_schema TO netocourier;
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO netocourier;

GRANT USAGE ON SCHEMA pg_catalog TO netocourier;
GRANT SELECT ON ALL TABLES IN SCHEMA pg_catalog TO netocourier;

--3. Должны быть созданы следующие отношения:
--courier: --данные по заявкам на курьера
--account: --список контрагентов
--contact: --список контактов контрагентов
--user: --сотрудники

--4. Для генерации uuid необходимо использовать функционал модуля uuid-ossp, который уже подключен в облачной базе.
--
--5. Для формирования списка значений в атрибуте status используйте create type ... as enum 

SELECT * FROM pg_available_extensions WHERE name = 'uuid-ossp';

CREATE TYPE status_enum AS ENUM ('В очереди', 'Выполняется', 'Выполнено', 'Отменен');

create table courier( --: --данные по заявкам на курьера
	id uuid primary key DEFAULT uuid_generate_v1(),
	from_place varchar(150) not null, --откуда
	where_place varchar(150) not null, --куда
	name varchar(30) not null, --название документа
	account_id uuid not null REFERENCES account(id), --id контрагента
	contact_id uuid not null references contact(id), --id контакта 
	description text, --описание
	user_id uuid not null REFERENCES "user"(id),--id сотрудника отправителя
	status status_enum not null default 'В очереди', -- статусы 'В очереди', 'Выполняется', 'Выполнено', 'Отменен'. По умолчанию 'В очереди'
	created_date date not null default NOW() --дата создания заявки, значение по умолчанию now()
);

create table account( --: --список контрагентов
	id uuid primary key  DEFAULT uuid_generate_v1(),
	name varchar(50) not null--название контрагента
);

--DROP TABLE account CASCADE;
--
--DROP TABLE contact CASCADE;
--
--DROP TABLE "user" CASCADE;
--
--DROP TABLE courier CASCADE;

create table contact( --: --список контактов контрагентов
	id uuid primary key DEFAULT uuid_generate_v1(), 
	last_name varchar(30) not null, --фамилия контакта
	first_name varchar(30) not null, --имя контакта
	account_id uuid not null REFERENCES account(id) --id контрагента
);


create table "user"( --сотрудники
	id uuid primary key DEFAULT uuid_generate_v1(),
	last_name varchar(30) not null, --фамилия сотрудника
	first_name varchar(30) not null, --имя сотрудника
	dismissed boolean not null default FALSE --уволен или нет, значение по умолчанию "нет"
);


--6. Для возможности тестирования приложения необходимо реализовать процедуру insert_test_data(value), которая принимает на вход целочисленное значение.
--Данная процедура должна внести:
--value * 1 строк случайных данных в отношение account.
--value * 2 строк случайных данных в отношение contact.
--value * 1 строк случайных данных в отношение user.
--value * 5 строк случайных данных в отношение courier.
--- Генерация id должна быть через uuid-ossp
--- Генерация символьных полей через конструкцию SELECT repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя',1,(random()*33)::integer),(random()*10)::integer);
--Соблюдайте длину типа varchar. Первый random получает случайный набор символов из строки, второй random дублирует количество символов полученных в substring.
--- Генерация булева типа происходит через 0 и 1 с использованием оператора random.
--- Генерацию даты и времени можно сформировать через select now() - interval '1 day' * round(random() * 1000) as timestamp;
--- Генерацию статусов можно реализовать через enum_range()

truncate contact cascade;

create or replace procedure insert_test_data(value int) as $$
begin 
	for i in 1..value
	loop
		insert into account( name)
		values(
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() * 2 + 1)::integer), 50)
			);
	end loop;
	for i in 1..(value * 2)
	loop
		insert into contact(last_name, first_name, account_id)
		values(
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() + 1)::integer), 30),
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() + 1)::integer), 30),
			(select id from account order by random() limit 1)
			);
	end loop;
	for i in 1..value
	loop
		insert into "user"(last_name, first_name, dismissed)
		values(
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() + 1)::integer), 30),
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() + 1)::integer), 30),
			((random() < 0.5))
			);
	end loop;
	for i in 1..(value * 5)
	loop
		insert into courier (from_place, where_place, name, account_id,	contact_id,	description, user_id, status, created_date)
		values(
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() * 4 + 1)::integer), 150),
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() * 4 + 1)::integer), 150),
			left(repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() + 1)::integer), 30),
			(select id from account order by random() limit 1),
			(select id from contact order by random() limit 1),
			repeat(substring('абвгдеёжзийклмнопрстуфхцчшщьыъэюя', 1, (random() * 33 + 1)::integer), (random() * 5)::integer),
			(select id from "user" order by random() limit 1),
			(SELECT aaa
				FROM (
			    	SELECT unnest(enum_range(NULL::status_enum)) as aaa) t
				ORDER BY random()
				LIMIT 1),
			(select now() - interval '1 day' * round(random() * 60) as timestamp)
			);
	end loop;	
end
$$ language plpgsql;

call insert_test_data(1);

--DROP PROCEDURE IF EXISTS insert_test_data(integer);
--
--DROP PROCEDURE erase_test_data(text);


SELECT proname, proargtypes
FROM pg_proc
WHERE proname = 'insert_test_data';

--7. Необходимо реализовать процедуру erase_test_data(), которая будет удалять тестовые данные из отношений.

create or replace procedure erase_test_data() as $$
begin
	execute 'truncate table courier, "user", contact, account cascade;';
end
$$ language plpgsql;

call erase_test_data();

--8. Нужно реализовать процедуру add_courier(from_place, where_place, name, account_id, contact_id, description, user_id), 
--которая принимает на вход вышеуказанные аргументы и вносит данные в таблицу courier
--Важно! Последовательность значений должна быть строго соблюдена, иначе приложение работать не будет.

create or replace procedure add_courier(from_place varchar, where_place varchar, name varchar, account_id uuid, contact_id uuid, description text, user_id uuid) as $$
begin 
	insert into courier(from_place, where_place, name, account_id, contact_id, description, user_id)
	values (
		from_place, 
		where_place,
		name,
		account_id,
		contact_id,
		description,
		user_id
	);
end
$$ language plpgsql;

call add_courier('домдомдом', 'доромдомдом', 'конверт', '0445fe0a-348d-11ef-bb6d-069100a14ac9', '044bedec-348d-11ef-bb6d-069100a14ac9', 'трулалатрулала', '04629c7c-348d-11ef-bb6d-069100a14ac9')


--9. Нужно реализовать функцию get_courier(), которая возвращает таблицу согласно следующей структуры:
--id --идентификатор заявки
--from_place --откуда
--where_place --куда
--name --название документа
--account_id --идентификатор контрагента
--account --название контрагента
--contact_id --идентификатор контакта
--contact --фамилия и имя контакта через пробел
--description --описание
--user_id --идентификатор сотрудника
--user --фамилия и имя сотрудника через пробел
--status --статус заявки
--created_date --дата создания заявки
--Сортировка результата должна быть сперва по статусу, затем по дате от большего к меньшему.
--Важно! Если названия столбцов возвращаемой функцией таблицы будут отличаться от указанных выше, то приложение работать не будет.

create or replace function get_courier()
returns table (
    id UUID,
    from_place VARCHAR,
    where_place VARCHAR,
    name VARCHAR,
    account_id UUID,
    account VARCHAR,
    contact_id UUID,
    contact VARCHAR,
    description VARCHAR,
    user_id UUID,
    "user" VARCHAR,
    status status_enum,
    created_date DATE
) as $$
begin 
	return query (
		select 
			c.id, --идентификатор заявки
			c.from_place, --откуда
			c.where_place, --куда
			c.name, --название документа
			c.account_id, --идентификатор контрагента
			a.name as account, --название контрагента
			c.contact_id, --идентификатор контакта
			concat(cc.last_name, ' ', cc.first_name)::varchar as contact, --фамилия и имя контакта через пробел
			c.description::varchar, --описание
			c.user_id, --идентификатор сотрудника
			concat(u.last_name, ' ', u.first_name)::varchar as "user", --фамилия и имя сотрудника через пробел
			c.status, --статус заявки
			c.created_date --дата созда
		from courier c
		left join account a on c.account_id = a.id
		left join contact cc on c.contact_id = cc.id
		left join "user" u on c.user_id = u.id
		order by c.status, c.created_date desc);
end
$$ language plpgsql;

select *
from get_courier()

--drop function get_courier;

--10. Нужно реализовать процедуру change_status(status, id), которая будет изменять статус заявки.
--На вход процедура принимает новое значение статуса и значение идентификатора заявки

create or replace procedure change_status(status status_enum, id uuid) as $$
begin 
	update courier
	set status = change_status.status
	where courier.id = change_status.id;
end
$$ language plpgsql;

SELECT proname, proargtypes
FROM pg_proc
WHERE proname = 'change_status';

--drop procedure change_status(varchar, uuid)

call change_status( 'Выполняется', 'f17adf42-348d-11ef-bb6d-069100a14ac9')

--11. Нужно реализовать функцию get_users(), которая возвращает таблицу согласно следующей структуры:
--user --фамилия и имя сотрудника через пробел 
--Сотрудник должен быть действующим! Сортировка должна быть по фамилии сотрудника

create or replace function get_users() returns table("user" varchar) as $$
begin
	return query(
		select concat(last_name, ' ', first_name)::varchar as "user" 
		from "user" u 
		where dismissed = false
		order by last_name
	);
end
$$ language plpgsql;

select * from get_users()

--12.Нужно реализовать функцию get_accounts(), которая возвращает таблицу согласно следующей структуры:
--account --название контрагента 
--Сортировка должна быть по названию контрагента.

create or replace function get_accounts() returns table(account varchar) as $$
begin
	return query(
		select distinct "name" as account
		from account
		order by "name"
	);
end
$$ language plpgsql;

select * from get_accounts()

--13. Нужно реализовать функцию get_contacts(account_id), которая принимает на вход идентификатор контрагента
--и возвращает таблицу с контактами переданного контрагента согласно следующей структуры:
--contact --фамилия и имя контакта через пробел 
--Сортировка должна быть по фамилии контакта. Если в функцию вместо идентификатора контрагента передан null, нужно вернуть строку 'Выберите контрагента'.

create or replace function get_contacts(in_account_id uuid) returns table(contact varchar) as $$
begin
	if in_account_id is null then
		return query
		select 'Выберите контрагента'::varchar;
	elseif  in_account_id in (select c.account_id from contact c) then
		return query(
			select concat(last_name, ' ', first_name)::varchar as contact
			from contact c 
			where c.account_id = in_account_id
			order by last_name
		);
	else
		raise exception 'Введен на корректный номер контрагента';
	end if;
end
$$ language plpgsql;

--DROP FUNCTION get_contacts(uuid)

select * from get_contacts(NULL)
--Выберите контрагента

select * from get_contacts('04465986-348d-11ef-bb6d-069100a14ac9')
--аааааааааааа абвгдеёжзийклмнопрстуфхцчшщьыъ
--абвабвабвабвабвабвабвабвабвабв абвгдеёжзийклмнопрсабвгдеёжзий
--абвгабвгабвгабвгабвгабвгабвгаб абвгдеёжзийклмнопрстуфабвгдеёж
--абвгдабвгдабвгдабвгдабвгдабвгд абвгдеёжзиабвгдеёжзиабвгдеёжзи
--абвгдеёжзийкабвгдеёжзийкабвгде абвгдеёжабвгдеёжабвгдеёжабвгде
--абвгдеёжзийклмнопабвгдеёжзийкл абвгдеёжзийклмнопрстабвгдеёжзи
--абвгдеёжзийклмнопрабвгдеёжзийк абвгдеёжзийклмабвгдеёжзийклмаб
--абвгдеёжзийклмнопрстабвгдеёжзи абвгдеёжзийклмнопрстуфхцабвгде
--абвгдеёжзийклмнопрстуабвгдеёжз абвабвабвабвабвабвабвабвабвабв
--абвгдеёжзийклмнопрстуфхабвгдеё абвгдеёжабвгдеёжабвгдеёжабвгде
--абвгдеёжзийклмнопрстуфхцабвгде абвгдеёжзийклмнопрстабвгдеёжзи
--абвгдеёжзийклмнопрстуфхцчшабвг абвгдеёжзийклмнопрстабвгдеёжзи
--абвгдеёжзийклмнопрстуфхцчшщабв абвгдеёжзийклмнопрстуфхцчшщабв
--абвгдеёжзийклмнопрстуфхцчшщьыъ абвгдеёжзийклмнопрстуфхабвгдеё
--абвгдеёжзийклмнопрстуфхцчшщьыъ абвгдеёжзийклмнопрстуфхцчабвгд

select * from get_contacts('0445fe0a-350d-11ef-bb6d-069100a14ac9')
--SQL Error [P0001]: ERROR: Введен на корректный номер контрагента

--14. Нужно реализовать представление courier_statistic, со следующей структурой:
--account_id --идентификатор контрагента
--account --название контрагента
--count_courier --количество заказов на курьера для каждого контрагента
--count_complete --количество завершенных заказов для каждого контрагента
--count_canceled --количество отмененных заказов для каждого контрагента
--percent_relative_prev_month -- процентное изменение количества заказов текущего месяца к предыдущему месяцу для каждого контрагента,
--если получаете деление на 0, то в результат вывести 0.
--count_where_place --количество мест доставки для каждого контрагента
--count_contact --количество контактов по контрагенту, которым доставляются документы
--cansel_user_array --массив с идентификаторами сотрудников, по которым были заказы со статусом "Отменен" для каждого контрагента

create view courier_statistic as
with courier_cte as(
	select account_id, 
		count(*) as count_courier,
		count(*) filter(where status = 'Выполнено') as count_complete,
		count(*) filter(where status = 'Отменен') as count_canceled,
		count(*) filter(where date_trunc('month', created_date) = date_trunc('month', now())) as month_now,
		count(*) filter(where date_trunc('month', created_date) = date_trunc('month', now() - interval '1 month')) as month_before,
		count(distinct where_place) as count_where_place,
		count(contact_id) filter(where status = 'Выполняется') as count_contact,
		array_agg(distinct user_id) filter(where status = 'Отменен') as cansel_user_array
	from courier c 
	group by account_id
)
select account_id,
	   a.name as account,
	   count_courier,
  	   count_complete,
       count_canceled,
       coalesce(round(100 * (month_now - month_before)::numeric / nullif(month_before, 0), 2), 0) as percent_relative_prev_month, 
       count_where_place,
       count_contact,
       cansel_user_array
from courier_cte cte
left join account a on cte.account_id = a.id

select * from courier_statistic
		
--drop view courier_statistic;



--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.
create schema lecture_4

set search_path to lecture_4

--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
create table language (
	language_id serial primary key,
	language_name varchar(50) not null unique,
	created_at timestamp not null default current_timestamp,
	deleted boolean not null default false
)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
insert into language (language_name)
values ('Русский'), ('Французский'),('Английский'), ('Немецкий'), ('Японский') 

select *
from "language" l 

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

create table people (
	people_id serial primary key,
	people_name varchar(50) not null unique	
)


select *
from people p 
--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ

insert into people (people_name)
values ('Славяне'), ('Франки'), ('Саксы'), ('Галлы'), ('Айны') 

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
create table country (
	country_id serial primary key,
	country_name varchar(50) not null unique
) 

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ

insert into country  (country_name)
values ('Российская Империя'), ('Французская республика'),('Великобритания'), ('ФРГ'), ('Япония') 

select *
from country c 

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table union_language(
	language_id int2 not null references language(language_id),
	people_id int2 not null references people(people_id),
	primary key(language_id, people_id)
)

select *
from union_language ul 

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into union_language(language_id, people_id)
select language_id, people_id
from "language", people 


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table union_people(
	country_id int2 not null references country(country_id),
	people_id int2 not null references people(people_id),
	primary key(country_id, people_id)
	)


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
insert into union_people(country_id, people_id)
select country_id, people_id
from country, people

select * from union_people up 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.
create table film_new(
	film_name varchar(25) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0) 
)

select* from film_new fn 

--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
	values ('The Shawshank Redemption', 1994, 2.99, 142), ('The Green Mile', 1999, 0.99, 189), ('Back to the Future', 1985, 1.99, 116), ('Forrest Gump', 1994, 2.99, 142), ('Schindlers List', 1993, 3.99, 195)

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
select unnest(array['Film_1', 'Film_2', 'Film_3', 'Film_4', 'Film_5']), unnest(array[1999, 2005, 2012, 2019, 2023]), unnest(array[0.99, 1.99, 2.99, 3.99, 4.99]), unnest(array[122, 176, 146, 152, 175])

select *
from film_new fn 

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41
update film_new set film_rental_rate = film_rental_rate*1.41 


--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

delete from film_new 
where film_name = 'Back to the Future'


--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме
insert into film_new(film_name, film_year, film_rental_rate, film_duration)
	values ('Avatar 2', 2023, 5.99, 192)


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых
select *,
	round(film_duration/60 + (film_duration%60)*0.01, 1)
from film_new fn 


--ЗАДАНИЕ №7 
--Удалите таблицу film_new
drop table film_new 

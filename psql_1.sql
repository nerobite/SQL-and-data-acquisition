--По заданиям 1.3 и 1.4 в качестве решения пришлите скриншоты.
--По заданиям 1.1, 1.2, 2.х и 3.х решение должны быть в виде одного sql файла со всеми командами.

--Задание 1. Работа с командной строкой
--1.1. Создайте новую базу данных с любым названием
--1.2. Восстановите бэкап учебной базы данных в новую базу данных с помощью psql
--1.3. Выведите список всех таблиц восстановленной базы данных
--1.4. Выполните SQL-запрос на выборку всех полей из любой таблицы восстановленной базы данных
--Пункты 1.1 и 1.2 выполняются в командной строке, пункты 1.3 и 1.4 выполняются в интерактивном режиме.

--1.1. Создайте новую базу данных с любым названием
--в команжной строке
C:\Program Files\PostgreSQL\15\bin>psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE new_base"
Пароль пользователя postgres:
CREATE DATABASE

--в интерактивном режиме
C:\Program Files\PostgreSQL\15\bin>psql -h localhost -p 5432 -U postgres
Пароль пользователя postgres:
psql (15.2)
Введите "help", чтобы получить справку.

postgres=# create database hr_new;
CREATE DATABASE
postgres=#

--1.2. Восстановите бэкап учебной базы данных в новую базу данных с помощью psql
--восстановил бд с помощью команды

C:\Program Files\PostgreSQL\15\bin>psql -h localhost -p 5432 -U postgres -d hr_new
--Пароль пользователя postgres:
--psql (15.2)
--Введите "help", чтобы получить справку.
--
--hr_new=# \i "D:\Doc\hr.sql"
--unrecognized win32 error code: 123"D:/Doc/hr.sql: Invalid argument
--hr_new=# \i D:\Doc\hr.sql
--D:: Permission denied
--пойдем другим путем

psql -h localhost -p 5432 -U postgres -d hr_new -f "D:\Doc\hr.sql"

--C:\Program Files\PostgreSQL\15\bin>psql -h localhost -p 5432 -U postgres -d hr_new -l
--Пароль пользователя postgres:
--                                                                  Список баз данных
--           Имя            | Владелец | Кодировка |     LC_COLLATE      |      LC_CTYPE       | локаль ICU | Провайдер локали |     Права доступа
----------------------------+----------+-----------+---------------------+---------------------+------------+------------------+-----------------------
-- Test_tasks               | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- hr_new                   | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_classified_ads  | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_django_testing  | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_import_phones   | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_m2m_relations   | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_models_list     | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_orm_migrations  | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_smart_home      | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- netology_stocks_products | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- postgres                 | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             |
-- template0                | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             | =c/postgres          +
--                          |          |           |                     |                     |            |                  | postgres=CTc/postgres
-- template1                | postgres | UTF8      | Russian_Russia.1251 | Russian_Russia.1251 |            | libc             | =c/postgres          +
--                          |          |           |                     |                     |            |                  | postgres=CTc/postgres
--(13 строк)

--1.3, 1.4 сделаны скрины

--Задание 2. Работа с пользователями
--2.1. Создайте нового пользователя MyUser, которому разрешен вход, но не задан пароль и права доступа.
--2.2. Задайте пользователю MyUser любой пароль сроком действия до последнего дня текущего месяца.
--2.3. Дайте пользователю MyUser права на чтение данных из двух любых таблиц восстановленной базы данных.
--2.4. Заберите право на чтение данных ранее выданных таблиц
--2.5. Удалите пользователя MyUser.
--Задание выполняется в DBeaver

--2.1. Создайте нового пользователя MyUser, которому разрешен вход, но не задан пароль и права доступа.
create role	MyUser with login

--2.2. Задайте пользователю MyUser любой пароль сроком действия до последнего дня текущего месяца.

alter role MyUser with password '12345' valid until '2024-06-30'

--2.3. Дайте пользователю MyUser права на чтение данных из двух любых таблиц восстановленной базы данных.

grant connect on database hr_new to myuser

grant usage on schema hr to myuser

grant select on table hr.city, hr.person to myuser

--2.4. Заберите право на чтение данных ранее выданных таблиц
revoke select on table hr.city, hr.person from myuser

--2.5. Удалите пользователя MyUser.
revoke connect on database hr_new from myuser

revoke usage on schema hr from myuser

revoke all on all tables in schema hr from myuser

drop role myuser -- не хочет удалять... 
--пока эксперементировал, надавал кучу разрешений, соответственно создаем групповую политику и все разрешения пользователя передаем ей. 
create role group_role

grant connect on database postgres to group_role

grant connect on database hr_new to group_role

grant usage on schema public to group_role

grant usage on schema hr to group_role

grant select on all tables in schema public to group_role

grant select on all tables in schema hr to group_role

grant group_role to myuser

revoke connect on database postgres from group_role

revoke usage on schema public from group_role

revoke usage on schema hr from group_role

revoke select on all tables in schema hr from group_role

drop owned by myuser

DROP ROLE myuser

select *
from pg_catalog.pg_roles pr

--Задание 3. Работа с транзакциями
--3.1. Начните транзакцию
--3.2. Добавьте в таблицу projects новую запись
--3.3. Создайте точку сохранения
--3.4. Удалите строку, добавленную в п.3.2
--3.5. Откатитесь к точке сохранения
--3.6. Завершите транзакцию.
--Задание выполняется в DBeaver

--3.1. Начните транзакцию
begin
	
--3.2. Добавьте в таблицу projects новую запись
insert into projects
values (129, 'ЫЫЫЫЫЫЫЫЫ', ARRAY[7777, 77, 777, 1588], 100500)

--3.3. Создайте точку сохранения
savepoint deback_point

--3.4. Удалите строку, добавленную в п.3.2
delete from projects where project_id = 129;

--3.5. Откатитесь к точке сохранения
rollback to savepoint deback_point

--3.6. Завершите транзакцию.
commit




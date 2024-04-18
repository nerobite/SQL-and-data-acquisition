--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
explain analyze --67.5 | 0.721

select film_id , title , special_features 
from film f 
where special_features @> array['Behind the Scenes']

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
explain analyze -- 538 | 0.609

select film_id , title , special_features 
from film f 
where 'Behind the Scenes' = any(special_features)

explain analyze --67.5 | 0.902
select film_id , title , special_features 
from film f 
where special_features && array['Behind the Scenes']

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
explain analyze -- 720 | 16.84

select c.customer_id , count(r.rental_id) 
from rental r 
join customer c on r.customer_id = c.customer_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
where f.special_features && array['Behind the Scenes']
group by c.customer_id 
order by c.customer_id 

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.
explain analyze -- 720 | 18.04

with cte as (
	select film_id , title , special_features 
	from film f 
	where special_features @> array['Behind the Scenes'])
select c.customer_id , count(r.rental_id) 
from cte
join inventory i on i.film_id = cte.film_id
join rental r on r.inventory_id = i.inventory_id 
join customer c on c.customer_id = r.customer_id 
where i.film_id = cte.film_id
group by c.customer_id 
order by c.customer_id 



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".
explain analyze --720 | 17

select c.customer_id , count(r.rental_id) 
from (
	select film_id , title , special_features 
	from film f 
	where special_features @> array['Behind the Scenes']) t
join inventory i on t.film_id = i.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on c.customer_id = r.customer_id
group by c.customer_id 
order by c.customer_id

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.





--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view task as 
	select c.customer_id , count(r.rental_id) 
	from (
	select film_id , title , special_features 
	from film f 
	where special_features @> array['Behind the Scenes']) t
	join inventory i on t.film_id = i.film_id 
	join rental r on r.inventory_id = i.inventory_id 
	join customer c on c.customer_id = r.customer_id
	group by c.customer_id 
	order by c.customer_id
with no data

refresh materialized view task

select * from task

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
Через оператор any поиск значений в массиве происходит быстрее всего

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
Вариант с использованием подзапроса работает немного быстрее


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

select 
	t.staff_id,
	f.film_id ,
	f.title ,
	t.amount ,
	t.payment_date,
	concat(c.first_name, ' ', c.last_name) 
from (
	select *,
	row_number () over(partition by p.staff_id order by p.payment_date)
	from payment p 
	) t
join customer c on c.customer_id = t.customer_id
join rental r on c.customer_id = r.customer_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id
where row_number = 1
-- я так понимаю, один покупатель взял сразу несколько дисков, чек был пробит в одно время и таблица отображает  позиции в чеке 



--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день






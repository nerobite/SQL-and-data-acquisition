--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select 
	initcap(concat(last_name , ' ',first_name)) as "Фамилия и имя",
	a.address,
	c2.city,
	c3.country 
from customer c 
join address a on c.address_id = a.address_id 
join city c2 on a.city_id = c2.city_id
join country c3 on c2.country_id = c3.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id, count(c.customer_id)
from customer c 
join store s on c.store_id = s.store_id 
group by s.store_id 


SELECT store_id, COUNT(customer_id)
FROM customer
GROUP BY store_id


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select s.store_id, count(c.customer_id)
from customer c 
join store s on c.store_id = s.store_id 
group by s.store_id 
having count(c.customer_id) > 300


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select s.store_id,
	s2.last_name,
	s2.first_name,
	c2.city,
	count(c.customer_id)
from customer c 
join store s on c.store_id = s.store_id
join address a on s.address_id = a.address_id
join staff s2 on s.store_id  = s2.store_id
join city c2 on a.city_id = c2.city_id 
group by s.store_id, a.address_id,  s2.last_name, s2.first_name, c2.city_id, s2.staff_id 
having count(c.customer_id) > 300

SELECT
    s.store_id as "ID магазина",
    COUNT(c.customer_id) as "Количество покупателей",
    c2.city as "Город",
    CONCAT(st.first_name, ' ', st.last_name) AS "Имя сотрудника"
from customer c
join store s ON c.store_id = s.store_id
join address a ON s.address_id = a.address_id
join staff st ON s.store_id = st.store_id
join city c2 on a.city_id = c2.city_id 
GROUP by s.store_id, c2.city, st.staff_id 
having COUNT(c.customer_id) > 300

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select 
	c.last_name,
	c.first_name,
	count(p.amount)
from customer c 
join payment p  on c.customer_id  = p.customer_id 
group by c.customer_id
order by count(p.amount) desc
limit(5)

select 
	c.last_name,
	c.first_name,
	sum(active)
from customer c 
join rental r  on c.customer_id  = r.customer_id 
group by c.customer_id
order by sum(active) desc
limit(5)



--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select 
	c.first_name,
	c.last_name,
	count(p.amount) as "Количество",
	round(sum(p.amount)) as "Сумма платежей",
	min(p.amount),
	max(p.amount)	
from customer c 
join payment p on c.customer_id  = p.customer_id 
group by c.customer_id 




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 select 
 	c.city as "Город 1",
 	c2.city as "Город 2" 	
 from city c 
 cross join city c2 where c.city != c2.city 
 




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 select 
 	customer_id,	
 	round(avg(return_date::date - rental_date::date), 2)
 from rental r
 group by customer_id 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select 
	f.title as "Название фильма",
	f.rating as "Рейтинг",
	c."name" as "Жанр",
	f.release_year as "Год выпуска",
	l."name" as "Язык",
	count(p.amount) as "Количество аренды",
	sum(p.amount) as "Сумма аренды"	
from film f 
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id 
join payment p on r.rental_id = p.rental_id
join "language" l on f.language_id = l.language_id 
join film_category fc on f.film_id  = fc.film_id 
join category c on fc.category_id = c.category_id 
group by f.film_id, l."name", c."name"





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
select 
	f.title as "Название фильма",
	f.rating as "Рейтинг",
	c."name" as "Жанр",
	f.release_year as "Год выпуска",
	l."name" as "Язык",
	count(p.amount) as "Количество аренды",
	sum(p.amount) as "Сумма аренды"	
from film f 
left join inventory i on f.film_id = i.film_id 
left join rental r on i.inventory_id = r.inventory_id 
left join payment p on r.rental_id = p.rental_id
left join "language" l on f.language_id = l.language_id 
left join film_category fc on f.film_id  = fc.film_id 
left join category c on fc.category_id = c.category_id 
where p.amount is null 
group by f.film_id, l."name", c."name"




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select 
	s.staff_id,
	count(p.amount),
	(case
		when count(p.amount) > 7300 then 'Да'
		else 'Нет'
	end) as "Премия"
from staff s 
join payment p on s.staff_id = p.staff_id 
group by s.staff_id 







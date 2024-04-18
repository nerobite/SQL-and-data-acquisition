--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select  customer_id,
		payment_id,
		payment_date,
		row_number () over(order by payment_date::timestamp) as "Номер платежа",
		row_number () over(partition by customer_id  order by payment_date) as "№ платежа покупателя",
		sum(amount) over(partition by customer_id order by payment_date, amount) as "Сумма платежа",
		rank() over(partition by customer_id order by amount desc) as "№ платежа"
from payment p 
group by payment_id 
order by customer_id 


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select 
	customer_id,
	payment_id,
	payment_date,
	amount,
	lag(amount, 1, 0) over(partition by customer_id order by payment_date) 
from payment p 

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select
	customer_id ,
	payment_id ,
	payment_date ,
	amount ,
	amount - lead(amount, 1, 0) over(partition by customer_id order by payment_date) as "difference"
from payment p 

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

explain analyze --1612/0.056

select distinct on (customer_id) customer_id,
	payment_id ,
	payment_date ,
	first_value(amount) over(partition by customer_id order by payment_date desc) as "amount"
from payment p 


explain analyze --1771/0.065

select f.customer_id , f.payment_id , f.payment_date , f.amount
from (select p.customer_id , p.payment_id , p.payment_date , p.amount,  row_number() over (partition by p.customer_id order by p.payment_date desc)
from payment p ) f
where row_number ='1'


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

select 
	staff_id ,
	payment_date::date,
	--amount,
	sum(amount),
	sum(sum(amount)) over(partition by staff_id order by payment_date::date)
from payment p
where payment_date > '1-08-2005' and payment_date < '01-09-2005'
group by staff_id, payment_date::date




--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

select 
	customer_id ,
	payment_date ,
	row_number as payment_number
from (
	select
		*,
		row_number() over(order by payment_date::timestamp)
	from payment p 
	where p.payment_date::date = '20-08-2005'
 ) t
where row_number % 100 = 0


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

with cte1 as(
	select  c.customer_id,
			c2.country_id,
			count(i.film_id),
			sum(p.amount),
			max(r.rental_date),
			concat(c.last_name, ' ', c.first_name ) 
	from rental r 
	join payment p on p.rental_id = r.rental_id
	join inventory i on i.inventory_id = r.inventory_id 
	join customer c on c.customer_id = r.customer_id 
	join address a on a.address_id = c.address_id 
	join city c2 on c2.city_id = a.city_id 
	group by c.customer_id, c2.country_id),
cte2 as(
	select country_id,
		concat,
		row_number() over(partition by country_id order by count desc) as rc,
		row_number() over(partition by country_id order by sum desc) as rs,
		row_number() over(partition by country_id order by max desc) as rm
	from cte1) 
select country, c1.concat, c2.concat, c3.concat
from country c
left join cte2 c1 on c1.country_id = c.country_id and c1.rc = 1
left join cte2 c2 on c2.country_id = c.country_id and c2.rs = 1
left join cte2 c3 on c3.country_id = c.country_id and c3.rm = 1
order by country



--Задания:
--1. Получите количество проектов, подписанных в 2023 году.
--В результат вывести одно значение количества.

select count(p.sign_date)
from project p 
where date_trunc('year', p.sign_date) = '2023-01-01'


--2. Получите общий возраст сотрудников, нанятых в 2022 году.
--Результат вывести одним значением в виде "... years ... month ... days"
--Использование более 2х функций для работы с типом данных дата и время будет являться ошибкой.

select sum(age(e.hire_date, p.birthdate))
from person p 
join employee e on p.person_id = e.person_id
where date_trunc('year', e.hire_date) = '2022-01-01';


--3. Получите сотрудников, у которого фамилия начинается на М, всего в фамилии 8 букв и который работает дольше других.
--Если таких сотрудников несколько, выведите одного случайного.
--В результат выведите два столбца, в первом должны быть имя и фамилия через пробел, во втором дата найма.

select concat(first_name,  ' ', last_name), e.hire_date
from person p
join employee e on p.person_id = e.person_id
where p.last_name like 'М%' and length(p.last_name) = 8 and e.dismissal_date is null
order by hire_date
limit 1


--4. Получите среднее значение полных лет сотрудников, которые уволены и не задействованы на проектах.
--В результат вывести одно среднее значение. Если получаете null, то в результат нужно вывести 0.

select coalesce(avg(extract(year from age(NOW()::date, p.birthdate))), 0)
from employee e 
join person p on p.person_id = e.person_id
left join(
	select p.project_id, 
		   unnest(p.employees_id || ARRAY[p.project_manager_id]) AS employees_id
	from project p 
) as pj on pj.employees_id = e.employee_id
where dismissal_date is not null and pj.project_id is null


--5. Чему равна сумма полученных платежей от контрагентов из Жуковский, Россия.
--В результат вывести одно значение суммы.

select sum(amount)
from project_payment pp 
join project p on pp.project_id = p.project_id
join customer c on c.customer_id = p.customer_id
join address a on a.address_id = c.address_id
join city c2 on c2.city_id = a.city_id
join country c3 on c3.country_id = c2.country_id
where c2.city_name = 'Жуковский' and c3.country_name = 'Россия'
	and p.status != 'Отменен' and pp.fact_transaction_timestamp is not null


--6. Пусть руководитель проекта получает премию в 1% от стоимости завершенного проекта.
--Если взять завершенные проекты, какой руководитель проекта получит самый большой бонус?
--В результат нужно вывести идентификатор руководителя проекта, его ФИО и размер бонуса.
--Если таких руководителей несколько, предусмотреть вывод всех.

select tt.project_manager_id, tt.full_fio, tt.bonus
from(
	select t.project_manager_id, t.full_fio,t.bonus, rank() over( order by t.bonus desc)
	from(
		select  p.project_manager_id, p2.full_fio, SUM(p.project_cost * 0.01) as bonus
		from project p 
		join employee e on e.employee_id = p.project_manager_id
		join person p2 on p2.person_id = e.person_id
		where p.status = 'Завершен'
		group by p.project_manager_id, p2.full_fio
		order by bonus desc) t) tt
where tt.rank = 1


--7. Получите накопительный итог планируемых авансовых платежей на каждый месяц в отдельности.
--Выведите в результат те даты планируемых платежей, которые идут после преодаления накопительной суммой значения в 30 000 000
--Пример:
--дата		накопление
--2022-06-14	28362946.20
--2022-06-20	29633316.30
--2022-06-23	34237017.30
--2022-06-24	46248120.30
--В результат должна попасть дата 2022-06-23

select tt.plan_payment_date
from (
	select *, row_number() over(partition by date_trunc('month', t.plan_payment_date) order by cum_sum) as r_n
	from (
		select pp.plan_payment_date, SUM(pp.amount) over(partition by date_trunc('month', pp.plan_payment_date) order by pp.plan_payment_date) as cum_sum
		from project_payment pp 
		where pp."payment_type" = 'Авансовый' ) t
	where t.cum_sum > 30000000) tt
where tt.r_n = 1


--8. Используя рекурсию посчитайте сумму фактических окладов сотрудников из структурного подразделения с id равным 17 и всех дочерних подразделений.
--В результат вывести одно значение суммы.

with recursive rec as (
	select *, 1 as level
	from company_structure cs 
	where cs.unit_id = 17
	union all
	select cs2.*, level + 1 as level
	from rec
	join company_structure cs2 on rec.unit_id = cs2.parent_id
	)
select SUM(salary * rate)
from rec cs
join "position" p on cs.unit_id = p.unit_id
join employee_position ep on ep.position_id = p.position_id


--9. Задание выполняется одним запросом.
--
--Сделайте сквозную нумерацию фактических платежей по проектам на каждый год в отдельности в порядке даты платежей.
--Получите платежи, сквозной номер которых кратен 5.
--Выведите скользящее среднее размеров платежей с шагом 2 строки назад и 2 строки вперед от текущей.
--Получите сумму скользящих средних значений.
--Получите сумму проектов на каждый год.
--Выведите в результат значение года (годов) и сумму проектов, где сумма проектов меньше, чем сумма скользящих средних значений.

with cte as(
	select SUM(tt.moving_avg) as sum_moving_avg
	from(
		select *, avg(amount ) over(order by t.fact_transaction_timestamp rows between 2 PRECEDING AND 2 FOLLOWING) as moving_avg
			from(
			select *,
				row_number() over(partition by date_trunc('year', pp.fact_transaction_timestamp) order by  pp.fact_transaction_timestamp) as rn
			from project_payment pp
			where pp.fact_transaction_timestamp is not null) t
		where (rn % 5 = 0)
		) tt
		),
cte2 as (
	select extract(year from sign_date) as year, sum(project_cost) as sum_project_cost
	from project p 
	group by extract(year from sign_date))
select cte2.year, cte2.sum_project_cost
from cte2, cte
where cte2.sum_project_cost < cte.sum_moving_avg


--10. Создайте материализованное представление, которое будет хранить отчет следующей структуры:
--идентификатор проекта
--название проекта
--дата последней фактической оплаты по проекту
--размер последней фактической оплаты
--ФИО руководителей проектов
--Названия контрагентов
--В виде строки названия типов работ контрагентов

CREATE MATERIALIZED VIEW last_payments as
select  p.project_id,
		p.project_name,
		lp.date,
		lp.amount,
		p2.full_fio as project_manager_name,
		ctow.customer_name,
		ctow.type_of_works_name
from project p 
join (
	select  project_id, 
			fact_transaction_timestamp::date AS date, 
			amount,
			row_number() over(partition by project_id order by fact_transaction_timestamp desc) as rn
	from project_payment pp
	where fact_transaction_timestamp is not null) as lp on lp.project_id = p.project_id and lp.rn = 1
join employee e on p.project_manager_id = e.employee_id
join person p2 on e.person_id = p2.person_id
left join (
	select c.customer_id,
		c.customer_name,
		string_agg(type_of_work_name, ', ') as type_of_works_name
	from customer c 
	join customer_type_of_work ctow on c.customer_id = ctow.customer_id
	join type_of_work tow on ctow.type_of_work_id = tow.type_of_work_id
	group by  c.customer_id
) ctow on p.customer_id = ctow.customer_id

select *
from last_payments

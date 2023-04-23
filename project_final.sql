--1. Выведите название самолетов, которые имеют менее 50 посадочных мест?

select a.model, count(seat_no) as "Число посадочных мест"
from seats s
join aircrafts a ON s.aircraft_code = a.aircraft_code
group by a.model 
having count(seat_no) < 50


--2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

with cte as(
	select date_trunc('month', b.book_date) month_payments ,
	sum(b.total_amount) pay_for_month
	from bookings b
	group by month_payments
	order by month_payments)
select 
	b.month_payments as month_of_booking,
	round(100.0*(b.pay_for_month - c.pay_for_month)/c.pay_for_month, 2) as change_percent
from cte c
right join cte b ON c.month_payments = b.month_payments - interval '1 month'


--3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

select t.model
from (
	select 	a.model,
	array_agg(fare_conditions)
	from seats s
	join aircrafts a on a.aircraft_code = s.aircraft_code 
	group by a.model)t
where not 'Business' = any(array_agg)
	

--4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день,
-- учитывая только те самолеты, которые летали пустыми и только те дни,
-- где из одного аэропорта таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата, количество пустых мест и накопительный итог.

with cte1 as (
	select *,
		   count(f.aircraft_code) over(partition by f.departure_airport, f.actual_departure::date  order by f.actual_departure::date) ccc
	from boarding_passes bp
	right join flights f on f.flight_id =bp.flight_id 
	where bp.boarding_no is null and (f.status = 'Departed' or f.status = 'Arrived')),
cte2 as (
	select *
	from cte1
	where ccc>1),
cte3 as(
	select
		s.aircraft_code,
		count(*) as seat
	from seats s
	group by s.aircraft_code),
cte4 as(
	select
		cte2.departure_airport,
		cte2.actual_departure,
		cte3.seat
	from cte2
	join cte3 on cte3.aircraft_code = cte2.aircraft_code
	order by cte2.departure_airport, cte2.actual_departure)
select *,
	sum(cte4.seat) over(partition by cte4.departure_airport, cte4.actual_departure::date order by cte4.actual_departure)
from cte4


--5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.

with cte as (
	select *,
		count(f.flight_no) over(partition by f.flight_no) as a1,
		count(f.flight_id) over() as a2
	from flights f
	group by f.flight_no, f.flight_id),
cte2 as ( 
	select a.airport_name as otkuda,
			a2.airport_name as kuda,
		round((a1*100)/a2::numeric, 2) as procent
	from cte
	join airports a ON a.airport_code = cte.departure_airport
	left join airports a2 ON cte.arrival_airport = a2.airport_code
	group by a.airport_name, a2.airport_name, cte.a1, cte.a2)
select *
from cte2
order by cte2.otkuda


--6. Выведите количество пассажиров по каждому коду сотового оператора,
-- если учесть, что код оператора - это три символа после +7

select tt.kod,
		count(tt.passenger_id) 
from ( select substring(t.phone, 3, 3) as kod,
		t.passenger_id 
		from (
			select passenger_id,
			t.contact_data ->> 'phone' as phone
			from tickets t) t) tt
group by tt.kod
order by tt.kod


--7. Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе.

with cte as(
	select 
	sum(amount),
	case 
		when sum(amount)  < 50000000 then 'low'
		when sum(amount) >= 50000000  and sum(amount) < 150000000 then 'middle'
		else 'high'
		end as rang
	from ticket_flights tf 
	join flights f on tf.flight_id=f.flight_id
	group by f.flight_no)
select cte.rang,
	count(cte.rang)
from cte
group by cte.rang


--8. Вычислите медиану стоимости билетов, медиану размера бронирования и
-- отношение медианы бронирования к медиане стоимости билетов, округленной до сотых.

with cte1 as(
select 
	percentile_cont(0.5) WITHIN GROUP (ORDER BY tf.amount) m_t
from ticket_flights tf),
cte2 as(
select
	percentile_cont(0.5) WITHIN GROUP (ORDER BY b.total_amount) m_b
from bookings b)
select *,
	round(cte2.m_b::numeric /cte1.m_t::numeric , 2)
from cte1, cte2
	

--Найдите значение минимальной стоимости полета 1 км для пассажиров. 
--То есть нужно найти расстояние между аэропортами и с учетом стоимости билетов получить искомый результат
	
with cte1 as(
	select f.flight_id ,
		f.departure_airport ,
		a.latitude as d_a_sh,
		a.longitude as d_a_d,
		f.arrival_airport ,
		a2.latitude as a_a_sh,
		a2.longitude as a_a_d
	from flights f
	join airports a on a.airport_code = f.departure_airport 
	join airports a2 on a2.airport_code = f.arrival_airport),
cte2 as(
	select cte1.flight_id,
			earth_distance(
			ll_to_earth(cte1.d_a_sh, cte1.d_a_d),
			ll_to_earth(cte1.a_a_sh, cte1.a_a_d))/1000 as distance_km
	from cte1),
cte3 as(
	select tf.flight_id ,
	min(tf.amount) as min_p
	from ticket_flights tf 
	group by tf.flight_id)
select 
	cte3.min_p/distance_km as min_price
from cte2
join cte3 on cte3.flight_id = cte2.flight_id
order by cte3.min_p/distance_km
limit(1)



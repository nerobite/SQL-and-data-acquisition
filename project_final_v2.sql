--1. Выведите название самолетов, которые имеют менее 50 посадочных мест?

select a.model, count(seat_no) as "Число посадочных мест"
from seats s
join aircrafts a ON s.aircraft_code = a.aircraft_code
group by a.model 
having count(seat_no) < 50


--2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
explain analyze  --73

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

explain analyze --72

select month as "Месяц", 
    round(((new_sum - old_sum) / old_sum) * 100, 2) as "Процентное изменение"
from (
    select date_trunc('month', book_date) as month, 
        sum(total_amount) as new_sum, 
        lag(sum(total_amount)) over (order by date_trunc('month', book_date)) as old_sum
    from bookings
    group by date_trunc('month', book_date)
) as t

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

--Вариант 1
explain analyze --229 min

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

--Вариант 2
explain analyze --219 min

with cte1 as (
	select *,
		   count(f.aircraft_code) over(partition by f.departure_airport, f.actual_departure::date) as ccc
	from boarding_passes bp
	right join flights f on f.flight_id =bp.flight_id 
	where bp.boarding_no is null and (f.status = 'Departed' or f.status = 'Arrived')),
cte3 as(
	select
		s.aircraft_code,
		count(*) as seat
	from seats s
	group by s.aircraft_code),
cte4 as(
	select
		cte1.departure_airport,
		cte1.actual_departure,
		cte3.seat,
		cte1.ccc
	from cte1
	join cte3 on cte3.aircraft_code = cte1.aircraft_code
	order by cte1.departure_airport, cte1.actual_departure)
select 	cte4.departure_airport,
		cte4.actual_departure,
		cte4.seat,
	sum(cte4.seat) over(partition by cte4.departure_airport, cte4.actual_departure::date order by cte4.actual_departure)
from cte4
where ccc > 1


--Вариант 3
explain analyze --265 min

with cte1 as (
	select *,
		   count(f.aircraft_code) over(partition by f.departure_airport, f.actual_departure::date) as ccc
	from boarding_passes bp
	right join flights f on f.flight_id =bp.flight_id 
	where bp.boarding_no is null and (f.status = 'Departed' or f.status = 'Arrived')),
cte3 as(
	select
		s.aircraft_code,
		count(*) as seat
	from seats s
	group by s.aircraft_code)
select 	cte1.departure_airport,
		cte1.actual_departure,
		cte3.seat,
	sum(cte3.seat) over(partition by cte1.departure_airport, cte1.actual_departure::date order by cte1.actual_departure)
from cte1
join cte3 on cte3.aircraft_code = cte1.aircraft_code
where ccc > 1
order by cte1.departure_airport, cte1.actual_departure



--5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.

--Вариант 1
explain analyze --307 min

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


--Вариант 2
explain analyze --420 min

with cte as (
select 
		a.airport_name as otkuda,
		a2.airport_name as kuda,
		round((count(f.flight_no) over(partition by f.flight_no)::numeric*100)/(count(f.flight_id) over())::numeric, 2) as procent
from flights f
join airports a on a.airport_code = f.departure_airport 
right join airports a2 on a2.airport_code = f.arrival_airport 
group by a.airport_name, a2.airport_name, flight_no, flight_id, f.departure_airport, f.arrival_airport, a.airport_code, a2.airport_code
order by departure_airport 
)
select *
from cte
group by cte.otkuda, cte.kuda, cte.procent
order by cte.otkuda
--

--Вариант 3
explain analyze --415 min

select *
from (
select 
		a.airport_name as otkuda,
		a2.airport_name as kuda,
		round((count(f.flight_no) over(partition by f.flight_no)::numeric*100)/(count(f.flight_id) over())::numeric, 2) as procent
from flights f
join airports a on a.airport_code = f.departure_airport 
right join airports a2 on a2.airport_code = f.arrival_airport 
group by a.airport_name, a2.airport_name, flight_no, flight_id, f.departure_airport, f.arrival_airport, a.airport_code, a2.airport_code
order by departure_airport
) t
group by t.otkuda, t.kuda, t.procent
order by t.otkuda


--Вариант 4
explain analyze --362 min

select distinct a.airport_name as otkuda,
		a2.airport_name as kuda,
		round(count(f.flight_no) over(partition by f.flight_no)::numeric *100/count(f.flight_id) over(), 2)  
from flights f
join airports a on f.departure_airport = a.airport_code 
join airports a2 on f.arrival_airport = a2.airport_code 
group by a.airport_name, a2.airport_name, f.flight_no, f.flight_id
order by otkuda

--Вариант 5 финальный
explain analyze -- 180 min

select 	a.airport_name as otkuda,
		a2.airport_name as kuda,
		round(  count(f.flight_id)*100/
				sum(count(f.flight_id)) over(),
		2)
from flights f
join airports a on f.departure_airport = a.airport_code 
join airports a2 on f.arrival_airport = a2.airport_code 
group by a.airport_name, a2.airport_name, f.flight_no
order by otkuda


--6. Выведите количество пассажиров по каждому коду сотового оператора,
-- если учесть, что код оператора - это три символа после +7

--Вариант 1
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

--Вариант 2
select ttt.kod,
		count(ttt.passenger_id) 
from ( select substring(t2.contact_data ->> 'phone', 3, 3) as kod,
		t2.passenger_id 
		from tickets t2 ) ttt
group by ttt.kod
order by ttt.kod


--7. Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе.

--Вариант 1
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


--Вариант 2
select t.class, count(t.class)
from (
select sum(tf.amount),
    case
        when sum(tf.amount) < 50000000 then 'low'
        when sum(tf.amount) >= 50000000 and sum(tf.amount) < 150000000 then 'middle'
        else 'high'
    end as class
from ticket_flights tf
join flights f on f.flight_id = tf.flight_id
group by f.flight_no  ) as t
group by t.class

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
	

--9. Найдите значение минимальной стоимости полета 1 км для пассажиров. 
--То есть нужно найти расстояние между аэропортами и с учетом стоимости билетов получить искомый результат

--Вариант 1
explain analyze	--790 min

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

--Вариант 2
explain analyze --825

with cte as(
	select tf.flight_id ,
	min(tf.amount) as min_p
	from ticket_flights tf 
	group by tf.flight_id)
select cte.min_p*1000/earth_distance(
			ll_to_earth(a.latitude, a.longitude),
			ll_to_earth(a2.latitude, a2.longitude))  as min_price
from flights f 
join airports a on a.airport_code = f.departure_airport 
join airports a2 on a2.airport_code = f.arrival_airport
join cte on cte.flight_id = f.flight_id 
order by cte.min_p/earth_distance(
			ll_to_earth(a.latitude, a.longitude),
			ll_to_earth(a2.latitude, a2.longitude))
limit(1)

-------------------------------------------------------ДОПОЛНИТЕЛЬНЫЕ ЗАДАНИЯ К ИТОГОВОЙ------------------------------------------------
--Сколько суммарно каждый тип самолета провел в воздухе, если брать завершенные перелеты.


select  a.model,
		SUM(f.actual_arrival - f.actual_departure)  as flight_time
from flights f 
join aircrafts a on f.aircraft_code = a.aircraft_code
where f.status = 'Arrived'
group by a.model


--Сколько было получено посадочных талонов по каждой брони.

select b.book_ref, Count(bp.boarding_no)
from bookings b
left join tickets t on b.book_ref = t.book_ref 
left join boarding_passes bp on t.ticket_no = bp.ticket_no 
group by b.book_ref


--Вывести общую сумму продаж по каждому классу билетов

select tf.fare_conditions , sum(amount)
from ticket_flights tf 
group by tf.fare_conditions

--Найти маршрут с наибольшим финансовым оборотом

select f.flight_no, SUM(tf.amount) 
from flights f 
join ticket_flights tf on f.flight_id = tf.flight_id
group by f.flight_no 
order by SUM(tf.amount) desc 
limit (1)


--Найти наилучший и наихудший месяц по бронированию билетов (количество и сумма)

select month_, book_count, sum_amount
from (
	select date_trunc('MONTH', b.book_date)::date as month_,
			count(b.book_ref) as book_count,
			sum(b.total_amount) as sum_amount,
			row_number() over (order by count(b.book_ref)) as rn,
			row_number() over (order by sum(b.total_amount)) as rn2,
			row_number() over (order by count(b.book_ref) desc) as rn_desc,
			row_number() over (order by sum(b.total_amount) desc) as rn_desc2
	from bookings b 
	group by date_trunc('MONTH', b.book_date))t 
where (t.rn = 1 and t.rn2 = 1) or (t.rn_desc=1 and t.rn_desc2=1)


--Между какими городами пассажиры не делали пересадки? Пересадкой считается нахождение пассажира в промежуточном аэропорту менее 24 часов.


with cte as (
select distinct 
	concat(t.city , '-', t.next_city) as pair,
	t.city as first_city,
	t.next_city as second_city
from(
		select  t.passenger_id ,
				a2.city,
				f.actual_arrival,
				lead (a.city) over (partition by t.passenger_id order by a.city) as next_city,
				lead (f.actual_departure) over (partition by t.passenger_id order by f.actual_departure) as next_departure_time
		from flights f
		left join ticket_flights tf on f.flight_id = tf.flight_id 
		left join tickets t on tf.ticket_no = t.ticket_no
		left join airports a on f.departure_airport = a.airport_code
		left join airports a2 on f.arrival_airport = a2.airport_code) t
where t.next_city is not null and (t.next_departure_time - t.actual_arrival) < interval '24 hours' and (t.city <> t.next_city)
order by t.city),
cte2 as(
	select distinct
			concat(a.city , '-', a2.city ) as pair,
			a.city as city_from,
			a2.city as city_to
	from airports a 
	cross join airports a2
	where a.city <> a2.city
	order by a.city, a2.city)
select 
		cte2.city_from,
		cte2.city_to
from cte2
left join cte on cte2.pair = cte.pair
where cte.pair is null


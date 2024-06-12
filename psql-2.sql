--Модуль 2. Домашнее задание по теме "Хранимые процедуры"
--
--Цель домашнего задания:
--
--закрепить навыки создания функций, процедур, триггеров в PostgreSQL
--Все задания следует выполнять в базе данных HR
--
--Задание 1. Напишите функцию, которая принимает на вход название должности (например, стажер), а также даты периода поиска,
-- и возвращает количество вакансий, опубликованных по этой должности в заданный период.
--
create function find_emp(vac_name text, date_start date, date_end date) returns integer as $$
begin
	return
		(select count(vac_id) 
		from vacancy
		where vac_title = vac_name and create_date between date_start and date_end);
end;
$$ language plpgsql

--drop function find_emp(vac_name text, date_start date, date_end date)

select find_emp('руководель проектов', '2012-05-01', '2017-05-01') --49

select find_emp('ведущий разработчик', '2012-05-01', '2017-05-01') --222

create or replace function find_emp(vac_name text, date_start date, date_end date) returns integer as $$
begin
	if date_start is null 
		then date_start = (select min(create_date::date) from vacancy);
	end if;	
	if date_end is null 
		then date_end = (select max(create_date::date) from vacancy);
	end if;
	if date_start > date_end
		then raise exception 'Дата начала % больше, чем дата окончания %', date_start, date_end;
	end if;
	return (
		select count(vac_id) 
		from vacancy
		where vac_title = vac_name and create_date between date_start and date_end);
end;
$$ language plpgsql


select find_emp('руководель проектов', '2012-05-01', NULL) --80

select find_emp('руководель проектов', NULL, '2017-05-01')--63

select find_emp('ведущий разработчик', '2017-05-01', '2012-05-01') --SQL Error [P0001]: ОШИБКА: Дата начала 2017-05-01 больше, чем дата окончания 2012-05-01
 -- Где: функция PL/pgSQL find_emp(text,date,date), строка 10, оператор RAISE

--Задание 2. Напишите триггер, срабатывающий тогда, когда в таблицу position добавляется значение grade,
-- которого нет в таблице-справочнике grade_salary. Триггер должен возвращать предупреждение пользователю о несуществующем значении grade.
--

create or replace function grade_tg() returns trigger as $$
begin
	IF NEW.grade NOT IN (SELECT grade FROM grade_salary)
		THEN RAISE EXCEPTION 'Грейда % не существует', NEW.grade;
	else return new;
	end if;
end;
$$ language plpgsql

create trigger grade_tg 
before INSERT or update on hr."position"  
for each row execute function grade_tg()

--drop trigger grade_tg on "position"

select *
from "position" p 
where pos_id = 1

update "position" 
set grade = '1'
where pos_id = 1
--SQL Error [P0001]: ОШИБКА: Грейда 1 не существует
--  Где: функция PL/pgSQL grade_tg(), строка 4, оператор RAISE

update "position" 
set grade = '2'
where pos_id = 1

update "position" 
set grade = null
where pos_id = 1

insert into "position" (pos_id, pos_title, pos_category, unit_id, grade, address_id, manager_pos_id)
	values(4592, 'QA-инженер', null,  204, 1, 20, 4568)
--	SQL Error [P0001]: ОШИБКА: Грейда 1 не существует
--  Где: функция PL/pgSQL grade_tg(), строка 4, оператор RAISE

--Задание 3. Создайте таблицу employee_salary_history с полями:
--
--emp_id - id сотрудника
--salary_old - последнее значение salary (если не найдено, то 0)
--salary_new - новое значение salary
--difference - разница между новым и старым значением salary
--last_update - текущая дата и время
--Напишите триггерную функцию, которая срабатывает при добавлении новой записи о сотруднике или при обновлении значения salary в таблице employee_salary, и заполняет таблицу employee_salary_history данными.
--
CREATE TABLE employee_salary_history (
    emp_id INT NOT NULL,
    salary_old DECIMAL(10, 2) DEFAULT 0,
    salary_new DECIMAL(10, 2),
    difference DECIMAL(10, 2),
    last_update TIMESTAMP
);


create or replace function salary_tg() returns trigger as $$
declare last_salary DECIMAL(10, 2);
begin
	if tg_op = 'INSERT' then
		last_salary := (
			select salary 
			from employee_salary
			where emp_id = new.emp_id and effective_from = (
						select effective_from
						from employee_salary
						where emp_id = new.emp_id
						order by effective_from desc
						offset 1 limit 1));
		if last_salary is null then
            last_salary = 0;
        end if;
		insert into employee_salary_history (emp_id, salary_old, salary_new, difference, last_update )
	    values (new.emp_id, last_salary, new.salary, new.salary-last_salary, now());
	elsif tg_op = 'UPDATE'
		then 
			insert into employee_salary_history (emp_id, salary_old, salary_new, difference, last_update )
			values (old.emp_id, old.salary, new.salary, new.salary-old.salary, now());	
	end if;
	return null;
end;
$$ language plpgsql

create trigger salery_trigger 
after insert or update on hr.employee_salary 
for each row execute function salary_tg()

select salary
from employee_salary
where emp_id = 2 and effective_from = (select max(effective_from) from employee_salary where emp_id = 2)


update employee_salary 
set salary = 20000
where emp_id = 1

update employee_salary 
set salary = 15000
where emp_id = 2 and order_id = 30000

select *
from employee_salary
where emp_id = 2

insert into employee_salary (order_id, emp_id, salary, effective_from)
	values(30000, 2, 21300, now()::date)
	
DELETE FROM employee_salary
WHERE order_id  IN (30005, 30004, 30003, 30002, 30001, 30000);
	
DELETE FROM employee_salary_history
WHERE emp_id = 2


--employee_salary_history
--1	12130.00	20000.00	7870.00	2024-06-05 08:35:49.645
--2	0.00	150000.00	150000.00	2024-06-05 08:39:14.205
--2	150000.00	15000.00	-135000.00	2024-06-05 10:37:12.298	
	
--Задание 4. Напишите процедуру, которая содержит в себе транзакцию на вставку данных в таблицу employee_salary.
-- Входными параметрами являются поля таблицы employee_salary.


create procedure add_salary(order_val int, emp_val int, salary_val numeric, effective_from_val date) as $$
	begin 
		insert into employee_salary (order_id , emp_id, salary, effective_from)
			values (order_val, emp_val, salary_val, effective_from_val);
			commit;	
	end;
$$ language plpgsql;

call add_salary(30001, 2, 30000, now()::date) 

--employee_salary
--25001	1	20000.00
--30001	2	30000.00
--30000	2	15000.00
--25002	2	12130.00
--25003	2	10311.00
--25004	2	8662.00
--25005	2	7103.00


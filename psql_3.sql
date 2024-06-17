CREATE TABLE employee (
    id_emp SERIAL PRIMARY KEY,
    person_id INTEGER REFERENCES person(person_id),
    id_pos INTEGER REFERENCES positions(id_pos),
    manager_id INTEGER,
    salary integer,
    start_date date
   );
  
CREATE TABLE person ( 
	person_id SERIAL PRIMARY key,
    first_name VARCHAR(100) not null,
    last_name VARCHAR(100) not null,
    birth_date DATE,
    email VARCHAR(100),
    id_street INTEGER REFERENCES adress(id_street),
    house_number VARCHAR(10)
);

INSERT INTO person (first_name, last_name, birth_date, email, id_street, house_number)
VALUES ('Mary', 'Roberts', '15.07.1975', 'MaryRoberts@default.com', 1, 'GL1')	

INSERT INTO person (first_name, last_name, birth_date, email, id_street, house_number)
VALUES ('Leon', 'Mitchell', '27.09.1970', 'LeonMitchell@default.com', 1, 'GB4')	

--DELETE FROM person WHERE person_id = 3
	  

CREATE TABLE departments (
    id_dep SERIAL PRIMARY KEY,
    name VARCHAR(100) not null,
    id_street INTEGER REFERENCES adress(id_street),
    house_number VARCHAR(10)
);

INSERT INTO departments (name, id_street, house_number)
VALUES ('Design', 2, 'W1D')	 

CREATE TABLE positions (
    id_pos SERIAL PRIMARY KEY,
    name VARCHAR(100),
    id_dep INTEGER REFERENCES departments(id_dep)
);

INSERT INTO positions (name, id_dep)
VALUES ('Graphic Designer', 1)

INSERT INTO person (first_name, last_name, birth_date, email, id_street, house_number)
VALUES ('Mary', 'Roberts', '15.07.1975', 'MaryRoberts@default.com', 1, 'GL1')

CREATE TABLE city (
    id_city SERIAL PRIMARY KEY,
    city VARCHAR(100)
);

INSERT INTO city (city)
VALUES ('Bradford')

CREATE TABLE adress (
    id_street SERIAL PRIMARY KEY,
    street VARCHAR(100),
    id_city INTEGER REFERENCES city(id_city)
);
	  
INSERT INTO adress (street, id_city)
VALUES ('72 Shaw Land Lake Holly', 1)

INSERT INTO adress (street, id_city)
VALUES ('113 Meadow Freyaview', 1)


CREATE TABLE salary_history (
    order_id SERIAL PRIMARY KEY,
    id_emp INTEGER REFERENCES employee(id_emp),
    id_pos INTEGER REFERENCES positions(id_pos),
    salary DECIMAL,
    start_date DATE,
    end_date DATE,
    change_date DATE
);


create or replace function salary_foo() returns trigger as $$
begin
  if tg_op = 'INSERT' and new.person_id in (select person_id from employee) then
    INSERT INTO salary_history (id_emp, id_pos, salary, start_date, change_date)
    SELECT id_emp, id_pos, salary, start_date, now()
    FROM employee
    WHERE person_id = NEW.person_id;
    	set session_replication_role = replica; --отключаем для нашей сессии работу триггеров
    update employee
    set salary = new.salary, start_date = new.start_date, id_pos = new.id_pos, manager_id = new.manager_id
    where person_id = new.person_id;
    	set session_replication_role = default; --включаем для нашей сессии работу триггеров
    return null;
  elseif tg_op = 'UPDATE' then
    insert into salary_history (id_emp, id_pos, salary, start_date, change_date)
	values (OLD.id_emp, OLD.id_pos, OLD.salary, OLD.start_date, now());
    return new;
  elseif  tg_op = 'DELETE' then
  	insert into salary_history (id_emp, id_pos, salary, start_date, change_date)
	values (OLD.id_emp, OLD.id_pos, OLD.salary, OLD.start_date, now());
	return old;
  else
  return new;
  end if;
end;
$$ language plpgsql;

create trigger salary_trigger
before insert or update on employee
for each row execute function salary_foo();

create trigger salary_delete_trigger
after delete on employee
for each row execute function salary_foo();

DROP TRIGGER IF EXISTS salary_trigger ON employee;

DROP TRIGGER IF EXISTS salary_delete_trigger ON employee;


ALTER TABLE public.employee DISABLE TRIGGER salery_trigger;

ALTER TABLE public.employee ENABLE TRIGGER salery_trigger;

INSERT INTO employee (person_id, id_pos, manager_id, salary, start_date)
VALUES (1, 1, 2, 17000, '20.08.2017') 

DELETE FROM employee WHERE person_id = 1

INSERT INTO employee (person_id, id_pos, manager_id, salary, start_date)
VALUES (1, 1, 2, 18500, '21.02.2019') 
  

DELETE FROM employee WHERE person_id = 1

update employee
set salary = 23500, start_date = '01.01.2021'
where person_id = 1
 

TRUNCATE TABLE employee;

TRUNCATE TABLE salary_history;
	  
	  
	  
	  
	  
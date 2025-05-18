--Домашнее задание к лекции «Продвинутая выборка данных»
--Задание 1
--Продолжаем работать со своей базой данных. В этом задании заполните базу данных из домашнего задания к занятию "Работа с SQL. Создание БД". В ней должно быть:
--
--не менее 4 исполнителей,
--не менее 3 жанров,
--не менее 3 альбомов,
--не менее 6 треков,
--не менее 4 сборников.
--Внимание: должны быть заполнены все поля каждой таблицы, в том числе таблицы связей исполнителей с жанрами, исполнителей с альбомами, сборников с треками.

-- Вставка жанров (не менее 6)
INSERT INTO genres (name) VALUES 
('Rock'), ('Pop'), ('Hip-Hop'), ('Jazz'), ('Electronic'), ('Classical'), ('Country');

-- Вставка исполнителей (не менее 14)
INSERT INTO performers (nickname) VALUES 
('The Beatles'), ('Queen'), ('Eminem'), ('Madonna'), ('Mozart'), 
('Beyoncé'), ('Drake'), ('Coldplay'), ('Adele'), ('Kanye'), 
('Taylor Swift'), ('BTS'), ('Ed Sheeran'), ('Rihanna'), ('Elvis');

-- Вставка связей исполнителей с жанрами
INSERT INTO genre_performer (performer_id, genre_id) VALUES 
(1, 1), (1, 2),  -- The Beatles (Rock, Pop)
(2, 1),           -- Queen (Rock)
(3, 3),           -- Eminem (Hip-Hop)
(4, 2),           -- Madonna (Pop)
(5, 6),           -- Mozart (Classical)
(6, 2), (6, 3),   -- Beyoncé (Pop, Hip-Hop)
(7, 3),           -- Drake (Hip-Hop)
(8, 1), (8, 2),   -- Coldplay (Rock, Pop)
(9, 2),           -- Adele (Pop)
(10, 3), (10, 5), -- Kanye (Hip-Hop, Electronic)
(11, 2), (11, 7), -- Taylor Swift (Pop, Country)
(12, 2),          -- BTS (Pop)
(13, 2), (13, 7), -- Ed Sheeran (Pop, Country)
(14, 2), (14, 3), -- Rihanna (Pop, Hip-Hop)
(15, 1), (15, 7); -- Elvis (Rock, Country)

-- Вставка альбомов (не менее 8)
INSERT INTO albums (title, year) VALUES 
('Abbey Road', 1969),
('A Night at the Opera', 1975),
('The Marshall Mathers LP', 2000),
('Like a Virgin', 1984),
('Requiem', 1791),
('Lemonade', 2016),
('Scorpion', 2018),
('Parachutes', 2000),
('21', 2011),
('Folklore', 2020),
('Map of the Soul: 7', 2020),
('÷', 2017),
('Anti', 2016),
('Elvis Presley', 1956);

-- Вставка связей исполнителей с альбомами
INSERT INTO performer_album (performer_id, album_id) VALUES 
(1, 1),   -- The Beatles - Abbey Road
(2, 2),   -- Queen - A Night at the Opera
(3, 3),   -- Eminem - The Marshall Mathers LP
(4, 4),   -- Madonna - Like a Virgin
(5, 5),   -- Mozart - Requiem
(6, 6),   -- Beyoncé - Lemonade
(7, 7),   -- Drake - Scorpion
(8, 8),   -- Coldplay - Parachutes
(9, 9),   -- Adele - 21
(11, 10), -- Taylor Swift - Folklore
(12, 11), -- BTS - Map of the Soul: 7
(13, 12), -- Ed Sheeran - ÷
(14, 13), -- Rihanna - Anti
(15, 14); -- Elvis - Elvis Presley

-- Вставка треков (не менее 16, с разной продолжительностью и 2 с "мой"/"my")
INSERT INTO tracks (album_id, title, duration) VALUES 
-- Abbey Road (менее 3.5 минут)
(1, 'Come Together', '00:04:20'),
(1, 'Something', '00:03:03'),
(1, 'Octopus''s Garden', '00:02:51'),
(1, 'Here Comes the Sun', '00:03:05'),

-- A Night at the Opera (более 3.5 минут)
(2, 'Bohemian Rhapsody', '00:05:55'),
(2, 'You''re My Best Friend', '00:02:52'),  -- с "my"

-- The Marshall Mathers LP
(3, 'The Real Slim Shady', '00:04:44'),
(3, 'Stan', '00:06:44'),

-- Like a Virgin
(4, 'Like a Virgin', '00:03:38'),
(4, 'Material Girl', '00:04:00'),

-- Requiem
(5, 'Lacrimosa', '00:03:40'),

-- Lemonade
(6, 'Formation', '00:03:26'),
(6, 'Sorry', '00:03:52'),

-- Scorpion
(7, 'God''s Plan', '00:03:19'),
(7, 'In My Feelings', '00:03:38'),  -- с "my"

-- Parachutes
(8, 'Yellow', '00:04:27');

-- Вставка сборников (не менее 6, в период 2015-2020)
INSERT INTO compendium (name, year) VALUES 
('Greatest Hits 2015', 2015),
('Pop Classics 2016', 2016),
('Hip-Hop Essentials 2017', 2017),
('Rock Anthems 2018', 2018),
('Best of 2019', 2019),
('Chart Toppers 2020', 2020);

-- Вставка связей сборников с треками
INSERT INTO compendium_tracks (track_id, compendium_id) VALUES 
(1, 1), (2, 1),   -- Greatest Hits 2015
(3, 2), (4, 2),   -- Pop Classics 2016
(5, 3), (6, 3),   -- Hip-Hop Essentials 2017
(7, 4), (8, 4),   -- Rock Anthems 2018
(9, 5), (10, 5),  -- Best of 2019
(11, 6), (12, 6), -- Chart Toppers 2020
(13, 1), (14, 2), -- Перекрестные связи
(15, 3), (16, 4);

-- Код закрыл и он почему-то не сохранился, пишу заново, данные уже внесены...


--Задание 2
--Написать SELECT-запросы, которые выведут информацию согласно инструкциям ниже.
--
--Внимание: результаты запросов не должны быть пустыми, учтите это при заполнении таблиц.
--
--Название и продолжительность самого длительного трека.
--Название треков, продолжительность которых не менее 3,5 минут.
--Названия сборников, вышедших в период с 2018 по 2020 год включительно.
--Исполнители, чьё имя состоит из одного слова.
--Название треков, которые содержат слово «мой» или «my».

--Название и продолжительность самого длительного трека.
select t.title, t.duration
from tracks t 
order by t.duration desc 
limit 1

Stan	00:06:44

--Название треков, продолжительность которых не менее 3,5 минут.

select t.title
from tracks t 
where t.duration >= make_time(0, 3, 30)

Come Together
Bohemian Rhapsody
The Real Slim Shady
Stan
Like a Virgin
Material Girl
Lacrimosa
Sorry
In My Feelings
Yellow
the 1
cardigan
the last great american dynasty
exile (feat. Bon Iver)
my tears ricochet
august
Boy With Luv (feat. Halsey)
Make It Right
Dionysus
Interlude: Shadow
My Time
We are Bulletproof: the Eternal

--Названия сборников, вышедших в период с 2018 по 2020 год включительно.

select c."name"
from compendium c 
where "year" between '2018' and '2020'

Rock Anthems 2018
Best of 2019
Chart Toppers 2020

--Исполнители, чьё имя состоит из одного слова.

select p.nickname
from performers p 
where p.nickname not ilike '% %'

Queen
Eminem
Madonna
Mozart
Beyoncé
Drake
Coldplay
Adele
Kanye
BTS
Rihanna
Elvis

--Название треков, которые содержат слово «мой» или «my».

select t.title
from tracks t 
where t.title ilike '%my%' or t.title ilike '%мой%'

Youre My Best Friend
In My Feelings
my tears ricochet
My Time

--Задание 3
--Написать SELECT-запросы, которые выведут информацию согласно инструкциям ниже.
--
--Внимание: результаты запросов не должны быть пустыми, при необходимости добавьте данные в таблицы.
--
--Количество исполнителей в каждом жанре.
--Количество треков, вошедших в альбомы 2019–2020 годов.
--Средняя продолжительность треков по каждому альбому.
--Все исполнители, которые не выпустили альбомы в 2020 году.
--Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).

--Количество исполнителей в каждом жанре.

select g."name", COUNT(performer_id )
from genre_performer gp 
join genres g on gp.genre_id = g.genre_id
group by g.genre_id 

Pop	9
Hip-Hop	5
Electronic	1
Classical	1
Country	3
Rock	4

--Количество треков, вошедших в альбомы 2019–2020 годов.

select a.title, count(t.track_id)
from tracks t 
join albums a on t.album_id = a.album_id
where a."year" between '2019' and '2020'
group by a.album_id

Folklore	8
Map of the Soul: 7	10

--Средняя продолжительность треков по каждому альбому.

select a.title, avg(t.duration)
from tracks t 
join albums a on a.album_id = t.album_id
group by a.album_id 

Folklore	00:03:57.125
A Night at the Opera	00:04:23.5
The Marshall Mathers LP	00:05:44
Requiem	00:03:40
Parachutes	00:04:27
Like a Virgin	00:03:49
Lemonade	00:03:39
Map of the Soul: 7	00:03:40.3
Scorpion	00:03:28.5
Abbey Road	00:03:19.75

--Все исполнители, которые не выпустили альбомы в 2020 году.

select p.nickname
from performers p 
where p.nickname not in (
		select p.nickname
		from performer_album pa 
		join albums a on a.album_id = pa.album_id
		join performers p on p.performer_id = pa.performer_id
		where a."year" = '2020')
		
The Beatles
Queen
Eminem
Madonna
Mozart
Beyoncé
Drake
Coldplay
Adele
Kanye
Ed Sheeran
Rihanna
Elvis
		
--Названия сборников, в которых присутствует конкретный исполнитель (выберите его сами).

select c."name"
from compendium c 
where c."name" ilike '%Taylor Swift%'

Top charts with Taylor Swift

--insert into compendium (compendium_id, "name", "year")
--values (7, 'Top charts with Taylor Swift', '2022')
--
--insert into compendium_tracks (id, track_id, compendium_id)
--values (17, 17, 7)

--Задание 4(необязательное)
--Написать SELECT-запросы, которые выведут информацию согласно инструкциям ниже.
--
--Внимание: результаты запросов не должны быть пустыми, при необходимости добавьте данные в таблицы.
--
--Названия альбомов, в которых присутствуют исполнители более чем одного жанра.
--Наименования треков, которые не входят в сборники.
--Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, — теоретически таких треков может быть несколько.
--Названия альбомов, содержащих наименьшее количество треков.

--Названия альбомов, в которых присутствуют исполнители более чем одного жанра.

select a.title
from albums a 
join performer_album pa on pa.album_id = a.album_id
join performers p  on p.performer_id = pa.performer_id
join genre_performer gp on p.performer_id = gp.performer_id
join genres g on g.genre_id = gp.genre_id
group by a.title 
having COUNT(g.genre_id) > 1

Anti
÷
Abbey Road
Folklore
Elvis Presley
Parachutes
Lemonade

--Наименования треков, которые не входят в сборники.

select t.title
from tracks t 
where t.track_id not in (select ct.track_id from compendium_tracks ct )

cardigan
the last great american dynasty
exile (feat. Bon Iver)
my tears ricochet
mirrorball
seven
august
Intro: Persona
Boy With Luv (feat. Halsey)
Make It Right
Dionysus
Interlude: Shadow
Black Swan
Filter
My Time
We are Bulletproof: the Eternal
Outro: Ego

--Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, — теоретически таких треков может быть несколько.

select t.nickname
from (
	select *, dense_rank() over(order by duration) as r
	from tracks t
	join performer_album pa on t.album_id = pa.album_id
	join performers p on pa.performer_id = p.performer_id) t
where r = 1

The Beatles

--Названия альбомов, содержащих наименьшее количество треков.
select tt.title
from (
	select t.title, dense_rank() over(order by c) as rank
	from (
		select a.title, COUNT(t.track_id) as c
		from tracks t
		join albums a on  t.album_id = a.album_id
		group by a.album_id
		order by c) t) tt
where tt.rank = 1

Requiem
Parachutes

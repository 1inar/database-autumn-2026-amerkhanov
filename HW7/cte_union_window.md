# Домашнее задание 6: CTE, UNION/INTERSECT/EXCEPT и оконные функции

## Часть 0. Добавление данных (Данные я просил сгенерировать ИИ)

Чтобы все запросы возвращали непустой результат, в базу добавлены новые пользователи, стихи, жанровые связи, комментарии и оценки.

```sql
-- Новые пользователи (последние двое только читают, стихов не пишут)
INSERT INTO users (username, email, registration_date, bio) VALUES
('Сергей Есенин', 'esenin@mail.ru', '2023-05-12', 'Русский лирик, певец русской деревни'),
('Александр Блок', 'blok@mail.ru', '2023-06-18', 'Один из крупнейших поэтов Серебряного века'),
('Владимир Маяковский', 'mayakovsky@gmail.com', '2023-07-22', 'Поэт-футурист'),
('Фёдор Тютчев', 'tyutchev@mail.ru', '2023-08-30', 'Поэт-философ, мастер пейзажной лирики'),
('Анна Читателева', 'reader1@mail.ru', '2023-09-14', 'Читатель'),
('Пётр Читатель', 'reader2@gmail.com', '2023-10-01', 'Читатель');

-- Новые стихотворения (у некоторых совпадают даты публикации)
INSERT INTO poems (title, poem_text, publication_date, author_id) VALUES
('Гой ты, Русь, моя родная', 'Гой ты, Русь, моя родная...', '2024-05-10', 5),
('Не жалею, не зову, не плачу', 'Не жалею, не зову, не плачу...', '2024-06-02', 5),
('Ночь, улица, фонарь, аптека', 'Ночь, улица, фонарь, аптека...', '2024-06-02', 6),
('Незнакомка', 'По вечерам над ресторанами...', '2024-07-14', 6),
('Послушайте!', 'Послушайте! Ведь, если звёзды зажигают...', '2024-07-14', 7),
('Лиличка!', 'Дым табачный воздух выел...', '2024-08-21', 7),
('Silentium!', 'Молчи, скрывайся и таи...', '2024-09-05', 8),
('Люблю грозу в начале мая', 'Люблю грозу в начале мая...', '2024-10-01', 8),
('Зимнее утро', 'Мороз и солнце; день чудесный!..', '2024-11-03', 1),
('Я входил вместо дикого зверя в клетку', 'Я входил вместо дикого зверя в клетку...', '2024-11-20', 3);

INSERT INTO poem_genres (poem_id, genre_id) VALUES
(5, 1), (5, 4), (6, 1), (7, 2), (7, 3), (8, 1), (9, 3),
(10, 1), (11, 2), (12, 4), (12, 1), (13, 4), (14, 2);

-- Фиксируем время старых комментариев, чтобы результаты не зависели от момента запуска
UPDATE comments SET created_at = '2024-01-12 12:00' WHERE comment_id = 1;
UPDATE comments SET created_at = '2024-02-18 14:30' WHERE comment_id = 2;
UPDATE comments SET created_at = '2024-03-22 16:45' WHERE comment_id = 3;
UPDATE comments SET created_at = '2024-04-27 10:00' WHERE comment_id = 4;

INSERT INTO comments (comment_text, user_id, poem_id, created_at) VALUES
('Прекрасные строки', 1, 5, '2024-05-12 10:15'),
('Очень по-есенински', 2, 5, '2024-05-12 18:40'),
('Люблю эти стихи', 3, 5, '2024-05-14 09:05'),
('Тоска и ритм', 4, 7, '2024-06-05 21:30'),
('Классика', 1, 7, '2024-06-06 08:00'),
('Загадочно', 2, 8, '2024-07-16 12:00'),
('Сильно сказано', 3, 9, '2024-07-20 15:45'),
('Нежно', 5, 10, '2024-08-25 19:20'),
('Глубоко', 2, 11, '2024-09-07 11:11'),
('Весна в строках', 1, 12, '2024-10-03 07:50'),
('Дождь за окном', 4, 12, '2024-10-04 20:10'),
('Холодно и красиво', 9, 13, '2024-11-05 09:30');

INSERT INTO ratings (score, user_id, poem_id) VALUES
(4, 2, 4), (3, 3, 4),
(5, 1, 5), (4, 2, 5), (3, 3, 5),
(3, 2, 6), (4, 4, 6), (4, 7, 6),
(4, 1, 7), (5, 3, 7), (2, 5, 7),
(5, 2, 8), (4, 5, 8), (3, 9, 8),
(3, 1, 9), (2, 4, 9), (4, 10, 9),
(4, 3, 10), (4, 6, 10), (5, 9, 10),
(5, 2, 11), (3, 7, 11), (4, 10, 11),
(5, 1, 12), (5, 4, 12), (4, 6, 12), (5, 9, 12),
(3, 3, 13), (4, 5, 13),
(4, 1, 14), (4, 2, 14), (3, 8, 14);
```


## Часть 1. CTE (WITH)

### Запрос 1.1. Что хотим получить
Стихи со средней оценкой выше 4 и количеством оценок (простое CTE со статистикой по стихам).

```sql
WITH poem_stats AS (
    SELECT poem_id, COUNT(*) AS ratings_count, ROUND(AVG(score), 2) AS avg_score
    FROM ratings
    GROUP BY poem_id
)
SELECT p.title, ps.ratings_count, ps.avg_score
FROM poems p
JOIN poem_stats ps ON p.poem_id = ps.poem_id
WHERE ps.avg_score > 4
ORDER BY ps.avg_score DESC, p.title;
```

Результат выполнения запроса:

<img width="569" height="238" alt="image" src="https://github.com/user-attachments/assets/952a0a87-f2c4-4de2-85a4-70cdb9eb4b3f" />

### Запрос 1.2. Что хотим получить
Для каждого автора вывести число стихов и среднюю оценку его стихов (два CTE, соединённые между собой).

```sql
WITH author_poems AS (
    SELECT author_id, COUNT(*) AS poems_count
    FROM poems
    GROUP BY author_id
),
author_ratings AS (
    SELECT p.author_id, ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.author_id
)
SELECT u.username, ap.poems_count, ar.avg_score
FROM users u
JOIN author_poems ap ON u.user_id = ap.author_id
JOIN author_ratings ar ON u.user_id = ar.author_id
ORDER BY ar.avg_score DESC, u.username;
```

Результат выполнения запроса:

<img width="523" height="255" alt="image" src="https://github.com/user-attachments/assets/7527863d-88bf-4bf7-86a1-31e4cfc45b2e" />

### Запрос 1.3. Что хотим получить
Количество опубликованных стихов по каждому месяцу 2024 года, включая месяцы без публикаций (рекурсивное CTE генерирует календарь).

```sql
WITH RECURSIVE months(month_start) AS (
    SELECT DATE '2024-01-01'
    UNION ALL
    SELECT (month_start + INTERVAL '1 month')::date
    FROM months
    WHERE month_start < DATE '2024-12-01'
)
SELECT
    TO_CHAR(m.month_start, 'YYYY-MM') AS month,
    COUNT(p.poem_id) AS poems_published
FROM months m
LEFT JOIN poems p ON DATE_TRUNC('month', p.publication_date) = m.month_start
GROUP BY m.month_start
ORDER BY m.month_start;
```

Результат выполнения запроса:

<img width="396" height="276" alt="image" src="https://github.com/user-attachments/assets/59f06ade-317d-4743-af02-4e5e7c7b7e5c" />

## Часть 2. UNION, INTERSECT, EXCEPT

### Запрос 2.1. Что хотим получить
UNION: все пользователи, которые писали стихи или оставляли комментарии (без дублей).

```sql
SELECT u.username
FROM users u
JOIN poems p ON u.user_id = p.author_id
UNION
SELECT u.username
FROM users u
JOIN comments c ON u.user_id = c.user_id
ORDER BY username;
```

Результат выполнения запроса:

<img width="300" height="246" alt="image" src="https://github.com/user-attachments/assets/0293c163-5c6a-4fd2-87ab-154ce89a607c" />


### Запрос 2.2. Что хотим получить
INTERSECT: пользователи, которые и пишут стихи, и ставят оценки.

```sql
SELECT u.username
FROM users u
JOIN poems p ON u.user_id = p.author_id
INTERSECT
SELECT u.username
FROM users u
JOIN ratings r ON u.user_id = r.user_id
ORDER BY username;
```

Результат выполнения запроса:

<img width="340" height="240" alt="image" src="https://github.com/user-attachments/assets/0acea016-dc8e-4d19-8389-74438f92b7d8" />

### Запрос 2.3. Что хотим получить
EXCEPT: пользователи, которые не написали ни одного стихотворения (только читатели).

```sql
SELECT username
FROM users
EXCEPT
SELECT u.username
FROM users u
JOIN poems p ON u.user_id = p.author_id
ORDER BY username;
```

Результат выполнения запроса:

<img width="270" height="155" alt="image" src="https://github.com/user-attachments/assets/e3cf3786-414a-48af-b5e5-8eac1e1ce772" />

## Часть 3. Оконные функции: PARTITION BY

### Запрос 3.1. Что хотим получить
Каждая оценка вместе со средней оценкой своего стихотворения и отклонением от неё.

```sql
SELECT
    r.rating_id,
    p.title,
    r.score,
    ROUND(AVG(r.score) OVER (PARTITION BY r.poem_id), 2) AS poem_avg_score,
    ROUND(r.score - AVG(r.score) OVER (PARTITION BY r.poem_id), 2) AS deviation
FROM ratings r
JOIN poems p ON r.poem_id = p.poem_id
ORDER BY r.poem_id, r.rating_id;
```

Результат выполнения запроса:

<img width="852" height="265" alt="image" src="https://github.com/user-attachments/assets/8cdde8f8-cb18-4e01-b625-1d5edcdc3c6b" />

### Запрос 3.2. Что хотим получить
Каждое стихотворение вместе с общим числом стихов его автора.

```sql
SELECT
    u.username,
    p.title,
    COUNT(*) OVER (PARTITION BY p.author_id) AS author_poems_total
FROM poems p
JOIN users u ON p.author_id = u.user_id
ORDER BY u.username, p.title;
```

Результат выполнения запроса:

<img width="730" height="238" alt="image" src="https://github.com/user-attachments/assets/9d8a7b00-ffbc-438e-908e-980f10cb8046" />

## Часть 4. Оконные функции: PARTITION BY + ORDER BY

### Запрос 4.1. Что хотим получить
Нарастающий итог оценок по каждому стихотворению (в порядке выставления оценок).

```sql
SELECT
    p.title,
    r.rating_id,
    r.score,
    SUM(r.score) OVER (PARTITION BY r.poem_id ORDER BY r.rating_id) AS running_sum
FROM ratings r
JOIN poems p ON r.poem_id = p.poem_id
ORDER BY r.poem_id, r.rating_id;
```

Результат выполнения запроса:

<img width="690" height="206" alt="image" src="https://github.com/user-attachments/assets/a0349e49-8485-4b84-a4d2-e64c9c7dc657" />


### Запрос 4.2. Что хотим получить
Нарастающее количество комментариев к каждому стихотворению по времени.

```sql
SELECT
    p.title,
    c.created_at,
    c.comment_text,
    COUNT(*) OVER (PARTITION BY c.poem_id ORDER BY c.created_at) AS comments_so_far
FROM comments c
JOIN poems p ON c.poem_id = p.poem_id
ORDER BY c.poem_id, c.created_at;
```

Результат выполнения запроса:

<img width="776" height="211" alt="image" src="https://github.com/user-attachments/assets/fdc41bd5-5a69-4f8c-add4-4f2ce34892bd" />

## Часть 5. Оконные функции: ROWS

### Запрос 5.1. Что хотим получить
Скользящее среднее оценки по трём последним оценкам (текущая и две предыдущие) в порядке выставления.

```sql
SELECT
    rating_id,
    score,
    ROUND(AVG(score) OVER (
        ORDER BY rating_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3
FROM ratings
ORDER BY rating_id;
```

Результат выполнения запроса:

<img width="445" height="257" alt="image" src="https://github.com/user-attachments/assets/9054a032-acba-4fc1-b654-0907e9bc5496" />

### Запрос 5.2. Что хотим получить
Средняя оценка стихотворения, сглаженная по соседям: предыдущее, текущее и следующее стихотворение по дате публикации.

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    publication_date,
    avg_score,
    ROUND(AVG(avg_score) OVER (
        ORDER BY publication_date, poem_id
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) AS smoothed_avg
FROM poem_avg
ORDER BY publication_date, poem_id;
```

Результат выполнения запроса:

<img width="763" height="210" alt="image" src="https://github.com/user-attachments/assets/9281fc85-df79-4bfb-a0f8-6f95e4efec4f" />


## Часть 6. Оконные функции: RANGE

### Запрос 6.1. Что хотим получить
Сколько стихов было опубликовано за последние 30 дней, включая текущий (RANGE по датам; стихи с одинаковой датой считаются вместе).

```sql
SELECT
    title,
    publication_date,
    COUNT(*) OVER (
        ORDER BY publication_date
        RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW
    ) AS poems_last_30_days
FROM poems
ORDER BY publication_date, poem_id;
```

Результат выполнения запроса:

<img width="702" height="210" alt="image" src="https://github.com/user-attachments/assets/04559860-2d8e-4e3e-a46b-947e2685457f" />

### Запрос 6.2. Что хотим получить
Сколько пользователей зарегистрировалось за последние 60 дней, включая текущего.

```sql
SELECT
    username,
    registration_date,
    COUNT(*) OVER (
        ORDER BY registration_date
        RANGE BETWEEN INTERVAL '60 days' PRECEDING AND CURRENT ROW
    ) AS registered_last_60_days
FROM users
ORDER BY registration_date, user_id;
```

Результат выполнения запроса:

<img width="608" height="205" alt="image" src="https://github.com/user-attachments/assets/cab92b96-f501-4b8e-813a-1f39974b33fb" />


## Часть 7. Ранжирующие функции

### Запрос 7.1. Что хотим получить
ROW_NUMBER: лучшее по средней оценке стихотворение каждого автора.

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT username, title, avg_score
FROM (
    SELECT
        u.username,
        pa.title,
        pa.avg_score,
        ROW_NUMBER() OVER (
            PARTITION BY pa.author_id
            ORDER BY pa.avg_score DESC, pa.title
        ) AS rn
    FROM poem_avg pa
    JOIN users u ON pa.author_id = u.user_id
) t
WHERE rn = 1
ORDER BY avg_score DESC, username;
```

Результат выполнения запроса:

<img width="673" height="206" alt="image" src="https://github.com/user-attachments/assets/e3dd1243-db2d-4ff6-96c7-468bcfdf5ca5" />


### Запрос 7.2. Что хотим получить
RANK: место стихотворения по средней оценке (при равных оценках места совпадают, после них есть пропуски).

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    avg_score,
    RANK() OVER (ORDER BY avg_score DESC) AS rank
FROM poem_avg
ORDER BY rank, title;
```

Результат выполнения запроса:

<img width="596" height="207" alt="image" src="https://github.com/user-attachments/assets/e3592c80-20ec-4aed-854e-7d50fe014500" />


### Запрос 7.3. Что хотим получить
DENSE_RANK: то же самое, но без пропусков в нумерации мест.

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    avg_score,
    DENSE_RANK() OVER (ORDER BY avg_score DESC) AS dense_rank
FROM poem_avg
ORDER BY dense_rank, title;
```

Результат выполнения запроса:

<img width="604" height="232" alt="image" src="https://github.com/user-attachments/assets/f67497a5-cd8c-432c-af59-118ef8ef188b" />


### Запрос 7.4. Что хотим получить
NTILE: разбиение стихов на 4 группы (квартили) по средней оценке.

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    avg_score,
    NTILE(4) OVER (ORDER BY avg_score DESC, title) AS quartile
FROM poem_avg
ORDER BY quartile, avg_score DESC, title;
```

Результат выполнения запроса:

<img width="552" height="205" alt="image" src="https://github.com/user-attachments/assets/a32ba1c0-6941-4a46-9c3f-50b7c6336663" />


### Запрос 7.5. Что хотим получить
PERCENT_RANK: относительное положение стихотворения по средней оценке (от 0 до 1).

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    avg_score,
    ROUND(PERCENT_RANK() OVER (ORDER BY avg_score)::numeric, 3) AS percent_rank
FROM poem_avg
ORDER BY percent_rank DESC, title;
```

Результат выполнения запроса:

<img width="610" height="191" alt="image" src="https://github.com/user-attachments/assets/f1a13f49-921a-43c9-8c65-92b15e5d52a6" />


### Запрос 7.6. Что хотим получить
CUME_DIST: доля стихов, у которых средняя оценка не больше, чем у данного.

```sql
WITH poem_avg AS (
    SELECT p.poem_id, p.title, p.author_id, p.publication_date,
           ROUND(AVG(r.score), 2) AS avg_score
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    GROUP BY p.poem_id, p.title, p.author_id, p.publication_date
)
SELECT
    title,
    avg_score,
    ROUND(CUME_DIST() OVER (ORDER BY avg_score)::numeric, 3) AS cume_dist
FROM poem_avg
ORDER BY cume_dist DESC, title;
```

Результат выполнения запроса:

<img width="581" height="206" alt="image" src="https://github.com/user-attachments/assets/c182b7c4-364e-4b57-96aa-5c0c8f66235f" />

## Часть 8. Функции смещения

### Запрос 8.1. Что хотим получить
LAG: для каждого стихотворения показать предыдущее по дате публикации и сколько дней прошло между ними.

```sql
SELECT
    title,
    publication_date,
    LAG(title) OVER (ORDER BY publication_date, poem_id) AS previous_poem,
    publication_date - LAG(publication_date) OVER (ORDER BY publication_date, poem_id) AS days_since_previous
FROM poems
ORDER BY publication_date, poem_id;
```

Результат выполнения запроса:

<img width="940" height="194" alt="image" src="https://github.com/user-attachments/assets/80d54632-1444-4eaf-ae87-3756938bd12a" />


### Запрос 8.2. Что хотим получить
LEAD: для каждого стихотворения показать следующее стихотворение того же автора.

```sql
SELECT
    u.username,
    p.title,
    p.publication_date,
    LEAD(p.title) OVER (PARTITION BY p.author_id ORDER BY p.publication_date, p.poem_id) AS next_poem_of_author
FROM poems p
JOIN users u ON p.author_id = u.user_id
ORDER BY u.username, p.publication_date;
```

Результат выполнения запроса:

<img width="952" height="198" alt="image" src="https://github.com/user-attachments/assets/d6505d58-1032-4e77-9820-704a9e5d3d41" />


### Запрос 8.3. Что хотим получить
FIRST_VALUE: самое раннее стихотворение своего жанра для каждого стихотворения.

```sql
SELECT
    g.genre_name,
    p.title,
    p.publication_date,
    FIRST_VALUE(p.title) OVER (
        PARTITION BY g.genre_id
        ORDER BY p.publication_date, p.poem_id
    ) AS first_poem_in_genre
FROM genres g
JOIN poem_genres pg ON g.genre_id = pg.genre_id
JOIN poems p ON pg.poem_id = p.poem_id
ORDER BY g.genre_name, p.publication_date, p.poem_id;
```

Результат выполнения запроса:

<img width="918" height="192" alt="image" src="https://github.com/user-attachments/assets/9ac3de1f-643a-4342-92f1-9539e7e6a939" />


### Запрос 8.4. Что хотим получить
LAST_VALUE: самое позднее стихотворение своего жанра (нужна рамка до конца раздела).

```sql
SELECT
    g.genre_name,
    p.title,
    p.publication_date,
    LAST_VALUE(p.title) OVER (
        PARTITION BY g.genre_id
        ORDER BY p.publication_date, p.poem_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS latest_poem_in_genre
FROM genres g
JOIN poem_genres pg ON g.genre_id = pg.genre_id
JOIN poems p ON pg.poem_id = p.poem_id
ORDER BY g.genre_name, p.publication_date, p.poem_id;
```

Результат выполнения запроса:

<img width="918" height="209" alt="image" src="https://github.com/user-attachments/assets/268b4bec-f317-45ce-a116-7b49e6f26f47" />

### Запрос 8.5. Что хотим получить
NTH_VALUE: второе по дате публикации стихотворение в каждом жанре.

```sql
SELECT
    g.genre_name,
    p.title,
    p.publication_date,
    NTH_VALUE(p.title, 2) OVER (
        PARTITION BY g.genre_id
        ORDER BY p.publication_date, p.poem_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_poem_in_genre
FROM genres g
JOIN poem_genres pg ON g.genre_id = pg.genre_id
JOIN poems p ON pg.poem_id = p.poem_id
ORDER BY g.genre_name, p.publication_date, p.poem_id;
```

Результат выполнения запроса:

<img width="940" height="204" alt="image" src="https://github.com/user-attachments/assets/ea922e6e-3bee-4518-94b9-f04d883ac22b" />

# Домашнее задание 6: Подзапросы


## Часть 1. Подзапросы в SELECT

### Запрос 1.1. Что хотим получить
Для каждого стихотворения вывести его оценку-ориентир: среднюю оценку по всей платформе (скалярный подзапрос в списке столбцов).

```sql
SELECT
    title,
    (SELECT ROUND(AVG(score), 2) FROM ratings) AS platform_avg_score
FROM poems;
```

Результат выполнения запроса:
<img width="540" height="213" alt="image" src="https://github.com/user-attachments/assets/0eb5216a-5c44-4c13-a25b-fb06f5bc8be1" />

### Запрос 1.2. Что хотим получить
Для каждого стихотворения показать, за сколько дней до самой свежей публикации на платформе оно было опубликовано.

```sql
SELECT
    title,
    publication_date,
    (SELECT MAX(publication_date) FROM poems) - publication_date AS days_before_latest
FROM poems
ORDER BY publication_date;
```

Результат выполнения запроса:
<img width="701" height="222" alt="image" src="https://github.com/user-attachments/assets/7eb0a46f-9128-4574-ae79-678a1a301403" />

## Часть 2. Подзапросы в FROM

### Запрос 2.1. Что хотим получить
Показать название каждого стихотворения и его среднюю оценку. Средние оценки считаются в подзапросе, который используется как таблица.

```sql
SELECT
    p.title,
    s.avg_score
FROM poems p
JOIN (
    SELECT poem_id, ROUND(AVG(score), 2) AS avg_score
    FROM ratings
    GROUP BY poem_id
) AS s ON p.poem_id = s.poem_id
ORDER BY s.avg_score DESC, p.title;
```

Результат выполнения запроса:

<img width="508" height="246" alt="image" src="https://github.com/user-attachments/assets/aab02692-5255-476f-87c1-e4d55245d665" />

### Запрос 2.2. Что хотим получить
Показать все жанры и количество стихов в каждом (у жанров без стихов — 0). Количество считается в подзапросе в FROM.

```sql
SELECT
    g.genre_name,
    COALESCE(t.poems_count, 0) AS poems_count
FROM genres g
LEFT JOIN (
    SELECT genre_id, COUNT(*) AS poems_count
    FROM poem_genres
    GROUP BY genre_id
) AS t ON g.genre_id = t.genre_id
ORDER BY poems_count DESC, g.genre_name;
```

Результат выполнения запроса:

<img width="382" height="206" alt="image" src="https://github.com/user-attachments/assets/164b3e69-90d8-4780-80c6-ef16953842cd" />

## Часть 3. Подзапросы в WHERE

### Запрос 3.1. Что хотим получить
Найти стихи, опубликованные позже, чем «Я помню чудное мгновенье».

```sql
SELECT title, publication_date
FROM poems
WHERE publication_date > (
    SELECT publication_date
    FROM poems
    WHERE title = 'Я помню чудное мгновенье'
)
ORDER BY publication_date;
```

Результат выполнения запроса:

<img width="517" height="223" alt="image" src="https://github.com/user-attachments/assets/3337a478-fdd9-4b09-9cef-023a4bfae9e5" />

### Запрос 3.2. Что хотим получить
Найти оценки, которые выше средней оценки по платформе.

```sql
SELECT rating_id, score, user_id, poem_id
FROM ratings
WHERE score > (SELECT AVG(score) FROM ratings)
ORDER BY rating_id;
```

Результат выполнения запроса:

<img width="447" height="275" alt="image" src="https://github.com/user-attachments/assets/620aa517-bd04-48e6-a78f-4922584ac32e" />

## Часть 4. Подзапросы в HAVING

### Запрос 4.1. Что хотим получить
Вывести стихи, у которых средняя оценка выше средней оценки по всей платформе.

```sql
SELECT
    p.title,
    ROUND(AVG(r.score), 2) AS avg_score
FROM poems p
JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
HAVING AVG(r.score) > (SELECT AVG(score) FROM ratings)
ORDER BY p.title;
```

Результат выполнения запроса:

<img width="482" height="183" alt="image" src="https://github.com/user-attachments/assets/e90f182d-0dc3-4ad7-95fc-4041b4a85fc1" />

### Запрос 4.2. Что хотим получить
Вывести пользователей, которые поставили больше оценок, чем в среднем ставит один пользователь.

```sql
SELECT
    u.username,
    COUNT(r.rating_id) AS ratings_given
FROM users u
JOIN ratings r ON u.user_id = r.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(r.rating_id) > (
    SELECT COUNT(*)::numeric / COUNT(DISTINCT user_id)
    FROM ratings
)
ORDER BY u.username;
```

Результат выполнения запроса:

<img width="402" height="177" alt="image" src="https://github.com/user-attachments/assets/12da9c7c-b9ac-43b7-a6c9-d95e784288c9" />

## Часть 5. ALL

### Запрос 5.1. Что хотим получить
Найти стихи, у которых средняя оценка не меньше средних оценок всех остальных стихов (лучшие стихи).

```sql
SELECT
    p.title,
    ROUND(AVG(r.score), 2) AS avg_score
FROM poems p
JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
HAVING AVG(r.score) >= ALL (
    SELECT AVG(score)
    FROM ratings
    GROUP BY poem_id
)
ORDER BY p.title;
```

Результат выполнения запроса:

<img width="496" height="207" alt="image" src="https://github.com/user-attachments/assets/5ae26258-76e9-447a-bc90-3b03318011b2" />

### Запрос 5.2. Что хотим получить
Найти пользователей, зарегистрировавшихся позже всех авторов, которые пишут в жанре «Философская лирика».

```sql
SELECT username, registration_date
FROM users
WHERE registration_date > ALL (
    SELECT u.registration_date
    FROM users u
    JOIN poems p ON u.user_id = p.author_id
    JOIN poem_genres pg ON p.poem_id = pg.poem_id
    JOIN genres g ON pg.genre_id = g.genre_id
    WHERE g.genre_name = 'Философская лирика'
);
```

Результат выполнения запроса:

<img width="397" height="136" alt="image" src="https://github.com/user-attachments/assets/713e1143-59c2-4969-bd29-0fa2451bf895" />

## Часть 6. IN

### Запрос 6.1. Что хотим получить
Найти все стихи жанра «Лирика».

```sql
SELECT title
FROM poems
WHERE poem_id IN (
    SELECT pg.poem_id
    FROM poem_genres pg
    JOIN genres g ON pg.genre_id = g.genre_id
    WHERE g.genre_name = 'Лирика'
)
ORDER BY title;
```

Результат выполнения запроса:

<img width="383" height="210" alt="image" src="https://github.com/user-attachments/assets/d641eaf3-f249-42d9-ab0e-503e164586c3" />

### Запрос 6.2. Что хотим получить
Найти авторов, чьи стихи получили хотя бы одну оценку ниже 5.

```sql
SELECT username
FROM users
WHERE user_id IN (
    SELECT p.author_id
    FROM poems p
    JOIN ratings r ON p.poem_id = r.poem_id
    WHERE r.score < 5
);
```

Результат выполнения запроса:

<img width="327" height="133" alt="image" src="https://github.com/user-attachments/assets/40780299-71c8-4faa-b186-afd7f3e31269" />

## Часть 7. ANY

### Запрос 7.1. Что хотим получить
Найти стихи, опубликованные позже, чем хотя бы одно стихотворение Анны Ахматовой или Иосифа Бродского.

```sql
SELECT title, publication_date
FROM poems
WHERE publication_date > ANY (
    SELECT p.publication_date
    FROM poems p
    JOIN users u ON p.author_id = u.user_id
    WHERE u.username IN ('Анна Ахматова', 'Иосиф Бродский')
)
ORDER BY publication_date;
```

Результат выполнения запроса:

<img width="533" height="135" alt="image" src="https://github.com/user-attachments/assets/723541a1-355c-41c8-a441-2beb99a4cde2" />

### Запрос 7.2. Что хотим получить
Найти жанры, к которым относится стихотворение «Я помню чудное мгновенье» (= ANY).

```sql
SELECT genre_name
FROM genres
WHERE genre_id = ANY (
    SELECT pg.genre_id
    FROM poem_genres pg
    JOIN poems p ON pg.poem_id = p.poem_id
    WHERE p.title = 'Я помню чудное мгновенье'
)
ORDER BY genre_name;
```

Результат выполнения запроса:

<img width="332" height="162" alt="image" src="https://github.com/user-attachments/assets/8d99612b-e59c-485c-a00b-baa788c0471d" />

## Часть 8. EXISTS

### Запрос 8.1. Что хотим получить
Найти жанры, в которых есть хотя бы одно стихотворение.

```sql
SELECT g.genre_name
FROM genres g
WHERE EXISTS (
    SELECT 1
    FROM poem_genres pg
    WHERE pg.genre_id = g.genre_id
)
ORDER BY g.genre_name;
```

Результат выполнения запроса:

<img width="251" height="172" alt="image" src="https://github.com/user-attachments/assets/3cab3021-9dcd-4fa6-a120-f307415d0451" />

### Запрос 8.2. Что хотим получить
Найти жанры, в которых нет ни одного стихотворения (NOT EXISTS).

```sql
SELECT g.genre_name
FROM genres g
WHERE NOT EXISTS (
    SELECT 1
    FROM poem_genres pg
    WHERE pg.genre_id = g.genre_id
);
```

Результат выполнения запроса:

<img width="282" height="90" alt="image" src="https://github.com/user-attachments/assets/f7046033-9d32-4fca-878a-48da21564859" />

## Часть 9. Сравнение по нескольким столбцам

### Запрос 9.1. Что хотим получить
Найти оценки, которые являются максимальными для своего стихотворения (сравнение пары «стихотворение + оценка»).

```sql
SELECT rating_id, poem_id, user_id, score
FROM ratings
WHERE (poem_id, score) IN (
    SELECT poem_id, MAX(score)
    FROM ratings
    GROUP BY poem_id
)
ORDER BY poem_id, rating_id;
```

Результат выполнения запроса:

<img width="472" height="240" alt="image" src="https://github.com/user-attachments/assets/1caaedd0-c714-44f5-8403-2321c1dbcffe" />

### Запрос 9.2. Что хотим получить
Найти комментарии, оставленные пользователем без оценки этого же стихотворения (пара «пользователь + стихотворение»).

```sql
SELECT comment_id, comment_text, user_id, poem_id
FROM comments
WHERE (user_id, poem_id) NOT IN (
    SELECT user_id, poem_id
    FROM ratings
);
```

Результат выполнения запроса:

<img width="553" height="106" alt="image" src="https://github.com/user-attachments/assets/e29940cb-4fbf-49ea-86b6-948cd3ad4b59" />

## Часть 10. Коррелированные подзапросы

### Запрос 10.1. Что хотим получить
Найти оценки, которые выше средней оценки именно этого стихотворения.

```sql
SELECT r.rating_id, r.poem_id, r.user_id, r.score
FROM ratings r
WHERE r.score > (
    SELECT AVG(r2.score)
    FROM ratings r2
    WHERE r2.poem_id = r.poem_id
);
```

Результат выполнения запроса:

<img width="476" height="171" alt="image" src="https://github.com/user-attachments/assets/146726d5-914e-47a1-b949-6ca39f28b298" />

### Запрос 10.2. Что хотим получить
Для каждого пользователя вывести число написанных комментариев и среднюю оценку, которую он ставит.

```sql
SELECT
    u.username,
    (SELECT COUNT(*) FROM comments c WHERE c.user_id = u.user_id) AS comments_written,
    (SELECT ROUND(AVG(r.score), 2) FROM ratings r WHERE r.user_id = u.user_id) AS avg_score_given
FROM users u
ORDER BY u.user_id;
```

Результат выполнения запроса:

<img width="576" height="187" alt="image" src="https://github.com/user-attachments/assets/50b68dc8-2a7b-409e-b5a5-9f74589907e6" />

### Запрос 10.3. Что хотим получить
Найти стихи, у которых есть комментарий от пользователя, поставившего этому же стихотворению оценку.

```sql
SELECT p.title
FROM poems p
WHERE EXISTS (
    SELECT 1
    FROM comments c
    JOIN ratings r ON r.user_id = c.user_id AND r.poem_id = c.poem_id
    WHERE c.poem_id = p.poem_id
)
ORDER BY p.title;
```

Результат выполнения запроса:

<img width="371" height="170" alt="image" src="https://github.com/user-attachments/assets/c1c12437-4b64-4324-85fe-a3c2bd702335" />

### Запрос 10.4. Что хотим получить
Найти стихи, у которых оценок больше, чем жанров.

```sql
SELECT p.title
FROM poems p
WHERE (SELECT COUNT(*) FROM ratings r WHERE r.poem_id = p.poem_id)
    > (SELECT COUNT(*) FROM poem_genres pg WHERE pg.poem_id = p.poem_id)
ORDER BY p.title;
```

Результат выполнения запроса:

<img width="357" height="127" alt="image" src="https://github.com/user-attachments/assets/485ba35d-1042-45eb-96a3-314e14b5f820" />

### Запрос 10.5. Что хотим получить
Для каждого стихотворения определить порядковый номер публикации (сколько стихов было опубликовано раньше него, плюс один).

```sql
SELECT
    p.title,
    p.publication_date,
    (SELECT COUNT(*) FROM poems p2 WHERE p2.publication_date < p.publication_date) + 1 AS publication_order
FROM poems p
ORDER BY publication_order;
```

Результат выполнения запроса:

<img width="682" height="210" alt="image" src="https://github.com/user-attachments/assets/1193ab2f-c234-4e18-ad42-15107fef4e2f" />

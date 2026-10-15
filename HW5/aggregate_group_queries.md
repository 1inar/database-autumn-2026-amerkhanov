# Домашнее задание 5: Агрегация и группировка

## Часть 1. Агрегатные функции: COUNT(), SUM(), AVG(), MIN(), MAX(), STRING_AGG()

### Запрос 1.1. Что хотим получить
Общее количество пользователей, стихотворений и комментариев на платформе (одной строкой).

```sql
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM poems) AS total_poems,
    (SELECT COUNT(*) FROM comments) AS total_comments;
```

<img width="786" height="575" alt="image" src="https://github.com/user-attachments/assets/cfab4118-f48f-4e82-a089-05c37b0987d9" />

### Запрос 1.2. Что хотим получить
По каждому стихотворению: минимальная, максимальная, средняя и суммарная оценка, а также количество оценок.

```sql
SELECT
    p.title,
    COUNT(r.rating_id) AS ratings_count,
    MIN(r.score) AS min_score,
    MAX(r.score) AS max_score,
    ROUND(AVG(r.score), 2) AS avg_score,
    SUM(r.score) AS sum_score
FROM poems p
JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
ORDER BY avg_score DESC;
```
<img width="913" height="584" alt="image" src="https://github.com/user-attachments/assets/c0152aab-0e08-4676-badc-e89e5452ee20" />

### Запрос 1.3. Что хотим получить
Для каждого стихотворения — список имён пользователей, оставивших комментарии, объединённых в одну строку через запятую (STRING_AGG).

```sql
SELECT
    p.title,
    STRING_AGG(u.username, ', ' ORDER BY u.username) AS commentators
FROM poems p
JOIN comments c ON p.poem_id = c.poem_id
JOIN users u ON c.user_id = u.user_id
GROUP BY p.poem_id, p.title
ORDER BY p.title;
```
<img width="687" height="557" alt="image" src="https://github.com/user-attachments/assets/7b592cd4-9186-440a-94c9-fdee51f00384" />

##Часть 2. GROUP BY, HAVING

### Запрос 2.1. Что хотим получить
Вывести авторов, у которых опубликовано больше одного стихотворения, и количество их стихов.

```sql
SELECT
    u.username,
    COUNT(p.poem_id) AS poems_count
FROM users u
JOIN poems p ON u.user_id = p.author_id
GROUP BY u.user_id, u.username
HAVING COUNT(p.poem_id) > 1
ORDER BY poems_count DESC;
```
<img width="701" height="363" alt="image" src="https://github.com/user-attachments/assets/9ac59db5-5743-4a14-8050-d265be986734" />

### Запрос 2.2. Что хотим получить
Вывести стихотворения, у которых средняя оценка выше 4, вместе с количеством оценок.

```sql
SELECT
    p.title,
    COUNT(r.rating_id) AS ratings_count,
    ROUND(AVG(r.score), 2) AS avg_score
FROM poems p
JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
HAVING AVG(r.score) > 4
ORDER BY avg_score DESC;
```
<img width="654" height="563" alt="image" src="https://github.com/user-attachments/assets/c9155fb7-f338-41da-8f8c-d20082f99307" />

##Часть 3. GROUPING SETS, ROLLUP и CUBE

### Запрос 3.1. Что хотим получить
Количество стихотворений в разрезе: по автору, по жанру, а также общий итог — всё в одном запросе через GROUPING SETS.

```sql
SELECT
    u.username AS author,
    g.genre_name AS genre,
    COUNT(DISTINCT p.poem_id) AS poems_count
FROM poems p
LEFT JOIN users u ON p.author_id = u.user_id
LEFT JOIN poem_genres pg ON p.poem_id = pg.poem_id
LEFT JOIN genres g ON pg.genre_id = g.genre_id
GROUP BY GROUPING SETS (
    (u.username),
    (g.genre_name),
    ()
)
ORDER BY author NULLS LAST, genre NULLS LAST;
```
<img width="691" height="674" alt="image" src="https://github.com/user-attachments/assets/13a48991-b20d-4bf3-abab-9a1501e37089" />

### Запрос 3.2. Что хотим получить
Количество оценок в разрезе «автор → стихотворение» с промежуточными итогами по каждому автору и общим итогом.

```sql
SELECT
    u.username AS author,
    p.title,
    COUNT(r.rating_id) AS ratings_count
FROM users u
JOIN poems p ON u.user_id = p.author_id
LEFT JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY ROLLUP (u.username, p.title)
ORDER BY u.username NULLS LAST, p.title NULLS LAST;
```
<img width="686" height="608" alt="image" src="https://github.com/user-attachments/assets/c05bf64f-687d-42ce-9b79-9b5a668bf6f7" />

### Запрос 3.3. Что хотим получить
Количество стихотворений в разрезе «автор × жанр» — со всеми возможными комбинациями (по автору, по жанру, по обоим, и общий итог).
```sql
SELECT
    u.username AS author,
    g.genre_name AS genre,
    COUNT(DISTINCT p.poem_id) AS poems_count
FROM poems p
LEFT JOIN users u ON p.author_id = u.user_id
LEFT JOIN poem_genres pg ON p.poem_id = pg.poem_id
LEFT JOIN genres g ON pg.genre_id = g.genre_id
GROUP BY CUBE (u.username, g.genre_name)
ORDER BY author NULLS LAST, genre NULLS LAST;
```
<img width="696" height="627" alt="image" src="https://github.com/user-attachments/assets/20f2e243-c2a7-4a80-ba92-0235798ee54c" />

##Часть 4. Полный SELECT: FROM, WHERE, GROUP BY, HAVING, ORDER BY

### Запрос 4.1. Что хотим получить
Топ-3 стихотворения по средней оценке среди тех, что опубликованы в 2024 году, с количеством оценок не менее 2.

```sql
SELECT
    p.title,
    u.username AS author,
    COUNT(r.rating_id) AS ratings_count,
    ROUND(AVG(r.score), 2) AS avg_score
FROM poems p
JOIN users u ON p.author_id = u.user_id
JOIN ratings r ON p.poem_id = r.poem_id
WHERE p.publication_date >= '2024-01-01'
GROUP BY p.poem_id, p.title, u.username
HAVING COUNT(r.rating_id) >= 2
ORDER BY avg_score DESC
LIMIT 3;
```
<img width="749" height="609" alt="image" src="https://github.com/user-attachments/assets/93cedf5a-568f-4c5c-83e8-a8312e9927d2" />

### Запрос 4.2. Что хотим получить
Список жанров, по которым средняя оценка стихотворений выше 4, с указанием количества стихов в жанре. Отсортировать по убыванию средней оценки.

```sql
SELECT
    g.genre_name,
    COUNT(DISTINCT p.poem_id) AS poems_count,
    ROUND(AVG(r.score), 2) AS avg_score
FROM genres g
JOIN poem_genres pg ON g.genre_id = pg.genre_id
JOIN poems p ON pg.poem_id = p.poem_id
JOIN ratings r ON p.poem_id = r.poem_id
WHERE r.score IS NOT NULL
GROUP BY g.genre_id, g.genre_name
HAVING AVG(r.score) > 4
ORDER BY avg_score DESC;
```
<img width="706" height="608" alt="image" src="https://github.com/user-attachments/assets/eeb048b4-118d-46ef-bd70-f61c741297b9" />


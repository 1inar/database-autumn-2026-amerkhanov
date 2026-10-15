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

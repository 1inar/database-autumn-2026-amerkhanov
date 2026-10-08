SELECT
    u.username,
    r.score
FROM ratings r
RIGHT JOIN users u ON r.user_id = u.user_id
ORDER BY u.username;
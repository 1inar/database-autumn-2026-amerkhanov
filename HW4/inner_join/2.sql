SELECT
    u.username,
    p.title,
    r.score
FROM ratings r
INNER JOIN users u ON r.user_id = u.user_id
INNER JOIN poems p ON r.poem_id = p.poem_id
ORDER BY u.username;
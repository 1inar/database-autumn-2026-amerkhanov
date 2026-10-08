SELECT
    p.title,
    u.username AS author
FROM poems p
INNER JOIN users u ON p.author_id = u.user_id
ORDER BY u.username, p.title;
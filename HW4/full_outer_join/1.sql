SELECT
    u.username,
    p.title
FROM users u
FULL OUTER JOIN poems p ON u.user_id = p.author_id
ORDER BY u.username NULLS LAST, p.title;
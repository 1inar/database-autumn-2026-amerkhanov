SELECT
    p.title,
    c.comment_text
FROM poems p
LEFT JOIN comments c ON p.poem_id = c.poem_id
ORDER BY p.title;
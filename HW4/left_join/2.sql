SELECT
    p.title
FROM poems p
LEFT JOIN ratings r ON p.poem_id = r.poem_id
WHERE r.rating_id IS NULL;
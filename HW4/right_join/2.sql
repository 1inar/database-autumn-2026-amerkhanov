SELECT
    p.title,
    g.genre_name
FROM poems p
CROSS JOIN genres g
ORDER BY p.title, g.genre_name;
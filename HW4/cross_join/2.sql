SELECT
    p.title,
    g.genre_name
FROM poems p
CROSS JOIN genres g
LEFT JOIN poem_genres pg
    ON p.poem_id = pg.poem_id AND g.genre_id = pg.genre_id
WHERE pg.poem_id IS NULL
ORDER BY p.title, g.genre_name;
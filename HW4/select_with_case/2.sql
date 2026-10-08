SELECT
    p.title,
    ROUND(AVG(r.score), 2) AS avg_score,
    CASE
        WHEN AVG(r.score) >= 4.5 THEN 'Шедевр'
        WHEN AVG(r.score) >= 3.5 THEN 'Хорошо'
        WHEN AVG(r.score) >= 2.5 THEN 'Средне'
        ELSE 'Слабо'
    END AS verdict
FROM poems p
JOIN ratings r ON p.poem_id = r.poem_id
GROUP BY p.poem_id, p.title
ORDER BY avg_score DESC;
SELECT
    title,
    LENGTH(poem_text) AS text_length,
    CASE
        WHEN LENGTH(poem_text) < 100 THEN 'Короткое'
        WHEN LENGTH(poem_text) BETWEEN 100 AND 500 THEN 'Среднее'
        ELSE 'Длинное'
    END AS category
FROM poems
ORDER BY text_length;
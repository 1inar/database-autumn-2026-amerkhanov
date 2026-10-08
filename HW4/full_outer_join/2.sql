SELECT
    COALESCE(c.user_id, r.user_id) AS user_id,
    COALESCE(c.poem_id, r.poem_id) AS poem_id,
    c.comment_text,
    r.score
FROM comments c
FULL OUTER JOIN ratings r
    ON c.user_id = r.user_id AND c.poem_id = r.poem_id
ORDER BY user_id, poem_id;
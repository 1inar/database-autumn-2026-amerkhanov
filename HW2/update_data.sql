UPDATE users SET email = 'pushkin_new@mail.ru' WHERE user_id = 1;

UPDATE users SET bio = 'Великая русская поэтесса, одна из ключевых фигур Серебряного века.' WHERE user_id = 2;

UPDATE ratings SET score = 5 WHERE user_id = 1 AND poem_id = 3;

UPDATE poems SET title = 'Мне нравится, что Вы больны не мной...' WHERE poem_id = 4;

UPDATE poems SET publication_date = '2024-02-16' WHERE poem_id = 2;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE poems (
    poem_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    text TEXT NOT NULL,
    publication_date DATE DEFAULT CURRENT_DATE,
    author_id INT NOT NULL,
    CONSTRAINT fk_poem_author FOREIGN KEY (author_id) REFERENCES users(user_id) ON DELETE CASCADE
);


CREATE TABLE poem_genres (
    poem_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (poem_id, genre_id),
    CONSTRAINT fk_pg_poem FOREIGN KEY (poem_id) REFERENCES poems(poem_id) ON DELETE CASCADE,
    CONSTRAINT fk_pg_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT NOT NULL,
    poem_id INT NOT NULL,
    CONSTRAINT fk_comment_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_poem FOREIGN KEY (poem_id) REFERENCES poems(poem_id) ON DELETE CASCADE
);

CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    score INT NOT NULL CHECK (score >= 1 AND score <= 5),
    user_id INT NOT NULL,
    poem_id INT NOT NULL,
    CONSTRAINT fk_rating_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_rating_poem FOREIGN KEY (poem_id) REFERENCES poems(poem_id) ON DELETE CASCADE
);

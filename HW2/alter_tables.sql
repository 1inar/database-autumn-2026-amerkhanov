ALTER TABLE users ADD COLUMN bio TEXT;

ALTER TABLE poems RENAME COLUMN text TO poem_text;

ALTER TABLE ratings ADD CONSTRAINT chk_min_score CHECK (score >= 1);

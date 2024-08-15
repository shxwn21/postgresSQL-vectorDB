
-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS postgres_ml;

-- Create grade_levels table
CREATE TABLE IF NOT EXISTS grade_levels (
    id SERIAL PRIMARY KEY,
    grade_level TEXT NOT NULL UNIQUE
);

-- Create chapters table
CREATE TABLE IF NOT EXISTS chapters (
    id SERIAL PRIMARY KEY,
    grade_level_id INT REFERENCES grade_levels(id),
    chapter_name TEXT NOT NULL,
    chapter_url TEXT NOT NULL
);

-- Create lessons table
CREATE TABLE IF NOT EXISTS lessons (
    id SERIAL PRIMARY KEY,
    chapter_id INT REFERENCES chapters(id),
    lesson_name TEXT NOT NULL,
    lesson_url TEXT NOT NULL
);

-- Create a table to store the vector embeddings
CREATE TABLE IF NOT EXISTS grade_chapter_embeddings (
    id SERIAL PRIMARY KEY,
    grade_level_id INT REFERENCES grade_levels(id),
    chapter_id INT REFERENCES chapters(id),
    embedding VECTOR(300) -- Adjust the dimension as needed
);

-- Insert sample grade levels
INSERT INTO grade_levels (grade_level) VALUES ('Grade 1'), ('Grade 2');

-- Insert sample chapters
INSERT INTO chapters (grade_level_id, chapter_name, chapter_url)
VALUES 
(1, 'Chapter 1', 'http://example.com/chapter1'),
(1, 'Chapter 2', 'http://example.com/chapter2'),
(2, 'Chapter 3', 'http://example.com/chapter3');

-- Insert sample lessons
INSERT INTO lessons (chapter_id, lesson_name, lesson_url)
VALUES 
(1, 'Lesson 1.1', 'http://example.com/lesson1.1'),
(1, 'Lesson 1.2', 'http://example.com/lesson1.2'),
(2, 'Lesson 2.1', 'http://example.com/lesson2.1'),
(3, 'Lesson 3.1', 'http://example.com/lesson3.1');

-- Generate embeddings for chapters and grades
-- For each chapter, generate an embedding combining the grade level and lessons
INSERT INTO grade_chapter_embeddings (grade_level_id, chapter_id, embedding)
VALUES 
(1, 1, (SELECT embedding FROM postgres_ml.embed('text_embedding_model', 'Grade 1 Chapter 1 Lessons 1.1, 1.2'))),
(1, 2, (SELECT embedding FROM postgres_ml.embed('text_embedding_model', 'Grade 1 Chapter 2 Lessons 2.1'))),
(2, 3, (SELECT embedding FROM postgres_ml.embed('text_embedding_model', 'Grade 2 Chapter 3 Lessons 3.1')));

-- Verify inserted data
SELECT * FROM grade_chapter_embeddings;





DROP SCHEMA IF EXISTS elearning CASCADE;

DROP USER IF EXISTS db_reader_user;
DROP USER IF EXISTS db_admin_user;

DROP ROLE IF EXISTS elearning_readonly;
DROP ROLE IF EXISTS elearning_admin;

CREATE SCHEMA elearning;

CREATE TABLE elearning.users (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (role IN ('student', 'instructor'))
);

CREATE TABLE elearning.courses (
    course_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    instructor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES elearning.users(user_id)
);

CREATE TABLE elearning.modules (
    module_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT,
    title VARCHAR(200) NOT NULL,
    position INT NOT NULL,
    FOREIGN KEY (course_id) REFERENCES elearning.courses(course_id)
);

CREATE TABLE elearning.lessons (
    lesson_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    module_id INT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    position INT NOT NULL,
    FOREIGN KEY (module_id) REFERENCES elearning.modules(module_id)
);

CREATE TABLE elearning.assessments (
    assessment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lesson_id INT,
    title VARCHAR(200) NOT NULL,
    max_score INT NOT NULL,
    due_date TIMESTAMP,
    CHECK (max_score >= 0),
    FOREIGN KEY (lesson_id) REFERENCES elearning.lessons(lesson_id)
);

CREATE TABLE elearning.submissions (
    submission_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    assessment_id INT,
    student_id INT,
    score INT,
    submitted_at TIMESTAMP NOT NULL,
    CHECK (score >= 0),
    FOREIGN KEY (assessment_id) REFERENCES elearning.assessments(assessment_id),
    FOREIGN KEY (student_id) REFERENCES elearning.users(user_id)
);

CREATE TABLE elearning.enrollments (
    enrollment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrolled_at TIMESTAMP NOT NULL,
    status VARCHAR(30) NOT NULL,
    CHECK (status IN ('active', 'completed', 'dropped')),
    FOREIGN KEY (student_id) REFERENCES elearning.users(user_id),
    FOREIGN KEY (course_id) REFERENCES elearning.courses(course_id)
);

CREATE TABLE elearning.progress (
    progress_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT,
    lesson_id INT,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES elearning.users(user_id),
    FOREIGN KEY (lesson_id) REFERENCES elearning.lessons(lesson_id)
);

CREATE TABLE elearning.feedback (
    feedback_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT,
    course_id INT,
    rating INT,
    comment TEXT,
    created_at TIMESTAMP NOT NULL,
    CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (student_id) REFERENCES elearning.users(user_id),
    FOREIGN KEY (course_id) REFERENCES elearning.courses(course_id)
);

CREATE TABLE elearning.discussions (
    discussion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT,
    title VARCHAR(200) NOT NULL,
    created_at TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES elearning.courses(course_id)
);

CREATE TABLE elearning.messages (
    message_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    discussion_id INT,
    user_id INT,
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (discussion_id) REFERENCES elearning.discussions(discussion_id),
    FOREIGN KEY (user_id) REFERENCES elearning.users(user_id)
);

CREATE TABLE elearning.certificates (
    certificate_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT,
    course_id INT,
    issue_date TIMESTAMP NOT NULL,
    certificate_number VARCHAR(50) UNIQUE,
    FOREIGN KEY (student_id) REFERENCES elearning.users(user_id),
    FOREIGN KEY (course_id) REFERENCES elearning.courses(course_id)
);

CREATE ROLE elearning_admin;
CREATE ROLE elearning_readonly;

GRANT USAGE ON SCHEMA elearning TO elearning_admin;
GRANT USAGE ON SCHEMA elearning TO elearning_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA elearning
TO elearning_admin;

GRANT SELECT
ON ALL TABLES IN SCHEMA elearning
TO elearning_readonly;

CREATE USER db_admin_user WITH PASSWORD 'Admin123!';
CREATE USER db_reader_user WITH PASSWORD 'Reader123!';

GRANT elearning_admin TO db_admin_user;
GRANT elearning_readonly TO db_reader_user;

REVOKE UPDATE, DELETE
ON ALL TABLES IN SCHEMA elearning
FROM elearning_readonly;

-- db_admin_user: SELECT INSERT UPDATE DELETE
-- db_reader_user: SELECT

TRUNCATE TABLE elearning.certificates RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.messages RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.discussions RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.feedback RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.progress RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.submissions RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.assessments RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.enrollments RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.lessons RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.modules RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.courses RESTART IDENTITY CASCADE;
TRUNCATE TABLE elearning.users RESTART IDENTITY CASCADE;

INSERT INTO elearning.users(first_name,last_name,email,password,role,created_at)
VALUES
('Aiken','Amanbay','aiken@gmail.com','pass123','student','2026-03-01'),
('Dias','Yermekov','dias@gmail.com','pass456','instructor','2026-03-01'),
('Alina','Sarsen','alina@gmail.com','learn789','student','2026-03-02'),
('Nursultan','Bekov','nursultan@gmail.com','code321','student','2026-03-03'),
('Madina','Kaliyeva','madina@gmail.com','teach654','instructor','2026-03-01');

INSERT INTO elearning.courses(title,description,instructor_id,created_at)
VALUES
(
'Python Basics',
'Introduction to Python programming',
(SELECT user_id FROM elearning.users WHERE email='dias@gmail.com'),
'2026-03-02'
),
(
'Web Design',
'HTML and CSS fundamentals',
(SELECT user_id FROM elearning.users WHERE email='madina@gmail.com'),
'2026-03-04'
),
(
'Database Systems',
'SQL and PostgreSQL',
(SELECT user_id FROM elearning.users WHERE email='madina@gmail.com'),
'2026-03-05'
),
(
'Java Fundamentals',
'Java basics',
(SELECT user_id FROM elearning.users WHERE email='dias@gmail.com'),
'2026-03-06'
),
(
'C# Development',
'C#/.NET course',
(SELECT user_id FROM elearning.users WHERE email='dias@gmail.com'),
'2026-03-07'
);

INSERT INTO elearning.modules(course_id,title,position)
VALUES
(
(SELECT course_id FROM elearning.courses WHERE title='Python Basics'),
'Python Introduction',
1
),
(
(SELECT course_id FROM elearning.courses WHERE title='Web Design'),
'HTML Basics',
1
),
(
(SELECT course_id FROM elearning.courses WHERE title='Database Systems'),
'SQL Queries',
1
),
(
(SELECT course_id FROM elearning.courses WHERE title='Java Fundamentals'),
'Java Syntax',
1
),
(
(SELECT course_id FROM elearning.courses WHERE title='C# Development'),
'C# Basics',
1
);

INSERT INTO elearning.lessons(module_id,title,content,position)
VALUES
(
(SELECT module_id FROM elearning.modules WHERE title='Python Introduction'),
'What is Python',
'Introduction lesson',
1
),
(
(SELECT module_id FROM elearning.modules WHERE title='HTML Basics'),
'HTML Tags',
'HTML lesson',
1
),
(
(SELECT module_id FROM elearning.modules WHERE title='SQL Queries'),
'SELECT Statements',
'SQL lesson',
1
),
(
(SELECT module_id FROM elearning.modules WHERE title='Java Syntax'),
'Java Variables',
'Java lesson',
1
),
(
(SELECT module_id FROM elearning.modules WHERE title='C# Basics'),
'C# Classes',
'C# lesson',
1
);

INSERT INTO elearning.assessments(lesson_id,title,max_score,due_date)
VALUES
(
(SELECT lesson_id FROM elearning.lessons WHERE title='What is Python'),
'Python Quiz',
100,
'2026-03-10'
),
(
(SELECT lesson_id FROM elearning.lessons WHERE title='HTML Tags'),
'HTML Practice',
80,
'2026-03-18'
),
(
(SELECT lesson_id FROM elearning.lessons WHERE title='SELECT Statements'),
'SQL Homework',
90,
'2026-03-20'
),
(
(SELECT lesson_id FROM elearning.lessons WHERE title='Java Variables'),
'Java Quiz',
100,
'2026-03-25'
),
(
(SELECT lesson_id FROM elearning.lessons WHERE title='C# Classes'),
'C# Homework',
95,
'2026-03-30'
);

INSERT INTO elearning.enrollments(student_id,course_id,enrolled_at,status)
VALUES
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Python Basics'),
'2026-03-03',
'active'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Web Design'),
'2026-03-04',
'completed'
),
(
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Database Systems'),
'2026-03-06',
'dropped'
),
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Java Fundamentals'),
'2026-03-08',
'active'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='C# Development'),
'2026-03-09',
'active'
);

INSERT INTO elearning.submissions(assessment_id,student_id,score,submitted_at)
VALUES
(
(SELECT assessment_id FROM elearning.assessments WHERE title='Python Quiz'),
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
90,
'2026-03-09'
),
(
(SELECT assessment_id FROM elearning.assessments WHERE title='HTML Practice'),
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
75,
'2026-03-17'
),
(
(SELECT assessment_id FROM elearning.assessments WHERE title='SQL Homework'),
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
82,
'2026-03-20'
),
(
(SELECT assessment_id FROM elearning.assessments WHERE title='Java Quiz'),
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
91,
'2026-03-25'
),
(
(SELECT assessment_id FROM elearning.assessments WHERE title='C# Homework'),
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
88,
'2026-03-30'
);

INSERT INTO elearning.progress(student_id,lesson_id,completed,completed_at)
VALUES
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT lesson_id FROM elearning.lessons WHERE title='What is Python'),
true,
'2026-03-04'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT lesson_id FROM elearning.lessons WHERE title='HTML Tags'),
true,
'2026-03-18'
),
(
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
(SELECT lesson_id FROM elearning.lessons WHERE title='SELECT Statements'),
false,
NULL
),
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT lesson_id FROM elearning.lessons WHERE title='Java Variables'),
true,
'2026-03-24'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT lesson_id FROM elearning.lessons WHERE title='C# Classes'),
false,
NULL
);

INSERT INTO elearning.feedback(student_id,course_id,rating,comment,created_at)
VALUES
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Python Basics'),
5,
'Very useful course',
'2026-03-12'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Web Design'),
4,
'Easy to understand',
'2026-03-18'
),
(
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Database Systems'),
5,
'Great SQL explanations',
'2026-03-22'
),
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Java Fundamentals'),
4,
'Interesting lessons',
'2026-03-28'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='C# Development'),
5,
'Helpful assignments',
'2026-04-01'
);

INSERT INTO elearning.discussions(course_id,title,created_at)
VALUES
(
(SELECT course_id FROM elearning.courses WHERE title='Python Basics'),
'Python Help',
'2026-03-05'
),
(
(SELECT course_id FROM elearning.courses WHERE title='Web Design'),
'HTML Support',
'2026-03-07'
),
(
(SELECT course_id FROM elearning.courses WHERE title='Database Systems'),
'SQL Questions',
'2026-03-10'
),
(
(SELECT course_id FROM elearning.courses WHERE title='Java Fundamentals'),
'Java Discussion',
'2026-03-15'
),
(
(SELECT course_id FROM elearning.courses WHERE title='C# Development'),
'C# Support',
'2026-03-18'
);

INSERT INTO elearning.messages(discussion_id,user_id,message,created_at)
VALUES
(
(SELECT discussion_id FROM elearning.discussions WHERE title='Python Help'),
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
'I need help with loops',
'2026-03-05'
),
(
(SELECT discussion_id FROM elearning.discussions WHERE title='HTML Support'),
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
'How do div tags work?',
'2026-03-07'
),
(
(SELECT discussion_id FROM elearning.discussions WHERE title='SQL Questions'),
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
'What is JOIN?',
'2026-03-10'
),
(
(SELECT discussion_id FROM elearning.discussions WHERE title='Java Discussion'),
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
'How to create objects?',
'2026-03-15'
),
(
(SELECT discussion_id FROM elearning.discussions WHERE title='C# Support'),
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
'What is inheritance?',
'2026-03-18'
);

INSERT INTO elearning.certificates(student_id,course_id,issue_date,certificate_number)
VALUES
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Python Basics'),
'2026-04-01',
'CERT-001'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Web Design'),
'2026-04-12',
'CERT-002'
),
(
(SELECT user_id FROM elearning.users WHERE email='nursultan@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Database Systems'),
'2026-04-15',
'CERT-003'
),
(
(SELECT user_id FROM elearning.users WHERE email='aiken@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='Java Fundamentals'),
'2026-04-20',
'CERT-004'
),
(
(SELECT user_id FROM elearning.users WHERE email='alina@gmail.com'),
(SELECT course_id FROM elearning.courses WHERE title='C# Development'),
'2026-04-22',
'CERT-005'
);

SELECT *
FROM elearning.users
WHERE email='aiken@gmail.com';

-- rows: 1

UPDATE elearning.users
SET email='aiken_edu@gmail.com'
WHERE email='aiken@gmail.com';

SELECT *
FROM elearning.enrollments
WHERE student_id=(
SELECT user_id
FROM elearning.users
WHERE email='aiken_edu@gmail.com'
);

-- rows: 2

UPDATE elearning.enrollments
SET status='completed'
WHERE student_id=(
SELECT user_id
FROM elearning.users
WHERE email='aiken_edu@gmail.com'
);

SELECT s.submission_id,s.score,a.max_score
FROM elearning.submissions s
JOIN elearning.assessments a
ON s.assessment_id=a.assessment_id
WHERE s.score<80;

-- rows: 1

UPDATE elearning.submissions s
SET score=s.score+5
FROM elearning.assessments a
WHERE s.assessment_id=a.assessment_id
AND a.title='HTML Practice';

BEGIN;

-- dropped enrollments are removed because the student left the course

DELETE FROM elearning.enrollments
WHERE status='dropped';

SELECT COUNT(*)
FROM elearning.enrollments;

-- count: 4

ROLLBACK;
SET ROLE db_admin_user;

SELECT current_user;

SELECT COUNT(*)
FROM elearning.users;

INSERT INTO elearning.users
(first_name,last_name,email,password,role,created_at)
VALUES
('Admin','Test','admin_test@gmail.com','123','student','2026-05-01');

UPDATE elearning.users
SET first_name='Updated'
WHERE email='admin_test@gmail.com';

DELETE FROM elearning.users
WHERE email='admin_test@gmail.com';

RESET ROLE;

SET ROLE db_reader_user;

SELECT current_user;

SELECT COUNT(*)
FROM elearning.users;

BEGIN;

INSERT INTO elearning.users
(first_name,last_name,email,password,role,created_at)
VALUES
('Test','User','test@gmail.com','123','student','2026-05-01');

-- ERROR: permission denied for table users

ROLLBACK;

BEGIN;

UPDATE elearning.users
SET first_name='Test'
WHERE user_id=1;

-- ERROR: permission denied for table users

ROLLBACK;

BEGIN;

DELETE FROM elearning.users
WHERE user_id=1;

-- ERROR: permission denied for table users

ROLLBACK;

RESET ROLE;
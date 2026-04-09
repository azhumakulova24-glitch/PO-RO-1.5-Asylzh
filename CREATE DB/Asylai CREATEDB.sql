DROP SCHEMA IF EXISTS elearning CASCADE;
CREATE SCHEMA elearning;

CREATE TABLE elearning.users (
-- ID is automatic, we use it to not mix up students
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	-- I used 50 chars for names because its enough and saves space
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	-- UNIQUE means special, no two people can have the same email
    email VARCHAR(100) UNIQUE NOT NULL,
	-- 255 chars is perfect for a secret password
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
	-- Date is added automatically when user signs up
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (role IN ('student', 'instructor')),
	-- A rule to make sure the date is from this year or later
    CHECK (created_at > '2026-01-01')
);

CREATE TABLE elearning.courses (
    course_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
	-- I used TEXT because a description can be very long
    description TEXT,
	-- This links the course to a teacher from the Users table
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
	-- Score cannot be less than zero
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
	-- Can only be one of three options
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
	-- Only 1 to 5 stars allowed
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
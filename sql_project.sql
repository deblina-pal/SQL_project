-- 1. Create Database
DROP DATABASE IF EXISTS StudentPlacementDB; -- Ensures clean start
CREATE DATABASE StudentPlacementDB;
USE StudentPlacementDB;

-- 2. Create Tables

-- Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    cgpa DECIMAL(3,1), -- Changed to DECIMAL for better precision
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

-- Add trigger to enforce CGPA constraint since MySQL often ignores CHECK constraints
DELIMITER //
CREATE TRIGGER check_cgpa BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    IF NEW.cgpa < 0 OR NEW.cgpa > 10 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'CGPA must be between 0 and 10';
    END IF;
END//
DELIMITER ;

-- Companies Table
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    job_role VARCHAR(50),
    package DECIMAL(10,2), -- Changed to DECIMAL for currency
    location VARCHAR(100)
);

-- Placements Table
CREATE TABLE placements (
    placement_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    company_id INT,
    placement_date DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

-- 3. Insert Sample Data

-- Students
INSERT INTO students (name, department, cgpa, email, phone) VALUES
('Ananya Sharma', 'CSE', 9.2, 'ananya@example.com', '9876543210'),
('Rohan Das', 'ECE', 8.5, 'rohan@example.com', '9876543211'),
('Priya Mehta', 'IT', 8.9, 'priya@example.com', '9876543212'),
('Samar Khan', 'EEE', 7.8, 'samar@example.com', '9876543213'),
('Kriti Singh', 'CSE', 9.4, 'kriti@example.com', '9876543214');

-- Companies
INSERT INTO companies (name, job_role, package, location) VALUES
('TCS', 'Software Engineer', 7.0, 'Bangalore'),
('Google', 'Frontend Developer', 20.0, 'Hyderabad'),
('Infosys', 'System Engineer', 6.5, 'Pune'),
('Microsoft', 'Backend Developer', 22.0, 'Bangalore');

-- Placements
INSERT INTO placements (student_id, company_id, placement_date) VALUES
(1, 1, '2025-01-15'),
(2, 2, '2025-01-20'),
(5, 4, '2025-01-25');

-- 4. Useful Queries

-- List all students with their placement status
SELECT 
    s.name AS Student,
    s.department,
    c.name AS Company,
    c.job_role,
    c.package,
    c.location
FROM students s
LEFT JOIN placements p ON s.student_id = p.student_id
LEFT JOIN companies c ON p.company_id = c.company_id;

-- Find unplaced students
SELECT * FROM students
WHERE student_id NOT IN (SELECT student_id FROM placements);

-- Highest package offered
SELECT MAX(package) AS Highest_Package FROM companies;

-- Average CGPA of placed students
SELECT AVG(s.cgpa) AS Average_CGPA_Placed
FROM students s
JOIN placements p ON s.student_id = p.student_id;

-- Companies hiring CSE students
SELECT DISTINCT c.name AS Company, companies.job_role
FROM students
JOIN placements ON students.student_id = placements.student_id
JOIN companies ON placements.company_id = companies.company_id
WHERE students.department = 'CSE';

SELECT DISTINCT department FROM students;
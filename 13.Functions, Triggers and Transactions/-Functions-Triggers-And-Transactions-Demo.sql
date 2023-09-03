-- Functions

USE soft_uni;

SELECT * FROM projects;

DELIMITER $$
CREATE FUNCTION udf_project_weeks(start_date DATE, end_date DATE)
RETURNS INT
BEGIN
	DECLARE projectWeeks INT;
	
	IF(end_date IS NULL) THEN
		SET end_date := now();
	ELSE IF (end_date = '2016-10-07') THEN
   	SET end_date := now();
	ELSE
	-- 
	END IF;
	
	SET projectWeeks := DATEDIFF(end_date, start_date)/7;
	RETURN projectWeeks;
END $$

DELIMITER ;

SELECT p.project_id,p.start_date, p.end_date,
       udf_project_weeks(p.start_date,p.end_date)
  FROM projects as p
  
-- Transactions
CREATE DATABASE Trans;

USE Trans;

CREATE TABLE employees(
	employee_id INT,
	employee_name VARCHAR(50)
);

INSERT INTO employees(employee_id, employee_name)
VALUES (1, 'Pesho');

SELECT * FROM employees;

SET autocommit=0;
START TRANSACTION;
INSERT INTO employees(employee_id, employee_name)
VALUES (3, 'Teo');

COMMIT;

SELECT * FROM employees;

-- Procedures
SELECT * FROM employees_projects;

DELIMITER \\
CREATE PROCEDURE udp_assing_project (employee_id INT, project_id INT)
BEGIN
	DECLARE maxProjects INT;
	DECLARE currentProjects INT;
	SET maxProjects := 3;
	SET currentProjects := (SELECT COUNT(*) AS total_projects
  									 FROM employees_projects AS ep
 									WHERE ep.employee_id = employee_id);
 									
 	START TRANSACTION;
 	
 	INSERT INTO employees_projects(employee_id, project_id)
 	VALUES (employee_id, project_id);
 	
 	IF (currentProjects >= maxProjects) THEN
 		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Too many projects';
 		ROLLBACK;
 	ELSE
 		COMMIT;
 	END IF;

END \\

DELIMTER ;

CALL udp_assing_project(227, 5)

SELECT * FROM employees_projects
WHERE employee_id = 227

SELECT employee_id,COUNT(*)
  FROM employees_projects
GROUP BY employee_id
HAVING COUNT(*) = 2

DELETE FROM employees_projects
WHERE employee_id = 227

-- Loops
DELIMITER $$
CREATE PROCEDURE udp_loop_test()
BEGIN
	DECLARE startValue INT;
	DECLARE maxValueVariable INT;
	SET startValue := 0;
	SET maxValueVariable := 10;
	
	WHILE (startValue < maxValueVariable) DO
		SELECT startValue;
		SET startValue := startValue + 1;	
	END WHILE;

END $$


CALL udp_loop_test()

-- Triggers
	CREATE TABLE IF NOT EXISTS employees_projects_history(
	employee_id INT,
	project_id INT
	);

DELIMITER $$
CREATE TRIGGER tr_log_records
AFTER DELETE
ON employees_projects
FOR EACH ROW
BEGIN

	INSERT INTO employees_projects_history(employee_id, project_id)
	VALUES(old.employee_id, old.project_id);
	
END $$

DELIMITER ;

DELETE FROM employees_projects
WHERE employee_id = 1;


SELECT * FROM employees_projects_history

--INDICES
CREATE INDEX idx_student_degree ON studentregistrationstodegrees(studentid);

CREATE INDEX idx_course_id ON courseoffers(courseid);

--MATERIALIZED VIEW
CREATE MATERIALIZED VIEW non_fail_stu AS
SELECT *
FROM courseregistrations_passed
WHERE NOT EXISTS( SELECT failed_UNION_4.studentregistrationid FROM failed_UNION_4 WHERE failed_UNION_4.studentregistrationid = courseregistrations_passed.studentregistrationid)
;


CREATE MATERIALIZED VIEW GPA AS
SELECT
	sr_to_deg.studentregistrationid as srid,
	(SUM(cr_passed.grade*courses.ects)/SUM(courses.ects)) AS GPA_score
FROM
	studentregistrationstodegrees AS sr_to_deg,
	courseregistrations_passed AS cr_passed,
	courseoffers AS co,
	courses
WHERE
	courses.courseid = co.courseid
	AND co.courseofferid = cr_passed.courseofferid
	AND sr_to_deg.studentregistrationid = cr_passed.studentregistrationid
GROUP BY sr_to_deg.studentregistrationid
;

CREATE MATERIALIZED VIEW inactive AS
SELECT studentregistrationstodegrees.studentregistrationid
FROM studentregistrationstodegrees, courses, degrees, courseoffers, courseregistrations_passed
WHERE studentregistrationstodegrees.degreeid = degrees.degreeid
AND courseregistrations_passed.courseofferid = courseoffers.courseofferid
AND courseregistrations_passed.studentregistrationid = studentregistrationstodegrees.studentregistrationid
AND courseoffers.courseid = courses.courseid
GROUP BY studentregistrationstodegrees.studentregistrationid, degrees.totalects
HAVING sum(courses.ects) >= degrees.totalects
;

--NORMAL VIEWS
CREATE VIEW CourseRegistrations AS 
SELECT * FROM courseregistrations_NULL
UNION ALL
SELECT * FROM courseregistrations_failed
UNION ALL
SELECT * FROM courseregistrations_4
UNION ALL
SELECT * FROM courseregistrations_passed;

CREATE VIEW max_grade_for_coid(coid,max_grade) AS
SELECT cr.CourseOfferId, max(cr.grade)
FROM CourseOffers AS co, CourseRegistrations AS cr
WHERE cr.CourseOfferId = co.CourseOfferId
 	AND co.Year = 2018 AND co.Quartile = 1
GROUP BY cr.CourseOfferId;

CREATE MATERIALIZED VIEW good_student(sid,good_grades) AS
SELECT srtg.StudentId AS sid , cr.grade AS good_grades
FROM max_grade_for_coid, CourseRegistrations AS cr, StudentRegistrationsToDegrees AS srtg
WHERE srtg.StudentRegistrationId = cr.StudentRegistrationId
	AND max_grade_for_coid.coid  = cr.CourseOfferId
	AND max_grade_for_coid.max_grade = cr.Grade
;
					       
					       
CREATE VIEW students_per_courseOffer(students,courseOfferID) AS 
SELECT  COUNT(C.Studentregistrationid), C.CourseOfferId
FROM CourseRegistrations as C
GROUP BY C.CourseOfferId;

CREATE VIEW assistants_per_courseOffer(assistants, courseOfferID) AS 
SELECT COUNT(studentregistrationid), CourseOfferID
FROM Studentassistants
GROUP BY CourseOfferID;

CREATE VIEW courses_with_no_assistants(courseofferID) AS
SELECT DISTINCT courseofferid
FROM CourseOffers
EXCEPT
SELECT DISTINCT courseofferid
FROM studentassistants;


CREATE OR REPLACE VIEW failed_UNION_4 AS
SELECT studentregistrationid FROM courseregistrations_4 UNION ALL SELECT studentregistrationid FROM courseregistrations_failed
;

CREATE VIEW active AS
(SELECT studentregistrationid
FROM studentregistrationstodegrees)
EXCEPT
(SELECT studentregistrationstodegrees.studentregistrationid
FROM studentregistrationstodegrees, inactive
WHERE studentregistrationstodegrees.studentregistrationid = inactive.studentregistrationid)
;

CREATE VIEW courses_with_too_few_assistants(courseofferId) AS
SELECT s.courseofferid
FROM students_per_courseOffer as S, assistants_per_courseOffer as A
WHERE s.courseofferid = a.courseofferid AND s.students/a.assistants>50;




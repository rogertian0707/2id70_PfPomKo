--NORMAL VIEWS
CREATE VIEW CourseRegistrations AS 
SELECT * FROM courseregistrations_NULL
UNION ALL
SELECT * FROM courseregistrations_failed
UNION ALL
SELECT * FROM courseregistrations_4
UNION ALL
SELECT * FROM courseregistrations_passed;

CREATE VIEW students_per_courseOffer(students,courseOfferID) AS 
SELECT C.CourseOfferId, CASE WHEN COUNT(C.Studentregistrationid) < 50 then 50 else COUNT(C.Studentregistrationid) end
FROM CourseRegistrations as C
GROUP BY C.CourseOfferId;

CREATE VIEW assistants_per_courseOffer(assistants, courseOfferID) AS 
SELECT COUNT(studentregistrationid), CourseOfferID
FROM Studentassistants
GROUP BY CourseOfferID;

CREATE VIEW max_grade_for_coid(coid,max_grade) AS
SELECT cr.CourseOfferId, max(cr.grade)
FROM CourseOffers AS co, CourseRegistrations_passed AS cr
WHERE cr.CourseOfferId = co.CourseOfferId
 	AND co.Year = 2018 AND co.Quartile = 1
GROUP BY cr.CourseOfferId;

--MATERIALIZED VIEW
CREATE MATERIALIZED VIEW good_student(sid,good_grades) AS
SELECT srtg.StudentId AS sid , cr.grade AS good_grades
FROM max_grade_for_coid, CourseRegistrations_passed AS cr, StudentRegistrationsToDegrees AS srtg
WHERE srtg.StudentRegistrationId = cr.StudentRegistrationId
	AND max_grade_for_coid.coid  = cr.CourseOfferId
	AND max_grade_for_coid.max_grade = cr.Grade
;

--INDICES
CREATE INDEX idx_student_degree ON studentregistrationstodegrees(studentid);

CREATE INDEX idx_course_id ON courseoffers(courseid);


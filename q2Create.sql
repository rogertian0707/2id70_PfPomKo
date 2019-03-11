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
FROM CourseOffers AS co, CourseRegistrations AS cr
WHERE cr.CourseOfferId = co.CourseOfferId
 	AND co.Year = 2018 AND co.Quartile = 1
GROUP BY cr.CourseOfferId;


CREATE OR REPLACE VIEW failed_UNION_4 AS
SELECT studentregistrationid FROM courseregistrations_4 UNION ALL SELECT studentregistrationid FROM courseregistrations_failed
;

CREATE VIEW active AS
SELECT s.studentid, studentname, address, birthyearstudent, gender
FROM    (SELECT cr.studentregistrationID, SUM(c.ects)
	FROM courseregistrations_passed as cr, courses as c, courseoffers as co
	WHERE cr.courseofferid = co.courseofferid AND co.courseid = c.courseid
	GROUP BY cr.studentregistrationID) as currentECTS(studentregistrationID, ECTS), 
	(SELECT studentID, srtd.studentregistrationID, totalects
	FROM degrees as d, studentregistrationstodegrees as srtd
	WHERE d.degreeid = srtd.degreeid) as neededECTS(studentID,studentregistrationID, ECTS),
	students as s
WHERE	currentECTS.studentregistrationID = neededECTS.studentregistrationID AND
	currentECTS.ECTS < neededECTS.ECTS AND
	neededECTS.studentid = s.studentid
UNION ALL
SELECT 	s.studentid, studentname, address, birthyearstudent, gender
FROM 	(SELECT studentregistrationid
	FROM studentregistrationstodegrees
	EXCEPT
	SELECT DISTINCT studentregistrationid
	FROM Courseregistrations) as noCourses,
	students as s, studentregistrationstodegrees as srtd
WHERE	s.studentid = srtd.studentid AND
	srtd.studentregistrationid = noCourses.studentregistrationid
;

CREATE VIEW courses_with_too_few_assistants(courseofferId) AS
SELECT s.courseofferid
FROM students_per_courseOffer as S, assistants_per_courseOffer as A
WHERE s.courseofferid = a.courseofferid AND s.students/a.assistants>50;

--MATERIALIZED VIEW
CREATE MATERIALIZED VIEW good_student(sid,good_grades) AS
SELECT srtg.StudentId AS sid , cr.grade AS good_grades
FROM max_grade_for_coid, CourseRegistrations AS cr, StudentRegistrationsToDegrees AS srtg
WHERE srtg.StudentRegistrationId = cr.StudentRegistrationId
	AND max_grade_for_coid.coid  = cr.CourseOfferId
	AND max_grade_for_coid.max_grade = cr.Grade
;

CREATE MATERIALIZED VIEW non_fail_stu AS
SELECT *
FROM courseregistrations_passed
WHERE NOT EXISTS( SELECT failed_UNION_4.studentregistrationid FROM failed_UNION_4 WHERE failed_UNION_4.studentregistrationid = courseregistrations_passed.studentregistrationid)
;

CREATE MATERIALIZED VIEW GPA AS
SELECT
	sr_to_deg.studentregistrationid as srid,
	(SUM(cr_passed.grade*courses.ects)/SUM(courses.ects)) AS GPA_score,
	(CASE WHEN SUM(courses.ects)<degrees.totalects THEN 1 ELSE 0 END) AS degree_complete_or_not
FROM
	studentregistrationstodegrees AS sr_to_deg,
	courseregistrations_passed AS cr_passed,
	courseoffers AS co,
	courses,
	degrees
WHERE
		courses.courseid = co.courseid
	AND co.courseofferid = cr_passed.courseofferid
	AND sr_to_deg.studentregistrationid = cr_passed.studentregistrationid
	AND sr_to_deg.degreeid = degrees.degreeid
GROUP BY sr_to_deg.studentregistrationid,degrees.totalects
;

--INDICES
CREATE INDEX idx_student_degree ON studentregistrationstodegrees(studentid);

CREATE INDEX idx_course_id ON courseoffers(courseid);


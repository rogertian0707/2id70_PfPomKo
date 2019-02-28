CREATE VIEW courseoffers_one AS
SELECT *
FROM courseoffers
WHERE courseoffers.CourseOfferId = 1;
SELECT courseoffers_one.CourseOfferId,courseoffers_one.CourseId,courseoffers_one.Year,courseoffers_one.Quartile,
courses.CourseName,courses.CourseDescription,courses.DegreeId,courses.ECTS,
degrees.Dept,degrees.DegreeDescription,degrees.TotalECTS,
teachers.TeacherId,teachers.TeacherName,teachers.Address,teachers.BirthyearTeacher,teachers.Gender
FROM courseoffers_one,courses,degrees,teachers,teacherAssignmentsToCourses
WHERE 	courseoffers_one.CourseId = courses.CourseId
		AND courses.DegreeId = degrees.DegreeId
		AND teacherAssignmentsToCourses.TeacherId = teachers.TeacherId
		AND teacherAssignmentsToCourses.CourseOfferId  = courseoffers_one.CourseOfferId;

SELECT courseoffers.courseofferid, courseoffers.courseid, courseoffers.year, courseoffers.quartile, courses.coursename, courses.coursedescription, degrees.degreeid, courses.ects, degrees.dept, degrees.degreedescription, degrees.totalects, teachers.teacherid, teachers.teachername, teachers.address, teachers.birthyearteacher, teachers.gender FROM courseoffers, courses, degrees, teachers, studentassistants, teacherassignmentstocourses WHERE studentassistants.studentregistrationid=140 AND studentassistants.courseofferid=courseoffers.courseofferid AND courseoffers.courseid=courses.courseid AND courses.degreeid=degrees.degreeid AND teacherassignmentstocourses.courseofferid=courseoffers.courseofferid AND teacherassignmentstocourses.teacherid=teachers.teacherid ;
SELECT AVG(Grade) FROM CourseRegistrations WHERE studentregistrationid=3;

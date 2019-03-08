#!/bin/bash
#
# create db
# createdb uni
START=$(date +%s)
psql -U postgres -c "CREATE DATABASE uni;"
#
#
# create table
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE Degrees(DegreeId INT PRIMARY KEY,Dept VARCHAR,DegreeDescription VARCHAR,TotalECTS INT);"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE Students(StudentId INT PRIMARY KEY,StudentName VARCHAR,Address VARCHAR,BirthyearStudent INT,Gender VARCHAR);"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE Teachers(TeacherId INT PRIMARY KEY,TeacherName VARCHAR,Address VARCHAR,BirthyearTeacher INT,Gender VARCHAR) ;"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE Courses(CourseId INT PRIMARY KEY,CourseName VARCHAR,CourseDescription VARCHAR,DegreeId INT ,ECTS INT);"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseOffers(CourseOfferId INT PRIMARY KEY,CourseId INT, Year INT ,Quartile INT );"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE StudentRegistrationsToDegrees(StudentRegistrationId INT PRIMARY KEY,StudentId INT,DegreeId INT ,RegistrationYear INT );"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseRegistrations(CourseOfferId INT,StudentRegistrationId INT ,Grade INT );"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE StudentAssistants(CourseOfferId INT,StudentRegistrationId INT );"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE TeacherAssignmentsToCourses(CourseOfferId INT ,TeacherId INT);"
#
# copy data
psql -U postgres -d uni -c "COPY CourseOffers(CourseOfferId,CourseId,Year,Quartile)  FROM '/mnt/ramdisk/tables/CourseOffers.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY CourseRegistrations(CourseOfferId,StudentRegistrationId,Grade)  FROM '/mnt/ramdisk/tables/CourseRegistrations.table' DELIMITER ',' CSV HEADER NULL 'null';"
psql -U postgres -d uni -c "COPY Courses(CourseId,CourseName,CourseDescription,DegreeId,ECTS)  FROM '/mnt/ramdisk/tables/Courses.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY Degrees(DegreeId,Dept,DegreeDescription,TotalECTS)  FROM '/mnt/ramdisk/tables/Degrees.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY StudentAssistants(CourseOfferId,StudentRegistrationId)  FROM '/mnt/ramdisk/tables/StudentAssistants.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY StudentRegistrationsToDegrees(StudentRegistrationId,StudentId,DegreeId,RegistrationYear)  FROM '/mnt/ramdisk/tables/StudentRegistrationsToDegrees.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY Students(StudentId,StudentName,Address,BirthyearStudent,Gender)  FROM '/mnt/ramdisk/tables/Students.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY TeacherAssignmentsToCourses(CourseOfferId,TeacherId)  FROM '/mnt/ramdisk/tables/TeacherAssignmentsToCourses.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "COPY Teachers(TeacherId,TeacherName,Address,BirthyearTeacher,Gender)  FROM '/mnt/ramdisk/tables/Teachers.table' DELIMITER ',' CSV HEADER;"
psql -U postgres -d uni -c "VACUUM;"
psql -U postgres -d uni -c "ANALYZE;"
#
#
# loading CourseRegistrations to small tables
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseRegistrations_NULL AS SELECT * FROM CourseRegistrations WHERE NOT (CourseRegistrations.grade IS NOT NULL) ORDER BY studentregistrationid;"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseRegistrations_failed AS SELECT * FROM CourseRegistrations WHERE grade < 4 ORDER BY studentregistrationid;"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseRegistrations_4 AS SELECT * FROM CourseRegistrations WHERE grade = 4 ORDER BY studentregistrationid;"
psql -U postgres -d uni -c "CREATE UNLOGGED TABLE CourseRegistrations_passed AS SELECT * FROM CourseRegistrations WHERE grade >4 ORDER BY studentregistrationid;"
psql -U postgres -d uni -c "DROP TABLE CourseRegistrations;"
psql -U postgres -d uni -c "ALTER TABLE courseregistrations_4 ADD PRIMARY KEY (studentregistrationid,courseofferid);"
psql -U postgres -d uni -c "ALTER TABLE courseregistrations_null ADD PRIMARY KEY (studentregistrationid,courseofferid);"
psql -U postgres -d uni -c "ALTER TABLE courseregistrations_failed ADD PRIMARY KEY (studentregistrationid,courseofferid);"
psql -U postgres -d uni -c "ALTER TABLE courseregistrations_passed ADD PRIMARY KEY (studentregistrationid,courseofferid);"
#
#OPTIMIZATION
# DO NOT SET FK, slow down performance
#
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_0 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_garbage ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_4 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_5 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_6 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_7 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_8 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_9 ADD PRIMARY KEY (CourseOfferId);"
# psql -U postgres -d uni -c "ALTER TABLE CourseRegistrations_10 ADD PRIMARY KEY (CourseOfferId);"
# #
#DATA TYPE OPTIMIZATION (BY DAVID)
# psql -U postgres -d uni -c "ALTER TABLE courseoffers ALTER COLUMN year TYPE smallint USING year::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE courseoffers ALTER COLUMN quartile TYPE smallint USING quartile::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE courseregistrations ALTER COLUMN grade TYPE smallint USING grade::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE courses ALTER COLUMN degreeid TYPE smallint USING degreeid::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE courses ALTER COLUMN ects TYPE smallint USING ects::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE courses ALTER COLUMN coursename TYPE varchar(50) USING coursename::varchar(50) ;"
# psql -U postgres -d uni -c "ALTER TABLE courses ALTER COLUMN coursedescription TYPE varchar(200) USING coursedescription::varchar(200) ;"
# psql -U postgres -d uni -c "ALTER TABLE degrees ALTER COLUMN degreeid TYPE smallint USING degreeid::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE degrees ALTER COLUMN dept TYPE varchar(50) USING dept::varchar(50) ;"
# psql -U postgres -d uni -c "ALTER TABLE degrees ALTER COLUMN degreedescription TYPE varchar(200) USING degreedescription::varchar(200) ;"
# psql -U postgres -d uni -c "ALTER TABLE degrees ALTER COLUMN totalects TYPE smallint USING totalects::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE studentregistrationstodegrees ALTER COLUMN degreeid TYPE smallint USING degreeid::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE studentregistrationstodegrees ALTER COLUMN registrationyear TYPE smallint USING registrationyear::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE students ALTER COLUMN studentname TYPE varchar(50) USING studentname::varchar(50) ;"
# psql -U postgres -d uni -c "ALTER TABLE students ALTER COLUMN address TYPE varchar(200) USING address::varchar(200) ;"
# psql -U postgres -d uni -c "ALTER TABLE students ALTER COLUMN birthyearstudent TYPE smallint USING birthyearstudent::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE students ALTER COLUMN gender TYPE char(1) USING gender::char(1) ;"
# psql -U postgres -d uni -c "ALTER TABLE teachers ALTER COLUMN teachername TYPE varchar(50) USING teachername::varchar(50) ;"
# psql -U postgres -d uni -c "ALTER TABLE teachers ALTER COLUMN address TYPE varchar(200) USING address::varchar(200) ;"
# psql -U postgres -d uni -c "ALTER TABLE teachers ALTER COLUMN birthyearteacher TYPE smallint USING birthyearteacher::smallint ;"
# psql -U postgres -d uni -c "ALTER TABLE teachers ALTER COLUMN gender TYPE char(1) USING gender::char(1) ;"
#
END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo "It takes DIFF=$DIFF seconds to complete this task..."

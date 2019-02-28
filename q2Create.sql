CREATE INDEX idx_studentRegistrationID ON CourseRegistrations(studentregistrationID);
-- Takes 3:18 minutes. Drastically improves time needed for queries 1,6 and 8 (still need to test the others).
CREATE INDEX idx_student_degree ON studentregistrationstodegrees(studentid,degreeid);
-- Takes 16 seconds. Makes query 1 basically instant.

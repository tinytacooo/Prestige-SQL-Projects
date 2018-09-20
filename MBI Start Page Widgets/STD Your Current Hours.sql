-- Current Attended Hours in School (student widget)
-- Author: Kelly MJ   |   7/19/2018
    -- Lists students' hours attended, scheduled, and remaining
-- Update 7/26/18: Added 'Hours Transferred' to the balance
-- Update 9/5/18: Added "Programmes" join to calculate scheduled hours
-- Kelly MJ 9/18/2018: Added breakdown of regular/intern clinic hours

-- Intern Clinic Hours
(SELECT '<strong>Clinic Attendance:</strong>' AS ' '
     , FORMAT(C.instructHour, 2) 'Hours Required'		-- Intern clinic hours scheduled
     , FORMAT(SUM(A.duration),2) 'Hours Attended'    -- hours attended
     , FORMAT(C.instructHour - SUM(A.duration), 2) 'Hours Remaining'
    
FROM Registrations R
   
INNER JOIN (SELECT studentId, MAX(startDate) AS maxDate FROM Registrations GROUP BY studentId) R2
	ON R2.studentId = R.studentId AND R2.maxDate = R.startDate

INNER JOIN Attendance A
	ON R.studentId = A.studentId
	AND A.isActive = 1
	AND A.attendanceDate >= R.startDate

INNER JOIN Programmes P
	ON P.programmeId = R.programmeId

INNER JOIN Classes C
	ON C.classId = A.classId
	AND C.isActive = 1
	AND C.subjectId IN (SELECT subjectId FROM GroupSubjectReltn GSR, CourseGroups CG
						WHERE CG.programmeId=R.programmeId AND CG.isActive=1
	                    AND CG.courseGroupId=GSR.courseGroupId AND GSR.isActive=1)
	AND (C.className LIKE '%Intern%' OR C.className LIKE '%IC')

INNER JOIN ClassStudentReltn CSR
	ON CSR.classId = C.classId
	AND CSR.isActive = 1
	AND R.studentId = CSR.studentId

INNER JOIN Students S
	ON R.studentId = S.studentId
	AND S.isActive = 1 

WHERE R.<ADMINID>
	AND R.studentId = [USERID]
  
GROUP BY R.registrationId)

UNION	-- Massage Class Hours
(SELECT '<strong>Class Attendance</strong>'
	 , FORMAT(C.instructHour, 2) 'Hours Required'		-- Massage class hours scheduled
     , FORMAT(SUM(A.duration),2) 'Hours Attended'    -- hours attended
     , FORMAT(C.instructHour - SUM(A.duration), 2) 'Hours Remaining'
    
FROM Registrations R
   
INNER JOIN (SELECT studentId, MAX(startDate) AS maxDate FROM Registrations GROUP BY studentId) R2
	ON R2.studentId = R.studentId AND R2.maxDate = R.startDate

INNER JOIN Attendance A
	ON R.studentId = A.studentId
	AND A.isActive = 1
	AND A.attendanceDate >= R.startDate

INNER JOIN Programmes P
	ON P.programmeId = R.programmeId

INNER JOIN Classes C
	ON C.classId = A.classId
	AND C.isActive = 1
	AND C.subjectId IN (SELECT subjectId FROM GroupSubjectReltn GSR, CourseGroups CG
						WHERE CG.programmeId=R.programmeId AND CG.isActive=1
	                    AND CG.courseGroupId=GSR.courseGroupId AND GSR.isActive=1)
	AND C.className NOT LIKE '%Intern%'
	AND C.className NOT LIKE '%IC'

INNER JOIN ClassStudentReltn CSR
	ON CSR.classId = C.classId
	AND CSR.isActive = 1
	AND R.studentId = CSR.studentId

INNER JOIN Students S
	ON R.studentId = S.studentId
	AND S.isActive = 1 

WHERE R.<ADMINID>
	AND R.studentId = [USERID]
  
GROUP BY R.registrationId)

UNION -- Overall Hours
(SELECT '<strong>Attendance Overall:</strong>' AS 'Category'
     , FORMAT(P.minClockHours, 2) 'Hours Required'		-- Total hours scheduled
	 , FORMAT(SUM(A.duration),2) 'Hours Attended'    -- hours attended
     , FORMAT(P.minClockHours - SUM(A.duration) - R.transferUnits, 2) 'Hours Remaining'
    
FROM Registrations R
   
INNER JOIN (SELECT studentId, MAX(startDate) AS maxDate FROM Registrations GROUP BY studentId) R2
	ON R2.studentId = R.studentId AND R2.maxDate = R.startDate

INNER JOIN Attendance A
	ON R.studentId = A.studentId
	AND A.isActive = 1
	AND A.attendanceDate >= R.startDate

INNER JOIN Programmes P
	ON P.programmeId = R.programmeId

INNER JOIN Classes C
	ON C.classId = A.classId
	AND C.isActive = 1
	AND C.subjectId IN (SELECT subjectId FROM GroupSubjectReltn GSR, CourseGroups CG
						WHERE CG.programmeId=R.programmeId AND CG.isActive=1
	                    AND CG.courseGroupId=GSR.courseGroupId AND GSR.isActive=1)

INNER JOIN ClassStudentReltn CSR
	ON CSR.classId = C.classId
	AND CSR.isActive = 1
	AND R.studentId = CSR.studentId

INNER JOIN Students S
	ON R.studentId = S.studentId
	AND S.isActive = 1 

WHERE R.<ADMINID>
	AND R.studentId = [USERID]
  
GROUP BY R.registrationId)
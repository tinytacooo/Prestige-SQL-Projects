-- USTA Payroll Report
-- Written by Andrew
-- Edited by Kelly MJ
-- Last Updated: 6/6/2018
-- Changed hours total from hour:minute to decimal format
-- Now only sums up 1 duration value per employee per day to obtain weekly hours - this avoids counting double punches.
-- Added column to display Vacation/Illness reasons

SELECT t1.TeacherID
  , t1.Name AS 'Staff Member Name'
  , t1.DOW AS 'Day Of The Week'
  , DATE_FORMAT(t1.ATDate, '%m/%d/%Y') AS 'Attendance Date'
  , CP.punchTimes 'Un-Rounded Punch Times'
  , CONCAT(CAST(FLOOR((t1.rawDuration)) AS CHAR), ':', LPAD(CAST(FLOOR(60*((t1.rawDuration) - FLOOR((t1.rawDuration)))) AS CHAR), 2, '0')) 'Rounded Duration'
  , CONCAT((SELECT fieldValue FROM ProfileFieldValues WHERE fieldName = 'BREAK_TIME' AND userId = t1.TeacherID), ' min') 'Break Time'
  -- formatted daily duration as "hh:mm"
  , CONCAT(CAST(FLOOR((t1.duration)) AS CHAR), ':', LPAD(CAST(FLOOR(60*((t1.duration) - FLOOR((t1.duration)))) AS CHAR), 2, '0')) AS 'Rounded Duration - Break Time'

FROM
      (SELECT T.teacherID AS TeacherID
        , CONCAT('<a href="admin_view_teacher.jsp?teacherid=', CAST(T.teacherId AS CHAR),'"target="_blank">', T.firstName, ' ', T.lastName, '</a>') AS Name
        , TA.attendanceDate AS ATdate
        , MAX(duration) AS rawDuration
        , MAX(duration) - (SELECT fieldValue/60 FROM ProfileFieldValues WHERE fieldName = 'BREAK_TIME' AND userId = T.teacherId) AS duration
        , T.campusCode AS Campus_Code
        , DAYNAME(TA.attendanceDate) AS DOW
        , MAX(TA.teacherAttendanceId)
        , TA.reasonType
        , TA.reasonText
        , 1 AS isTeacher
       FROM TeacherAttendance TA
       INNER JOIN Teachers T
           ON TA.teacherID = T.teacherID
       WHERE DATE(TA.attendancedate)  BETWEEN '[?Start Date]' AND '[?End Date]'
         AND TA.isactive = 1
         and T.isactive = 1
         AND (duration > 0 OR TA.reasonType > 0 OR TA.reasonText > 'a')
         AND T.<ADMINID>
       GROUP BY T.teacherID, TA.attendancedate
UNION
       SELECT SA.SubadminID AS TeacherID
       , CONCAT('<a href="admin_view_subadmin.jsp?subadminid=', CAST(SA.subAdminId AS CHAR),'" target="_blank">', SA.firstName, ' ', SA.lastName, '</a>') AS Name
       , SAA.attendanceDate AS ATdate
       , MAX(duration) AS rawDuration
       , MAX(duration) - (SELECT fieldValue/60 FROM ProfileFieldValues WHERE fieldName = 'BREAK_TIME' AND userId = SA.subAdminId) AS duration
       , SA.campusCode AS Campus_Code
       , DAYNAME(SAA.attendanceDate) AS DOW
       , MAX(SAA.subAdminAttendanceId)
       , SAA.reasonType
       , SAA.reasonText
       , 0 AS isTeacher
       FROM SubAdminAttendance SAA
       INNER JOIN SubAdmins SA
       ON SA.SubAdminID = SAA.SubAdminID
       WHERE DATE(SAA.attendancedate)  BETWEEN '[?Start Date]' AND '[?End Date]'
         AND SAA.isactive = 1
         and SA.isactive = 1
         AND (duration > 0 OR SAA.reasonType > 0 OR SAA.reasonText > 'a')
         AND SA.<ADMINID>
         GROUP BY SA.subAdminID, SAA.attendanceDate
             ) AS t1

INNER JOIN (
  SELECT C.userId, C.punchDate, GROUP_CONCAT(C.punchTime ORDER BY C.clockPunchId SEPARATOR '; ') AS punchTimes
  FROM (
    SELECT userId
      , DATE_FORMAT(punchTime, '%h:%i %p') AS punchTime
      , DATE(punchTime) as punchDate
      , clockPunchId
      FROM ClockPunches
          WHERE isActive > 0) C
  GROUP BY C.userId, C.punchDate) CP
  ON CP.userId = t1.TeacherID
  AND CP.punchDate = t1.ATDate


UNION
SELECT t3.TeacherID, NULL, NULL, NULL, t3.n3, t3.n4, NULL,
CONCAT('</td></tr><tr><td></td><td colspan="7" style="text-align: right; font color: white; font-size: 150%; font-weight: bold;">','',
CONCAT('</td></tr><tr><td></td><td colspan="7" style="text-align: right; font color: white; font-size: 150%; background-color: #A8D0E6; font-weight: bold;">','<div align="right">'
,t3.Name,"'s" '  Weekly Hours Are','  '
    , CONCAT(CAST(FLOOR(SUM(t3.duration)) AS CHAR), ':', LPAD(CAST(FLOOR(60*(SUM(t3.duration) - FLOOR(SUM(t3.duration)))) AS CHAR), 2, '0'))
    -- , FORMAT(SUM(t3.duration) - COUNT(t3.duration)*BT.fieldValue/60, 2)      -- original sum (decimal format)
    , CONCAT('</td></tr><tr><td></td><td colspan="7" style="text-align: right; font color: white; font-size: 150%; font-weight: bold;">','','','</td></tr></font></div>')))

FROM (
    SELECT T.teacherID AS TeacherID
        , CONCAT('<a href="admin_view_teacher.jsp?teacherid=', CAST(T.teacherId AS CHAR),'"target="_blank">', T.firstName, ' ', T.lastName, '</a>') AS Name
        , TA.attendanceDate AS ATdate
        , MAX(duration) - (SELECT fieldValue/60 FROM ProfileFieldValues WHERE fieldName = 'BREAK_TIME' AND userId = T.teacherId) AS duration
        , T.campusCode AS Campus_Code
        , MAX(TA.teacherAttendanceId)
        , NULL AS n3
        , NULL AS n4
       FROM TeacherAttendance TA
       INNER JOIN Teachers T
           ON TA.teacherID = T.teacherID
       WHERE DATE(TA.attendancedate)  BETWEEN '[?Start Date]' AND '[?End Date]'
         AND TA.isactive = 1
         and T.isactive = 1
         AND (duration > 0 OR TA.reasonType > 0)
         AND T.<ADMINID>
       GROUP BY T.teacherID, TA.attendancedate
UNION
       SELECT SA.SubadminID AS TeacherID
       , CONCAT('<a href="admin_view_subadmin.jsp?subadminid=', CAST(SA.subAdminId AS CHAR),'" target="_blank">', SA.firstName, ' ', SA.lastName, '</a>') AS Name
       , SAA.attendanceDate AS ATdate
       , MAX(duration) - (SELECT fieldValue/60 FROM ProfileFieldValues WHERE fieldName = 'BREAK_TIME' AND userId = SA.subAdminId) AS duration
       , SA.campusCode AS Campus_Code
       , MAX(SAA.subAdminAttendanceId)
       , NULL AS n3
       , NULL AS n4
       FROM SubAdminAttendance SAA
       INNER JOIN SubAdmins SA
       ON SA.SubAdminID = SAA.SubAdminID
       WHERE DATE(SAA.attendancedate)  BETWEEN '[?Start Date]' AND '[?End Date]'
         AND SAA.isactive = 1
         and SA.isactive = 1
         AND (duration > 0 OR SAA.reasonType > 0)
         AND SA.<ADMINID>
         GROUP BY SA.subADminID, SAA.attendanceDate
             ) AS t3

GROUP BY TeacherID
ORDER BY TeacherID

SELECT 
	t1.IncidentNo,
	CONVERT(VARCHAR, CURRENT_TIMESTAMP, 121) AS TimeNow,
	t1.IncDate,
	t2.LastNote,
	t3.D,
	t3.E,
	t3.O,
	t3.A,
	t1.Nature,
	t1.Grid,
	t1.Trucks
FROM tblActiveFireCalls t1
LEFT JOIN (
	SELECT 
		Incident,
		MAX( NoteTime ) AS LastNote
	FROM tblActiveCallNotes 
	GROUP BY Incident
) t2 ON t2.Incident = t1.IncidentNo
LEFT JOIN (
	SELECT 
		Incident,
		MAX( Dispatched ) AS D,
		MAX( Enroute ) AS E,
		MAX( Onscene ) AS O,
		MAX( Available ) AS A		
	FROM tblActiveTrucks 
	GROUP BY Incident
) t3 ON t3.Incident = t1.IncidentNo
ORDER BY IncDate ASC;

-- Filter out Patients Who don have both baseline and 6-week survey questions
WITH FilteredPatients AS (
	SELECT [PatientID]
	FROM [PH_Views].[dbo].[PROMPT_Surveys_tbl]
	WHERE [SurveyName] LIKE 'Baseline%' OR [SurveyName] LIKE '6-week%'
	GROUP BY [PatientID]
	HAVING COUNT(DISTINCT [SurveyName]) = 2
), 
FilteredSurvey AS (
-- Select out survey questions for those satisfying above criteria
	SELECT fp.[PatientID],
		   p.[SurveyKey],
		   p.[SurveyName],
		   p.[SurveyQuestionEndDate],
		   p.[SurveyQuestion],
		   p.[SurveyAnswer],
		   p.[PossibleAnswers]
	  FROM FilteredPatients fp
	  LEFT JOIN [PH_Views].[dbo].[PROMPT_Surveys_tbl] p
	  ON fp.PatientID = p.PatientID
	  -- Select Sucidal Ideation questions, and demographics
	  WHERE 
		(p.[SurveyName] LIKE '6-Week%' AND p.[SurveyQuestion] LIKE '%killing yourself%')
		OR
		(p.[SurveyName] LIKE 'Baseline%' AND p.[SurveyQuestion] Like '%gender%'
			OR
		 p.[SurveyName] LIKE 'Baseline%' AND p.[SurveyQuestion] Like '%sex%'
			OR
		 p.[SurveyName] LIKE 'Baseline%' AND p.[SurveyQuestion] Like '%Hispanic%'
			OR
		 p.[SurveyName] LIKE 'Baseline%' AND p.[SurveyQuestion] Like '%employment status%'
			OR
		 p.[SurveyName] LIKE 'Baseline%' AND p.[SurveyQuestion] Like '%relationship status%'
		)
), 
SubjectDateCounts AS (
	SELECT [PatientID],
		CAST([SurveyQuestionEndDate] as DATE) AS EndDate
	FROM FilteredSurvey
	WHERE [SurveyName] LIKE '6-Week%'
	GROUP BY [PatientID], CAST(SurveyQuestionEndDate AS DATE)
),
SubjectDateRange AS (
	SELECT [PatientID],
		MIN(EndDate) AS MinDate,
		MAX(EndDate) As MaxDate
	FROM SubjectDateCounts
	GROUP BY [PatientID]
),
ExcludedSubjects AS (
	SELECT [PatientID]
	FROM SubjectDateRange
	WHERE DATEDIFF(DAY, MinDate, MaxDate) > 3
),
FinalSurveyData AS (

SELECT fs.*
FROM FilteredSurvey fs
LEFT JOIN ExcludedSubjects es
ON fs.PatientID = es.PatientID
WHERE es.PatientID IS NULL
),
CommonPatients AS (
	SELECT DISTINCT fsd.PatientID
	FROM FinalSurveyData fsd
	JOIN [PH_Views].[dbo].[PROMPT_FitbitDailyData_tbl] fdd ON fsd.PatientID = fdd.PatientID
	JOIN [PH_Views].[dbo].[PROMPT_FitbitSleepLogSummary_tbl] fsl ON fsd.PatientID = fsl.PatientID
)

-- Step 8: Efficiently Filter Fitbit Daily Data Before `MinDate`
SELECT fdd.*
FROM [PH_Views].[dbo].[PROMPT_FitbitDailyData_tbl] fdd
WHERE EXISTS (
	-- Ensure PatientID is in the Survey data (FinalSurveyData)
	SELECT 1 FROM FinalSurveyData fsd
	WHERE fsd.PatientID = fdd.PatientID
)
AND EXISTS (
	-- Ensure PatientID is also in Fitbit Sleep Log Summary
	SELECT 1 FROM [PH_Views].[dbo].[PROMPT_FitbitSleepLogSummary_tbl] fsl
	WHERE fsl.PatientID = fdd.PatientID
)
AND fdd.[Date] < (
	-- Get MinDate dynamically for each patient
	SELECT MIN(sr.MinDate)
	FROM SubjectDateRange sr
	WHERE sr.PatientID = fdd.PatientID
)
ORDER BY fdd.PatientID, fdd.Date




		
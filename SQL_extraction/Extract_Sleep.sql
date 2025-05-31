
WITH FilteredPatients AS (
	-- Step 1: Select only patients who have both baseline and 6-week survey questions
	SELECT [PatientID]
	FROM [PH_Views].[dbo].[PROMPT_Surveys_tbl]
	WHERE [SurveyName] LIKE 'Baseline%' OR [SurveyName] LIKE '6-week%'
	GROUP BY [PatientID]
	HAVING COUNT(DISTINCT [SurveyName]) = 2
), 
FilteredSurvey AS (
	-- Step 2: Select relevant survey responses for those satisfying the above criteria
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
	-- Step 3: Count distinct 6-Week SurveyQuestionEndDate (date part only) per subject
	SELECT [PatientID],
		CAST([SurveyQuestionEndDate] as DATE) AS EndDate	-- Extracts date only
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
	-- Step 4: Identify the Min and Max date per patient
	SELECT [PatientID]
	FROM SubjectDateRange
	WHERE DATEDIFF(DAY, MinDate, MaxDate) > 3
),
FinalSurveyData AS (
	-- Step 6: Retrieve final dataset excluding patients with >3-day difference
	SELECT fs.*
	FROM FilteredSurvey fs
	LEFT JOIN ExcludedSubjects es
	ON fs.PatientID = es.PatientID
	WHERE es.PatientID IS NULL -- Exclude subjects where difference is too large
	),
	CommonPatients AS (
		SELECT DISTINCT fsd.PatientID
		FROM FinalSurveyData fsd
		JOIN [PH_Views].[dbo].[PROMPT_FitbitDailyData_tbl] fdd ON fsd.PatientID = fdd.PatientID
		JOIN [PH_Views].[dbo].[PROMPT_FitbitSleepLogSummary_tbl] fsl ON fsd.PatientID = fsl.PatientID
)
-- Step 8: Efficiently Filter Fitbit Sleep Log Data Before `MinDate`
SELECT fsl.*
FROM [PH_Views].[dbo].[PROMPT_FitbitSleepLogSummary_tbl] fsl
WHERE EXISTS (
	-- Ensure PatientID is also in Fitbit Sleep Log Summary (FinalSurveyData)
	SELECT 1 FROM FinalSurveyData fsd
	WHERE fsd.PatientID = fsl.PatientID
)
AND EXISTS (
	-- Ensure PatientID is also in Fitbit Daily Data
	SELECT 1 FROM [PH_Views].[dbo].[PROMPT_FitbitDailyData_tbl] fdd
	WHERE fdd.PatientID = fsl.PatientID
)
AND fsl.[EndDate] < (
	-- Get MinDate dynamically for each patient
	SELECT MIN(sr.MinDate)
	FROM SubjectDateRange sr
	WHERE sr.PatientID = fsl.PatientID
)
ORDER BY fsl.PatientID, fsl.EndDate




		
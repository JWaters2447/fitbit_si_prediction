
-- Filter out Patients Who don have both baseline and 6-week survey questions
WITH FilteredPatients AS (
	SELECT [PatientID]
	FROM [PH_Views].[dbo].[PROMPT_Surveys_tbl]
	WHERE [SurveyName] LIKE 'Baseline%' OR [SurveyName] LIKE '6-week%'
	GROUP BY [PatientID]
	HAVING COUNT(DISTINCT [SurveyName]) = 2
)
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
  ORDER BY [PatientID], [SurveyName]
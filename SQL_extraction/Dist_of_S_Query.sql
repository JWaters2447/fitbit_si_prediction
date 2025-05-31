/****** Script for SelectTopNRows command from SSMS  ******/
SELECT MaxSurveyAnswer, COUNT(*) AS Frequency
FROM (
	SELECT TOP 1 WITH TIES
		[PatientID],
		[SurveyName],
		[SurveyAnswer] AS MaxSurveyAnswer,
		[SurveyEndDate]
	FROM [PH_Views].[dbo].[PROMPT_Surveys_tbl]
	WHERE [SurveyName] LIKE 'Baseline%'
	AND [SurveyQuestion] LIKE '%killing yourself%'
	ORDER BY
		ROW_NUMBER() OVER (PARTITION BY [PatientID] ORDER BY [SurveyAnswer] DESC)
) AS MaxSurveyResults
GROUP BY MaxSurveyAnswer
ORDER BY MaxSurveyAnswer ASC;











/*SELECT 
[PatientID],
[SurveyName], 
[SurveyQuestion],
[SurveyAnswer],
[SurveyAnswerDate],
[SurveyEndDate]
FROM [PH_Views].[dbo].[PROMPT_Surveys_tbl]
WHERE [SurveyName] LIKE '12-Month%'
AND [SurveyQuestion] LIKE '%killing yourself%'
ORDER BY [PatientID] ASC, [SurveyQuestion] ASC;*/
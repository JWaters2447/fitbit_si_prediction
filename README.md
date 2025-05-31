# Predicting Suicidal Ideation from Fitbit Data

This project was completed as part of my graduate coursework (BIOSTAT 629) at the University of Michigan. It explores the use of Fitbit-derived health metrics and survey data to predict suicidal ideation levels based on PHQ-9 responses using statistical and deep learning models.

## Project Overview

- **Goal:** Predict future suicidal ideation severity from daily Fitbit data
- **Data:** PHQ-9 survey responses (collected at multiple time points) + daily Fitbit metrics (sleep, activity, BMI, calories burned) recorded over 6 months
- **Outcome:** PHQ-9 suicidal ideation score (ordinal: 1–5)
- **Predictors:** Fitbit physical activity, calorie intake, and sleep metrics

## Methods

- **Data Extraction:** SQL queries run on the University of Michigan Yottabyte ecosystem (via Mott Hospital)
- **Preprocessing & Imputation:** 
  - R (packages: `mice`, `tidyverse`)

- **Modeling Approaches:**
  - Linear and generalized linear models (R)
  - Deep learning using PyTorch (CNN, LSTM for time-series prediction)

- **Evaluation:**
  - Cross-validation, RMSE, AUC, SHAP scores

- **Platform:** SLURM-based HPC system

## Project Structure

```
├── EDA/              # Exploratory data analysis (R and Python)
├── SQL_extraction/   # SQL scripts for pulling data from the Yottabyte platform
├── data/             # [Excluded] Raw data directory (subject-protected)
├── figures/          # Plots for EDA, modeling and demographic table
├── modeling/         # Main model code (OLS, CNN, LSTM subfolders)
│   ├── OLS/	        # OLS modeling
│   ├── CNN/            # CNN modeling
│   ├── LSTM/           # LSTM modeling
├── preprocessing/    # Data cleaning, imputation, feature engineering

```

## Notes
- The `data/` folder is excluded to protect subject confidentiality and follow IRB guidelines
- Project integrates both R and Python, depending on the task (preprocessing vs modeling)
- Models are designed to explore prediction feasibility, not for clinical decision-making

## Tools Used

- **Languages:** Python, R, SQL
- **Libraries:** PyTorch, pandas, scikit-learn, tidyverse, mice
- **Platform:** SLURM HPC system (for model training and parallel processing)



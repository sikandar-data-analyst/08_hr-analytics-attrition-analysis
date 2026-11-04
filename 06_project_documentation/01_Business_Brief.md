# Business Brief — HR Analytics

## Background

A company wants to understand its workforce and, in particular, its attrition: how many people leave, who they are, and whether anything in the HR data explains it. The dataset covers 50,000 employees across five departments, hired between January 2015 and January 2025.

This is a practice project on what appears to be a synthetic dataset. The brief is written as a realistic business request so the analysis has a clear purpose.

## Objective

Describe the current workforce, measure attrition, and identify any drivers of attrition, pay differences or retention risk that HR could act on.

## Scope

**In scope:** workforce profile, attrition overall and by group, pay and performance relationships, the quality of the `RetentionRisk` label, reasons for leaving, data quality.

**Out of scope:** forecasting future headcount, cost-of-attrition modelling (the data has recruitment cost but no cost of lost productivity), and anything needing data that isn't in the file (exit interviews, manager feedback, market pay).

## Data

| | |
|---|---|
| Source file | `01_raw_data/HR_raw_data.csv` |
| Size | 50,000 rows × 40 columns |
| Key | `EmployeeID` (unique, no duplicates) |
| Cleaned version | `03_python/HR_cleaned_data.csv` (50,000 rows × 41 columns: 2 columns dropped, 3 added) |

See [`03_Data_Dictionary.md`](03_Data_Dictionary.md) for every column.

## Business questions

### Part 1 — Descriptive analysis (Excel, Python, SQL, Power BI)

1. What is the overall attrition rate, and how does it differ by department?
2. Which departments have the highest average salary and bonus?
3. Is `PerformanceRating` associated with `Salary` or `Bonus`?
4. Is `StressLevelScore` associated with `Absences` or `JobSatisfactionScore`?
5. Which `HireSource` is associated with longer tenure or better performance?
6. How does `RetentionRisk` relate to `EmployeeEngagementScore` and `JobSatisfactionScore`?
7. Does average `Salary` differ by `Gender`?
8. How does `PromotionCount` relate to `YearsAtCompany`?
9. What are the average `RecruitmentCost` and `TimeToFillPosition` by department?

### Part 2 — Attrition drivers (Python)

10. What does the 33% attrition figure mean as a yearly rate, and how has it changed over time?
11. Is any column statistically linked to who leaves?
12. Can a model predict who leaves from the other columns?
13. Does the `RetentionRisk` label match actual attrition?
14. Why do people leave, and how complete is that information?
15. Does `YearsAtCompany` agree with the hire and termination dates?

## Definitions

| Term | Definition |
|---|---|
| Attrition rate | Terminated employees ÷ all employees (cumulative, 2015–2025) |
| Yearly exit rate | Exits in a year ÷ headcount at the start of that year |
| Leaver | `EmploymentStatus = 'Terminated'` |
| Stayer | Active or On Leave |
| Data-quality flag | A column marking a suspect row. The row is kept, not deleted. |

## Deliverables

| Deliverable | Location |
|---|---|
| Data-quality checks and summary tables | `02_excel/HR_Initial_Analysis.xlsx` |
| Cleaning, EDA and driver analysis | `03_python/HR_Analysis.ipynb` |
| SQL analysis | `04_sql/HR_Analysis.sql` |
| Dashboards | `05_powerbi/` |
| Insights and recommendations | `02_Business_Insights.md` |

## Approach and assumptions

- Suspicious values are **flagged, not deleted or guessed**, because the true values are unknown.
- Blank `TerminationDate` and `ReasonForLeaving` are expected for people who haven't left, and blank `LastPromotionDate` for people never promoted.
- Salary is treated as US dollars, as in the notebook charts. The data does not state a currency.
- The last termination date in the file (30 January 2025) is used as the "today" date when tenure is rebuilt from dates.

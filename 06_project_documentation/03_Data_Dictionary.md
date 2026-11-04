# Data Dictionary

Describes every column in `03_python/HR_cleaned_data.csv` (50,000 rows × 41 columns). Ranges and counts were measured from the file.

> **Note:** The source has no documentation, so meanings are **inferred from the column names**. Units and time periods (for example, what period "absences" covers) are not stated in the data. Confirm with the data owner before relying on them.

**Date format:** the raw file stores dates as text in `DD-MM-YYYY`. The cleaned file stores them as `YYYY-MM-DD`.
**Flag columns:** `0` = no problem, `1` = problem found.

## Identity and demographics

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `EmployeeID` | integer | Unique employee identifier | 1 – 50,000 | Primary key; no duplicates |
| `DateOfBirth` | date | Employee's date of birth | 1959-02-01 – 2007-01-30 | |
| `Gender` | text | Gender | Male, Female, Non-Binary | About 16,500–16,800 each |
| `DiversityCategory` | text | Diversity grouping | Diverse, Non-Diverse | Definition not stated |

## Job and organisation

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `Department` | text | Department | Finance, HR, IT, Marketing, Sales | About 10,000 each |
| `JobTitle` | text | Job title | 639 distinct titles | Every title appears in every department, so it is not tied to `Department` |
| `SupervisorLevel` | text | Level of the employee's supervisor | Manager, Director, VP | About 16,500–16,900 each |
| `SeniorLeader` | text | Senior leader the employee reports up to | Patrick, Thomas G, Arun S | Three names only |
| `TeamSize` | integer | Size of the employee's team | 5 – 50 | |
| `HireSource` | text | How the employee was hired | Recruiter, Referral, Job Board, Walk-in | |
| `DateOfHire` | date | Date hired | 2015-01-31 – 2025-01-30 | |
| `InternalPromotion` | text | Whether the role came from an internal promotion | Yes, No | |

## Employment status

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `EmploymentStatus` | text | Current status | Active (16,669), On Leave (16,703), Terminated (16,628) | "Attrition" = Terminated |
| `TerminationDate` | date | Date employment ended | 2015-04-08 – 2025-01-30 | Blank for 33,372 non-terminated employees (expected) |
| `ReasonForLeaving` | text | Reason for leaving | Layoff, Retirement, Resignation | Blank for all 33,372 non-terminated employees **and** 4,263 terminated ones (data gap) |
| `YearsAtCompany` | integer | Years at the company | 0 – 10 | **Unreliable:** does not match hire/termination dates |
| `YearsInCurrentRole` | integer | Years in current role | 0 – 10 | |

## Pay and promotion

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `Salary` | decimal | Annual salary | 30,000 – 119,995 (mean 75,090) | Currency not stated; USD assumed |
| `Bonus` | decimal | Bonus amount | 0.25 – 19,999.91 (mean 10,029) | |
| `PromotionCount` | integer | Number of promotions | 0 – 5 | |
| `LastPromotionDate` | date | Date of last promotion | — | Blank for 24,927 rows. 20,805 rows have `PromotionCount` > 0 but no date |

## Performance and development

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `PerformanceRating` | integer | Performance rating | 1 – 5 | |
| `ProjectsAssigned` | integer | Projects assigned | 0 – 20 | |
| `ProjectsCompleted` | integer | Projects completed | 0 – 20 | Exceeds `ProjectsAssigned` in 23,789 rows |
| `SkillsAssessmentScore` | decimal | Skills assessment score | 50 – 100 | |
| `TrainingHours` | integer | Training hours | 0 – 100 | Period not stated |
| `YearsSinceLastTraining` | integer | Years since last training | 0 – 5 | |
| `PerformanceImprovementPlan` | text | On a performance improvement plan | Yes, No | |

## Wellbeing and engagement

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `EmployeeEngagementScore` | decimal | Engagement score | 1.0 – 5.0 | |
| `JobSatisfactionScore` | decimal | Job satisfaction score | 1.0 – 5.0 | |
| `StressLevelScore` | decimal | Stress level | 1.0 – 10.0 | Different scale from the two above |
| `RetentionRisk` | text | Risk the employee will leave | Low, Medium, High | Does not predict actual attrition (see Business Insights) |
| `Absences` | integer | Days absent | 0 – 20 | Period not stated |
| `OvertimeHours` | integer | Overtime hours | 0 – 50 | Period not stated |
| `WorkHoursPerWeek` | integer | Weekly working hours | 30 – 60 | |
| `WorkFromHomeDays` | integer | Work-from-home days | 0 – 20 | Period not stated |

## Recruitment

| Column | Type | Description | Values / range | Notes |
|---|---|---|---|---|
| `RecruitmentCost` | decimal | Cost to recruit the employee | 1,000.53 – 9,999.95 (mean 5,477) | Currency not stated |
| `TimeToFillPosition` | integer | Days taken to fill the position | 5 – 60 | |

## Columns added during cleaning

| Column | Type | Description | Notes |
|---|---|---|---|
| `AgeAtHireYears` | decimal | (`DateOfHire` − `DateOfBirth`) in years | Range 8.1 – 65.9 |
| `AgeAtHireFlag` | flag | 1 if age at hire is under 16 | 3,373 rows flagged. Exclude from age analysis |
| `ProjectsIssueFlag` | flag | 1 if `ProjectsCompleted` > `ProjectsAssigned` | 23,789 rows flagged |

## Columns in the raw file but dropped from the cleaned file

| Column | Reason |
|---|---|
| `SupervisorID` | Each of the 1,000 IDs is linked to many different names, so it is not a real key |
| `SupervisorName` | Same reason |

## Known quality issues by column

| Column | Issue |
|---|---|
| `DateOfBirth` / `DateOfHire` | Impossible age at hire in 3,373 rows |
| `ProjectsCompleted` | Higher than `ProjectsAssigned` in 47.6% of rows |
| `PromotionCount` / `LastPromotionDate` | Disagree in 20,805 rows |
| `YearsAtCompany` | Disagrees with dates in about 66% of rows |
| `ReasonForLeaving` | Missing for 26% of leavers; "Retirement" exits have a median age of about 39 |

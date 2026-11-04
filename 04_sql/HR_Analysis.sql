-- ============================================================
-- HR Analytics — MySQL Business Analysis
-- Source: 03_python/HR_cleaned_data.csv (already cleaned & flagged)
-- Requires MySQL 8.0+ (CTEs, window functions).
-- ============================================================

-- ============================================================
-- 01. Database / Table Setup
-- ============================================================
-- DROP DATABASE hr_analytics; 
CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    EmployeeID              INT PRIMARY KEY,
    DateOfHire              DATE,
    DateOfBirth             DATE,
    Gender                  VARCHAR(20),
    Department              VARCHAR(30),
    JobTitle                VARCHAR(100),
    EmploymentStatus        VARCHAR(20),
    SupervisorLevel         VARCHAR(20),
    ProjectsAssigned        INT,
    ProjectsCompleted       INT,
    PerformanceRating       INT,
    Salary                  DECIMAL(10,2),
    Bonus                   DECIMAL(10,2),
    YearsAtCompany          INT,
    YearsInCurrentRole      INT,
    TrainingHours           INT,
    OvertimeHours           INT,
    Absences                INT,
    HireSource              VARCHAR(30),
    EmployeeEngagementScore DECIMAL(4,2),
    TerminationDate         DATE NULL,
    ReasonForLeaving        VARCHAR(30) NULL,
    LastPromotionDate       DATE NULL,
    SeniorLeader            VARCHAR(50),
    TeamSize                INT,
    PromotionCount          INT,
    WorkFromHomeDays        INT,
    PerformanceImprovementPlan VARCHAR(5),
    YearsSinceLastTraining  INT,
    JobSatisfactionScore    DECIMAL(4,2),
    RetentionRisk           VARCHAR(10),
    DiversityCategory       VARCHAR(20),
    SkillsAssessmentScore   DECIMAL(5,2),
    RecruitmentCost         DECIMAL(10,2),
    TimeToFillPosition      INT,
    InternalPromotion       VARCHAR(5),
    WorkHoursPerWeek        INT,
    StressLevelScore        DECIMAL(4,2),
    AgeAtHireYears          DECIMAL(5,1),
    AgeAtHireFlag           TINYINT(1),   -- 1 = impossible age at hire (<16), flagged in Python step
    ProjectsIssueFlag       TINYINT(1)    -- 1 = ProjectsCompleted > ProjectsAssigned, flagged in Python step
);


-- Load the cleaned CSV.
-- Before running:
--   1. Replace the path below with the full path to HR_cleaned_data.csv (use forward slashes on Windows).
--   2. Enable local_infile:  SET GLOBAL local_infile = 1;
--      (and connect with local_infile enabled; in MySQL Workbench, add OPT_LOCAL_INFILE=1 under Connection > Advanced).
--   3. If the file was saved with Windows line endings, change '\n' to '\r\n'.
--
-- Why the SET clause is needed:
--   * Blank dates in the CSV would otherwise be loaded as '0000-00-00' or raise an error. NULLIF turns them into NULL.
--   * The two flag columns are stored in the CSV as the text 'True' / 'False'. Loaded straight into TINYINT they
--     would silently become 0, and the validation query below would show no flagged rows.
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'D:/1. Revision Topics/5. Projects/08_HR-Analytics/04_sql/HR_cleaned_data.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    EmployeeID,
    DateOfHire,
    DateOfBirth,
    Gender,
    Department,
    JobTitle,
    EmploymentStatus,
    SupervisorLevel,
    ProjectsAssigned,
    ProjectsCompleted,
    PerformanceRating,
    Salary,
    Bonus,
    YearsAtCompany,
    YearsInCurrentRole,
    TrainingHours,
    OvertimeHours,
    Absences,
    HireSource,
    EmployeeEngagementScore,
    @TerminationDate,
    @ReasonForLeaving,
    @LastPromotionDate,
    SeniorLeader,
    TeamSize,
    PromotionCount,
    WorkFromHomeDays,
    PerformanceImprovementPlan,
    YearsSinceLastTraining,
    JobSatisfactionScore,
    RetentionRisk,
    DiversityCategory,
    SkillsAssessmentScore,
    RecruitmentCost,
    TimeToFillPosition,
    InternalPromotion,
    WorkHoursPerWeek,
    StressLevelScore,
    AgeAtHireYears,
    @AgeAtHireFlag,
    @ProjectsIssueFlag
)
SET
    TerminationDate   = NULLIF(@TerminationDate, ''),
    ReasonForLeaving  = NULLIF(@ReasonForLeaving, ''),
    LastPromotionDate = NULLIF(@LastPromotionDate, ''),
    AgeAtHireFlag     = (@AgeAtHireFlag = 'True'),
    ProjectsIssueFlag = (@ProjectsIssueFlag = 'True');


-- ============================================================
-- 02. Data Validation
-- ============================================================

-- Row count check — should be 50,000
SELECT COUNT(*) AS total_rows FROM employees;

-- Confirm EmployeeID is unique (should return 0 rows)
SELECT EmployeeID, COUNT(*) AS cnt
FROM employees
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

-- Confirm the two data-quality flags carried over correctly from Python
-- Expected: invalid_age_rows = 3373, projects_issue_rows = 23789
SELECT
    SUM(AgeAtHireFlag)     AS invalid_age_rows,
    SUM(ProjectsIssueFlag) AS projects_issue_rows
FROM employees;


-- ============================================================
-- 03. Basic KPIs
-- ============================================================

-- Total employees by status
SELECT EmploymentStatus, COUNT(*) AS employee_count
FROM employees
GROUP BY EmploymentStatus;

-- Overall attrition rate (expected 33.26)
SELECT
    ROUND(100.0 * SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;

-- Average salary and average tenure across the whole company
SELECT
    ROUND(AVG(Salary), 2)         AS avg_salary,
    ROUND(AVG(YearsAtCompany), 2) AS avg_tenure_years
FROM employees;


-- ============================================================
-- 04. Department Analysis
-- ============================================================

-- Employees and attrition rate by department
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) AS terminated,
    ROUND(100.0 * SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- Recruitment cost and time-to-fill by department
SELECT
    Department,
    ROUND(AVG(RecruitmentCost), 2)     AS avg_recruitment_cost,
    ROUND(AVG(TimeToFillPosition), 2)  AS avg_days_to_fill
FROM employees
GROUP BY Department
ORDER BY avg_recruitment_cost DESC;


-- ============================================================
-- 05. Job Role Analysis
-- ============================================================

-- Top 10 most common job titles
-- Note: JobTitle has 639 distinct values and is not tied to Department in this
-- dataset, so this is a simple frequency check rather than a deep breakdown.
SELECT JobTitle, COUNT(*) AS employee_count
FROM employees
GROUP BY JobTitle
ORDER BY employee_count DESC
LIMIT 10;


-- ============================================================
-- 06. Salary Analysis
-- ============================================================

-- Average salary by department
SELECT
    Department,
    ROUND(AVG(Salary), 2) AS avg_salary,
    ROUND(AVG(Bonus), 2)  AS avg_bonus
FROM employees
GROUP BY Department
ORDER BY avg_salary DESC;

-- Average salary by gender
SELECT
    Gender,
    ROUND(AVG(Salary), 2) AS avg_salary
FROM employees
GROUP BY Gender
ORDER BY avg_salary DESC;

-- Average salary by performance rating
SELECT
    PerformanceRating,
    ROUND(AVG(Salary), 2) AS avg_salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY PerformanceRating
ORDER BY PerformanceRating;


-- ============================================================
-- 07. Attrition Analysis
-- ============================================================

-- Reason for leaving, among terminated employees who have a reason recorded
SELECT
    ReasonForLeaving,
    COUNT(*) AS employee_count
FROM employees
WHERE EmploymentStatus = 'Terminated' AND ReasonForLeaving IS NOT NULL
GROUP BY ReasonForLeaving
ORDER BY employee_count DESC;

-- How many terminated employees have NO reason recorded (data quality gap)
SELECT COUNT(*) AS terminated_no_reason
FROM employees
WHERE EmploymentStatus = 'Terminated' AND ReasonForLeaving IS NULL;

-- Average tenure and performance by hire source (does source relate to attrition risk factors?)
SELECT
    HireSource,
    ROUND(AVG(YearsAtCompany), 2)    AS avg_tenure,
    ROUND(AVG(PerformanceRating), 2) AS avg_performance
FROM employees
GROUP BY HireSource
ORDER BY avg_tenure DESC;


-- ============================================================
-- 08. Other Business Questions
-- ============================================================

-- Engagement and satisfaction by RetentionRisk label
SELECT
    RetentionRisk,
    ROUND(AVG(EmployeeEngagementScore), 2) AS avg_engagement,
    ROUND(AVG(JobSatisfactionScore), 2)    AS avg_satisfaction
FROM employees
GROUP BY RetentionRisk;

-- Promotions vs tenure (does staying longer mean more promotions?)
SELECT
    YearsAtCompany,
    ROUND(AVG(PromotionCount), 2) AS avg_promotions
FROM employees
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany;


-- ============================================================
-- 09. CTE Analysis
-- ============================================================

-- Yearly exit rate = exits in the year / headcount at the start of the year.
-- The 33.26% figure above is cumulative over ten years; this is the yearly view.
-- (2025 is left out: the data ends on 30 January 2025.)
WITH years AS (
    SELECT 2016 AS yr UNION ALL SELECT 2017 UNION ALL SELECT 2018 UNION ALL
    SELECT 2019 UNION ALL SELECT 2020 UNION ALL SELECT 2021 UNION ALL
    SELECT 2022 UNION ALL SELECT 2023 UNION ALL SELECT 2024
)
SELECT
    y.yr AS exit_year,
    SUM(CASE WHEN e.DateOfHire < MAKEDATE(y.yr, 1)
              AND (e.TerminationDate IS NULL OR e.TerminationDate >= MAKEDATE(y.yr, 1))
             THEN 1 ELSE 0 END) AS opening_headcount,
    SUM(CASE WHEN YEAR(e.TerminationDate) = y.yr THEN 1 ELSE 0 END) AS exits,
    ROUND(100.0 * SUM(CASE WHEN YEAR(e.TerminationDate) = y.yr THEN 1 ELSE 0 END)
          / SUM(CASE WHEN e.DateOfHire < MAKEDATE(y.yr, 1)
                      AND (e.TerminationDate IS NULL OR e.TerminationDate >= MAKEDATE(y.yr, 1))
                     THEN 1 ELSE 0 END), 1) AS exit_rate_pct
FROM years y
CROSS JOIN employees e
GROUP BY y.yr
ORDER BY y.yr;

-- Do the conclusions hold on clean rows only?
-- Compare attrition for rows with no data-quality flag against flagged rows.
WITH row_quality AS (
    SELECT
        CASE WHEN AgeAtHireFlag = 0 AND ProjectsIssueFlag = 0 THEN 'No flags'
             ELSE 'Has a flag' END AS quality_group,
        CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END AS left_flag
    FROM employees
)
SELECT
    quality_group,
    COUNT(*)                          AS employees,
    ROUND(100.0 * AVG(left_flag), 2)  AS attrition_rate_pct
FROM row_quality
GROUP BY quality_group;

-- Reason for leaving by department, as a share of that department's leavers
WITH leavers AS (
    SELECT Department, COALESCE(ReasonForLeaving, 'Not recorded') AS reason
    FROM employees
    WHERE EmploymentStatus = 'Terminated'
),
reason_counts AS (
    SELECT Department, reason, COUNT(*) AS leavers
    FROM leavers
    GROUP BY Department, reason
)
SELECT
    Department,
    reason,
    leavers,
    ROUND(100.0 * leavers / SUM(leavers) OVER (PARTITION BY Department), 1) AS pct_of_dept_leavers
FROM reason_counts
ORDER BY Department, leavers DESC;


-- ============================================================
-- 10. Window Function Analysis
-- ============================================================

-- Departments ranked by attrition, with the gap to the company average
WITH dept AS (
    SELECT
        Department,
        100.0 * AVG(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) AS attrition_pct
    FROM employees
    GROUP BY Department
)
SELECT
    Department,
    ROUND(attrition_pct, 2)                                  AS attrition_pct,
    RANK() OVER (ORDER BY attrition_pct DESC)                AS attrition_rank,
    ROUND(attrition_pct - AVG(attrition_pct) OVER (), 2)     AS gap_to_dept_average_pp
FROM dept
ORDER BY attrition_rank;

-- Exits per year, year-over-year change and running total
WITH yearly AS (
    SELECT YEAR(TerminationDate) AS exit_year, COUNT(*) AS exits
    FROM employees
    WHERE EmploymentStatus = 'Terminated'
    GROUP BY YEAR(TerminationDate)
)
SELECT
    exit_year,
    exits,
    exits - LAG(exits) OVER (ORDER BY exit_year)                       AS change_vs_prev_year,
    ROUND(100.0 * (exits - LAG(exits) OVER (ORDER BY exit_year))
          / LAG(exits) OVER (ORDER BY exit_year), 1)                   AS change_pct,
    SUM(exits) OVER (ORDER BY exit_year)                               AS cumulative_exits
FROM yearly
ORDER BY exit_year;

-- Does pay level relate to attrition? Split employees into salary quartiles with NTILE.
WITH salary_bands AS (
    SELECT
        NTILE(4) OVER (ORDER BY Salary) AS salary_quartile,
        Salary,
        CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END AS left_flag
    FROM employees
)
SELECT
    salary_quartile,
    ROUND(MIN(Salary), 0)            AS min_salary,
    ROUND(MAX(Salary), 0)            AS max_salary,
    COUNT(*)                         AS employees,
    ROUND(100.0 * AVG(left_flag), 2) AS attrition_rate_pct
FROM salary_bands
GROUP BY salary_quartile
ORDER BY salary_quartile;

-- Three most common job titles in each department
WITH title_counts AS (
    SELECT Department, JobTitle, COUNT(*) AS employee_count
    FROM employees
    GROUP BY Department, JobTitle
),
ranked AS (
    SELECT
        Department, JobTitle, employee_count,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY employee_count DESC, JobTitle) AS rn
    FROM title_counts
)
SELECT Department, JobTitle, employee_count
FROM ranked
WHERE rn <= 3
ORDER BY Department, rn;

-- Tenure at exit, rebuilt from dates (YearsAtCompany is unreliable: it does not match the dates)
SELECT
    CASE
        WHEN DATEDIFF(TerminationDate, DateOfHire) < 183  THEN '1. Under 6 months'
        WHEN DATEDIFF(TerminationDate, DateOfHire) < 365  THEN '2. 6-12 months'
        WHEN DATEDIFF(TerminationDate, DateOfHire) < 1095 THEN '3. 1-3 years'
        ELSE '4. Over 3 years'
    END AS tenure_at_exit,
    COUNT(*) AS leavers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_leavers
FROM employees
WHERE EmploymentStatus = 'Terminated'
GROUP BY tenure_at_exit
ORDER BY tenure_at_exit;


-- ============================================================
-- 11. Views (reusable queries for reporting or Power BI)
-- ============================================================

-- Employees with no data-quality flags, for analysis that must avoid suspect rows
DROP VIEW IF EXISTS v_employees_clean;
CREATE VIEW v_employees_clean AS
SELECT *
FROM employees
WHERE AgeAtHireFlag = 0 AND ProjectsIssueFlag = 0;

-- One-row company KPI summary
DROP VIEW IF EXISTS v_kpi_summary;
CREATE VIEW v_kpi_summary AS
SELECT
    COUNT(*)                                                             AS total_employees,
    SUM(CASE WHEN EmploymentStatus = 'Active'     THEN 1 ELSE 0 END)     AS active_employees,
    SUM(CASE WHEN EmploymentStatus = 'On Leave'   THEN 1 ELSE 0 END)     AS on_leave_employees,
    SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END)     AS terminated_employees,
    ROUND(100.0 * SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(Salary), 2)                                                AS avg_salary,
    ROUND(AVG(YearsAtCompany), 2)                                        AS avg_tenure_years,
    SUM(AgeAtHireFlag)                                                   AS invalid_age_rows,
    SUM(ProjectsIssueFlag)                                               AS projects_issue_rows
FROM employees;

-- Attrition by department
DROP VIEW IF EXISTS v_attrition_by_department;
CREATE VIEW v_attrition_by_department AS
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) AS terminated,
    ROUND(100.0 * SUM(CASE WHEN EmploymentStatus = 'Terminated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department;

-- Exits per year
DROP VIEW IF EXISTS v_exits_by_year;
CREATE VIEW v_exits_by_year AS
SELECT
    YEAR(TerminationDate) AS exit_year,
    COUNT(*)              AS exits
FROM employees
WHERE EmploymentStatus = 'Terminated'
GROUP BY YEAR(TerminationDate);

-- Using the views
SELECT * FROM v_kpi_summary;
SELECT * FROM v_attrition_by_department ORDER BY attrition_rate_pct DESC;
SELECT * FROM v_exits_by_year ORDER BY exit_year;


-- ============================================================
-- 12. Final Findings
-- ============================================================

-- This section is a summary, not a query. See 06_project_documentation/
-- 02_Business_Insights.md for the full Finding / Evidence / Business Meaning /
-- Possible Action write-up.
--
-- Short version:
--   * Attrition is 33.26%, but that is cumulative over ten years. As a yearly
--     rate on opening headcount, exits rise from about 5% (2016) to about 15% (2024).
--   * Attrition, salary, performance and engagement come out close to equal across
--     department, gender, hire source and retention-risk label. Salary quartile
--     does not relate to attrition either.
--   * Reasons for leaving are split about evenly (about 25% each) and are missing
--     for about 26% of leavers.
--   * Nothing in this dataset shows a strong, actionable driver of attrition,
--     consistent with it being a synthetic/practice dataset rather than real
--     company data.

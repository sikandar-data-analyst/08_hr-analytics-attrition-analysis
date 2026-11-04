# Business Insights

Each finding follows the same format: **Finding → Evidence → Business meaning → Possible action.** Numbers come from `03_python/HR_Analysis.ipynb` and `04_sql/HR_Analysis.sql`, and match the Power BI dashboards.

**Read this first:** the dataset looks randomly generated. Almost every group comparison is flat, so the findings below are mostly "no difference" results. That is an honest result, not a gap in the analysis, and the "Possible action" lines describe what would be sensible *if this were real HR data*.

---

## 1. One in three employees has left, but that is a ten-year total

- **Finding:** Attrition is 33.26%, but this is the share of everyone ever hired, not a yearly rate.
- **Evidence:** 16,628 terminated, 16,669 active, 16,703 on leave, out of 50,000. Hiring is steady at about 5,000 a year, while the yearly exit rate (exits ÷ opening headcount) rises from 5.7% in 2016 to 14.6% in 2024.
- **Business meaning:** The 33% can't be compared with the 10–15% yearly attrition that HR teams usually quote. The rising yearly rate is the only pattern in the data that isn't flat, but it may come from how the termination dates were generated.
- **Possible action:** Report attrition as a yearly rate on opening headcount. Ask the data owner whether the 2022–2024 rise is real.

## 2. Attrition is the same in every group

- **Finding:** No department, gender or hire source stands out.
- **Evidence:** Departments range from 32.81% (Marketing) to 33.97% (IT). Genders range from 33.20% to 33.31%. The sample would have detected a department gap of about 1.9 percentage points, and the real spread is 1.2.
- **Business meaning:** There is no high-attrition team to focus on.
- **Possible action:** Don't target retention spending by department, gender or hire source.

## 3. Nothing in the data explains who leaves

- **Finding:** None of 30 factors is linked to leaving, and a model can't predict it.
- **Evidence:** 0 of 30 tests significant at 0.05 (closest: engagement score, p = 0.063), so 0 after Bonferroni correction. Logistic regression AUC 0.496 and random forest AUC 0.499 (0.50 = guessing).
- **Business meaning:** Salary, overtime, work-from-home days, stress, training, performance and tenure all look the same for leavers and stayers.
- **Possible action:** Collect data that could explain exits (exit interviews, manager changes, market pay) before building a predictive model.

## 4. The Retention Risk label does not predict leaving

- **Finding:** "High risk" employees are no more likely to leave, and are not less engaged.
- **Evidence:** Attrition is 32.76% (Low), 33.69% (Medium), 33.32% (High); chi-square p = 0.196. Engagement is 2.99 / 3.01 / 3.01 and job satisfaction 3.00 / 2.99 / 2.99.
- **Business meaning:** If HR used this label to decide who gets retention attention, it would be picking people at random.
- **Possible action:** Validate the label against real exits before using it, or rebuild it from factors that do relate to leaving.

## 5. Pay does not follow performance, gender or department

- **Finding:** Salary is flat across groups and unrelated to performance.
- **Evidence:** Performance rating vs salary correlation −0.005. Average salary by gender: Male $75,192, Female $75,146, Non-Binary $74,931 (under 0.4% spread). Departments differ by about 1.7% (Finance highest, HR lowest).
- **Business meaning:** There is no visible gender pay gap, but also no reward for performance, which would normally be a concern.
- **Possible action:** Review whether pay bands are linked to performance ratings.

## 6. Hire source, promotions and stress show no relationships

- **Finding:** Hire source doesn't affect tenure or performance, promotions don't grow with tenure, and stress doesn't relate to absences or satisfaction.
- **Evidence:** Average tenure is about 5.0 years for all four hire sources. Promotions vs tenure correlation −0.0065. Stress vs absences 0.004, stress vs satisfaction 0.002. Recruitment cost (about $5,450–$5,490) and time to fill (about 32.4–32.6 days) are the same in every department.
- **Business meaning:** No hiring channel is better value, and tenure is not rewarded with promotion.
- **Possible action:** Don't change hiring channels based on this data. Review the promotion process.

## 7. Reasons for leaving are evenly split and often missing

- **Finding:** Leavers split almost equally across layoff, retirement and resignation, and a quarter have no reason.
- **Evidence:** Of 16,628 leavers: Layoff 4,177 (25.1%), Retirement 4,144 (24.9%), Resignation 4,044 (24.3%), not recorded 4,263 (25.6%). The mix is about the same in every department.
- **Business meaning:** Only resignations are the kind HR can influence, and they are about a quarter of exits.
- **Possible action:** Make `ReasonForLeaving` mandatory at exit.

## 8. Many leavers go within the first year

- **Finding:** Using dates, a typical leaver left after about 1.9 years, and one in five left within six months.
- **Evidence:** Median tenure at exit 1.87 years. 20.2% left within 6 months and 33.1% within 1 year of hire.
- **Business meaning:** If real, early exits point to onboarding or hiring-fit problems. Recruitment cost (average about $5,477 per hire) is lost on each.
- **Possible action:** Review onboarding for the first six months. Treat this carefully, since it depends on dates that are part of the data-quality problem in section 9.

## 9. Data quality problems

Six issues were found. All are flagged and kept in the data; none were guessed away.

| Issue | Size | Handling |
|---|---|---|
| Age at hire under 16 (youngest 8.1) | 3,373 rows | `AgeAtHireFlag`; excluded from age analysis |
| `ProjectsCompleted` > `ProjectsAssigned` | 23,789 rows (47.6%) | `ProjectsIssueFlag` |
| Promotion count with no promotion date | 20,805 rows | Noted as a limitation |
| `SupervisorID` maps to many names | 1,000 of 1,000 IDs | Columns dropped from the cleaned file |
| `YearsAtCompany` disagrees with dates | about 66% of rows off by over 2 years | Reported; not overwritten |
| "Retirement" exits at a median age of about 39 | 4,144 rows (82% under 55) | Reported |

- **Business meaning:** The tenure and age fields can't be trusted for analysis, and the dashboard's "Average Age at Hire" (37.0) and tenure (5.0) include rows with these problems.
- **Possible action:** Fix the HR system's date and tenure entry, and add validation (minimum hiring age, completed ≤ assigned).

---

## Limitations

- The data looks synthetic, so "no difference" results describe this file, not real workforces.
- Flagged rows remain in the headline numbers on the dashboards.
- Attrition status has three values; "On Leave" is treated as staying.
- Column meanings are inferred from their names.

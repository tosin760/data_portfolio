# Lendwise Finance — Consumer Lending Portfolio & Credit Risk Analytics

## Project Overview

**Lendwise Finance** is an end-to-end consumer lending analytics project designed to simulate the work of a **Portfolio Analyst / Credit Risk Analyst** at a Nigerian fintech or consumer lending company.

The project uses a **synthetic lending portfolio** to investigate portfolio health, borrower risk, delinquency, loan performance, vintage behavior, and collections.

The objective is to demonstrate how I can take a lending business problem, structure a relational dataset, apply credit-risk concepts, analyze portfolio performance, identify risk patterns, validate results, and communicate findings to business stakeholders.

> **Important:** The dataset is synthetic and the findings are intended for portfolio-analytics practice rather than real-world lending decisions.

---

## Business Problem

Lendwise Finance has issued personal loans to customers and wants to understand:

- How healthy is the current loan portfolio?
- How much exposure is outstanding?
- How much of the portfolio is 30+ days past due?
- What proportion of loans have defaulted?
- Which borrower characteristics are associated with higher observed default rates?
- How do loan tenor and interest rate relate to observed performance?
- Which loan vintages show stronger or weaker performance?
- How quickly do defaults occur after loan origination?
- How effective are collections activities?
- How often do delinquent loans return to current status?

The analysis is structured around practical credit-risk concepts such as:

**DPD, PAR30, default rate, DTI, vintage analysis, MOB, cure rate, collections, and portfolio exposure.**

---

# 1. Data Model

I designed a relational lending database with six core tables.

```text
customers
    │
    ├──────────────┐
    │              │
    ▼              ▼
applications   credit_bureau
    │
    ▼
loans
    ├──────────────┐
    ▼              ▼
repayments     collections
```

### Tables

| Table | Grain | Purpose |
|---|---|---|
| `customers` | One row per customer | Customer demographics, income and employment information |
| `applications` | One row per application | Loan application, credit score, risk grade and approval information |
| `credit_bureau` | One row per bureau check | Historical credit obligations and repayment history |
| `loans` | One row per loan | Loan amount, tenor, interest rate, payment and status |
| `repayments` | One row per installment | Due dates, payments, DPD and repayment status |
| `collections` | One row per collection activity | Collection channel, DPD at contact and amount collected |

A key design principle was maintaining the correct **data grain** to avoid double-counting.

For example, one loan can have multiple repayment records. Joining the tables incorrectly could cause the same loan amount to be counted multiple times.

---

# 2. Portfolio Snapshot

The synthetic portfolio contains:

| Metric | Result |
|---|---:|
| Customers | 2,000 |
| Applications | 3,200 |
| Credit bureau records | 4,019 |
| Loans | 805 |
| Repayment records | 5,386 |
| Collection activities | 202 |

### Loan Status

| Loan Status | Loans | Share |
|---|---:|---:|
| Closed | 600 | 74.53% |
| Active | 173 | 21.49% |
| Defaulted | 32 | 3.98% |

The project defines a **default** as a loan reaching **90+ DPD**. This is a project-specific assumption and is not intended to represent a universal industry definition.

---

# 3. Portfolio Health

## Default Rate

The portfolio contains:

- **805 loans**
- **32 defaulted loans**
- **3.98% observed default rate**

---

## Outstanding Principal

I developed a repayment-based approach to estimate outstanding principal by loan.

The calculation uses:

```text
Outstanding Principal
=
Total Principal Due
-
Estimated Principal Paid
```

where estimated principal paid is derived from:

```text
Amount Paid - Interest Due
```

The resulting portfolio exposure used in the PAR analysis was:

**₦2,573,831.13**

### Methodology Note

Because this is a synthetic dataset, the repayment schedule does not contain every production-level treatment that a real lending system might require, such as payment allocation rules, fees, penalties, reversals, waivers, overpayments, and partial-payment allocation.

Therefore, the outstanding balance calculation is treated as a simplified analytical exposure measure rather than a production accounting balance.

---

# 4. PAR30 Analysis

I calculated **Portfolio at Risk 30 (PAR30)** as:

```text
PAR30 %
=
Outstanding principal on 30+ DPD loans
/
Total outstanding principal
× 100
```

Results:

| Metric | Result |
|---|---:|
| Total outstanding principal | ₦2,573,831.13 |
| PAR30 exposure | ₦1,173,048.82 |
| PAR30 | **45.58%** |

### Finding

Under the project's simplified exposure definition, **45.58% of outstanding principal exposure was associated with loans currently at 30+ DPD**.

This is a synthetic portfolio and should not be compared directly with real lender benchmarks.

---

# 5. Delinquency Analysis

## Repayment-Level DPD Distribution

Across the 5,386 repayment records:

| DPD Bucket | Records | Share |
|---|---:|---:|
| Current | 3,647 | 67.71% |
| 1–7 DPD | 1,399 | 25.97% |
| 8–30 DPD | 220 | 4.08% |
| 31–60 DPD | 52 | 0.97% |
| 61–90 DPD | 36 | 0.67% |
| 90+ DPD | 32 | 0.59% |

This is a **repayment-record analysis**, not a loan-level exposure analysis.

That distinction matters because one loan can contribute multiple repayment records.

---

# 6. Credit Score Risk Analysis

I grouped originated loans by application credit score and compared observed default rates.

| Credit Score Band | Loans | Defaults | Default Rate |
|---|---:|---:|---:|
| <550 | 84 | 6 | **7.14%** |
| 550–599 | 48 | 0 | 0.00% |
| 600–649 | 69 | 2 | 2.90% |
| 650–699 | 117 | 5 | 4.27% |
| 700+ | 487 | 19 | 3.90% |

### Finding

The **<550 credit-score band had the highest observed default rate at 7.14%**.

However, the relationship was not perfectly monotonic. The 550–599 group had 0% observed defaults but contained only 48 loans.

Therefore:

> Lower credit scores showed evidence of higher observed risk in this synthetic portfolio, but the relationship was not strictly monotonic and should not be interpreted as causal.

---

# 7. Debt-to-Income Ratio (DTI)

DTI was calculated conceptually as:

```text
DTI
=
(existing monthly debt obligations + new loan payment)
/
monthly income
× 100
```

An important data-quality issue was identified during this analysis.

The `credit_bureau` table contains multiple records per customer. A simple join would duplicate loans and potentially introduce **look-ahead bias**.

To avoid this, I selected the most recent bureau record available **on or before the loan application date**.

This resulted in:

- **506 loans** with valid historical bureau information
- **299 loans** without a bureau record available before application

The 299 loans were not assigned invented bureau values.

### DTI Distribution

| DTI Band | Loans |
|---|---:|
| <30% | 75 |
| 30–39% | 61 |
| 40–49% | 56 |
| 50–59% | 47 |
| 60–69% | 43 |
| 70–99% | 75 |
| 100%+ | 149 |

### DTI vs Default

| DTI Band | Loans | Defaults | Default Rate |
|---|---:|---:|---:|
| <30% | 75 | 1 | **1.33%** |
| 30–39% | 61 | 2 | 3.28% |
| 40–49% | 56 | 0 | 0.00% |
| 50–59% | 47 | 1 | 2.13% |
| 60–69% | 43 | 0 | 0.00% |
| 70–99% | 75 | 2 | 2.67% |
| 100%+ | 149 | 10 | **6.71%** |

### Finding

Loans with **100%+ DTI recorded a 6.71% observed default rate**, compared with **1.33% for loans below 30% DTI**.

That is roughly five times higher in this synthetic sample.

The intermediate bands were not monotonic, so DTI should be treated as one risk indicator rather than proof of causation.

---

# 8. Loan Tenor Analysis

| Tenor | Loans | Defaults | Default Rate |
|---|---:|---:|---:|
| 3 months | 134 | 6 | 4.48% |
| 6 months | 315 | 10 | 3.17% |
| 9 months | 148 | 10 | **6.76%** |
| 12 months | 208 | 6 | 2.88% |

### Finding

The **9-month tenor had the highest observed default rate at 6.76%**, while the 12-month group had the lowest at 2.88%.

The relationship was not consistently increasing with tenor, so tenor alone does not explain default outcomes.

---

# 9. Interest Rate Analysis

The portfolio's observed interest rates ranged from:

- **18.02% minimum**
- **33.23% average**
- **47.94% maximum**

### Default Rate by Interest Rate

| Interest Rate Band | Loans | Defaults | Default Rate |
|---|---:|---:|---:|
| <25% | 167 | 9 | **5.39%** |
| 25–29.99% | 133 | 3 | 2.26% |
| 30–34.99% | 146 | 3 | **2.05%** |
| 35–39.99% | 150 | 7 | 4.67% |
| 40%+ | 209 | 10 | 4.78% |

### Finding

Default rates varied across interest-rate bands rather than increasing consistently with pricing.

The <25% band recorded the highest observed default rate at 5.39%, while the 30–34.99% band recorded the lowest at 2.05%.

This demonstrates why interest rate should not be evaluated in isolation. In real lending portfolios, pricing may itself reflect borrower risk.

---

# 10. Previous Repayment History

Historical bureau records were matched using the latest bureau observation available before application.

## Previous Defaults

| Previous Default History | Loans | Current Defaults | Default Rate |
|---|---:|---:|---:|
| No previous defaults | 439 | 15 | 3.42% |
| 1 previous default | 65 | 1 | 1.54% |
| 2+ previous defaults | 2 | 0 | 0.00% |

## Previous Late Payments

| Previous Late Payments | Loans | Current Defaults | Default Rate |
|---|---:|---:|---:|
| 0 | 144 | 6 | 4.17% |
| 1–2 | 287 | 9 | 3.14% |
| 3–5 | 73 | 1 | 1.37% |
| 6+ | 2 | 0 | 0.00% |

### Finding

The synthetic data did not produce a clean monotonic relationship between historical late payments/defaults and current default.

The very small 2+ and 6+ groups also make their 0% rates unreliable.

This demonstrates why portfolio analysis should consider **sample size and data quality**, not only percentages.

---

# 11. Vintage Analysis

Vintage analysis groups loans by their origination period to identify differences in performance across cohorts.

## Year-Level Vintage Performance

| Vintage Year | Loans | Amount Disbursed | Defaults | Default Rate |
|---|---:|---:|---:|---:|
| 2024 | 332 | ₦131.65m | 18 | **5.42%** |
| 2025 | 346 | ₦143.45m | 14 | **4.05%** |
| 2026 | 127 | ₦51.90m | 0 | 0.00% |

### Finding

The 2024 vintage recorded the highest observed default rate at **5.42%**, compared with **4.05% for 2025**.

The 2026 vintage currently shows 0% observed defaults, but this should **not** be interpreted as superior performance because the cohort is younger and has had less time to experience default.

This highlights an important credit-risk concept:

> Vintage performance should be evaluated with loan age/maturity in mind.

---

# 12. Default Timing / MOB Analysis

I investigated **Months on Book (MOB)** to understand when defaults occurred after origination.

| Default MOB | Defaults |
|---|---:|
| 2 | 3 |
| 3 | 6 |
| 4 | 11 |
| 5 | 8 |
| 6 | 1 |
| 7 | 1 |
| 10 | 1 |
| 13 | 1 |

### Finding

**28 of the 32 observed defaults (87.5%) occurred by MOB 5.**

Additionally:

- 30 of 32 defaults occurred by MOB 7
- 31 of 32 occurred by MOB 10
- 32 of 32 occurred by MOB 13

This suggests that, within the synthetic portfolio, default risk was concentrated relatively early in the loan lifecycle.

The timing uses the first repayment record reaching 90+ DPD, so it is a simplified analytical definition rather than a production-grade default-date methodology.

---

# 13. Collections Analysis

The collections table contains:

- **202 collection activities**
- **174 loans with collection activity**
- **₦5,782,848.25 total amount collected**
- **₦28,627.96 average collected per activity**

## Collections by Channel

| Channel | Activities | Loans Contacted | Total Collected | Avg/Activity |
|---|---:|---:|---:|---:|
| WhatsApp | 51 | 49 | ₦1,829,461.46 | ₦35,871.79 |
| Email | 54 | 50 | ₦1,420,302.08 | ₦26,301.89 |
| SMS | 44 | 42 | ₦1,323,220.95 | ₦30,073.20 |
| Phone | 53 | 50 | ₦1,209,863.76 | ₦22,827.62 |

### Finding

WhatsApp recorded the highest total collections and the highest average amount collected per activity.

However, this does **not** prove that WhatsApp is a more effective collection channel.

Channel effectiveness would need to control for borrower risk, DPD severity, loan balance, collection strategy, customer characteristics, and contact frequency.

---

# 14. Cure Rate

For this project, a simplified cure was defined as:

> A loan that reached 30+ DPD and subsequently recorded a repayment with 0 DPD.

Results:

- 180 loans reached 30+ DPD
- 170 subsequently recorded 0 DPD
- **94.44% observed cure rate**

### Finding

Under the project's simplified definition, most delinquent loans subsequently returned to a current repayment record.

However, this should not be interpreted as a sustained cure rate because the methodology does not require the borrower to remain current for a defined period.

---

# 15. Methodology and Data-Quality Lessons

One of the most valuable parts of this project has been learning to distinguish a technically correct SQL query from a **business-correct analytical metric**.

### Avoiding one-to-many duplication

A loan can have multiple repayment records, so loan-level amounts cannot simply be summed after joining repayments.

### Avoiding look-ahead bias

Historical bureau information must be selected based on what was known **at or before application time**.

### Distinguishing metric grains

The project separates:

- repayment-record delinquency
- loan-level delinquency
- exposure-based PAR
- loan-count default rate

### Recognizing immature vintages

A 2026 vintage with 0% defaults cannot automatically be considered better than an older vintage.

### Rejecting misleading recovery calculations

A preliminary recovery calculation produced a value above 100% because cumulative collections were compared with a point-in-time delinquent exposure denominator.

Rather than presenting the result as a success metric, I treated it as a **methodology/data-model limitation** and excluded it from the final KPI set.

This reflects an important principle in portfolio analytics:

> **A metric is only useful when its numerator and denominator represent comparable concepts and time periods.**

---

# 16. Tools & Technologies

### Data & Analytics

- MySQL
- SQL
- Python
- Pandas
- Excel
- Tableau

### SQL Techniques

- Aggregations
- `CASE WHEN`
- CTEs
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- Window functions
- `ROW_NUMBER()`
- Date functions
- Cohort/vintage analysis
- Conditional aggregation

### Credit-Risk Concepts

- DPD
- DPD buckets
- PAR30
- Default rate
- DTI
- Credit-score segmentation
- Vintage analysis
- MOB
- Cure rate
- Collections
- Portfolio exposure

---

# 17. Project Workflow

```text
Business Problem
       ↓
Lending Data Model
       ↓
Synthetic Data Generation
       ↓
MySQL Database
       ↓
SQL Portfolio Analysis
       ↓
Credit Risk Metrics
       ↓
Risk Driver Analysis
       ↓
Vintage / MOB Analysis
       ↓
Collections Analysis
       ↓
Python + Pandas
       ↓
Excel Monitoring Report
       ↓
Tableau Risk Dashboard
       ↓
Executive Findings
```

---

# 18. Current Status

### Completed

- [x] Defined lending business problem
- [x] Designed relational lending data model
- [x] Generated synthetic lending dataset
- [x] Loaded data into MySQL
- [x] Created primary and foreign keys
- [x] Validated table relationships
- [x] Analyzed portfolio volume
- [x] Calculated outstanding exposure
- [x] Calculated PAR30
- [x] Calculated default rate
- [x] Built DPD analysis
- [x] Analyzed credit-score risk
- [x] Analyzed DTI
- [x] Analyzed loan tenor
- [x] Analyzed interest rate
- [x] Analyzed repayment history
- [x] Performed vintage analysis
- [x] Investigated default timing using MOB
- [x] Analyzed collections
- [x] Calculated simplified cure rate
- [x] Documented analytical limitations and data-quality issues

### Next Steps

- [ ] Build loan-level analytical dataset in Python/Pandas
- [ ] Feature engineering
- [ ] Portfolio visualizations
- [ ] Risk-driver charts
- [ ] Excel portfolio monitoring report
- [ ] Tableau credit-risk dashboard
- [ ] Executive summary
- [ ] Final GitHub documentation
- [ ] Resume/project presentation

---

# 19. Key Portfolio Findings

1. **Default rate:** 3.98% of loans were classified as defaulted under the project's 90+ DPD definition.

2. **PAR30:** 45.58% of the simplified outstanding principal exposure was associated with loans at 30+ DPD.

3. **Credit score:** The <550 score band had the highest observed default rate at 7.14%.

4. **DTI:** Loans with 100%+ DTI recorded a 6.71% default rate versus 1.33% for loans below 30% DTI.

5. **Tenor:** 9-month loans had the highest observed default rate at 6.76%.

6. **Interest rate:** Default rates varied across pricing bands without a simple monotonic relationship.

7. **Vintage:** The 2024 vintage had a 5.42% observed default rate versus 4.05% for 2025; the 2026 cohort is too immature for a fair comparison.

8. **Default timing:** 87.5% of observed defaults occurred by MOB 5.

9. **Collections:** WhatsApp recorded the highest total and average collections per activity, but the result is observational and not causal.

10. **Cure:** 94.44% of loans that reached 30+ DPD subsequently recorded a 0-DPD repayment under the project's simplified cure definition.

---

# 20. What This Project Demonstrates

This project demonstrates practical ability to:

- Translate a business problem into an analytical framework
- Design relational data structures for lending analytics
- Work with multi-table financial datasets
- Write SQL for portfolio and credit-risk analysis
- Calculate lending KPIs
- Identify and investigate risk drivers
- Perform cohort/vintage analysis
- Work with time-dependent financial data
- Detect data-quality and methodology issues
- Avoid double-counting and look-ahead bias
- Challenge misleading metrics instead of blindly reporting them
- Communicate findings in business language
- Build toward a repeatable portfolio-monitoring workflow

The emphasis is on **analytical reasoning, data quality, and business interpretation**, rather than simply producing charts.

---

## Author

**Tosin Rilwan Ogundele**

Project focus: **Portfolio Analytics | Credit Risk | Consumer Lending | SQL | Python | Data Analysis**

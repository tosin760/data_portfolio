-- DEFAULT RATE BY VINTAGE YEAR
SELECT
    YEAR(disbursement_date) AS vintage_year,

    COUNT(*) AS total_loans,

    SUM(loan_amount) AS total_disbursed,

    SUM(
        CASE
            WHEN loan_status = 'Defaulted' THEN 1
            ELSE 0
        END
    ) AS defaulted_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status = 'Defaulted' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS default_rate

FROM loans

GROUP BY YEAR(disbursement_date)

ORDER BY vintage_year;

-- CALCULATING MONTHS ON BOOK (MOB)
SELECT
    loan_id,
    disbursement_date,
    maturity_date,
    TIMESTAMPDIFF(
        MONTH,
        disbursement_date,
        maturity_date
    ) + 1 AS loan_life_months
FROM loans
ORDER BY loan_id
LIMIT 20;

-- DETERMINING WHEN EACH LOAN DEFAULTED
SELECT 
  loan_id,
  MIN(due_date) AS first_default_date  
FROM repayments
WHERE due_date >= 90
GROUP BY loan_id
ORDER BY first_default_date;

-- CALCULATING MOB AT DEFAULT

SELECT
    l.loan_id,
    l.disbursement_date,
    MIN(r.due_date) AS first_default_date,

    TIMESTAMPDIFF(
        MONTH,
        l.disbursement_date,
        MIN(r.due_date)
    ) + 1 AS default_mob

FROM loans l

JOIN repayments r
    ON l.loan_id = r.loan_id

WHERE r.days_past_due >= 90

GROUP BY
    l.loan_id,
    l.disbursement_date

ORDER BY default_mob;

SELECT
    loan_id,
    disbursement_date,
    TIMESTAMPDIFF(
        MONTH,
        disbursement_date,
        '2026-06-30'
    ) + 1 AS current_mob
FROM loans
ORDER BY current_mob
LIMIT 20;

WITH loan_defaults AS (
    SELECT
        l.loan_id,
        l.disbursement_date,
        MIN(r.due_date) AS first_default_date
    FROM loans l
    JOIN repayments r
        ON l.loan_id = r.loan_id
    WHERE r.days_past_due >= 90
    GROUP BY
        l.loan_id,
        l.disbursement_date
),

default_mob AS (
    SELECT
        loan_id,
        TIMESTAMPDIFF(
            MONTH,
            disbursement_date,
            first_default_date
        ) + 1 AS default_mob
    FROM loan_defaults
)

SELECT
    default_mob,
    COUNT(*) AS defaulted_loans
FROM default_mob
GROUP BY default_mob
ORDER BY default_mob;

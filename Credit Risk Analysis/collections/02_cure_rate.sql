WITH delinquent_loans AS (
    SELECT DISTINCT
        loan_id
    FROM repayments
    WHERE days_past_due >= 30
),

cured_loans AS (
    SELECT DISTINCT
        d.loan_id
	FROM delinquent_loans d
    JOIN repayments r
        ON d.loan_id = r.loan_id
    WHERE r.days_past_due = 0
)

SELECT
    COUNT(DISTINCT d.loan_id) AS delinquent_loans,
    COUNT(DISTINCT c.loan_id) AS cured_loans,
    ROUND(
        100.0 * COUNT(DISTINCT c.loan_id)
        / NULLIF(COUNT(DISTINCT d.loan_id), 0),
        2
    ) AS cure_rate
FROM delinquent_loans d
LEFT JOIN cured_loans c
    ON d.loan_id = c.loan_id;
    
SELECT loan_id, days_past_due
FROM repayments
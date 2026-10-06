WITH delinquent_loans AS (
    SELECT DISTINCT
        loan_id
    FROM repayments
    WHERE days_past_due >= 30
),

loan_exposure AS (
    SELECT
        loan_id,
        SUM(principal_due)
            - SUM(amount_paid - interest_due) AS outstanding_principal
    FROM repayments
    GROUP BY loan_id
)

SELECT
    ROUND(SUM(le.outstanding_principal), 2) AS delinquent_exposure
FROM delinquent_loans d
JOIN loan_exposure le
    ON d.loan_id = le.loan_id;
    

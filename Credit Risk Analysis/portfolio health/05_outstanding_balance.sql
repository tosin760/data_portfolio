-- OUTSTANDING BALANCE
WITH principal_activity AS (
    SELECT 
        loan_id,
        SUM(principal_due) AS total_principal,
        SUM(amount_paid - interest_due) AS principal_paid,
        SUM(principal_due)
            - SUM(amount_paid - interest_due) AS outstanding_principal
    FROM repayments
    GROUP BY loan_id
)

SELECT 
    l.loan_id,
    l.loan_amount,
    COALESCE(
        p.outstanding_principal, 
        0
    ) AS outstanding_principal
FROM loans l
LEFT JOIN principal_activity p
    ON p.loan_id = l.loan_id
ORDER BY l.loan_id;
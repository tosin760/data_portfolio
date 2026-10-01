-- WHAT % OF THE LOAN OUTSTANDING BALANCE IS ASSOCIATED WITH LOANS THAT ARE AT LEAST 30DPD

-- PART 1: CALCULATE EACH LOAN APPLICATION OUSTANDING BALANCE
WITH principal_activity AS (
SELECT 
 loan_id,
 SUM(principal_due) AS total_principal,
 SUM(amount_paid - interest_due) AS principal_paid,
  SUM(principal_due) - SUM(amount_paid - interest_due) AS outstanding_principal
FROM repayments
GROUP BY loan_id)
SELECT 
 l.loan_id,
 l.loan_amount,
 COALESCE(p.outstanding_principal, 0) AS outstanding_principal
FROM loans l
LEFT JOIN principal_activity p
ON p.loan_id = l.loan_id
ORDER BY l.loan_id;
-- PART 2: IDENTIFY LOANS 30+ DPD
WITH loan_balance AS (
    SELECT 
        loan_id,
        SUM(principal_due) 
            - SUM(amount_paid - interest_due) AS outstanding_principal
    FROM repayments
    GROUP BY loan_id
),

loan_dpd AS (
    SELECT
        loan_id,
        MAX(days_past_due) AS max_dpd
    FROM repayments
    WHERE payment_status = 'Overdue'
    GROUP BY loan_id
), 
portfolio AS (
SELECT
    l.loan_id,
    l.loan_amount,
    COALESCE(lb.outstanding_principal, 0) AS outstanding_principal,
    COALESCE(ld.max_dpd, 0) AS max_current_dpd,
    CASE
        WHEN COALESCE(ld.max_dpd, 0) >= 30 THEN '30+ DPD'
        ELSE 'Below 30 DPD'
     END AS dpd_bucket
FROM loans l
LEFT JOIN loan_balance lb
    ON l.loan_id = lb.loan_id
LEFT JOIN loan_dpd ld
    ON l.loan_id = ld.loan_id
)
SELECT 
	 ROUND(SUM(outstanding_principal ), 2) AS total_outstanding,
	 ROUND ( SUM(CASE 
		 WHEN max_current_dpd >= 30
		 THEN outstanding_principal 
		 ELSE 0
		 END) , 2) AS par30_exposure,
	 ROUND ( SUM(CASE 
		 WHEN max_current_dpd >= 30
		 THEN outstanding_principal 
		 ELSE 0
		 END) * 100/ NULLIF(SUM(outstanding_principal), 0), 2) AS par30_percentage
FROM portfolio 
WHERE outstanding_principal > 0;

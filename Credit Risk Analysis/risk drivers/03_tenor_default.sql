-- Do loans with different repayment periods have different observed default rates?
-- What percentage of loans in each tenor group reached my project-defined default state (90+ DPD)

SELECT 
tenor_months,
COUNT(*) AS total_loans,
SUM(
CASE 
   WHEN loan_status = 'Defaulted' THEN 1
   ELSE 0
   END
) AS defaulted_loans,
ROUND(100 *
SUM(
CASE 
   WHEN loan_status = 'Defaulted' THEN 1
   ELSE 0
   END
) / COUNT(*) , 2) AS deafult_rate
FROM loans
GROUP BY tenor_months
ORDER BY tenor_months
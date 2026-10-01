-- LOAN STATUS % DISTRIBUTION
SELECT
loan_status,
COUNT(*) AS loan_count,
ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS pct_of_loan
FROM loans
GROUP BY loan_status
ORDER BY pct_of_loan DESC;

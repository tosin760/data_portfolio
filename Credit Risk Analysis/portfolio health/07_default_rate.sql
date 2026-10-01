-- OVERALL DEFAULT RATE
SELECT
 COUNT(*) AS total_loans,
  SUM(
   CASE 
       WHEN loan_status = 'Defaulted' THEN 1
       ELSE 0
       END
  ) AS defaulted_loans,
  ROUND( SUM(
   CASE 
       WHEN loan_status = 'Defaulted' THEN 1
       ELSE 0
       END
  ) * 100 / COUNT(*) , 2) AS default_rate
FROM loans;

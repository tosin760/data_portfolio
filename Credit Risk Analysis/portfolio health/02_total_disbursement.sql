-- TOTAL AMOUNT DISBURSED
SELECT 
  ROUND(SUM(loan_amount) , 2) AS total_disbursed
FROM loans;
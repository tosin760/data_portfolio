-- DELIQUENCY BY DPD BUCKET     
SELECT
    CASE
        WHEN days_past_due = 0 THEN 'Current'
        WHEN days_past_due BETWEEN 1 AND 7 THEN '1-7 DPD'
        WHEN days_past_due BETWEEN 8 AND 30 THEN '8-30 DPD'
        WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD'
    END AS dpd_bucket,
    
    COUNT(*) AS repayment_count,
    ROUND(SUM(principal_due), 2) AS principal_due,
    ROUND(SUM(amount_paid - interest_due), 2) AS principal_paid

FROM repayments

GROUP BY
    CASE
        WHEN days_past_due = 0 THEN 'Current'
        WHEN days_past_due BETWEEN 1 AND 7 THEN '1-7 DPD'
        WHEN days_past_due BETWEEN 8 AND 30 THEN '8-30 DPD'
        WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD'
    END

ORDER BY
    MIN(days_past_due);

-- DPD BUCKETS PERCENTAGE RATE
SELECT
  CASE 
     WHEN days_past_due = 0 THEN 'Current'
     WHEN days_past_due BETWEEN 1 AND 7 THEN '1-7 DPD'
     WHEN days_past_due BETWEEN 8 AND 30 THEN '8-30 DPD'
     WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 DPD'
     WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 DPD'
     WHEN days_past_due > 90 THEN '90+ DPD'
  END AS dpd_bucket,
  COUNT(*) AS repayment_count,
  COUNT(*) * 100 / (SELECT COUNT(*) FROM repayments) AS pct_of_repayments
FROM repayments
GROUP BY 
   CASE 
     WHEN days_past_due = 0 THEN 'Current'
     WHEN days_past_due BETWEEN 1 AND 7 THEN '1-7 DPD'
     WHEN days_past_due BETWEEN 8 AND 30 THEN '8-30 DPD'
     WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 DPD'
     WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 DPD'
     WHEN days_past_due > 90 THEN '90+ DPD'
  END;
  

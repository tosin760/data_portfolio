-- DELIQUENCY AT LOAN LEVEL
WITH loan_dpd AS (
SELECT 
  loan_id,
  MAX(days_past_due) AS max_dpd
FROM repayments
GROUP BY loan_id)
SELECT
    CASE
        WHEN max_dpd = 0 THEN 'Current'
        WHEN max_dpd BETWEEN 1 AND 7 THEN '1-7 DPD'
        WHEN max_dpd BETWEEN 8 AND 30 THEN '8-30 DPD'
        WHEN max_dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN max_dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD'
    END AS dpd_bucket,

    COUNT(*) AS loan_count,

    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM loan_dpd),
        2
    ) AS percentage_of_loans

FROM loan_dpd

GROUP BY
    CASE
        WHEN max_dpd = 0 THEN 'Current'
        WHEN max_dpd BETWEEN 1 AND 7 THEN '1-7 DPD'
        WHEN max_dpd BETWEEN 8 AND 30 THEN '8-30 DPD'
        WHEN max_dpd BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN max_dpd BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD'
    END
ORDER BY MIN(max_dpd);

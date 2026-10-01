-- Do loans with different interest rates have different observed default rates?

-- DETERMINING THE INTEREST RATE BAND
    SELECT
    ROUND(MIN(interest_rate), 2) AS minimum_rate,
    ROUND(AVG(interest_rate), 2) AS average_rate,
    ROUND(MAX(interest_rate), 2) AS maximum_rate
FROM loans;

SELECT
    CASE 
        WHEN interest_rate < 25 THEN '<25%'
        WHEN interest_rate < 30 THEN '25-29.99%'
        WHEN interest_rate < 35 THEN '30-34.99%'
        WHEN interest_rate < 40 THEN '35-39.99%'
        ELSE '40%+'
    END AS interest_rate_band,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN loan_status = 'Defaulted' THEN 1
            ELSE 0
        END
    ) AS defaulted_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN loan_status = 'Defaulted' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS default_rate

FROM loans

GROUP BY
    CASE
        WHEN interest_rate < 25 THEN '<25%'
        WHEN interest_rate < 30 THEN '25-29.99%'
        WHEN interest_rate < 35 THEN '30-34.99%'
        WHEN interest_rate < 40 THEN '35-39.99%'
        ELSE '40%+'
    END

ORDER BY MIN(interest_rate);
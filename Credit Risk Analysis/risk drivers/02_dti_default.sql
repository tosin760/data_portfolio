-- LOANS WHOSE APPLICATION DATE CAME AFTER BUREAU DATE
SELECT
COUNT(*) AS loans_without_prior_bureau 
FROM loans l
JOIN applications a
    ON l.application_id = a.application_id
LEFT JOIN credit_bureau cb
    ON l.customer_id = cb.customer_id
    AND cb.bureau_date <= a.application_date
 WHERE cb.bureau_id IS NULL;

-- CONFIRMING TO CHECK THAT ALL LOANS HAVE A BUREAU RECORD
SELECT
    COUNT(*) AS loans_with_any_bureau_record,
    SUM(
        CASE
            WHEN cb.bureau_id IS NULL THEN 1
            ELSE 0
        END
    ) AS loans_with_no_bureau_record
FROM loans l
JOIN applications a
    ON l.application_id = a.application_id
LEFT JOIN credit_bureau cb
    ON l.customer_id = cb.customer_id;

-- how many days after the application was the earliest bureau record created?
SELECT
    l.loan_id,
    a.application_date,
    MIN(cb.bureau_date) AS earliest_bureau_date,
    DATEDIFF(
        MIN(cb.bureau_date),
        a.application_date
    ) AS days_after_application
FROM loans l
JOIN applications a
    ON l.application_id = a.application_id
JOIN credit_bureau cb
    ON l.customer_id = cb.customer_id
WHERE cb.bureau_date > a.application_date
GROUP BY
    l.loan_id,
    a.application_date
ORDER BY days_after_application;

-- RANGE OF GAPS IN THE 299 LOANS WHOSE BUREAU RECORDS OCCURED AFTER THE APPLICATION DATE
SELECT
    MIN(
        DATEDIFF(
            cb.bureau_date,
            a.application_date
        )
    ) AS minimum_days_after,
    
    AVG(
        DATEDIFF(
            cb.bureau_date,
            a.application_date
        )
    ) AS average_days_after,
    
    MAX(
        DATEDIFF(
            cb.bureau_date,
            a.application_date
        )
    ) AS maximum_days_after
FROM loans l
JOIN applications a
    ON l.application_id = a.application_id
JOIN credit_bureau cb
    ON l.customer_id = cb.customer_id
WHERE cb.bureau_date > a.application_date;

-- CALCULATING THE DEBT TO INCOME (DTI)
WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        l.customer_id,
        a.application_date,
        cb.bureau_id,
        cb.bureau_date,
        cb.monthly_debt_obligations,

        ROW_NUMBER() OVER (
            PARTITION BY l.loan_id
            ORDER BY cb.bureau_date DESC, cb.bureau_id DESC
        ) AS rn

    FROM loans l

    JOIN applications a
        ON l.application_id = a.application_id

    JOIN credit_bureau cb
        ON l.customer_id = cb.customer_id
        AND cb.bureau_date <= a.application_date
),

dti_base AS (
    SELECT
        l.loan_id,
        l.customer_id,
        c.monthly_income,
        b.monthly_debt_obligations,
        l.monthly_payment,

        ROUND(
            100.0 *
            (
                b.monthly_debt_obligations
                + l.monthly_payment
            )
            / NULLIF(c.monthly_income, 0),
            2
        ) AS dti,

        l.loan_status

    FROM loans l

    JOIN customers c
        ON l.customer_id = c.customer_id

    JOIN bureau_ranked b
        ON l.loan_id = b.loan_id
        AND b.rn = 1
)

SELECT *
FROM dti_base
ORDER BY dti DESC;

-- DTI RANGE
WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        l.customer_id,
        a.application_date,
        cb.bureau_id,
        cb.bureau_date,
        cb.monthly_debt_obligations,

        ROW_NUMBER() OVER (
            PARTITION BY l.loan_id
            ORDER BY cb.bureau_date DESC, cb.bureau_id DESC
        ) AS rn

    FROM loans l

    JOIN applications a
        ON l.application_id = a.application_id

    JOIN credit_bureau cb
        ON l.customer_id = cb.customer_id
        AND cb.bureau_date <= a.application_date
),

dti_base AS (
    SELECT
        l.loan_id,
        l.customer_id,
        c.monthly_income,
        b.monthly_debt_obligations,
        l.monthly_payment,

        ROUND(
            100.0 *
            (
                b.monthly_debt_obligations
                + l.monthly_payment
            )
            / NULLIF(c.monthly_income, 0),
            2
        ) AS dti,

        l.loan_status

    FROM loans l

    JOIN customers c
        ON l.customer_id = c.customer_id

    JOIN bureau_ranked b
        ON l.loan_id = b.loan_id
        AND b.rn = 1
)
SELECT
    COUNT(*) AS loans_with_dti,
    ROUND(MIN(dti), 2) AS minimum_dti,
    ROUND(AVG(dti), 2) AS average_dti,
    ROUND(MAX(dti), 2) AS maximum_dti
FROM dti_base;

-- DTI DISTRIBUTION 

WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        cb.monthly_debt_obligations,

        ROW_NUMBER() OVER (
            PARTITION BY l.loan_id
            ORDER BY cb.bureau_date DESC, cb.bureau_id DESC
        ) AS rn

    FROM loans l

    JOIN applications a
        ON l.application_id = a.application_id

    JOIN credit_bureau cb
        ON l.customer_id = cb.customer_id
        AND cb.bureau_date <= a.application_date
),

dti_base AS (
    SELECT
        l.loan_id,
        c.monthly_income,
        b.monthly_debt_obligations,
        l.monthly_payment,

        ROUND(
            100.0 *
            (
                b.monthly_debt_obligations
                + l.monthly_payment
            )
            / NULLIF(c.monthly_income, 0),
            2
        ) AS dti,

        l.loan_status

    FROM loans l

    JOIN customers c
        ON l.customer_id = c.customer_id

    JOIN bureau_ranked b
        ON l.loan_id = b.loan_id
        AND b.rn = 1
)

SELECT
    CASE
        WHEN dti < 30 THEN '<30%'
        WHEN dti < 40 THEN '30-39%'
        WHEN dti < 50 THEN '40-49%'
        WHEN dti < 60 THEN '50-59%'
        WHEN dti < 70 THEN '60-69%'
        WHEN dti < 100 THEN '70-99%'
        ELSE '100%+'
    END AS dti_band,

    COUNT(*) AS loan_count

FROM dti_base

GROUP BY
    CASE
        WHEN dti < 30 THEN '<30%'
        WHEN dti < 40 THEN '30-39%'
        WHEN dti < 50 THEN '40-49%'
        WHEN dti < 60 THEN '50-59%'
        WHEN dti < 70 THEN '60-69%'
        WHEN dti < 100 THEN '70-99%'
        ELSE '100%+'
    END

ORDER BY
    MIN(dti);
    
    
-- DOES DEFAULT RATE INCREASE AS DTI INCREASES
WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        cb.monthly_debt_obligations,

        ROW_NUMBER() OVER (
            PARTITION BY l.loan_id
            ORDER BY cb.bureau_date DESC, cb.bureau_id DESC
        ) AS rn

    FROM loans l

    JOIN applications a
        ON l.application_id = a.application_id

    JOIN credit_bureau cb
        ON l.customer_id = cb.customer_id
        AND cb.bureau_date <= a.application_date
),

dti_base AS (
    SELECT
        l.loan_id,

        ROUND(
            100.0 *
            (
                b.monthly_debt_obligations
                + l.monthly_payment
            )
            / NULLIF(c.monthly_income, 0),
            2
        ) AS dti,

        l.loan_status

    FROM loans l

    JOIN customers c
        ON l.customer_id = c.customer_id

    JOIN bureau_ranked b
        ON l.loan_id = b.loan_id
        AND b.rn = 1
)

SELECT
    CASE
        WHEN dti < 30 THEN '<30%'
        WHEN dti < 40 THEN '30-39%'
        WHEN dti < 50 THEN '40-49%'
        WHEN dti < 60 THEN '50-59%'
        WHEN dti < 70 THEN '60-69%'
        WHEN dti < 100 THEN '70-99%'
        ELSE '100%+'
    END AS dti_band,

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

FROM dti_base

GROUP BY
    CASE
        WHEN dti < 30 THEN '<30%'
        WHEN dti < 40 THEN '30-39%'
        WHEN dti < 50 THEN '40-49%'
        WHEN dti < 60 THEN '50-59%'
        WHEN dti < 70 THEN '60-69%'
        WHEN dti < 100 THEN '70-99%'
        ELSE '100%+'
    END

ORDER BY MIN(dti);
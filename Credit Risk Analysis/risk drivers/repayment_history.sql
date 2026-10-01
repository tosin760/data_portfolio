-- Do borrowers who already had problems with previous credit perform differently on their new Lendwise loan?
WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        l.customer_id,
        a.application_date,
        cb.previous_defaults,
        cb.previous_late_payments,
        cb.bureau_date,

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

loan_history AS (
    SELECT
        loan_id,
        previous_defaults,
        previous_late_payments
    FROM bureau_ranked
    WHERE rn = 1
)

SELECT
    CASE
        WHEN previous_defaults = 0 THEN 'No previous defaults'
        WHEN previous_defaults = 1 THEN '1 previous default'
        ELSE '2+ previous defaults'
    END AS previous_default_band,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN l.loan_status = 'Defaulted' THEN 1
            ELSE 0
        END
    ) AS current_defaults,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN l.loan_status = 'Defaulted' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS current_default_rate

FROM loan_history h

JOIN loans l
    ON h.loan_id = l.loan_id

GROUP BY
    CASE
        WHEN previous_defaults = 0 THEN 'No previous defaults'
        WHEN previous_defaults = 1 THEN '1 previous default'
        ELSE '2+ previous defaults'
    END

ORDER BY
    MIN(previous_defaults);
    
-- PREVIOUS LATE PAYMENTS
WITH bureau_ranked AS (
    SELECT
        l.loan_id,
        l.customer_id,
        a.application_date,
        cb.previous_defaults,
        cb.previous_late_payments,
        cb.bureau_date,

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

loan_history AS (
    SELECT
        loan_id,
        previous_defaults,
        previous_late_payments
    FROM bureau_ranked
    WHERE rn = 1
)

SELECT
    CASE
        WHEN previous_late_payments = 0 THEN '0'
        WHEN previous_late_payments BETWEEN 1 AND 2 THEN '1-2'
        WHEN previous_late_payments BETWEEN 3 AND 5 THEN '3-5'
        ELSE '6+'
    END AS late_payment_band,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN l.loan_status = 'Defaulted' THEN 1
            ELSE 0
        END
    ) AS current_defaults,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN l.loan_status = 'Defaulted' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS current_default_rate

FROM loan_history h

JOIN loans l
    ON h.loan_id = l.loan_id

GROUP BY
    CASE
        WHEN previous_late_payments = 0 THEN '0'
        WHEN previous_late_payments BETWEEN 1 AND 2 THEN '1-2'
        WHEN previous_late_payments BETWEEN 3 AND 5 THEN '3-5'
        ELSE '6+'
    END

ORDER BY MIN(previous_late_payments);
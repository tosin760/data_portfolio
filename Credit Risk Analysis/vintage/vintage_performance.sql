-- DEFAULT RATE FOR EACH VINTAGE
SELECT
    DATE_FORMAT(disbursement_date, '%Y-%m') AS vintage,

    COUNT(*) AS total_loans,

    SUM(loan_amount) AS total_disbursed,

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

GROUP BY DATE_FORMAT(disbursement_date, '%Y-%m')

ORDER BY vintage;
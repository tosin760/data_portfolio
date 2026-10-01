SELECT
    CASE
        WHEN a.credit_score < 550 THEN '<550'
        WHEN a.credit_score BETWEEN 550 AND 599 THEN '550-599'
        WHEN a.credit_score BETWEEN 600 AND 649 THEN '600-649'
        WHEN a.credit_score BETWEEN 650 AND 699 THEN '650-699'
        ELSE '700+'
    END AS credit_score_band,

    COUNT(l.loan_id) AS total_loans,

    SUM(
        CASE
            WHEN l.loan_status = 'Defaulted' THEN 1
            ELSE 0
        END
    ) AS defaulted_loans,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN l.loan_status = 'Defaulted' THEN 1
                ELSE 0
            END
        ) / COUNT(l.loan_id),
        2
    ) AS default_rate

FROM applications a

JOIN loans l
    ON a.application_id = l.application_id

GROUP BY
    CASE
        WHEN a.credit_score < 550 THEN '<550'
        WHEN a.credit_score BETWEEN 550 AND 599 THEN '550-599'
        WHEN a.credit_score BETWEEN 600 AND 649 THEN '600-649'
        WHEN a.credit_score BETWEEN 650 AND 699 THEN '650-699'
        ELSE '700+'
    END

ORDER BY
    MIN(a.credit_score);
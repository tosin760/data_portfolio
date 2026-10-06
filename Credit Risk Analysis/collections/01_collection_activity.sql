-- How much collection activity did Lendwise perform, and how much money was recovered?
SELECT
    COUNT(*) AS total_collection_activities,
    COUNT(DISTINCT loan_id) AS loans_with_collection_activity,
    SUM(amount_collected) AS total_amount_collected,
    ROUND(AVG(amount_collected), 2) AS average_amount_collected
FROM collections;

-- COLLECTION PERFORMANCE BY CHANNEL

SELECT
    collection_channel,
    COUNT(*) AS collection_activities,
    COUNT(DISTINCT loan_id) AS loans_contacted,
    ROUND(SUM(amount_collected), 2) AS total_collected,
    ROUND(AVG(amount_collected), 2) AS average_collected
FROM collections
GROUP BY collection_channel
ORDER BY total_collected DESC;


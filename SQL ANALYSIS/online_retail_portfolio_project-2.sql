-- ============================================================
----------         Online Retail Analysis  ------
-- (o = orders, oi = order_items, p = products, c = customers)
-- ============================================================

-- TOP CUSTOMERS (completed orders only, most recent order date)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COUNT(o.order_id) AS num_orders,
    ROUND(SUM(o.order_total), 2) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC;


-- MONTHLY SALES TREND with 3-month rolling average
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        COUNT(order_id) AS num_orders,
        ROUND(SUM(order_total), 2) AS total_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month
)
SELECT
    order_month,
    num_orders,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (
        ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3mo_avg
FROM monthly_sales
ORDER BY order_month;


-- REVENUE AND ORDERS BY STATUS (all statuses, no filter)
WITH status_revenue AS (
    SELECT
        o.status,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.status
)
SELECT
    status,
    order_count,
    ROUND(order_count * 100.0 / SUM(order_count) OVER (), 2) AS pct_of_orders,
    revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS pct_of_revenue
FROM status_revenue
ORDER BY revenue DESC;


-- REVENUE LOST PER PRODUCT FROM NON-COMPLETED ORDERS
SELECT
    p.product_id,
    p.product_name,
    SUM(CASE WHEN o.status = 'Completed' THEN oi.quantity * oi.unit_price ELSE 0 END) AS completed_revenue,
    SUM(CASE WHEN o.status != 'Completed' THEN oi.quantity * oi.unit_price ELSE 0 END) AS lost_revenue,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    ROUND(
        SUM(CASE WHEN o.status != 'Completed' THEN oi.quantity * oi.unit_price ELSE 0 END) * 100.0
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0), 2
    ) AS lost_revenue_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name
ORDER BY lost_revenue_pct DESC;


-- BEST SELLING PRODUCTS BY QUANTITY AND REVENUE (completed sales only)
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) * 100.0
        / SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 2) AS revenue_share_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;


-- REVENUE BY CATEGORY (completed sales only)
WITH sales AS (
    SELECT order_id, product_id, SUM(quantity * unit_price) AS sales_total
    FROM order_items
    GROUP BY order_id, product_id
)
SELECT
    p.category,
    ROUND(SUM(s.sales_total), 2) AS total
FROM products p
JOIN sales s ON p.product_id = s.product_id
JOIN orders o ON o.order_id = s.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY total DESC;

-- AVERAGE ORDER VALUE 
-- USING A CTE TO CALCULATE AOV
WITH average_order_value AS (
SELECT (SUM(quantity * unit_price)) AS revenue, COUNT(DISTINCT o.order_id) AS total_customers
FROM order_items o
JOIN 
orders od
ON o.order_id = od.order_id
WHERE od.status = 'Completed'
)
SELECT revenue, total_customers, (revenue / total_customers) AS margin
FROM average_order_value;
-- USING A MATHEMATICAL FIX TO CALCULATE AOV
SELECT (SUM(quantity * unit_price)) AS revenue, COUNT(DISTINCT od.order_id) AS num_orders, (SUM(quantity * unit_price)/COUNT(DISTINCT o.order_id)) as margin
FROM order_items o
JOIN 
orders od
ON o.order_id = od.order_id
WHERE od.status = 'Completed';

-- USING A SUBQUERY TO CALCULATE AOV
SELECT r, n, r/n AS margin
FROM (
SELECT SUM(quantity * unit_price) AS r, COUNT(DISTINCT o.order_id) AS n 
FROM order_items o
JOIN orders od
ON o.order_id = od.order_id
WHERE od.status = 'Completed') AS subquery_table

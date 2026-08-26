# E-Commerce Sales & Customer Analytics — SQL Portfolio Dataset

## Tables
- customers: customer demographics and segments
- products: product catalog, cost, and selling price
- orders: order-level transactions
- order_items: products and quantities within each order
- reviews: customer product reviews and ratings

## Relationships
customers.customer_id -> orders.customer_id
orders.order_id -> order_items.order_id
products.product_id -> order_items.product_id
customers.customer_id -> reviews.customer_id
products.product_id -> reviews.product_id

## Suggested business questions
1. What is monthly revenue and month-over-month growth?
2. Which products generate the most revenue and profit?
3. Which customer segments have the highest average order value?
4. What percentage of customers are repeat purchasers?
5. Which countries generate the most revenue?
6. What are the top 10 customers by lifetime value?
7. Which products have high sales but low profit margins?
8. Which products have the best and worst review ratings?
9. What payment methods are most popular?
10. What is the cancellation/return rate by month?
11. What is the average number of items per order?
12. Which categories are growing fastest year over year?

## Portfolio tip
Create a SQL project with:
- data model / ERD
- data quality checks
- exploratory SQL queries
- KPI queries
- advanced queries using CTEs and window functions
- business recommendations based on findings

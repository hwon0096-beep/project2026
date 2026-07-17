-- Business SQL for portfolio analysis.
-- Run after loading data. Each query can be copied into your README, notebook,
-- dashboard tool, or saved as views.

-- 1. Monthly revenue
WITH monthly_revenue AS (
    SELECT
        date_trunc('month', o.order_purchase_timestamp)::date AS order_month,
        SUM(oi.price) AS product_revenue,
        SUM(oi.freight_value) AS freight_revenue,
        SUM(oi.total_item_value) AS gross_revenue,
        COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    order_month,
    product_revenue,
    freight_revenue,
    gross_revenue,
    orders
FROM monthly_revenue
ORDER BY order_month;

-- 2. Month-over-month growth
WITH monthly_revenue AS (
    SELECT
        date_trunc('month', o.order_purchase_timestamp)::date AS order_month,
        SUM(oi.total_item_value) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),
with_lag AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue,
    previous_month_revenue,
    revenue - previous_month_revenue AS revenue_change,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_pct
FROM with_lag
ORDER BY order_month;

-- 3. Top product categories
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    SUM(oi.price) AS product_revenue,
    SUM(oi.total_item_value) AS gross_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation ct
    ON ct.product_category_name = p.product_category_name
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY gross_revenue DESC
LIMIT 20;

-- 4. Average order value
WITH order_totals AS (
    SELECT
        o.order_id,
        SUM(oi.total_item_value) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_value)::numeric, 2) AS median_order_value
FROM order_totals;

-- 5. Late delivery rate
SELECT
    COUNT(*) FILTER (WHERE delivery_delay_days > 0) AS late_orders,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NOT NULL) AS delivered_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivery_delay_days > 0)
        / NULLIF(COUNT(*) FILTER (WHERE order_delivered_customer_date IS NOT NULL), 0),
        2
    ) AS late_delivery_rate_pct
FROM orders
WHERE order_status = 'delivered';

-- 6. Review score vs delivery delay
WITH review_delay AS (
    SELECT
        CASE
            WHEN o.delivery_delay_days <= -7 THEN '7+ days early'
            WHEN o.delivery_delay_days BETWEEN -6 AND -1 THEN '1-6 days early'
            WHEN o.delivery_delay_days = 0 THEN 'on estimated date'
            WHEN o.delivery_delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
            WHEN o.delivery_delay_days BETWEEN 4 AND 7 THEN '4-7 days late'
            WHEN o.delivery_delay_days > 7 THEN '7+ days late'
            ELSE 'unknown'
        END AS delivery_timing_bucket,
        r.review_score
    FROM order_reviews r
    JOIN orders o ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    delivery_timing_bucket,
    COUNT(*) AS reviews,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM review_delay
GROUP BY delivery_timing_bucket
ORDER BY
    CASE delivery_timing_bucket
        WHEN '7+ days early' THEN 1
        WHEN '1-6 days early' THEN 2
        WHEN 'on estimated date' THEN 3
        WHEN '1-3 days late' THEN 4
        WHEN '4-7 days late' THEN 5
        WHEN '7+ days late' THEN 6
        ELSE 7
    END;

-- 7. RFM customer segmentation
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        SUM(oi.total_item_value) AS order_value
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id, o.order_id, o.order_purchase_timestamp
),
rfm AS (
    SELECT
        customer_unique_id,
        (MAX(order_purchase_timestamp)::date - MIN(order_purchase_timestamp)::date) AS active_days,
        ((SELECT MAX(order_purchase_timestamp)::date FROM customer_orders) + 1
            - MAX(order_purchase_timestamp)::date) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_value) AS monetary_value
    FROM customer_orders
    GROUP BY customer_unique_id
),
scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 4 AND frequency_score >= 3 THEN 'Loyal customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New or promising'
        WHEN recency_score <= 2 AND frequency_score >= 4 THEN 'At risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
        ELSE 'Needs attention'
    END AS rfm_segment
FROM scores
ORDER BY rfm_score DESC, monetary_value DESC;

-- 8. Seller revenue ranking
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    SUM(oi.price) AS product_revenue,
    SUM(oi.total_item_value) AS gross_revenue,
    RANK() OVER (ORDER BY SUM(oi.total_item_value) DESC) AS revenue_rank
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY revenue_rank
LIMIT 50;

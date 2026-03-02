-- PHASE 3.1 — Growth Analysis

--Are we growing overall?
SELECT
    o.order_month,
    COUNT(*) as total_orders,
    sum(order_revenue) as total_revenue ,
    (SUM(o.order_revenue) / count(distinct order_id)) as AOV
from fact_orders as o
GROUP by o.order_month
ORDER BY o.order_month


-- Month-over-Month Growth Rate
WITH monthly_data AS (
    SELECT 
        o.order_month,
        COUNT(*) AS current_month_total_orders,
        SUM(o.order_revenue) AS current_total_revenue
    FROM fact_orders o
    GROUP BY o.order_month
),

MOM AS (
    SELECT
        order_month,
        (
            (current_month_total_orders - LAG(current_month_total_orders) OVER (ORDER BY order_month)) * 100.0
            / NULLIF(LAG(current_month_total_orders) OVER (ORDER BY order_month), 0)
        ) AS MOM_orders,
        (
            (current_total_revenue - LAG(current_total_revenue) OVER (ORDER BY order_month)) * 100.0
            / NULLIF(LAG(current_total_revenue) OVER (ORDER BY order_month), 0)
        ) AS MOM_revenue,
        CASE 
            WHEN (
                (current_total_revenue - LAG(current_total_revenue) OVER (ORDER BY order_month)) * 100.0
                / NULLIF(LAG(current_total_revenue) OVER (ORDER BY order_month), 0)
            ) < 0 THEN 1
            ELSE 0
        END AS negative_growth_flag

    FROM monthly_data
)

SELECT 
    m.order_month,
    CAST(ROUND(m.MOM_orders, 2) AS DECIMAL(10,2)) AS MOM_orders,
    CAST(ROUND(m.MOM_revenue, 2) AS DECIMAL(10,2)) AS MOM_revenue,
    m.negative_growth_flag
FROM MOM as m
ORDER BY order_month;


-- Seasonality & Patterns
SELECT 
    FORMAT(fo.order_month , 'MMM') as Month_Name,
    COUNT(DISTINCT fo.order_id) as No_of_Orders
from fact_orders as fo
GROUP BY FORMAT(fo.order_month , 'MMM')


-- Average Order Value (AOV) Trend
SELECT 
    format(order_month , 'MMM') as month_name,
    SUM(order_revenue) AS total_revenue,
    (sum(order_revenue) / COUNT(distinct order_id) ) as AOV
FROM fact_orders AS FO
GROUP BY format(order_month , 'MMM')


--  New vs Returning Customer Contribution to Growth
SELECT c.customer_type, SUM(order_revenue) AS revenue
FROM fact_orders f
JOIN dbo.customer_segmentation c ON f.customer_id = c.customer_id
GROUP BY c.customer_type


--Growth Stability & Risk Signals
SELECT 
    *,
    CASE	
        WHEN mom_orders_change IS NULL THEN 'First month' 
        WHEN mom_orders_change > 0 AND mom_revenue_change < 0 THEN 'Orders up, Revenue down'
        WHEN mom_orders_change <= 0 AND mom_revenue_change > 0 THEN 'Revenue up, Orders flat/down' 
    END AS growth_mismatch_type
FROM (
    SELECT 
        order_month,no_of_orders, 
        no_of_orders - LAG(no_of_orders) OVER(ORDER BY order_month) AS mom_orders_change, revenue,
        revenue - LAG(revenue) OVER(ORDER BY order_month) AS mom_revenue_change
    FROM(
        SELECT 
            order_month, COUNT(DISTINCT order_id) AS no_of_orders, 
            SUM(order_revenue) AS revenue
        FROM fact_orders
GROUP BY order_month) AS t1) AS t2
WHERE
  (mom_orders_change > 0 AND mom_revenue_change < 0)
   OR   
  (mom_orders_change <= 0 AND mom_revenue_change > 0)

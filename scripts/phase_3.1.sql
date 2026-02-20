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

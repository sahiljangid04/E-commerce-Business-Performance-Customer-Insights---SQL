/* 

CREATE VIEW clean_orders AS
SELECT
    order_id,
    customer_id,
    order_date,
    approved_date,
    delivered_date,
    estimated_delivery_date,
    status,
    CASE
        WHEN status = 'delivered'
        AND delivered_date IS NOT NULL
        AND delivered_date >= approved_date
        THEN DATEDIFF(day, approved_date, delivered_date)
        ELSE NULL
        END AS delivery_days,
    CASE
    WHEN status = 'delivered' THEN 1
    ELSE 0
    END AS is_delivered
FROM orders
WHERE order_date >= '2022-01-01'
AND order_date <= GETDATE()

*/

/*
CREATE VIEW clean_order_items AS
SELECT 
    ot.order_id,
    ot.price,
    ot.product_id,
    ot.quantity,
    ot.freight_value
from dbo.order_items as ot
WHERE ot.quantity > 0 and price > 0 

*/

/*

CREATE VIEW fact_orders AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.delivered_date,
    o.status,
    o.delivery_days,
    DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS order_month,
    SUM(oi.quantity * oi.price) AS order_revenue
FROM clean_orders o
JOIN clean_order_items oi
ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date,
    o.delivered_date,
    o.status,
    o.delivery_days;

*/

/*

CREATE VIEW dim_customers AS
SELECT
    c.customer_id,
    c.signup_date,
    c.city,
    c.state,
    MIN(o.order_date) AS first_order_date
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.signup_date,
    c.city,
    c.state;

*/



/*

CREATE VIEW dim_products AS
SELECT
product_id,
category,
product_name
FROM products;

*/

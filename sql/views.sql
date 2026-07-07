USE ecommerce;

-- =========================================================
-- VIEW 1: CUSTOMER PURCHASE SUMMARY
-- Purpose:
-- Shows customer segment, total orders, total spending,
-- and average order value for each customer.
-- =========================================================

CREATE VIEW customer_purchase_summary AS

SELECT

    o.customer_id,
    c.customer_segment,

    COUNT(o.order_id) AS total_orders,

    SUM(oi.unit_price * oi.quantity) AS total_spent,

    AVG(oi.unit_price * oi.quantity) AS avg_order_value

FROM cleaned_orders_dataset o

JOIN cleaned_order_items_dataset oi
ON o.order_id = oi.order_id

JOIN cleaned_customers_dataset c
ON o.customer_id = c.customer_id

GROUP BY
    o.customer_id,
    c.customer_segment;


-- RUN
SELECT * FROM customer_purchase_summary
LIMIT 10;



-- =========================================================
-- VIEW 2: PRODUCT PROFITABILITY SUMMARY
-- Purpose:
-- Shows category-wise and brand-wise revenue,
-- total profit, and average profit.
-- =========================================================

CREATE VIEW product_profitability AS

SELECT

    p.Category_name,
    p.brand,

    SUM(p.selling_price * oi.quantity) AS total_revenue,

    SUM(oi.profit) AS total_profit,

    AVG(oi.profit) AS avg_profit

FROM cleaned_products_dataset p

JOIN cleaned_order_items_dataset oi
ON p.product_id = oi.product_id

GROUP BY
    p.Category_name,
    p.brand;


-- RUN
SELECT * FROM product_profitability
LIMIT 10;



-- =========================================================
-- VIEW 3: DELIVERY PERFORMANCE SUMMARY
-- Purpose:
-- Shows region-wise delivery performance,
-- average delivery days, and delayed orders.
-- =========================================================

CREATE VIEW delivery_performance AS

SELECT

    g.region,

    COUNT(*) AS total_orders,

    AVG(
        DATEDIFF(
            o.order_delivered_customer_date,
            o.order_purchase_timestamp
        )
    ) AS avg_delivery_days,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS delayed_orders

FROM cleaned_orders_dataset o

JOIN cleaned_customers_dataset c
ON o.customer_id = c.customer_id

JOIN cleaned_geolocation_dataset g
ON c.customer_zip_code = g.geolocation_zip_code

GROUP BY g.region;


-- RUN
SELECT * FROM delivery_performance
LIMIT 10;



-- =========================================================
-- VIEW 4: REVIEW & RATING SUMMARY
-- Purpose:
-- Groups reviews into rating ranges and
-- calculates total reviews and average rating.
-- =========================================================

CREATE VIEW review_summary AS

SELECT

    CASE
        WHEN review_score <= 1 THEN '0-1'
        WHEN review_score <= 2 THEN '1-2'
        WHEN review_score <= 3 THEN '2-3'
        WHEN review_score <= 4 THEN '3-4'
        ELSE '4-5'
    END AS rating_range,

    COUNT(*) AS total_reviews,

    AVG(review_score) AS avg_rating

FROM cleaned_order_reviews_dataset

GROUP BY rating_range;


-- RUN
SELECT * FROM review_summary
LIMIT 10;
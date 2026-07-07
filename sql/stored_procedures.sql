USE ecommerce;

-- =========================================================
-- PROCEDURE 1: TOP CUSTOMERS
-- Purpose:
-- Identifies the top 10 customers based on
-- their total spending.
-- =========================================================

DELIMITER //

CREATE PROCEDURE top_customers()

BEGIN

    SELECT

        o.customer_id,

        SUM(oi.unit_price * oi.quantity) AS total_spent

    FROM cleaned_orders_dataset o

    JOIN cleaned_order_items_dataset oi
    ON o.order_id = oi.order_id

    GROUP BY o.customer_id

    ORDER BY total_spent DESC

    LIMIT 10;

END //

DELIMITER ;


-- RUN
CALL top_customers();



-- =========================================================
-- PROCEDURE 2: REVENUE BY CATEGORY
-- Purpose:
-- Calculates category-wise revenue and profit.
-- =========================================================

DELIMITER //

CREATE PROCEDURE category_revenue()

BEGIN

    SELECT

        p.Category_name,

        SUM(
            p.selling_price * oi.quantity
        ) AS total_revenue,

        SUM(
            (p.selling_price - p.cost_price) * oi.quantity
        ) AS total_profit

    FROM cleaned_products_dataset p

    JOIN cleaned_order_items_dataset oi
    ON p.product_id = oi.product_id

    GROUP BY p.Category_name

    ORDER BY total_revenue DESC;

END //

DELIMITER ;


-- RUN
CALL category_revenue();



-- =========================================================
-- PROCEDURE 3: REPEAT PURCHASE ANALYSIS
-- Purpose:
-- Shows customer segment-wise customer count
-- and average spending.
-- =========================================================

DELIMITER //

CREATE PROCEDURE repeat_purchase_summary()

BEGIN

    SELECT

        c.customer_segment,

        COUNT(DISTINCT c.customer_id)
        AS total_customers,

        AVG(
            oi.unit_price * oi.quantity
        ) AS avg_spending

    FROM cleaned_customers_dataset c

    JOIN cleaned_orders_dataset o
    ON c.customer_id = o.customer_id

    JOIN cleaned_order_items_dataset oi
    ON o.order_id = oi.order_id

    GROUP BY c.customer_segment;

END //

DELIMITER ;


-- RUN
CALL repeat_purchase_summary();
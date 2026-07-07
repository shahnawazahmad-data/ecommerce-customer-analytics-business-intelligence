USE ecommerce;

-- =========================================================
-- TRIGGER 1: AUTO UPDATE CUSTOMER SEGMENT
-- Purpose:
-- Automatically updates customer segment based on
-- the number of orders placed by the customer.
-- =========================================================

DELIMITER //

CREATE TRIGGER update_customer_segment
AFTER INSERT ON cleaned_orders_dataset
FOR EACH ROW

BEGIN

    DECLARE order_count INT;

    SELECT COUNT(*)
    INTO order_count
    FROM cleaned_orders_dataset
    WHERE customer_id = NEW.customer_id;

    UPDATE cleaned_customers_dataset
    SET customer_segment =
        CASE
            WHEN order_count = 1 THEN 'New'
            WHEN order_count BETWEEN 2 AND 4 THEN 'Returning'
            ELSE 'Loyal'
        END

    WHERE customer_id = NEW.customer_id;

END //

DELIMITER ;


-- TEST
INSERT INTO cleaned_orders_dataset
(order_id, customer_id, order_purchase_timestamp)
VALUES
('ORDA9999', 'C00001', NOW());

SELECT customer_id, customer_segment
FROM cleaned_customers_dataset
WHERE customer_id = 'C00001';



-- =========================================================
-- TRIGGER 2: AUTOMATICALLY CALCULATE PROFIT
-- Purpose:
-- Calculates profit before inserting order items.
-- Profit = (Selling Price - Cost Price) × Quantity
-- =========================================================

DELIMITER //

CREATE TRIGGER calculate_profit
BEFORE INSERT ON cleaned_order_items_dataset
FOR EACH ROW

BEGIN

    DECLARE sp DOUBLE;
    DECLARE cp DOUBLE;

    SELECT selling_price
    INTO sp
    FROM cleaned_products_dataset
    WHERE product_id = NEW.product_id;

    SELECT cost_price
    INTO cp
    FROM cleaned_products_dataset
    WHERE product_id = NEW.product_id;

    SET NEW.profit = (sp - cp) * NEW.quantity;

END //

DELIMITER ;


-- TEST
INSERT INTO cleaned_order_items_dataset
(order_item_id, order_id, quantity, product_id,
 unit_price, `discount(%)`, shipping_cost)
VALUES
('OI99999', 'O00002', 2, 'P04408', 7590, 25, 150);

SELECT product_id, profit
FROM cleaned_order_items_dataset
WHERE order_item_id = 'OI99999';



-- =========================================================
-- TRIGGER 3: AUTO UPDATE DELIVERY STATUS
-- Purpose:
-- Marks orders as On Time or Delayed based on
-- actual delivery date and estimated delivery date.
-- =========================================================

DELIMITER //

CREATE TRIGGER update_delivery_status
BEFORE UPDATE ON cleaned_orders_dataset
FOR EACH ROW

BEGIN

    IF NEW.order_delivered_customer_date >
       NEW.order_estimated_delivery_date THEN

        SET NEW.delivery_status = 'Delayed';

    ELSE

        SET NEW.delivery_status = 'On Time';

    END IF;

END //

DELIMITER ;


-- TEST
UPDATE cleaned_orders_dataset
SET order_delivered_customer_date = '2025-06-15'
WHERE order_id = 'O00003';

SELECT
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    delivery_status
FROM cleaned_orders_dataset
WHERE order_id = 'O00003';



-- =========================================================
-- TRIGGER 4: AUTO ASSIGN DISCOUNT RANGE
-- Purpose:
-- Categorizes discount percentage into ranges.
-- =========================================================

DELIMITER //

CREATE TRIGGER assign_discount_range
BEFORE INSERT ON cleaned_order_items_dataset
FOR EACH ROW

BEGIN

    IF NEW.`discount(%)` <= 10 THEN

        SET NEW.discount_range = '0-10';

    ELSEIF NEW.`discount(%)` <= 20 THEN

        SET NEW.discount_range = '10-20';

    ELSEIF NEW.`discount(%)` <= 30 THEN

        SET NEW.discount_range = '20-30';

    ELSE

        SET NEW.discount_range = '30+';

    END IF;

END //

DELIMITER ;


-- TEST
INSERT INTO cleaned_order_items_dataset
(order_item_id, order_id, quantity, product_id,
 unit_price, `discount(%)`, shipping_cost)
VALUES
('OI99998', 'O00002', 2, 'P04408', 7590, 25, 150);

SELECT
    `discount(%)`,
    discount_range
FROM cleaned_order_items_dataset
WHERE order_item_id = 'OI99998';



-- =========================================================
-- TRIGGER 5: AUTO GENERATE REVIEW FLAG
-- Purpose:
-- Automatically marks whether a review has been given.
-- =========================================================

DELIMITER //

CREATE TRIGGER review_flag
BEFORE INSERT ON cleaned_order_reviews_dataset
FOR EACH ROW

BEGIN

    IF NEW.review_score IS NOT NULL THEN

        SET NEW.review_given = 'Yes';

    ELSE

        SET NEW.review_given = 'No';

    END IF;

END //

DELIMITER ;


-- TEST
INSERT INTO cleaned_order_reviews_dataset
(review_id, order_id, review_score)
VALUES
('R99999', 'O41195', 5);

SELECT
    review_score,
    review_given
FROM cleaned_order_reviews_dataset
WHERE review_id = 'R99999';
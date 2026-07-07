create database ecommerce; 
use ecommerce;
SELECT * FROM cleaned_customers_dataset LIMIT 10;
desc cleaned_customers_dataset;
SELECT * FROM cleaned_geolocation_dataset LIMIT 10;
SELECT * FROM cleaned_order_items_dataset LIMIT 10;
SELECT * FROM cleaned_order_reviews_dataset LIMIT 10;
SELECT * FROM cleaned_orders_dataset LIMIT 10;
SELECT * FROM cleaned_products_dataset LIMIT 10;

show tables;

show columns from cleaned_order_items_dataset;

ALTER TABLE cleaned_orders_dataset
ADD COLUMN delivery_status VARCHAR(20);

ALTER TABLE cleaned_order_items_dataset
ADD COLUMN discount_range VARCHAR(20);

ALTER TABLE cleaned_order_reviews_dataset
ADD COLUMN review_given VARCHAR(10);

ALTER TABLE cleaned_order_items_dataset
ADD COLUMN profit DOUBLE;



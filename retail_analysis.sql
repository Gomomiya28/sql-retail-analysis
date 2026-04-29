CREATE TABLE customers (
		customer_id VARCHAR (500) PRIMARY KEY,
		customer_unique_id VARCHAR (500),
		customer_zip_code_prefix INT,
		customer_city VARCHAR (500),
		customer_state VARCHAR(500)
);

CREATE TABLE orders (
		order_id VARCHAR (500) PRIMARY KEY,
		customer_id VARCHAR (500),
		order_status VARCHAR (500),
		order_purchase_timestamp TIMESTAMP,
		order_approved_at TIMESTAMP,
		order_delivered_carrier_date TIMESTAMP,
		order_delivered_customer_date TIMESTAMP,
		order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE products (
		product_id VARCHAR (500) PRIMARY KEY,
		product_category_name VARCHAR (500),
		product_name_lenght INT,
		product_description_lenght INT,
		product_photos_qty NUMERIC,
		product_weight_g INT,
		product_length_cm INT,
		product_height_cm INT,
		product_width_cm INT
		
);


CREATE TABLE order_items (
		order_id VARCHAR (500),
		order_item_id INT,
		product_id VARCHAR (500),
		seller_id VARCHAR (500),
		shipping_limit_date TIMESTAMP,
		price NUMERIC,
		freight_value NUMERIC
);

CREATE TABLE payments (
		order_id VARCHAR (500),
		payment_sequential INT,
		payment_type VARCHAR (500),
		payment_installments INT,
		payment_value NUMERIC
);

---------------- Using a subquery to count each tables records and have the result as seperate columns -----------------------------------
SELECT 								
(SELECT COUNT(*) FROM products) AS num_products,
(SELECT COUNT(*) FROM customers) AS num_customers,
(SELECT COUNT(*) FROM order_items) AS num_order_items,
(SELECT COUNT(*) FROM orders) AS num_orders,
(SELECT COUNT(*) FROM payments) AS num_payments;

-------------------------------- TOTAL REVEUE MADE OVERALL ------------------------
SELECT ROUND(SUM(payment_value), 0) AS total_revenue -- total revenue made
FROM payments;




--------------- MAXIMUM REVENUE PER PRODUCT CATEGORY, FOR EVERY CUSTOMR_ID, SORTED DESC. USING JOINS BRINGING ALL THE TABLES TOGETHER TO QUERY ALL AT ONCE. ----------------
SELECT pd.product_category_name, 
	   ROUND(MAX(pa.payment_value), 2) AS max_revenue_per_product_cat, 
	   c.customer_id
FROM products AS pd
LEFT JOIN order_items AS oi ON pd.product_id = oi.product_id
LEFT JOIN payments AS pa ON oi.order_id = pa.order_id
LEFT JOIN orders AS o ON pa.order_id = o.order_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY pd.product_category_name, c.customer_id
HAVING pd.product_category_name IS NOT NULL AND c.customer_id IS NOT NULL
ORDER BY max_revenue_per_product_cat DESC; 

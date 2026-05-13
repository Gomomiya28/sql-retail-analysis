---------------- CREATING TABLES NECESSARY TO HOLD THE DATA -----------------------------------

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

---------------- USING A SUBQUERY TO COUNT EACH TABLES RECORDS AND HAVE THE RESULT AS SEPERATE COLUMNS -----------------------------------
SELECT 								
(SELECT COUNT(*) FROM products) AS num_products,
(SELECT COUNT(*) FROM customers) AS num_customers,
(SELECT COUNT(*) FROM order_items) AS num_order_items,
(SELECT COUNT(*) FROM orders) AS num_orders,
(SELECT COUNT(*) FROM payments) AS num_payments;

-- == FINDINGS: Total recrods per table: 
-- number of products: 32,951 | 
-- number of customers: 99,441(unique) | 
-- number of items: 112,650 | 
-- number of orders: 99,441 | 
-- number of payments: 103,886 

-------------------------------- TOTAL REVEUE MADE OVERALL ------------------------

SELECT ROUND(SUM(payment_value)::NUMERIC, 2) AS total_revenue -- total revenue made, rounded to 2 decimal places
FROM payments;

-- == FINDINGS: Total revenue stated at: R$16,008,872.12


---------------- TOTAL ORDERS ON A MONTHLY BASIS OVER THE ENTIRE DATASET REGARDLESS OF YEAR (Years will be collapsed into each other) -----------------------------------

SELECT COUNT(*) AS total,
	   EXTRACT(month FROM order_purchase_timestamp) AS month
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month ASC;

-- == FINDINGS: ORDERS INCREASE FROM JAN - MAY AND DIP AGAIN. MAY, JULY, AUGUST EXPERIENCE HIGHEST ORDERS YEARLY


---------------- TOTAL ORDERS ON A MONTHLY BASIS OVER THE ENTIRE DATASET FOR EACH YEAR (Years highlighted in this query) -----------------------------------

SELECT COUNT(*) AS total,
	   DATE_TRUNC('month', order_purchase_timestamp)::DATE AS month
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month ASC;

-- == FINDINGS: 2016 has no record for the 11th month(November),orders increase from 2017-01-01, peaks for the first time at 7289 during 2017-11-01 again at 7003 
--    during 2018-01-01. 2016-09-01, 2016-12-01 at the lowest with 1 order each, and 2016-10-01 at second  lowest with 265. 
--    no records for 11th month in 2016 - find out why

----------------------------------------- MONTHS IN 2016 THAT HAVE DATA (ORDERS PLACED) -----------------------------------------


SELECT EXTRACT('YEAR' FROM order_purchase_timestamp) AS year,
	   EXTRACT('MONTH' FROM order_purchase_timestamp) AS month,
	   COUNT(*) AS num_orders
FROM orders
WHERE EXTRACT('YEAR' FROM order_purchase_timestamp) = '2016'
GROUP BY year, month
ORDER BY num_orders;

-- == FINDINGS: 2016 only has data for months: 9,10,12 - no records for month 11. **Assumption** is that there were no orders placed this month.

--------------- MAXIMUM REVENUE PER PRODUCT CATEGORY, FOR EVERY CUSTOMER_ID, SORTED DESC. USING JOINS BRINGING ALL THE TABLES TOGETHER TO QUERY ALL AT ONCE. ----------------
 

SELECT pd.product_category_name, 
	   ROUND(MAX(pa.payment_value)::NUMERIC, 2) AS max_revenue_per_product_cat, 
	   c.customer_id
FROM products AS pd
LEFT JOIN order_items AS oi ON pd.product_id = oi.product_id
LEFT JOIN payments AS pa ON oi.order_id = pa.order_id
LEFT JOIN orders AS o ON pa.order_id = o.order_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, pd.product_category_name
HAVING pd.product_category_name IS NOT NULL AND c.customer_id IS NOT NULL
ORDER BY max_revenue_per_product_cat DESC; 

-- == FINDINGS: 'telefonia_fixa' is highest grossing product at R$13,664.08, with customer_id identified with the highest payment value.

----------------------------- AVGERAGE DELIVERY DAYS FOR EVERY STATE -----------------------------

SELECT c.customer_state, 
	    ROUND(AVG(EXTRACT(DAY from(o.order_delivered_customer_date - o.order_purchase_timestamp ))), 0) AS avg_order_days
FROM customers AS c
JOIN orders AS o 
ON c.customer_id = o.customer_id
WHERE order_purchase_timestamp IS NOT NULL
	  AND order_delivered_customer_date IS NOT NULL
	  AND order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_order_days DESC;

--== FINDINGS: State RR has the highest avg order days at 29 days, lowest is SP with 8 days avg order delivery days.

--------------- TOP 10 STATES THAT HAVE THE HIGHEST DELIVERY DAYS DELAY, ACCORDING TO ORDER ID'S, GROUPED BY CUSTOMER STATE AND ORDERID ORDERED BY DELIVERY DAYS  ---------------

SELECT c.customer_state,
	   o.order_id,
	   MAX(o.order_purchase_timestamp)::DATE AS latest_order_date ,  
       MAX(o.order_delivered_customer_date)::DATE AS latest_order_delivered ,
	   EXTRACT(DAY FROM (MAX( o.order_delivered_customer_date) - MAX(o.order_purchase_timestamp))) AS delivery_days
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL 
	  AND  o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_state, o.order_id 
ORDER BY delivery_days DESC
LIMIT 10;

-- == FINDINGS: ES had the highest delivery days at 209 for an order from order placed to order delivered. MG had the lowest with 187 within the Top 10.

--------------- CUSTOMERS THAT GENERATE THE MOST REVENUE PER CUSTOMER ---------------


SELECT c.customer_id, MAX(pa.payment_value) AS highest_payment
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN payments AS pa ON o.order_id = pa.order_id
WHERE o.order_id IS NOT NULL
GROUP BY c.customer_id
ORDER BY highest_payment DESC
LIMIT 10;

-- == FINDINGS: The same customer that purchased 'telefonia_fixa' made the highest payment. There is a correlation between payment value and most valuable product.

----------------------------------------- MOST POPULAR PAYMENT METHODS -----------------------------------------

SELECT COUNT(payment_type) AS payment_types,
	   payment_type
FROM payments
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY payment_types DESC;

-- == FINDINGS: Credit card is the most used payment method.

----------------------------------------- PERCENTAGE OF ORDERS WITHIN ESTIMATED DELIVERY DATE RANGE -----------------------------------------


SELECT ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 ELSE 0 END)
	   / COUNT(*), 1) AS orders_on_time_percentag_overall
FROM ORDERS
WHERE order_delivered_customer_date IS NOT NULL;

-- == FINDINGS: 90.8% of orders are within or less than the estimated delivery date.


----------------------------------------- PERCENTAGE OF ORDERS WITHIN ESTIMATED DELIVERY DATE RANGE PER STATE -----------------------------------------


SELECT c.customer_state,
	   ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 ELSE 0 END)
	   / COUNT(*), 1) AS orders_on_time_percentage_per_state
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY orders_on_time_percentage_per_state ASC;

-- == FINDINGS: AL has the lowest % of orders within or before estimated delivery date and RO has the highest. 
--  We now know that AL is bringing the overall percentage down.


----------------------------------------- RANKING ORDERS WITHIN EACH STATE BY DELIVERY TIME USING PARTITION -----------------------------------------


SELECT o.order_id,
	   c.customer_state,
	   EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp )) AS delivery_days,
	   ROUND(AVG(EXTRACT (DAY FROM(order_delivered_customer_date - order_purchase_timestamp)))
  	   OVER (PARTITION BY c.customer_state),0) AS avg_delivery_days_per_state
FROM orders AS o
JOIN customers AS c
ON o.customer_id = o.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
	AND o.order_purchase_timestamp IS NOT NULL
	AND o.order_status = 'delivered'
GROUP BY order_id,customer_state
ORDER BY avg_delivery_days_per_state, delivery_days
LIMIT 10;

-- = Findings: State RR and other remote northern states consistently rank highest. SP and RJ orders rank lowest in their states reflecting faster delivery in major urban centres. 
-- (query takes time to execute as it runs row by row as expected)

----------------------------------------- RANKING ORDERS WITHIN EACH STATE BY DELIVERY TIME USING PARTITION -----------------------------------------

SELECT o.order_id,
	   c.customer_state,
	   EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp )) AS delivery_days,
	   RANK () OVER 
	   (PARTITION BY customer_state
	   ORDER BY 
	   EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp )) DESC)
	   AS rank_in_state
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
     AND o.order_purchase_timestamp IS NOT NULL
	 AND o.order_status = 'delivered'
ORDER BY c.customer_state, rank_in_state 
LIMIT 1000; 

-- = Findings: Every state's order delivery day has been ranked individually from 1st to last. State AC's orders ranks highest.






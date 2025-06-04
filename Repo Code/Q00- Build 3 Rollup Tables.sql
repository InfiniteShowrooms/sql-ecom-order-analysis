USE magist123;
-- ## BASE TABLES

## #1 Directly connected (via layout)
#SELECT * FROM orders; #o_all
#SELECT * FROM order_payments; #o_pay
#SELECT * FROM order_reviews; #o_rev

## #2 Bridge by order ID (via layout)
#SELECT * FROM customers; #cust_zip -99441 customers, customer_unique_id only 96096
#SELECT * FROM geo; #cust_geo
#SELECT * FROM sellers;
#SELECT * FROM order_items;
#SELECT * FROM orders;
#SELECT * FROM products;
#SELECT * FROM product_category_name_translation;
#SELECT COUNT(DISTINCT customer_unique_id) FROM customers; #cust_zip

## AFTER CREATION OF TABLES
#SELECT * FROM rollup_01_ordered_products_details_w_seller; # order line-item base for order/payment rollup
#SELECT * FROM rollup_A2_orders_single_line; # order base for customer rollup -99441 orders
#SELECT * FROM rollup_A3_customers_ltv; # final list of all customers with data rollup



#CREATE TABLE: rollup_01_ordered_products_details_w_seller: One row for each order line item, LEFT JOIN all order/category/seller info into order_items
CREATE TABLE rollup_01_ordered_products_details_w_seller AS
SELECT 
	o_itms.order_id AS overall_order_id,
    o_all.order_status AS overall_order_status,
    o_all.order_purchase_timestamp AS overall_order_purchase_timestamp,
    o_all.order_estimated_delivery_date AS overall_order_estimated_delivery_date,
    o_all.order_delivered_carrier_date AS overall_order_delivered_carrier_date,
    o_all.order_delivered_customer_date AS overall_order_delivered_customer_date,
    o_itms.order_item_id AS line_item_id,
    o_itms.product_id,
    cat_concat.product_category_name_english,
    o_itms.price AS line_item_price,
    o_itms.freight_value AS line_item_ship_cost,
    o_itms.shipping_limit_date,
	cat_concat.product_name_length,
	cat_concat.product_description_length,
	cat_concat.product_photos_qty,
	cat_concat.product_weight_g,
    cat_concat.linear_size_cm,
    o_itms.seller_id,
    'Brazil' AS seller_country,
	seller_location.state AS seller_state,
    seller_location.city AS seller_city,
    seller_location.seller_zip_code_prefix,
    seller_location.lat AS seller_lat,
    seller_location.lng AS seller_lng
FROM order_items AS o_itms
	LEFT JOIN orders AS o_all
		ON o_itms.order_id = o_all.order_id
	LEFT JOIN 
		(SELECT
			o_prods.product_id,
            o_cat_en.product_category_name_english,
			o_prods.product_name_length,
			o_prods.product_description_length,
			o_prods.product_photos_qty,
			o_prods.product_weight_g,
			o_prods.product_length_cm + o_prods.product_length_cm + o_prods.product_length_cm AS linear_size_cm
		FROM products AS o_prods
		LEFT JOIN product_category_name_translation AS o_cat_en
			ON o_prods.product_category_name = o_cat_en.product_category_name) AS cat_concat
		ON o_itms.product_id = cat_concat.product_id
	LEFT JOIN 
		(SELECT
			seller_zip.seller_id,
            seller_zip.seller_zip_code_prefix,
            seller_geo.city,
            seller_geo.state,
            seller_geo.lat,
            seller_geo.lng
		FROM sellers AS seller_zip
        LEFT JOIN geo AS seller_geo
			ON seller_zip.seller_zip_code_prefix = seller_geo.zip_code_prefix) AS seller_location
		ON o_itms.seller_id = seller_location.seller_id;
# =============================================================


#CREATE TABLE: rollup_A2_orders_single_line: GROUP BY rollup all rollup_01_ordered_products_details_w_seller data into single order row data
CREATE TABLE rollup_A2_orders_single_line AS
WITH ranked_reviews AS (
	SELECT *,
    ROW_NUMBER() OVER (
		PARTITION BY order_id
        ORDER BY review_creation_date DESC) AS rn
	FROM order_reviews
),
o_latest_review AS (
	SELECT *
	FROM ranked_reviews
	WHERE rn = 1
) # if I do the WHERE rn = 1 at the end of my query, it cuts the 1162 orders without reviews, so I need to do it before my SELECT
SELECT 
	cust.customer_unique_id,
    o_all.customer_id,
    o_all.order_id,
	o_pay.payment_order_total,
    ord_line_summary.ord_total_line_items,
    ord_line_summary.ord_total_product_items,
    ord_line_summary.ord_total_product_categories,
    o_all.order_status,
    o_all.order_purchase_timestamp,
    o_all.order_approved_at,
    o_all.order_delivered_carrier_date,
    o_all.order_delivered_customer_date,
    o_all.order_estimated_delivery_date,
    ROUND((ord_line_summary.ord_total_item_value + ord_line_summary.ord_total_ship_cost),2) AS ord_order_value_total,
    ROUND((payment_order_total - ord_line_summary.ord_total_item_value - ord_total_ship_cost),2) AS payment_financing_costs,
    ROUND(ord_line_summary.ord_total_item_value,2) AS ord_total_item_value,
    ROUND(ord_line_summary.ord_total_ship_cost,2) AS ord_total_ship_cost,
	o_pay.payment_total_installments,
    o_pay.payment_type,
    o_latest_review.review_score,
    o_latest_review.review_comment_title,
    o_latest_review.review_comment_message,
    o_latest_review.review_creation_date,
    o_latest_review.review_answer_timestamp,
	o_latest_review.review_id,
    'Brazil' AS customer_country,
    customer_location.state AS customer_state,
    customer_location.city AS customer_city,
    customer_location.customer_zip_code_prefix,
    customer_location.lat AS customer_lat,
    customer_location.lng AS customer_lng
FROM orders AS o_all
LEFT JOIN customers AS cust
	ON o_all.customer_id = cust.customer_id
LEFT JOIN  
	(SELECT
		order_id,
        MAX(payment_sequential) AS payment_total_installments,
        MAX(payment_type) AS payment_type,
        #MAX(payment_installments) , #This isn't listed as separate transactions - payment_sequential should be summed but payment_installments (usually credit card) isn't listed as separate payment transactions (see 1389d3b1fab26d87e40c382d11a8ac3c)
        ROUND(SUM(payment_value),2) AS payment_order_total
    FROM order_payments
    GROUP BY order_id
	) AS o_pay
	ON o_all.order_id = o_pay.order_id
LEFT JOIN o_latest_review
	ON o_all.order_id = o_latest_review.order_id
LEFT JOIN (SELECT
			cust_zip.customer_id,
            cust_zip.customer_zip_code_prefix,
            cust_geo.city,
            cust_geo.state,
            cust_geo.lat,
            cust_geo.lng
		FROM customers AS cust_zip
        LEFT JOIN geo AS cust_geo
			ON cust_zip.customer_zip_code_prefix = cust_geo.zip_code_prefix) AS customer_location
	ON o_all.customer_id = customer_location.customer_id
LEFT JOIN (SELECT 
			order_id,
            MAX(line_item_id) AS ord_total_line_items,
            SUM(line_item_price) AS ord_total_item_value,
            SUM(line_item_ship_cost) AS ord_total_ship_cost,
			GROUP_CONCAT(
				DISTINCT COALESCE(product_id, 'UNKNOWN')
				ORDER BY product_id
				SEPARATOR ', '
			) AS ord_total_product_items,
            GROUP_CONCAT(
				DISTINCT COALESCE(product_category_name_english, 'UNKNOWN')
				ORDER BY product_id
				SEPARATOR ', '
			) AS ord_total_product_categories
			FROM rollup_01_ordered_products_details_w_seller
			GROUP BY order_id) AS ord_line_summary
	ON o_all.order_id = ord_line_summary.order_id;
# =======================================================================



#CREATE TABLE: rollup_A3_customers_ltv: GROUP BY rollup all order data into customer-level info
CREATE TABLE rollup_A3_customers_ltv AS
SELECT
	cust.customer_unique_id,
    MAX(customer_order_rollup.cust_LTV) AS cust_LTV, #Have to MAX() because of the GROUP BY on customers which assumes aggregation. It's already being agreggated but MAX() is a safe, real-world pass-through of scalar values from the subquery, even if there's only one row per group — it’s a very common and accepted practice in production code.
    MAX(customer_order_rollup.cust_num_orders) AS cust_num_orders,
    MAX(customer_order_rollup.cust_avg_order_value) AS cust_avg_order_value,
	MAX(customer_order_rollup.cust_first_order_date) AS cust_first_order_date,
	MAX(customer_order_rollup.cust_newest_order_date) AS cust_newest_order_date,
    DATEDIFF(
		MAX(customer_order_rollup.cust_newest_order_date),
		MAX(customer_order_rollup.cust_first_order_date)
	) AS cust_lifespan_days,
    ROUND((DATEDIFF(
		MAX(customer_order_rollup.cust_newest_order_date),
		MAX(customer_order_rollup.cust_first_order_date)
	) / MAX(customer_order_rollup.cust_num_orders)),0) AS cust_avg_days_between_order,
    'Brazil' AS customer_country,
    MAX(cust_geo.state) AS customer_state,
    MAX(cust_geo.city) AS customer_city,
    MAX(cust_geo.zip_code_prefix) AS customer_zip_code_prefix,
    MAX(cust_geo.lat) AS customer_lat,
    MAX(cust_geo.lng) AS customer_lng,
	MAX(customer_order_rollup.num_cust_accounts) AS num_cust_accounts__id_for_each_order
FROM customers AS cust
LEFT JOIN geo AS cust_geo
	ON cust.customer_zip_code_prefix = cust_geo.zip_code_prefix
LEFT JOIN (
		SELECT
			customer_unique_id,
            COUNT(customer_id) AS num_cust_accounts,
            ROUND(SUM(payment_order_total),2) AS cust_LTV,
            COUNT(DISTINCT order_id) AS cust_num_orders,
            ROUND(AVG(payment_order_total),2) AS cust_avg_order_value,
            MIN(order_purchase_timestamp) AS cust_first_order_date,
            MAX(order_purchase_timestamp) AS cust_newest_order_date
        FROM rollup_A2_orders_single_line
		GROUP BY customer_unique_id
    ) AS customer_order_rollup
    ON cust.customer_unique_id = customer_order_rollup.customer_unique_id
#WHERE cust.customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455'
GROUP BY cust.customer_unique_id;
# =======================================================================


SELECT * FROM rollup_01_ordered_products_details_w_seller; # order line-item base for order/payment rollup
SELECT * FROM rollup_A2_orders_single_line; # order base for customer rollup -99441 orders
SELECT * FROM rollup_A3_customers_ltv; # final list of all customers with data rollup



/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL

-- See GPT chat: Joining rollup_A2_orders_single_line and customers: Even though I want to join on customer_unique_id, the TRUE unique database key between the two tables is customer_id. So if I use customer_id for the LEFT JOIN it is safe (except in scenarios you mentioned). But it explodes the data when using customer_unique_id because (in my 6469f99c1f9dfae7733b25662e7f1782 example) it finds that value 7 times in the rollup_A2_orders_single_line table rows and 7 times in customers table rows, so I end up with 49 entries. // revised answer: Even though I want to join on customer_unique_id (because I want to roll up customer-level data), the true row-to-row join key between rollup_A2_orders_single_line and customers is actually customer_id — because each order is tied to a specific customer account. So when I use customer_id in the LEFT JOIN, I get a clean, 1:1 relationship, which is safe and accurate. But if I join on customer_unique_id, it explodes the data: 1. rollup_A2_orders_single_line has 7 rows for that customer (1 per order) 2. customers has 7 rows (1 per account under that same person) 3. The result: 7 × 7 = 49 rows — a full many-to-many join explosion, unless I aggregate first or deduplicate with a subquery.
-- WITH (executed before SELECT) is considered the modern way to pre-filter aggregate values if you want to return the MAX or whatever of a particular row and get all other values for that row
-- simple way to count dupes: https://www.linkedin.com/pulse/how-find-duplicates-table-using-sql-learnsql-com/
-- create table: CREATE TABLE rollup_01_ordered_products_details_w_seller AS SELECT ... 
-rename table: RENAME TABLE rollup_order_line_items TO rollup_01_ordered_products_details_w_seller;
-SUM() is an aggregation function and requires GROUP BY under ONLY_FULL_GROUP_BY mode ✅ You don’t need SUM() for simple math on a single row — just use + (Yes — ONLY_FULL_GROUP_BY is now the default in MySQL (since version 5.7.5, released in 2015), and it’s considered a best practice for modern SQL writing - also strict in PostgreSQL, BigQuery, and Oracle)
-Select count+distinct = Count(DISTINCT program_name) AS [Count]: https://stackoverflow.com/questions/1521605/selecting-count-with-distinct
-nested queries can be done in SELECT: https://learnsql.com/blog/sql-nested-select/
Month: https://www.w3schools.com/sql/func_sqlserver_month.asp
Year: https://www.w3schools.com/sql/func_sqlserver_year.asp
Joining 2 databases (JOIN): https://www.w3schools.com/sql/sql_join.asp
COUNT, SUM, AVG, etc: https://www.w3schools.com/sql/sql_count_avg_sum.asp
CASE (add column with if/else categorization): 
Sum 2 fields in a query(SELECT *, (FieldA + FieldB) AS Sum FROM Table
): https://stackoverflow.com/questions/14877797/how-to-sum-two-fields-within-an-sql-query
Percentage (couldn't get to work, did round*100): https://www.mssqltips.com/sqlservertip/7021/sql-format-number/
Calculate against previous rows with LAG(), but couldn't try: https://www.devart.com/dbforge/sql/datacompare/compare-sql-server-rows-and-columns.html
*/

-- ==========================END DOCUMENT==================================
USE magist123;

-- use Justin's 3 tables
SELECT * FROM rollup_01_ordered_products_details_w_seller;
SELECT * FROM rollup_A2_orders_single_line;
SELECT * FROM rollup_A3_customers_ltv;

/*
#################################################
Question 1:  How many orders are there in the dataset? The orders table contains a row for each order, so this should be easy to find out!
Author: Justin
*/


-- ## BASE TABLES
SELECT * FROM orders;

-- ## FINAL SQL
-- SUMMARY: 99,441 orders (need more info than just a raw count)
SELECT COUNT(*) 
FROM orders;

/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL

*/




/*
#################################################
Question 2: Are orders actually delivered? Look at the columns in the orders table: one of them is called order_status. Most orders seem to be delivered, but some aren’t. Find out how many orders are delivered and how many are cancelled, unavailable, or in any other status by grouping and aggregating this column.
Author: Justin
*/


-- ## BASE TABLES
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM order_items;

-- ## FINAL SQL
-- SUMMARY: [Need deeper analysis]
SELECT 
	order_status, 
    COUNT(order_purchase_timestamp) AS 'Total Orders'
FROM orders
GROUP BY order_status;

/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL

*/


/*
#################################################
Question 3: Is Magist having user growth? A platform losing users left and right isn’t going to be very useful to us. It would be a good idea to check for the number of orders grouped by year and month. Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.
Author: Justin
*/


-- use my 3 tables
SELECT * FROM summarized_1_order_line_items;
SELECT * FROM summarized_2_orders;
SELECT * FROM summarized_3_customers;
-- Customers/Orders: #3: Is Magist having user growth? A platform losing users left and right isn’t going to be very useful to us. It would be a good idea to check for the number of orders grouped by year and month. Tip: you can use the functions YEAR() and MONTH() to separate the year and the month of the order_purchase_timestamp.

## SUMMARY: Understanding the data:
-- -- 
-- CURRENT ITERATION: 
-- TO-DO: Maybe want to merge in description length, photos for added purchase correlations. And weight, and sum liniar dimensions for additional delivery patterns.

-- ## BASE TABLES
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM product_category_name_translation;

# total customers - 96,096
SELECT 
	COUNT(customer_unique_id),
    ROUND(SUM(cust_LTV),2),
    SUM(cust_num_orders),
    ROUND(AVG(cust_LTV),2)
FROM summarized_3_customers
GROUP BY customer_country;
# total repeat customers - 2997 (3.1% repeat purchase rate, VERY LOW) 
SELECT 
	COUNT(customer_unique_id),
    ROUND(SUM(cust_LTV),2),
    SUM(cust_num_orders),
    ROUND(AVG(cust_LTV),2)
FROM summarized_3_customers
WHERE cust_num_orders >= 2
GROUP BY customer_country;

-- ## FINAL SQL
-- SUMMARY: [Need deeper analysis with visual graphing/comparative data]
# Group customer by year
SELECT 
	YEAR(cust.cust_first_order_date) AS order_year, 
    MONTH(cust.cust_first_order_date) AS order_month, 
    ROUND(SUM(cust.cust_LTV),2) AS 'Total Lifetime Revenue', 
    SUM(cust.cust_num_orders) AS 'Total Lifetime Products Bought (not unique products)'
    /*ROUND(SUM(i.price + i.freight_value),2) AS 'Sum Order Totals', 
    ROUND(SUM(i.price),2) AS 'Total Net Product Sales',
    ROUND(AVG(i.price + i.freight_value),2) AS avg_order_value,
    ROUND(AVG(i.freight_value / (i.price  + i.freight_value))*100,2) AS 'Avg Shipping Cost %'*/
FROM summarized_3_customers AS cust
GROUP BY order_year, order_month
ORDER BY order_year ASC, order_month ASC;
#ORDER By avg_order_value DESC;
-- ORDER By order_year ASC, order_month ASC;





/*
#################################################
Question 4: How many products are there on the products table? (Make sure that there are no duplicate products.)
Author: Justin
*/
-- ## SUMMARY: Total_Product_Count= 32951.
-- -- [see Q06 notes]
-- CURRENT ITERATION: Add sum-up of avg/median description, 
-- TO-DO: 

-- ## BASE TABLES
SELECT * FROM products;

-- ## FINAL SQL
select count(distinct product_id) as Total_Product_Count
from products;

/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL
-Capitalization is not required, mostly a leftover from 40+ age COBOL programmers. Purely a personal preference. IDE handles it: https://stackoverflow.com/questions/608196/why-should-i-capitalize-my-sql-keywords-is-there-a-good-reason
-uncheck 1000 row limit in MySQL: https://superuser.com/questions/240291/how-to-remove-1000-row-limit-in-mysql-workbench-queries
*/




/*
#################################################
Question 5: Which are the categories with the most products? Since this is an external database and has been partially anonymized, we do not have the names of the products. But we do know which categories products belong to. This is the closest we can get to knowing what sellers are offering in the Magist marketplace. By counting the rows in the products table and grouping them by categories, we will know how many products are offered in each category. This is not the same as how many products are actually sold by category. To acquire this insight we will have to combine multiple tables together: we’ll do this in the next lesson.
Author: Justin
*/
-- ## SUMMARY: ???
-- CURRENT ITERATION: Merge english names (DONE)
-- TO-DO: 

-- ## BASE TABLES
SELECT * FROM products;
SELECT * FROM product_category_name_translation;

-- ## FINAL SQL
select t.product_category_name_english, count(distinct p.product_id) as Product_Count
from products as p
join product_category_name_translation as t 
	using(product_category_name)
group by product_category_name
order by Product_Count desc;

/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL
-Capitalization is not required, mostly a leftover from 40+ age COBOL programmers. Purely a personal preference. IDE handles it: https://stackoverflow.com/questions/608196/why-should-i-capitalize-my-sql-keywords-is-there-a-good-reason
*/




/*
#################################################
Question 6: How many of those products were present in actual transactions? The products table is a “reference” of all the available products. Have all these products been involved in orders? Check out the order_items table to find out!
Author: Justin
*/
-- ## SUMMARY: Understanding the data:
-- --  No, they did not give us a list of all products offered via their services, so we're not accounting for unpurchased products (products list == products ordered, 32951 for product_id)
-- -- Line items is order_item_id in order_items table, so total # orders sum comes from GROUP BY of all order_id (Yes, order item ID is the # in the order, to account for multiple products in single order_id '8272b63d03f5f79c56e9e4120aec44ef'. So the full order value is actually the GROUP BY of all order_id)
-- CURRENT ITERATION: 
-- TO-DO: 

-- ## BASE TABLES
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM product_category_name_translation;
SELECT * FROM order_payments;
SELECT * FROM customers;

-- ## FINAL SQL
-- SUMMARY: ???

# Number of ordered items
select count(distinct product_id) as Ordered_Product_Count 
from order_items as o
	join products as p
		using(product_id);
        




/*
-- ## QUESTION SQL (RE)LEARNING MATERIAL
-Capitalization is not required, mostly a leftover from 40+ age COBOL programmers. Purely a personal preference. IDE handles it: https://stackoverflow.com/questions/608196/why-should-i-capitalize-my-sql-keywords-is-there-a-good-reason
-Multiple joins in 1 query: https://stackoverflow.com/questions/8974328/mysql-multiple-joins-in-one-query
*/




/*
#################################################
Question 7: What’s the price for the most expensive and cheapest products? Sometimes, having a broad range of prices is informative. Looking for the maximum and minimum values is also a good way to detect extreme outliers.
Author: Kareem
*/
--Answer: the cheapest is price will be 0.85 and the most expensive one is 6735

SELECT
product_category_name,
COUNT(product_id) AS total_products
FROM products
WHERE product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY total_products DESC;



SELECT COUNT(DISTINCT product_id) AS total_products FROM products;





/*
#################################################
Question 8: What are the highest and lowest payment values? Some orders contain multiple products. What’s the highest someone has paid for an order? Look at the order_payments table and try to find it out.
Author: Kareem
*/

--Answer: highest 13664.1 lowest 0
--	13664.099609375

SELECT
MAX(price) AS most_expensive,
MIN(price) AS cheapest
FROM order_items;





-- ==========================END DOCUMENT==================================

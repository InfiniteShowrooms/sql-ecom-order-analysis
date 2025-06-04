USE magist123;

-- use my 3 tables
SELECT * FROM rollup_01_ordered_products_details_w_seller;
SELECT * FROM rollup_A2_orders_single_line;
SELECT * FROM rollup_A3_customers_ltv;

/*
#################################################
2.1. In relation to the products:
==================================
-2.1.1 What categories of tech products does Magist have?
-2.1.2 How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
-2.1.3 What’s the average price of the products being sold?
-2.1.4 Are expensive tech products popular? (TIP: Look at the function CASE WHEN to accomplish this task)
*/



/*
#################################################
2.2. In relation to the sellers:
==================================
-2.2.1 How many months of data are included in the magist database?
-2.2.2 How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-2.2.3 What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-2.2.4 Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
*/



/*
#################################################
2.3. In relation to the delivery time:
==================================
-2.3.1 What’s the average time between the order being placed and the product being delivered?
-2.3.2 How many orders are delivered on time vs orders delivered with a delay?
-2.3.3 Is there any pattern for delayed orders, e.g. big products being delayed more often?
*/

#################################################
##2.3.1 What’s the average time between the order being placed and the product being delivered?
#################################################
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_days
FROM rollup_A2_orders_single_line;


#################################################
##2.3.2 How many orders are delivered on time vs orders delivered with a delay?
#################################################
	
#full list of statuses
#approved	2 -- INCLUDE: from 2017, took money so why weren't they delivered or cancelled?
#canceled	625 -- EXCLUDE: they're cancelled
#created	5 -- INCLUDE: 4 from 2017, took money so why weren't they delivered or cancelled?
#delivered	96478 -- INCLUDE: Ideal scenario
#invoiced	314 -- INCLUDE: Spans 2017-18, took money so why weren't they delivered or cancelled?
#processing	301 -- INCLUDE: Spans 2017-18, took money so why weren't they delivered or cancelled?
#shipped	1107 -- INCLUDE: Spans 2017-18, took money (and picked up by carrier) so why weren't they delivered or cancelled?
#unavailable	609 -- INCLUDE: Spans 2016-18, took money so why weren't they delivered or cancelled?
SELECT
	order_status,
    count(order_id)
FROM rollup_A2_orders_single_line
GROUP BY order_status;

#check individual statuses
SELECT * FROM rollup_A2_orders_single_line
WHERE order_status NOT IN ('unavailable','','','','');
#('processing','canceled','approved','created','','','','')

##WRONG: aliases like delivery_status aren't available in the GROUP BY (they don't exist yet) so you either have to repeat CASE twice or use a subquery
SELECT
  CASE
    WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
    WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Delayed'
    ELSE 'No Deliver Date (Status != created,approved,processing,cancelled)'
  END AS delivery_status,
	order_status,
    delivery_status,
	COUNT(*) AS num_orders
FROM rollup_A2_orders_single_line
WHERE order_status NOT IN ('processing','canceled','approved','created','','','','')
GROUP BY order_status, delivery_status;

#do subquery method
SELECT
  order_status,
  delivery_status,
  COUNT(*) AS num_orders,
  ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),2) AS avg_delivery_days,
  ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)),2) AS deliver_vs_estimate__negative_good,
  ROUND(AVG(payment_order_total),2) AS order_payment__avg,
  ROUND(SUM(payment_order_total),2) AS order_payment__total,
  ROUND(AVG(ord_total_item_value),2) AS item_value__avg,
  ROUND(SUM(ord_total_item_value),2) AS item_value__total,
  ROUND(AVG(ord_total_ship_cost),2) AS ship_cost__avg,
  ROUND(SUM(ord_total_ship_cost),2) AS ship_cost__total
FROM (
  SELECT *,
    CASE
      WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On Time'
      WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Delayed'
      ELSE 'No Delivery Date (paid, but no deliver time)'
    END AS delivery_status
  FROM rollup_A2_orders_single_line
  WHERE order_status NOT IN ('canceled','')
) AS labeled_orders
GROUP BY order_status, delivery_status;


#################################################
#-2.3.3 Is there any pattern for delayed orders, e.g. big products being delayed more often?
#################################################
SELECT * FROM rollup_01_ordered_products_details_w_seller;

SELECT
  overall_order_status,
  delivery_status,
  #product_category_name_english,
  COUNT(*) AS num_line_items,
  ROUND(AVG(DATEDIFF(overall_order_delivered_customer_date, overall_order_purchase_timestamp)),2) AS avg_delivery_days,
  ROUND(AVG(DATEDIFF(overall_order_delivered_customer_date, overall_order_estimated_delivery_date)),2) AS deliver_vs_estimate__negative_good,
  ROUND(AVG(line_item_ship_cost),2) AS avg_line_item_ship_cost,
  ROUND(AVG(product_weight_g),2) AS avg_product_weight_g,
  ROUND(AVG(linear_size_cm),2) AS avg_linear_size_cm
FROM (
  SELECT *,
    CASE
      WHEN overall_order_delivered_customer_date <= overall_order_estimated_delivery_date THEN 'On Time'
      WHEN overall_order_delivered_customer_date > overall_order_estimated_delivery_date THEN 'Delayed'
      ELSE 'No Delivery Date (paid, but no deliver time)'
    END AS delivery_status
  FROM rollup_01_ordered_products_details_w_seller
  WHERE overall_order_status NOT IN ('canceled','')
) AS labeled_orders
GROUP BY overall_order_status, delivery_status;

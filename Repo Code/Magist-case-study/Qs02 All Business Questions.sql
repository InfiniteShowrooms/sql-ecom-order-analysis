USE magist123;

-- use Justin's 3 tables
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

-- #################################################
-- ##2.1.1 What categories of tech products does Magist have?
-- #################################################

-- #Swayam

select pt.product_category_name_english, count(pt.product_category_name_english) as total_products
from products p
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "%telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
or pt.product_category_name_english like "%mobile%"

group by pt.product_category_name_english
order by total_products desc;


-- #################################################
-- ##2.1.2 How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?
-- #################################################

#Swayam
select 
pt.product_category_name_english, 
count(o.order_id) as Product_Sold,
round((count(o.order_id)*100)/(select count(o1.order_id) from orders o1),2) as Percentage_Product_Sold
from orders o
left join order_items oi using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
group by pt.product_category_name_english
order by Product_Sold desc ;

#################################################################
select count(*) from orders;
#################################################################
#Top 10 share of items sold by Magist

select 
pt.product_category_name_english, 
count(o.order_id) as Product_Sold,
round((count(o.order_id)*100)/(select count(o1.order_id) from orders o1),2) as Percentage_Product_Sold
from orders o
left join order_items oi using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
group by pt.product_category_name_english
order by Product_Sold desc 
limit 10;


-- #################################################
-- ##2.1.3 What’s the average price of the products being sold?
-- #################################################

-- #Swayam
select 
pt.product_category_name_english,
count(o.order_id),
round(avg(oi.price),2) as Avg_price
from orders o
left join order_items oi using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
group by pt.product_category_name_english
order by Avg_price desc;



-- #################################################
-- ##2.1.4 Are expensive tech products popular? (TIP: Look at the function CASE WHEN to accomplish this task)
-- #################################################


-- #Swayam
use magist123;
select
pt.product_category_name_english, 
case when oi.price > 500 then "Expensive"
     when oi.price <= 500 and oi.price > 100 then "Affordable"
     when oi.price <= 100 then "Low-Priced"
end as Price_Category,
count(o.order_id) as Products_Sold,
round(sum(oi.price),2) as Total_Revenue
from orders o
left join order_items oi using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
group by pt.product_category_name_english, Price_Category
order by Total_Revenue desc;




/*
#################################################
2.2. In relation to the sellers:
==================================
-2.2.1 How many months of data are included in the magist database?
-2.2.2 How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-2.2.3 What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-2.2.4 Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
*/

-- #################################################
-- ##2.2.1 How many months of data are included in the magist database?
-- #################################################

#Swayam
select min(order_purchase_timestamp) as Earliest_order, 
       max(order_purchase_timestamp) as Latest_order,
	   timestampdiff(month,min(order_purchase_timestamp),max(order_purchase_timestamp))as Total_Months

from orders;

SELECT
TIMESTAMPDIFF(MONTH,
MIN(order_purchase_timestamp),
MAX(order_purchase_timestamp)
) AS total_months
FROM orders;



-- #################################################
-- ##2.2.2 How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- #################################################

#Swayam
select count(distinct seller_id) from sellers;

select 
(select count(distinct seller_id) from sellers) as Total_Sellers,
count(distinct oi.seller_id) as Tech_Sellers,
round((count(distinct oi.seller_id)*100)/(select count(distinct seller_id) from sellers),0) as '%Tech_Sellers'
from sellers s
join order_items oi using (seller_id)
join products p using (product_id)
join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
;


-- #################################################
-- ##2.2.3 What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- #################################################

#Swayam
select 
(select round(sum(price + freight_value),0) from order_items) as Total_Seller_Revenue,
round(sum(oi.price + oi.freight_value),0) as Tech_Seller_Revenue
from order_items oi
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
;

#Product_Category wise break up of Seller Revenue- Tech Products only
select 
pt. product_category_name_english,
round(sum(oi.price),0) as Product_Price,
round(sum(oi.freight_value),0) as Shipping_Cost,
round(sum(oi.price + oi.freight_value),0) as Seller_Revenue
from order_items oi
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%"
group by pt.product_category_name_english;



-- #################################################
-- ##2.2.4 Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
-- #################################################

#Swayam
select 
round((sum(oi.price + oi.freight_value))/ count(distinct date_format(o.order_purchase_timestamp, '%Y-%m')),0) as Monthly_Seller_Revenue,

(select 
round(sum(oi.price + oi.freight_value)/ count(distinct date_format(o.order_purchase_timestamp, '%Y-%m')),0) 
from order_items oi
left join orders o using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where o.order_status = "delivered"
and 
(pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%")
)as Monthly_Tech_Seller_Revenue

from order_items oi
left join orders o using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where o.order_status = "delivered"
;       


/*
#################################################
2.3. In relation to the delivery time:
==================================
-2.3.1 What’s the average time between the order being placed and the product being delivered?
-2.3.2 How many orders are delivered on time vs orders delivered with a delay?
-2.3.3 Is there any pattern for delayed orders, e.g. big products being delayed more often?
*/

-- #################################################
-- ##2.3.1 (Swayam) What’s the average time between the order being placed and the product being delivered?
-- #################################################
#2.3.1: What’s the average time between the order being placed and the product being delivered?

select 

pt.product_category_name_english,
round(Avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)),0) as Avg_Delivery_TAT
from orders o
left join order_items oi using (order_id)
left join products p using (product_id)
left join product_category_name_translation pt using (product_category_name)
where order_status= "delivered"
and 
(pt.product_category_name_english like "%computer%"
or pt.product_category_name_english like "%tech%"
or pt.product_category_name_english like "%audio%"
or pt.product_category_name_english like "telephony%"
or pt.product_category_name_english like "%electronics%"
or pt.product_category_name_english like "%game%"
or pt.product_category_name_english like "%mobile%"
or pt.product_category_name_english like "%tablet%"
or pt.product_category_name_english like "%camera%")
group by pt.product_category_name_english
order by Avg_Delivery_TAT desc;






-- #################################################
-- ##2.3.2 How many orders are delivered on time vs orders delivered with a delay?
-- #################################################
	
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

-- ##WRONG: aliases like delivery_status aren't available in the GROUP BY (they don't exist yet) so you either have to repeat CASE twice or use a subquery
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

-- #do subquery method
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




-- #################################################
-- #-2.3.3 Is there any pattern for delayed orders, e.g. big products being delayed more often?
-- #################################################

-- #Justin
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

-- ##Swayam

with order_level_data as
(
select distinct
o.order_id,
pt.product_category_name_english,
o.order_delivered_customer_date,
o.order_estimated_delivery_date
from orders o
join order_items oi using (order_id)
join products p using (product_id)
join product_category_name_translation pt using (product_category_name)
where o.order_status= "delivered"
and o.order_delivered_customer_date is not null
and o.order_estimated_delivery_date is not null
)

select product_category_name_english,
count(order_id) as Total_Orders,
sum( case when order_delivered_customer_date <= order_estimated_delivery_date then 1
          else 0
          end) as On_Time_Delivery,
sum( case when order_delivered_customer_date > order_estimated_delivery_date then 1
          else 0
          end) as Delayed_Delivery,
round(((100*sum( case when order_delivered_customer_date <= order_estimated_delivery_date then 1
          else 0
          end))/count(order_id)),0) as On_Time_Percentage,
round(((100*sum( case when order_delivered_customer_date > order_estimated_delivery_date then 1
          else 0
          end))/count(order_id)),0) as Delayed_Percentage

from order_level_data
#where product_category_name_english like "%computer%"
#or product_category_name_english like "%tech%"
#or product_category_name_english like "%audio%"
#or product_category_name_english like "telephony%"
#or product_category_name_english like "%electronics%"
#or product_category_name_english like "%game%"
#or product_category_name_english like "%mobile%"
#or product_category_name_english like "%tablet%"
#or product_category_name_english like "%camera%"
group by product_category_name_english
order by Delayed_Percentage desc;



-- ==========================END DOCUMENT==================================

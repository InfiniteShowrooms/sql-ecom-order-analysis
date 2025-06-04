# SQL E-Commerce Order Analysis

This project transforms raw e-commerce order data into a cleaner, more manageable format for business analysis. It includes SQL logic to build rollup tables and business-focused queries, along with a PDF presentation outlining the insights.

## 🛠 How It Works

The main SQL file processes the source tables to generate three core rollup tables, each building on the last:

1. **`rollup_01_ordered_products_details_w_seller`**  
   Combines raw order items with seller and product metadata.

2. **`rollup_A2_orders_single_line`**  
   Aggregates orders to one row per purchase, with delivery and status logic.

3. **`rollup_A3_customers_ltv`**  
   Calculates customer-level lifetime value (LTV) and summarization metrics.

These rollup tables act as a foundation for the individual business analysis queries found in the other SQL scripts.

## 📊 Presentation

A PDF presentation summarizing key findings is included in the `/Magist-case-study` subfolder.

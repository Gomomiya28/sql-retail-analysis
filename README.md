# Brazilian E-Commerce Retail Analysis — SQL Portfolio Project

# Project Overview

This project is an end-to-end SQL analysis of a real-world Brazilian e-commerce dataset provided by Olist, one of Brazil's largest online marketplaces. The goal here was to analyse business performance across revenue, delivery logistics, customer behaviour, and payment methods — answering key business questions a data analyst would be expected to tackle in a junior role.

The project was built entirely using **PostgreSQL** and pgAdmin 4, using only SQL to extract, clean, join, and analyse data across multiple related tables.

---

# Dataset

**Source from Kaggle:** [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains real anonymised retail data from 2016 to 2018 and consists of multiple CSV files covering orders, customers, products, payments, and sellers.

**Tables used in this project:**

| Table       |     Description         |        Records      |
|---|---|---|
| `customers` | Customer location and ID information | 99,441 |
| `orders` | Order status and timestamps | 99,441 |
| `order_items` | Products purchased per order | 112,650 |
| `products` | Product category and dimensions | 32,951 |
| `payments` | Payment method and value per order | 103,886 |

---

# Tools & Technologies

- **PostgreSQL 18** — Database engine
- **pgAdmin 4** — Database GUI and query tool
- **GitHub** — Version control and project hosting

---

# Database Schema

The five tables are related through shared key columns forming a star-like schema:

```
customers ──── orders ──── order_items ──── products
                  │
               payments
```

- `customers.customer_id` → `orders.customer_id`
- `orders.order_id` → `order_items.order_id`
- `order_items.product_id` → `products.product_id`
- `orders.order_id` → `payments.order_id`

---

# Business Questions that are Answered

1. How many records exist across each table?
2. What is the total revenue generated across the entire dataset?
3. Which months experience the highest order volumes?
4. Which product categories generate the highest revenue?
5. Which states have the longest average delivery times?
6. Which individual orders had the longest delivery delays?
7. Which customers generate the most revenue?
8. What are the most popular payment methods?
9. What percentage of orders were delivered on time overall?
10. Which states have the lowest on-time delivery rates?
11. How do individual order delivery times compare to their state average?

---

# Key Findings

# Revenue:
- **Total revenue generated: R$16,008,872.12** across the entire dataset
- The product category **telefonia_fixa (fixed telephony)** produced the single highest payment value at **R$13,664.08**
- The same customer responsible for the highest product payment was also identified as the highest spending customer overall, confirming a direct correlation between high-value product categories and high-value customers

# Order Trends
- Orders follow a clear **seasonal pattern** — increasing from January through to May, dipping briefly, then spiking again in July and August.
- **May** spikes are driven by **Mother's Day**, one of Brazil's biggest commercial holidays.
- **July** spikes align with Brazil's **winter school holiday season**.
- **August** spikes are driven by **Father's Day (Dia dos Pais)**, celebrated on the second Sunday of August in Brazil.
- This pattern indicates Olist's revenue is heavily **event-driven** rather than reflecting consistent organic growth.
- 2016 data does not have as many orders placed, with some months showing as few as 1 order — consistent with Olist having launched mid-2016.

# Delivery Performance
- The **overall on-time delivery rate is 90.8%** — a strong performance for a marketplace operating across a country the size of Brazil.
- **State RR (Roraima)** has the longest average delivery time at **29 days**.
- **State SP (São Paulo)** has the shortest average delivery time at **8 days** — reflecting its proximity to major distribution centres.
- **State AL (Alagoas)** has the lowest on-time delivery percentage, identified as the primary contributor pulling the overall 90.8% rate down.
- The worst individual delivery delay recorded was **209 days** in State ES (Espírito Santo)
- The geographic pattern is consistent — remote northern states consistently underperform on delivery stats, strongly suggesting **logistics infrastructure** as the     root cause rather than data quality issues.

# Payment Methods
- **Credit card** is by far the most popular payment method across all transactions.
- The `not_defined` payment type was excluded from analysis as it does not represent a real payment method.

---

# SQL Concepts Demonstrated

| Concept | Where Used |
|---|---|
| `CREATE TABLE` with data types and primary keys | Database setup |
| `JOIN` across multiple tables (up to 5 tables) | Revenue and delivery queries |
| `GROUP BY` and aggregate functions | All summary queries |
| `HAVING` for post-aggregation filtering | Product category revenue query |
| Subqueries in SELECT | Table record count query |
| `DATE_TRUNC` and `EXTRACT` for date analysis | Monthly order trends |
| `CASE WHEN` for conditional aggregation | On-time delivery percentage |
| `WINDOW FUNCTIONS` with `PARTITION BY` | Delivery days vs state average |
| `RANK()` window function | Ranking orders within states |
| `ROUND` and `::NUMERIC` casting | All monetary and percentage outputs |
| `IS NOT NULL` filtering | Delivery date queries |

---

# Project Structure

```
sql-retail-analysis/
│
├── README.md               # Project overview and findings (this file)
└── retail_analysis.sql     # All SQL scripts — table creation, data validation, and analysis queries
```

---

# How to Reproduce / View This Project (Especially if you're unfamilair with how to do so. Step by step guide below!)

1. Install [PostgreSQL](https://www.postgresql.org/download/) and pgAdmin 4
2. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
3. Create a new database called `olist_retail` in pgAdmin
4. Run the `CREATE TABLE` statements at the top of `retail_analysis.sql`
5. Import each CSV file into its corresponding table using pgAdmin's Import/Export tool
6. Run the analysis queries in order

---

# Author: Gomolemo Miya

I built this as a portfolio project following completion of the **DataCamp Associate Data Analyst in SQL** career track, combined with foundational database knowledge from the **Microsoft DP-900** certification I completed in March 2026 . This is a beginner level project to showcase my skills and had some assistance from Claude.AI and Reddit for guidance to help me write up this README as I have never created one before. Hope your enjoyed viewing this project!

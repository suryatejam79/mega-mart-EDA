# 🛒 Mega Mart SQL Exploratory Data Analysis (EDA)

**Author:** Surya Teja Mukka  
**Tools Used:** MySQL  
**Domain:** Retail / Superstore Sales  
**Dataset:** Mega Mart (Simulated Superstore Transaction Data)  
**Purpose:** Clean and analyze transactional data to answer stakeholder-driven business questions using SQL.

---

## 🔍 Project Objectives

This project focuses on building a **strong exploratory data analysis (EDA)** framework using **only SQL**, converting raw transaction data into actionable insights.  

This is a big step for any data analyst — taking real input from stakeholders and transforming it into measurable outcomes using KPIs.

---

## 🧹 Data Cleaning Steps

- ✅ Created a backup table (`mega_mart_safety`)
- ✅ Removed duplicate `order id` entries
- ✅ Trimmed customer name spaces
- ✅ Standardized mixed date formats (`order date` and `ship date`)
- ✅ Converted dates to proper `DATE` type
- ✅ Dropped irrelevant columns:
  - `row id`, `segment`, `district`, `country`, `postal code`, `product id`

---

## 📈 KPIs Used Throughout

| KPI                 | Description                                 |
|---------------------|---------------------------------------------|
| `Total_Revenue`     | Total revenue generated                     |
| `Total_Orders`      | Count of all transactions                   |
| `Profit_Margin`     | Ratio of profit to sales (%)                |
| `Quantity_per_Order`| Average quantity sold per order             |
| `Average_Delivery`  | Average shipping duration (days)            |

---

## 📊 Stakeholder Questions & SQL Solutions

### 1. 🧾 Repeat Purchase Behavior of Customers

**Insight:** Repeat buyers account for ~60% of sales and 70% of profit.  
One-time buyers have lower profit margins and churn quickly.

### 2. 🚚 Shipping Mode Analysis

**Insight:** `Standard Class` shipping has the highest delivery delays.  
`First` and `Second Class` modes yield better margins and timely delivery.

### 3. 💰 Top 1% Revenue Customers

**Insight:** Top 1% customers contribute ~35% of total revenue.  
They mostly purchase high-value items in `Office Supplies` and `Technology`.

### 4. 📆 Year-over-Year Sales Performance

**Insight:** Strong YOY growth in early 2000s; sharp declines in 2011  
(e.g., Jan 2011 dropped 67.61% vs Jan 2010).

### 5. 📉 High Volume but Negative Profit Products

**Insight:** Several products with sales > ₹10,000 still have negative profit margins.  
Action needed to reassess pricing/discount strategy.

### 6. 🧮 Discount Elasticity of Profit

**Insight:** Discounts above 20% lead to steep margin drops (>30%).  
Optimal discount range = 0–10%.

### 7. 🌍 Regional Sales Penetration

**Insight:** Regions like **North** and **Central** show high profit-per-customer  
but low total customers — opportunity for targeted growth.

---

## ✅ Final KPI Snapshot (Post-EDA)

| Metric               | Value         |
|----------------------|---------------|
| Total Orders         | 131483        |
| Total Revenue        | ₹30728k       |
| Avg Quantity/Order   | 4             |
| Avg Delivery Time    | 3 days        |
| Profit Margin        | 12.1%         |



---

## 💬 Let's Connect

Want to discuss this project or have feedback?  
Feel free to connect with me on LinkedIn:  
**[Surya Teja Mukka](https://www.linkedin.com/in/surya-teja-mukka/)**




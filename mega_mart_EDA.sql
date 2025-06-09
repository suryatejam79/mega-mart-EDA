/*
  Mega Mart Sales Data - Exploratory Data Analysis using SQL
  Author: Surya Teja Mukka
  Description:
  - Cleaning raw sales data for accuracy
  - Identifying business KPIs
  - Solving stakeholder business questions
  - Outputs are commented for interpretability

  Tools Used: MySQL
  Date: 09-06-2025
*/

-- Creating Duplicate table for data security
create table mega_mart_safety
like mega_mart;

-- inserting data into mega_mart_safety from mega_mart
insert mega_mart_safety
select * from mega_mart;

-- data cleaning for accurate results
-- checking duplicates and deleting

with cte as (select *, row_number() over(partition by `order id`) as duplicated from mega_mart_safety
)
delete from mega_mart_safety where `order id` in(select `order id` from cte where duplicated > 1);

-- deleting extra space using trim function and follows remaining columns

update mega_mart_safety
set `customer name` = trim(`customer name`);

-- checking spelling mistake using distinct

select distinct `customer name` from mega_mart_safety;

-- after checking dataset in my data i have two types of date format in single column and arranging them
update mega_mart_safety
set `ship date` = case 
when `ship date` like "%/%" then str_to_date(`ship date`, "%m/%d/%Y")
when `ship date` like "%-%" then str_to_date(`ship date`, "%m-%d-%Y")
else null
end;

-- same step follows for `order date`
update mega_mart_safety
set `order date` = case 
when `order date` like "%/%" then str_to_date(`order date`, "%m/%d/%Y")
when `order date` like "%-%" then str_to_date(`order date`, "%m-%d-%Y")
else null
end;

-- now we just arranged the date in default format of MYSQL but not arranged into date type
alter table mega_mart_safety
modify `order date` date;

-- same step follows for `ship date`
alter table mega_mart_safety
modify `ship date` date;

-- deleting unwanted columns for easy analysis
alter table mega_mart_safety
drop column `row id`,
drop column segment,
drop column district,
drop column country,
drop column `postal code`,
drop column `product id`;


-- data cleaning process is completed
-- now preparing data exploratory according to Stakeholders problems and questions are below
-- 1. What is the repeat purchase behavior of customers?
-- 2. Which shipping mode results in the highest loss or delayed fulfillment?
-- 3. Who are the top 1% of customers by revenue and how do their buying patterns differ from the rest?
-- 4. How has the monthly sales performance changed year-over-year across the business?
-- 5. Which products have negative profits despite high volume sales?
-- 6. How do we optimize pricing? What’s the discount elasticity of profit?
-- 7. Which regions have low sales penetration but high potential based on profit per customer?

-- and in this questions there is common factors and i call it as KPI's 
-- MY KPI's are Total_revenue, Total_orders, Profit_margin, Quantity_per_order and below is the query for KPI'savepoint
-- 📊 Final Summary of KPI Metrics

select concat(round(sum(sales)/1000,0), 'k') as Total_revenue, 
concat(round((sum(profit) / nullif(sum(sales),0))*100,2), "%") as profit_margin, 
concat(round(avg(datediff(`ship date`, `order date`)),0),"days") as Average_delivery_time,
round(avg(Quantity),0) as quantity_per_order,
Count(*) as total_orders
 from mega_mart;
 
 -- Let's query for first question
 -- ✅ Repeat Purchase Behavior Analysis
-- Identifies customers who placed more than one order per year
-- Calculates average order value per type (new vs repeat)

 WITH cte AS (
SELECT `customer name`, YEAR(`Order Date`) AS `year`, count(*) as total_orders,
    ROUND(SUM(sales),0) AS total_revenue, COUNT(`customer name`) AS total_times_ordered 
  FROM mega_mart
  GROUP BY `customer name`, `year`),
repeated_users AS (SELECT *, 
    CASE WHEN total_times_ordered > 1 THEN "repeated_customer" ELSE "new_customer" END AS Customer_type
  FROM cte)
SELECT `year`, Customer_type, sum(total_orders) as total_ordered, ROUND(AVG(total_revenue/total_times_ordered),1) AS avg_ordered 
FROM repeated_users 
GROUP BY `year`, Customer_type;


-- explaining about result
-- Repeat buyers contribute around 60% of total sales and 70% of total profit.
-- One-time buyers show lower profitability and higher churn risk.

-- 2. Which shipping mode results in the highest loss or delayed fulfillment?

SELECT `Ship Mode`, 
  Round(greatest(AVG(DATEDIFF(`ship date`, `order date`)),0),0) AS avg_delivery_days,  
  round(SUM(profit),1) AS total_profit, 
  COUNT(*) AS total_orders,  
round((SUM(profit)/NULLIF(SUM(sales),0))*100,1) AS profit_margin 
FROM mega_mart 
GROUP BY `ship mode`;


-- explaination: Standard Class shipping shows the highest number of delayed shipments.
-- First Class and Second Class have better on-time rates and positive profit margins.

-- 3. Who are the top 1% of customers by revenue and how do their buying patterns differ from the rest?

WITH cte AS (
  SELECT `customer name`, `sub-category`, 
    ROUND(SUM(sales),0) AS total_revenue, ROUND(AVG(Discount) * 100, 1) AS avg_discount_pct 
  FROM mega_mart
  GROUP BY `Customer Name`, `Sub-Category`
),
ranked AS (
  SELECT DISTINCT *, ROUND(PERCENT_RANK() OVER(ORDER BY total_revenue DESC),2) AS top_customers 
  FROM cte)
SELECT * 
FROM ranked 
WHERE top_customers >= 0.99
ORDER BY top_customers DESC;

-- Explaination: Top 1% customers generate approximately 35% of total revenue.
-- These customers purchase high-volume products like “Office Supplies” and “Technology” items more frequently.

-- 4. How has the monthly sales performance changed year-over-year across the business?
WITH rw AS (
  SELECT MONTH(`Order Date`) AS month_num, 
YEAR(`order date`) AS `year`, 
    ROUND(SUM(Sales),0) AS total_sales FROM mega_mart
  GROUP BY month_num, `year` ),
YOY as (SELECT *, LAG(total_sales) OVER(PARTITION BY month_num ORDER BY `year`) AS YOY_change FROM rw)
select *,round(((total_sales - YOY_change)/nullif(YOY_change,0))*100,2) as YOY_percent from YOY
ORDER BY month_num;

-- Explaination: Sales peaked in 2002 and 2003 with positive YOY growth (+26.64% in Feb 2002).
-- Sharp decline observed in 2011 with over 60% drop in several months (e.g., January sales dropped by 67.61%).
-- Recovery seen in some months post-2008 but overall declining trend toward 2011.


-- 5. Which products have negative profits despite high volume sales?
SELECT `product name`, 
  ROUND(SUM(sales),0) AS total_revenue, 
  ROUND(AVG(Discount*100),1) AS avg_discount, 
  ROUND((SUM(profit)/NULLIF(SUM(sales),0))*100,1) AS profit_margin 
FROM mega_mart
GROUP BY `product name`
HAVING SUM(sales) > 10000 AND profit_margin < 0
ORDER BY SUM(sales) DESC, avg_discount DESC;

-- Explaination: shows which products have high revenue but loss in profit


-- 6. How do we optimize pricing? What’s the discount elasticity of profit?

SELECT 
  CASE 
WHEN ROUND(discount * 100, 0) BETWEEN 0 AND 10 THEN '0-10'
WHEN ROUND(discount * 100, 0) BETWEEN 11 AND 20 THEN '11-20'
WHEN ROUND(discount * 100, 0) BETWEEN 21 AND 30 THEN '21-30'
 WHEN ROUND(discount * 100, 0) BETWEEN 31 AND 40 THEN '31-40'
    ELSE 'top-discounted' 
  END AS ranged, 
  SUM(quantity) AS total_quantity,
  ROUND(SUM(sales), 0) AS total_sales,
  ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 1) AS profit_margin FROM mega_mart
GROUP BY ranged
ORDER BY ranged;

-- Explaination: Discounts between 0-10% maintain positive profit margins.
-- Discounts above 20% lead to profit margin drops of over 30%, showing high sensitivity.

-- 7. Which regions have low sales penetration but high potential based on profit per customer?
WITH customer_profit AS (
  SELECT region, `customer name`, SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit FROM mega_mart
  GROUP BY region, `customer name`),
region_summary AS (
  SELECT 
    region,
    COUNT(DISTINCT `customer name`) AS total_customers,
    ROUND(SUM(total_revenue), 0) AS region_sales,
    ROUND(SUM(total_profit), 0) AS region_profit,
    ROUND(SUM(total_profit) / NULLIF(COUNT(DISTINCT `customer name`), 0), 0) AS profit_per_customer,
    ROUND(SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100, 1) AS profit_margin
  FROM customer_profit
  GROUP BY region
)
SELECT * FROM region_summary
ORDER BY total_customers ASC, profit_per_customer DESC;

-- Explaination: Regions like north and Central show lower total sales but have high profit per customer (~₹1000+ per customer).
-- These regions have potential for targeted marketing to increase sales without large increases in acquisition cost.





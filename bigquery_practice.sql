--LEVEL 1--

--(1)what is the earliest year of purchase? 
--2011
select year from prework.sales
ORDER BY year
LIMIT 1;

SELECT min(year) as earliest_year 
  from prework.sales

--(2)What is the average customer age per year? Order the years in ascending order.
-- 2011 (34.251774374299593)
--2012 (34.251774374299593)
--2013 (35.2289408010474)
--2014 (36.6449758486973)
--2015 (35.2289408010474)
--2016 (36.64497584869)
SELECT year, AVG(customer_age) as avg_age 
  FROM prework.sales
GROUP BY Year
ORDER BY Year;

--(3)Return all clothing purchases from September 2015 where the cost was at least $70.
-- 553 results 
SELECT * FROM prework.sales
WHERE Year = 2015
  AND Month = 'September'
  AND Cost >= 70 
  AND Product_Category = 'Clothing';

--(4)What are all the different types of product categories that were sold from 2014 to 2016 in France?
--UNSURE ABOUT ANSWER - just returns all possible categories in the schema 
SELECT DISTINCT Sub_Category FROM prework.sales 
WHERE Year IN (2014,2015,2016)
  AND Country = 'France'
ORDER BY 1

--(5)Within each product category and age group (combined), what is the average order quantity and total profit?
SELECT Product_Category, Age_Group, AVG(ORDER_Quantity) Avg_Qty, SUM(Profit) total_profit
  FROM prework.sales
GROUP BY 1, 2

--LEVEL 2--

--(1)Which product category has the highest number of orders among 31-year olds? Return only the top product category.
-- Accessories 
SELECT Product_Category, COUNT(*), Customer_Age 
FROM prework.sales 
WHERE Customer_Age = 31
GROUP BY 1,3
ORDER BY 2 DESC

--(2)Of female customers in the U.S. who purchased bike-related products in 2015, what was the average revenue?
--2610.20
SELECT AVG(Revenue)
FROM prework.sales 
WHERE Customer_Gender = 'F'
AND Product_Category = 'Bikes' 
AND Year = 2015

--(3)



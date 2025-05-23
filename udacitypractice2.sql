-----SUBQUERIES-----

--Find the average number of events daily, by channel.
--first write a query that shows the count of events, by day, for each channel. 
--then write a query that uses the first subquery and then finds the average of the daily counts

  SELECT channel, AVG(events_daily)
  FROM (
    SELECT DATE_TRUNC('day',occurred_at), channel, 
           COUNT(*) events_daily
    FROM web_events
    GROUP BY 1, 2
    ORDER BY 3 DESC
   ) sub
   GROUP BY channel

--Find the avg for each paper quantity for just the first month of sales
-- first write a query that gives the earliest month of sales
-- then write a query that shows the averages, and filters on this first subquery 
    
  SELECT DATE_TRUNC('month',occurred_at),
         AVG(standard_qty) as avg_standard_qty,
         AVG(gloss_qty) as avg_gloss_qty,
         AVG(poster_qty) as avg_poster_qty
    FROM orders
    WHERE DATE_TRUNC('month',occurred_at) = 
      (SELECT DATE_TRUNC('month',MIN(occurred_at))
       FROM orders) 
   GROUP BY 1

-----SUBQUERIES AND WITH AS------

--Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
--first create a view of the sales reps in each region and each of their total sales. 
    --then a table to show just the max sales for each region (no sales rep name)
    --then join these two tables to view everything together

    -- 1) USING SUBQUERY--
  SELECT t2.region as region, t3.sales_rep as salesrep, t2.max_sales
    FROM(
    SELECT region, max(total) as max_sales
      FROM(
      SELECT R.name as region, S.name as sales_rep, SUM(total_amt_usd)as total
      FROM orders O
      JOIN accounts A
      ON O.account_id = A.id
      JOIN sales_reps S
      ON A.sales_rep_id = S.id
      JOIN region R
      ON S.region_id = R.id
      GROUP BY 1,2) t1
    GROUP BY region) t2
    
  JOIN (
    SELECT R.name as region, S.name as sales_rep, SUM(total_amt_usd)as total
    FROM orders O
    JOIN accounts A
    ON O.account_id = A.id
    JOIN sales_reps S
    ON A.sales_rep_id = S.id
    JOIN region R
    ON S.region_id = R.id
    GROUP BY 1,2) t3
  
  ON t3.region = t2.region AND
     t2.max_sales = t3.total


  --2) USING CTE--

    WITH t1 AS (SELECT S.id, S.name sales_rep, R.name region, SUM(O.total_amt_usd) totalsale
                     FROM sales_reps S
                     JOIN accounts A
                     ON S.id = A.sales_rep_id
                     JOIN orders O 
                     ON O.account_id = A.id
                     JOIN region R
                     ON R.id = S.region_id
                     GROUP BY 1,2),
              
      t2 AS (SELECT region, MAX(totalsale) totalsale
                     FROM t1
                     GROUP BY 1

    SELECT t2.region, t1.sales_rep, t2.totalsale
    FROM t1
    JOIN t2
    ON t1.region = t2.region AND t1.totalsale = t2.totalsale


--For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
--first figure out the region 
    
   --1)USING SUBQUERY---
      SELECT t1.region, t2.order_ct
      FROM 
          (SELECT R.name region, SUM(O.total_amt_usd) total_sales
          FROM orders O
              JOIN accounts A
              ON O.account_id = A.id
              JOIN sales_reps S
              ON A.sales_rep_id = S.id
              JOIN region R
              ON S.region_id = R.id
          GROUP BY region
          ORDER BY total_sales DESC
          LIMIT 1) t1 --region with max sales
      JOIN 
          (SELECT R.name region, COUNT(*) order_ct
          FROM orders O
              JOIN accounts A
              ON O.account_id = A.id
              JOIN sales_reps S
              ON A.sales_rep_id = S.id
              JOIN region R
              ON S.region_id = R.id
            GROUP BY region) t2 --regional order counts
      ON t1.region = t2.region

    --2)USING CTE---

    WITH t1 AS (
                SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON o.account_id = a.id
                JOIN region r
                ON r.id = s.region_id
                GROUP BY r.name), 
        t2 AS (
              SELECT MAX(total_amt)
              FROM t1)
    SELECT r.name, COUNT(o.total) total_orders
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY r.name
    HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

--OR--
      SELECT R.name as region, SUM(O.total_amt_usd) as reg_total, COUNT(*) as total_orders
                  FROM region R
                  JOIN sales_reps S
                  ON R.id = S.region_id 
                  JOIN accounts A
                  ON A.sales_rep_id = S.id
                  JOIN orders O
                  ON O.account_id = A.id
                  GROUP BY 1
                  ORDER BY 2 DESC
                  LIMIT 1
                              
--How many accounts had more total purchases than the account name which has bought the most 
--standard_qty paper throughout their lifetime as a customer?

 ---1)USING SUBQUERY---
        SELECT COUNT(*)
        FROM 
          (SELECT A.name account, SUM(O.total) as total_purchases
          FROM accounts A
          JOIN orders O
          ON A.id = O.account_id 
            GROUP BY 1
            HAVING SUM(O.total) > (SELECT total_qty
                                 FROM(
                                    SELECT A.name account, SUM(O.standard_qty) as total_std_qty, SUM(O.total) as total_qty
                                    FROM accounts A
                                    JOIN orders O
                                    ON A.id = O.account_id 
                                    GROUP BY 1
                                    ORDER BY 2 DESC
                                    LIMIT 1)))


---2) USING CTE ---
        WITH t1 AS (SELECT A.name, SUM(O.standard_qty) std_paper, SUM(O.total) total
                FROM accounts A
                JOIN orders O
                ON A.id = O.account_id
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1),
        t2 AS (SELECT A.name
              FROM accounts A
              JOIN orders O
              ON A.id = O.account_id 
              GROUP BY 1
              HAVING SUM(O.total) > (SELECT total FROM t1) )
    
        SELECT COUNT(*)
            FROM t2

--get the total purchase count for the account that had the highest std qty orders

      SELECT total_qty
      FROM(SELECT account
           FROM(
            SELECT A.name account, SUM(O.standard_qty) total_std_qty, SUM(O.total) as total_qty
            FROM accounts A
            JOIN orders O
            ON A.id = O.account_id 
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1))

--For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
--how many web_events did they have for each channel?

--- 1) USING SUBQUERY---
-- 1) first find which customer spent the most
      SELECT customer
        FROM(
              SELECT A.name customer, SUM(O.total_amt_usd) 
              FROM accounts A
              JOIN orders O
              ON A.id = O.account_id
              GROUP BY 1
              ORDER BY 2 DESC)
        LIMIT 1
-- 2) use first query in this one, and then find count of webevents grouped by channel

       SELECT W.channel, COUNT(*)  
        FROM web_events W
        JOIN accounts A
        ON W.account_id = A.id
        WHERE A.name = 
              ( SELECT customer
                FROM(
                    SELECT A.name customer, SUM(O.total_amt_usd) 
                    FROM accounts A
                    JOIN orders O
                    ON A.id = O.account_id
                    GROUP BY 1
                    ORDER BY 2 DESC)
                LIMIT 1)
        GROUP BY W.channel


  ---2) USING CTE ---
        WITH t1 AS (SELECT A.name, SUM(O.total_amt_usd) as totalspent
                FROM accounts A
                JOIN orders O 
                ON A.id = O.account_id 
                GROUP BY 1
                ORDER BY 2 DESC
                LIMIT 1)

          SELECT A.name, W.channel, COUNT(*)
          FROM web_events W
          JOIN accounts A
          ON W.account_id = A.id AND A.name = (SELECT name FROM t1)
          GROUP BY 1,2



--What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

---1) USING SUBQUERY ---
--1) find the top ten accounts 

      SELECT A.name, SUM(O.total_amt_usd)
      FROM accounts A
      JOIN orders O
      ON A.id = O.account_id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10

--2) find the avg of these 10 spending amounts

      SELECT AVG(total_spent)
      FROM(
        SELECT A.name, SUM(O.total_amt_usd) total_spent
        FROM accounts A
        JOIN orders O
        ON A.id = O.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10)
        
--3) if they asked what the average amount spent per order, for those ten accounts: 
        
      SELECT A.name account, AVG(O.total_amt_usd) avg_spent
      FROM accounts A
      JOIN orders O
      ON A.id = O.account_id 
      JOIN  (SELECT A.name account, SUM(O.total_amt_usd)
            FROM accounts A
            JOIN orders O
            ON A.id = O.account_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10) t1
      ON t1.account = A.name
      GROUP BY 1
      ORDER BY 2 DESC

  ---2) USING CTE ---
        WITH t1 AS (SELECT A.name, SUM(O.total_amt_usd) total 
                FROM accounts A
                JOIN orders O 
                ON A.id = O.account_id 
                GROUP BY A.name 
                ORDER BY 2 DESC
                LIMIT 10)
    SELECT AVG(total)
    FROM t1



--What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that 
--spent more per order, on average, than the average of all orders.

--- 1) USING SUBQUERY ---
        
--1) find the average of all the orders
--2) find the companies whose average per-order amount is greaer than this average 
--3) then find the average of those averages for just these companies 

SELECT AVG(avg_order)
  FROM(
  SELECT A.name, AVG(total_amt_usd) as avg_order
                  FROM accounts A
                  JOIN orders O
                  ON A.id = O.account_id
                  GROUP BY A.name
                  HAVING AVG(total_amt_usd) > (SELECT AVG(total_amt_usd)
                                               FROM orders) ) 

--if it was finding the average lifetime spending amount among those companies (as opposed to per-order avg), then this >

  SELECT AVG(total_spent)
FROM (
  SELECT A.name, SUM(O.total_amt_usd)
  FROM accounts A
  JOIN orders O 
  ON A.id = O.account_id
  WHERE A.name IN (SELECT A.name
                  FROM accounts A
                  JOIN orders O
                  ON A.id = O.account_id
                  GROUP BY A.name
                  HAVING AVG(total_amt_usd) > (SELECT AVG(total_amt_usd)
                                               FROM orders) ) 
   GROUP BY A.name)


---2) USING CTE ---
        
 WITH t1 AS (SELECT AVG(O.total_amt_usd) avg_order
                FROM orders O
                JOIN accounts A
                ON O.account_id = A.id),
        t2 AS (SELECT account_id, AVG(total_amt_usd) avg_order
                FROM orders  
                GROUP BY 1
                HAVING AVG(total_amt_usd) > (SELECT * FROM t1))
     SELECT AVG(avg_order)
      FROM t2


    















   

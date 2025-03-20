------BASICS------

--displays only the top 15 rows (limit function ALWAYS COMES LAST)
       SELECT occurred_at, account_id, channel
       FROM web_events
       LIMIT 15;

--comparison between tables based on order of columns that are sorted
       SELECT id, account_id, total_amt_usd
       FROM orders
       ORDER BY account_id, total_amt_usd DESC;
       
       SELECT id, account_id, total_amt_usd
       FROM orders
       ORDER BY total_amt_usd DESC, account_id;
       --the first one groups them by account ID and shows a list of items from most to least expensive
       --the second one gives the account ID for each item when the items are listed from most to least expensive. shows you which accounts have the most expensive items.

--derived columns using math operators: makes calculations for multiple entire columns, use PEMDAS
       SELECT id, account_id, standard_amt_usd/standard_qty AS unit_price
       FROM orders
       LIMIT 10;
       
       SELECT id, account_id, 
              poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
       FROM orders
       LIMIT 10;

--IN operator: easier way to include several criteria options rather than use OR multiple times 
       SELECT name, primary_poc, sales_rep_id 
       FROM accounts
       WHERE name IN ('Walmart', 'Target', 'Nordstrom');
       
       SELECT *
       FROM web_events
       WHERE channel IN ('organic','adwords');

--between operator includes the end values in the table results 
       SELECT occurred_at, gloss_qty
       FROM orders
       WHERE gloss_qty BETWEEN 24 AND 29;

--between operator for dates: assumes the timestamp is at midnight (00:00:00) 
       SELECT *
       FROM web_events 
       WHERE channel IN ('organic','adwords')
       AND occurred_at BETWEEN '2016-01-01' and '2017-01-01' 
       --returns results for anything in 2016 

--multiple criteria
       SELECT name, primary_poc
       FROM accounts
       WHERE name LIKE 'C%' OR name LIKE 'W%'
       AND (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
       AND (primary_poc NOT LIKE '%eana%');

------JOINS------

-- data lives differently in tables (ie. some tables are updated more regularly, compared with some tables that just capture info like order details)
-- data normalization is essential - 
       -- arranging data into logical groupings such that each group describes a small part of the whole; 
       --minimizing the amount of duplicate data stored in a database
       --organizing the data such that, when you modify it, you make the change in only one place
-- INNER JOIN: pulls only the rows for which the ON clause is true (the middle of the Venn diagram)

-- inner joins combining info from orders table and company accounts table: 
-- shows each order and the associated company name and primary poc

       SELECT orders.standard_qty, 
              orders.gloss_qty, 
              orders.poster_qty, 
              accounts.website, 
              accounts.primary_poc
       FROM orders
       JOIN accounts
         ON orders.account_id = accounts.id

--primary key (PK): first column in most tables, unique identifiers for each row
--foreign key (FK): a column in a table that is linked to a primary key of a different table.
--FK usually shows up multiple times in its own table, but only once (as a PK) in another table.

------JOINS PROBLEMS------
       
--Provide a table for all web_events associated with account name of Walmart. 
--There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. 
-- Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
              
       SELECT t2.name,t2.primary_poc,t1.occurred_at,t1.channel
       FROM web_events as t1
       JOIN accounts as t2
       ON t1.account_id = t2.id
       WHERE t2.name = 'Walmart';

--Provide a table that provides the region for each sales_rep along with their associated accounts. 
--Your final table should include three columns: the region name, the sales rep name, and the account name. 
--Sort the accounts alphabetically (A-Z) according to account name.

       SELECT t1.name as rep, t2.name as region, t3.name as company
       FROM sales_reps as t1
       JOIN region as t2
       ON t1.region_id = t2.id
       JOIN accounts as t3
       ON t3.sales_rep_id = t1.id
       ORDER BY t3.name
              
--Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order.
--Your final table should have 3 columns: region name, account name, and unit price. 
--A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.     
              
       SELECT O.id as order_id, R.name AS region, A.name AS account, O.total_amt_usd/(O.total + 0.01) AS unit_price
       FROM orders as O
       JOIN accounts as A
       ON O.account_id = A.id
       JOIN sales_reps as S
       ON S.id = A.sales_rep_id
       JOIN region as R
       ON R.id = S.region_id

-----OTHER JOINS-----
              
--Provide a table that provides the region for each sales_rep along with their associated accounts. 
--This time only for the Midwest region. Your final table should include three columns: 
--the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.
              
       SELECT S.name Rep, R.name Region, A.name Account
       FROM sales_reps S
       LEFT JOIN region R
       ON S.region_id = R.id
       LEFT JOIN accounts A
       ON A.sales_rep_id= S.id
       WHERE R.name = 'Midwest'
       ORDER BY Account

--Same as above problem, but only show the reps with last name starting with K
              
       SELECT S.name Rep, R.name Region, A.name Account
       FROM sales_reps S
       LEFT JOIN region R
       ON S.region_id = R.id
       LEFT JOIN accounts A
       ON A.sales_rep_id= S.id
       WHERE R.name = 'Midwest' 
         AND S.name LIKE '% K%'
       ORDER BY Account;

--Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order.
--However, you should only provide the results if the standard order quantity exceeds 100. 
--Your final table should have 3 columns: region name, account name, and unit price. 
--In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).

       SELECT R.name as region, A.name as account, O.total_amt_usd/(total+0.01) as unit_price
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       JOIN sales_reps S
       ON A.sales_rep_id = S.id
       JOIN region R
       ON S.region_id = R.id
       WHERE standard_qty > 100;
--What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the different channels.
--You can try SELECT DISTINCT to narrow down the results to only the unique values.
       SELECT DISTINCT accounts.name, web_events.channel
       FROM accounts
       JOIN web_events
       ON accounts.id = web_events.account_id
       WHERE accounts.id = 1001

--Find all the orders that occurred in 2015. Your final table should have 4 columns: 
--occurred_at, account name, order total, and order total_amt_usd.
       SELECT O.occurred_at, A.name as account_name, O.total, total_amt_usd
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       WHERE O.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
       ORDER BY O.occurred_at

------AGGREGATIONS------

--Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.

       SELECT A.name, O.occurred_at
       FROM orders as O
       JOIN accounts as A
       ON O.account_id = A.id
       ORDER BY O.occurred_at 
       LIMIT 1;

--Find the total sales in usd for each account. 
--You should include two columns - the total sales for each company's orders in usd and the company name.

       SELECT A.name as company, SUM(O.total_amt_usd) as total_sales
       FROM accounts A
       JOIN orders O
       ON A.id = O.account_id
       GROUP BY company
       ORDER BY company;

--Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
--Your query should return only three values - the date, channel, and account name.
       SELECT W.occurred_at as date, W.channel as channel, 
              A.name as account 
       FROM web_events W
       JOIN accounts A
       ON W.account_id = A.id
       ORDER BY date DESC
       LIMIT 1;

--Find the total number of times each type of channel from the web_events was used. 
--Your final table should have two columns - the channel and the number of times the channel was used.    

       SELECT channel, COUNT(id) as num_used
       FROM web_events
       GROUP BY channel
       ORDER BY channel;

--Who was the primary contact associated with the earliest web_event?

       SELECT A.primary_poc 
       FROM accounts A
       JOIN web_events W
       ON A.id = W.account_id 
       ORDER BY W.occurred_at 
       LIMIT 1;

--What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.

       SELECT A.name as account, MIN(O.total_amt_usd) as smallest_order_amount
       FROM orders O
       JOIN accounts A
       ON A.id = O.account_id
       GROUP BY A.name
       ORDER BY smallest_order_amount;

--Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. 
--Order from fewest reps to most reps.

       SELECT R.name as region, COUNT(S.id)as num_reps
       FROM sales_reps S 
       JOIN region R
       ON S.region_id = R.id
       GROUP BY R.name
       ORDER BY num_reps

-----GROUP BY-----

--For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.

       SELECT A.name, AVG(O.standard_qty) as avg_std_qty,
              AVG(O.gloss_qty) as avg_gloss_qty,
              AVG(O.poster_qty) as avg_poster_qty
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       GROUP BY A.name;

--For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
       
       SELECT A.name, AVG(O.standard_amt_usd) as avg_std_amt,
              AVG(O.gloss_amt_usd) as avg_gloss_amt,
              AVG(O.poster_amt_usd) as avg_poster_amt
       FROM orders O
       JOIN accounts A
       ON A.id = O.account_id
       GROUP BY A.name;

--Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.

       SELECT S.name as sales_rep, W.channel, COUNT(W.*)
       --should this be W.* or W.channel?
       FROM web_events W
       JOIN accounts A
       ON W.account_id = A.id
       JOIN sales_reps S
       ON S.id = A.sales_rep_id
       GROUP BY W.channel, S.name
       ORDER BY sales_rep, count DESC;

--Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.

       SELECT R.name, W.channel, COUNT(W.channel) as num_channel_occurences
       FROM web_events W
       JOIN accounts A
       ON W.account_id = A.id
       JOIN sales_reps S
       ON S.id = A.sales_rep_id
       JOIN region R
       ON R.id = S.region_id
       GROUP BY W.channel, R.name
       ORDER BY R.name, num_channel_occurences DESC

-----DISTINCT-----

--Use DISTINCT to test if there are any accounts associated with more than one region.

       SELECT A.name as account, R.name as region
       FROM accounts A
       JOIN sales_reps S
       ON A.sales_rep_id = S.id
       JOIN region R
       ON S.region_id = R.id
       ORDER BY account;
       
       SELECT DISTINCT id, name
       FROM accounts
              
--use this second one to compare with first. if there was more than one region for each account, the first query would 
--return more rows than the second. 

--Have any sales reps worked on more than one account?

       SELECT S.name, COUNT(A.name) as num_accounts
       FROM sales_reps S
       JOIN accounts A
       ON S.id = A.sales_rep_id
       GROUP BY S.name
       
       SELECT id, name
       FROM sales_reps 


-----HAVING-----
--having is like where, but is used for aggregations. it comes after group by, but before order by

--How many of the sales reps have more than 5 accounts that they manage?

       SELECT S.id, S.name as sales_rep, COUNT(A.id) as num_accounts
       FROM accounts A
       JOIN sales_reps S
       ON A.sales_rep_id = S.id
       GROUP BY S.id, S.name
       HAVING COUNT(A.id) > 5;

--How many accounts have more than 20 orders?
       SELECT A.name, COUNT(*)
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       GROUP BY A.name
       HAVING COUNT(O.*) > 20;

--Which account has the most orders?
       SELECT A.name, COUNT(O.*)
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       GROUP BY A.name
       ORDER BY COUNT(O.*) DESC
       LIMIT 1

--Which accounts spent more than 30,000 usd total across all orders? 204
       SELECT A.name, SUM(O.total_amt_usd) 
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       GROUP BY A.name
       HAVING SUM(O.total_amt_usd) > 30000
       ORDER BY SUM(O.total_amt_usd) DESC;

--Which accounts spent less than 1,000 usd total across all orders? 3
       SELECT A.name, SUM(total_amt_usd)
       FROM orders O
       JOIN accounts A
       ON O.account_id = A.id
       GROUP BY A.name
       HAVING SUM(total_amt_usd)<1000
       ORDER BY SUM(total_amt_usd);

--Which account has spent the most with us? EOG resources
--Which account has spent the least? Nike
       
--Which accounts used facebook as a channel to contact customers more than 6 times?
       SELECT A.name, COUNT(W.*) 
       FROM accounts A
       JOIN web_events W
       ON A.id = W.account_id
       WHERE W.channel = 'facebook' --OR, include this logic into the HAVING part
       GROUP BY A.name
       HAVING COUNT(W.*)>6
       ORDER BY COUNT(W.*) DESC;
--Which account used facebook most as a channel? Gilead Sciences

--Which channel is more frequently used by most accounts?
       SELECT W.channel, COUNT(*)
       FROM web_events W
       JOIN accounts A
       ON W.account_id = A.id
       GROUP BY W.channel
       ORDER BY COUNT(*) DESC

-----DATES-----

--DATE_TRUNC lets you adjust the date detail to be more general so that you can use it into groups 
--DATE_PART lets you extract a specific part of the date, but all the other details become irrelevant (ie. year doesn't matter if you 
--end up extracting month as the main detail) 

--Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. 
--Do you notice any trends in the yearly sales totals? 2016 was the top year, by two fold. 2017 was the smallest year. 

       SELECT DATE_PART('year',occurred_at), SUM(total_amt_usd)
       FROM orders 
       GROUP BY DATE_PART('year',occurred_at)
       ORDER BY SUM(total_amt_usd) DESC;

--Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset? 
--the range was 409 - 882, most spent in feb and then jan, the least in dec even though it had the most actual sales

       SELECT DATE_PART('month',occurred_at),
              SUM(total_amt_usd),COUNT(occurred_at)
       FROM orders
       GROUP BY DATE_PART('month', occurred_at)
       ORDER BY SUM(total_amt_usd);

--Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
-- no, in 2013 and 2017 there was only one month of data. can filter the select statement to exclude these months of data

       SELECT DATE_PART('year',occurred_at) as year, COUNT(*) as num_sales,
       COUNT (DISTINCT DATE_PART('month',occurred_at)) as num_months
       GROUP BY DATE_PART('year',occurred_at)
       ORDER BY COUNT(*) DESC;

(((-----CASE-----)))

--Case helps you to view all your data but also see certain conditions in a new separate column. It helps you filter your data but its 
--different from a WHERE clause because WHERE clause can only let you see one condition at a time

--Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’ 
-- depending on if the order is $3000 or more, or smaller than $3000.

       SELECT account_id, total_amt_usd, 
              CASE WHEN total_amt_usd > 3000 THEN 'Large'
                   WHEN total_amt_usd < 3000 THEN 'Small' END as order_level -- could also just do "ELSE" since only two criteria
       FROM orders;

--Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.

SELECT
       CASE WHEN total >= 2000 THEN 'At Least 2000'
            WHEN total < 2000 AND total >= 1000 THEN 'BETWEEN 1000 and 2000'
            WHEN total < 1000 THEN 'Less than 1000'   -- could also just do "ELSE"
            END AS category,
       COUNT(*) as order_count
FROM orders
GROUP BY category

--We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
--The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level 
--is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table that includes the level 
--associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. 
--Order with the top spending customers listed first.

       SELECT A.name, SUM(O.total_amt_usd),
             CASE WHEN SUM(O.total_amt_usd) > 200000 THEN 'Level 3'
                  WHEN SUM(O.total_amt_usd) < 200000 AND
                       SUM(O.total_amt_usd) > 100000 THEN 'Level 2'
                  WHEN SUM(O.total_amt_usd) < 100000 THEN 'Level 1'   -- the answer key didn't use AND, so they had overlapping criteria...
                  END
            FROM orders O
            JOIN accounts A
            ON O.account_id = A.id
       GROUP BY A.name
       ORDER BY SUM(O.total_amt_usd) DESC;

--We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 
--and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.

       SELECT A.name, SUM(O.total_amt_usd),
             CASE WHEN SUM(O.total_amt_usd) > 200000 THEN 'Level 3'
                  WHEN SUM(O.total_amt_usd) < 200000 AND
                       SUM(O.total_amt_usd) > 100000 THEN 'Level 2'
                  WHEN SUM(O.total_amt_usd) < 100000 THEN 'Level 1'   -- the answer key didn't use AND, so they had overlapping criteria...
                  END
            FROM orders O
            JOIN accounts A
            ON O.account_id = A.id
            WHERE occurred_at BETWEEN '2016-01-01' AND '2018-01-01'  --or can say '> 2015-12-31'
       GROUP BY A.nmame
       ORDER BY total_amt_usd DESC;

--We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table with the sales rep name, 
--the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the top sales people first in your final table.

       SELECT S.name as sales_rep, COUNT(O.*),
              CASE WHEN COUNT(O.*) > 200 THEN 'TOP'
                   ELSE 'Not'
                   END AS level
         FROM orders O 
         JOIN accounts A
         ON O.account_id = A.id
         JOIN sales_reps S
         ON A.sales_rep_id = S.id
       GROUP BY S.name
       ORDER BY COUNT(O.*) DESC;

--The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. 
--We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any
--rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, 
--middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. 

       SELECT S.name as sales_rep, COUNT(O.*) as total_orders, SUM(total_amt_usd) as total_dollars,
              CASE WHEN COUNT(O.*) > 200 OR SUM(total_amt_usd) > 750000 
                        THEN 'Top'
                   WHEN ( COUNT(O.*) >150 AND COUNT(O.*) <=200 )
                          OR ( SUM(total_amt_usd) > 500000 
                               AND SUM(total_amt_usd) <=750000 )
                          THEN 'Middle'
                   ELSE 'Low'
                   END AS level
         FROM orders O 
         JOIN accounts A
         ON O.account_id = A.id
         JOIN sales_reps S
         ON A.sales_rep_id = S.id
       GROUP BY S.name
       ORDER BY SUM(total_amt_usd) DESC;


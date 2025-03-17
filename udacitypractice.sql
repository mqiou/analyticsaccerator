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



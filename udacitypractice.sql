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

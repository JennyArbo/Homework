--1)Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT first_name, last_name
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name;
--For this question, I wanted the names of all customers whose last name begins with 'T', so I select both the first and last names, which
--are stored in the 'customer' table. Since we want any last name that begins with T, I use the % wildcard to select all names that begin
--with T, followed by any other combo of letters. Finally, I used the ORDER BY command to put the names in alphabetical order by first name.
--The question wants A-Z order so the default of ascending order is fine here and nothing else needs to be done.

--2)Show all rentals returned from 5/28/2005 to 6/1/2005
SELECT *
FROM rental
WHERE return_date > '2005-05-28'
AND return_date < '2005-06-02'
ORDER BY return_date;

--The question wants all info from a particular time period, so I begin by using * to select all.
--The desired information is stored in the rental table so I reference it in my FROM statement.
--Next I used a WHERE statement to select the desired dates for the rental. I use the AND statement to only pull data between the 2 dates.
--Lastly, I used ORDER BY to put everything in order by date.

--3)How would you determine which movies are rented the most?
SELECT i.film_id, count(i.film_id)AS number_rented, title
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
ORDER BY number_rented DESC;
--For this question, I needed to join several tables to return the desired data. I wanted to find out which movies are rented the most so
-- I needed a metric to determine how often a particular film is rented. For this, I chose to use the COUNT of the film_id in the rental table.
--This should tell me how many times a particular film is actually rented. Since the film_id doesn't make much sense when we are just looking at the data,
--I also added title since that is easier for us to interpret. To accomplish all of this, I needed to join the rental, inventory, and film tables.
--Once that is accomplished, I grouped by the film_id and title categories. Finally, I put the movies in order from the most rented to the least rented.

--FROM Class:
--


--4)Show how much each customer spent on movies (for all time) . Order them from least to most.
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent;

--For this question, I identified the customer ID and used SUM to calculate how much each customer spent.
--I could have also tied this to customer name but decided for this ask, the id was enough.
--This information is stored in the payment table so I call that in my FROM statement.
--Next, I grouped by customer_id so I could summarize how much each unique customer spent.
--Finally, I ordered by the total money each customer spent. Since the question asks for least --> most, I can leave this just as order by.


--5)Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name.
--Order the results from most to least.

  SELECT fa.actor_id, fa.film_id, f.title, a.last_name AS Actor_last_name, a.first_name AS Actor_first_name
  INTO popular_in_2006
  FROM film_actor AS fa
  INNER JOIN actor AS a
  ON fa.actor_id = a.actor_id
  INNER JOIN film AS f
  ON fa.film_id = f.film_id
  WHERE f.release_year = 2006;

  SELECT COUNT(film_id) AS number_films, actor_first_name, actor_last_name
  FROM popular_in_2006
  GROUP BY actor_id, actor_last_name, actor_first_name
  ORDER BY number_films DESC;

  --This probably could have been done more efficiently or in a single request. My brain was struggling to conceptualize how to best do that, so I did what made
  --the most sense to me. I decided to store my joined data in a new table called 'popular_in_2006'. I joined data from the film_actor, actor, and film tables.
  --I aliased each of these tables to simplify things and save time typing. I wanted the actor_id, film_id, title, last_name, and first_name for each actor.
  --I also only cared about the year 2006, so I used a WHERE statement to select only results from that particular release year.
  --Next, I used my new table to calculate the number of films each actor appeared in in 2006 and I also selected the actors' full names (first & last).
  --I grouped by their ID and full name to ensure that I was grouping each distinct actor. Then I ordered by the number of films (caculated using COUNT on the film IDs).
  --I wanted the number of films ordered from most to least appearances for each actor in 2006, so I used ORDER BY and DESC to put it in order of most-least.

  --Since we had an extra week to work on this, I decided to rewrite this as one query:
  SELECT a.last_name AS Actor_last_name, a.first_name AS Actor_first_name, COUNT(f.film_id) AS number_films
   FROM film_actor AS fa
   INNER JOIN actor AS a
   ON fa.actor_id = a.actor_id
   INNER JOIN film AS f
   ON fa.film_id = f.film_id
   WHERE f.release_year = 2006
   GROUP BY fa.actor_id, actor_last_name, Actor_first_name
   ORDER BY number_films DESC;


--6)Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one.
  Use the following link to understand how this works http://postgresguide.com/performance/explain.html
--For question 4:
  "Sort  (cost=383.25..384.75 rows=599 width=34)"
  "  Sort Key: (sum(amount))"
  "  ->  HashAggregate  (cost=348.13..355.62 rows=599 width=34)"
  "        Group Key: customer_id"
  "        ->  Seq Scan on payment  (cost=0.00..270.42 rows=15542 width=8)"

  --Explain Analyze instead:
  "Sort  (cost=383.25..384.75 rows=599 width=34) (actual time=39.937..39.978 rows=599 loops=1)"
"  Sort Key: (sum(amount))"
"  Sort Method: quicksort  Memory: 53kB"
"  ->  HashAggregate  (cost=348.13..355.62 rows=599 width=34) (actual time=38.632..38.828 rows=599 loops=1)"
"        Group Key: customer_id"
"        Batches: 1  Memory Usage: 297kB"
"        ->  Seq Scan on payment  (cost=0.00..270.42 rows=15542 width=8) (actual time=0.562..6.504 rows=14596 loops=1)"
"Planning Time: 0.759 ms"
"Execution Time: 40.752 ms"

  --For question 5:
  "Sort  (cost=748.16..764.09 rows=6372 width=23)"
  "  Sort Key: (count(f.film_id)) DESC"
  "  ->  HashAggregate  (cost=281.80..345.52 rows=6372 width=23)"
  "        Group Key: fa.actor_id, a.last_name, a.first_name"
  "        ->  Hash Join  (cost=85.50..218.08 rows=6372 width=19)"
  "              Hash Cond: (fa.film_id = f.film_id)"
  "              ->  Hash Join  (cost=6.50..122.30 rows=6372 width=17)"
  "                    Hash Cond: (fa.actor_id = a.actor_id)"
  "                    ->  Seq Scan on film_actor fa  (cost=0.00..98.72 rows=6372 width=4)"
  "                    ->  Hash  (cost=4.00..4.00 rows=200 width=17)"
  "                          ->  Seq Scan on actor a  (cost=0.00..4.00 rows=200 width=17)"
  "              ->  Hash  (cost=66.50..66.50 rows=1000 width=4)"
  "                    ->  Seq Scan on film f  (cost=0.00..66.50 rows=1000 width=4)"
  "                          Filter: ((release_year)::integer = 2006)"

  --Explain Analyze for question 5:
  "Sort  (cost=748.16..764.09 rows=6372 width=23) (actual time=30.207..30.953 rows=200 loops=1)"
"  Sort Key: (count(f.film_id)) DESC"
"  Sort Method: quicksort  Memory: 40kB"
"  ->  HashAggregate  (cost=281.80..345.52 rows=6372 width=23) (actual time=29.405..30.237 rows=200 loops=1)"
"        Group Key: fa.actor_id, a.last_name, a.first_name"
"        Batches: 1  Memory Usage: 241kB"
"        ->  Hash Join  (cost=85.50..218.08 rows=6372 width=19) (actual time=17.036..28.222 rows=5462 loops=1)"
"              Hash Cond: (fa.film_id = f.film_id)"
"              ->  Hash Join  (cost=6.50..122.30 rows=6372 width=17) (actual time=9.009..17.650 rows=5462 loops=1)"
"                    Hash Cond: (fa.actor_id = a.actor_id)"
"                    ->  Seq Scan on film_actor fa  (cost=0.00..98.72 rows=6372 width=4) (actual time=6.194..8.283 rows=5462 loops=1)"
"                    ->  Hash  (cost=4.00..4.00 rows=200 width=17) (actual time=1.384..1.385 rows=200 loops=1)"
"                          Buckets: 1024  Batches: 1  Memory Usage: 18kB"
"                          ->  Seq Scan on actor a  (cost=0.00..4.00 rows=200 width=17) (actual time=0.612..1.333 rows=200 loops=1)"
"              ->  Hash  (cost=66.50..66.50 rows=1000 width=4) (actual time=7.375..8.101 rows=1000 loops=1)"
"                    Buckets: 1024  Batches: 1  Memory Usage: 44kB"
"                    ->  Seq Scan on film f  (cost=0.00..66.50 rows=1000 width=4) (actual time=0.015..0.366 rows=1000 loops=1)"
"                          Filter: ((release_year)::integer = 2006)"
"Planning Time: 10.690 ms"
"Execution Time: 32.312 ms"

  --For these explain plans, we see cost of performing the query. This can allow us to look at how long a query is taking to plan and perform.
  --This data can be used to optimize queries to minimize the time needed to perform the query and the amount of memory needed.
  --We can also use Explain Analyze to obtain more detailed data (with actual times given).

--7)What is the average rental rate per genre?
--#7: Average rental rate for each genre
--Need to join the film, film_category, and category tables to get all info we want

SELECT c.name as category_name, AVG(f.rental_rate) AS average_rental_rate
FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id = fc.film_id
INNER JOIN category AS c
ON fc.category_id = c.category_id
GROUP BY category_name;
--To complete this query, 2 joins need to be completed, linking the film, film_category, and category tables to give all necessary data.
--Then, I chose to group by category name. My SELECT statement takes in the category name and the average rental rate (which due to grouping will be displayed
--for each category name). This query then returns the category name and the average rental rate for each category in the dataset.

--8)How many films were returned late? Early? On time?
SELECT film.film_id, film.rental_duration, inventory.inventory_id, (rental.return_date-rental.rental_date) AS rental_time
INTO rental_time_data
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id;

SELECT  film_id, inventory_id, rental_time,
CASE WHEN make_interval(days => rental_duration) = rental_time THEN 'on time'
WHEN make_interval(days => rental_duration) > rental_time THEN 'early'
ELSE 'late' END
AS rental_time_return
INTO rental_time_details
FROM rental_time_data;

SELECT COUNT(rental_time_return), rental_time_return
FROM rental_time_details
GROUP BY rental_time_return;

--Again, this probably could have been done more efficiently but this is how my brain was making sense of linking everything together.
--First, I joined the film, inventory, and rental tables into a new table that I called rental_time_data. Then, I used a CASE statement
--to determine whether a film was early, on time, or late. I again saved this into a new table called rental_time_details (this was probably unnecessary).
--Finally I grouped by the returns (early, on time, late) and then counted how many films fell into each category.

--Since we were given extra time to work on this assignment, I redid the problem and  combined the multiple queries into a single query.
SELECT
SUM(CASE
	WHEN make_interval(days => rental_duration) = (rental.return_date - rental.rental_date)
	THEN 1
	ELSE 0
	END) AS ontime,
SUM(CASE
	WHEN make_interval(days => rental_duration) > (rental.return_date - rental.rental_date)
	THEN 1
	ELSE 0
	END) AS late,
SUM(CASE
   WHEN make_interval(days => rental_duration) < (rental.return_date - rental.rental_date)
	THEN 1
	ELSE 0
	END) AS early
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id;

--In the above query I used a set of CASE WHEN statements to calculate the # of each films that were returned early, on time, and late.
--To do this I also had to perform 2 inner joins linking the film, inventory and rental tables from the dataset.


--9)What categories are the most rented and what are their total sales?
SELECT p.rental_id AS rental, p.amount AS price, r.inventory_id AS inventory, i.film_id AS film, fc.category_id as Category, c.name as Cat_name
INTO category_price
FROM payment AS p
INNER JOIN rental AS r
ON p.rental_id = r.rental_id
INNER JOIN inventory  AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film_category AS fc
ON i.film_id = fc.film_id
INNER JOIN category as c
ON fc.category_id = c. category_id;

SELECT COUNT(rental) AS number_rented, Cat_name, SUM(price) AS total_sales
FROM category_price
GROUP BY Cat_name
ORDER BY(number_rented) DESC;

--I again split this problem into 2 parts. For the first, I made a new table called category_price.
--The query joins the payment, rental, inventory, film_category, and category tables then put the desired data (given in SELECT statement) into category_price.
--Next, I used COUNT to determine the number of films rented and SUM to determine the total prices. These operations were performed on groups by category names
--and then ordered by the number of films rented. This query returns the total films rented and the total price paid for rentals in each named category.
--The final line of the query orders the categories by number of films rented from highest to lowest.
SELECT COUNT(r.rental_id) AS number_rented, c.name, SUM(cp.price) AS total_sales
FROM payment AS p
INNER JOIN rental AS r
ON p.rental_id = r.rental_id
INNER JOIN inventory  AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film_category AS fc
ON i.film_id = fc.film_id
INNER JOIN category as c
ON fc.category_id = c. category_id
INNER JOIN category_price AS cp
ON c.name = cp.cat_name
GROUP BY c.name
ORDER BY(number_rented) DESC;

--In an effort to clean this up and combine things, I went wrong somewhere along the line. I'm still looking into what is wrong.


10)Create a view for 8 and a view for 9. Be sure to name them appropriately.

--For number 8, I created a view based on the 3rd query:
CREATE VIEW rental_time_designations AS
SELECT COUNT(rental_time_return), rental_time_return
FROM rental_time_details
GROUP BY rental_time_return;

--For number 9 (Note I used the condensed code even though I know this is not working properly)
CREATE VIEW Most_rented_categories AS
SELECT COUNT(r.rental_id) AS number_rented, c.name, SUM(cp.price) AS total_sales
FROM payment AS p
INNER JOIN rental AS r
ON p.rental_id = r.rental_id
INNER JOIN inventory  AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film_category AS fc
ON i.film_id = fc.film_id
INNER JOIN category as c
ON fc.category_id = c. category_id
INNER JOIN category_price AS cp
ON c.name = cp.cat_name
GROUP BY c.name
ORDER BY(number_rented) DESC;


Bonus:
Write a query that shows how many films were rented each month. Group them by category and month.

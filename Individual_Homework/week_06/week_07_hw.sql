--1) Create a new column called “status” in the rental table that uses a case statement to indicate if a film was returned late, early, or on time.
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
FROM rental_time_data;

--My answer here is very similar to number 8 from week 6 because I chose to use a case statement to solve that one. Not sure if you were looking for something
--totally different here.

2) Show the total payment amounts for people who live in Kansas City or Saint Louis.
SELECT city, SUM(p.amount)
FROM customer AS c1
INNER JOIN payment AS p
ON c1.customer_id = p.customer_id
INNER JOIN address AS a
ON c1.address_id = a.address_id
INNER JOIN city AS c2
ON a.city_id = c2.city_id
WHERE city = 'Kansas City' OR city = 'Saint Louis'
GROUP BY city;
--This query returns the city name and the total payment amounts (expressed using SUM) for customers living in KC or STL.
--I had to join the customer, payment, address, and city tables to obtain the desired data.
--I used a WHERE clause to filter based on city name of Kansas City or Saint Louis.
--Finally, I grouped by city to split the output into 2 results-one for KC and one for STL.

--3) How many film categories are in each category? Why do you think there is a table for category and a table for film category?
--There are 16 film categories and 16 named categories. So there is a 1:1 correlation between the category_id and category name (which makes sense).
--designations act as "buckets" to bin the films and make them more easily searchable. When including the film IDs, the tables are of different lengths.
--It would be redundant/a waste of space to include the film's category ID and name in each entry if they were stored in one single table.

--4) Show a roster for the staff that includes their email, address, city, and country (not ids)
SELECT s.email, a.address, a.address2, c1.city, c2.country
FROM staff AS s
INNER JOIN address AS a
ON s.address_id = a.address_id
INNER JOIN city AS c1
ON a.city_id = c1.city_id
INNER JOIN country AS c2
ON c1.country_id = c2.country_id;

--This query performs 3 joins to aggregate data from the staff, address, city, and country tables. It returns a roster of employees with their email,
--address, city, and country listed.

--5) Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
SELECT f.film_id, f.title, f.length
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id;
WHERE r.return_date >= '2005-05-15' AND r.return_date <= '2005-05-31';

--This query joins the film, inventory, and rental tables. The WHERE clause here filters the data returned based on return date and includes the film_id,
--title, and length for movies returned between May 15 and May 31, 2005 (inclusive of the 15 and 31).

--6) Write a subquery to show which movies are rented below the average price for all movies.
SELECT DISTINCT title, rental_rate
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
WHERE rental_rate < (SELECT AVG(rental_rate) FROM film);

--This query joins the film and inventory tables and has a subquery which allows the rental rate of each film to be compared to the average rental rate for
--all films. I chose to use distinct when selecting data so that there were no replicated films included in the output data.


--7) Write a join statement to show which moves are rented below the average price for all movies.
SELECT DISTINCT title, rental_rate
FROM film AS f1
JOIN (SELECT AVG(rental_rate) AS avg_rate FROM film) AS f2
ON f1.rental_rate < f2.avg_rate;

--This query performs the same actions as the one from question 6 but it uses the concept of a self-join instead of a subquery. Here the self join is performed
--by comparing the rental rate from the original table to the average rental rate calculated using the same data but labeled as f2. This filters the results
--based on a comparison of a particular film's rental rate to the average rental rate for all films.


--8) Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they differ.
--From #6:
"HashAggregate  (cost=227.69..231.02 rows=333 width=21)"
"  Group Key: film.title, film.rental_rate"
"  InitPlan 1 (returns $0)"
"    ->  Aggregate  (cost=66.50..66.51 rows=1 width=32)"
"          ->  Seq Scan on film film_1  (cost=0.00..64.00 rows=1000 width=6)"
"  ->  Hash Join  (cost=70.66..153.55 rows=1525 width=21)"
"        Hash Cond: (inventory.film_id = film.film_id)"
"        ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=2)"
"        ->  Hash  (cost=66.50..66.50 rows=333 width=25)"
"              ->  Seq Scan on film  (cost=0.00..66.50 rows=333 width=25)"
"                    Filter: (rental_rate < $0)"

--From #7:
"HashAggregate  (cost=144.69..148.02 rows=333 width=21)"
"  Group Key: f1.title, f1.rental_rate"
"  ->  Nested Loop  (cost=66.50..143.02 rows=333 width=21)"
"        Join Filter: (f1.rental_rate < (avg(film.rental_rate)))"
"        ->  Aggregate  (cost=66.50..66.51 rows=1 width=32)"
"              ->  Seq Scan on film  (cost=0.00..64.00 rows=1000 width=6)"
"        ->  Seq Scan on film f1  (cost=0.00..64.00 rows=1000 width=21)"

--The overall cost is fairly significantly lower for the self join statement used in number 7. The cost is about 63.5% the cost of the process used in
--question 6. So in terms of cost efficacy, it is better the use the self join compared to the subquery for this question.

--9) With a window function, write a query that shows the film, its duration, and what percentile the duration fits into.
This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank

SELECT film.title, film.length,
NTILE(100) OVER (ORDER BY film.length) AS percentile
FROM film;

--This query returns the film title, length, and the rank of the film's length expressed as a percentile relative to the length's of all other films in the dataset.


--10) In under 100 words, explain what the difference is between set-based and procedural programming. Be sure to specify which sql and python are.
--Procedural programming is using the code you write to dictate what the desired output is and how to obtain it.  Python is an example of procedural programming.
--Set based programming is inputting what you want for output, but does not include how to obtain those results. SQL is an example of set-based programming.


--Bonus:
--Find the relationship that is wrong in the data model. Explain why its wrong.

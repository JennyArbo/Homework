--1)Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT first_name, last_name
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name;

--2)Show all rentals returned from 5/28/2005 to 6/1/2005
SELECT *
FROM rental
WHERE return_date > '2005-05-28'
AND return_date < '2005-06-02'
ORDER BY return_date;

--3)How would you determine which movies are rented the most?
SELECT i.film_id, count(i.film_id)AS number_rented, title
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
ORDER BY number_rented DESC;


--4)Show how much each customer spent on movies (for all time) . Order them from least to most.
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent;


--5)Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name.
  Order the results from most to least.

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


--6)Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one.
  Use the following link to understand how this works http://postgresguide.com/performance/explain.html


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


8)How many films were returned late? Early? On time?
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

10)Create a view for 8 and a view for 9. Be sure to name them appropriately.


Bonus:
Write a query that shows how many films were rented each month. Group them by category and month.

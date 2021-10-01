WITH base_counts AS (
SELECT
  film_id,
  COUNT(*) AS record_count
FROM dvd_rentals.inventory
GROUP BY film_id
)
SELECT
  record_count,
  COUNT(DISTINCT film_id) as unique_film_id_values
FROM base_counts
GROUP BY record_count
ORDER BY record_count;

---Confirmation of 1 to many relationship for te film_id foreign key in inventory table

SELECT
  film_id,
  COUNT(*) AS record_count
FROM dvd_rentals.film
GROUP BY film_id
ORDER BY record_count DESC
LIMIT 5;

---We can now also confirm that there is a 1-to-1 relationship in the dvd_rentals.film
-- how many foreign keys only exist in the inventory table
SELECT
  COUNT(DISTINCT inventory.film_id)
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.film
  WHERE film.film_id = inventory.film_id
);

--Count: 0

-- how many foreign keys only exist in the film table
SELECT
  COUNT(DISTINCT film.film_id)
FROM dvd_rentals.film
WHERE NOT EXISTS (
  SELECT film_id
  FROM dvd_rentals.inventory
  WHERE film.film_id = inventory.film_id
);

---Count: 42
/*Finally - let’s check that total count of distinct foreign key values that will be generated when we use a left semi join on our dvd_rentals.inventory as our base left table.*/

SELECT
  COUNT(DISTINCT film_id)
FROM dvd_rentals.inventory
-- note how the NOT is no longer here for a left semi join
-- compared to the anti join!
WHERE EXISTS (
  SELECT film_id
  FROM dvd_rentals.film
  WHERE film.film_id = inventory.film_id
);

---Count: 958

---We will be expecting a total distinct count of film_id values of 958 once we perform the final join between our 2 tables.
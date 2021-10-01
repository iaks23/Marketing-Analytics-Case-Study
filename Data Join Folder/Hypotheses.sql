/*1. The number of unique inventory_id records will be equal in both dvd_rentals.rental and dvd_rentals.inventory tables*/

SELECT 
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.rental; 

/*4580*/ 

SELECT 
  COUNT(DISTINCT inventory_id)
FROM dvd_rentals.inventory;

/*4581*/

/*Hypothesis: 1 fails because of one extra inventory id*/

/*2. There will be a multiple records per unique inventory_id in the dvd_rentals.rental table*/

-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  inventory_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.rental
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;

/*
4 inventory ID's have 1 row count,
1126 inventory id's have 2 row counts and so on...*/

-- Hence, we can confirm that there are multiple rows per inventory_id in our rental table. Thus Hypothesis: 2 passes.

-- 3. There will be multiple inventory_id records per unique film_id value in the dvd_rentals.inventory table

-- first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  film_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.inventory
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;

-- And we can confirm that our hypotheses 3 is valid and indeed there are multiple inventory_id per unique film_id.

---Question 1: How many records exist per inventory_id value in rental or inventory tables?

-- Hypothesis 2 has answered the for the rental part which shows a 1 to many relationship. 

---inventory distribution analysis on inventory_id foreign key

--first we generate group by counts on the target_column_values
WITH counts_base AS (
SELECT 
  inventory_id AS target_column_values,
  COUNT(*) AS row_count
FROM dvd_rentals.inventory
GROUP BY target_column_values
)

-- we then group by again on the row_count to summarize our results
SELECT
  row_count,
  COUNT(target_column_values) AS count_of_target_values
FROM counts_base
GROUP BY row_count
ORDER BY row_count;

-- 1 : 4581
--As compared to the rental table, the inventory table contains only 1 row per unique inventory_id showing a one-to-one relationship.

-- Question 2: How many overlapping and missing unique foreign key values are there between the two tables?
SELECT
  COUNT(DISTINCT inventory_id) 
FROM dvd_rentals.rental
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.inventory
  WHERE rental.inventory_id = inventory.inventory_id
);

-- Output: 0

SELECT
  COUNT(DISTINCT inventory_id) 
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);

-- Output: 1

--- Only one record from right (inventory) is not present in the left (rental).

SELECT *
FROM dvd_rentals.inventory
WHERE NOT EXISTS (
  SELECT inventory_id
  FROM dvd_rentals.rental
  WHERE rental.inventory_id = inventory.inventory_id
);

-- Inventory Id: 5 Film Id: 1 Store_Id : 2


--This one record is the reason the discrepancy is caused between two tables. This could've been a DVD that was not rented out by any customer/not tracked in the rental table.


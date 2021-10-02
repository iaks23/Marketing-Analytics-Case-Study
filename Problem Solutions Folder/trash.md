Final base table preview:

DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  category.name AS category_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id;

SELECT * FROM complete_joint_dataset limit 10;

From starting point ---> calculate insights




Limiting sample size to estimate better:
Top 2 categories for each customer--->

DEAL WITH ties


Let’s first aggregate that rental_count value first - however let’s also use the version of the joint dataset that also had the rental_date for each record too so we can generate an additional latest_rental_date field for use with our sorting and ordering step, just like in our simple illustrated example.

DROP TABLE IF EXISTS category_rental_counts;
CREATE TEMP TABLE category_rental_counts AS
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset_with_rental_date
GROUP BY
  customer_id,
  category_name;

-- profile just customer_id = 1 values sorted by desc rental_count
SELECT *
FROM category_rental_counts
WHERE customer_id = 1
ORDER BY
  rental_count DESC;






category_percentage: What proportion of each customer’s total films watched does this count make?


DROP TABLE IF EXISTS customer_total_rentals;
CREATE TEMP TABLE customer_total_rentals AS
SELECT
  customer_id,
  SUM(rental_count) AS total_rental_count
FROM category_rental_counts
GROUP BY customer_id;

-- show output for first 5 customer_id values
SELECT *
FROM customer_total_rentals
WHERE customer_id <= 5
ORDER BY customer_id;



AVG CATEGORY RENTAL COUNTS using AVG


DROP TABLE IF EXISTS average_category_rental_counts;
CREATE TEMP TABLE average_category_rental_counts AS
SELECT
  category_name,
  AVG(rental_count) AS avg_rental_count
FROM category_rental_counts
GROUP BY
  category_name;

-- output the entire table by desc avg_rental_count
SELECT *
FROM average_category_rental_counts
ORDER BY
  avg_rental_count DESC;


Update query to mmake averages look prettier:

UPDATE average_category_rental_counts
SET avg_rental_count = FLOOR(avg_rental_count)
RETURNING *;



NEXT QUESTION: percentile: How does the customer rank in terms of the top X% compared to all other customers in this film category?


SELECT
  customer_id,
  category_name,
  rental_count,
  -- use ceiling to round up to nearest integer after multiplying by 100
  CEILING(
    100 * PERCENT_RANK() OVER (
      PARTITION BY category_name
      ORDER BY rental_count DESC
    )
  ) AS percentile
FROM category_rental_counts
ORDER BY customer_id, rental_count DESC
LIMIT 2;


CTE---->

DROP TABLE IF EXISTS customer_category_percentiles;
CREATE TEMP TABLE customer_category_percentiles AS
SELECT
  customer_id,
  category_name,
  -- use ceiling to round up to nearest integer after multiplying by 100
  CEILING(
    100 * PERCENT_RANK() OVER (
      PARTITION BY category_name
      ORDER BY rental_count DESC
    )
  ) AS percentile
FROM category_rental_counts;

-- inspect top 2 records for customer_id = 1 sorted by ascending percentile
SELECT *
FROM customer_category_percentiles
WHERE customer_id = 1
ORDER BY customer_id, percentile
LIMIT 2;



FINDING INSIGHTS FOR CUSTOMER 1:

SELECT *
FROM category_rental_counts
WHERE customer_id = 1
ORDER BY rental_count DESC
LIMIT 5;


SELECT *
FROM customer_total_rentals
LIMIT 5;


SELECT *
FROM average_category_rental_counts
LIMIT 5;

SELECT *
FROM customer_category_percentiles
WHERE customer_id = 1
ORDER BY percentile
LIMIT 5;


JOIN THEM ALL

DROP TABLE IF EXISTS customer_category_joint_table;
CREATE TEMP TABLE customer_category_joint_table AS
SELECT
  t1.customer_id,
  t1.category_name,
  t1.rental_count,
  t1.latest_rental_date,
  t2.total_rental_count,
  t3.avg_rental_count,
  t4.percentile,
  t1.rental_count - t3.avg_rental_count AS average_comparison,
  -- round to nearest integer for percentage after multiplying by 100
  ROUND(100 * t1.rental_count / t2.total_rental_count) AS category_percentage
FROM category_rental_counts AS t1
INNER JOIN customer_total_rentals AS t2
  ON t1.customer_id = t2.customer_id
INNER JOIN average_category_rental_counts AS t3
  ON t1.category_name = t3.category_name
INNER JOIN customer_category_percentiles AS t4
  ON t1.customer_id = t4.customer_id
  AND t1.category_name = t4.category_name;

SELECT *
FROM customer_category_joint_table
WHERE customer_id = 1
ORDER BY percentile
limit 5;


GET TOP 2 CATEGORIES for each customer:

DROP TABLE IF EXISTS top_categories_information;

-- Note that you need an extra pair of (brackets) when you create tables
-- with CTEs inside the SQL statement!
CREATE TEMP TABLE top_categories_information AS (
-- use a CTE with the ROW_NUMBER() window function implemented
WITH ordered_customer_category_joint_table AS (
  SELECT
    customer_id,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY rental_count DESC, latest_rental_date DESC
    ) AS category_ranking,
    category_name,
    rental_count,
    average_comparison,
    percentile,
    category_percentage
  FROM customer_category_joint_table
)
-- filter out top 2 rows from the CTE for final output
SELECT *
FROM ordered_customer_category_joint_table
WHERE category_ranking <= 2
);


SELECT *
FROM top_categories_information
WHERE customer_id in (1, 2, 3)
ORDER BY customer_id, category_ranking;




Breaking down the steps of finding category & actor insights


Create Base Dataset: We also included the rental_date column to help us split ties for rankings which had the same count of rentals at a customer level - this helps us prioritise film categories which were more recently viewed.

DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  category.name AS category_name,
  -- also included rental_date for sorting purposes
  rental.rental_date
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id;



  Category Counts
  DROP TABLE IF EXISTS category_counts;
CREATE TEMP TABLE category_counts AS
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset
GROUP BY
  customer_id,
  category_name;

Helps us get the top categories based on rental counts for each customer


TOTAL COUNTS----> All the movies a customer has ever rented

DROP TABLE IF EXISTS total_counts;
CREATE TEMP TABLE total_counts AS
SELECT
  customer_id,
  SUM(rental_count) AS total_count
FROM category_counts
GROUP BY
  customer_id;


Top Categories:

DROP TABLE IF EXISTS top_categories;
CREATE TABLE top_categories AS
WITH ranked_cte AS (
  SELECT
    customer_id,
    category_name,
    rental_count,
    DENSE_RANK() OVER (
      PARTITION BY customer_id
      ORDER BY
        rental_count DESC,
        latest_rental_date DESC,
        category_name
    ) AS category_rank
  FROM category_counts
)
SELECT * FROM ranked_cte
WHERE category_rank <= 2;


GET ONLY TOP 2

Average Category Count: Average of DVD Rental Co.

DROP TABLE IF EXISTS average_category_count;
CREATE TEMP TABLE average_category_count AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS category_average
FROM category_counts
GROUP BY category_name;

Top Category Percentile

DROP TABLE IF EXISTS top_category_percentile;
CREATE TABLE top_category_percentile AS
WITH calculated_cte AS (
SELECT
  top_categories.customer_id,
  top_categories.category_name AS top_category_name,
  top_categories.rental_count,
  category_counts.category_name,
  top_categories.category_rank,
  PERCENT_RANK() OVER (
    PARTITION BY category_counts.category_name
    ORDER BY category_counts.rental_count DESC
  ) AS raw_percentile_value
FROM category_counts
LEFT JOIN top_categories
  ON category_counts.customer_id = top_categories.customer_id
)
SELECT
  customer_id,
  category_name,
  rental_count,
  category_rank,
  CASE
    WHEN ROUND(100 * raw_percentile_value) = 0 THEN 1
    ELSE ROUND(100 * raw_percentile_value)
  END AS percentile
FROM calculated_cte
WHERE
  category_rank = 1
  AND top_category_name = category_name;
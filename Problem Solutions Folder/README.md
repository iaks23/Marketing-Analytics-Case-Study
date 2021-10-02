# Case Study - Problem Solving Folder

We've got our analysis, and we've formed our base table, all that's left to do is generate the insights and customize our report! 

![gif-plan]()

## Solution Plan Breakdown 📋
* [Category Insights](#catin)
* [Category Recommendations](#catrec)
* [Actor Insights](#actin)
* [Actor Recommendations](#actrec)
* [Final Transformation](#output)

> P.S. if you want to skip all this and skip right to the main SQL script, click [here]() 

------

# Category Insights <a name='catin'></a>

To generate insights, we are kicking off by creating a base dataset which includes the <code>rental_date</code> column in order to break ties between top categories, such that the latest rented film's category will be chosen. Ofcourse, you are allowed to implement anoter tie breaking criteria of your own. 

```sql
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
```
|Customer_Id|Film_Id|Title|category_id|category_name|
|---|---|---|---|---|
|130|80|BLANKET BEVERLY|8|Family|
|459|333|FREAKY POCUS|12|Music|

## Category Counts

A follow-up table which uses the complete_joint_dataset to aggregate our data and generate a rental_count and the latest rental_date for our ranking purposes downstream.

```sql
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
```

For <code>customer_id = 1</code>:

|Customer_Id|category_name|rental_count|latest_rental_date|
|---|---|---|---|
|1|Classics|6|2005-08-19 09:55:16|
|1|Comedy|5|2005-08-22 19:41:37|

## Total Counts

A table generated to get a count of the entire number of rentals by every customer.

```sql
DROP TABLE IF EXISTS total_counts;
CREATE TEMP TABLE total_counts AS
SELECT
  customer_id,
  SUM(rental_count) AS total_count
FROM category_counts
GROUP BY
  customer_id;
```

## Top Categories

```sql
DROP TABLE IF EXISTS top_categories;
CREATE TEMP TABLE top_categories AS
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
```
|Customer_Id|category_name|rental_count|category_rank|
|---|---|---|---|
|1|Classics|6|1|
|1|Comedy|5|2|
|2|Sports|5|1|

## Average Category Count

We will use <code> category_counts </code> table to generate the average aggregated rental count for each category rounded down to the nearest integer using the FLOOR function.

```SQL
DROP TABLE IF EXISTS average_category_count;
CREATE TEMP TABLE average_category_count AS
SELECT
  category_name,
  FLOOR(AVG(rental_count)) AS category_average
FROM category_counts
GROUP BY category_name;
```

## Top Category Percentile 

This is to obtain the fact of what percentile the customer falls in compared to other customers for a particular category.

```SQL
DROP TABLE IF EXISTS top_category_percentile;
CREATE TEMP TABLE top_category_percentile AS
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
```

## First Category Insights

We will now bring the temp tables together to generate all necessary details that is printed in the template for a customer's top 1 category.

```SQL
ROP TABLE IF EXISTS first_category_insights;
CREATE TEMP TABLE first_category_insights AS
SELECT
  base.customer_id,
  base.category_name,
  base.rental_count,
  base.rental_count - average.category_average AS average_comparison,
  base.percentile
FROM top_category_percentile AS base
LEFT JOIN average_category_count AS average
  ON base.category_name = average.category_name;
```
|Customer_Id|category_name|rental_count|average_comparison|percentile|
|---|---|---|---|---|
|323|Action|7|5|1|
|506|Action|7|5|1|
|151|Action|6|4|1|

## Second Category Insights

Our second ranked category insight is pretty simple as we only need our top_categories table and the total_counts table to process our insights.

```SQL
DROP TABLE IF EXISTS second_category_insights;
CREATE TEMP TABLE second_category_insights AS
SELECT
  top_categories.customer_id,
  top_categories.category_name,
  top_categories.rental_count,
  -- need to cast as NUMERIC to avoid INTEGER floor division!
  ROUND(
    100 * top_categories.rental_count::NUMERIC / total_counts.total_count
  ) AS total_percentage
FROM top_categories
LEFT JOIN total_counts
  ON top_categories.customer_id = total_counts.customer_id
WHERE category_rank = 2;
```

|Customer_Id|category_name|rental_count|total_percentage|
|---|---|---|---|
|184|Drama|3|13|
|87|Sci-Fi|3|10|

---------
# Category Recommendations <a name='catrec'></a>

Here we tackle the recommendations for both our categories but we must ensure that these films have not already been viewed/rented by the customer.

## Film Counts

Performing the same total counts but now to determine how many times a particular FILM has been rented.

```SQL

DROP TABLE IF EXISTS film_counts;
CREATE TEMP TABLE film_counts AS
SELECT DISTINCT
  film_id,
  title,
  category_name,
  COUNT(*) OVER (
    PARTITION BY film_id
  ) AS rental_count
FROM complete_joint_dataset;
```

## Category Film Exclusions

We will need to generate a table with all of our customer’s previously watched films so we don’t recommend them something which they’ve already seen before.

```SQL
DROP TABLE IF EXISTS category_film_exclusions;
CREATE TEMP TABLE category_film_exclusions AS
SELECT DISTINCT
  customer_id,
  film_id
FROM complete_joint_dataset;
```

### Final Category Recommendations

```SQL
DROP TABLE IF EXISTS category_recommendations;
CREATE TEMP TABLE category_recommendations AS
WITH ranked_films_cte AS (
  SELECT
    top_categories.customer_id,
    top_categories.category_name,
    top_categories.category_rank,
    -- why do we keep this `film_id` column you might ask?
    -- you will find out later on during the actor level recommendations!
    film_counts.film_id,
    film_counts.title,
    film_counts.rental_count,
    DENSE_RANK() OVER (
      PARTITION BY
        top_categories.customer_id,
        top_categories.category_rank
      ORDER BY
        film_counts.rental_count DESC,
        film_counts.title
    ) AS reco_rank
  FROM top_categories
  INNER JOIN film_counts
    ON top_categories.category_name = film_counts.category_name
  -- This is a tricky anti-join where we need to "join" on 2 different tables!
  WHERE NOT EXISTS (
    SELECT 1
    FROM category_film_exclusions
    WHERE
      category_film_exclusions.customer_id = top_categories.customer_id AND
      category_film_exclusions.film_id = film_counts.film_id
  )
)
SELECT * FROM ranked_films_cte
WHERE reco_rank <= 3;
```

For <code>customer_id = 1</code>,

```SELECT *
FROM category_recommendations
WHERE customer_id = 1
ORDER BY category_rank, reco_rank;
```
|Customer_Id|category_name|category_rank|film_id|title|rental_count|reco_rank|
|---|---|---|---|---|---|---|
|1|Classics|1|891|Timberland Sky|31|1|
|1|Classics|1|358|Gilmore Boiled|31|2|
|1|Classics|1|951|Voyage Legally|28|3|
|1|Comedy|2|1000|Zorro Ark|31|1|
|1|Comedy|2|127|Cat Coneheads|30|2|
|1|Comedy|2|638|Operation Operation|27|3|

# Actor Insights <a name='actin'></a>

For this entire analysis on actors - we will need to create a new base table as we will need to introduce the <code>dvd_rentals.film_actor</code> and <code>dvd_rentals.actor</code> tables to extract all the required data points we need for the final output.

## Creating Joint Table

```SQL
DROP TABLE IF EXISTS actor_joint_dataset;
CREATE TEMP TABLE actor_joint_dataset AS
SELECT
  rental.customer_id,
  rental.rental_id,
  rental.rental_date,
  film.film_id,
  film.title,
  actor.actor_id,
  actor.first_name,
  actor.last_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
-- different to our previous base table as we know use actor tables
INNER JOIN dvd_rentals.film_actor
  ON film.film_id = film_actor.film_id
INNER JOIN dvd_rentals.actor
  ON film_actor.actor_id = actor.actor_id;
```

## Top Actor Count 

```SQL
DROP TABLE IF EXISTS top_actor_counts;
CREATE TEMP TABLE top_actor_counts AS
WITH actor_counts AS (
  SELECT
    customer_id,
    actor_id,
    first_name,
    last_name,
    COUNT(*) AS rental_count,
    -- we also generate the latest_rental_date just like our category insight
    MAX(rental_date) AS latest_rental_date
  FROM actor_joint_dataset
  GROUP BY
    customer_id,
    actor_id,
    first_name,
    last_name
),
ranked_actor_counts AS (
  SELECT
    actor_counts.*,
    DENSE_RANK() OVER (
      PARTITION BY customer_id
      ORDER BY
        rental_count DESC,
        latest_rental_date DESC,
        -- just in case we have any further ties, we'll throw in the names too!
        first_name,
        last_name
    ) AS actor_rank
  FROM actor_counts
)
SELECT
  customer_id,
  actor_id,
  first_name,
  last_name,
  rental_count
FROM ranked_actor_counts
WHERE actor_rank = 1;
```
|Customer Id|Actor Id|First Name|Last Name|Rental Count|
|---|---|---|---|---|
|1|37|VAL|BOLGER|6|
|2|107|GINA|DEGENERES|5|

------

# Actor Recommendations <a name='actrec'></a>

## Actor Film Counts

To generate a temo table which gets the actors and an aggregated total counts of their movies which have been rented from across the database.

```SQL
DROP TABLE IF EXISTS actor_film_counts;
CREATE TEMP TABLE actor_film_counts AS
WITH film_counts AS (
  SELECT
    film_id,
    COUNT(DISTINCT rental_id) AS rental_count
  FROM actor_joint_dataset
  GROUP BY film_id
)
SELECT DISTINCT
  actor_joint_dataset.film_id,
  actor_joint_dataset.actor_id,
  -- why do we keep the title here? can you figure out why?
  actor_joint_dataset.title,
  film_counts.rental_count
FROM actor_joint_dataset
LEFT JOIN film_counts
  ON actor_joint_dataset.film_id = film_counts.film_id;
```

## Actor Film Exclusions

Similar to the category, we have to recommend only those movies of an actor to a customer, which they have not seen before.

> We can perform the same steps we used to create the <code>category_film_exclusions</code> table - however we also need to <code>UNION</code> our exclusions with         the relevant category recommendations that we have already given our customers.

> The rationale behind this - customers would not want to receive a recommendation for the same film twice in the same email!

```SQL
DROP TABLE IF EXISTS actor_film_exclusions;
CREATE TEMP TABLE actor_film_exclusions AS
-- repeat the first steps as per the category exclusions
-- we'll use our original complete_joint_dataset as the base here
-- can you figure out why???
(
  SELECT DISTINCT
    customer_id,
    film_id
  FROM complete_joint_dataset
)
-- we use a UNION to combine the previously watched and the recommended films!
UNION
(
  SELECT DISTINCT
    customer_id,
    film_id
  FROM category_recommendations
);
```
## Final Actor Recommendations

Bringing all temp tables together,

```SQL
DROP TABLE IF EXISTS actor_recommendations;
CREATE TEMP TABLE actor_recommendations AS
WITH ranked_actor_films_cte AS (
  SELECT
    top_actor_counts.customer_id,
    top_actor_counts.first_name,
    top_actor_counts.last_name,
    top_actor_counts.rental_count,
    actor_film_counts.title,
    actor_film_counts.film_id,
    actor_film_counts.actor_id,
    DENSE_RANK() OVER (
      PARTITION BY
        top_actor_counts.customer_id
      ORDER BY
        actor_film_counts.rental_count DESC,
        actor_film_counts.title
    ) AS reco_rank
  FROM top_actor_counts
  INNER JOIN actor_film_counts
    -- join on actor_id instead of category_name!
    ON top_actor_counts.actor_id = actor_film_counts.actor_id
  -- This is a tricky anti-join where we need to "join" on 2 different tables!
  WHERE NOT EXISTS (
    SELECT 1
    FROM actor_film_exclusions
    WHERE
      actor_film_exclusions.customer_id = top_actor_counts.customer_id AND
      actor_film_exclusions.film_id = actor_film_counts.film_id
  )
)
SELECT * FROM ranked_actor_films_cte
WHERE reco_rank <= 3;
```
|Customer_Id|first_name|last_name|rental_count|title|film_id|actor_id|reco_rank|
|---|---|---|---|---|---|---|---|
|1|Val|Bolger|6|Primary Glass|697|37|1|
|1|Val|Bolger|6|Alaska Phantom|12|37|2|
|1|Val|Bolger|6|Metropolis Coma|572|37|3|















/* -----------------------------
################################
### Category Recommendations ###
################################
--------------------------------*/


/* --------------------------------------------------------------
1. Generate a summarised film count table with the category
included, we will use this table to rank the films by popularity
  * `film_counts`
---------------------------------------------------------------- */

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


/* ---------------------------------------------------
2. Create a previously watched films for the top 2
categories to exclude for each customer
  * `category_film_exclusions`
---------------------------------------------------- */

DROP TABLE IF EXISTS category_film_exclusions;
CREATE TEMP TABLE category_film_exclusions AS
SELECT DISTINCT
  customer_id,
  film_id
FROM complete_joint_dataset;

/* -------------------------------------------------------------------------
3. Finally perform an anti join from the relevant category films on the
exclusions and use window functions to keep the top 3 from each category
by popularity - be sure to split out the recommendations by category ranking
  * `category_recommendations`
---------------------------------------------------------------------------- */

DROP TABLE IF EXISTS category_recommendations;
CREATE TEMP TABLE category_recommendations AS
WITH ranked_films_cte AS (
  SELECT
    top_categories.customer_id,
    top_categories.category_name,
    top_categories.category_rank,
    -- we use this film_id downstream when we
    -- need to exclude new category recommendations for each customer!
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
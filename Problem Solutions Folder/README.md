# Case Study - Problem Solving Folder

We've got our analysis, and we've formed our base table, all that's left to do is generate the insights and customize our report! 

![gif-plan]()

## Solution Plan Breakdown
* [Category Insights](#catin)
* [Category Recommendations](#catrec)
* [Actor Insights](#actin)
* [Actor Recommendations](#actrec)
* [Final Transformation](#output)

> P.S. if you want to skip all this and skip right to the main SQL script, click [here]() 

------

# Category Insights 

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




## Decisions, Decisions, Decisions...

For part 1 of our table joining journey - we can see that we need to start with the <code>rental</code> table and end at the <code>inventory</code> 
table using the foreign key <code>inventory_id</code>.

#### 💡 Our Purpose?

> We need to generate the rental_count calculation - the number of films that a customer has watched in a specific category. 
Thus, we need to keep all of the customer rental records from <code>dvd_rentals.rental</code> and match up each record with its equivalent 
<code>film_id</code> value from the <code>dvd_rentals.inventory</code> table.

### Left-Join V/S Inner-Join

Here are a few unknowns that we need to address as we are matching the <code>inventory_id</code> foreign key between the <code>rental</code> and 
<code>inventory</code> tables.

1. How many records exist per <code>inventory_id</code> value in <code>rental</code> or <code>inventory</code> tables?
2. How many overlapping and missing unique foreign key values are there between the two tables?

The best way to answer these questions is to follow a 2-phase approach where we generate a hypotheses and then try to validate them. 

### Hypotheses - Join Part 1

1. The number of unique <code>inventory_id</code> records will be equal in both <code>dvd_rentals.rental</code> and <code>dvd_rentals.inventory</code> tables.
2. There will be a multiple records per unique <code>inventory_id</code> in the <code>dvd_rentals.rental</code> table.
3. There will be multiple <code>inventory_id</code> records per unique <code>film_id</code> value in the <code>dvd_rentals.inventory</code> table.

You can find the SQL code I've followed to validate these hypotheses [here](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/Data%20Join%20Folder/Hypotheses.sql). 

This finally gives us the green signal to implement our Joins. 

![funny-gif]()

After performing this analysis we can conclude there is in fact no difference between running a <code>LEFT JOIN</code> or an <code>INNER JOIN</code>

We can confirm the same with the following query:

```sql
DROP TABLE IF EXISTS left_rental_join;
CREATE TEMP TABLE left_rental_join AS
SELECT
  rental.customer_id,
  rental.inventory_id,
  inventory.film_id
FROM dvd_rentals.rental
LEFT JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id;

DROP TABLE IF EXISTS inner_rental_join;
CREATE TEMP TABLE inner_rental_join AS
SELECT
  rental.customer_id,
  rental.inventory_id,
  inventory.film_id
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id;

-- check the counts for each output (bonus UNION usage)
-- note that these parantheses are not really required but it makes
-- the code look and read a bit nicer!
(
  SELECT
    'left join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT inventory_id) AS unique_key_values
  FROM left_rental_join
)
UNION
(
  SELECT
    'inner join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT inventory_id) AS unique_key_values
  FROM inner_rental_join
);
```
|Join_Type|Record_Count|Unique_Key_Values|
|---|---|---|
|inner-join|16044|4580|
|left-join|16044|4580|

### Hypotheses - Join Part 2 

We now go through our assumptions to join our output from part 1. We go through the checlist for <code>dvd_rentals.inventory</code> and <code>dvd_rentals.film</code> tables. 

You can find the SQL implemmentation [here]()

Once again, there is no difference between the <code>LEFT JOIN</code> or an <code>INNER JOIN</code>, as proven by

```SQL

DROP TABLE IF EXISTS left_join_part_2;
CREATE TEMP TABLE left_join_part_2 AS
SELECT
  inventory.inventory_id,
  inventory.film_id,
  film.title
FROM dvd_rentals.inventory
LEFT JOIN dvd_rentals.film
  ON film.film_id = inventory.film_id;

DROP TABLE IF EXISTS inner_join_part_2;
CREATE TEMP TABLE inner_join_part_2 AS
SELECT
  inventory.inventory_id,
  inventory.film_id,
  film.title
FROM dvd_rentals.inventory
LEFT JOIN dvd_rentals.film
  ON film.film_id = inventory.film_id;

-- check the counts for each output (bonus UNION usage)
-- note that these parantheses are not really required but it makes
-- the code look and read a bit nicer!
(
  SELECT
    'left join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT film_id) AS unique_key_values
  FROM left_join_part_2
)
UNION
(
  SELECT
    'inner join' AS join_type,
    COUNT(*) AS record_count,
    COUNT(DISTINCT film_id) AS unique_key_values
  FROM inner_join_part_2
);

```
|Join_Type|Record_Count|Unique_Key_Values
|---|---|---|
|inner-join|4581|958|
|left-join|4581|958|



### Bringing it all together 

![funny-meme](https://imgflip.com/i/5ows21)

Kudos on making it this far! All that's left to do is bring our tables together. 

Joining all 4 parts together would look a little like this:

```SQL 
DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  film_category.category_id,
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

SELECT * FROM complete_joint_dataset limit 2;
```
|Customer_Id|Film_Id|Title|category_id|category|
|---|---|---|---|---|
|130|80|BLANKET BEVERLY|8|Family|
|459|333|FREAKY POCUS|12|Music|

#### Stick around, let's find out how to use this base table to calculate our aggregations! 👇

[![problem-solving](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/view-problem-solving-folder.svg)](https://github.com/iaks23/Marketing-Analytics-Case-Study/tree/main/Problem%20Solutions%20Folder)


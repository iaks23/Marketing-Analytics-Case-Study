### Exploratory Data Analysis

The ERD below explains the 7 different tables we have to work with and the relationship between them. 

<p align="center">
  <img width="650" height="350" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/ERD.png">
</p>

At first look, it is clear that most of the data that we require is not immediately retrived from the available tables, rather we must be performing some kind of minor steps before we reach a target state. 

Though it may seem counter-intuitive, it is useful to start with the <code>target state</code> first.
  
Remembering our [requirements](https://github.com/iaks23/Marketing-Analytics-Case-Study#reqs), we can break down those 5 major ones into 9 smaller ones that are easier to understand.

### Breakdown of Requirements

#### Category Data Points

1. Top ranking category name: <code>cat_1</code>
2. Top ranking category customer insight: <code>insight_cat_1</code>
3. Top ranking category film recommendations: <code>cat_1_reco_1</code>, <code>cat_1_reco_2</code>, <code>cat_1_reco_3</code>
4. 2nd ranking category name: <code>cat_2</code>
5. 2nd ranking category customer insight: <code>insight_cat_2</code>
6. 2nd ranking category film recommendations: <code>cat_2_reco_1</code>, <code>cat_2_reco_2</code>, <code>cat_2_reco_3</code>

#### Actor Data Points

7. Top actor name: <code>actor</code>
8. Top actor insight: <code>insight_actor</code>
9. Actor film recommendations: <code>actor_reco_1</code>, <code>actor_reco_2</code>, <code>actor_reco_3</code>

Along with this, we also require <code>rental_count</code>, <code>average_comparison</code>, <code>percentile</code>, <code>actor_name</code> in order to also print the insights about each customer.

The resulting table will be a commbination of these columns and each row would be for a unique <customer_id>. Knowing this, we can take a step further and identify all key columns from te existing tables that will help us derive the information required above. 

![key_coulmns](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/key-columns.png)

### Identifying Key Columns

Here we can see that the column <code>rental_count</code> seems to determine a lot of other columns such as <code>average_comparison</code>, <code>percentile</code> <code>category_ranking</code>and even the <code>category_percentage</code>

So if we need to generate the reverse engineered datasets required to calculate this rental_count at a customer_id level - or simply put the number of films that a customer has watched in a specific category--

> We need two main details to achieve this:
* <code>customer_id</code>
* <code>category_name</code>

### Data Mapping Journey

From here, it is evident one table is not going to have all the information we need, neither are a combination of two tables. Thus, we can break our Data Journey into <strong> four </strong> steps before deciding on a join. 

💡 We are currently only focusing on getting the first 4 requirements met, we will come back to requirement 5 later.

#### Step 1:

> Start with <code>dvd_rentals.rental</code> table & join it with the <code>dvd_rentals.inventory</code> to obtain <code>customer_id</code>

#### Step 2:

> Connect <code>dvd_rentals.inventory</code> with <code>dvd_rentals.film</code> to get the ID's of the films and titles a particular customer has seen. 

#### Step 3:

> Join <code>dvd_rentals.film</code> and <code>dvd_rentals.film_category</code> to obtain what categories these films belong to. 

### Step 4:

> Finally derive <category_name> by joining <code>dvd_rentals.film_category</code> and <code>dvd_rentals.category</code> and mapping the <code>category_id</code> to the name. 


In summary, our Data Mapping Journey looks a little like:


|SNo|Start|End|Join On|
|---|---|---|---|
|Step 1|<code>rental</code>|<code>inventory</code>|<code>inventory_id</code>|
|Step 2|<code>inventory</code>|<code>film</code>|<code>film_id</code>|
|Step 3|<code>film</code>|<code>film_category</code>|<code>film_id</code>|
|Step 4|<code>film_category</code>|<code>category</code>|<code>category_id</code>|


Now that we've finally explored the data, it is time to implement the joins!

[![data_join](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/view-data-join-folder.svg)](https://github.com/iaks23/Marketing-Analytics-Case-Study/tree/main/Data%20Join%20Folder)


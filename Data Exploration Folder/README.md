### Exploratory Data Analysis

Te ERD below explains the 7 different tables we have to work with and the relationship between them. 

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

![key_coulmns]()


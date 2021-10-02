 [![forthebadge](https://forthebadge.com/images/badges/powered-by-netflix.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://forthebadge.com) <img align="left" width="170" height="35" src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white">


# Marketing Campaigns Case Study
> A case study performed on fictitious customer data from DVD Rental Co as a part of the [Serious SQL](https://www.datawithdanny.com) course by Danny Ma.

[![star-useful](https://img.shields.io/badge/🌟-If%20useful-red.svg)](https://shields.io) 
[![view-repo](https://img.shields.io/badge/View-Repo-blueviolet)](https://github.com/iaks23?tab=repositories)
[![view-profile](https://img.shields.io/badge/Go%20To-Profile-orange)](https://github.com/iaks23)

## Table of Contents 📖

* [🚨 Problem Statement](#problem)
* [⚙️ Requirements](#reqs)
* [🔭 Exploratory Data Analysis](#eda)
* [🔁 Data Joining](#join)
* [📖 SQL Problem Solving](#solving)
* [🐣 Final Outputs](#output)



----
# 🚨 Problem Statement <a name='problem'></a>

The customer analytics team at DVD Rental Co has asked for our help with generating the necessary data points required to populate specific parts of this first-ever customer email campaign. Personalized customer emails based off marketing analytics is a winning formula for many digital companies, and this is exactly the initiative that the leadership team at DVD Rental Co has decided to tackle! 


# ⚙️ Requirements <a name='reqs'></a>

The marketing team have shared with us a draft of the email they wish to send to their customers. Take a look at the expected final product, before we dive into the specific requirements. 

<p align="center">
  <img width="350" height="550" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/main-poster.png">
</p>

 ### Requiremment 1: Top 2 Categories
<details> 
  <summary>
     View Requirement Details
  </summary>

 For each customer, we need to identify the top 2 <code> categories </code> for each customer based off their past rental history. These top categories will drive marketing creative images as seen in the sci-fi and rom-com examples in the draft email.
 
 <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req1.gif">
</p>
 
 </details>
 
 ### Requirement 2: Category Film Recommendations

<details> 
  <summary>
    View Requirement Details
  </summary>

 The marketing team has also requested for the 3 most popular <code> films </code> for each customer’s top 2 <code> categories </code>.

There is a catch though - we cannot recommend a film which the customer has already viewed.

If there are less than 3 films available - marketing is happy to show at least 1 film.

> 💡 Any customer which do not have any film recommendations for either category must be flagged out so the marketing team can exclude from the email campaign - this is of high importance!
 
  <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req2.gif">
</p>
 </details>
 
  ### Requirements 3 & 4: Individual Customer Insights
 <details> 
  <summary>
    View Requirement Details
  </summary>

The number of films watched by each customer in their top 2 categories is required as well as some specific <code> insights.</code>

#### For the 1st category, the marketing requires the following insights (requirement 3):

How many total films have they watched in their top category?
How many more films has the customer watched compared to the average DVD Rental Co customer?
How does the customer rank in terms of the top X% compared to all other customers in this film category?

#### For the second ranking category (requirement 4):

How many total films has the customer watched in this category?
What proportion of each customer’s total films watched does this count make?

 > 💡 Note the specific rounding of the percentages with 0 decimal places!
 
 <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req3&4.gif">
</p>
 </details>
 
   ### Reuirement 5: Favorite Actor Recommendations
 <details> 
  <summary>
    View Requirement Details
  </summary>
 
 Along with the top 2 categories, marketing has also requested top <code> actor </code> film recommendations where up to 3 more films are included in the recommendations list as well as the count of films by the top actor.

We have been given guidance by marketing to choose the actors in alphabetical order should there be any ties - i.e. if the customer has seen 5 Brad Pitt films vs 5 George Clooney films - Brad Pitt will be chosen instead of George Clooney.

The same logical business rules apply - in addition any films that have already been recommended in the top 2 categories must not be included as actor recommendations.

If the customer doesn’t have at least 1 film recommendation - they also need to be flagged with a separate actor exclusion flag.

 <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req5.gif">
</p>
 </details>
 
 # 🔭 Exploratory Data Analysis <a name='eda'></a>
 
 The primary step to any data analysis is to first understand the data. The folks at DVD Rental Co. have given us 7 tables to work with. We must be able to derive as much information from these individual tables before deciding what type of joins can be used to obtain a final table that'll help us get answers.
 
 [![DEF](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/view-data-exploration-folder.svg)](https://github.com/iaks23/Marketing-Analytics-Case-Study/tree/main/Data%20Exploration%20Folder)
 
 # 🔁 Data Joining <a name='join'></a>
 
 ### View Summary 👇
<details>
 <summary> EDA Re-Cap </summary>
 
 Data Mapping Journey
 
|SNo|Start|End|Join On|
|---|---|---|---|
|Step 1|<code>rental</code>|<code>inventory</code>|<code>inventory_id</code>|
|Step 2|<code>inventory</code>|<code>film</code>|<code>film_id</code>|
|Step 3|<code>film</code>|<code>film_category</code>|<code>film_id</code>|
|Step 4|<code>film_category</code>|<code>category</code>|<code>category_id</code>|

 </details>
 
 We lastly identified key columns and all the tables that will provide us with these details. It is natural to face a dilemma about what kind of join to use in order to retain only the data that is important to us. Is it going to be a <code>left-join</code> or an <code>inner-join</code> ? Let's try to tackle these questions and truly find the purpose of our joins..
 
[![data_join](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/view-data-join-folder.svg)](https://github.com/iaks23/Marketing-Analytics-Case-Study/tree/main/Data%20Join%20Folder)

# 📖 SQL Problem Solving <a name='solving'></a>
### Data Join Re-Cap 👇

<details>
 <summary> BASE TABLE RECAP </summary>
 
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
 
 </details>


[![data_solutions](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/view-problem-solving-folder.svg)](https://github.com/iaks23/Marketing-Analytics-Case-Study/tree/main/Problem%20Solutions%20Folder)

# 🐣 Final Outputs <a name='output'></a>

We are looking into <code>customer_id = 1</code> rental insights to generate an e-mail template.

<details>
 <summary> Top 2 Categories </summary>
 |Customer_Id|category_name|rental_count|category_rank|
|---|---|---|---|
|1|Classics|6|1|
|1|Comedy|5|2|
 
 </details>

<details>
 <summary> Category Insights </summary>
 <code>First Category Insights </code>
 |Customer_Id|category_name|rental_count|average_comparison|percentile|
|---|---|---|---|---|
|1|Classics|6|4|1|
 
 <code> Second Category Insights </code>
 
 |Customer_Id|category_name|rental_count|total_percentage|
|---|---|---|---|
|1|Comedy|5|16|
 
 
 </details>
 
 <details>
 <summary>Category Recommendations</summary>
 
 |Customer_Id|category_name|category_rank|film_id|title|rental_count|reco_rank|
|---|---|---|---|---|---|---|
|1|Classics|1|891|Timberland Sky|31|1|
|1|Classics|1|358|Gilmore Boiled|31|2|
|1|Classics|1|951|Voyage Legally|28|3|
|1|Comedy|2|1000|Zorro Ark|31|1|
|1|Comedy|2|127|Cat Coneheads|30|2|
|1|Comedy|2|638|Operation Operation|27|3|
 
 </details>
 
 <details>
 <summary> Top Actor </summary>
 |Customer Id|Actor Id|First Name|Last Name|Rental Count|
|---|---|---|---|---|
|1|37|VAL|BOLGER|6|
 </details>
 
 <details>
 <summary> Actor Recommendations </summary>
 |Customer_Id|first_name|last_name|rental_count|title|film_id|actor_id|reco_rank|
|---|---|---|---|---|---|---|---|
|1|Val|Bolger|6|Primary Glass|697|37|1|
|1|Val|Bolger|6|Alaska Phantom|12|37|2|
|1|Val|Bolger|6|Metropolis Coma|572|37|3|
 
 </details>


### Final e-mail template!

*Drumroll please*

Here's what's waiting for the customer!

![final-flyer](https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/datawdanny-resized.png)

----------------------

© Akshaya Parthasarathy, 2021

For feedback, or if you just feel like saying Hi!

[![LINKEDIN](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/akshaya-parthasarathy23)
[![INSTAGRAM](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/aks_sarathy/)
[![REDDIT](https://img.shields.io/badge/Reddit-FF4500?style=for-the-badge&logo=reddit&logoColor=white)](https://www.reddit.com/user/longstoryshort_)

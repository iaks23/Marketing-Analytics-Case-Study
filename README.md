 [![forthebadge](https://forthebadge.com/images/badges/powered-by-netflix.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://forthebadge.com) <img align="left" width="170" height="35" src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white">


# Marketing Campaigns Case Study
> A case study performed on fictitious customer data from DVD Rental Co as a part of the [Serious SQL](https://www.datawithdanny.com) course by Danny Ma.

[![star-useful](https://img.shields.io/badge/🌟-If%20useful-red.svg)](https://shields.io) 
[![view-repo](https://img.shields.io/badge/View-Repo-blueviolet)](https://github.com/iaks23?tab=repositories)
[![view-profile](https://img.shields.io/badge/Go%20To-Profile-orange)](https://github.com/iaks23)

## Table of Contents 📖

* [🚨 Problem Statement](#problem)
* [⚙️ Requirements](#reqs)
* [📖 Business Questions](#questions)
* [🌟 Solutions](#solutions)

----
# 🚨 Problem Statement <a name='problem'></a>

The customer analytics team at DVD Rental Co has asked for our help with generating the necessary data points required to populate specific parts of this first-ever customer email campaign. Personalized customer emails based off marketing analytics is a winning formula for many digital companies, and this is exactly the initiative that the leadership team at DVD Rental Co has decided to tackle! 


# ⚙️ Requirements <a name='reqs'></a>

The marketing team have shared with us a draft of the email they wish to send to their customers. Take a look at the expected final product, before we dive into the specific requirements. 

<p align="center">
  <img width="350" height="550" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/main-poster.png">
</p>

<details> 
  <summary>
    Requirement #1
  </summary>
 
 ### Top 2 Categories

 For each customer, we need to identify the top 2 <code> categories </code> for each customer based off their past rental history. These top categories will drive marketing creative images as seen in the sci-fi and rom-com examples in the draft email.
 
 <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req1.gif">
</p>
 
 </details>

<details> 
  <summary>
    Requirement #2
  </summary>
 
 ### Category Film Recommendations

 The marketing team has also requested for the 3 most popular <code> films </code> for each customer’s top 2 <code> categories </code>.

There is a catch though - we cannot recommend a film which the customer has already viewed.

If there are less than 3 films available - marketing is happy to show at least 1 film.

> 💡 Any customer which do not have any film recommendations for either category must be flagged out so the marketing team can exclude from the email campaign - this is of high importance!
 
  <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req2.gif">
</p>
 </details>
 
 <details> 
  <summary>
    Requirement #3 & #4
  </summary>
 
 ### Individual Customer Insights

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
 
 <details> 
  <summary>
    Requirement #5
  </summary>
 
 Favorite Actor Recommendations

 Along with the top 2 categories, marketing has also requested top <code> actor </code> film recommendations where up to 3 more films are included in the recommendations list as well as the count of films by the top actor.

We have been given guidance by marketing to choose the actors in alphabetical order should there be any ties - i.e. if the customer has seen 5 Brad Pitt films vs 5 George Clooney films - Brad Pitt will be chosen instead of George Clooney.

The same logical business rules apply - in addition any films that have already been recommended in the top 2 categories must not be included as actor recommendations.

If the customer doesn’t have at least 1 film recommendation - they also need to be flagged with a separate actor exclusion flag.

 <p align="center">
  <img width="400" height="320" src="https://github.com/iaks23/Marketing-Analytics-Case-Study/blob/main/images/req5.gif">
</p>
 </details>
 
 # 

----------------------

© Akshaya Parthasarathy, 2021

For feedback, or if you just feel like saying Hi!

[![LINKEDIN](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/akshaya-parthasarathy23)
[![INSTAGRAM](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/aks_sarathy/)
[![REDDIT](https://img.shields.io/badge/Reddit-FF4500?style=for-the-badge&logo=reddit&logoColor=white)](https://www.reddit.com/user/longstoryshort_)

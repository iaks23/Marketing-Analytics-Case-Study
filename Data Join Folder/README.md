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



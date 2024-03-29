# :curry: Case Study 1 - Danny's Diner

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/SQL%20Syntax/Danny's%20Diner.sql).

***

### 1.  What is the total amount each customer spent at the restaurant?

```sql
SELECT s.customer_id, SUM(m.price) as total_spent
FROM sales as s
INNER JOIN menu as m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
#### Steps:
- Use **JOIN** to merge ```sales``` and ```menu``` tables.
- Use **SELECT** to pull ```customer_id``` and the **SUM** of ```price``` from both tables.
- Use **GROUP BY** to find the ```total_spent``` contributed by each customer.

<details>
  <summary> Answer </summary>
  

| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |
  

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.
  
 </details>
 
 
 ***
 
 ### 2. How many days has each customer visited the restaurant?
 
 ```sql
SELECT s.customer_id, COUNT(DISTINCT(s.order_date)) as visit_count
FROM sales as s
GROUP BY s.customer_id;
 ```
 
 #### Steps:
 - The ```sales``` table can contain duplicate dates, as each item ordered has it's own ```order_date``` value. 
 - Thus, we use **DISTINCT** and **COUNT** to find the number of unique days within the ```sales``` table. 
 - Use **GROUP BY** to find the number of days each customer has visited the restaurant.


<details>
  <summary> Answer </summary>
  
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |
  
  - Customer A visited 4 days in total.
  - Customer B visited 6 days in total.
  - Customer C visited 2 days in total.
  
  </details>
  
  ***
  
  ### 3. What was the first item from the menu purchased by each customer?
  
  ```sql
WITH ordered_sales AS (
  SELECT s.customer_id, s.order_date, m.product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank 
  FROM sales as s
  	INNER JOIN menu as m
  ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;
  ```
  
 #### Steps:
 - Create a temporary table, ```ordered_sales```, then use a window function with **DENSE_RANK** to create a new column, ```rank```.
 - Use **DENSE_RANK** as opposed to **RANK** or **ROW_NUMBER** as ```order_date``` has no timestamp. Therefore, there is no distinction made in which item is ordered first, if two or more items are ordered on the same day.
 - Use **GROUP BY** in a new query to show all rows where ```rank = 1```, displaying each customers first purchased item.

<details>
  <summary> Answer </summary>
  
  | customer_id | product_name |
  | ----------- | -----------  |
  | A           | curry        |
  | A           | sushi        |
  | B           | curry        |
  | C           | ramen        |
  
  - Customer A's first items were Curry and Sushi.
  - Customer B's first item was Curry.
  - Customer C's first item was Ramen.
  
 </details>
 
 ***
 
 ### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
 ```sql
SELECT TOP 1 m.product_name, COUNT(s.product_id) AS total
FROM sales AS s
 INNER JOIN menu AS m
 ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total DESC;
 ```
 
 #### Steps:
 - Use **JOIN** to merge the ```sales``` and ```menu``` tables.
 - Use **COUNT** to total the ```product_id```.
 - Use **ORDER BY** to find ```total``` in descending order (highest value first).
 - Use **SELECT TOP 1** to display only the row with the highest value of ```total```.

<details>
  <summary> Answer </summary>
  
  | product_name |    total    |
  | ------------ | ----------- |
  | ramen        | 8           |
  
  - The most purchased item is ramen, being purchased 8 times by all customers.
  
   </details>
   
   ***
   
   ###  5. Which item was the most popular for each customer?
```sql
WITH order_count_CTE AS (
 SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
 FROM menu AS m
	INNER JOIN sales AS s
	ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
    
SELECT customer_id, product_name, order_count
FROM most_popular_CTE 
WHERE rank = 1;
```

#### Steps:
- Create a temporary table, ```order_count_CTE```, then use **DENSE_RANK** to rank the ```order_count``` for each product, in descending order, for each customer.
- Use **GROUP BY** in a new query to show all rows where ```rank = 1```, displaying the most popular item for each customer. 

<details>
  <summary> Answer </summary>
  
  | customer_id | product_name | order_count |
  | ----------- | ------------ | ----------- |
  | A           |	ramen	       | 3           |
  | B           |	sushi	       | 2           |
  | B           |	ramen	       | 2           |
  | B           |	curry	       | 2           |
  | C           |	ramen	       | 3           |
  
  - The most popular item for Customers A and C is Ramen, with 3 orders.
  - The most popular item for Customer B is Ramen, Sushi, and Curry, tied with 2 orders each.
  
</details>
   
***


### 6. Which item was purchased first by the customer after they became a member?
```sql
WITH CTE AS (
 SELECT s.customer_id, m.product_name, s.order_date, ms.join_date,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS DR
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
 WHERE s.order_date >= ms.join_date
)
SELECT customer_id, product_name, order_date
FROM CTE 
WHERE DR = 1;
```

#### Steps:
- Create a temporary table ```CTE```, to use a window function to partition ```customer_id``` by ```order_date```.
- Then within the temporary table, filter ```order_date``` to be on the same date or after ```join_date```.
- Finally, filter a new query to find rows where ```DR = 1```, displaying each customers first purchase after becoming a member.
<details>
  <summary> Answer </summary>
  
  | customer_id | product_name |  order_date  |
  | ----------- | ------------ | ------------ |
  | A           |	curry	       | 2021-01-07   |
  | B           |	sushi	       | 2021-01-09   |
  
  - Customer A's first purchase post-membership was Curry.
  - Customer b's first purchase post-membership was Sushi.

</details>
   
***

### 7. Which item was purchased just before the customer became a member?

#### Solution 1
```sql
WITH CTE AS (
 SELECT s.customer_id, s.order_date, ms.join_date, s.product_id,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS DR
 FROM sales AS s
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
 WHERE s.order_date < ms.join_date
	)
SELECT customer_id, order_date, product_name
FROM CTE 
 INNER JOIN menu AS m 
 ON CTE.product_id = m.product_id
WHERE DR = 1;
```

#### Solution 2
```sql
WITH CTE AS (
 SELECT s.customer_id, s.order_date, ms.join_date, s.product_id, product_name,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS DR
 FROM sales AS s
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
 WHERE s.order_date < ms.join_date
)
SELECT customer_id, order_date, product_name
FROM CTE 
WHERE DR = 1;
```
These two solutions only differ in where the second ```join``` of the ```menu``` table occurs. With both joins occuring within the temporary table for **Solution 1**, while the second join occurs outside ofthe temporary table for **Solution 2**.

I listed these solutions seperately as note to explore optimization in the future. That is to say, within a larger dataset with millions of rows, would one of these solutions notably outperform the other in terms of completion time?


#### Steps:
- Create a temporary table, then use a window function to partition ```customer_id``` by ```order_date```, in descending order.
- Then within the temporary table, filter ```order_date``` to be a date before ```join_date```.
- Finally, filter a new query to find rows where ```DR = 1```, displaying each customers last purchase before becoming a member.

<details>
  <summary> Answer </summary>
  
  | customer_id | product_name |  order_date  |
  | ----------- | ------------ | ------------ |
  | A           | sushi        | 2021-01-01   |
  | A           |	curry	       | 2021-01-01   |
  | B           |	sushi	       | 2021-01-04   |

</details>
   
***

### 8. What is the total items and amount spent for each member before they became a member?
```sql
SELECT s.customer_id,  COUNT(DISTINCT s.product_id) AS unique_item_purchase, SUM(price) AS total_amount_spent
FROM sales AS s
	INNER JOIN members AS ms
	ON s.customer_id = ms.customer_id
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
WHERE s.order_date < ms.join_date
GROUP BY s.customer_id;
```

#### Steps:
- Filter the query to select rows where ```order_date``` is value before ```join_date```.
- Use **COUNT** and **DISTINCT** together to find the total of unique ```product_id``` values.
- Use **GROUP BY** to find ```total_amount_spent``` per each customer.

<details>
  <summary> Answer </summary>
  
  | customer_id | unique_item_purchase |  total_amount_spent  |
  | ----------- | ------------ | ------------ |
  | A           | 2            | 25           |
  | B           | 2	       | 40           |
	
- Customer A purchased 2 items and spent $25, prior to membership.
- Customer B purchased 2 items and spent $40, prior to membership.
</details>
   
***

###  9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
#### Solution 1
```sql
WITH CTE AS (
 SELECT s.customer_id, m.product_id, m.product_name, m.price, order_date
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id=m.product_id
)
SELECT customer_id, SUM(CASE 
		WHEN product_name = 'Sushi' THEN (2*10*price) 
		ELSE (price * 10) 
		END) AS total_points
FROM CTE
GROUP BY customer_id;
```

#### Solution 2
```sql
WITH customer_points AS (
	SELECT *, CASE 
		WHEN product_id = 1 THEN (2*10*price)
		ELSE (price * 10)
		END AS points
	FROM menu
)
SELECT s.customer_id, SUM(p.points) AS total_points
FROM customer_points AS p
  INNER JOIN sales AS s 
  ON p.product_id = s.product_id
GROUP BY s.customer_id;
```

For Question 9, I present two solutions that provide an identical result. Similar to the consideration presented in [```Question 7```](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/Solutions.md#7-which-item-was-purchased-just-before-the-customer-became-a-member), I was curious as to which solution would be more optimal in terms of completion time within a larger dataset. I will revisit this topic in the future.

#### Steps:
<details>
  <summary> Solution 1 </summary>
	
- Create a temporary table, joining the ```sales``` table to the ```menu``` table.
- Use a **CASE** expression in order to calculate the **SUM** of customer points, depending on their transaction history.
- Use **GROUP BY** to display ```total_points``` for each customer.
	
</details>

<details>
  <summary> Solution 2 </summary>
	
- Create a temporary table ```customer_points```, and use a **CASE** expression to calculate the points gained for each transaction in a customers' transaction history.
- Join ```customer_points``` to the ```sales``` table in order to calculate the **SUM** of customers points.
- Use **GROUP BY** to display ```total_points``` for each customer.
	
</details>

<details>
  <summary> Answer </summary>
	
| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |
	
- Customer A had 860 points.
- Customer B had 940 points.
- Customer C has 360 points.

</details>
   
***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
#### Solution 1 
```sql
WITH CTE AS (
 SELECT ms.customer_id, m.product_id, m.product_name, m.price, order_date, join_date
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id=m.product_id
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
)
SELECT customer_id, 
	SUM(CASE 
		WHEN product_name = 'sushi' THEN (2*10*price)
		WHEN order_date BETWEEN join_date AND DATEADD(day, 6, join_date)  THEN (2*10*price) 
		ELSE (price * 10) 
		END) AS customer_points
FROM CTE
WHERE order_date < EOMONTH('2021-01-31')
GROUP BY customer_id;
```

#### Solution 2 
```sql
WITH DATES_CTE AS (
 SELECT *,
	DATEADD(day, 6, join_date) AS double_points_valid
 FROM members AS ms 
)
SELECT d.customer_id,
	SUM(CASE 
	WHEN m.product_name = 'sushi' THEN 2*10*m.price
	WHEN s.order_date BETWEEN d.join_date AND d.double_points_valid THEN 2*10*m.price
	ELSE 10*m.price
	END) AS points
FROM DATES_CTE AS d
  INNER JOIN sales AS s 
  ON d.customer_id = s.customer_id
  INNER JOIN menu AS m 
  ON s.product_id = m.product_id
WHERE s.order_date < EOMONTH('2021-01-31')
GROUP BY d.customer_id;
```

For Question 10, I present two solutions that provide an identical result. Similar to the consideration presented in [```Question 9```](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/Solutions.md#9-if-each-1-spent-equates-to-10-points-and-sushi-has-a-2x-points-multiplier---how-many-points-would-each-customer-have), I was curious as to which solution would be more optimal in terms of completion time within a larger dataset. I will revisit this topic in the future.

#### Steps:
<details>
  <summary> Solution 1 </summary>
	
- Create a temporary table, joining the ```sales``` table to the ```menu``` and ```members``` tables.
- Use a **CASE** expression in order to calculate the **SUM** of customer points, depending on their transaction history.
- Filter results to only include transactions within the month of January. 
- Use **GROUP BY** to display ```total_points``` for each customer.
	
Our assumptions for the CASE expression:
* If a non-member customer purchases any item besides sushi, they will receive 10 points per $1 spent. 
* If a non-member customer purchases sushi, they will recieve 20 points per $1 spent. 
* From the customers ```join_date``` and the following 7 days (inclusive), they received double points per dollar spent on ALL purchases.
	
</details>

<details>
  <summary> Solution 2 </summary>
	
- Create a temporary table ```DATES_CTE``` to create a calculated column ```double_points_valid``` within the ```members``` table.
- Use a **CASE** expression in order to calculate the **SUM** of customer points, depending on their transaction history.
- Filter results to only include transactions within the month of January. 
- Use **GROUP BY** to display ```total_points``` for each customer.
  
Our assumptions for the CASE expression:
* If a non-member customer purchases any item besides sushi, they will receive 10 points per $1 spent. 
* If a non-member customer purchases sushi, they will recieve 20 points per $1 spent. 
* If the transaction occurs between the customers ```join_date``` and the date of ```double_points_valid```, they receive double points per dollar spent on ALL purchases.
	
</details>

<details>
  <summary> Answer </summary>
  
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

- Customer A has 1370 total points.
- Customer B has 820 total points.
	
</details>
   
***
## Bonus Questions

### Bonus 1. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
```sql
WITH CTE AS (
 SELECT s.customer_id, s.order_date, m.product_name, m.price
 FROM sales AS s, menu AS m
 WHERE s.product_id = m.product_id
)

SELECT c.customer_id, order_date, product_name, price,
	(CASE  
	WHEN ms.customer_id IS NOT NULL AND order_date >= ms.join_date THEN 'Y' 
	ELSE 'N'
	END ) AS member
FROM CTE AS c
 LEFT JOIN members AS ms 
 ON c.customer_id = ms.customer_id;
```

#### Steps:
- Create temporary table ```CTE```, joining the ```sales``` table to the ```menu``` table.
- Join the ```CTE``` table to the ```members``` table.
- Use a **CASE** expression in order to determine if a customer is a member or not.
- Display intended result.

<details>
  <summary> Answer </summary>
	
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

</details>

### Bonus 2. Rank All The Things - Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.
```sql
WITH CTE AS (
 SELECT s.customer_id, s.order_date, m.product_name, m.price,
	(CASE  
	WHEN order_date >= ms.join_date THEN 'Y' 
	WHEN order_date < ms.join_date THEN 'N'
	ELSE 'N' END ) AS member
 FROM sales AS s
	LEFT JOIN menu AS m 
	ON s.product_id = m.product_id
	LEFT JOIN members AS ms 
	ON s.customer_id = ms.customer_id
)

SELECT *, (CASE 
	WHEN member = 'N' THEN NULL 
	ELSE RANK() OVER(PARTITION BY c.customer_id, member ORDER BY order_date)
	END ) as ranking
FROM CTE AS c;
```
> **Note**
> The temporary table ```CTE``` functions as an alternative solution to the solution I presented in [Bonus 1](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/Solutions.md#bonus-1-join-all-the-things---recreate-the-table-with-customer_id-order_date-product_name-price-member-yn)
#### Steps:
- Create a temporary table, joining the ```sales``` table to the ```menu``` and ```members``` tables.
- Use a **CASE** expression in order to determine if a customer is a member or not.
- In the new query, Use a new **CASE** expression to create a ranking for customers.
- Partition by ```customer_id``` and ```member```, ordered by ```order_date```.

<details>
  <summary> Answer </summary>
  
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL
</details>
   
***


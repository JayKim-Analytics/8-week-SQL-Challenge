# 🍕: Case Study 2 - Pizza Runner - Question Set A

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%202%20-%20Pizza%20Runner/SQL%20Syntax/Pizza%20Metrics.sql).

***

### 1. How many pizzas were ordered?

```sql
SELECT COUNT(order_id) AS total_pizzas
FROM dbo.customer_orders
```

### Steps:
- Use **COUNT** to select the number of rows with an ```order_id``` value, which represents the total number of pizzas ordered.


<details>
	<summary> Answer </summary>

| total_pizzas |
| ------------ |
| 14           |
  
  - There are a total of 14 pizzas ordered.
  
</details>

***

### 2. How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM dbo.customer_orders 
```

### Steps: 
- Use **COUNT** with **DISTINCT** over ```order_id``` to get the unique number of customer orders.


<details>
  <summary> Answer </summary>

| unique_orders |
| ------------- |
| 10            |
  
  - There are 10 unique customer orders.
  
</details>

***


### 3. How many successful orders were delivered by each runner?

```sql
SELECT runner_id, COUNT(order_id) AS sucessful_deliveries
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
```

### Steps:
- Use **SELECT** to query each ```runner_id```and the **COUNT** of ```order_id``` for each runner.
- Use **WHERE** to filter the query and only return results where the order was not cancelled.
- Use **GROUP BY** to ```successful_deliveries``` for each runner.

<details>
  <summary> Answer </summary>
  
| runner_id | sucessful_deliveries |
| --------- | -------------------- |
| 1         | 4                    |
| 2         | 3                    |
| 3         | 1                    |
  
  - Runner 1 had 4 succesful deliveries.
  - Runner 2 had 3 succesful deliveries.
  - Runner 3 had 1 succesful deliveries.
  
</details>

***

### 4. How many of each type of pizza was delivered?

```sql
SELECT pn.pizza_name, COUNT(c.pizza_id) AS pizza_count
FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	INNER JOIN pizza_names AS pn
	ON c.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY pn.pizza_name;
```

### Steps:
- Use **JOIN** to merge the ```customer_orders``` table with ```runner_orders``` and ```pizza_names``` tables.
- Use **WHERE** to filter the query to only return results where the order was not cancelled.
- Use **GROUP BY** to group results by the type of pizza. 

<details>
	<summary> Answer </summary>
  
| pizza_name | pizza_count |
| ---------- | ----------- |
| Meatlovers | 9           |
| Vegetarian | 3           |
  
  - There were 9 orders of the Meatlovers pizza delivered.
  - There were 3 orders of the Vegetarian pizza delivered.
  
</details>

***

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT c.customer_id, pn.pizza_name, COUNT(c.pizza_id) AS pizza_count
FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	INNER JOIN pizza_names AS pn
	ON c.pizza_id = pn.pizza_id
GROUP BY c.customer_id, pn.pizza_name;
```

### Steps:
- Use **JOIN** to merge the ```customer_orders``` table with ```runner_orders``` and ```pizza_names``` tables.
- Use **GROUP BY** to group results by ```customer_id``` and ```pizza_name```.

<details>
	<summary> Answer </summary>
  
| customer_id | pizza_name | pizza_count |
| ----------- | ---------- | ----------- |
| 101         | Meatlovers | 2           |
| 102         | Meatlovers | 2           |
| 103         | Meatlovers | 3           |
| 104         | Meatlovers | 3           |
| 101         | Vegetarian | 1           |
| 102         | Vegetarian | 1           |
| 103         | Vegetarian | 1           |
| 105         | Vegetarian | 1           |
	
- Customer 101 ordered 2 Meatlovers and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers and 1 Vegetarian pizza.
- Customer 103 ordered 3 Meatlovers and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.
	
</details>


***

### 6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT TOP 1 COUNT(order_id) AS order_count
FROM customer_orders 
GROUP BY order_id
ORDER BY order_count DESC;
```

### Steps:
- Use **TOP 1 COUNT** to return only the top result of the query.
- Use **ORDER BY DESC** to order the query with the largest result at the top.

<details>
	<summary> Answer </summary>
	
| order_count | 
| ----------- | 
| 3           | 
	
- The most pizzas delivered in a single order is 3.
	
</details>

***

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT 
	c.customer_id,
	sum(CASE
		WHEN c.exclusions is not null 
			OR c.extras is not null
			THEN 1
		ELSE 0
	END) AS at_least_1_change,
	sum(CASE
		WHEN c.exclusions is null 
			AND c.extras is null
			THEN 1
		ELSE 0
	END) AS no_changes
FROM 
	customer_orders AS c,
	runner_orders AS r
WHERE
	c.order_id = r.order_id
	AND
	r.cancellation IS NULL
GROUP BY c.customer_id

```

### Steps:
- Use **JOIN** to merge the ```customer_orders``` and ```runner_orders``` tables.
- Use **WHERE** to filter results to only included delivered pizzas.
- Use **CASE WHEN** within the **SELECT** statement to find permutations of results with at least 1 change, and no changes.

<details>
	<summary> Answer </summary>
	
| customer_id | at_least_1_change | no_changes |
| ----------- | ----------------- | ---------- |
| 101         | 0                 | 2          |
| 102         | 0                 | 3          |
| 103         | 3                 | 0          |
| 104         | 2                 | 1          |
| 105         | 1                 | 0          |
- Customer 101 had 0 pizzas with a change, and 2 pizzas with no changes.
- Customer 102 had 0 pizzas with a change, and 3 pizzas with no changes.
- Customer 103 had 3 pizzas with a change, and 0 pizzas with no changes.
- Customer 104 had 2 pizzas with a change, and 1 pizzas with no changes.
- Customer 105 had 1 pizzas with a change, and 0 pizzas with no changes.
</details>

***

### 8.  How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT c.order_id
FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
WHERE cancellation IS NULL AND 
	(exclusions IS NOT NULL AND extras IS NOT NULL)

```

### Steps:
- Use **JOIN** to merge the ```customer_orders``` and ```runner_orders``` tables.
- Use **WHERE** to filter results where orders that were not cancelled, and had an exclusion and an extra.

<details>
	<summary> Answer </summary>
	
| order_id | 
| -------- |
| 10       |
	
- There was 1 pizza delivered that had both exclusions and extras.
</details>

***

### 9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT DATEPART(HOUR, order_time) AS hour_of_day, COUNT(order_id) as order_count
	FROM customer_orders AS c
	GROUP BY DATEPART(HOUR, order_time)
```

### Steps:
- Use **DATEPART** to select the ```HOUR``` from ```order_time```.
- Use **GROUP BY** to match the ```HOUR``` with the **COUNT** of ```order_id```. 

<details>
	<summary> Answer </summary>
	
| hour_of_day | order_count |
| ----------- | ----------- |
| 11          | 1           |
| 13          | 3           |
| 18          | 3           |
| 19          | 1           |
| 21          | 3           |
| 23          | 3           |
	
</details>

***

### 10. What was the volume of orders for each day of the week?

```sql
SELECT 
	FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');
```

### Steps:
- Use **FORMAT** and **DATEADD** to add a new column ```day_of_week```.
- Use **COUNT** to query the total amount of pizzas ordered.

<details>
	<summary> Answer </summary>
	
| day_of_week | total_pizzas_ordered |
| ----------- | -------------------- |
| Friday      | 5                    |
| Monday      | 5                    |
| Saturday    | 3                    |
| Sunday      | 1                    |

- Friday had 5 pizzas ordered.
- Monday had 5 pizzas ordered.
- Saturday had 3 pizzas ordered.
- Sunday had 1 pizza ordered.
	
</details>

# 🍕: Case Study 2 - Pizza Runner - Question Set A

## Solution Syntax
View the complete SQL Syntax [here]().

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
- Use **COUNT* with **DISTINCT** over ```order_id``` to get the unique number of customer orders.


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
	
</details>


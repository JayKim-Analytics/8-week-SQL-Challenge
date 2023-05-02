# 🍕 Case Study 2 - Pizza Runner - Question Set B

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%202%20-%20Pizza%20Runner/SQL%20Syntax/Runner%20and%20Customer%20Experience).

***

### 1. How many runners signed up for each 1 week period?
 
```sql 
SELECT runner_id, 
	CASE 
	WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 'Week 1'
	WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-14'THEN 'Week 2'
	ELSE 'Week 3'
	END AS registration_date
FROM runners
GROUP BY runner_id, registration_date
```

### Steps:
- Use **CASE WHEN** expression to assign runners to a week, depending on their date of registration.
- Use **GROUP BY** to group results by 

<details>
	<summary> Answer </summary>
  
| runner_id | registration_date |
| --------- | ----------------- |
| 1         | Week 1            |
| 2         | Week 1            |
| 3         | Week 2            |
| 4         | Week 3            |

- Runners 1 and 2 signed up during the Week 1 period.
- Runner 3 signed up during the Week 2 period.
- Runner 4 signed up during the Week 3 period.

</details>

***

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
WITH CTE AS (
	SELECT ro.runner_id, c.customer_id, DATEDIFF(MINUTE, c.order_time, ro.pickup_time) AS runner_time
	FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	WHERE cancellation IS NULL -- Rows where cancellation is null means that the order was *not* cancelled.
) 

SELECT runner_id, AVG(runner_time) AS average_pickup_time
FROM CTE
GROUP BY runner_id
```

### Steps:
- Use a temporary table ```CTE```, to query results where the time to for each runner to arrive is calculated, as ```runner_time```.
- Query the temporary table, using **AVG** to calculate the average pickup time.
- Use **GROUP BY** to find the average time for each runner.

<details>
	<summary> Answer </summary>
  
| runner_id | average_pickup_time |
| --------- | ------------------- |
| 1         | 15                  |
| 2         | 24                  |
| 3         | 10                  |

- Runner 1 took an average of 15 minutes to pickup the order.
- Runner 2 took an average of 24 minutes to pickup the order.
- Runner 3 took an average of 10 minutes to pickup the order.

</details>


***

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH CTE AS (
	SELECT c.order_id, COUNT(c.order_id) AS pizzas_count, DATEDIFF(MINUTE, c.order_time, ro.pickup_time) AS prep_time
	FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	WHERE cancellation IS NULL -- Rows where cancellation is null means that the order was *not* cancelled.
	GROUP BY c.order_id, c.order_time, ro.pickup_time
) 

SELECT pizzas_count, AVG(prep_time) AS average_prep_time
FROM CTE
GROUP BY pizzas_count

```

### Steps:
- Use a temporary table, ```CTE```, to acquire the pickup time for each order, as well as the number of pizzas within the order.
- Query the temporary table to display the number of pizzas in the ordeer, and the average pickup time as the pizzas' prep time.


<details>
	<summary> Answer </summary>
  
| pizzas_count | average_prep_time |
| ------------ | ----------------- |
| 1            | 12                |
| 2            | 28                |
| 3            | 30                |

- Orders with 1 pizza took an average of 12 minutes to prepare.
- Orders with 2 pizzas took an average of 18 minutes to prepare.
- Orders with 3 pizzas took an average of 30 minutes to prepare.

Based on these results, we could infer that the number of pizzas within an order has an increasing effect on how long the order takes to prepare.
</details>

***

### 4. What was the average distance travelled for each customer?

```sql
SELECT customer_id, AVG(CAST(distance AS INT)) AS average_distance
FROM customer_orders AS c
  INNER JOIN runner_orders AS ro
  ON c.order_id = ro.order_id
WHERE cancellation IS NULL -- Rows where cancellation is null means that the order was *not* cancelled.
GROUP BY customer_id

```

### Steps:
- Use **JOIN** to merge the ```customer_orders``` and ```runners_orders``` tables.
- Use **SELECT** and **AVG** to query the ```customer_id``` and the average distance for each order.
- Use **GROUP BY** to find the average distance travelled for each customer.

<details>
	<summary> Answer </summary>
	
| customer_id | average_distance |
| ----------- | ---------------- |
| 101         | 20               |
| 102         | 16               |
| 103         | 23               |
| 104         | 10               |
| 105         | 25               |

- Customer 101 requires an average of 20 km travel.
- Customer 102 requires an average of 16 km travel.
- Customer 103 requires an average of 23 km travel.
- Customer 104 requires an average of 10 km travel.
- Customer 105 requires an average of 25 km travel.

</details>

***

### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT (MAX(duration) - MIN(duration)) AS delivery_diff 
FROM runner_orders
WHERE cancellation IS NULL
```

### Steps:
- Use **MAX** and **MIN** to query the largest and smallest values of ```duration```, respectively.
- Subtract these values to find difference between longest and shortest delivery times, as ```delivery_diff```.
- Use **WHERE** to only use results where the order was not cancelled.

<details>
	<summary> Answer </summary>
	
| customer_id | 
| ----------- | 
| 30          | 

- The difference between the longest and shortest delivery times is 30 minutes.

</details>

***

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT runner_id, order_id, distance, ROUND(distance/duration *60,2) AS avg_speed
FROM runner_orders
WHERE cancellation IS NULL
```

### Steps:
- Use **ROUND** to calculate the average delivery speed as km/hr for each delivery. 

<details>
	<summary> Answer </summary>
  
| runner_id | order_id | distance | avg_speed |
| --------- | -------- | -------- | --------- |
| 1         | 1        | 20       | 37.5      |
| 1         | 2        | 20       | 44.44     |
| 1         | 3        | 13.4     | 40.2      |
| 2         | 4        | 23.4     | 35.1      |
| 3         | 5        | 10       | 40        |
| 2         | 7        | 25       | 60        |
| 2         | 8        | 23.4     | 93.6      |
| 1         | 10       | 10       | 60        |

- Runner 1 generally had a higher average speed when travelling short distances.
- Runner 2 had the greatest flucation in average speed.
- Runner 3 only had a single delivery, not enough information to infer any trends.

</details>

***

### 7. What is the successful delivery percentage for each runner?

```sql
SELECT runner_id, ROUND(100 * SUM(CASE
	WHEN cancellation IS NOT NULL THEN 0
	ELSE 1 END)/ COUNT(*), 0) AS success_percent
FROM runner_orders
GROUP BY runner_id
```

### Steps:
- Use **CASE WHEN** expression to create a new column ```success_percent```, that represents the percentage of successful deliveries.
- Use **GROUP BY** to display ```success_percent``` for each runner.

<details>
	<summary> Answer </summary>
	
| runner_id | success_percent |
| --------- | --------------- |
| 1         | 100             |
| 2         | 75              |
| 3         | 50              |

- Cancellations are not indicative of a runners ability to deliver! Existing cancellations in the database are marked as 'Restuarant Cancellation' or 'Customer Cancellation'. 
</details>

# 🍕 Case Study 2 - Pizza Runner - Question Set d

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%202%20-%20Pizza%20Runner/SQL%20Syntax/Pricing%20and%20Ratings).

***

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT SUM(pizza_cost) AS total_profit
FROM (	
	SELECT CASE
		WHEN pizza_id = 1 THEN 12
		ELSE 10 
		END AS pizza_cost
	FROM customer_orders
) x
```

### Steps:
* Use a **SUBQUERY** to create a new column, ```pizza_cost```, that describes the price of each pizza on the menu.
* Use **SELECT** on the subquery to find the sum of pizza sales, as ```total_profits```.

<details>
	<summary> Answer </summary>
	
  | total_profit |
  | ------------ |
  | 160 |
  
  * Pizza runner has $160 in profit.
</details>


***

### 2. What if there was an additional $1 charge for any pizza extras? 

```sql
WITH pizza_cost_cte AS (
	SELECT record_id, CASE
		WHEN pizza_id = 1 THEN 12
		ELSE 10 
		END AS pizza_cost
	FROM customer_orders
),
extras_count_cte AS (
	SELECT c.record_id, pizza_id, CAST(COUNT(topping_id) AS INT) AS extras_count
	FROM customer_orders AS c -- order_id, pizza_id, count(topping_id)
	JOIN extras AS e
	ON c.record_id = e.record_id
	GROUP BY c.record_id, pizza_id
),
final_cte AS (
	SELECT c.record_id, c.order_id, pizza_cost, extras, CASE 
		WHEN c.record_id IN (SELECT record_id
							FROM extras_count_cte AS e
							WHERE c.record_id = e.record_id)
		THEN pc.pizza_cost + (SELECT extras_count FROM extras_count_cte AS e WHERE c.record_id = e.record_id)
			ELSE pc.pizza_cost
		END AS cost
		
	FROM customer_orders AS c
	INNER JOIN pizza_cost_cte AS pc 
	ON c.record_id = pc.record_id

)
SELECT SUM(cost) AS total_profit
FROM final_cte

```

### Steps:
* Create three table expressions; ``pizza_cost_cte``, ``extras_count_cte``, and ``final_cte``. 
* ``pizza_cost_cte`` exists to replicate the subquery from the previous question. 
* ``extras_count_cte`` is a query that coutns the total number of extras ingredients present in an order.
* ``final_cte`` creates a new column ``pizza_cost`` that calculates the total cost of the pizza, while adding $1 per extra ingredient.
* Use **SUM** to find the total cost of pizzas with the additional charge for extras, as ``total_profits``


<details>
	<summary> Answer </summary>
  
  | total_profit |
  | ------------ |
  | 160 |
  
  * Pizza runner has $166 in profit.
</details>

***

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset? 

#### Generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. 

```sql
DROP TABLE IF EXISTS order_rating
SELECT order_id, runner_id 
  INTO order_rating
  FROM runner_orders
  WHERE cancellation IS NULL

ALTER TABLE order_rating
ADD rating INT NULL 
UPDATE order_rating 
SET rating = ROUND( 5 * RAND(convert(varbinary, newid())), 0) +1

SELECT * FROM order_rating
```

### Steps:
* Create a new table ``order_rating``, that allows customers to rate the quality of their delivery. 
* Use **SELECT INTO** in order to create a new table and add the existing ``order_id`` and ``runner_id`` values into it.
* Use **ALTER TABLE** to add the ``rating`` column.
* Use **RAND** to generate a random value between 1 and 5 that exists as the ratings for each runner.

<details>
	<summary> Answer </summary>
  
  | order_id | runner_id | rating |
  | -------- | --------- | ------ |
  |  1 |	1	| 2 |
  |  2 |	1	| 3 |
  |  3 |	1	| 4 |
  |  4 |	2	| 4 |
  |  5 |	3	| 3 |
  |  7 |	2	| 2 |
  |  8 |	2	| 3 |
  |  10 |	1	| 4 |
	
</details>

***
 
### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? 

```sql
WITH cte_1 AS (
	SELECT customer_id, c.order_id, order_time, pickup_time, duration, ro.cancellation, rating,
		CASE 
			WHEN duration = 0 THEN NULL
			ELSE ROUND(distance/duration * 60, 2) 
			END AS speed_km_hr,
		CASE 
			WHEN DATEDIFF(MINUTE, c.order_time, ro.pickup_time) < 0 THEN NULL 
			ELSE DATEDIFF(MINUTE, c.order_time, ro.pickup_time) 
			END  AS order_to_pickup_time
	FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	INNER JOIN order_rating AS ord_rat
	ON c.order_id = ord_rat.order_id
),
cte_2 AS (
	SELECT order_id, COUNT(order_id) AS pizza_count
	FROM customer_orders
	GROUP BY order_Id
),
cte_3 AS (
	SELECT customer_id, cte_1.order_id, pizza_count, duration, speed_km_hr, order_to_pickup_time, cancellation, order_time, pickup_time, rating
	FROM cte_1
	INNER JOIN cte_2
	ON cte_1.order_id = cte_2.order_id
)
SELECT * FROM cte_3


UPDATE cte_3 
SET rating = NULL 
WHERE cancellation IS NOT NULL
```

### Steps:
* Create three common table expressions in order to join all necessary information from the ``customer_orders``, ``runner_orders``, and ``order_rating`` tables.
* Use **UPDATE** in order to assign a ``NULL`` value for ``ratings`` where the order was cancelled before delivery. 

<details>
	<summary> Answer </summary>
  
  ![image](https://user-images.githubusercontent.com/56371474/235573314-74e21b6b-f184-40b7-95a6-1ce8c90b0b32.png)

	
</details>

***

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled, how much money does Pizza Runner have left over after these deliveries?

```sql
WITH cte_1 AS (
	SELECT order_id, SUM(pizza_cost) AS total_profit
	FROM (
		SELECT order_id, CASE
			WHEN pizza_id = 1 THEN 12
			ELSE 10 
			END AS pizza_cost
		FROM customer_orders
	) x
	GROUP BY order_id
),
cte_2 AS (
	SELECT order_id, SUM(payment) AS runner_comp
	FROM (
		SELECT order_id, runner_id, SUM(distance) AS total_km_traveled, ROUND(SUM(DISTANCE)*0.30, 2) AS payment
		FROM runner_orders
		WHERE cancellation IS NULL
		GROUP BY order_id,runner_id
	) x
	GROUP BY order_id
)

SELECT (SUM(total_profit) - SUM(runner_comp)) AS pizza_runner_funds
FROM cte_1 
INNER JOIN cte_2
ON cte_1.order_id = cte_2.order_id

```

### Steps:
* Create 2 common table expressions; ``cte_1`` and ``cte_2``. 
* Use ``cte_1`` to assign the appropriate dollar value to each type of pizza.
* Use ``cte_2`` to calculate the monetary compensation for runners at 30 cents per kilometre traveled. 
* Subtract the difference of ``total_profit`` and ``runner_comp`` in order to find Pizza Runner's remaining profit.


<details>
	<summary> Answer </summary>
	
  
  | pizza_runner_funds |
  | ------------------ |
  | 94.44 |
  
  * Pizza Runner is left with $94.44 in profits.
</details> 


***

### Bonus Question: 
### If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

```sql
INSERT INTO pizza_names
VALUES (3, 'Supreme')

INSERT INTO pizza_recipes
VALUES (3, ('1,2,3,4,6,7,8,9,10,11,12'))
```

### Steps:
* Use **INSERT** to add a new option into the ``pizza_names`` table.
* Use **INSERT** to add a new option into the ``pizza_recipes`` table.


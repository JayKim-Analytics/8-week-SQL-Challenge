# 🍕 Case Study 2 - Pizza Runner - Question Set C

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%202%20-%20Pizza%20Runner/SQL%20Syntax/Indgredient%20Optimisation).

***

### Preqrequisite Data Cleaning for Question Set C

#### Add new column 'record_id' 

```sql
ALTER TABLE dbo.customer_orders
ADD record_id INT IDENTITY(1,1);   
```

#### Purpose 
* Add new column ```record_id``` in order to access each individual pizza within an order.


#### Create new table 'clean_pizza_recipes' 
```sql
DROP TABLE IF EXISTS clean_pizza_recipes
CREATE TABLE clean_pizza_recipes (
	pizza_id int,
	topping_id int
)
INSERT INTO clean_pizza_recipes
(pizza_id, topping_id)
VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);
```

#### Purpose 
* Seperate comma-seperated id of ```pizza_recipes``` into multiple rows for easier reference. 


#### Create new table 'clean_pizza_toppings'
```sql
 SELECT	p.pizza_id, p.topping_id, pt.topping_name
 INTO dbo.clean_pizza_toppings
 FROM 
     pizza_recipes1 as p
     JOIN pizza_toppings as pt
     ON p.topping_id = pt.topping_id;
```

#### Purpose
* Combine data of ```clean_pizza_recipes``` with topping name for easier reference of ```topping_name``` and ```topping_id```. 

#### Create new table 'extras'
```sql
SELECT c.record_id, TRIM(e.value) AS topping_id
INTO dbo.extras
FROM customer_orders AS c
CROSS APPLY STRING_SPLIT(c.extras, ',') AS e
```

#### Purpose
* Seperate comma-seperated id of ```extras``` column within ```customer_orders``` into new table for easier reference. 

#### Create new table 'exclusions'
```sql
SELECT c.record_id, TRIM(e.value) AS topping_id
INTO dbo.exclusions
FROM customer_orders AS c
CROSS APPLY STRING_SPLIT(c.exclusions, ',') AS e
```

#### Purpose
* Seperate comma-seperated id of ```exclusions``` column within ```customer_orders``` into new table for easier reference. 

***

### 1. What are the standard ingredients for each pizza?

```sql
SELECT pizza_name, STRING_AGG(topping_name, ',') AS standard_toppings
FROM clean_pizza_toppings AS cpt
  INNER JOIN pizza_names AS p
  ON cpt.pizza_id = p.pizza_id
GROUP BY pizza_name	
```

### Steps:
* Use **JOIN** to merge the ```clean_pizza_toppings``` and ```pizza_names``` tables.
* Use **STRING_AGG** function to aggregate ```topping_names``` into a single comma-seperated value. 
* Use **GROUP BY** to display ```standard_toppings``` for each pizza on the menu.

<details>
	<summary> Answer </summary>
  
| pizza_name | standard_toppings |
| ---------- | ----------------- |
| Meatlovers |	Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami | 
| Vegetarian |	Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce |
  
</details>


***

### 2. What was the most commonly added extra?

```sql
SELECT topping_name, COUNT(DISTINCT record_id) AS added_extras
FROM extras AS e
  INNER JOIN clean_pizza_toppings AS cpt
  ON e.topping_id = cpt.topping_id
WHERE pizza_id = 1
GROUP BY topping_name
ORDER BY added_extras DESC
```

### Steps:
* Use **JOIN** to merge the ```extras``` and ```clean_pizza_toppings``` tables.
* Use **DISTINCT** to filter out unnecessary data. The query without the **DISTINCT** clause will display ```cheese``` as an extra twice, despite it only appearing as an extra once. This is due to its presence as an ingredient in the ```clean_pizza_toppings``` table for both values of ```pizza_id```. 
* Use **COUNT** to display the total number of each extra that was ordered.
* Use **GROUP BY** to display ```added_extras``` for each ```topping_name```.
 

<details>
	<summary> Answer </summary>
	
| topping_name | added_extras |
| ------------ | ------------ |
| Bacon	| 4 |
| Cheese	| 1 | 
| Chicken |	1 |
  
  * Bacon was the most common exclusion.
</details>



***


### 3. What was the most common exclusion?

```sql
SELECT topping_name, COUNT(DISTINCT record_id) AS exclusions_count
FROM exclusions AS e
  INNER JOIN clean_pizza_toppings AS cpt
  ON e.topping_id = cpt.topping_id
GROUP BY topping_name
ORDER BY exclusions_count DESC
```

### Steps:
* Use **JOIN** to merge the ```exclusions``` and ```clean_pizza_toppings``` tables.
* Use **DISTINCT** to filter out unnecessary data. The query without the **DISTINCT** clause will display duplicate toppings. This is due to ```clean_pizza_toppings``` table containing information for both values of ```pizza_id```. 
* Use **COUNT** to display the total number of each exclusion that was requested.
* Use **GROUP BY** to display ```exclusions_count``` for each ```topping_name```.

<details>
	<summary> Answer </summary>
  
| topping_name | exclusions_count |
| ------------ | ---------------- |
| Cheese	| 4 |
| Mushrooms	| 1 | 
| BBQ Sauce |	1 |
  
* Cheese was the most common exclusion.
</details>

***

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following: 

    * Meat Lovers
    * Meat Lovers - Exclude Beef
    * Meat Lovers - Extra Bacon
    * Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
WITH extras_cte AS (
	SELECT record_id, 'Extra ' + STRING_AGG(t.topping_name, ', ') as record_options
	FROM
		customer_orders c
	CROSS APPLY STRING_SPLIT(extras, ',') AS e
	INNER JOIN pizza_toppings AS t
	ON e.value = t.topping_id
	GROUP BY record_id
),
exclusions_cte AS (
	SELECT record_id,
		'Exclude ' + STRING_AGG(t.topping_name, ', ') as record_options
	FROM customer_orders AS c
	CROSS APPLY STRING_SPLIT(exclusions, ',') AS e
	INNER JOIN pizza_toppings AS t
	ON e.value = t.topping_id
	GROUP BY record_id
),
union_cte AS
(
	SELECT * FROM extras_cte
	UNION
	SELECT * FROM exclusions_cte
),

final_cte AS (
	SELECT c.record_id, CONCAT_WS(' - ', p.pizza_name, STRING_AGG(cte.record_options, ' - ')) AS order_item
	FROM
		customer_orders AS c
		INNER JOIN pizza_names AS p
		on c.pizza_id = p.pizza_id
		INNER JOIN union_cte AS cte
		ON c.record_id = cte.record_id
	GROUP BY c.record_id, p.pizza_name
)

ALTER TABLE dbo.customer_orders
ADD order_item VARCHAR(1000) NULL 

UPDATE dbo.customer_orders SET order_item = (SELECT order_item FROM final_cte WHERE customer_orders.record_id = final_cte.record_id) 

```

### Steps:
* Create three table expression; ```extras_cte```, ```exclusions_cte```, and ```union_cte```, which exists to create a queryable union of the two former CTEs. These CTEs query their respective tables to display extras and exclusions in the desire format.
* Create one more table expression, ```final_cte```. This CTE creates a column ```order_item``` which is a string aggregation in the format ```[pizza name] - [exclusions/extras]``` as desired by the question. Then ```order_item``` is matched to its appropriate ```record_id```.
* Use **ALTER TABLE** to add a blank column ```order_item``` to the ```customer_orders``` table. 
* Use **UPDATE** to add the values of ```order_item``` from ```final_cte``` to the column within the ```customer_orders``` table. 

<details>
	<summary> Answer </summary>
  
  
The ```customer_orders``` table after the addition of ```order_item```
  
  ![image](https://user-images.githubusercontent.com/56371474/231321769-14213633-f741-4adf-a4bd-9124122275b6.png)

</details> 

***

###  5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.

    * For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
WITH ingredients_cte AS (
	SELECT c.record_id, p.pizza_name, CASE
		WHEN t.topping_id IN (
			SELECT topping_id FROM extras AS e 
			WHERE c.record_id = e.record_id)
		THEN '2x' + t.topping_name 
		ELSE t.topping_name 
	END AS topping
	
	FROM customer_orders AS c
	INNER JOIN pizza_names AS p
		ON c.pizza_id = p.pizza_id
	INNER JOIN clean_pizza_toppings AS t
		ON c.pizza_id = t.pizza_id
	WHERE t.topping_id NOT IN (
		SELECT topping_id FROM exclusions AS e 
		WHERE c.record_id = e.record_id)
),
list_cte AS (
	SELECT record_id, CONCAT(pizza_name+': ', STRING_AGG(topping, ', ')) AS ingredients_list
	FROM ingredients_cte
	GROUP BY record_id, pizza_name
)

ALTER TABLE dbo.customer_orders
ADD ingredients_list NVARCHAR(1000) NOT NULL DEFAULT ''

UPDATE dbo.customer_orders SET ingredients_list = (SELECT ingredients_list FROM list_cte WHERE customer_orders.record_id = list_cte.record_id)

```

### Steps:
* Create a common table expression; ```ingredients_cte```, to query each topping for all pizzas within each record, in the requested format. 
* Using a second common table expression, ```lit_cte```, use **CONCAT** to concatenate ```pizza_name``` and the string aggregation of ```topping``` into a single column, ```ingredients_list```.
* Use **ALTER TABLE** to add a blank column ```ingredients_list``` to the ```customer_orders``` table. 
* Use **UPDATE** to add the values of ```ingredients_list``` from ```list_cte``` to the column within the ```customer_orders``` table.  
            
<details>
	<summary> Answer </summary>
  
  The ```customer_orders``` table after the addition of the ```ingredients_list``` column.
  
  ![image](https://user-images.githubusercontent.com/56371474/231323433-02c60a57-5f91-43cb-b642-c9b701ddd180.png)
   
</details>

***

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH ingredients_cte AS (
  SELECT c.record_id, t.topping_name, CASE
      WHEN t.topping_id 
        IN (SELECT topping_id FROM extras AS e 
        WHERE e.record_id = c.record_id) 
      THEN 2
      WHEN t.topping_id
        IN (SELECT topping_id FROM exclusions AS e
        WHERE e.record_id = c.record_id) 
      THEN 0
      ELSE 1
    END AS times_used
FROM 
    customer_orders AS c
    INNER JOIN clean_pizza_toppings AS t
    ON c.pizza_id = t.pizza_id
  	INNER JOIN runner_orders AS r
		ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
)
SELECT topping_name, SUM(times_used) AS times_used
FROM ingredients_cte
GROUP BY topping_name
ORDER BY times_used DESC
```

### Steps:
* Use a common table expression, ```ingredients_cte```, to query the quantity of ingredients for each pizza.
* Use a **CASE WHEN** expression to calculate the quantity of ingredients, by referencing the ```extras``` and ```exclusions``` tables, as column ```times_used```. 
* Use **JOIN** as a second join within  ```ingredients_cte```, in order to reference the ```cancellation``` column within ```runner_orders```.
* Use **SUM** when querying ```ingredients_cte```, to find the sum quantity of ingredients.
* Use **GROUP BY** to display the resulting sum for each ingredient.
* Use **ORDER BY** to display the  most frequent ingredients first. 

<details>
	<summary> Answer </summary>

| topping_name | times_used |
| ------------ | ---------- | 
| Bacon |	11 |
| Mushrooms |	11 |
| Cheese  |	10 |
| Chicken |	9 |
| Pepperoni |	9 |
| Salami |	9 |
| Beef |	9 |
| BBQ Sauce	| 8 |
| Peppers | 	3 | 
| Onions	| 3 |
| Tomato Sauce |	3 |
| Tomatoes	| 3 |
  
</details>


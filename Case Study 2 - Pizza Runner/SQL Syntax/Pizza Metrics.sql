/* --------------------------------
   --CASE STUDY #2: PIZZA RUNNER--
   ---------------------------------*/

--Author: Jay Kim
--Completed using: Microsoft SQL Server Management Studio 18


/* -------------------
-- A. Pizza Metrics --
------------------- */

-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) 
FROM dbo.customer_orders

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) 
FROM dbo.customer_orders 

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS sucessful_deliveries
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id

--4. How many of each type of pizza was delivered?
SELECT pn.pizza_name, COUNT(c.pizza_id) AS pizza_count
FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	INNER JOIN pizza_names AS pn
	ON c.pizza_id = pn.pizza_id
WHERE cancellation IS NULL
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, pn.pizza_name, COUNT(c.pizza_id) AS pizza_count
FROM customer_orders AS c
	INNER JOIN runner_orders AS ro
	ON c.order_id = ro.order_id
	INNER JOIN pizza_names AS pn
	ON c.pizza_id = pn.pizza_id
GROUP BY c.customer_id, pn.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1 COUNT(order_id) AS order_count
FROM customer_orders AS c
GROUP BY order_id
ORDER BY order_count DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT count(c.order_id) 
FROM customer_orders C
	INNER JOIN runner_orders ro
	ON c.order_id = ro.order_id
WHERE cancellation IS NULL AND (
	(exclusions IS NULL and extras IS NULL) OR
	(exclusions IS NULL AND extras IS NOT NULL) OR
	(exclusions IS NOT NULL AND extras IS NULL)
	)
GROUP BY c.order_id

-- 8.  How many pizzas were delivered that had both exclusions and extras?
SELECT *
FROM customer_orders C
	INNER JOIN runner_orders ro
	ON c.order_id = ro.order_id
WHERE cancellation IS NULL AND 
	(exclusions IS NOT NULL AND extras IS NOT NULL)

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT DATEPART(HOUR, order_time) AS hour_of_day, COUNT(order_id) as order_count
	FROM customer_orders AS c
	GROUP BY DATEPART(HOUR, order_time)


-- 10. What was the volume of orders for each day of the week?
SELECT 
	FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

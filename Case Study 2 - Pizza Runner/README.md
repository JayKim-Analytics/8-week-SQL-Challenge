# :curry: Case Study 2 - Danny's Diner
<img src = 'https://8weeksqlchallenge.com/images/case-study-designs/2.png' width = "300" >

## :clipboard: Table of Contents
- [Introduction and Problem Statement]()
- [Entity Relationship Diagram]()
- [Creating the Schema and Dataset]()
- [Exploring Example Dataset]()
- [Case Study Questions]()
- [Solutions]()


## Introduction and Problem Statement
### Introduction 
Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

### Problem Statement
He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

## Entity Relationship Diagram
![image](https://user-images.githubusercontent.com/56371474/228993877-f36a2722-7b78-4679-9144-17a883ab9971.png)

## Creating the Schema and Dataset
<details>
  <summary> SQL Code </summary>
  
  
```sql
  CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
```
 
</details>

## Exploring Example Dataset
- The ```runners``` table contains the ```runner_id``` and ```registration_date``` for each of the Pizza Runners.
- The ```customer_orders``` table contains information for each individual pizza within an order. This includes; the type of pizza as ```pizza_id``` , the ingredients to exclude or include extra as ```exclusions``` and ```extras``` respectively, as well as the date and time the pizza was ordered as ```order_time```. 
- The ```runners_orders``` table contains information on orders after they are assigned to a runner. Orders can be cancelled by the restaurant or customer. This includes; the timestamp when the runner picks up the pizza as ```pickup_time```, the distance the runner had to travel as ```distance```, or the amount of time the runner traveled to deliver the pizza as ```duration```.
- The ```pizza_names``` table contains the numerical ID of a pizza, and its name, as ```pizza_id``` and ```pizza_name``` respectively.
- The ```pizza_recipes``` table contains the numerical ID of a pizza, and the toppings used as ingredients, as ```pizza_id``` and ```toppings``` respectively. 
- The ```pizza_toppings``` table contains the numerical ID of each topping, and the names of all available toppings, as ```topping_id``` and ```topping_name``` respectively.

## Case Study Questions
<details>
  <summary> Section A - Pizza Metrics </summary>
  
    1. How many pizzas were ordered?
    2. How many unique customer orders were made?
    3. How many successful orders were delivered by each runner?
    4. How many of each type of pizza was delivered?
    5. How many Vegetarian and Meatlovers were ordered by each customer?
    6. What was the maximum number of pizzas delivered in a single order?
    7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
    8. How many pizzas were delivered that had both exclusions and extras?
    9. What was the total volume of pizzas ordered for each hour of the day?
    10. What was the volume of orders for each day of the week?
 
</details>

<details>
  <summary> Section B - Runner and Customer Experience </summary>
 
    1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
    2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
    3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
    4. What was the average distance travelled for each customer?
    5. What was the difference between the longest and shortest delivery times for all orders?
    6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
    7. What is the successful delivery percentage for each runner?

</details>


<details>
  <summary> Section C - Ingredient Optimisation </summary>
  
    1. What are the standard ingredients for each pizza?
    2. What was the most commonly added extra?
    3. What was the most common exclusion?
    4. Generate an order item for each record in the customers_orders table in the format of one of the following: 
    5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
    6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
  
</details>

<details>
  <summary> Section D - Pricing and Ratings </summary>
  
    1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
    2. What if there was an additional $1 charge for any pizza extras?
    3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
    4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? 
    5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled, how much money does Pizza Runner have left over after these deliveries?

</details>


## Solutions

View the solutions to the case study questions [here.]()

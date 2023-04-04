/* -------------------------------
   --CASE STUDY #2: PIZZA RUNNER--
   ------------------------------- */
-- Dataset Cleaning	--


-- Table 2 : customer_orders 
-- has empty, null values in exclusions column
-- has null, empty, NaN in extras column
-- Need to clean up dataset -> standardize "no exclusions/extras" as NULL value

UPDATE dbo.customer_orders SET 
	exclusions = CASE 
		WHEN exclusions = ' ' THEN NULL
		WHEN exclusions = 'null' THEN NULL
		ELSE exclusions END,
	extras = CASE 
		WHEN extras = ' ' THEN NULL
		WHEN extras = 'null' THEN NULL
		WHEN extras = 'NaN' THEN NULL
		ELSE extras END 

exec sp_help runner_orders


-- Table 3 : runner_orders
-- 'distance' column is inconsistent. Some records display km, others do not.
-- Remove 'km' from all records. In practice, 'km' should be added to column name to ascribe meaning to values.

UPDATE dbo.runner_orders SET
distance = CASE
		WHEN distance LIKE 'null' THEN ' ' 
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance) 
		ELSE distance END,
    
-- cancellation column is inconsistent. Contains empty, NaN, null values

cancellation = CASE
	WHEN cancellation = ' ' THEN NULL 
	WHEN cancellation = 'NaN' THEN NULL
	WHEN cancellation = 'null' THEN NULL
	ELSE cancellation END,
  
-- 'duration' column is inconsistent. Some records display minutes unit, some display minutes as 'min', others have no unit.
-- Remove 'minutes','min' from all records. In pratice, should add 'min" to column name to ascribe meaning to values.

duration = CASE	
	WHEN duration LIKE 'null' THEN ' ' 
	WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
	WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
	ELSE duration END, 
pickup_time = CASE
	WHEN pickup_time LIKE 'null' THEN ' '
	ELSE pickup_time END
  
-- Column types are in incorrect types for later calculations.
ALTER COLUMN pickup_time DATETIME
ALTER COLUMN distance FLOAT
ALTER COLUMN duration INT;

/* Renaming column names, not used for case study solutions.
EXEC sp_rename 'runner_orders.distance', 'distance_km';
EXEC sp_rename 'runner_orders.duration', 'duration_min'
*/

UPDATE dbo.runner_orders
	SET pickup_time =  ' '
	WHERE cancellation IS NOT NULL
  
  
  -- Table 4: pizza_names
-- The pizza_name column is a depreciated type /text/, update to NVARCHAR
ALTER TABLE dbo.pizza_names
ALTER COLUMN pizza_name NVARCHAR(100)


-- Table 5: pizza_recipes
-- The pizza_recipes column is a depreciated type /text/, update to NVARCHAR
ALTER TABLE dbo.pizza_recipes
ALTER COLUMN toppings NVARCHAR(20)


-- Table 6: pizza_toppings
-- The topping_name column is a depreciated type /text/, update to NVARCHAR
ALTER TABLE dbo.pizza_toppings
ALTER COLUMN topping_name NVARCHAR(20)


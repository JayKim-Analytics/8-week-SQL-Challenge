/* --------------------------------
   -- CASE STUDY #3: FOODIE - FI --
   --------------------------------- */

--Author: Jay Kim
--Completed using: Microsoft SQL Server Management Studio 18

/* ---------------------------------
-- C.  Challenge Payment Question --
--------------------------------- */

/*
| plan_id | plan_name     | price |
| ------- | ------------- | ----- |
| 0	      | trial         | 0     |
| 1	      | basic monthly | 9.90  |
| 2	      | pro monthly   | 19.90 |
| 3	      | pro annual    | 199   |
| 4	      | churn         | null  |
*/


DROP TABLE IF EXISTS payments_2020;

with plan_cte AS (
	SELECT customer_id, s.plan_id, plan_name, start_date,  
		LEAD(start_date, 1) OVER (
			PARTITION BY customer_id
			ORDER BY start_date, s.plan_id) AS cutoff_date, -- start date of users new plan, if it exists
		price AS amount
	FROM subscriptions AS s
		JOIN plans AS p
		ON s.plan_id = p.plan_id
	WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
		--AND plan_name NOT IN ('trial', 'churn')
		AND s.plan_id <> 0
),
cte_1 AS (
	SELECT customer_id, plan_id, plan_name, start_date,
		COALESCE(cutoff_date, '2020-12-31') AS cutoff_date, amount
	FROM plan_cte 
	-- months between start_date and cutoff_date indicates # of monthly payments
	-- Annual plan users will make a single payment in 2020
),
-- cte_2 will create new rows for users on monthly plan, 
-- by incrementing start_Date by +1 month while cutoff_date is greater than start_date + 1month
cte_2 AS ( 
	SELECT customer_id, plan_id, plan_name, start_date, cutoff_date, amount
	FROM cte_1

	UNION ALL

	SELECT customer_id, plan_id, plan_name, 
		(DATEADD(mm, 1, start_date)) AS start_date,
		cutoff_date, amount
	FROM cte_2
	WHERE cutoff_date > (DATEADD(mm, 1, start_date))
		AND plan_name NOT IN ('churn', 'pro annual')
),
-- cte-3 deducts money paid for basic plan by pro plan, where user upgraded from basic plan
cte_3 AS (
	SELECT *,
		LAG(plan_id, 1) OVER (
			PARTITION BY customer_id
			ORDER BY start_date) AS last_payment_plan,
		LAG(amount, 1) OVER (
			PARTITION BY customer_id
			ORDER BY start_date) AS last_amount_paid,
		RANK() OVER (
			PARTITION BY customer_id
			ORDER BY start_date) AS payment_ord
	FROM cte_2
),
final_cte AS (
	SELECT customer_id, plan_id, plan_name, start_date AS payment_date, 
		CASE
			WHEN plan_id IN (2,3) AND last_payment_plan = 1
			THEN amount - last_amount_paid
		ELSE amount
		END AS amount,
		payment_ord
	FROM cte_3
	-- WHERE customer_id IN (1,2,13,15,16,18,19)
		--AND plan_name <> 'churn'
	WHERE plan_name <> 'churn'
)

--DROP TABLE IF EXISTS payments_2020 
--CREATE TABLE payments_2020 AS 

SELECT *
INTO payments_2020
FROM final_cte;	

SELECT * FROM payments_2020;

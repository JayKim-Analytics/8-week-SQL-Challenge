# :tv: : Case Study 3 - Foodie Fi - Question Set C

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%203%20-%20Foodie%20Fi/SQL%20Syntax/C%20-%20Challenge%20Payment%20Question.sql).

***

### 1. The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

```

   - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
   - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
   - upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
   - once a customer churns they will no longer make payments

```

***

```sql
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
	WHERE plan_name <> 'churn'
)


SELECT *
INTO payments_2020
FROM final_cte;	

SELECT TOP 5 * FROM payments_2020;
```

### Steps:
- With a CTE, utilize the window function **LEAD** to find the ``start_date`` of plans for each customer.
- With ``cte_1``, query from ``plan_cte`` and use **COALESCE()** to set the value as the last day of a users current plan.
- With ``cte_2``, create a union between ``cte_1`` and a new query to create new rows for users with monthly subscriptions.
- With ``cte_3``, use window functions to retain a users previous subscription plan, the previous amount paid, and the order of payments as  ``last_payment_date``, ``last_amount_paid``, and ``payment_ord`` respectively.
- With ``final_cte``, use the data from ``cte_3`` to reduce a users subscription payment should they upgrade from a basic plan to a pro plan, as ``amount``.
- Insert the values from ``final_cte`` into a new table, ``payments_2020``.


***

<details>
	<summary> Example Output of New Table </summary>

![image](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/assets/56371474/28fded3d-4ff1-4ddf-92a8-6d43472e45b6)


</details>

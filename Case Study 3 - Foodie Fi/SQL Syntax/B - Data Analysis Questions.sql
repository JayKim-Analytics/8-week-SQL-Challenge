/* --------------------------------
   -- CASE STUDY #3: FOODIE - FI --
   --------------------------------- */

--Author: Jay Kim
--Completed using: Microsoft SQL Server Management Studio 18

/* -----------------------------
-- B. Data Analysis Questions --
----------------------------- */

-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions


-- 2. What is the monthly distribution of trial plan ``start_date`` values for our dataset - use the start of the month as the group by value
SELECT DATENAME(mm, start_date) AS months,  COUNT(plan_id) AS trial_plan_counts
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH(start_date), DATENAME(mm, start_date)
ORDER BY MONTH(start_date)

-- 3. What plan ``start_date`` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each ``plan_name``

SELECT plan_name, COUNT(*) AS plan_count
FROM subscriptions AS s
INNER JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name


-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
DECLARE @total_cust float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

SELECT churn_count, ROUND(((churn_count / @total_cust ) * 100.0), 1) AS churn_percent
FROM (
	SELECT COUNT(customer_id) AS churn_count 
	FROM subscriptions	
	WHERE plan_id = 4
) x

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- DECLARE @total_cust float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

WITH churn_post_trial AS ( 
	SELECT customer_id, 
	CASE 
		WHEN 
			plan_id = 4 -- churn
			AND 
			LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0 -- Access prev rows to see if prev plan_id is a trial
		THEN 1
		ELSE 0
	END AS is_churned
	FROM subscriptions
) 

SELECT 
	SUM(is_churned) AS churned_customers,
	FLOOR(SUM(is_churned) / CAST(COUNT(DISTINCT customer_id) AS FLOAT) * 100) AS churn_percent
FROM churn_post_trial

-- 6. What is the number and percentage of customer plans after their initial free trial?

DECLARE @total_cust float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

WITH plans_post_trial AS (
	SELECT 
		plan_id, 
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_order
	FROM subscriptions
	WHERE plan_id <> 0
) 

SELECT p2.plan_name,
	COUNT(p1.plan_id) AS plan_post_trial,
	COUNT(p1.plan_id) / @total_cust * 100 AS percentage
FROM plans_post_trial AS p1
JOIN plans AS p2
ON p1.plan_id = p2.plan_id
WHERE p1.plan_order = 1
GROUP BY p2.plan_name


-- 7. What is the customer count and percentage breakdown of all 5 ``plan_name`` values at ``2020-12-31``?
DECLARE @total_cust float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE start_date <= ('2020-12-31'));

WITH customer_plans AS (
	SELECT 
		customer_id,
		plan_id,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS plans_reverse_order
	FROM subscriptions
	WHERE start_date <= ('2020-12-31')
)

SELECT p.plan_name,
	COUNT(cpl.customer_id) AS total_customers,
	COUNT(cpl.customer_id) / @total_cust * 100 AS customers_percent
FROM customer_plans AS cpl
JOIN plans AS p
ON cpl.plan_id = p.plan_id
WHERE plans_reverse_order = 1
GROUP BY p.plan_name 

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(customer_id) AS customer_count
FROM subscriptions 
WHERE YEAR(start_date) = '2020' AND plan_id = 3

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH join_date_cte AS (
    SELECT customer_id, start_date
    FROM subscriptions
	WHERE plan_id = 0
),
pro_up_date AS (
	SELECT customer_id, start_date AS upgrade_date
	FROM subscriptions
	WHERE plan_id = 3
)

SELECT AVG(DATEDIFF(dd, start_date, upgrade_date)*1.0) AS avg_days_to_annual
FROM join_date_cte AS jd
JOIN pro_up_date AS pu
ON jd.customer_id = pu.customer_id


-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH join_date_cte AS (
    SELECT customer_id, start_date
    FROM subscriptions
	WHERE plan_id = 0
),
pro_up_date AS (
	SELECT customer_id, start_date AS upgrade_date
	FROM subscriptions
	WHERE plan_id = 3
),
date_bins AS (
	SELECT 
		jd.customer_id,
		start_date,
		upgrade_date,
		-- create buckets of 30 days period from 1 to 12 (i.e monthly buckets)
		DATEDIFF(DAY, start_date, upgrade_date)/30 + 1 AS bin
	FROM join_date_cte AS jd
	JOIN pro_up_date AS pu
	ON jd.customer_id = pu.customer_id
)
SELECT CASE 
	WHEN
		bin = 1 THEN CONCAT(bin - 1, ' - ', bin*30, ' days')
		ELSE CONCAT((bin - 1) * 30 + 1, ' - ', bin*30, ' days')
		END AS period,
	COUNT(customer_id) AS total_customers,
	CAST(AVG(DATEDIFF(dd, start_date, upgrade_date)*1.0) AS decimal(5,2)) AS avg_days_to_annual
FROM date_bins
GROUP BY bin

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH next_plan_cte AS (
    SELECT *, 
        LEAD(plan_id, 1) 
        OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
    FROM subscriptions
) 

SELECT COUNT(*) AS downgrade_count
FROM next_plan_cte
WHERE plan_id = 2 AND next_plan = 1

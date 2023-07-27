# 🍎 : Case Study 3 - Foodie Fi - Question Set B

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%203%20-%20Foodie%20Fi/SQL%20Syntax/B%20-%20Data%20Analysis%20Questions.sql).

***

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions
```

### Steps:
- Use **COUNT** with **DISTINCT** to select the total number of unique ```customer_id``` values. 


<details>
	<summary> Answer </summary>

| total_customers |
| --------------- |
| 1000            |
  
  - Foodie-Fi has had a total of 1000 customers.
  
</details>

***

### 2. What is the monthly distribution of trial plan ``start_date`` values for our dataset - use the start of the month as the group by value

```sql
SELECT DATENAME(mm, start_date) AS months,  COUNT(plan_id) AS trial_plan_counts
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTH(start_date), DATENAME(mm, start_date)
ORDER BY MONTH(start_date)
```

### Steps:
- Use **DATENAME** with on ```start_date``` to select the month name as the value to group by.
- Use **WHERE** to only select plans where ```plan_id``` is 0, representing a trial plan.
- Use **ORDER BY** with **MONTH()** function to display results in chronlogical date order. 


<details>
	<summary> Answer </summary>


| months | trial_plan_counts |
| ------ | ----------------- |
| January	| 88 |
| February |	68 |
| March	| 94 |
| April	| 81 |
| May	| 88 |
| June |	79 |
| July | 89 |
| August | 88 |
| September |	87 |
| October	| 79 |
| November | 75 |
| December	| 84 |
    
</details>

*** 

### 3. What plan ``start_date`` values occur after the year 2020 for our dataset? Show the breakdown by count of events for each ``plan_name``

```sql
SELECT plan_name, COUNT(*) AS plan_count
FROM subscriptions AS s
  INNER JOIN plans AS p
  ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name
```

### Steps:
* Use **WHERE** to filter ``start_date`` values that occur after the year 2020.
* Use **GROUP BY** and **COUNT** to show the count of plans that occur after the year 2020.


<details>
	<summary> Answer </summary>

| plan_name | plan_count |
| --------- | ---------- |
| basic monthly	| 8 |
| churn	| 71 |
| pro annual | 63 |
| pro monthly	| 60 |

</details>

***

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
DECLARE @total_cust float = (SELECT COUNT(DISTINCT customer_id) FROM subscriptions);

SELECT churn_count, ROUND(((churn_count / @total_cust ) * 100.0), 1) AS churn_percent
FROM (
	SELECT COUNT(customer_id) AS churn_count 
	FROM subscriptions	
	WHERE plan_id = 4
) x
```

### Steps:
* Declare a temporary variable, ``@total_cust`` to get the total number of customers in the database. This method allows the value to scale as the database increases in size.
* Use a subquery to get the **COUNT** of ``customer_id`` values where their ``plan_id`` is 4, representing a customer who churned.
* Use the ``churn_count`` and ``@total_cust`` values to calculate the percentage of customers who churned, as ``churn_percent``


<details>
	<summary> Answer </summary>

| churn_count | churn_percent |
| ----------- | ------------- |
| 307	| 30.7 |

* 307 customers churned. 30.7% of Foodie-Fi's customers have churned.
  
</details>

***

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql

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
	FLOOR(SUM(is_churned) / @total_cust ) * 100) AS churn_percent
FROM churn_post_trial;
```

### Steps:
* With a CTE, utilize **CASE WHEN** and **LAG()** to find find the count of customers who churned directly after their free trial.
* Use the previous ``@total_cust`` variable to calculate the percentage of customers who churned directly after their free trial.
* Use **FLOOR** to round the percentage to the nearest whole number.


<details>
	<summary> Answer </summary>

| churned_customers	| churn_percent |
| ----------------	| ------------- |
| 92 |	9 |

* 92 customers directly churned. This represents 9% of all customers. 
	
</details>

***

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
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
  INNER JOIN plans AS p2
  ON p1.plan_id = p2.plan_id
WHERE p1.plan_order = 1
GROUP BY p2.plan_name
```

### Steps:
* With a CTE, use a window function to find the progression of current customer plans following their free trial.
* Use **WHERE** to filter the results of **ROW_NUMBER()** to find the plan following the free trial.
* Use the previous ``@total_cust`` variable to calculate the percentage values.

<details>
	<summary> Answer </summary>

| plan_name	| plan_post_trial	| percentage |
| ----------| --------------- | ---------- |
| basic monthly	| 546	| 54.6 |
| churn	| 92 |	9.2 |
| pro annual |	37	| 3.7 |
| pro monthly |	325	| 32.5 |
	
</details>

***

### 7. What is the customer count and percentage breakdown of all 5 ``plan_name`` values at ``2020-12-31``?

```sql
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
```

### Steps:
* With a CTE, use **ROW_NUMBER** to find the progression of customer plans from '2020-12-31', in reverse order.
* Use **WHERE** to filter the results for a customers most current plan, as of '2020-12-31'
* Use the previous ``@total_cust`` variable to calculate the percentage values.  


<details>
	<summary> Answer </summary>

 
| plan_name	| total_customers | customers_percent |
| ----------| --------------- | ----------------- |
| basic monthly	| 224	| 22.4 |
| churn	| 236 |	23.6 |
| pro annual |	195	| 19.5 |
| pro monthly |	326	| 32.6 |
| trial | 19 | 1.9 |
	
</details>

***

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(customer_id) AS customer_count
FROM subscriptions 
WHERE YEAR(start_date) = '2020' AND plan_id = 3
```

### Steps:
* Use **WHERE** to filter the query by year(2020) and ``plan_id``.


<details>
	<summary> Answer </summary>

| customer_count |
| -------------- |
| 195 |

* 195 customers upgraded to an annual plan in 2020. 
	
</details>

***

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
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
```

### Steps:
* With a CTE, filter the query to find ``customer_id`` and ``start_date``, when ``plan_id`` is 0, representing a trial account.
* With a 2nd CTE, filter the query to find ``customer_id`` and ``start_date``, when ``plan_id`` is 3, representing a pro annual account.
* Use **AVG** and **DATEDIFF** to calculate the average number of days until a customer upgraded to an annual account, from their start date.


<details>
	<summary> Answer </summary>

| avg_days_to_annual |
| ------------------ |
| 104.62 |

* It takes a customer an average of 104 days to ugprade to an annual account from their start date.
	
</details>

***

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
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
GROUP BY bin;

```

### Steps:
* With a CTE, filter the query to find ``customer_id`` and ``start_date``, when ``plan_id`` is 0, representing a trial account.
* With a 2nd CTE, filter the query to find ``customer_id`` and ``start_date``, when ``plan_id`` is 3, representing a pro annual account.
* With a 3rd CTE, use **DATEDIFF** to create "bins" representing 30 day periods.
* Use **CASE WHEN** to create a text value representing each 30 day period within the bins.
* Use **AVG** and **DATEDIFF** to calculate the average number of days until a customer upgraded to an annual account, from their start date.


<details>
	<summary> Answer </summary>
  
| period | total_customers | avg_days_to_annual |
| -------| --------------- | ------------------ |
| 0 - 30 days	| 48 | 9.54 |
| 31 - 60 days |	25 |	41.84 |
| 61 - 90 days |	33 | 70.88 |
| 91 - 120 days |	35 |	99.83 |
| 121 - 150 days	| 43 |	133.05 |
| 151 - 180 days	| 35 |	161.54 |
| 181 - 210 days	| 27 |	190.33 |
| 211 - 240 days	| 4 |	224.25 |
| 241 - 270 days	| 5 |	257.20 |
| 271 - 300 days  | 1	| 285.00 |
| 301 - 330 days	| 1 |	327.00 |
| 331 - 360 days  |	1 |	346.00 |


</details>

***

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH next_plan_cte AS (
    SELECT *, 
        LEAD(plan_id, 1) 
        OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan
    FROM subscriptions
) 

SELECT COUNT(*) AS downgrade_count
FROM next_plan_cte
WHERE plan_id = 2 AND next_plan = 1
AND YEAR(start_date) = '2020';
```

### Steps:
* With a CTE, use **LEAD** to partition ``plan_id`` by ``customer_id`` and ``start_date`` to find the progression of a customers subscription.
* Use **WHERE** to filter the query where a customers current plan is 'pro monthly' and their ``next_plan`` is 'basic monthly'.
* Use **COUNT** to find the sum of customers who downgraded their plan in 2020.

<details>
	<summary> Answer </summary>

| downgrade_count |
| --------------- |
| 0 | 


* No customers downgraded their plan from a pro monthly to a basic monthly plan in 2020.
	
</details>

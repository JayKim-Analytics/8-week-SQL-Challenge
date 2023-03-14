/* --------------------------------
   --CASE STUDY #1: DANNY'S DINER--
   ---------------------------------*/

--Author: Jay Kim
--Date: 2023-03-06
--Completed using: Microsoft SQL Server Management Studio 18

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) as total_spent
FROM sales as s
INNER JOIN menu as m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT(s.order_date)) as visit_count
FROM sales as s
GROUP BY s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales AS (
  SELECT s.customer_id, s.order_date, m.product_name,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank 
  FROM sales as s
  	INNER JOIN menu as m
  ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 m.product_name, COUNT(s.product_id) AS total
FROM sales AS s
 INNER JOIN menu AS m
 ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total DESC;

-- 5. Which item was the most popular for each customer?
WITH order_count_CTE AS (
 SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
 FROM menu AS m
	INNER JOIN sales AS s
	ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name
)
    
SELECT customer_id, product_name, order_count
FROM most_popular_CTE 
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS (
 SELECT s.customer_id, m.product_name, s.order_date, ms.join_date,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS DR
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
 WHERE s.order_date >= ms.join_date
	)
SELECT customer_id, product_name, order_date
FROM CTE 
WHERE DR = 1;

-- 7. Which item was purchased just before the customer became a member?
-- Solution 1.
WITH CTE AS (
 SELECT s.customer_id, s.order_date, ms.join_date, s.product_id,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS DR
 FROM sales AS s
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
 WHERE s.order_date < ms.join_date
	)
SELECT customer_id, order_date, product_name
FROM CTE 
 INNER JOIN menu AS m 
 ON CTE.product_id = m.product_id
WHERE DR = 1;

-- Solution 2.
WITH CTE AS (
 SELECT s.customer_id, s.order_date, ms.join_date, s.product_id, product_name,
 	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS DR
 FROM sales AS s
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
 WHERE s.order_date < ms.join_date
	)
SELECT customer_id, order_date, product_name
FROM CTE 
WHERE DR = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,  COUNT(DISTINCT s.product_id) AS unique_item_purchase, SUM(price) AS total_amount_spent
FROM sales AS s
	INNER JOIN members AS ms
	ON s.customer_id = ms.customer_id
	INNER JOIN menu AS m 
	ON s.product_id = m.product_id
WHERE s.order_date < ms.join_date
GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Solution 1.
WITH CTE AS (
 SELECT s.customer_id, m.product_id, m.product_name, m.price, order_date
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id=m.product_id
)
SELECT customer_id, SUM(CASE 
		WHEN product_name = 'Sushi' THEN (2*10*price) 
		ELSE (price * 10) 
		END) AS total_points
FROM CTE
GROUP BY customer_id;

-- Solution 2.
WITH customer_points AS (
	SELECT *, CASE 
		WHEN product_id = 1 THEN (2*10*price)
		ELSE (price * 10)
		END AS points
	FROM menu
)
SELECT s.customer_id, SUM(p.points) AS total_points
FROM customer_points AS p
  INNER JOIN sales AS s 
  ON p.product_id = s.product_id
GROUP BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- Solution 1.
WITH CTE AS (
 SELECT ms.customer_id, m.product_id, m.product_name, m.price, order_date, join_date
 FROM sales AS s
	INNER JOIN menu AS m 
	ON s.product_id=m.product_id
	INNER JOIN members AS ms 
	ON s.customer_id = ms.customer_id
)
SELECT customer_id, 
	SUM(CASE 
		WHEN product_name = 'sushi' THEN (2*10*price)
		WHEN order_date BETWEEN join_date AND DATEADD(day, 6, join_date)  THEN (2*10*price) 
		ELSE (price * 10) 
		END) AS customer_points
FROM CTE
WHERE order_date < EOMONTH('2021-01-31')
GROUP BY customer_id;

-- Solution 2.
WITH DATES_CTE AS (
 SELECT *,
	DATEADD(day, 6, join_date) AS double_points_valid
 FROM members AS ms 
)
SELECT d.customer_id,
	SUM(CASE 
	WHEN m.product_name = 'sushi' THEN 2*10*m.price
	WHEN s.order_date BETWEEN d.join_date AND d.double_points_valid THEN 2*10*m.price
	ELSE 10*m.price
	END) AS points
FROM DATES_CTE AS d
  INNER JOIN sales AS s 
  ON d.customer_id = s.customer_id
  INNER JOIN menu AS m 
  ON s.product_id = m.product_id
WHERE s.order_date < EOMONTH('2021-01-31')
GROUP BY d.customer_id;

/* ------------------
-- BONUS QUESTIONS --
------------------- */

-- Join All The Things
WITH CTE AS (
 SELECT s.customer_id, s.order_date, m.product_name, m.price
 FROM sales AS s, menu AS m
 WHERE s.product_id = m.product_id
)

SELECT c.customer_id, order_date, product_name, price,
	(CASE  
	WHEN ms.customer_id IS NOT NULL AND order_date >= ms.join_date THEN 'Y' 
	ELSE 'N'
	END ) AS member
FROM CTE AS c
 LEFT JOIN members AS ms 
 ON c.customer_id = ms.customer_id;

-- Rank All The Things
WITH CTE AS (
 SELECT s.customer_id, s.order_date, m.product_name, m.price,
	(CASE  
	WHEN order_date >= ms.join_date THEN 'Y' 
	WHEN order_date < ms.join_date THEN 'N'
	ELSE 'N' END ) AS member
 FROM sales AS s
	LEFT JOIN menu AS m 
	ON s.product_id = m.product_id
	LEFT JOIN members AS ms 
	ON s.customer_id = ms.customer_id
)

SELECT *, (CASE 
	WHEN member = 'N' THEN NULL 
	ELSE RANK() OVER(PARTITION BY c.customer_id, member ORDER BY order_date)
	END ) as ranking
FROM CTE AS c;

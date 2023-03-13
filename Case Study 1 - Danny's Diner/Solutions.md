# :curry: Case Study 1 - Danny's Diner

## Solution Syntax
View the complete SQL Syntax [here](https://github.com/JayKim-Analytics/8-week-SQL-Challenge/blob/main/Case%20Study%201%20-%20Danny's%20Diner/SQL%20Syntax/Danny's%20Diner.sql).

***

### 1.  What is the total amount each customer spent at the restaurant?

```sql
SELECT s.customer_id, SUM(m.price) as total_spent
FROM sales as s
INNER JOIN menu as m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
#### Steps:
- Use **JOIN** to merge ```sales``` and ```menu``` tables.
- Use **SELECT** to pull ```customer_id``` and the **SUM** of ```price``` from both tables.
- Use **GROUP BY** to find the ```total_spent``` contributed by each customer.

<details>
  <summary> Answer </summary>
  
  
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |
  

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.
  
 </details>
 
 
 ***

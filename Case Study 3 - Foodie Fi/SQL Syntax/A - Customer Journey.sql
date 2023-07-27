/* --------------------------------
   -- CASE STUDY #3: FOODIE - FI --
   --------------------------------- */

--Author: Jay Kim
--Completed using: Microsoft SQL Server Management Studio 18


/* ----------------------
-- A. Customer Journey --
-------------------------- */


/*
Based off the 8 sample customers provided in the sample from the ```subscriptions``` table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
*/	

SELECT customer_id, plan_name, start_date
FROM subscriptions AS s
INNER JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)

-- Trial automatically updates to pro monthly
/*
Customer 1: Began trial account on August 1st, enjoyed Foodie-Fi so much they upgraded to a basic monthly subscription once their trial ended.
Customer 2: Began trial account on Sept 20th. Enjoyed Foodie-Fi so mcuh that they decided to commit to a pro-annual subscripton once their trial ended.
Customer 11: Began trial on Nov. 11th. Decided that Foodie-Fi was not enjoyment worth the money to them, and cancelled once their free trial ended.
Customer 13: Began trial account on Dec. 15th. Upgraded to a basic monthly account once their trial ended. Upgraded their basic subscription to the pro monthly 3 months later.
Customer 15: Began trial account on March 17th. Upgraded to a pro monthly account after their trial. Then decided they had seen enough and ended their subscription about a month later.
Customer 16: Began trial account on May 31st. Upgraded to a basical monthly after their trial ended. Then love the service so much, they upgraded to a pro annual account after 4 months of subscription.
Customer 18: Began trial account on July 6th. Upgraded to a pro monthly after their trial ended.
Customer 19: Began trial on June 22nd. Upgraded to a pro monthly after theit trial ended. Loved the service so much they upgrade to an annual subscription after 2 months.
*/

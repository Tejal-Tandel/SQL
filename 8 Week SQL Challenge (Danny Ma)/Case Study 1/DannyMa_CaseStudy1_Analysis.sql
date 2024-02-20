------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT s.customer_id, SUM(m.price) AS amount_spent
FROM sales s
JOIN menu m
    ON (s.product_id = m.product_id)
GROUP BY s.customer_id
ORDER BY amount_spent DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS no_of_days_visited
FROM sales s
JOIN menu m
    ON (s.product_id = m.product_id)
GROUP BY s.customer_id
ORDER BY no_of_days_visited DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH cte AS (
    SELECT s.customer_id, 
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rn, 
        m.product_name
    FROM sales s
    JOIN menu m
        ON (s.product_id = m.product_id)
)

SELECT *
FROM cte
WHERE rn = 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 1 m.product_name, COUNT(s.order_date) AS times_sold
FROM sales s
JOIN menu m
    ON (s.product_id = m.product_id)
GROUP BY m.product_name
ORDER BY times_sold DESC;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Which item was the most popular for each customer? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH cte AS (
    SELECT s.customer_id,
    m.product_name, 
    COUNT(s.product_id) AS products_sold,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rn
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT customer_id, product_name, products_sold
FROM cte
WHERE rn = 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH cte AS(
    SELECT s.customer_id, 
        join_date, 
        product_name, 
        order_date,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS rn
    FROM sales s 
    JOIN menu m 
        ON s.product_id = m.product_id
    JOIN members mem
        ON s.customer_id = mem.customer_id
    WHERE s.order_date >= mem.join_date
)

SELECT *
FROM cte
WHERE rn = 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7. Which item was purchased just before the customer became a member? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH cte AS(
    SELECT s.customer_id, 
        join_date, 
        product_name, 
        order_date,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS rnk
    FROM sales s 
    JOIN menu m 
        ON s.product_id = m.product_id
    JOIN members mem
        ON s.customer_id = mem.customer_id
    WHERE s.order_date < mem.join_date
)

SELECT
    customer_id,
    product_name
FROM cte
WHERE rnk = 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8. What is the total items and amount spent for each member before they became a member? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT s.customer_id, 
    COUNT(s.product_id) AS total_products,
    SUM(price)AS amount_spent
    FROM sales s 
JOIN menu m 
    ON s.product_id = m.product_id
JOIN members mem
    ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT s.customer_id,
    SUM(CASE WHEN m.product_name = 'sushi' THEN m.price*20 ELSE m.price*10 END) AS points
FROM sales s 
JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY s.customer_id;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- How many points do customer A and B have at the end of January? --
------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT s.customer_id,
    SUM(CASE 
        WHEN order_date BETWEEN join_date AND DATEADD(day,6,join_date) THEN price*20
        WHEN product_name = 'sushi' THEN price*20
        ELSE price*10
        END) AS points
FROM sales s 
JOIN menu m 
    ON s.product_id = m.product_id
JOIN members mem
    ON mem.customer_id = s.customer_id
WHERE order_date LIKE '2021-01-%'
GROUP BY s.customer_id;


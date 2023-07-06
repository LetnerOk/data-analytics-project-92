--Count the total number of customers
SELECT 
	COUNT(customer_id) AS customers_count
FROM customers;

--top 10 employees with the highest income
SELECT
	CONCAT(first_name, ' ', last_name) AS name,
	COUNT(sales_id) AS operations,
	SUM(price*quantity) AS income
FROM employees e
INNER JOIN sales s
	ON e.employee_id = s.sales_person_id
INNER JOIN products P
ON p.product_id = s.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10 
;

-- The list of employees whose income is below the average income of all employees
WITH income AS
(
	SELECT
		CONCAT(first_name, ' ', last_name) AS name,
		COUNT(sales_id) AS operations,
		SUM(price*quantity) AS income
	FROM employees e
	INNER JOIN sales s
		ON e.employee_id = s.sales_person_id
	INNER JOIN products P
	ON p.product_id = s.product_id
	GROUP BY 1
	ORDER BY 3
),
 total_average_income AS 
 (
	SELECT
		name,
		income/operations AS average_income,
		(SELECT SUM(income)/SUM(operations) FROM income) AS total_avg
	FROM income
 )
SELECT
	name,
	ROUND(average_income, 0) AS average_income
FROM total_average_income
WHERE average_income < total_avg
ORDER BY average_income
;

--income data for each employee and day of the week
WITH weekday_income AS
(
	SELECT
		CONCAT(first_name, ' ', last_name) AS name,
		TO_CHAR(sale_date, 'day') AS weekday,
		ROUND(SUM(price*quantity), 0) AS income,
		EXTRACT(isodow FROM sale_date) AS num_weekday
	FROM employees e
	INNER JOIN sales s
		ON e.employee_id = s.sales_person_id
	INNER JOIN products P
		ON p.product_id = s.product_id
	GROUP BY 1, 2, 4
)
SELECT
	name,
	weekday,
	income
FROM weekday_income
ORDER BY num_weekday, name
;

-- Count of customers in different age groups
SELECT 
	CASE 
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '25-40'
		WHEN  age > 40 THEN '40+'
	END age_category,
	COUNT(customer_id) AS count
FROM customers
GROUP BY age_category
ORDER BY age_category
;

--Count of customers and their income by months
SELECT
	TO_CHAR(sale_date, 'YYYY-MM') AS date,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	SUM(s.quantity*p.price) AS income
FROM sales s
INNER JOIN products p
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1
;

--customers the first purchase came at the time of the sale of special promotions (price is 0)
SELECT 
	DISTINCT ON (s.customer_id)
	CONCAT(c.first_name, ' ', c.last_name) AS customer,
	s.sale_date,
	CONCAT(e.first_name, ' ', e.last_name) AS seller
	FROM sales s
INNER JOIN employees e
ON s.sales_person_id = e.employee_id
INNER JOIN customers c
ON s.customer_id = c.customer_id
INNER JOIN products p
ON s.product_id = p.product_id
WHERE price = 0
ORDER BY s.customer_id, s.sale_date
;

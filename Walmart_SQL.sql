use walmart_db;
show tables;
select * from walmart;

#Q1]Find different payment methods, number of transactions, and quantity sold by payment method
#CODE:
SELECT
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

#Q2 Identify the highest-rated category in each branch, displaying the branch, category AVG RATING
#CODE:
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart
    GROUP BY branch, category
) AS t
WHERE rnk = 1;

#Q.3 Identify the busiest day for each branch based on the number of transactions
#CODE:
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, day_name
) AS t
WHERE rnk = 1;

#Q4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
#CODE:
SELECT
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

#Q5. Determine the average, minimum, and maximum rating of category for each city.
#List the city, average_rating, min_rating, and max_rating.
#CODE:
SELECT
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2;

#Q6. Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
# List category and total_profit, ordered from highest to lowest profit.
#CODE:
SELECT
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1;

#Q7.Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method, WITH CTE.
#CODE:
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE rnk = 1;

#Q8]Categorize sales into 3 group MORNING, AFTERNOON, EVENING.Find out each of the shift and number of invoices
#CODE:
SELECT 
    branch,
    CASE
        WHEN HOUR(`time`) < 12 THEN 'Morning'
        WHEN HOUR(`time`) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_trans
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, total_trans DESC;

#Q9.Identify 5 branch with highest decrese ratio in revevenue compare to last year(current year 2023 and last year 2022)
# rdr == last_rev-cr_rev/ls_rev*100
#CODE:
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs 
    ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;

############################################################################################################################################
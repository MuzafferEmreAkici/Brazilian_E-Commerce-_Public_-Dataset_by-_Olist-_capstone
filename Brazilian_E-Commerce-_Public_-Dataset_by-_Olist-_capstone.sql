- Perform monthly total payment analysis and visualize it in Excel. Interpret the data.


SQL Query: 

SELECT 
      (date_trunc('month',o.order_approved_at))::date AS payment_month,
       (sum(payment_value))::integer AS total_payment_value
  FROM payments AS p
  LEFT JOIN orders AS o
    ON o.order_id = p.order_id
 WHERE o.order_approved_at IS NOT NULL
 GROUP BY 1
 ORDER BY payment_month


Upon reviewing the output, we observe a steady increase in order numbers month over month. However, there is a dramatic spike in November 2017, which could be attributed to a campaign that month, a special occasion (such as extra bonuses during holiday periods in Turkey leading to increased shopping), or the global impact of Black Friday in November. 

In 2018, there is also an increase observed in January, possibly due to salary raises at the beginning of the new year or the Christmas season.

It is challenging to evaluate seasonal trends based on the available data because there is limited data for the year 2016, an independent increase seen in 2017, and the winter and spring months of 2018 appear to have similar productivity levels. Our data is not sufficient for a thorough seasonal analysis.



Case 1 : Order Analysis
Question 1 : 
- Examine the monthly distribution of orders. The date data should be based on order_approved_at.

SELECT EXTRACT(YEAR FROM order_approved_at) AS year,
       EXTRACT(MONTH FROM order_approved_at) AS month,
       COUNT(*) AS order_count
FROM orders
GROUP BY year, month
ORDER BY year, month
Question 2 : 
-Examine the monthly breakdown of order numbers by order status. Visualize the output in Excel. Are there any months with a dramatic decrease or increase? Analyze the data and provide insights.

SELECT EXTRACT(YEAR FROM order_approved_at) AS year,
       EXTRACT(MONTH FROM order_approved_at) AS month,
       order_status,
       COUNT(*) AS order_count
FROM orders
GROUP BY year, month, order_status
ORDER BY year, month

In 2017, when we look at the canceled orders, we observe a decrease in the middle of the year followed by an increasing trend towards the end of the year. In 2018, there is a similar increase in the second month followed by a return to normal cancellation rates. Additionally, we can infer a connection between canceled orders and out-of-stock items. It appears that canceled orders are not reintroduced into circulation. Reintroducing these items could contribute to the company's profitability.

For shipped products, we notice a low rate of invoiced shipments. Moreover, for delivered orders, there is a generally increasing trend throughout the year, but significant declines occur during transitions from year-end to the beginning of the year. This could be due to year-end campaigns where customers have already made their purchases or reached saturation in their shopping needs.
 

Question 3 : 
- Analyze the number of orders broken down by product category. Which categories stand out during special occasions? For example, New Year's Eve, Valentine's Day...

SELECT 
    p.product_category_name, 
    COUNT(*) AS order_count
FROM 
    orders o 
INNER JOIN 
    products p ON p.products_id = p.products_id
WHERE 
    EXTRACT(MONTH FROM o.order_approved_at) IN (
        2,  -- Valentine's Day (February 14th)
        5,  -- Mother's Day (second Sunday of May)
        6,  -- Father's Day (third Sunday of June)
        10, -- Children's Day (October 12th)
        11  -- Black Friday (fourth Friday of November)
    )
    AND EXTRACT(DAY FROM o.order_approved_at) IN (
        14, -- Valentine's Day
        8,  -- Mother's Day
        15, -- Father's Day
        12, -- Children's Day
        25  -- Black Friday
    )
GROUP BY 
    p.product_category_name
ORDER BY 
    order_count DESC limit 10;

When we consider the total sales for 5 different special occasions, we observe that furniture and home decor products, sports and beauty products, automotive products, computer accessories, and electronics are prominent. Decoration items are highlighted on Mother's Day, while automotive products are featured on Father's Day.
Question 4 : 
Examine order numbers based on weekdays (Monday, Thursday...) and calendar days (1st of the month, 2nd of the month). Create a visualization in Excel using the output of your query and interpret it.


SELECT
    TO_CHAR(order_approved_at, 'Day') AS gun,
    EXTRACT(DAY FROM order_approved_at) AS ayin_gunu,
    COUNT(*) AS siparis_sayisi
FROM
    orders
GROUP BY
   gun, ayin_gunu
ORDER BY
    gun, ayin_gunu;

Sales peak on the 24th, 5th, 7th, 16th, and 18th days of the month. Specifically, Tuesdays, Wednesdays, and Thursdays are highlighted as strong sales days, while Sundays appear to be weaker. Additionally, Tuesdays, Wednesdays, and Thursdays coincide with the end of the month, specifically on the 24th, 25th, and 26th, which also show strong sales performances.
 
	
Case 2: Customer Analysis

Question 1:
- In which cities do customers shop the most? Determine the city where customers place the most orders and conduct the analysis based on that.

For example, if Sibel places 3 orders from Çanakkale, 8 from Muğla, and 10 from Istanbul, you should select Istanbul as the city where she places the most orders. The analysis should then show Sibel as having placed 21 orders from Istanbul.
select
c.customer_unique_id,
c.city,
count(DISTINCT o.order_id) as order_caunt
from orders as o
left join customers as c on o.customer_id= c.customer_id
group by 1,2
order by 3 desc

It is possible to say that customers tend to order from larger cities and repeat ordering from those cities.

Case 3: Seller Analysis

Question 1:
- Who are the sellers that deliver orders to customers most quickly? Provide the top 5. Analyze and interpret their order numbers, product reviews, and ratings.


sELECT s.seler_id, COUNT(o.order_id) AS order_count, AVG(p.review_score) AS average_score
FROM orders o
JOIN sellers s ON s.seler_id = s.seler_id
JOIN order_reviews p ON o.order_id = p.order_id
GROUP BY s.seler_id
ORDER BY AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))) ASC
LIMIT 5;  

We observe that sellers who deliver orders more quickly tend to receive higher ratings and achieve better sales. Fast delivery plays a significant role in both sales and customer satisfaction.

Question 2:
- Which sellers sell products in more categories?
- Do sellers with more categories also have higher order numbers?


SELECT
    oi.seller_id,
    COUNT(DISTINCT p.product_category_name) AS category_count,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM
    order_items AS oi
LEFT JOIN
    products AS p ON oi.product_id = p.products_id
GROUP BY
    oi.seller_id
ORDER BY
    category_count DESC;
Yes, it is possible to say that sellers who sell in more categories tend to have higher order numbers. However, there are also sellers who achieve high sales in fewer categories. This could indicate niche market expertise.

Case 4: Payment Analysis

Question 1:
- In which regions do users who choose higher installment numbers for payment reside the most? Interpret this output.

SELECT c.state, COUNT(p.payment_installments) AS installment_count
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_payments AS p ON o.order_id = p.order_id
GROUP BY c.state
HAVING COUNT(p.payment_installments) > 6
ORDER BY COUNT(p.payment_installments) DESC;

Question 2:
- Calculate the number of successful orders and the total successful payment amount based on payment type. Rank them from the most used payment type to the least used.



SELECT op.payments_type, COUNT(*) AS payment_count
FROM order_payments AS op
GROUP BY op.payments_type
ORDER BY COUNT(*) DESC;


SELECT payments_type,
       COUNT(order_id) AS successful_order_count,
       SUM(payment_value) AS total_successful_payment_amount
FROM order_payments
WHERE payment_sequential = 1  
      AND payment_value > 0  
GROUP BY payments_type
ORDER BY successful_order_count DESC;
Question 3:
- Perform a category-based analysis of orders paid in single payment and in installments. In which categories are installments most commonly used?

Categories such as Kitchen, Computer Games, and Fashion typically involve single payment transactions. Beauty products, Sports products, Bedding, Bathroom, and Home Decor items tend to have more installment payments. This could be because these products have higher prices and installment payments may be more suitable for them.
.

SELECT
    p.product_category_name,
    SUM(CASE WHEN op.payments_type = 'credit_card' AND op.payment_installments = 1 THEN 1 ELSE 0 END) AS tek_cekim,
    SUM(CASE WHEN op.payments_type = 'credit_card' AND op.payment_installments >= 6 THEN 1 ELSE 0 END) AS alti_üstü
FROM
    products p
INNER JOIN
    order_items oi ON p.products_id = oi.product_id
INNER JOIN
    order_payments op ON oi.order_id = op.order_id
GROUP BY
    p.product_category_name
ORDER BY
    tek_cekim DESC, alti_üstü ASC


	
Case 5: RFM Analysis

Perform RFM analysis using the dataset from the file e_commerce_data_.csv. When calculating Recency, use the date of the most recent order, not today's date.

You can access the dataset from the following link and review it to understand the data:
E-Commerce Data

E-Commerce Data



	WITH Frequency AS (
	SELECT
		customerid,
		COUNT(DISTINCT data.quantity) AS miktar,
		CASE
			WHEN COUNT(DISTINCT  quantity) >= 10 THEN 5
			WHEN COUNT(DISTINCT quantity) >= 5 THEN 4
			WHEN COUNT(DISTINCT  quantity) >= 3 THEN 3
			WHEN COUNT(DISTINCT quantity) >= 2 THEN 2
			ELSE 1
		END AS frequency_score
	FROM
		data
	GROUP BY
		customerid
),


Monetary AS (
	SELECT
		customerid,
		SUM(unitprice) AS fiyat,
		CASE
			WHEN SUM(unitprice) >= 1000 THEN 5
			WHEN SUM(unitprice) >= 500 THEN 4
			WHEN SUM(unitprice) >= 250 THEN 3
			WHEN SUM(unitprice) >= 100 THEN 2
			ELSE 1
		END AS fiyat_skoru
	FROM
		data
	GROUP BY
		customerid
),


Recency AS (
	SELECT
		customerid,
		MAX(invoicedate) AS tarih,
		DATE_PART('day', NOW() - MAX(invoicedate)) AS yenilik_skoru
	FROM
		data
	GROUP BY
		customerid
)


SELECT
	F.customerid,
	F.frequency_score,
	M.fiyat_skoru,
	R.yenilik_skoru,
	(R.yenilik_skoru + F.frequency_score + M.fiyat_skoru) AS rfm_puani
FROM
	Frequency F
JOIN
	Monetary M ON F.customerid = M.customerid
JOIN
	Recency R ON F.customerid = R.customerid;











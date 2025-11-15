-- sample_queries1_explaination.md

-- ## Query 1: Customer Value Analysis with Invoice Data
-- **Score: 5/5 (Advanced)**

SELECT 
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_ID) AS orders_count,
    IFNULL(ROUND(AVG(i.total_amount),2), 0) AS avg_invoice_amount
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
ORDER BY orders_count DESC;

-- ## Query 2: Product Quality Analysis with Review Ratings
-- **Score: 4.75/5 (Advanced)**

SELECT 
    p.product_ID,
    p.product_name,
    ROUND(AVG(r.rating),2) AS avg_rating,
    COUNT(r.review_ID) AS review_count
FROM products p
JOIN order_products op ON p.product_ID = op.product_ID
JOIN review r ON op.review_ID = r.review_ID
GROUP BY p.product_ID, p.product_name
HAVING review_count > 0
ORDER BY avg_rating DESC, review_count DESC;

-- ## Query 3: Unpaid Invoice Detection
-- **Score: 2.25/5 (Basic-Advanced hybrid)**

SELECT DISTINCT 
    o.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_ID
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID AND i.status = 'Paid'
WHERE i.invoice_ID IS NULL
ORDER BY o.customer_ID;

-- ## Query 4: Customer Lifetime Value Ranking
-- **Score: 3/5 (Advanced)**

SELECT 
    i.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ROUND(SUM(i.total_amount),2) AS lifetime_value,
    COUNT(DISTINCT i.order_ID) AS invoice_count
FROM invoice i
JOIN customer c ON i.customer_ID = c.customer_ID
GROUP BY i.customer_ID
ORDER BY lifetime_value DESC
LIMIT 20;

-- ## Query 5: Product Popularity by Order Frequency
-- **Score: 4/5 (Advanced)**

SELECT 
    p.product_ID,
    p.product_name,
    d.department,
    COUNT(op.order_ID) AS orders_containing_product
FROM products p
JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID
GROUP BY p.product_ID, p.product_name, d.department
ORDER BY orders_containing_product DESC
LIMIT 30;

-- ## Query 6: Late Delivery Performance Tracking
-- **Score: 4.5/5 (Advanced)**

SELECT 
    DATE_FORMAT(d.scheduled_date, '%Y-%m') AS delivery_month,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN d.actual_delivery_date IS NOT NULL
             AND d.actual_delivery_date > d.scheduled_date THEN 1 ELSE 0 END) AS late_delivery_count,
    ROUND(100 * SUM(CASE WHEN d.actual_delivery_date IS NOT NULL
             AND d.actual_delivery_date > d.scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_delivery_percentage
FROM delivery d
WHERE d.status = 'Delivered'
GROUP BY DATE_FORMAT(d.scheduled_date, '%Y-%m')
ORDER BY delivery_month DESC;

-- ## Query 7: Inventory Turnover Analysis
-- **Score: 5/5 (Advanced)**

SELECT 
    p.product_ID,
    p.product_name,
    COUNT(DISTINCT op.order_ID) AS orders_with_product,
    IFNULL(ROUND(AVG(ir.quantity_on_hand),2),0) AS avg_quantity_on_hand,
    CASE WHEN AVG(ir.quantity_on_hand) > 0 
         THEN ROUND(COUNT(DISTINCT op.order_ID) / AVG(ir.quantity_on_hand), 4)
         ELSE NULL END AS turnover_proxy
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN inventory_record ir ON p.product_ID = ir.product_ID
GROUP BY p.product_ID, p.product_name
ORDER BY turnover_proxy DESC
LIMIT 50;

-- ## Query 8: Products Never Ordered (Dead SKUs)
-- **Score: 3-4/5 (Basic to Advanced)**

SELECT 
    p.product_ID,
    p.product_name,
    d.department
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID
WHERE op.order_ID IS NULL
ORDER BY p.product_ID;

-- ## Query 9: Active Promotion Effectiveness
-- **Score: 3.5/5 (Advanced)**

SELECT 
    pr.code,
    pr.product_ID,
    p.product_name,
    pr.start_date,
    pr.end_date,
    COUNT(DISTINCT op.order_ID) AS orders_with_promo_product
FROM promotion pr
JOIN products p ON pr.product_ID = p.product_ID
LEFT JOIN order_products op ON pr.product_ID = op.product_ID
LEFT JOIN orders o ON op.order_ID = o.order_ID
WHERE op.order_ID IS NOT NULL
    AND pr.start_date <= NOW()
    AND pr.end_date >= NOW()
GROUP BY pr.code, pr.product_ID, p.product_name, pr.start_date, pr.end_date
ORDER BY orders_with_promo_product DESC;

-- ## Query 10: Loyalty Program Impact Analysis
-- **Score: 5/5 (Advanced)**

SELECT 
    lm.tier_level AS tier,
    ROUND(AVG(i.total_amount),2) AS avg_invoice_amount,
    COUNT(DISTINCT i.invoice_ID) AS invoice_count
FROM loyalty_membership lm
JOIN customer c ON lm.customer_ID = c.customer_ID
JOIN orders o ON c.customer_ID = o.customer_ID
JOIN invoice i ON o.order_ID = i.order_ID
WHERE lm.status = 'Active'
GROUP BY lm.tier_level
UNION ALL
SELECT 
    'Non-member',
    ROUND(AVG(i2.total_amount),2),
    COUNT(DISTINCT i2.invoice_ID)
FROM customer c2
LEFT JOIN loyalty_membership lm2 ON c2.customer_ID = lm2.customer_ID
JOIN orders o2 ON c2.customer_ID = o2.customer_ID
JOIN invoice i2 ON o2.order_ID = i2.order_ID
WHERE lm2.membership_ID IS NULL
ORDER BY avg_invoice_amount DESC;



-- advanced_queries_20.sql

-- ## Query 11: MONTHLY CUSTOMER ORDER SUMMARY WITH RETENTION

SELECT -- 4 4 4 4 4 4 = 4
    DATE_FORMAT(c.registration_date, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT c.customer_ID) AS total_customers,
    COUNT(DISTINCT CASE WHEN o.order_ID IS NOT NULL THEN c.customer_ID END) AS customers_with_orders,
    ROUND(100 * COUNT(DISTINCT CASE WHEN o.order_ID IS NOT NULL THEN c.customer_ID END) / COUNT(DISTINCT c.customer_ID), 2) AS purchase_rate,
    ROUND(AVG(i.total_amount), 2) AS avg_invoice_amount
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY DATE_FORMAT(c.registration_date, '%Y-%m')
ORDER BY cohort_month DESC;


-- ## Query 12: CUSTOMER SPENDING BY GENDER AND AGE GROUP

SELECT -- 4.5 5 4.525 4.5 4.5 4.5 = 4.5
    c.gender,
    CASE 
        WHEN FLOOR(DATEDIFF(NOW(), c.date_of_birth) / 365) < 25 THEN 'Under 25'
        WHEN FLOOR(DATEDIFF(NOW(), c.date_of_birth) / 365) < 35 THEN '25-34'
        WHEN FLOOR(DATEDIFF(NOW(), c.date_of_birth) / 365) < 50 THEN '35-49'
        ELSE '50+'
    END AS age_group,
    COUNT(DISTINCT c.customer_ID) AS customer_count,
    ROUND(AVG(total_spent.lifetime_value), 2) AS avg_total_spending,
    ROUND(AVG(total_spent.order_count), 2) AS avg_orders,
    ROUND(AVG(total_spent.lifetime_value) / NULLIF(AVG(total_spent.order_count), 0), 2) AS avg_per_order
FROM customer c
LEFT JOIN (
    SELECT 
        i.customer_ID,
        SUM(i.total_amount) AS lifetime_value,
        COUNT(DISTINCT i.order_ID) AS order_count
    FROM invoice i
    GROUP BY i.customer_ID
) AS total_spent ON c.customer_ID = total_spent.customer_ID
GROUP BY c.gender, age_group
HAVING customer_count >= 5
ORDER BY avg_total_spending DESC;


-- ## Query 13: DELIVERY PERFORMANCE BY PROVINCE

SELECT -- 4 4.5 4.5 4.5 4 4.5 = 4.25
    a.province,
    COUNT(DISTINCT d.delivery_ID) AS total_deliveries,
    ROUND(AVG(DATEDIFF(d.actual_delivery_date, d.scheduled_date)), 2) AS avg_delay_days,
    ROUND(100 * SUM(CASE WHEN d.actual_delivery_date <= d.scheduled_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_percentage,
    ROUND(100 * SUM(CASE WHEN d.status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_percentage,
    COUNT(DISTINCT o.customer_ID) AS unique_customers
FROM address a
JOIN customer c ON a.customer_ID = c.customer_ID
JOIN orders o ON c.customer_ID = o.customer_ID
JOIN delivery d ON o.order_ID = d.order_ID
WHERE d.actual_delivery_date IS NOT NULL
GROUP BY a.province
HAVING total_deliveries >= 10
ORDER BY on_time_percentage ASC;



-- ## Query 14: PRODUCTS FREQUENTLY BOUGHT TOGETHER

SELECT -- 4.8 4.5 4.75 4.5 4.5 4.5 = 4.5
    p1.product_ID AS product_1_id,
    p1.product_name AS product_1,
    p2.product_ID AS product_2_id,
    p2.product_name AS product_2,
    d.department,
    COUNT(DISTINCT op1.order_ID) AS times_bought_together,
    ROUND(AVG(i.total_amount), 2) AS avg_order_value
FROM order_products op1
JOIN order_products op2 ON op1.order_ID = op2.order_ID AND op1.product_ID < op2.product_ID
JOIN products p1 ON op1.product_ID = p1.product_ID
JOIN products p2 ON op2.product_ID = p2.product_ID AND p1.department_ID = p2.department_ID
JOIN departments d ON p1.department_ID = d.department_ID
JOIN invoice i ON op1.order_ID = i.order_ID
GROUP BY p1.product_ID, p1.product_name, p2.product_ID, p2.product_name, d.department
HAVING times_bought_together >= 5
ORDER BY times_bought_together DESC
LIMIT 50;


-- ## Query 15:  CUSTOMER ACTIVITY SEGMENTATION

SELECT -- 4 3.5 4 4.5 4.2582 4 = 4.125
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(NOW(), MAX(i.invoice_date)) AS days_since_last_order,
    COUNT(DISTINCT o.order_ID) AS total_orders,
    ROUND(SUM(i.total_amount), 2) AS total_spent,
    CASE 
        WHEN DATEDIFF(NOW(), MAX(i.invoice_date)) <= 30 AND COUNT(DISTINCT o.order_ID) >= 5 THEN 'Very Active'
        WHEN DATEDIFF(NOW(), MAX(i.invoice_date)) <= 60 AND COUNT(DISTINCT o.order_ID) >= 3 THEN 'Active'
        WHEN DATEDIFF(NOW(), MAX(i.invoice_date)) <= 90 THEN 'Moderate'
        WHEN DATEDIFF(NOW(), MAX(i.invoice_date)) > 180 THEN 'Inactive'
        ELSE 'Low Activity'
    END AS activity_segment
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
HAVING total_orders > 0
ORDER BY total_spent DESC;


-- ## Query 16: INVENTORY STOCK LEVELS VS RECENT DEMAND

SELECT -- 4 4.5 4 4 4 4 = 4.125
    p.product_ID,
    p.product_name,
    ir.quantity_on_hand,
    ir.reorder_level,
    COUNT(DISTINCT op.order_ID) AS orders_last_90_days,
    ROUND(COUNT(DISTINCT op.order_ID) / 90.0, 2) AS avg_daily_orders,
    ROUND(ir.quantity_on_hand / NULLIF(COUNT(DISTINCT op.order_ID) / 90.0, 0), 1) AS days_of_stock_remaining,
    CASE 
        WHEN ir.quantity_on_hand / NULLIF(COUNT(DISTINCT op.order_ID) / 90.0, 0) < 15 THEN 'Low Stock'
        WHEN ir.quantity_on_hand / NULLIF(COUNT(DISTINCT op.order_ID) / 90.0, 0) > 60 THEN 'Overstocked'
        ELSE 'Adequate'
    END AS stock_status
FROM inventory_record ir
JOIN products p ON ir.product_ID = p.product_ID
LEFT JOIN order_products op ON p.product_ID = op.product_ID
WHERE ir.inventory_status = 'In Stock'
GROUP BY p.product_ID, p.product_name, ir.quantity_on_hand, ir.reorder_level
HAVING orders_last_90_days > 0
ORDER BY days_of_stock_remaining ASC
LIMIT 20;


-- ## Query 17: PROMOTION EFFECTIVENESS SUMMARY

SELECT -- 4 4 4 4.25 4 3.14159265 = 3.8987
    pr.code AS promo_code,
    pr.product_ID,
    p.product_name,
    pr.discount_type,
    pr.discount_value,
    pr.start_date,
    pr.end_date,
    COUNT(DISTINCT op.order_ID) AS total_orders_with_product,
    ROUND(AVG(i.total_amount), 2) AS avg_order_value
FROM promotion pr
JOIN products p ON pr.product_ID = p.product_ID
LEFT JOIN order_products op ON pr.product_ID = op.product_ID
LEFT JOIN invoice i ON op.order_ID = i.order_ID
GROUP BY pr.code, pr.product_ID, p.product_name, pr.discount_type, pr.discount_value, pr.start_date, pr.end_date
ORDER BY total_orders_with_product DESC;


-- ## Query 18: PRODUCT RATINGS BY DEPARTMENT

SELECT -- 3.5 3.99 2.5 3 3 3.5 = 3.25
    p.product_ID,
    p.product_name,
    d.department,
    COUNT(DISTINCT r.review_ID) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    ROUND(100 * SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS low_rating_percentage,
    COUNT(DISTINCT op.order_ID) AS total_orders,
    CASE 
        WHEN AVG(r.rating) >= 4.5 THEN 'Excellent'
        WHEN AVG(r.rating) >= 4.0 THEN 'Good'
        WHEN AVG(r.rating) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS rating_category
FROM products p
JOIN order_products op ON p.product_ID = op.product_ID
JOIN review r ON op.review_ID = r.review_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID
GROUP BY p.product_ID, p.product_name, d.department
HAVING review_count >= 10
ORDER BY avg_rating DESC;


-- ## Query 19: DEPARTMENTS PURCHASED TOGETHER

SELECT -- 4.5 1 3.5 2 3 2.8 = 2.8333
    d1.department AS department_1,
    d2.department AS department_2,
    COUNT(DISTINCT o.order_ID) AS orders_with_both_departments,
    COUNT(DISTINCT o.customer_ID) AS unique_customers,
    ROUND(AVG(i.total_amount), 2) AS avg_order_total
FROM orders o
JOIN order_products op1 ON o.order_ID = op1.order_ID
JOIN products p1 ON op1.product_ID = p1.product_ID
JOIN departments d1 ON p1.department_ID = d1.department_ID
JOIN order_products op2 ON o.order_ID = op2.order_ID
JOIN products p2 ON op2.product_ID = p2.product_ID
JOIN departments d2 ON p2.department_ID = d2.department_ID AND d1.department_ID < d2.department_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY d1.department, d2.department
HAVING orders_with_both_departments >= 20
ORDER BY orders_with_both_departments DESC
LIMIT 30;


-- ## Query 20: LOYALTY MEMBERSHIP TIER SUMMARY

SELECT -- 4 3.98 3.5 3.5 2.5 4.5 = 3.7466
    lm.tier_level,
    COUNT(DISTINCT lm.customer_ID) AS total_members,
    ROUND(AVG(lm.points_balance), 2) AS avg_points_balance,
    ROUND(AVG(DATEDIFF(NOW(), lm.enrollment_date)), 0) AS avg_days_as_member,
    ROUND(AVG(customer_value.total_spent), 2) AS avg_total_spent,
    ROUND(100 * SUM(CASE WHEN lm.status = 'Active' THEN 1 ELSE 0 END) / COUNT(*), 2) AS active_percentage
FROM loyalty_membership lm
LEFT JOIN (
    SELECT i.customer_ID, SUM(i.total_amount) AS total_spent
    FROM invoice i
    GROUP BY i.customer_ID
) AS customer_value ON lm.customer_ID = customer_value.customer_ID
GROUP BY lm.tier_level
ORDER BY FIELD(lm.tier_level, 'Gold', 'Silver', 'Bronze');


-- ## Query 21: MONTHLY SALES BY DEPARTMENT

SELECT -- 3 4 4 4 3.5 3 = 3.5833
    d.department,
    MONTH(i.invoice_date) AS month_number,
    MONTHNAME(i.invoice_date) AS month_name,
    COUNT(DISTINCT op.order_ID) AS order_count,
    ROUND(SUM(i.total_amount), 2) AS total_revenue,
    ROUND(AVG(i.total_amount), 2) AS avg_order_value,
    NULL AS percent_of_annual_orders -- placeholder replaced by derived table below
FROM departments d
JOIN products p ON d.department_ID = p.department_ID
JOIN order_products op ON p.product_ID = op.product_ID
JOIN orders o ON op.order_ID = o.order_ID
JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY d.department, MONTH(i.invoice_date), MONTHNAME(i.invoice_date);


-- ## Query 22: DELIVERY TIMELINESS VS REVIEW RATINGS

SELECT -- 3.5 3.5 3.97 4 3 3.75 = 3.62
    CASE 
        WHEN DATEDIFF(d.actual_delivery_date, d.scheduled_date) <= 0 THEN 'On Time'
        WHEN DATEDIFF(d.actual_delivery_date, d.scheduled_date) <= 2 THEN '1-2 Days Late'
        WHEN DATEDIFF(d.actual_delivery_date, d.scheduled_date) <= 5 THEN '3-5 Days Late'
        ELSE 'Over 5 Days Late'
    END AS delivery_category,
    COUNT(DISTINCT d.delivery_ID) AS total_deliveries,
    ROUND(AVG(r.rating), 2) AS avg_review_rating,
    ROUND(100 * SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) / COUNT(*), 2) AS high_rating_percentage,
    COUNT(DISTINCT o.customer_ID) AS unique_customers
FROM delivery d
JOIN orders o ON d.order_ID = o.order_ID
JOIN order_products op ON o.order_ID = op.order_ID
JOIN review r ON op.review_ID = r.review_ID
WHERE d.status = 'Delivered' AND d.actual_delivery_date IS NOT NULL
GROUP BY delivery_category
ORDER BY FIELD(delivery_category, 'On Time', '1-2 Days Late', '3-5 Days Late', 'Over 5 Days Late');


-- ## Query 23: SLOW-MOVING INVENTORY IDENTIFICATION

SELECT * -- 4 4 3 3.77 3.67 4 = 3.8944
FROM (
    SELECT 
        p.product_ID,
        p.product_name,
        d.department,
        ir.quantity_on_hand,
        ir.last_restock_date,
        DATEDIFF(NOW(), ir.last_restock_date) AS days_since_restock,
        COUNT(DISTINCT op.order_ID) AS orders_in_last_90_days,
        CASE 
            WHEN COUNT(DISTINCT op.order_ID) = 0 AND DATEDIFF(NOW(), ir.last_restock_date) > 180 THEN 'Critical'
            WHEN COUNT(DISTINCT op.order_ID) <= 2 AND DATEDIFF(NOW(), ir.last_restock_date) > 120 THEN 'High Risk'
            WHEN COUNT(DISTINCT op.order_ID) <= 5 AND DATEDIFF(NOW(), ir.last_restock_date) > 90 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS slow_moving_risk
    FROM inventory_record ir
    JOIN products p ON ir.product_ID = p.product_ID
    LEFT JOIN departments d ON p.department_ID = d.department_ID
    LEFT JOIN order_products op ON p.product_ID = op.product_ID
    WHERE ir.inventory_status = 'In Stock'
    GROUP BY p.product_ID, p.product_name, d.department, ir.quantity_on_hand, ir.last_restock_date
) AS inv
WHERE inv.slow_moving_risk IN ('Critical', 'High Risk')
ORDER BY FIELD(inv.slow_moving_risk, 'Critical', 'High Risk'), inv.days_since_restock DESC
LIMIT 20;


-- ## Query 24: RETAILER SALES PERFORMANCE SUMMARY

SELECT -- 4.5 5 4.5 4.5 4.5 4 = 4.5833
    r.retailer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS retailer_name,
    r.account_name,
    COUNT(DISTINCT p.product_ID) AS products_supplied,
    COUNT(DISTINCT op.order_ID) AS total_orders,
    ROUND(SUM(i.total_amount), 2) AS total_revenue,
    ROUND(AVG(i.total_amount), 2) AS avg_order_value,
    ROUND(AVG(rev.rating), 2) AS avg_product_rating,
    CASE
        WHEN SUM(i.total_amount) >= 50000 THEN 'Top Tier'
        WHEN SUM(i.total_amount) >= 20000 THEN 'Mid Tier'
        ELSE 'Standard'
    END AS retailer_tier
FROM retailer r
JOIN customer c ON r.retailer_ID = c.customer_ID
JOIN products p ON r.retailer_ID = p.retailer_ID
JOIN order_products op ON p.product_ID = op.product_ID
JOIN orders o ON op.order_ID = o.order_ID
JOIN invoice i ON o.order_ID = i.order_ID
LEFT JOIN review rev ON op.review_ID = rev.review_ID
GROUP BY r.retailer_ID, c.first_name, c.last_name, r.account_name
HAVING total_orders >= 5
ORDER BY total_revenue DESC;
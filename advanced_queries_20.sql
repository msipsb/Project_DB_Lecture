-- ======================================================================
-- 20 ADDITIONAL ADVANCED QUERIES FOR BUSINESS INTELLIGENCE
-- MySQL 5.7.24 Compatible
-- ======================================================================
-- These queries provide deep analytical insights for strategic
-- decision-making across multiple business functions
-- ======================================================================

-- ============================================================================
-- ADVANCED QUERY 1: MONTHLY CUSTOMER ORDER SUMMARY WITH RETENTION
-- ============================================================================
-- BUSINESS VALUE:
--   Shows customer registration and purchasing activity by month
--   Tracks which customers from each month made purchases
-- DECISION SUPPORT:
--   - Identify active vs inactive customers by registration period
--   - Monitor monthly customer acquisition trends
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 2: PRODUCT SALES WITH INVENTORY STATUS
-- ============================================================================
-- BUSINESS VALUE:
--   Shows product sales volume compared to inventory levels
--   Identifies which products are selling well vs sitting in stock
-- DECISION SUPPORT:
--   - Reorder popular products before stockout
--   - Identify overstocked slow-moving products
-- ============================================================================
SELECT
    p.product_ID,
    p.product_name,
    d.department,
    COUNT(DISTINCT op.order_ID) AS total_orders,
    COALESCE(AVG(ir.quantity_on_hand), 0) AS avg_inventory_units,
    COALESCE(AVG(ir.quantity_reserved), 0) AS avg_reserved_units,
    ROUND(COUNT(DISTINCT op.order_ID) / NULLIF(AVG(ir.quantity_on_hand), 0), 4) AS turnover_ratio,
    CASE 
        WHEN COUNT(DISTINCT op.order_ID) = 0 THEN 'No Sales'
        WHEN COUNT(DISTINCT op.order_ID) / NULLIF(AVG(ir.quantity_on_hand), 0) > 0.5 THEN 'Fast Moving'
        WHEN COUNT(DISTINCT op.order_ID) / NULLIF(AVG(ir.quantity_on_hand), 0) > 0.1 THEN 'Moderate'
        ELSE 'Slow Moving'
    END AS movement_category
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN inventory_record ir ON p.product_ID = ir.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID
GROUP BY p.product_ID, p.product_name, d.department
ORDER BY total_orders DESC
LIMIT 100;

-- ============================================================================
-- ADVANCED QUERY 3: CUSTOMER SPENDING BY GENDER AND AGE GROUP
-- ============================================================================
-- BUSINESS VALUE:
--   Shows total spending patterns grouped by customer demographics
--   Identifies which demographic groups spend the most
-- DECISION SUPPORT:
--   - Target marketing campaigns to high-spending demographics
--   - Understand customer base composition
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 4: DELIVERY PERFORMANCE BY PROVINCE
-- ============================================================================
-- BUSINESS VALUE:
--   Shows delivery speed and success rate for each province
--   Identifies provinces with delivery issues
-- DECISION SUPPORT:
--   - Monitor delivery performance by location
--   - Compare on-time delivery rates across regions
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 5: PRODUCTS FREQUENTLY BOUGHT TOGETHER
-- ============================================================================
-- BUSINESS VALUE:
--   Finds products from the same department purchased in the same orders
--   Shows which products customers buy together
-- DECISION SUPPORT:
--   - Create product bundles for frequently paired items
--   - Improve product recommendations
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 6: MONTHLY PAYMENT STATUS SUMMARY
-- ============================================================================
-- BUSINESS VALUE:
--   Shows payment transaction success and failure rates by month
--   Tracks payment processing trends over time
-- DECISION SUPPORT:
--   - Monitor payment success rates
--   - Identify months with payment issues
-- ============================================================================
SELECT
    t.payment_month,
    t.status,
    t.transaction_count,
    t.total_amount,
    t.avg_transaction_amount,
    t.unique_customers,
    ROUND(100 * t.transaction_count / NULLIF(mt.month_total, 0), 2) AS percentage_of_month
FROM (
    SELECT 
        DATE_FORMAT(pt.payment_date, '%Y-%m') AS payment_month,
        pt.status,
        COUNT(*) AS transaction_count,
        ROUND(SUM(pt.amount), 2) AS total_amount,
        ROUND(AVG(pt.amount), 2) AS avg_transaction_amount,
        COUNT(DISTINCT pt.customer_ID) AS unique_customers
    FROM payment_transaction pt
    GROUP BY DATE_FORMAT(pt.payment_date, '%Y-%m'), pt.status
)
AS t
JOIN (
    SELECT 
        DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
        COUNT(*) AS month_total
    FROM payment_transaction
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
AS mt ON t.payment_month = mt.payment_month
ORDER BY t.payment_month DESC, t.transaction_count DESC;

-- ============================================================================
-- ADVANCED QUERY 7: CUSTOMER ACTIVITY SEGMENTATION
-- ============================================================================
-- BUSINESS VALUE:
--   Groups customers by recency, order frequency, and total spending
--   Identifies active vs inactive customers
-- DECISION SUPPORT:
--   - Find high-value customers for special offers
--   - Identify inactive customers for reactivation campaigns
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 8: INVENTORY STOCK LEVELS VS RECENT DEMAND
-- ============================================================================
-- BUSINESS VALUE:
--   Compares current inventory quantities to recent order demand
--   Shows which products may need restocking soon
-- DECISION SUPPORT:
--   - Identify products running low on stock
--   - Find products with excess inventory
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 9: CUSTOMER REPEAT PURCHASE PATTERNS
-- ============================================================================
-- BUSINESS VALUE:
--   Shows how often customers place orders and their order timing
--   Identifies customers who haven't ordered recently
-- DECISION SUPPORT:
--   - Find customers who may be due for another order
--   - Understand typical order frequency
-- ============================================================================
SELECT -- 2.5 0 2.5 ? ? 5 = First Own this one
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_ID) AS total_orders,
    ROUND(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) / NULLIF(COUNT(DISTINCT o.order_ID) - 1, 0), 1) AS avg_days_between_orders,
    DATEDIFF(NOW(), MAX(i.invoice_date)) AS days_since_last_order,
    CASE 
        WHEN COUNT(DISTINCT o.order_ID) >= 10 THEN 'Frequent Buyer'
        WHEN COUNT(DISTINCT o.order_ID) >= 5 THEN 'Regular Buyer'
        WHEN COUNT(DISTINCT o.order_ID) >= 3 THEN 'Occasional Buyer'
        ELSE 'New Buyer'
    END AS buyer_type
FROM customer c
JOIN orders o ON c.customer_ID = o.customer_ID
JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
HAVING total_orders >= 3
ORDER BY days_since_last_order DESC;

-- ============================================================================
-- ADVANCED QUERY 10: PROMOTION EFFECTIVENESS SUMMARY
-- ============================================================================
-- BUSINESS VALUE:
--   Shows how many orders each promotion generated
--   Compares promotion types and discount amounts
-- DECISION SUPPORT:
--   - Identify most effective promotions
--   - Compare discount strategies
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 11: INVOICE PAYMENT TIMING BY CUSTOMER TIER
-- ============================================================================
-- BUSINESS VALUE:
--   Shows how quickly different customer groups pay invoices
--   Identifies high-value vs standard customers payment patterns
-- DECISION SUPPORT:
--   - Monitor payment speed by customer segment
--   - Identify customers who pay quickly vs slowly
-- ============================================================================
SELECT -- 1.5 0 0 2 2 1 = 1.0833
    CASE 
        WHEN lifetime_value.total_spent >= 10000 THEN 'VIP'
        WHEN lifetime_value.total_spent >= 3000 THEN 'Premium'
        ELSE 'Standard'
    END AS customer_tier,
    COUNT(DISTINCT i.customer_ID) AS customer_count,
    COUNT(DISTINCT i.invoice_ID) AS total_invoices,
    ROUND(AVG(DATEDIFF(i.updated_at, i.invoice_date)), 1) AS avg_days_to_payment,
    ROUND(100 * SUM(CASE WHEN i.status = 'Paid' THEN 1 ELSE 0 END) / COUNT(*), 2) AS payment_rate_percentage,
    ROUND(SUM(CASE WHEN i.status = 'Paid' THEN i.total_amount ELSE 0 END), 2) AS total_collected,
    ROUND(SUM(CASE WHEN i.status != 'Paid' THEN i.total_amount ELSE 0 END), 2) AS total_outstanding
FROM invoice i
LEFT JOIN (
    SELECT customer_ID, SUM(total_amount) AS total_spent
    FROM invoice
    WHERE status = 'Paid'
    GROUP BY customer_ID
) AS lifetime_value ON i.customer_ID = lifetime_value.customer_ID
GROUP BY customer_tier
ORDER BY avg_days_to_payment DESC;

-- ============================================================================
-- ADVANCED QUERY 12: PRODUCT RATINGS BY DEPARTMENT
-- ============================================================================
-- BUSINESS VALUE:
--   Shows average customer ratings for products with reviews
--   Identifies well-rated vs poorly-rated products
-- DECISION SUPPORT:
--   - Find products needing quality improvement
--   - Highlight highly-rated products for marketing
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 13: DEPARTMENTS PURCHASED TOGETHER
-- ============================================================================
-- BUSINESS VALUE:
--   Shows which departments are bought together in same orders
--   Identifies complementary product categories
-- DECISION SUPPORT:
--   - Create cross-department promotions
--   - Understand shopping basket composition
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 14: LOYALTY MEMBERSHIP TIER SUMMARY
-- ============================================================================
-- BUSINESS VALUE:
--   Shows membership statistics for each loyalty tier
--   Compares spending and activity across tiers
-- DECISION SUPPORT:
--   - Monitor loyalty program participation
--   - Compare value of different membership tiers
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 15: MONTHLY SALES BY DEPARTMENT
-- ============================================================================
-- BUSINESS VALUE:
--   Shows sales revenue and order volume for each department by month
--   Identifies seasonal patterns in different product categories
-- DECISION SUPPORT:
--   - Track department performance over time
--   - Identify peak months for each department
-- ============================================================================
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


-- MySQL 5.7: Re-express percent_of_annual_orders without window functions
SELECT 
    m.department,
    m.month_number,
    m.month_name,
    m.order_count,
    m.total_revenue,
    m.avg_order_value,
    ROUND(100 * m.order_count / NULLIF(dt.dept_annual_orders, 0), 2) AS percent_of_annual_orders
FROM (
    SELECT 
        d.department,
        MONTH(i.invoice_date) AS month_number,
        MONTHNAME(i.invoice_date) AS month_name,
        COUNT(DISTINCT op.order_ID) AS order_count,
        ROUND(SUM(i.total_amount), 2) AS total_revenue,
        ROUND(AVG(i.total_amount), 2) AS avg_order_value
    FROM departments d
    JOIN products p ON d.department_ID = p.department_ID
    JOIN order_products op ON p.product_ID = op.product_ID
    JOIN orders o ON op.order_ID = o.order_ID
    JOIN invoice i ON o.order_ID = i.order_ID
    GROUP BY d.department, MONTH(i.invoice_date), MONTHNAME(i.invoice_date)
) AS m
JOIN (
    SELECT 
        d.department,
        COUNT(DISTINCT op.order_ID) AS dept_annual_orders
    FROM departments d
    JOIN products p ON d.department_ID = p.department_ID
    JOIN order_products op ON p.product_ID = op.product_ID
    JOIN orders o ON op.order_ID = o.order_ID
    JOIN invoice i ON o.order_ID = i.order_ID
    GROUP BY d.department
) AS dt
  ON m.department = dt.department
ORDER BY m.department, m.month_number;

-- ============================================================================
-- ADVANCED QUERY 16: DELIVERY TIMELINESS VS REVIEW RATINGS
-- ============================================================================
-- BUSINESS VALUE:
--   Compares delivery speed to customer review ratings
--   Shows if late deliveries affect customer satisfaction
-- DECISION SUPPORT:
--   - Monitor relationship between delivery time and ratings
--   - Understand impact of delivery delays
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 17: CUSTOMER VALUE BY REGISTRATION QUARTER
-- ============================================================================
-- BUSINESS VALUE:
--   Shows average customer spending grouped by when they registered
--   Tracks customer lifetime value trends over time
-- DECISION SUPPORT:
--   - Compare value of customers acquired in different periods
--   - Track customer value trends
-- ============================================================================
SELECT -- 1 1.25 1 1.25 1.96 2 = 1.2416
    YEAR(c.registration_date) AS registration_year,
    QUARTER(c.registration_date) AS registration_quarter,
    COUNT(DISTINCT c.customer_ID) AS new_customers,
    ROUND(AVG(customer_value.total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(AVG(customer_value.order_count), 2) AS avg_orders_per_customer,
    ROUND(AVG(DATEDIFF(customer_value.last_order_date, c.registration_date)), 0) AS avg_customer_lifespan_days
FROM customer c
LEFT JOIN (
    SELECT 
        c.customer_ID,
        SUM(i.total_amount) AS total_revenue,
        COUNT(DISTINCT o.order_ID) AS order_count,
        MAX(i.invoice_date) AS last_order_date
    FROM customer c
    JOIN orders o ON c.customer_ID = o.customer_ID
    JOIN invoice i ON o.order_ID = i.order_ID
    GROUP BY c.customer_ID
) AS customer_value ON c.customer_ID = customer_value.customer_ID
GROUP BY YEAR(c.registration_date), QUARTER(c.registration_date)
ORDER BY registration_year DESC, registration_quarter DESC;

-- ============================================================================
-- ADVANCED QUERY 18: SLOW-MOVING INVENTORY IDENTIFICATION
-- ============================================================================
-- BUSINESS VALUE:
--   Identifies products with low recent sales relative to stock levels
--   Highlights inventory that may need clearance
-- DECISION SUPPORT:
--   - Find overstocked products
--   - Identify candidates for clearance sales
-- ============================================================================
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

-- ============================================================================
-- ADVANCED QUERY 19: CUSTOMERS WITH MULTIPLE DELIVERY ADDRESSES
-- ============================================================================
-- BUSINESS VALUE:
--   Lists customers who have registered multiple delivery addresses
--   Shows order activity for multi-address customers
-- DECISION SUPPORT:
--   - Identify customers using multiple locations
--   - Track high-value customers with complex needs
-- ============================================================================
SELECT -- 0 0 0.5 0 1 0.4537 = 0.3256
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT a.address_ID) AS total_addresses,
    COUNT(DISTINCT a.province) AS different_provinces,
    COUNT(DISTINCT o.order_ID) AS total_orders,
    ROUND(SUM(i.total_amount), 2) AS total_spent,
    ROUND(AVG(i.total_amount), 2) AS avg_order_value
FROM customer c
JOIN address a ON c.customer_ID = a.customer_ID
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
HAVING total_addresses >= 2
ORDER BY total_spent DESC;

-- ============================================================================
-- ADVANCED QUERY 20: PAYMENT TRANSACTIONS BY CUSTOMER TIER
-- ============================================================================
-- BUSINESS VALUE:
--   Summarizes payment transaction volume and success rates by customer tier
--   Compares payment behavior across customer segments
-- DECISION SUPPORT:
--   - Monitor payment success rates by customer value
--   - Track transaction patterns
-- ============================================================================
SELECT -- 0 0 0 0 0 0 = 0
    CASE 
        WHEN customer_lifetime.total_value >= 5000 THEN 'VIP'
        WHEN customer_lifetime.total_value >= 2000 THEN 'Premium'
        ELSE 'Regular'
    END AS customer_tier,
    COUNT(DISTINCT pt.payment_ID) AS total_transactions,
    ROUND(SUM(pt.amount), 2) AS total_payment_amount,
    ROUND(AVG(pt.amount), 2) AS avg_transaction_amount,
    ROUND(100 * SUM(CASE WHEN pt.status = 'Successful' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_percentage,
    ROUND(100 * SUM(CASE WHEN pt.status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_percentage
FROM payment_transaction pt
JOIN (
    SELECT 
        i.customer_ID,
        SUM(i.total_amount) AS total_value
    FROM invoice i
    GROUP BY i.customer_ID
) AS customer_lifetime ON pt.customer_ID = customer_lifetime.customer_ID
GROUP BY customer_tier
ORDER BY total_payment_amount DESC;

-- ======================================================================
-- END OF 20 ADVANCED QUERIES
-- ======================================================================

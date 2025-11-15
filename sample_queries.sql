-- ======================================================================
-- MEANINGFUL QUERIES FOR DB_Lecture_Project DATABASE
-- MySQL 5.7.24 Compatible
-- ======================================================================
-- BUSINESS INTELLIGENCE & DECISION SUPPORT QUERIES
-- ======================================================================
-- These queries are designed to provide business administrators with
-- actionable insights for strategic decision-making, operational
-- optimization, and performance analysis.
-- ======================================================================

-- ======================================================================
-- PART 1: 12 BASIC MEANINGFUL QUERIES
-- ======================================================================

-- ============================================================================
-- QUERY 1: CUSTOMER CONTACT INFORMATION & ENGAGEMENT TRACKING
-- ============================================================================
-- BUSINESS VALUE:
--   - Enables targeted marketing campaigns and customer outreach
--   - Helps identify customer acquisition timeline and retention patterns
--   - Supports customer service operations with complete contact details
--   - Allows tracking of customer lifecycle from registration date
-- DECISION SUPPORT:
--   - Identify oldest customers for loyalty reward programs
--   - Target recent registrations with onboarding campaigns
--   - Segment customers by registration period for cohort analysis
-- ============================================================================
-- 1. List all customers with their email and phone number
SELECT -- 2.5
    customer_ID,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    phone_number,
    registration_date
FROM customer
ORDER BY registration_date DESC;

-- ============================================================================
-- QUERY 2: CATEGORY-BASED PRODUCT INVENTORY & SHELF MANAGEMENT
-- ============================================================================
-- BUSINESS VALUE:
--   - Supports inventory management by product category
--   - Helps with store layout optimization and shelf placement decisions
--   - Enables category-based promotional planning
--   - Aids in demand forecasting for specific product categories
-- DECISION SUPPORT:
--   - Determine which product categories to stock based on popularity
--   - Plan shelf space allocation across different aisles
--   - Identify opportunities for cross-selling within categories
-- ============================================================================
-- 2. Find all products in the Bakery Desserts aisle
SELECT -- 3 3 2 3 3 = 3
    p.product_ID,
    p.product_name,
    a.aisle
FROM products p
JOIN aisles a ON p.aisle_ID = a.aisle_ID
WHERE a.aisle = 'bakery desserts'
ORDER BY p.product_name;

-- PART 1: 12 BASIC MEANINGFUL QUERIES

-- Basic 1: List all customers with contact info and registration date
-- Useful for marketing lists and customer service
SELECT -- maybe
    customer_ID,
    CONCAT(first_name, IFNULL(CONCAT(' ', middle_name), ''), ' ', last_name) AS full_name,
    email,
    phone_number,
    registration_date,
    last_login_date
FROM customer
ORDER BY registration_date DESC;

-- Basic 2: Count customers by province (from address)
-- Helps with geographic market sizing / regional focus
SELECT -- 4 5 4.5 4 4 4 = 4
    a.province,
    COUNT(DISTINCT a.customer_ID) AS customer_count
FROM address a
GROUP BY a.province
ORDER BY customer_count DESC;

-- Basic 3: Orders count and average invoice amount per customer
-- Uses invoice.total_amount (average invoice value per customer)
SELECT -- advance -- 5 5 5 5 5 5 = 5
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_ID) AS orders_count,
    IFNULL(ROUND(AVG(i.total_amount),2), 0) AS avg_invoice_amount
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
ORDER BY orders_count DESC;

-- Basic 4: Cancelled deliveries (delivery.status = 'Cancelled')
-- Operational view for fulfillment team
SELECT -- 3.5 4 3.5 4 3 3.5 = 3.5
    d.delivery_ID,
    d.order_ID,
    d.scheduled_date,
    d.status
FROM delivery d
WHERE d.status = 'Cancelled'
ORDER BY d.scheduled_date ASC;

-- Basic 5: Product counts by department
-- Measures SKU distribution across departments
SELECT -- 3 4 3.5 3.5 3.5 3.5 = 3.5
    d.department_ID,
    d.department,
    COUNT(p.product_ID) AS product_count
FROM departments d
LEFT JOIN products p ON d.department_ID = p.department_ID
GROUP BY d.department_ID, d.department
ORDER BY product_count DESC;

-- Basic 6: Order volume by day-of-week (orders.order_dow)
-- Shows busiest weekdays to staff operations accordingly
SELECT -- 4.5 4 3.5 4.5 4.5 = 4.25
    o.order_dow AS day_of_week,
    COUNT(*) AS orders_count
FROM orders o
GROUP BY o.order_dow
ORDER BY orders_count DESC;

-- Basic 7: Loyalty membership distribution by tier (from loyalty_membership)
SELECT  -- 2 2.5 2.5 3 3 2 = 2.5
    tier_level,
    COUNT(membership_ID) AS members
FROM loyalty_membership
GROUP BY tier_level;

-- Basic 8: Dormant customers: last login more than 90 days ago
-- Useful for reactivation campaigns
SELECT -- 4.5 4.5 4 5 4 4 = 4.5
    customer_ID,
    CONCAT(first_name,' ', last_name) AS customer_name,
    last_login_date,
    DATEDIFF(NOW(), last_login_date) AS days_since_login
FROM customer
WHERE last_login_date IS NOT NULL
    AND DATEDIFF(NOW(), last_login_date) > 30 -- 30 30 30 30 45 30 = 45
ORDER BY days_since_login DESC;

-- Basic 9: Products with low inventory (quantity_on_hand <= reorder_level)
SELECT -- 4 4 4 4 4 4 444 4 44444444 = 4 
    ir.inventory_ID,
    ir.product_ID,
    p.product_name,
    ir.quantity_on_hand,
    ir.reorder_level
FROM inventory_record ir
JOIN products p ON ir.product_ID = p.product_ID
WHERE ir.quantity_on_hand <= ir.reorder_level
ORDER BY ir.quantity_on_hand ASC;

-- Basic 10: Customers with failed payment attempts
SELECT -- 2.5 2 2 3.5 2.5 = 2.5
    pt.customer_ID,
    COUNT(*) AS failed_payments,
    ROUND((DATEDIFF(NOW(), c.date_of_birth)/365),0) AS Age
FROM payment_transaction pt
join customer c on pt.customer_ID = c.customer_ID
WHERE pt.status = 'Failed'
GROUP BY pt.customer_ID
ORDER BY Age DESC;

-- Basic 11: Active promotions (current date between start and end)
SELECT -- 4 4 4 4 4 4 = 4
    code,
    product_ID,
    discount_type,
    discount_value,
    start_date,
    end_date
FROM promotion
WHERE start_date <= NOW() AND end_date >= NOW()
ORDER BY end_date ASC;

-- Basic 12: Average rating per product (join order_products -> review)
SELECT -- advance -- 5 4.5 4.5 5 4.5 5 = 4.75
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

-- PART 2: 12 ADVANCED MEANINGFUL QUERIES

-- Advanced 1: Customers who placed orders but have no paid invoices
-- (identify customers with outstanding billing or missing invoices)
SELECT DISTINCT -- 2.5 1.5 3 2 ? ? = 2.25
    o.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_ID
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID AND i.status = 'Paid' -- AND i.status != 'Cancelled'
WHERE i.invoice_ID IS NULL
ORDER BY o.customer_ID;

-- Advanced 2: Top customers by lifetime invoice total (lifetime value)
SELECT -- 2 3.5 2 3.5 3.5 3.5 = 3
    i.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    ROUND(SUM(i.total_amount),2) AS lifetime_value,
    COUNT(DISTINCT i.order_ID) AS invoice_count
FROM invoice i
JOIN customer c ON i.customer_ID = c.customer_ID
GROUP BY i.customer_ID
ORDER BY lifetime_value DESC
LIMIT 20;

-- Advanced 3: Most-ordered products (popularity) with department
SELECT -- 4 4 4.5 3.75  4 4 = 4
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

-- Advanced 4: late delivery rate by month
-- On-time defined as actual_delivery_date > scheduled_date
SELECT -- 4 4.5 4.5 4 5 4 = 4.5
    DATE_FORMAT(d.scheduled_date, '%Y-%m') AS delivery_month,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN d.actual_delivery_date IS NOT NULL
                        AND d.actual_delivery_date > d.scheduled_date THEN 1 ELSE 0 END) AS late_delivery_count,
    ROUND(100 * SUM(CASE WHEN d.actual_delivery_date IS NOT NULL
                        AND d.actual_delivery_date > d.scheduled_date THEN 1 ELSE 0 END) / COUNT(*),2) AS late_delivery_percentage
FROM delivery d
WHERE d.status = 'Delivered'
GROUP BY DATE_FORMAT(d.scheduled_date, '%Y-%m')
ORDER BY delivery_month DESC;

-- Advanced 5: Customers at risk of churn: no invoice in last 30 days and last login > 30 days
SELECT -- Same as the basic one
    c.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    MAX(i.invoice_date) AS last_invoice_date,
    c.last_login_date
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
GROUP BY c.customer_ID, c.first_name, c.last_name, c.last_login_date
HAVING (last_invoice_date IS NULL OR DATEDIFF(NOW(), last_invoice_date) > 30)
     AND (c.last_login_date IS NULL OR DATEDIFF(NOW(), c.last_login_date) > 30)
ORDER BY last_invoice_date ASC;

-- Advanced 6: Inventory turnover proxy: number of orders containing product / average quantity_on_hand
-- Note: inventory_record may contain multiple records per product; use AVG(quantity_on_hand)
SELECT -- 5 5 5 5 5 5 = 5
    p.product_ID,
    p.product_name,
    COUNT(DISTINCT op.order_ID) AS orders_with_product,
    IFNULL(ROUND(AVG(ir.quantity_on_hand),2),0) AS avg_quantity_on_hand,
    CASE WHEN AVG(ir.quantity_on_hand) > 0 THEN ROUND(COUNT(DISTINCT op.order_ID) / AVG(ir.quantity_on_hand), 4)
             ELSE NULL END AS turnover_proxy
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN inventory_record ir ON p.product_ID = ir.product_ID
GROUP BY p.product_ID, p.product_name
ORDER BY turnover_proxy DESC
LIMIT 50;

-- Advanced 7: Products never ordered (potential dead SKUs)
SELECT -- 4.5 4 4 4 4 4 = 4
    p.product_ID,
    p.product_name,
    d.department
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID -- delete to be basic
WHERE op.order_ID IS NULL
ORDER BY p.product_ID;

-- Advanced 8: Customers with multiple addresses (household / multi-location)
SELECT -- 1 1 1 1 1 1 = 1
    a.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(*) AS address_count
FROM address a
JOIN customer c ON a.customer_ID = c.customer_ID
GROUP BY a.customer_ID
HAVING address_count > 1
ORDER BY address_count DESC;

-- Advanced 9: Payment status trends: monthly success vs failed counts
SELECT -- 1 1 1 1 1 1 1 = 1
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(CASE WHEN status = 'Successful' THEN 1 ELSE 0 END) AS successful_payments,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed_payments,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending_payments
FROM payment_transaction
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month DESC;

-- Advanced 10: Promotion effectiveness: count of distinct orders that included promoted products during promotion window
SELECT -- 3.5 3.5 ? 3 3.5 = 3.5?
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
    AND pr.start_date <= NOW()  -- optional: limit to past/current promotions
    AND pr.end_date >= NOW()
GROUP BY pr.code, pr.product_ID, p.product_name, pr.start_date, pr.end_date
ORDER BY orders_with_promo_product DESC;

-- Advanced 11: Loyalty program impact: average invoice total for members vs non-members
SELECT -- 5 5 5 5 5 5  = 5
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

-- Advanced 12: Reviews vs invoice amount: compare average invoice amount for highly-rated orders (rating >=4) vs low-rated
SELECT --???????
    rating_bucket,
    ROUND(AVG(total_amount),2) AS avg_invoice_amount,
    COUNT(*) AS sample_size
FROM (
    SELECT
        CASE WHEN r.rating >= 4 THEN 'High (rating >= 4)' ELSE 'Low' END AS rating_bucket,
        i.total_amount
    FROM order_products op
    JOIN review r ON op.review_ID = r.review_ID
    JOIN orders o ON op.order_ID = o.order_ID
    JOIN invoice i ON o.order_ID = i.order_ID
) t
GROUP BY rating_bucket
ORDER BY rating_bucket DESC;

--   - Identifies opportunities for payment processing optimization
--   - Helps assess fraud risk by payment method
-- KEY METRICS:
--   - Transaction volume by payment method shows customer preferences
--   - Average transaction size indicates payment method viability
--   - Unique customers per method reveals market penetration
-- BUSINESS IMPACT:
--   - Optimize payment processing fees by method
--   - Prioritize high-volume payment methods for faster processing
--   - Implement additional fraud checks for high-risk methods
-- ============================================================================
-- 5. Payment Analysis: Transaction patterns by payment method
SELECT -- 0 0 0 0 0 0 0 0 0 0 
    pt.payment_method,
    COUNT(pt.payment_ID) AS total_transactions,
    SUM(pt.amount) AS total_amount,
    ROUND(AVG(pt.amount), 2) AS avg_transaction_amount,
    MIN(pt.amount) AS min_amount,
    MAX(pt.amount) AS max_amount,
    COUNT(DISTINCT pt.customer_ID) AS unique_customers
FROM payment_transaction pt
GROUP BY pt.payment_method
ORDER BY total_amount DESC;

-- ============================================================================
-- ADVANCED QUERY 6: MARKET BASKET ANALYSIS & PRODUCT BUNDLING
-- ============================================================================
-- BUSINESS VALUE:
--   - Identifies products frequently purchased together (associations)
--   - Enables strategic product bundling and recommendation engines
--   - Maximizes average order value through smart product placement
--   - Improves customer satisfaction through relevant suggestions
-- KEY METRICS:
--   - Times bought together: Frequency of association
--   - Product pair pricing: Opportunity for bundled discounts
-- BUSINESS IMPACT:
--   - Create attractive product bundles with 15-20% discount
--   - Implement "frequently bought together" recommendations in checkout
--   - Place complementary products in nearby shelf locations
--   - Design bundled packaging to increase average order value by 10-15%
-- ============================================================================
-- 6. Cross-Selling Opportunity: Products frequently bought together
SELECT 
    op1.product_ID AS product_1_id,
    p1.product_name AS product_1,
    op2.product_ID AS product_2_id,
    p2.product_name AS product_2,
    COUNT(DISTINCT op1.order_ID) AS times_bought_together,
    ROUND(AVG(op1.price), 2) AS avg_price_product_1,
    ROUND(AVG(op2.price), 2) AS avg_price_product_2
FROM order_products op1
JOIN order_products op2 ON op1.order_ID = op2.order_ID 
    AND op1.product_ID < op2.product_ID
JOIN products p1 ON op1.product_ID = p1.product_ID
JOIN products p2 ON op2.product_ID = p2.product_ID
GROUP BY op1.product_ID, p1.product_name, op2.product_ID, p2.product_name
HAVING COUNT(DISTINCT op1.order_ID) >= 5
ORDER BY times_bought_together DESC
LIMIT 20;

-- ============================================================================
-- ADVANCED QUERY 7: INVENTORY OPTIMIZATION & WORKING CAPITAL MANAGEMENT
-- ============================================================================
-- BUSINESS VALUE:
--   - Measures inventory turnover efficiency for each product
--   - Identifies slow-moving inventory tying up working capital
--   - Supports inventory rebalancing and clearance decisions
--   - Enables data-driven stocking decisions
-- KEY METRICS:
--   - Stock turnover days: Lower is better (faster cash conversion)
--   - Stock levels: Critical/Low/Normal categorization
-- BUSINESS IMPACT:
--   - Reduce holding costs by identifying slow movers
--   - Free up cash by liquidating dead inventory
--   - Implement fast-track ordering for fast-moving items
--   - Optimize safety stock levels based on turnover rates
-- ============================================================================
-- 7. Inventory Management: Stock turnover rate analysis
SELECT 
    p.product_ID,
    p.product_name,
    ir.quantity_on_hand,
    ir.reorder_point,
    ir.reorder_quantity,
    COALESCE(SUM(op.quantity), 0) AS units_sold_last_90_days,
    ROUND(
        COALESCE(SUM(op.quantity), 0) / NULLIF(ir.quantity_on_hand, 0) * 30, 2
    ) AS stock_turnover_days,
    CASE 
        WHEN ir.quantity_on_hand <= ir.reorder_point THEN 'CRITICAL'
        WHEN ir.quantity_on_hand <= ir.reorder_point * 1.5 THEN 'LOW'
        ELSE 'NORMAL'
    END AS stock_level
FROM inventory_record ir
JOIN products p ON ir.product_ID = p.product_ID
LEFT JOIN order_products op ON p.product_ID = op.product_ID 
    AND op.order_date >= DATE_SUB(NOW(), INTERVAL 90 DAY)
GROUP BY p.product_ID, p.product_name, ir.quantity_on_hand, 
         ir.reorder_point, ir.reorder_quantity
ORDER BY stock_turnover_days DESC;

-- ============================================================================
-- ADVANCED QUERY 8: PRODUCT QUALITY & CUSTOMER SATISFACTION METRICS
-- ============================================================================
-- BUSINESS VALUE:
--   - Measures product satisfaction through review ratings
--   - Identifies quality issues requiring corrective action
--   - Supports product improvement and discontinuation decisions
--   - Enables reputation management and response strategies
-- KEY METRICS:
--   - Average rating: Overall product satisfaction (target: >4.0/5.0)
--   - Positive percentage: Indicator of product quality (target: >80%)
--   - Review count: Product popularity and sales volume
-- BUSINESS IMPACT:
--   - Highlight top-rated products in marketing campaigns
--   - Address quality issues in low-rated products
--   - Remove products with <3.0 rating after review
--   - Use high ratings in testimonial marketing
-- ============================================================================
-- 8. Customer Review Analysis: Product ratings and sentiment
SELECT 
    p.product_ID,
    p.product_name,
    COUNT(r.review_ID) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN r.rating = 3 THEN 1 ELSE 0 END) AS neutral_reviews,
    SUM(CASE WHEN r.rating < 3 THEN 1 ELSE 0 END) AS negative_reviews,
    ROUND(
        (SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) / COUNT(r.review_ID) * 100), 2
    ) AS positive_percentage
FROM products p
LEFT JOIN review r ON p.product_ID = r.product_ID
GROUP BY p.product_ID, p.product_name
HAVING COUNT(r.review_ID) > 0
ORDER BY avg_rating DESC, review_count DESC
LIMIT 25;

-- ============================================================================
-- ADVANCED QUERY 9: ACCOUNTS RECEIVABLE & REVENUE RECOGNITION
-- ============================================================================
-- BUSINESS VALUE:
--   - Tracks invoice status and payment collection progress
--   - Critical for financial reporting and cash flow forecasting
--   - Identifies overdue invoices requiring collection action
--   - Supports DSO (Days Sales Outstanding) calculations
-- KEY METRICS:
--   - Collection rate: Percentage of invoiced amount paid (target: >95%)
--   - Payment status breakdown: Paid vs. Pending
--   - Monthly trends: Collection efficiency improvement tracking
-- BUSINESS IMPACT:
--   - Implement automated payment reminders for pending invoices
--   - Create early warning system for potential bad debts
--   - Negotiate payment terms based on collection performance
--   - Forecast monthly cash inflows based on collection rates
-- ============================================================================
-- 9. Invoice and Revenue Tracking: Monthly invoice analysis
SELECT 
    DATE_FORMAT(inv.invoice_date, '%Y-%m') AS invoice_month,
    COUNT(inv.invoice_ID) AS total_invoices,
    SUM(inv.total_amount) AS total_revenue,
    ROUND(AVG(inv.total_amount), 2) AS avg_invoice_value,
    SUM(CASE WHEN inv.payment_status = 'Paid' THEN inv.total_amount ELSE 0 END) AS amount_paid,
    SUM(CASE WHEN inv.payment_status = 'Pending' THEN inv.total_amount ELSE 0 END) AS amount_pending,
    ROUND(
        (SUM(CASE WHEN inv.payment_status = 'Paid' THEN inv.total_amount ELSE 0 END) / 
         SUM(inv.total_amount) * 100), 2
    ) AS collection_rate
FROM invoice inv
GROUP BY DATE_FORMAT(inv.invoice_date, '%Y-%m')
ORDER BY invoice_month DESC;

-- ============================================================================
-- ADVANCED QUERY 10: MARKETING CAMPAIGN ROI & PROMOTIONAL EFFECTIVENESS
-- ============================================================================
-- BUSINESS VALUE:
--   - Measures return on investment for promotional campaigns
--   - Identifies which promotions drive incremental sales
--   - Enables data-driven promotional calendar planning
--   - Supports vendor negotiation for promotional funding
-- KEY METRICS:
--   - Revenue lift %: Additional revenue generated by promotion
--   - Orders with promotion: Volume impact of discount
--   - Units sold: Demand elasticity indicator
-- BUSINESS IMPACT:
--   - Allocate promotion budget to high-ROI campaigns
--   - Time promotions based on historical effectiveness
--   - Negotiate vendor support for low-performing categories
--   - Eliminate low-ROI promotions from future calendars
-- ============================================================================
-- 10. Promotion Effectiveness: Impact of promotions on sales
SELECT 
    promo.promotion_ID,
    promo.promotion_name,
    promo.discount_percentage,
    promo.start_date,
    promo.end_date,
    COUNT(DISTINCT op.order_ID) AS orders_with_promotion,
    SUM(op.quantity) AS units_sold,
    ROUND(SUM(op.quantity * op.price), 2) AS promotion_revenue,
    ROUND(
        (SUM(op.quantity * op.price) / NULLIF(
            (SELECT ROUND(SUM(op2.quantity * op2.price), 2) 
             FROM order_products op2 
             WHERE op2.product_ID = op.product_ID 
             AND op2.order_date NOT BETWEEN promo.start_date AND promo.end_date), 0)) * 100, 2
    ) AS revenue_lift_percentage
FROM promotion promo
LEFT JOIN order_products op ON FIND_IN_SET(op.product_ID, 
    (SELECT GROUP_CONCAT(product_ID) FROM products WHERE promotion_ID = promo.promotion_ID))
WHERE op.order_date BETWEEN promo.start_date AND promo.end_date
GROUP BY promo.promotion_ID, promo.promotion_name, promo.discount_percentage, 
         promo.start_date, promo.end_date
ORDER BY promotion_revenue DESC;

-- ============================================================================
-- ADVANCED QUERY 11: GEOGRAPHIC EXPANSION & REGIONAL PERFORMANCE
-- ============================================================================
-- BUSINESS VALUE:
--   - Analyzes regional market performance and penetration
--   - Supports expansion strategy decisions for new markets
--   - Identifies high-performing regions for resource allocation
--   - Measures delivery performance by geographic region
-- KEY METRICS:
--   - Provincial revenue: Market size indicator
--   - Customer count: Market penetration level
--   - Delivery success rate: Regional logistics capability
--   - Average order value: Regional customer spending power
-- BUSINESS IMPACT:
--   - Prioritize expansion in high-AOV regions
--   - Invest in delivery infrastructure in high-volume regions
--   - Develop region-specific product assortments
--   - Target underserved provinces for growth initiatives
-- ============================================================================
-- 11. Geographic Analysis: Sales by region/province
SELECT 
    a.province,
    COUNT(DISTINCT a.customer_ID) AS customer_count,
    COUNT(DISTINCT o.order_ID) AS total_orders,
    SUM(o.order_total) AS provincial_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,
    COUNT(DISTINCT d.delivery_ID) AS completed_deliveries,
    ROUND(
        (COUNT(CASE WHEN d.status = 'Delivered' THEN 1 END) / 
         COUNT(d.delivery_ID) * 100), 2
    ) AS delivery_success_rate
FROM address a
LEFT JOIN customer c ON a.customer_ID = c.customer_ID
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN delivery d ON o.order_ID = d.order_ID
GROUP BY a.province
HAVING customer_count > 0
ORDER BY provincial_revenue DESC;

-- ============================================================================
-- ADVANCED QUERY 12: LOYALTY PROGRAM ROI & MEMBER VALUE ANALYSIS
-- ============================================================================
-- BUSINESS VALUE:
--   - Evaluates profitability of loyalty program investment
--   - Measures member engagement and lifetime value by tier
--   - Identifies opportunities for member tier migration
--   - Supports program redesign and benefit optimization decisions
-- KEY METRICS:
--   - Total spending by tier: Revenue contribution
--   - Average order value: Customer spending patterns by tier
--   - Days as member: Member tenure and program maturity
--   - Member count: Program penetration and growth
-- TARGETS:
--   - Gold members: >3x spending vs regular customers
--   - Silver members: >1.5x spending vs regular customers
-- BUSINESS IMPACT:
--   - Increase Gold membership by 10% annually
--   - Create upgrade incentives for Silver→Gold migration
--   - Design benefits to improve retention and spending
--   - Calculate program costs vs. incremental revenue by tier
-- ============================================================================
-- 12. Loyalty Program ROI: Membership tier analysis with spending patterns
SELECT 
    CASE 
        WHEN b.membership_ID IS NOT NULL THEN 'Bronze'
        WHEN s.membership_ID IS NOT NULL THEN 'Silver'
        WHEN g.membership_ID IS NOT NULL THEN 'Gold'
        ELSE 'Non-Member'
    END AS membership_tier,
    COUNT(DISTINCT lm.customer_ID) AS member_count,
    ROUND(AVG(COALESCE(b.birthday_point, s.birthday_point, g.birthday_point, 0)), 2) AS avg_points,
    COUNT(DISTINCT o.order_ID) AS total_orders,
    SUM(o.order_total) AS total_spending,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,
    MAX(o.order_date) AS last_purchase_date,
    DATEDIFF(NOW(), lm.membership_join_date) AS days_as_member
FROM loyalty_membership lm
LEFT JOIN customer c ON lm.customer_ID = c.customer_ID
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
LEFT JOIN bronze b ON lm.membership_ID = b.membership_ID
LEFT JOIN silver s ON lm.membership_ID = s.membership_ID
LEFT JOIN gold g ON lm.membership_ID = g.membership_ID
GROUP BY membership_tier, lm.membership_join_date
ORDER BY 
    CASE 
        WHEN membership_tier = 'Gold' THEN 1
        WHEN membership_tier = 'Silver' THEN 2
        WHEN membership_tier = 'Bronze' THEN 3
        ELSE 4
    END;

-- ======================================================================
-- END OF QUERIES
-- ======================================================================

-- ======================================================================
-- BUSINESS INTELLIGENCE SUMMARY & DECISION SUPPORT FRAMEWORK
-- ======================================================================
-- 
-- BASIC QUERIES (1-12) - OPERATIONAL DASHBOARDS:
-- These queries provide day-to-day operational insights for managers
-- to monitor business health and handle immediate issues.
-- 
-- Use Cases:
--   • Inventory managers: Monitor low stock and pending deliveries
--   • Sales team: Track customer orders and recent transactions
--   • Logistics: Monitor delivery performance and pending shipments
--   • Marketing: Access customer contact info for campaigns
--   • Finance: Track delivered orders for revenue recognition
--
-- ======================================================================
--
-- ADVANCED QUERIES (1-12) - STRATEGIC ANALYTICS:
-- These queries provide deep business insights for strategic decisions
-- and board-level reporting on business performance and opportunities.
--
-- Use Cases:
--   • C-Suite: Customer segmentation, geographic expansion, ROI analysis
--   • Finance: Revenue forecasting, inventory valuation, cash flow
--   • Operations: Supply chain optimization, delivery performance
--   • Marketing: Campaign effectiveness, customer engagement, seasonality
--   • Product: Portfolio analysis, quality metrics, bundle opportunities
--
-- ======================================================================
--
-- KEY PERFORMANCE INDICATORS (KPIs) TRACKED:
--
-- Customer Metrics:
--   ✓ Customer Lifetime Value (CLV) - Total spending per customer
--   ✓ Customer Segmentation - VIP/Premium/Regular classification
--   ✓ Customer Retention - Login frequency and repeat purchase rate
--
-- Sales & Revenue:
--   ✓ Revenue per Product - Identifies top performers
--   ✓ Average Order Value (AOV) - Customer spending power
--   ✓ Seasonal Trends - Month-over-month and year-over-year patterns
--   ✓ Promotion ROI - Campaign effectiveness and revenue lift
--
-- Operations:
--   ✓ On-Time Delivery Rate - SLA compliance (Target: >95%)
--   ✓ Inventory Turnover - Working capital efficiency
--   ✓ Stock-out Risk - Low inventory alerts
--
-- Loyalty & Engagement:
--   ✓ Membership Distribution - Tier breakdown and growth
--   ✓ Member Spending - Revenue by membership tier
--   ✓ Loyalty Program ROI - Cost-benefit analysis
--
-- ======================================================================
--
-- RECOMMENDED REPORTING FREQUENCY:
--
--   Daily:  Queries 4, 10 (Pending deliveries, Low inventory)
--   Weekly: Queries 3, 8, 9 (Customer value, Recent sales, Orders)
--   Monthly: Queries 1-3, 5-7, 11-12 (All advanced queries)
--   Quarterly: Board review of all advanced queries for strategy
--   Annually: Strategic planning based on annual trends and opportunities
--
-- ======================================================================

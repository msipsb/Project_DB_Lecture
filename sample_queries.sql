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
SELECT 
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
SELECT 
    p.product_ID,
    p.product_name,
    p.price,
    a.aisle
FROM products p
JOIN aisles a ON p.aisle_ID = a.aisle_ID
WHERE a.aisle = 'bakery desserts'
ORDER BY p.product_name;

-- ============================================================================
-- QUERY 3: CUSTOMER VALUE & PURCHASE FREQUENCY ANALYSIS
-- ============================================================================
-- BUSINESS VALUE:
--   - Identifies high-value customers vs. low-frequency customers
--   - Critical for customer lifetime value (CLV) calculations
--   - Supports VIP customer identification and special treatment programs
--   - Enables personalized marketing based on purchase behavior
-- DECISION SUPPORT:
--   - Allocate marketing budget to high-value customers
--   - Design retention programs for at-risk customers
--   - Prioritize service improvements for high-frequency buyers
--   - Identify potential churn risk among loyal customers
-- ============================================================================
-- 3. Get total orders count and average order value by customer
SELECT 
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_ID) AS total_orders,
    ROUND(AVG(o.order_total), 2) AS avg_order_value
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
GROUP BY c.customer_ID, c.first_name, c.last_name
HAVING total_orders > 0
ORDER BY total_orders DESC;

-- ============================================================================
-- QUERY 4: LOGISTICS & DELIVERY PERFORMANCE MONITORING
-- ============================================================================
-- BUSINESS VALUE:
--   - Monitors delivery performance and identifies bottlenecks
--   - Essential for customer satisfaction and service level agreements (SLAs)
--   - Helps optimize logistics operations and reduce fulfillment costs
--   - Identifies delayed shipments that need management attention
-- DECISION SUPPORT:
--   - Adjust delivery partner capacity based on pending order volume
--   - Implement early warning system for delayed deliveries
--   - Negotiate SLAs with logistics providers
-- ============================================================================
-- 4. View pending deliveries
SELECT 
    d.delivery_ID,
    d.order_ID,
    o.order_date,
    d.scheduled_date,
    d.status
FROM delivery d
JOIN orders o ON d.order_ID = o.order_ID
WHERE d.status = 'Pending'
ORDER BY d.scheduled_date;

-- ============================================================================
-- QUERY 5: GEOGRAPHIC MARKET ANALYSIS & EXPANSION PLANNING
-- ============================================================================
-- BUSINESS VALUE:
--   - Analyzes geographic distribution of customer base
--   - Supports regional expansion and market penetration strategies
--   - Identifies regional service gaps and opportunities
--   - Enables localized marketing and inventory decisions
-- DECISION SUPPORT:
--   - Plan regional warehouse locations based on customer concentration
--   - Develop region-specific marketing campaigns
--   - Allocate inventory based on regional demand patterns
-- ============================================================================
-- 5. Get customer address information
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.house_number,
    a.street,
    a.city,
    a.province,
    a.postal_code,
    a.country
FROM customer c
JOIN address a ON c.customer_ID = a.customer_ID
WHERE a.country = 'Thailand'
ORDER BY a.city;

-- ============================================================================
-- QUERY 6: PREMIUM PRODUCT PRICING & MARGIN ANALYSIS
-- ============================================================================
-- BUSINESS VALUE:
--   - Identifies premium product segment for strategic focus
--   - Supports pricing optimization and margin management
--   - Helps understand product portfolio value distribution
--   - Informs inventory stocking decisions for high-margin items
-- DECISION SUPPORT:
--   - Increase marketing focus on high-margin products
--   - Negotiate better margins with suppliers for bulk items
--   - Create exclusive sections for premium products
-- ============================================================================
-- 6. Find top 10 most expensive products
SELECT 
    product_ID,
    product_name,
    price,
    (SELECT aisle FROM aisles WHERE aisle_ID = products.aisle_ID) AS aisle_name
FROM products
ORDER BY price DESC
LIMIT 10;

-- ============================================================================
-- QUERY 7: DEPARTMENT PERFORMANCE & PRODUCT MIX ANALYSIS
-- ============================================================================
-- BUSINESS VALUE:
--   - Evaluates department-level performance metrics
--   - Identifies underperforming departments requiring attention
--   - Supports inventory allocation decisions across departments
--   - Enables benchmarking and comparative analysis
-- DECISION SUPPORT:
--   - Allocate shelf space based on product count and margins
--   - Identify departments with pricing power (high average prices)
--   - Plan promotions for departments with low average pricing
-- ============================================================================
-- 7. Count products by department
SELECT 
    d.department_ID,
    d.department,
    COUNT(p.product_ID) AS product_count,
    ROUND(AVG(p.price), 2) AS avg_price
FROM departments d
LEFT JOIN products p ON d.department_ID = p.department_ID
GROUP BY d.department_ID, d.department
ORDER BY product_count DESC;

-- ============================================================================
-- QUERY 8: RECENT SALES PERFORMANCE & SHORT-TERM TRENDS
-- ============================================================================
-- BUSINESS VALUE:
--   - Monitors recent sales activity and short-term trends
--   - Identifies current best-sellers and emerging trends
--   - Supports fast-response inventory replenishment
--   - Enables real-time business performance tracking
-- DECISION SUPPORT:
--   - Quickly identify and capitalize on emerging trends
--   - Adjust promotional calendars based on recent demand
--   - Monitor impact of recent marketing campaigns
-- ============================================================================
-- 8. Get all orders placed in the last 30 days
SELECT 
    o.order_ID,
    c.email,
    o.order_date,
    o.order_total,
    o.order_status
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY o.order_date DESC;

-- ============================================================================
-- QUERY 9: FULFILLMENT SUCCESS TRACKING & CUSTOMER SATISFACTION
-- ============================================================================
-- BUSINESS VALUE:
--   - Tracks successful order fulfillment and delivery completion
--   - Critical metric for customer satisfaction and retention
--   - Identifies potential service issues with specific customers
--   - Enables revenue confirmation and cash flow forecasting
-- DECISION SUPPORT:
--   - Track fulfillment rate for performance incentives
--   - Identify customers with delayed deliveries for follow-up
--   - Correlate delivery time with customer satisfaction
-- ============================================================================
-- 9. List all delivered orders with customer details
SELECT 
    d.delivery_ID,
    d.order_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    d.actual_delivery_date,
    o.order_total
FROM delivery d
JOIN orders o ON d.order_ID = o.order_ID
JOIN customer c ON o.customer_ID = c.customer_ID
WHERE d.status = 'Delivered'
ORDER BY d.actual_delivery_date DESC;

-- ============================================================================
-- QUERY 10: SUPPLY CHAIN RISK MANAGEMENT & STOCKOUT PREVENTION
-- ============================================================================
-- BUSINESS VALUE:
--   - Identifies products at risk of stockout
--   - Prevents revenue loss from out-of-stock situations
--   - Optimizes inventory levels and working capital
--   - Supports just-in-time inventory management
-- DECISION SUPPORT:
--   - Trigger automated purchase orders for low-stock items
--   - Identify products requiring safety stock increases
--   - Plan supplier communications for urgent replenishment
-- ============================================================================
-- 10. Show products with low inventory
SELECT 
    ir.inventory_record_ID,
    p.product_ID,
    p.product_name,
    ir.quantity_on_hand,
    ir.reorder_point,
    CASE 
        WHEN ir.quantity_on_hand <= ir.reorder_point THEN 'Reorder Needed'
        ELSE 'Sufficient Stock'
    END AS stock_status
FROM inventory_record ir
JOIN products p ON ir.product_ID = p.product_ID
WHERE ir.quantity_on_hand <= ir.reorder_point
ORDER BY ir.quantity_on_hand;

-- ============================================================================
-- QUERY 11: LOYALTY PROGRAM PORTFOLIO ANALYSIS & MEMBER DISTRIBUTION
-- ============================================================================
-- BUSINESS VALUE:
--   - Monitors loyalty program health and member distribution
--   - Measures effectiveness of multi-tier membership strategy
--   - Identifies opportunities for member upgrades and retention
--   - Supports ROI calculation for loyalty program investments
-- DECISION SUPPORT:
--   - Allocate marketing budget based on member distribution
--   - Design tier-specific benefits to drive upgrades
--   - Calculate cost-benefit of each membership tier
-- ============================================================================
-- 11. Get loyalty membership breakdown by tier
SELECT 
    'Bronze' AS membership_tier,
    COUNT(*) AS member_count
FROM bronze
UNION ALL
SELECT 
    'Silver',
    COUNT(*)
FROM silver
UNION ALL
SELECT 
    'Gold',
    COUNT(*)
FROM gold
ORDER BY 
    CASE 
        WHEN membership_tier = 'Gold' THEN 1
        WHEN membership_tier = 'Silver' THEN 2
        WHEN membership_tier = 'Bronze' THEN 3
    END;

-- ============================================================================
-- QUERY 12: CUSTOMER ENGAGEMENT & ACTIVITY MONITORING
-- ============================================================================
-- BUSINESS VALUE:
--   - Monitors customer engagement through login activity
--   - Identifies dormant customers requiring reactivation campaigns
--   - Tracks purchase frequency and customer lifecycle stage
--   - Predicts churn risk based on login and purchase patterns
-- DECISION SUPPORT:
--   - Segment customers for targeted reactivation campaigns
--   - Identify most engaged customers for referral programs
--   - Monitor impact of marketing initiatives on login frequency
-- ============================================================================
-- 12. Display customer with their latest login and orders
SELECT 
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.last_login_date,
    COUNT(o.order_ID) AS lifetime_orders,
    MAX(o.order_date) AS last_order_date
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
WHERE c.last_login_date IS NOT NULL
GROUP BY c.customer_ID, c.first_name, c.last_name, c.last_login_date
ORDER BY c.last_login_date DESC;

-- ======================================================================
-- PART 2: 12 ADVANCED MEANINGFUL QUERIES
-- ======================================================================

-- ============================================================================
-- ADVANCED QUERY 1: CUSTOMER SEGMENTATION FOR TARGETED MARKETING
-- ============================================================================
-- BUSINESS VALUE:
--   - Performs RFM (Recency, Frequency, Monetary) analysis for customer segmentation
--   - Enables precision marketing with tailored messaging for each segment
--   - Optimizes marketing spend by prioritizing high-value customers
--   - Supports CLV (Customer Lifetime Value) predictions and optimization
-- KEY METRICS:
--   - VIP: Customers with >$5,000 lifetime value (top priority)
--   - Premium: Customers with $2,000-$5,000 lifetime value (growth potential)
--   - Regular: Customers with <$2,000 lifetime value (volume focus)
-- BUSINESS IMPACT:
--   - Allocate 60% of marketing budget to VIP & Premium segments
--   - Design tier-specific product recommendations
--   - Create early warning system for VIP churn prevention
-- ============================================================================
-- 1. Customer Segmentation: Identify VIP customers with high spending
SELECT 
    c.customer_ID,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_ID) AS total_orders,
    SUM(o.order_total) AS lifetime_value,
    AVG(o.order_total) AS avg_order_value,
    CASE 
        WHEN SUM(o.order_total) > 5000 THEN 'VIP'
        WHEN SUM(o.order_total) > 2000 THEN 'Premium'
        ELSE 'Regular'
    END AS customer_segment,
    DATEDIFF(NOW(), c.registration_date) AS days_as_customer
FROM customer c
LEFT JOIN orders o ON c.customer_ID = o.customer_ID
GROUP BY c.customer_ID, c.first_name, c.last_name, c.email, c.registration_date
HAVING COUNT(o.order_ID) > 0
ORDER BY lifetime_value DESC;

-- ============================================================================
-- ADVANCED QUERY 2: PRODUCT PROFITABILITY & SALES PERFORMANCE
-- ============================================================================
-- BUSINESS VALUE:
--   - Analyzes product-level profitability and sales effectiveness
--   - Identifies top-performing products driving business revenue
--   - Supports SKU rationalization decisions (keep, discontinue, expand)
--   - Enables pricing optimization based on demand patterns
-- KEY METRICS:
--   - Total Revenue: Indicates product importance to business
--   - Revenue per Order: Shows customer willingness to buy
--   - Total Units Sold: Volume indicator for popular products
-- BUSINESS IMPACT:
--   - Focus marketing on top 20% of products generating 80% of revenue
--   - Implement dynamic pricing for high-demand products
--   - Bundle low-revenue with high-revenue products
-- ============================================================================
-- 2. Product Performance Analysis: Revenue per product
SELECT 
    p.product_ID,
    p.product_name,
    d.department,
    COUNT(DISTINCT op.order_ID) AS orders_containing_product,
    SUM(op.quantity) AS total_units_sold,
    ROUND(SUM(op.quantity * op.price), 2) AS total_revenue,
    ROUND(AVG(op.price), 2) AS avg_selling_price,
    ROUND(SUM(op.quantity * op.price) / COUNT(DISTINCT op.order_ID), 2) AS revenue_per_order
FROM products p
JOIN order_products op ON p.product_ID = op.product_ID
JOIN departments d ON p.department_ID = d.department_ID
GROUP BY p.product_ID, p.product_name, d.department
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================================================
-- ADVANCED QUERY 3: SEASONALITY & DEMAND FORECASTING INSIGHTS
-- ============================================================================
-- BUSINESS VALUE:
--   - Identifies seasonal patterns and cyclical demand variations
--   - Enables accurate demand forecasting for inventory planning
--   - Supports workforce planning around peak seasons
--   - Identifies opportunities for off-season promotions
-- KEY METRICS:
--   - Monthly revenue trends reveal peak and low seasons
--   - Average order value trends indicate customer spending patterns
--   - Customer acquisition patterns show seasonal marketing effectiveness
-- BUSINESS IMPACT:
--   - Build inventory ahead of peak seasons
--   - Plan promotional discounts during low seasons
--   - Adjust staffing levels based on seasonal order patterns
-- ============================================================================
-- 3. Seasonal Trend Analysis: Orders by month for the past year
SELECT 
    DATE_TRUNC(o.order_date, MONTH) AS order_month,
    COUNT(o.order_ID) AS total_orders,
    SUM(o.order_total) AS monthly_revenue,
    ROUND(AVG(o.order_total), 2) AS avg_order_value,
    COUNT(DISTINCT o.customer_ID) AS unique_customers
FROM orders o
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY DATE_TRUNC(o.order_date, MONTH)
ORDER BY order_month DESC;

-- ============================================================================
-- ADVANCED QUERY 4: SERVICE LEVEL AGREEMENT (SLA) COMPLIANCE
-- ============================================================================
-- BUSINESS VALUE:
--   - Measures on-time delivery performance against SLAs
--   - Critical metric for customer satisfaction and retention
--   - Identifies seasonal delivery challenges
--   - Supports logistics partner performance reviews
-- KEY METRICS:
--   - On-time percentage: Direct indicator of service quality
--   - Monthly trends: Identify periods requiring additional resources
-- TARGET: Maintain >95% on-time delivery rate
-- BUSINESS IMPACT:
--   - Negotiate penalties/bonuses with logistics partners based on performance
--   - Invest in delivery infrastructure during low-performance periods
--   - Use performance data in customer communications
-- ============================================================================
-- 4. Delivery Performance Metrics: On-time delivery rate by month
SELECT 
    DATE_FORMAT(d.scheduled_date, '%Y-%m') AS delivery_month,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN d.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN d.status = 'Delivered' AND d.actual_delivery_date <= d.scheduled_date THEN 1 ELSE 0 END) AS on_time_deliveries,
    ROUND(
        (SUM(CASE WHEN d.status = 'Delivered' AND d.actual_delivery_date <= d.scheduled_date THEN 1 ELSE 0 END) / 
         SUM(CASE WHEN d.status = 'Delivered' THEN 1 ELSE 0 END) * 100), 2
    ) AS on_time_percentage
FROM delivery d
WHERE d.status = 'Delivered'
GROUP BY DATE_FORMAT(d.scheduled_date, '%Y-%m')
ORDER BY delivery_month DESC;

-- ============================================================================
-- ADVANCED QUERY 5: PAYMENT METHOD TRENDS & CASH FLOW ANALYSIS
-- ============================================================================
-- BUSINESS VALUE:
--   - Analyzes payment method preferences and transaction patterns
--   - Supports cash flow forecasting and payment reconciliation
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
SELECT 
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

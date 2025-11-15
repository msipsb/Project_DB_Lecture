# Detailed Explanation of sample_queries1.sql

## Overview
This document provides comprehensive explanations for each of the 10 queries in `sample_queries1.sql`, including business value, technical breakdown, and decision-making applications.

---

## Query 1: Customer Value Analysis with Invoice Data
**Score: 5/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM customer c**
   - Start with the customer table as the base
   - Ensures ALL customers are included (even those without orders)

2. **LEFT JOIN orders o ON c.customer_ID = o.customer_ID**
   - Connect customers to their orders
   - LEFT JOIN keeps customers with zero orders
   - Each customer-order pair creates a row

3. **LEFT JOIN invoice i ON o.order_ID = i.order_ID**
   - Connect orders to their invoices
   - LEFT JOIN handles orders that might not have invoices yet
   - Creates final dataset: customer → orders → invoices

4. **CONCAT(c.first_name, ' ', c.last_name) AS customer_name**
   - Combines first and last name with space between
   - Creates a readable full name
   - Example: "John" + " " + "Smith" = "John Smith"

5. **COUNT(DISTINCT o.order_ID) AS orders_count**
   - Counts unique orders per customer
   - DISTINCT prevents duplicate counting if invoice has multiple rows
   - Returns 0 for customers with no orders (due to LEFT JOIN)

6. **IFNULL(ROUND(AVG(i.total_amount),2), 0) AS avg_invoice_amount**
   - AVG(i.total_amount): Average invoice value per customer
   - ROUND(..., 2): Round to 2 decimal places (for currency)
   - IFNULL(..., 0): If customer has no invoices, show 0 instead of NULL

7. **GROUP BY c.customer_ID, c.first_name, c.last_name**
   - Aggregates data per customer
   - Must include all non-aggregated SELECT columns
   - Creates one summary row per customer

8. **ORDER BY orders_count DESC**
   - Sorts customers by order count (highest first)
   - Identifies most frequent customers at the top

### Business Value:

**Why This Query Matters:**
- **Customer Lifetime Value (CLV) Indicator**: Orders count and average invoice amount are key CLV metrics
- **Customer Segmentation**: Identifies VIP customers (high orders + high average) vs. one-time buyers
- **Marketing Budget Allocation**: Helps prioritize retention spending on high-value customers
- **Churn Risk Identification**: Customers with 0 orders need reactivation campaigns

**Who Uses This:**
- **Marketing Team**: Segment customers for personalized campaigns
- **Sales Team**: Identify accounts worthy of personal attention
- **Customer Success**: Prioritize retention efforts
- **Finance**: Forecast revenue based on customer tiers

**Business Decisions Enabled:**
1. Create VIP program for customers with 10+ orders and $500+ average invoice
2. Design win-back campaigns for customers with 1 order only
3. Allocate 60% of marketing budget to top 20% of customers
4. Set sales targets based on customer order frequency patterns

**Example Interpretation:**
```
customer_ID | customer_name | orders_count | avg_invoice_amount
5           | John Smith    | 25           | 450.00
7           | Jane Doe      | 1            | 120.00
```
- John Smith: VIP customer → personal account manager, early access to new products
- Jane Doe: One-time buyer → send reactivation email with 15% discount

---

## Query 2: Product Quality Analysis with Review Ratings
**Score: 4.75/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM products p**
   - Start with products table (all products in catalog)

2. **JOIN order_products op ON p.product_ID = op.product_ID**
   - INNER JOIN: Only keep products that have been ordered
   - Filters out never-ordered products
   - Links products to specific order lines

3. **JOIN review r ON op.review_ID = r.review_ID**
   - INNER JOIN: Only keep order lines with reviews
   - Each order_products row has one review_ID (per schema)
   - Final dataset: products that were ordered AND reviewed

4. **ROUND(AVG(r.rating),2) AS avg_rating**
   - AVG(r.rating): Average rating across all reviews for the product
   - Ratings are 1-5 per schema constraint
   - ROUND to 2 decimals for readability (e.g., 4.23)

5. **COUNT(r.review_ID) AS review_count**
   - Total number of reviews per product
   - Higher count = more statistical confidence in avg_rating

6. **HAVING review_count > 0**
   - Filter out products with no reviews (redundant here due to INNER JOIN)
   - Safety check ensuring only reviewed products appear

7. **ORDER BY avg_rating DESC, review_count DESC**
   - Primary sort: Highest rated products first
   - Secondary sort: Among same rating, more reviews = higher rank
   - Shows "best reviewed + most reviewed" products at top

### Business Value:

**Why This Query Matters:**
- **Product Quality Monitoring**: Identifies problematic products needing quality improvement
- **Marketing Asset Identification**: High-rated products can be featured in ads
- **Inventory Decisions**: Low-rated products may need discontinuation
- **Customer Satisfaction Proxy**: Product ratings predict overall satisfaction

**Who Uses This:**
- **Product Managers**: Decide which products to expand/discontinue
- **Quality Assurance**: Investigate low-rated products for defects
- **Marketing**: Feature top-rated products in campaigns
- **Merchandising**: Allocate shelf space based on ratings

**Business Decisions Enabled:**
1. Discontinue products with avg_rating < 3.0 and review_count > 20
2. Feature products with avg_rating >= 4.5 in homepage banners
3. Investigate products with sudden rating drops
4. Offer quality guarantees for 4.5+ rated products

**Target Metrics:**
- **Excellent**: avg_rating >= 4.5 → Featured products, premium pricing
- **Good**: avg_rating 4.0-4.5 → Standard products, maintain quality
- **Average**: avg_rating 3.0-4.0 → Monitor quality, consider improvements
- **Poor**: avg_rating < 3.0 → Urgent quality review or discontinue

**Example Interpretation:**
```
product_ID | product_name      | avg_rating | review_count
101        | Organic Apples    | 4.85       | 230
202        | Frozen Pizza      | 2.15       | 45
```
- Organic Apples: Feature in "Customer Favorites" section, maintain supplier relationship
- Frozen Pizza: Investigate quality complaints, consider switching supplier or removing

---

## Query 3: Unpaid Invoice Detection
**Score: 2.25/5 (Basic-Advanced hybrid)**

### SQL Code:
```sql
SELECT DISTINCT 
    o.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_ID
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID AND i.status = 'Paid'
WHERE i.invoice_ID IS NULL
ORDER BY o.customer_ID;
```

### Technical Breakdown:

1. **FROM orders o**
   - Start with all orders in the system

2. **JOIN customer c ON o.customer_ID = c.customer_ID**
   - INNER JOIN: Get customer names for display
   - Only keeps orders with valid customers (should be all due to FK)

3. **LEFT JOIN invoice i ON o.order_ID = i.order_ID AND i.status = 'Paid'**
   - LEFT JOIN with TWO conditions:
     - Match order to invoice
     - AND invoice status must be 'Paid'
   - Result: If no PAID invoice exists → i.invoice_ID = NULL
   - Scenarios creating NULL:
     - Order has no invoice at all
     - Order has invoice with status 'Unpaid' or 'Overdue'

4. **WHERE i.invoice_ID IS NULL**
   - Keeps only orders where LEFT JOIN found no paid invoice
   - These are billing problems: missing invoices or unpaid invoices

5. **SELECT DISTINCT**
   - Removes duplicate rows if customer has multiple unpaid orders
   - Shows each customer-order combination once

6. **ORDER BY o.customer_ID**
   - Groups results by customer for easier review

### Business Value:

**Why This Query Matters:**
- **Cash Flow Management**: Identifies revenue not yet collected
- **Billing Process Audit**: Finds orders missing invoices (system errors)
- **Collections Priority**: Shows which customers to contact for payment
- **Revenue Recognition**: Helps track when revenue can be recognized (after payment)

**Who Uses This:**
- **Finance Team**: Collections and accounts receivable management
- **Accounting**: Revenue reconciliation and audit trail
- **Customer Service**: Follow up on payment issues
- **Credit Manager**: Assess customer payment behavior

**Business Decisions Enabled:**
1. Send payment reminders to customers with unpaid invoices
2. Hold new orders from customers with overdue payments
3. Escalate to collections after 60 days unpaid
4. Investigate systemic billing issues if many orders lack invoices

**Key Metrics to Track:**
- **Count**: How many customers have unpaid invoices?
- **Age**: How old are these unpaid invoices (add DATEDIFF)?
- **Amount**: Total $ outstanding (requires joining invoice.total_amount)
- **Repeat offenders**: Customers appearing multiple times

**Example Interpretation:**
```
customer_ID | customer_name | order_ID
5           | John Smith    | 1001
5           | John Smith    | 1005
7           | Jane Doe      | 1012
```
- John Smith: 2 unpaid orders → Contact urgently, may require payment before future orders
- Jane Doe: 1 unpaid order → Send automated reminder email

**Recommended Enhancements:**
```sql
-- Add invoice amount and age:
SELECT DISTINCT 
    o.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_ID,
    i.total_amount,
    DATEDIFF(NOW(), i.invoice_date) AS days_unpaid
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID
WHERE i.status IN ('Unpaid', 'Overdue')
ORDER BY days_unpaid DESC;
```

---

## Query 4: Customer Lifetime Value Ranking
**Score: 3/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM invoice i**
   - Start with invoice table (only invoiced orders)
   - Assumes invoice records represent actual revenue

2. **JOIN customer c ON i.customer_ID = c.customer_ID**
   - INNER JOIN: Get customer names
   - Only customers with at least one invoice appear

3. **SUM(i.total_amount) AS lifetime_value**
   - Sums all invoice amounts per customer
   - Represents total revenue generated by customer
   - Includes tax_amount in total (per schema)

4. **ROUND(..., 2)**
   - Round to 2 decimal places for currency display

5. **COUNT(DISTINCT i.order_ID) AS invoice_count**
   - Count unique orders per customer
   - DISTINCT handles cases where one order might have multiple invoice records

6. **GROUP BY i.customer_ID**
   - Aggregates per customer
   - Creates one summary row per customer

7. **ORDER BY lifetime_value DESC LIMIT 20**
   - Shows top 20 highest-value customers
   - VIP/whale identification

### Business Value:

**Why This Query Matters:**
- **VIP Customer Identification**: Top 20% often generate 80% of revenue (Pareto Principle)
- **Account Management Prioritization**: Highest-value customers deserve personal attention
- **Retention ROI**: Retaining a $10K customer is more valuable than acquiring 10 new $1K customers
- **Risk Assessment**: Losing a top-20 customer significantly impacts revenue

**Who Uses This:**
- **Sales Leadership**: Assign best account managers to top customers
- **Marketing**: Create exclusive VIP programs and experiences
- **Customer Success**: Proactive outreach to prevent churn
- **Finance**: Revenue forecasting and concentration risk analysis

**Business Decisions Enabled:**
1. Assign dedicated account managers to customers with $5K+ lifetime value
2. Offer exclusive early access to new products for top 20
3. Quarterly business reviews with customers spending $10K+
4. Create "President's Club" for customers with $20K+ lifetime value

**Target Segmentation:**
```
Lifetime Value      | Segment  | Treatment
$10,000+           | VIP      | Personal account manager, priority support
$5,000 - $9,999    | Premium  | Quarterly check-ins, exclusive offers
$2,000 - $4,999    | Valued   | Birthday discounts, early sale access
< $2,000           | Standard | Standard service
```

**Example Interpretation:**
```
customer_ID | customer_name | lifetime_value | invoice_count
5           | John Smith    | 12,450.00      | 35
12          | Alice Wong    | 8,920.00       | 22
18          | Bob Johnson   | 7,100.00       | 18
```

**Actions:**
- John Smith ($12K, 35 orders): Assign account manager, invite to advisory board
- Alice Wong ($9K, 22 orders): Send personalized thank you, offer 10% VIP discount
- Bob Johnson ($7K, 18 orders): Monitor for satisfaction, prevent churn

**Revenue Concentration Risk:**
If top 20 customers represent >50% of revenue, business is vulnerable. Diversification needed.

---

## Query 5: Product Popularity by Order Frequency
**Score: 4/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM products p**
   - Start with products table

2. **JOIN order_products op ON p.product_ID = op.product_ID**
   - INNER JOIN: Only products that have been ordered
   - Never-ordered products don't appear

3. **LEFT JOIN departments d ON p.department_ID = d.department_ID**
   - LEFT JOIN: Include products even if department missing
   - Gets department name for context

4. **COUNT(op.order_ID) AS orders_containing_product**
   - Counts total order lines for each product
   - **Note**: Counts order_products rows, not distinct orders
   - If product appears 3 times in 1 order, counts as 3
   - For distinct orders, use COUNT(DISTINCT op.order_ID)

5. **GROUP BY p.product_ID, p.product_name, d.department**
   - One row per product
   - Includes all non-aggregated columns

6. **ORDER BY orders_containing_product DESC LIMIT 30**
   - Top 30 most frequently ordered products
   - Best-sellers identification

### Business Value:

**Why This Query Matters:**
- **Inventory Prioritization**: Best-sellers should never stock out
- **Shelf Space Allocation**: Popular products deserve prominent placement
- **Supplier Negotiations**: High volume = leverage for better pricing
- **Marketing Focus**: Promote what already sells vs. pushing slow movers

**Who Uses This:**
- **Inventory Managers**: Ensure top products always in stock
- **Merchandising**: Allocate shelf space by popularity
- **Marketing**: Feature best-sellers in campaigns
- **Buyers**: Negotiate volume discounts with suppliers

**Business Decisions Enabled:**
1. Increase safety stock for top 30 products by 50%
2. Place top 10 products at eye level and end caps
3. Negotiate 5-10% better pricing for products with 500+ orders
4. Create "Customer Favorites" section featuring top 20

**The 80/20 Rule Application:**
- Typically, 20% of products generate 80% of orders
- Focus 80% of effort on managing this 20%

**Example Interpretation:**
```
product_ID | product_name      | department | orders_containing_product
101        | Organic Bananas   | produce    | 1,250
205        | Whole Milk        | dairy      | 980
310        | White Bread       | bakery     | 875
```

**Actions:**
- Organic Bananas (1,250 orders):
  - Never allow stockout (would disappoint 1,250 customers)
  - Place in multiple locations for convenience
  - Feature in "Most Popular" marketing
  - Negotiate better pricing due to volume

- Whole Milk (980 orders):
  - Ensure cold chain never breaks
  - Premium shelf space near entrance
  - Bundle with coffee/cereal for upsell

**Performance Indicators:**
- **Star Products** (500+ orders): Protect, promote, never discontinue
- **Growth Products** (100-499 orders): Invest in marketing
- **Niche Products** (50-99 orders): Maintain for variety
- **Candidates for Discontinuation** (<50 orders): Evaluate if worth carrying

---

## Query 6: Late Delivery Performance Tracking
**Score: 4.5/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM delivery d WHERE d.status = 'Delivered'**
   - Only completed deliveries (not pending/cancelled)
   - Ensures fair comparison (actual vs. scheduled)

2. **DATE_FORMAT(d.scheduled_date, '%Y-%m') AS delivery_month**
   - Groups deliveries by month
   - Format: '2025-11' for November 2025
   - Enables month-over-month trend analysis

3. **COUNT(*) AS total_deliveries**
   - Total deliveries per month
   - Baseline for percentage calculations

4. **SUM(CASE WHEN d.actual_delivery_date IS NOT NULL AND d.actual_delivery_date > d.scheduled_date THEN 1 ELSE 0 END)**
   - Counts late deliveries:
     - actual_delivery_date IS NOT NULL: Delivery actually occurred
     - actual_delivery_date > scheduled_date: Delivered after promised date
   - CASE returns 1 for late, 0 for on-time/early
   - SUM counts total lates

5. **ROUND(100 * late_count / total_count, 2) AS late_delivery_percentage**
   - Converts to percentage
   - 2 decimal places for precision

6. **GROUP BY delivery_month**
   - One row per month
   - Enables trend visualization

7. **ORDER BY delivery_month DESC**
   - Most recent month first
   - Shows current performance immediately

### Business Value:

**Why This Query Matters:**
- **Customer Satisfaction Driver**: Late delivery is #1 complaint in e-commerce
- **SLA Compliance**: Track against service level agreements
- **Logistics Partner Evaluation**: Compare carriers/partners
- **Seasonal Capacity Planning**: Identify months needing more capacity

**Who Uses This:**
- **Operations Manager**: Monitor delivery performance
- **Logistics Team**: Identify bottlenecks and failures
- **Customer Service**: Anticipate complaint volume
- **Executive Team**: Track key operational KPI

**Business Decisions Enabled:**
1. Penalize logistics partners with >10% late rate
2. Add capacity during months with >15% late rate
3. Adjust delivery promises during peak seasons
4. Invest in distribution centers if chronic delays in region

**Target Metrics:**
- **World-Class**: <5% late delivery rate
- **Good**: 5-10% late rate
- **Needs Improvement**: 10-20% late rate
- **Critical**: >20% late rate (immediate action required)

**Example Interpretation:**
```
delivery_month | total_deliveries | late_delivery_count | late_delivery_percentage
2025-11        | 1,500            | 225                 | 15.00
2025-10        | 1,200            | 84                  | 7.00
2025-09        | 1,100            | 44                  | 4.00
```

**Analysis:**
- **November (15% late)**: Problem month
  - Possible causes: Holiday surge, weather, capacity constraints
  - **Actions**: 
    - Add temporary delivery capacity
    - Extend delivery windows during peak
    - Investigate specific failure points

- **October (7% late)**: Acceptable but monitor
  - **Actions**: Review logistics partner performance

- **September (4% late)**: Excellent performance
  - **Actions**: Understand what went right, replicate

**Correlation Analysis:**
Compare late delivery % with:
- Customer complaint volume (should correlate)
- Return rates (late deliveries may increase returns)
- Repeat purchase rates (late delivery hurts retention)

---

## Query 7: Inventory Turnover Analysis
**Score: 5/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM products p**
   - Start with all products (even never-ordered ones)

2. **LEFT JOIN order_products op ON p.product_ID = op.product_ID**
   - Keep products with zero orders
   - Count orders for products that have been ordered

3. **LEFT JOIN inventory_record ir ON p.product_ID = ir.product_ID**
   - Keep products even if no inventory record
   - Get inventory levels

4. **COUNT(DISTINCT op.order_ID) AS orders_with_product**
   - Proxy for "demand" (number of orders containing product)
   - DISTINCT because product might appear multiple times per order

5. **AVG(ir.quantity_on_hand) AS avg_quantity_on_hand**
   - Average inventory across inventory records
   - If multiple warehouse records exist, averages them
   - IFNULL(..., 0): Show 0 if no inventory records

6. **turnover_proxy Calculation:**
   ```sql
   CASE WHEN AVG(ir.quantity_on_hand) > 0 
        THEN ROUND(COUNT(DISTINCT op.order_ID) / AVG(ir.quantity_on_hand), 4)
        ELSE NULL END
   ```
   - Formula: orders_count / avg_inventory
   - Only calculate if inventory > 0 (avoid divide by zero)
   - Higher value = faster turnover = more efficient
   - **Note**: Not true inventory turnover (would need units sold / avg inventory)

7. **ORDER BY turnover_proxy DESC LIMIT 50**
   - Top 50 fastest-moving products
   - Products with high demand relative to stock

### Business Value:

**Why This Query Matters:**
- **Working Capital Optimization**: Tied-up cash in slow-moving inventory
- **Stockout Risk**: Fast movers need higher safety stock
- **Profitability**: Inventory holding costs reduce profit margins
- **Space Utilization**: Slow movers waste warehouse space

**Who Uses This:**
- **Inventory Managers**: Optimize stock levels
- **CFO**: Reduce working capital tied in inventory
- **Buyers**: Adjust order quantities
- **Warehouse Managers**: Allocate space efficiently

**Business Decisions Enabled:**
1. **High Turnover (>1.0)**: 
   - Increase safety stock by 30%
   - Order more frequently
   - Allocate premium shelf space
   
2. **Medium Turnover (0.1-1.0)**:
   - Maintain current strategy
   - Monitor for changes

3. **Low Turnover (<0.1)**:
   - Reduce order quantities
   - Consider clearance promotions
   - May discontinue if chronic

**Example Interpretation:**
```
product_ID | product_name     | orders_with | avg_quantity | turnover_proxy
101        | Fresh Milk       | 450         | 200          | 2.2500
205        | Rare Spice       | 5           | 500          | 0.0100
310        | Seasonal Item    | 0           | 100          | NULL
```

**Analysis:**
- **Fresh Milk (2.25 turnover)**:
  - Very fast mover (450 orders, only 200 units on hand average)
  - **Risk**: Stockout likely
  - **Actions**: 
    - Increase par level to 300 units
    - Order more frequently (daily vs. weekly)
    - Ensure supplier can handle increased volume

- **Rare Spice (0.01 turnover)**:
  - Very slow mover (5 orders but 500 units in stock)
  - **Problem**: 500 ÷ 5 = 100 months of supply!
  - **Actions**:
    - Reduce stock to 20 units (4 months supply)
    - Clearance sale to liquidate excess
    - Order in smaller quantities going forward

- **Seasonal Item (NULL turnover)**:
  - No orders, 100 units in stock
  - **Problem**: Dead stock
  - **Actions**:
    - Liquidate inventory
    - Remove from catalog
    - Learn from failure

**Financial Impact:**
```
If inventory holding cost = 20% per year:
- Rare Spice: 500 units × $10/unit × 20% = $1,000/year in holding costs
- Reducing to 20 units saves: 480 × $10 × 20% = $960/year
```

---

## Query 8: Products Never Ordered (Dead SKUs)
**Score: 3-4/5 (Basic to Advanced)**

### SQL Code:
```sql
SELECT 
    p.product_ID,
    p.product_name,
    d.department
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID
WHERE op.order_ID IS NULL
ORDER BY p.product_ID;
```

### Technical Breakdown:

1. **FROM products p**
   - Start with all products in catalog

2. **LEFT JOIN order_products op ON p.product_ID = op.product_ID**
   - Try to find orders containing each product
   - If product never ordered: op.order_ID = NULL

3. **LEFT JOIN departments d ON p.department_ID = d.department_ID**
   - Get department name for context
   - Helps identify problematic categories

4. **WHERE op.order_ID IS NULL**
   - Filter: Keep only products never ordered
   - Dead SKUs / zombie inventory

5. **ORDER BY p.product_ID**
   - Sorted by product ID for systematic review

### Business Value:

**Why This Query Matters:**
- **Capital Waste**: Inventory dollars tied up in products that don't sell
- **Catalog Bloat**: Too many SKUs confuse customers and increase operational complexity
- **Opportunity Cost**: Shelf space could hold better-selling products
- **Data Quality**: May indicate product data issues (wrong categorization, poor descriptions)

**Who Uses This:**
- **Product Managers**: Decide which SKUs to discontinue
- **Buyers**: Avoid reordering dead inventory
- **Merchandising**: Free up shelf space for winners
- **Finance**: Write off obsolete inventory

**Business Decisions Enabled:**
1. **Immediate Actions** (products never ordered in 90+ days):
   - Clearance sale at 50% off
   - Return to supplier if possible
   - Donate for tax write-off
   
2. **Root Cause Analysis**:
   - Poor product descriptions? → Improve content
   - Wrong categorization? → Recategorize
   - Uncompetitive pricing? → Price correction
   - Low quality? → Discontinue

3. **SKU Rationalization**:
   - Target: 80% of products generate 95% of orders
   - Eliminate bottom 20% of SKUs if chronically dead

**Example Interpretation:**
```
product_ID | product_name              | department
450        | Artisanal Truffle Oil    | specialty
451        | Organic Yak Milk         | dairy
452        | Vintage Wine 1982        | beverages
```

**Investigation Process:**

**Product 450 - Artisanal Truffle Oil:**
1. Check inventory: 50 bottles × $25 = $1,250 tied up
2. Check listing: Poor product description, no images
3. Check pricing: $25 vs. competitor at $18
4. **Decision**: 
   - Improve listing with photos and recipes
   - Price-match at $18
   - Give 60 days to sell
   - If still no orders → clearance

**Product 451 - Organic Yak Milk:**
1. Check inventory: 100 units × $8 = $800 tied up
2. Analysis: Extremely niche product
3. **Decision**:
   - Immediate clearance: 50% off ($4)
   - Don't reorder
   - Remove from catalog after sellout
   - Learn: "organic" doesn't overcome "yak"

**Product 452 - Vintage Wine 1982:**
1. Check inventory: 12 bottles × $200 = $2,400 tied up
2. Analysis: Specialty item, small target market
3. **Decision**:
   - List on specialty wine marketplaces
   - Keep in catalog (high-margin if sold)
   - Accept low turnover for niche customers
   - Monitor 6 months

**Performance Targets:**
- **Acceptable**: <5% of SKUs with zero orders
- **Needs Improvement**: 5-15% with zero orders
- **Critical**: >15% with zero orders (catalog bloat)

---

## Query 9: Active Promotion Effectiveness
**Score: 3.5/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

1. **FROM promotion pr**
   - Start with all promotions in system

2. **JOIN products p ON pr.product_ID = p.product_ID**
   - Get product details
   - INNER JOIN: Only promotions with valid products

3. **LEFT JOIN order_products op ON pr.product_ID = op.product_ID**
   - Find orders containing the promoted product
   - LEFT JOIN: Keep promotions even if product never ordered

4. **LEFT JOIN orders o ON op.order_ID = o.order_ID**
   - Get order details (currently unused but available)
   - Could add order date filtering here

5. **WHERE Conditions:**
   - `op.order_ID IS NOT NULL`: Only count actual orders
   - `pr.start_date <= NOW()`: Promotion has started
   - `pr.end_date >= NOW()`: Promotion still active
   - **Result**: Currently running promotions only

6. **COUNT(DISTINCT op.order_ID) AS orders_with_promo_product**
   - Counts unique orders containing the promoted product
   - **Note**: Counts ALL orders with product, not just during promo period
   - For accurate lift, should filter op by date range

7. **GROUP BY promotion + product details**
   - One row per promotion
   - Multiple promotions on same product show separately

8. **ORDER BY orders_with_promo_product DESC**
   - Most popular promoted products first

### Business Value:

**Why This Query Matters:**
- **Promotion ROI**: Measures which promotions drive volume
- **Budget Allocation**: Invest in high-performing promotions
- **Product Positioning**: Identifies products that respond to discounts
- **Competitive Response**: Adjust offers based on effectiveness

**Who Uses This:**
- **Marketing Team**: Evaluate campaign effectiveness
- **Merchandising**: Select products for future promotions
- **Finance**: Calculate promotional P&L
- **Category Managers**: Optimize discount levels

**Business Decisions Enabled:**
1. **High Performance** (100+ orders):
   - Extend promotion duration
   - Increase product visibility
   - Replicate for similar products

2. **Medium Performance** (20-99 orders):
   - Maintain current promotion
   - Test deeper discounts

3. **Low Performance** (<20 orders):
   - End promotion early
   - Investigate: Wrong product? Wrong discount? Wrong timing?

**Example Interpretation:**
```
code    | product_ID | product_name     | start_date | end_date   | orders_with_promo
SAVE20  | 101        | Organic Apples   | 2025-11-01 | 2025-11-30 | 450
BOGO50  | 205        | Frozen Pizza     | 2025-11-01 | 2025-11-30 | 15
```

**Analysis:**

**SAVE20 on Organic Apples (450 orders):**
- **Success**: High volume
- **Next Steps**:
  - Calculate: Did 20% discount drive incremental volume?
  - Compare: 450 orders during promo vs. 300 orders normally = 50% lift
  - ROI: If 150 incremental orders × $5 profit (after discount) = $750 gain
  - **Decision**: Profitable promotion, repeat quarterly

**BOGO50 on Frozen Pizza (15 orders):**
- **Failure**: Low volume despite aggressive 50% discount
- **Investigation**:
  - Product quality issues? (check reviews)
  - Poor visibility? (check product page traffic)
  - Category mismatch? (frozen pizza buyers price-sensitive?)
- **Decision**: 
  - End promotion early
  - Don't promote this product again
  - Consider discontinuing product

**Critical Query Limitation:**
This query counts ALL orders with product, not just during promotion window. For accurate promotion lift:

```sql
-- IMPROVED VERSION:
SELECT 
    pr.code,
    COUNT(DISTINCT CASE WHEN o.order_date BETWEEN pr.start_date AND pr.end_date 
                        THEN op.order_ID END) AS orders_during_promo,
    COUNT(DISTINCT CASE WHEN o.order_date < pr.start_date 
                        AND o.order_date >= DATE_SUB(pr.start_date, INTERVAL 30 DAY)
                        THEN op.order_ID END) AS orders_before_promo,
    ROUND(100 * (orders_during - orders_before) / NULLIF(orders_before, 0), 2) AS lift_percentage
FROM promotion pr
JOIN products p ON pr.product_ID = p.product_ID
LEFT JOIN order_products op ON pr.product_ID = op.product_ID
LEFT JOIN orders o ON op.order_ID = o.order_ID
GROUP BY pr.code;
```

---

## Query 10: Loyalty Program Impact Analysis
**Score: 5/5 (Advanced)**

### SQL Code:
```sql
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
```

### Technical Breakdown:

**Part 1: Active Members by Tier**

1. **FROM loyalty_membership lm**
   - Start with loyalty program members

2. **JOIN customer → orders → invoice**
   - Chain joins to get invoice data
   - INNER JOINs: Only members with purchases

3. **WHERE lm.status = 'Active'**
   - Exclude expired memberships
   - Shows current program performance

4. **AVG(i.total_amount) AS avg_invoice_amount**
   - Average invoice value per tier
   - Key metric: Do higher tiers spend more?

5. **COUNT(DISTINCT i.invoice_ID) AS invoice_count**
   - Total invoices per tier
   - Shows program size

6. **GROUP BY lm.tier_level**
   - One row per tier (Bronze, Silver, Gold)

**Part 2: Non-Members (UNION ALL)**

7. **UNION ALL**
   - Combines member and non-member results
   - Creates comparison baseline

8. **LEFT JOIN loyalty_membership lm2**
   - Finds customers WITHOUT memberships

9. **WHERE lm2.membership_ID IS NULL**
   - Filters to non-members only

10. **'Non-member' AS tier**
    - Labels this segment

**Part 3: Final Sorting**

11. **ORDER BY avg_invoice_amount DESC**
    - Sorts all tiers by spending (highest first)
    - Shows tier value hierarchy

### Business Value:

**Why This Query Matters:**
- **Program ROI Validation**: Does loyalty program increase spending?
- **Tier Effectiveness**: Do benefits justify tier structure?
- **Investment Justification**: Loyalty programs cost money—do they pay back?
- **Upgrade Incentive Design**: Size prize gaps to motivate tier progression

**Who Uses This:**
- **Marketing Leadership**: Evaluate program ROI
- **Finance**: Calculate program profitability
- **Customer Success**: Design tier benefits
- **Executive Team**: Strategic program decisions

**Business Decisions Enabled:**

**Scenario A: Healthy Program**
```
tier        | avg_invoice_amount | invoice_count
Gold        | 450.00             | 1,250
Silver      | 280.00             | 3,500
Bronze      | 180.00             | 5,000
Non-member  | 120.00             | 2,000
```

**Analysis:**
- **Gold spending**: 3.75× non-members (450 ÷ 120)
- **Silver spending**: 2.33× non-members (280 ÷ 120)
- **Bronze spending**: 1.50× non-members (180 ÷ 120)

**Interpretation:**
✅ Program is working! Clear spending progression.

**Actions:**
1. Invest more in Gold benefits (they're worth it)
2. Create upgrade path: Bronze → Silver for customers spending $200+
3. Recruit non-members aggressively (2,000 untapped customers)
4. Calculate ROI:
   - If Gold benefits cost $50/member/year
   - But Gold members spend $330 more than non-members
   - ROI = ($330 - $50) ÷ $50 = 560% return

**Scenario B: Broken Program**
```
tier        | avg_invoice_amount | invoice_count
Gold        | 200.00             | 500
Silver      | 195.00             | 1,200
Bronze      | 190.00             | 2,000
Non-member  | 250.00             | 8,000
```

**Analysis:**
- Non-members spend MORE than members
- No differentiation between tiers
- Program is failing

**Interpretation:**
❌ Program destroying value! 

**Root Causes:**
- Benefits too generous (attracting price-sensitive customers)
- Tier thresholds too low (everyone qualifies)
- Non-members are actually better customers

**Actions:**
1. **Immediate**: Audit program costs vs. revenue
2. **Short-term**: Increase tier thresholds (make Gold exclusive)
3. **Medium-term**: Redesign benefits (focus on non-monetary perks)
4. **Consider**: Shutting down program if unfixable

**Target Metrics:**
- **Gold**: 2-3× non-member spending
- **Silver**: 1.5-2× non-member spending
- **Bronze**: 1.2-1.5× non-member spending
- **Tier Distribution**: 5% Gold, 15% Silver, 30% Bronze, 50% Non-member

**Program Health Indicators:**

✅ **Healthy**:
- Clear spending progression by tier
- Members spend >1.5× non-members
- Positive net revenue after program costs

⚠️ **Needs Improvement**:
- Weak tier differentiation
- Members spend 1.0-1.5× non-members
- Breakeven or slight positive ROI

❌ **Broken**:
- No tier differentiation
- Members spend ≤ non-members
- Negative net revenue

---

## Summary: Why These Queries Matter for Business

These 10 queries represent a comprehensive business intelligence toolkit covering:

1. **Customer Value (Queries 1, 4, 10)**: Identify, segment, and retain valuable customers
2. **Product Performance (Queries 2, 5, 8)**: Optimize product mix and inventory
3. **Operational Excellence (Queries 6, 7)**: Improve delivery and inventory efficiency
4. **Financial Health (Queries 3, 9)**: Manage cash flow and marketing ROI

**Combined Impact:**
Running all 10 queries monthly provides a 360° view of business health, enabling:
- **Proactive Management**: Spot problems before they become crises
- **Data-Driven Decisions**: Replace gut feel with facts
- **Resource Optimization**: Focus time/money on high-ROI activities
- **Competitive Advantage**: Faster, smarter decisions than competitors

**Recommended Dashboard Structure:**
- **Daily**: Queries 3, 6 (cash flow and delivery issues)
- **Weekly**: Queries 1, 5, 7 (customer value, best-sellers, inventory)
- **Monthly**: All queries for comprehensive review
- **Quarterly**: Deep-dive strategic analysis with year-over-year trends

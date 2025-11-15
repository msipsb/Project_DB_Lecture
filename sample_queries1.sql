-- 1
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

-- 2
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

-- 3
SELECT DISTINCT -- 2.5 1.5 3 2 ? ? = 2.25
    o.customer_ID,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    o.order_ID
FROM orders o
JOIN customer c ON o.customer_ID = c.customer_ID
LEFT JOIN invoice i ON o.order_ID = i.order_ID AND i.status = 'Paid' -- AND i.status != 'Cancelled'
WHERE i.invoice_ID IS NULL
ORDER BY o.customer_ID;

-- 4
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

-- 5
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

-- 6
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

-- 6
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

-- 7
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

-- 8
SELECT -- 4.5 4 4 4 4 4 = 4
    p.product_ID,
    p.product_name,
    d.department
FROM products p
LEFT JOIN order_products op ON p.product_ID = op.product_ID
LEFT JOIN departments d ON p.department_ID = d.department_ID -- delete to be basic
WHERE op.order_ID IS NULL
ORDER BY p.product_ID;

-- 9
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

-- 10
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
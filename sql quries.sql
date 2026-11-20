SELECT *
FROM customer_shopping_behavior
LIMIT 20;

SELECT
    gender,
    SUM("purchase_amount_(usd)") AS total_revenue
FROM customer_shopping_behavior
GROUP BY gender
ORDER BY total_revenue DESC;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';
SELECT*
FROM customer_shopping_behavior
WHERE LOWER("discount_applied") = 'yes'
AND "purchase_amount_(usd)" > (
    SELECT AVG("purchase_amount_(usd)")
    FROM customer_shopping_behavior
)
ORDER BY "purchase_amount_(usd)" DESC;

SELECT
    "item_purchased",
    ROUND(AVG("review_rating")::NUMERIC, 2) AS average_rating
FROM customer_shopping_behavior
GROUP BY "item_purchased"
ORDER BY average_rating DESC
LIMIT 5;

SELECT
    "shipping_type",
    ROUND(AVG("purchase_amount_(usd)")::NUMERIC, 2) AS average_purchase
FROM customer_shopping_behavior
WHERE "shipping_type" IN ('Standard', 'Express')
GROUP BY "shipping_type";

SELECT
    "subscription_status",
    ROUND(AVG("purchase_amount_(usd)")::NUMERIC, 2) AS average_spend,
    SUM("purchase_amount_(usd)") AS total_revenue,
    COUNT(*) AS total_customers
FROM customer_shopping_behavior
GROUP BY "subscription_status";

SELECT
    "item_purchased",
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE LOWER("discount_applied") = 'yes'
        ) / COUNT(*), 2
    ) AS discount_percentage
FROM customer_shopping_behavior
GROUP BY "item_purchased"
ORDER BY discount_percentage DESC
LIMIT 5;

SELECT
    CASE
        WHEN "previous_purchases" <= 1 THEN 'New'
        WHEN "previous_purchases" BETWEEN 2 AND 10
            THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_shopping_behavior
GROUP BY customer_segment
ORDER BY customer_count DESC;

WITH product_counts AS (
    SELECT
        "category",
        "item_purchased",
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY "category"
            ORDER BY COUNT(*) DESC, "item_purchased" ASC
        ) AS product_rank
    FROM customer_shopping_behavior
    GROUP BY "category", "item_purchased"
)
SELECT
    "category",
    "item_purchased",
    purchase_count
FROM product_counts
WHERE product_rank <= 3
ORDER BY "category", product_rank;


WITH product_counts AS (
    SELECT
        "category",
        "item_purchased",
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY "category"
            ORDER BY COUNT(*) DESC, "item_purchased" ASC
        ) AS product_rank
    FROM customer_shopping_behavior
    GROUP BY "category", "item_purchased"
)
SELECT *
FROM (
    SELECT
        "category",
        "item_purchased",
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (
            PARTITION BY "category"
            ORDER BY COUNT(*) DESC, "item_purchased"
        ) AS product_rank
    FROM customer_shopping_behavior
    GROUP BY "category", "item_purchased"
) AS ranked_products
WHERE product_rank <= 3
ORDER BY "category", product_rank;
-- ===============================================
-- Общая аналитика
-- ===============================================

-- Запрос для подсчёта общей выручки за год
SELECT 
    SUM(quantity * price_at_purchase) AS Выручка_за_год 
FROM 
    order_items;

-- Запрос для подсчёта количества продаж за год
SELECT 
    SUM(quantity) AS Количество_продаж 
FROM 
    order_items;

-- Запрос для вычисления среднего чека
SELECT 
    ROUND(SUM(price_at_purchase * quantity) / COUNT(order_id), 2) AS Средний_чек 
FROM 
    order_items;

-- Запрос на вычисление коэффициента возврата клиентов
SELECT 
    COUNT(DISTINCT customer_id) FILTER (WHERE order_count > 1) * 1.0 / COUNT(DISTINCT customer_id) AS Коэф_возврата
FROM (
    SELECT 
        customer_id, 
        COUNT(order_id) AS order_count
    FROM 
        orders
    GROUP BY 
        customer_id
) AS customer_orders;

-- ===============================================
-- Анализ продукции
-- ===============================================

-- Запрос для выведения списка продуктов отсортированных по рейтингу от самого высокого к самому низкому
SELECT 
    p.product_id, 
    p.product_name, 
    s.supplier_name, 
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM 
    suppliers s
JOIN 
    products p USING (supplier_id)
JOIN 
    reviews r USING (product_id)
GROUP BY 
    p.product_id, 
    p.product_name, 
    s.supplier_name
ORDER BY 
    avg_rating DESC;

-- Запрос для выведения продуктов с самым высоким рейтингом в каждой категории
WITH AvgRatings AS (
    SELECT 
        p.category, 
        p.product_id, 
        p.product_name, 
        s.supplier_name,
        ROUND(AVG(r.rating)) AS avg_rating
    FROM 
        products p
    JOIN 
        reviews r ON p.product_id = r.product_id
    JOIN 
        suppliers s USING (supplier_id)
    GROUP BY 
        p.category, 
        p.product_id, 
        p.product_name, 
        s.supplier_name
),
RankedProducts AS (
    SELECT 
        *, 
        RANK() OVER (PARTITION BY category ORDER BY avg_rating DESC) AS rank
    FROM 
        AvgRatings
)
SELECT 
    category, 
    product_id, 
    product_name, 
    supplier_name, 
    avg_rating
FROM 
    RankedProducts
WHERE 
    rank = 1;

-- Запрос для выведения самых прибыльных продуктов, компаний, которые их произвели, и выручка за год
SELECT 
    p.product_name, 
    s.supplier_name, 
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
FROM 
    order_items oi
RIGHT JOIN 
    products p USING (product_id)
JOIN 
    suppliers s USING (supplier_id)
GROUP BY 
    p.product_name, 
    s.supplier_name
HAVING 
    SUM(oi.quantity * oi.price_at_purchase) IS NOT NULL
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- ===============================================
-- Анализ производителей
-- ===============================================

-- Запрос для выявления топ лучших 5 продавцов по величине прибыли за год
SELECT 
    s.supplier_name, 
    SUM(oi.price_at_purchase * oi.quantity) AS profit
FROM 
    suppliers s
JOIN 
    products p USING (supplier_id)
JOIN 
    order_items oi USING (product_id)
GROUP BY 
    s.supplier_name
ORDER BY 
    profit DESC
LIMIT 5;

-- Запрос для вычисления выручки одной компании по датам
SELECT 
    o.order_date AS date, 
    SUM(oi.price_at_purchase * oi.quantity) AS profit
FROM 
    suppliers s
JOIN 
    products p USING (supplier_id)
JOIN 
    order_items oi USING (product_id)
JOIN 
    orders o USING (order_id)
WHERE 
    s.supplier_name = 'Smart Solutions Ltd.'
GROUP BY 
    o.order_date
ORDER BY 
    o.order_date;

-- Запрос для вычисления среднего рейтинга продавцов (от самого высокого к самому низкому)
SELECT 
    s.supplier_name, 
    ROUND(AVG(r.rating), 1) AS avg_rating
FROM 
    suppliers s
JOIN 
    products p USING (supplier_id)
JOIN 
    reviews r USING (product_id)
GROUP BY 
    s.supplier_name
ORDER BY 
    avg_rating DESC;

-- ===============================================
-- Анализ категорий
-- ===============================================

-- Запрос для подсчёта выручки в одной категории по датам
SELECT 
    o.order_date, 
    SUM(oi.quantity * oi.price_at_purchase) AS revenue
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON p.product_id = oi.product_id
WHERE 
    p.category = 'Electronics'
GROUP BY 
    o.order_date
ORDER BY 
    o.order_date;

-- Запрос для подсчёта продуктов в каждой категории
SELECT 
    p.category, 
    COUNT(p.product_id) AS num_products
FROM 
    products p
GROUP BY 
    p.category;

-- Запрос для подсчёта выручки в каждой категории
SELECT 
    p.category, 
    SUM(oi.price_at_purchase * oi.quantity) AS total_revenue
FROM 
    products p
JOIN 
    order_items oi USING (product_id)
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC;

-- Запрос для подсчёта количества продавцов в каждой категории
SELECT 
    p.category, 
    COUNT(DISTINCT s.supplier_id) AS num_suppliers
FROM 
    suppliers s
JOIN 
    products p USING (supplier_id)
GROUP BY 
    p.category
ORDER BY 
    num_suppliers DESC;

-- ===============================================
-- Анализ сервисов доставки
-- ===============================================

-- Запрос для вычисления среднего времени доставки для каждого сервиса
SELECT 
    s.carrier, 
    ROUND(AVG(s.delivery_date - s.shipment_date), 2) AS avg_delivery_time
FROM 
    shipments s
GROUP BY 
    s.carrier
ORDER BY 
    avg_delivery_time ASC;

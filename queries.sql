-- ===============================================
-- Анализ продукции
-- ===============================================

-- Запрос для выведения списка продуктов отсортированных по рейтингу от самого высокого к самому низкому
SELECT 
    products.product_id, 
    products.product_name, 
    suppliers.supplier_name, 
    ROUND(AVG(reviews.rating), 2) AS avg_rating
FROM 
    suppliers
JOIN 
    products USING(supplier_id)
JOIN 
    reviews USING(product_id)
GROUP BY 
    products.product_id, products.product_name, suppliers.supplier_name
ORDER BY 
    avg_rating DESC;

-- Запрос для выведения продуктов с самым высоким рейтингом в каждой категории
WITH AvgRatings AS (
    SELECT 
        products.category, 
        products.product_id, 
        products.product_name,
        ROUND(AVG(reviews.rating)) AS avg_rating
    FROM 
        products
    JOIN 
        reviews ON products.product_id = reviews.product_id
    GROUP BY 
        products.category, products.product_id, products.product_name
),
RankedProducts AS (
    SELECT 
        *, 
        RANK() OVER (PARTITION BY category ORDER BY avg_rating DESC) AS rank
    FROM 
        AvgRatings
)
SELECT 
    category, product_id, product_name, avg_rating
FROM 
    RankedProducts
WHERE 
    rank = 1;

-- Запрос для выведения 10 самых продаваемых продуктов и количества проданных продуктов за год
SELECT 
    products.product_id, 
    products.product_name, 
    SUM(quantity) AS total_sold
FROM 
    order_items
RIGHT JOIN 
    products USING(product_id)
GROUP BY 
    products.product_id, products.product_name
HAVING 
    SUM(quantity) IS NOT NULL
ORDER BY 
    total_sold DESC
LIMIT 10;

-- Запрос для выведения самых прибыльных продуктов, компаний, которые их произвели, и выручка за год
SELECT 
    products.product_name, 
    suppliers.supplier_name, 
    SUM(quantity * price_at_purchase) AS total_revenue
FROM 
    order_items
RIGHT JOIN 
    products USING(product_id)
JOIN 
    suppliers USING(supplier_id)
GROUP BY 
    products.product_name, suppliers.supplier_name
HAVING 
    total_revenue IS NOT NULL
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- Запрос для выведения самых продаваемых типов продуктов и количества проданных продуктов за год
SELECT 
    products.product_name, 
    SUM(quantity) AS total_sold
FROM 
    order_items
RIGHT JOIN 
    products USING(product_id)
GROUP BY 
    products.product_name
HAVING 
    SUM(quantity) IS NOT NULL
ORDER BY 
    total_sold DESC
LIMIT 10;

-- ===============================================
-- Анализ производителей
-- ===============================================

-- Запрос для выявления топ лучших 5 продавцов по величине прибыли за год
SELECT 
    supplier_name, 
    SUM(order_items.price_at_purchase * order_items.quantity) AS profit
FROM 
    suppliers
JOIN 
    products USING(supplier_id)
JOIN 
    order_items USING(product_id)
GROUP BY 
    supplier_name
ORDER BY 
    profit DESC
LIMIT 5;

-- Запрос для вычисления выручки одной компании по датам
SELECT 
    orders.order_date AS date,  
    SUM(order_items.price_at_purchase * order_items.quantity) AS profit
FROM  
    suppliers
JOIN  
    products USING(supplier_id)
JOIN  
    order_items USING(product_id)
JOIN  
    orders USING(order_id)
WHERE  
    suppliers.supplier_name = 'Smart Solutions Ltd.'
GROUP BY  
    orders.order_date
ORDER BY  
    orders.order_date;

-- Запрос для вычисления среднего рейтинга продавцов (от самого высокого к самому низкому)
SELECT  
    supplier_name,  
    ROUND(AVG(reviews.rating), 2) AS avg_rating
FROM  
    suppliers  
JOIN  
    products USING(supplier_id)  
JOIN  
    reviews USING(product_id)
GROUP BY  
    supplier_name  
ORDER BY  
    avg_rating DESC;

-- ===============================================
-- Анализ категорий
-- ===============================================

-- Запрос для подсчёта выручки в одной категории по датам
SELECT  
   order_date,  
   SUM(order_items.quantity * order_items.price_at_purchase) AS total_revenue
FROM  
   orders  
JOIN  
   order_items ON order_items.order_id = orders.order_id  
JOIN  
   products ON products.product_id = order_items.product_id  
WHERE  
   products.category = 'Electronics'  
GROUP BY  
   order_date  
ORDER BY  
   order_date;

-- Запрос для подсчёта продуктов в каждой категории
SELECT  
   category, COUNT(product_id) AS product_count
FROM  
   products  
GROUP BY  
   category;

-- Запрос для подсчёта выручки в каждой категории
SELECT  
   category, SUM(order_items.price_at_purchase * order_items.quantity) AS total_revenue
FROM   
   products   
JOIN   
   order_items USING(product_id)   
GROUP BY   
   category   
ORDER BY   
   total_revenue DESC;

-- Запрос для подсчёта количества продавцов в каждой категории
SELECT   
   category, COUNT(DISTINCT supplier_id) AS supplier_count   
FROM   
   suppliers   
JOIN   
   products USING(supplier_id)   
GROUP BY   
   category   
ORDER BY   
   supplier_count DESC;

-- ===============================================
-- Анализ сервисов доставки
-- ===============================================

-- Запрос для вычисления среднего времени доставки для каждого сервиса
SELECT   
   carrier, 
   ROUND(AVG(delivery_date - shipment_date), 2) AS avg_delivery_time    
FROM    
   shipments    
GROUP BY    
   carrier    
ORDER BY    
   avg_delivery_time ASC;




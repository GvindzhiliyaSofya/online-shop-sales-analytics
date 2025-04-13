select order_date, sum(order_items.quantity) as kolichestvo from orders
join order_items on order_items.order_id = orders.order_id
join products on products.product_id = order_items.product_id
where products.category = 'Accessories'
group by order_date
order by order_date;

select category, count(product_id) from products
group by category;

select category, sum(order_items.price_at_purchase*order_items.quantity) from products
join order_items using(product_id)
group by category
order by sum(order_items.price_at_purchase*order_items.quantity) desc;

select category, count(distinct supplier_id) as suppliers from suppliers
join products using(supplier_id)
group by category
order by count(supplier_id) desc;

select supplier_name, sum(order_items.price_at_purchase*order_items.quantity) as profit from suppliers
join products using(supplier_id)
join order_items using(product_id)
group by supplier_name
order by sum(order_items.price_at_purchase*order_items.quantity) desc
limit 5;

select orders.order_date as date, sum(order_items.price_at_purchase*order_items.quantity) as profit from suppliers
join products using(supplier_id)
join order_items using(product_id)
join orders using(order_id)
where suppliers.supplier_name = 'Smart Solutions Ltd.'
group by orders.order_date
order by orders.order_date;

select supplier_name, round(avg(reviews.rating), 2) from suppliers
join products using(supplier_id)
join reviews using(product_id)
group by supplier_name
order by avg(reviews.rating) desc;

select products.product_id, products.product_name, suppliers.supplier_name, round(avg(reviews.rating), 2) from suppliers
join products using(supplier_id)
join reviews using(product_id)
group by products.product_id, products.product_name, suppliers.supplier_name
order by avg(reviews.rating) desc;

WITH AvgRatings AS (SELECT products.category, products.product_id, products.product_name,
round(avg(reviews.rating)) as avg_rating FROM products
  JOIN reviews ON products.product_id = reviews.product_id
  GROUP BY products.category, products.product_id, products.product_name),
RankedProducts AS (SELECT *, RANK() OVER (PARTITION BY category 
   ORDER BY avg_rating DESC) AS rank FROM AvgRatings)

SELECT category, product_id, product_name, avg_rating FROM RankedProducts
WHERE rank = 1;

select products.product_id, products.product_name, sum(quantity) from order_items
right join products using(product_id)
group by products.product_id, products.product_name
having sum(quantity) is not null
order by sum(quantity) desc
limit 10;

select products.product_name, suppliers.supplier_name, sum(quantity*price_at_purchase) from order_items
right join products using(product_id)
join suppliers using(supplier_id)
group by products.product_name, suppliers.supplier_name
having sum(quantity*price_at_purchase) is not null
order by sum(quantity*price_at_purchase) desc
limit 10;

select carrier, round(avg(delivery_date - shipment_date), 2) as delivery_time from shipments
group by carrier
order by round(avg(delivery_date - shipment_date)) asc;


select products.product_name, sum(quantity) from order_items
right join products using(product_id)
group by products.product_name
having sum(quantity) is not null
order by sum(quantity) desc
limit 10;


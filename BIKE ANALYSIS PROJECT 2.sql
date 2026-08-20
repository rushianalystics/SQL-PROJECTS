use bikes;

-- 1 Find the total number of products sold by each store along with the store name.

SELECT 
    s.store_id,
    s.store_name,
    SUM(oi.quantity) AS total_product_sold
FROM
    stores s
        JOIN
    orders o ON s.store_id = o.store_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY s.store_id , s.store_name;

-- 2 Calculate the cumulative sum of quantities sold for each product over time.

select oi.product_id , 
	   o.order_date , 
       oi.quantity , 
       sum(oi.quantity) over (partition by oi.product_id
	   order by o.order_date) as cumulative_quantity
from order_items oi
join orders o on o.order_id = oi.order_id
order by oi.product_id , o.order_date ;

-- 3 Find the product with the highest total sales (quantity × price) for each category.

	WITH product_sales AS (
	select 
		p.product_id,
		p.product_name,
		p.category_id,
		sum(oi.quantity*oi.list_price) as total_sales
		from products p
		join order_items oi on p.product_id = oi.product_id
		group by  p.product_id, p.product_name, p.category_id
	),

	ranked as (
	select 	
	   ps.*,
	   c.category_name,
	   rank()over(partition by ps.category_id order by ps.total_sales desc)
	   as rnk
	   from product_sales ps
	   join categories c on c.category_id = ps.category_id
	   )
	   
	select category_name , product_name , total_sales
	from ranked
	where rnk = 1;
    
-- 4 Find the customer who spent the most money	on orders.

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.list_price * oi.discount) AS total_spent
FROM
    customers c
        JOIN
    orders o ON o.customer_id = c.customer_id
        JOIN
    order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id , c.first_name , c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- 5 Find the highest-priced product for each category name.

with ranked as (
select 
p.product_id,
p.product_name,
p.list_price,
c.category_name,
rank()over(partition by p.category_id order by p.list_price desc ) as rnk 
from products p
join categories c on c.category_id = p.category_id
)
select category_name , product_name, list_price
from ranked
where rnk = 1;

-- 6 Find the total	number of orders placed	by each	customer per store

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    s.store_id,
    s.store_name,
    COUNT(o.order_id) AS total_orders
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
        JOIN
    stores s ON s.store_id = o.store_id
GROUP BY c.customer_id , c.first_name , c.last_name , s.store_id , s.store_name;

-- 7 Find the names	of staff members who have not made any sales.

SELECT 
    st.staff_id, st.first_name, st.last_name
FROM
    staffs st
        LEFT JOIN
    orders o ON o.staff_id = st.staff_id
WHERE
    o.order_id IS NULL;

-- 8 Find the top 3	most sold products in terms	of quantity

	SELECT 
    p.product_id, p.product_name, SUM(oi.quantity) AS total_qty
FROM
    products p
        JOIN
    order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id , p.product_name
ORDER BY total_qty DESC
LIMIT 3;

-- 9  Find the median value	of the price list

	with ordered as (
	select 
	list_price,
	row_number()over(partition by list_price) as rnk,
	count(*) over () as total_rows
	from products
	)
	select avg(list_price) as median_price
	from ordered
	where rnk in (floor((total_rows+1) / 2), ceil((total_rows+1) / 2));
    
-- 10  List	all	products that have never been ordered (use	Exists).

SELECT 
    p.product_id, p.product_name
FROM
    products p
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            order_items oi
        WHERE
            oi.product_id = p.product_id);
                  
-- 11 List	the	names of staff members who have	made more sales	than the average number	of sales by	all	staff members.

with staff_sales as (
select
staff_id,
count(order_id) as total_sales 
from orders 
group by staff_id
)
select 
s.staff_id,
s.first_name,
s.last_name,
ss.total_sales
from staff_sales ss
join staffs s on s.staff_id = ss.staff_id
where ss.total_sales > (select avg(total_sales) from staff_sales);

-- 12 Identify the customers who have ordered all types of	products (i.e.,	from every category)

SELECT 
    c.customer_id, c.first_name, c.last_name
FROM
    customers c
WHERE
    NOT EXISTS( SELECT 
            cat.category_id
        FROM
            categories cat
        WHERE
            NOT EXISTS( SELECT 
                    1
                FROM
                    orders o
                        JOIN
                    order_items oi ON oi.order_id = o.order_id
                        JOIN
                    products p ON p.product_id = oi.product_id
                WHERE
                    o.customer_id = c.customer_id
                        AND p.category_id = cat.category_id));
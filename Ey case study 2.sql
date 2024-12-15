Create database ShopEase;
use ShopEase;

--Show the total number of customers who signed up in each month of 2023.
select
format(signup_date, 'yyyy-MM') as SignupMonth,
count(*) as TotalSignups
from shopease_customers
where year(signup_date) = 2023
group by format(signup_date, 'yyyy-MM')
order by SignupMonth;

-- List the top 5 products by total sales amount, including the total quantity sold for each
select top 5
    p.product_name,
    sum(o.quantity * o.price) as TotalSales,
    sum(o.quantity) as TotalQuantity
from shopease_order_items o
join shopease_products p on o.product_id = p.product_id
group by p.product_name
order by TotalSales desc;

-- Find the average order value for each customer who has placed more than 5 orders.
with CustomerOrderCounts as (
    select 
        customer_id,
        count(distinct order_id) as TotalOrders
    from shopease_orders
    group by customer_id
)
select 
    c.customer_id,
    avg(o.total_amount) as AvgOrderValue
from shopease_orders o
join CustomerOrderCounts c on o.customer_id = c.customer_id
where c.TotalOrders > 5
group by c.customer_id;

-- Get the total number of orders placed in each month of 2023, and calculate the average order value for each month.
select
    format(order_date, 'yyyy-MM') as OrderMonth,
    count(distinct order_id) as TotalOrders,
    avg(total_amount) as AvgOrderValue
from shopease_orders
where year (order_date) = 2023
group by format (order_date, 'yyyy-MM')
order by OrderMonth;

--Identify the product categories with the highest average rating, and list the top 3 categories
select top 3  category,avg(rating) as AvgRating
from shopease_reviews r
join shopease_products p on r.product_id = p.product_id
where rating is not null
group by category
order by AvgRating desc;

--Calculate the total revenue generated from each product category, and find the category with the highest revenue
select category,sum (o.quantity * o.price) as TotalRevenue
from shopease_order_items o
join shopease_products p on o.product_id = p.product_id
group by category
order by TotalRevenue desc;

-- List the customers who have placed more than 10 orders, along with the total amount spent by each customer
select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as CustomerName,
    sum(o.total_amount) as TotalSpent
from shopease_orders o
join shopease_customers c on o.customer_id = c.customer_id
group by c.customer_id, c.first_name, c.last_name
having count (distinct o.order_id) > 10;

-- Find the products that have never been reviewed, and list their details
select 
    p.product_id,
    p.product_name,
    p.category
from shopease_products p
left join shopease_reviews r on p.product_id = r.product_id 
where r.review_id IS NULL;

-- Show the details of the most expensive order placed, including the customer information
select top 1
    o.order_id,
	o.order_date,
	c.customer_id,
    concat (c.first_name, ' ', c.last_name) as CustomerName,
	o.total_amount,
    c.email
from shopease_orders o
join shopease_customers c on o.customer_id = c.customer_id
order by o.total_amount desc;

--Get the total quantity of each product sold in the last 30 days, and identify the top 5 products by quantity sold.
select top 5 
    p.product_name,
    sum (oi.quantity) as TotalQuantity
from shopease_order_items oi
join shopease_orders o on oi.order_id= o.order_id
join shopease_products p on oi.product_id = p.product_id
where o.order_date >= dateadd(day, -30, getDate())
group by p.product_name
order by TotalQuantity desc;
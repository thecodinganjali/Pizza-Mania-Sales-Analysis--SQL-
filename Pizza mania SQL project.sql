-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS total_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name AS pizza_name, MAX(pizzas.price) AS price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY price DESC
LIMIT 1;

-- 5. Identify the most common pizza size ordered.

SELECT 
    pizzas.size AS pizza_size,
    COUNT(order_details.order_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- 6. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 7. Join the necessary tables to find the total quantity of each  category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 8. Determine the distribution of orders by hour of the day.
 
SELECT 
    COUNT(orders.order_id) AS order_count,
    HOUR(orders.order_time) AS Hours
FROM
    orders
GROUP BY HOUR(orders.order_time);


-- 9. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category, COUNT(*) as order_count
FROM
    pizza_types
GROUP BY category;

-- 10. Group the orders by date and calculate the average number of pizzas ordered per day. 
 
SELECT 
    ROUND(AVG(quantity), 0) avg_quantity_ordered
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS ordered_quantity;
 
 -- 11. Determine the top 3 most ordered pizza types based on revenue.

 select pizza_types.name , round(sum(order_details.quantity * pizzas.price),0)  as revenue 
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue  desc
limit 3;


-- 12 . Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(pizzas.price * order_details.quantity),
                                2) AS total_sales
                FROM
                    pizzas
                        JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
 
-- 13. Analyze the cumulative revenue generated over time.

select order_date , sum(revenue) over( order by order_date) as cum_revenue 
from 
(select orders.order_date , ROUND(SUM(pizzas.price * order_details.quantity),2) AS revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
join orders
on orders.order_id = order_details.order_id 
group by orders.order_date) as sale;
    
 
-- 14. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
select name , revenue from
(select category , name , revenue ,  rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.name , pizza_types.category , SUM(pizzas.price * order_details.quantity) AS revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category , pizza_types.name) as a) as b
where rn <> 3 ;








-- Dimension table: customer 360 view
-- GRAIN: one row per customer

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(order_id)             as total_orders,
        sum(order_amount_usd)       as lifetime_value_usd,
        min(order_date)             as first_order_date,
        max(order_date)             as most_recent_order_date
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.created_at,
        coalesce(co.total_orders, 0)            as total_orders,
        coalesce(co.lifetime_value_usd, 0)      as lifetime_value_usd,
        co.first_order_date,
        co.most_recent_order_date,
        case
            when co.total_orders is null        then 'never_ordered'
            when co.total_orders = 1            then 'one_time'
            when co.total_orders >= 2           then 'repeat'
        end                                     as customer_segment
    from customers c
    left join customer_orders co on c.customer_id = co.customer_id
)

select * from final

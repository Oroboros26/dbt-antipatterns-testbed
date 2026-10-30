-- Intermediate: enrich orders with customer data
-- GRAIN: one row per order

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

-- LOGIC DRIFT: This calculation duplicates revenue logic already in fct_revenue.
-- Two different definitions of "net revenue" now exist across the project.
order_payments as (
    select
        order_id,
        sum(payment_amount_usd) as total_paid_usd
    from payments
    group by order_id
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.order_amount_usd,
        -- Net revenue calculated here (also calculated differently in fct_revenue)
        o.order_amount_usd - coalesce(p.total_paid_usd, 0) as outstanding_balance_usd,
        c.first_name,
        c.last_name,
        c.email
    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join order_payments p on o.order_id = p.order_id
)

select * from joined

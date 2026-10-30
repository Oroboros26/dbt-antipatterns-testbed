-- Fact table: orders with payment and customer info
-- GRAIN: one row per order
-- Downstream: used by BI dashboards, revenue reports, CS tooling

with order_items as (
    select * from {{ ref('int_order_items') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

-- GRAIN JOIN VIOLATION: joining order-grain table with payment-grain table
-- without aggregating payments first. This produces a fan-out (duplicate rows
-- per order when an order has multiple payments).
bad_join as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.order_amount_usd,
        o.first_name,
        o.last_name,
        o.email,
        -- This join multiplies rows when order has >1 payment
        p.payment_method,
        p.payment_amount_usd
    from order_items o
    left join payments p on o.order_id = p.order_id
)

select * from bad_join

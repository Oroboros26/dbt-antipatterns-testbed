-- Fact table: daily revenue aggregation
-- GRAIN: one row per day per payment_method
-- Used by: Finance dashboard, executive reporting

with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

joined as (
    select
        o.order_date,
        p.payment_method,
        -- DUPLICATE METRIC: "net_revenue_usd" is also defined in int_order_items
        -- with a different formula (order_amount - paid vs sum of payments).
        -- Two definitions of the same metric exist in the project.
        sum(p.payment_amount_usd)                               as gross_revenue_usd,
        sum(p.payment_amount_usd) * 0.97                        as net_revenue_usd,
        count(distinct o.order_id)                              as order_count,
        count(distinct o.customer_id)                           as customer_count
    from payments p
    inner join orders o on p.order_id = o.order_id
    group by 1, 2
)

select * from joined

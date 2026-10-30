-- DUPLICATE METRIC / ORPHAN: This model was created as a "v2" rewrite of dim_customers
-- but was never wired up to replace it. Both models now coexist with slightly different
-- customer_segment logic, causing inconsistent numbers across dashboards.
--
-- dim_customers:    segment uses total_orders (historical)
-- dim_customers_v2: segment uses lifetime_value (newer logic, not yet adopted)
--
-- Nothing downstream references this model yet — it is effectively dead.

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
        sum(order_amount_usd)       as lifetime_value_usd
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name || ' ' || c.last_name      as full_name,
        c.email,
        coalesce(co.total_orders, 0)             as total_orders,
        coalesce(co.lifetime_value_usd, 0)       as lifetime_value_usd,
        -- Different segmentation logic from dim_customers — causes metric drift
        case
            when co.lifetime_value_usd >= 1000   then 'high_value'
            when co.lifetime_value_usd >= 100    then 'mid_value'
            else                                      'low_value'
        end                                      as customer_segment
    from customers c
    left join customer_orders co on c.customer_id = co.customer_id
)

select * from final

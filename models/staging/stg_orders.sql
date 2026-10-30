-- Staging model for raw orders
-- Source: raw.orders

with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        id                          as order_id,
        user_id                     as customer_id,
        order_date,
        status,
        amount                      as order_amount_usd,
        _etl_loaded_at
    from source
)

select * from renamed

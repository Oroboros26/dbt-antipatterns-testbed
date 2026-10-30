-- Staging model for raw payments

with source as (
    select * from {{ source('raw', 'payments') }}
),

renamed as (
    select
        id              as payment_id,
        order_id,
        payment_method,
        amount          as payment_amount_usd,
        created_at
    from source
)

select * from renamed

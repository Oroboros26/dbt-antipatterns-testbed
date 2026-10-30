-- DEAD MODEL: Nothing in the project references this model.
-- It was created for a product catalog feature that was never shipped.
-- Should be deleted or deprecated.

with source as (
    select * from {{ source('raw', 'products') }}
),

renamed as (
    select
        id              as product_id,
        name            as product_name,
        category,
        unit_price_usd,
        is_active,
        created_at
    from source
)

select * from renamed

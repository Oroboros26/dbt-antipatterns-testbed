-- DEAD MODEL: Orphaned staging layer — source table was decommissioned in Q3 2023.
-- This model still compiles but produces empty results.
-- The source 'raw.inventory' no longer exists in the data warehouse.

with source as (
    -- WARNING: This source was deprecated. Query will fail in production.
    select * from {{ source('raw', 'inventory') }}
),

renamed as (
    select
        id              as inventory_id,
        product_id,
        warehouse_id,
        quantity_on_hand,
        reorder_threshold,
        last_updated_at
    from source
)

select * from renamed

-- NEW MODEL: Campaign dimension (added in this PR)
-- Also references a broken source

with source as (
    -- DEPRECATED SOURCE: raw.ad_campaigns was sunset in Dec 2023
    select * from {{ source('raw', 'ad_campaigns') }}
)

select
    id          as campaign_id,
    name        as campaign_name,
    channel,
    start_date  as campaign_date,
    budget_usd  as spend_usd,
    is_active
from source

-- NEW MODEL: Marketing spend fact table (added in this PR)
-- GRAIN: intended to be one row per campaign per day
--
-- VIOLATIONS INTRODUCED IN THIS PR:
--   1. GRAIN JOIN: joins campaign-grain to impression-grain without aggregating
--   2. BROKEN REF: references {{ ref('stg_campaigns') }} which does not exist
--   3. MISSING TESTS: no unique/not_null on any column
--   4. NO DESCRIPTION on most columns

with campaigns as (
    -- BROKEN REF: stg_campaigns does not exist in this project
    select * from {{ ref('stg_campaigns') }}
),

revenue as (
    select * from {{ ref('fct_revenue') }}
),

-- GRAIN JOIN: fct_revenue is day+payment_method grain,
-- campaigns is campaign grain — joining without alignment produces fan-out
joined as (
    select
        c.campaign_id,
        c.campaign_name,
        c.channel,
        c.spend_usd,
        r.order_date,
        r.gross_revenue_usd,
        -- DUPLICATE METRIC: another definition of net revenue
        r.gross_revenue_usd * 0.95              as net_revenue_usd,
        r.gross_revenue_usd / nullif(c.spend_usd, 0) as roas
    from campaigns c
    left join revenue r on c.campaign_date = r.order_date
)

select * from joined

{{ config(
    materialized = 'table'
) }}

with purchase_events as (
    select distinct
        event_key,
        session_key,
        event_date,
        event_timestamp,
        user_pseudo_id,
        ga_session_id,
        transaction_id
    from {{ ref('stg_ga4__events') }}
    where event_name = 'purchase'
      and transaction_id is not null
      and trim(transaction_id) != ''
),

purchase_items as (
    select
        i.event_item_key,
        i.event_key,
        i.session_key,
        pe.event_date as order_date,
        pe.event_timestamp as order_ts,
        i.user_pseudo_id,
        i.ga_session_id,
        pe.transaction_id,
        i.item_id,
        i.item_name,
        lower(trim(i.item_name)) as normalized_item_name,
        i.item_brand,
        i.item_variant,
        nullif(trim(i.item_category), '') as item_category,
        i.item_category2,
        i.item_category3,
        i.item_category4,
        i.item_category5,
        cast(i.item_price as float64) as item_price,
        cast(coalesce(i.quantity, 1) as int64) as quantity,
        cast(i.item_revenue as float64) as item_revenue,
        i.item_coupon,
        i.affiliation,
        i.location_id,
        i.item_list_id,
        i.item_list_name,
        i.item_list_index
    from {{ ref('stg_ga4__items') }} i
    inner join purchase_events pe
        on i.event_key = pe.event_key
    where i.event_name = 'purchase'
),

margin_joined as (
    select
        p.*,
        m.item_name as matched_margin_item_name,
        m.product_category as matched_product_category,
        m.unit_cogs as matched_unit_cogs,
        m.assumed_unit_price as matched_assumed_unit_price,
        m.gross_margin_pct as matched_gross_margin_pct,
        m.gross_margin_per_unit as matched_gross_margin_per_unit
    from purchase_items p
    left join {{ ref('stg_product_margin') }} m
        on p.normalized_item_name = m.normalized_item_name
),

enriched as (
    select
        *,
        case
            when matched_margin_item_name is not null then 'exact_margin_seed_match'
            when lower(coalesce(item_category, '')) = 'clearance' then 'fallback_clearance_margin'
            when regexp_contains(lower(coalesce(item_name, '')), r'(hoodie|tee|t-shirt|shirt|sweatshirt|jacket|cap|sock)') then 'fallback_apparel_margin'
            when regexp_contains(lower(coalesce(item_name, '')), r'(backpack|bottle|mug|journal|notebook|tote|pen|sticker)') then 'fallback_accessory_margin'
            when regexp_contains(lower(coalesce(item_name, '')), r'bike') then 'fallback_lifestyle_margin'
            else 'fallback_default_margin'
        end as margin_source,

        case
            when matched_margin_item_name is not null then matched_product_category
            when lower(coalesce(item_category, '')) = 'clearance' then 'clearance'
            when regexp_contains(lower(coalesce(item_name, '')), r'(hoodie|tee|t-shirt|shirt|sweatshirt|jacket|cap|sock)') then 'apparel'
            when regexp_contains(lower(coalesce(item_name, '')), r'(backpack|bottle|mug|journal|notebook|tote|pen|sticker)') then 'accessories'
            when regexp_contains(lower(coalesce(item_name, '')), r'bike') then 'lifestyle'
            else 'other'
        end as resolved_product_category,

        case
            when matched_margin_item_name is not null then matched_unit_cogs
            when lower(coalesce(item_category, '')) = 'clearance' then coalesce(item_price, 0) * 0.55
            when regexp_contains(lower(coalesce(item_name, '')), r'(hoodie|tee|t-shirt|shirt|sweatshirt|jacket|cap|sock)') then coalesce(item_price, 0) * 0.35
            when regexp_contains(lower(coalesce(item_name, '')), r'(backpack|bottle|mug|journal|notebook|tote|pen|sticker)') then coalesce(item_price, 0) * 0.20
            when regexp_contains(lower(coalesce(item_name, '')), r'bike') then coalesce(item_price, 0) * 0.48
            else coalesce(item_price, 0) * 0.40
        end as estimated_unit_cogs
    from margin_joined
)

select
    event_item_key,
    event_key,
    session_key,
    transaction_id,
    order_date,
    order_ts,
    user_pseudo_id,
    ga_session_id,
    item_id,
    item_name,
    normalized_item_name,
    item_brand,
    item_variant,
    item_category,
    item_category2,
    item_category3,
    item_category4,
    item_category5,
    resolved_product_category,
    item_price,
    quantity,
    item_revenue,
    coalesce(item_revenue, item_price * quantity) as estimated_line_revenue,
    estimated_unit_cogs,
    estimated_unit_cogs * quantity as estimated_line_cogs,
    coalesce(item_revenue, item_price * quantity) - (estimated_unit_cogs * quantity) as estimated_gross_profit,
    safe_divide(
        coalesce(item_revenue, item_price * quantity) - (estimated_unit_cogs * quantity),
        nullif(coalesce(item_revenue, item_price * quantity), 0)
    ) as estimated_gross_margin_pct,
    margin_source,
    matched_margin_item_name,
    matched_product_category,
    matched_unit_cogs,
    matched_assumed_unit_price,
    matched_gross_margin_pct,
    matched_gross_margin_per_unit,
    item_coupon,
    affiliation,
    location_id,
    item_list_id,
    item_list_name,
    item_list_index
from enriched

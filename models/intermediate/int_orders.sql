{{ config(
    materialized = 'table'
) }}

with purchase_events as (
    select
        event_date,
        event_timestamp,
        user_pseudo_id,
        ga_session_id,
        session_key,
        event_key,
        transaction_id,
        purchase_revenue,
        purchase_revenue_in_usd,
        tax_value,
        shipping_value,
        total_item_quantity,
        platform,
        device_category,
        country
    from {{ ref('stg_ga4__events') }}
    where event_name = 'purchase'
      and transaction_id is not null
      and trim(transaction_id) != ''
),

order_rollup as (
    select
        to_hex(md5(transaction_id)) as order_key,
        transaction_id,
        array_agg(event_date ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as order_date,
        min(event_timestamp) as order_ts,
        array_agg(user_pseudo_id ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as user_pseudo_id,
        array_agg(session_key ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as session_key,
        array_agg(ga_session_id ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as ga_session_id,
        count(*) as purchase_event_count,
        count(distinct event_key) as distinct_purchase_event_count,
        sum(coalesce(purchase_revenue, 0)) as order_revenue,
        sum(coalesce(purchase_revenue_in_usd, 0)) as order_revenue_usd,
        sum(coalesce(tax_value, 0)) as order_tax,
        sum(coalesce(shipping_value, 0)) as order_shipping,
        sum(coalesce(total_item_quantity, 0)) as total_item_quantity,
        array_agg(platform ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as platform,
        array_agg(device_category ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as device_category,
        array_agg(country ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as country
    from purchase_events
    group by transaction_id
)

select
    order_key,
    transaction_id,
    order_date,
    order_ts,
    user_pseudo_id,
    session_key,
    ga_session_id,
    purchase_event_count,
    distinct_purchase_event_count,
    order_revenue,
    order_revenue_usd,
    order_tax,
    order_shipping,
    total_item_quantity,
    platform,
    device_category,
    country
from order_rollup

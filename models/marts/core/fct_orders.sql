{{ config(
    materialized = 'table'
) }}

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
from {{ ref('int_orders') }}

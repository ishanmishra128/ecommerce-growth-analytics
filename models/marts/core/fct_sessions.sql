{{ config(
    materialized = 'table'
) }}

select
    session_key,
    user_pseudo_id,
    ga_session_id,
    session_date,
    session_start_ts,
    session_end_ts,
    session_duration_seconds,
    event_count,
    distinct_event_count,
    session_start_count,
    page_view_count,
    product_view_count,
    add_to_cart_count,
    begin_checkout_count,
    purchase_count,
    transaction_count,
    has_purchase,
    has_transaction,
    first_event_name,
    last_event_name,
    platform,
    device_category,
    country
from {{ ref('int_sessions') }}

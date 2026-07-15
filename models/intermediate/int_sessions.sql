{{ config(
    materialized = 'table'
) }}

with base_events as (

    select
        event_date,
        event_timestamp,
        event_name,
        user_pseudo_id,
        ga_session_id,
        session_key,
        event_key,
        platform,
        device_category,
        country,
        transaction_id

    from {{ ref('stg_ga4__events') }}
    where user_pseudo_id is not null
      and ga_session_id is not null
      and session_key is not null

),

session_rollup as (

    select
        session_key,
        user_pseudo_id,
        ga_session_id,

        date(min(event_timestamp)) as session_date,
        min(event_timestamp) as session_start_ts,
        max(event_timestamp) as session_end_ts,
        timestamp_diff(max(event_timestamp), min(event_timestamp), second) as session_duration_seconds,

        count(*) as event_count,
        count(distinct event_key) as distinct_event_count,

        countif(event_name = 'session_start') as session_start_count,
        countif(event_name = 'page_view') > 0 as has_page_view,
        countif(event_name = 'view_item') > 0 as has_product_view,
        countif(event_name = 'add_to_cart') > 0 as has_add_to_cart,
        countif(event_name = 'begin_checkout') > 0 as has_begin_checkout,
        countif(event_name = 'purchase') as purchase_count,

        count(distinct case when transaction_id is not null then transaction_id end) as transaction_count,

        countif(event_name = 'purchase') > 0 as has_purchase,
        count(distinct case when transaction_id is not null then transaction_id end) > 0 as has_transaction,

        array_agg(event_name order by event_timestamp asc limit 1)[safe_offset(0)] as first_event_name,
        array_agg(event_name order by event_timestamp desc limit 1)[safe_offset(0)] as last_event_name,

        array_agg(platform ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as platform,
        array_agg(device_category ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as device_category,
        array_agg(country ignore nulls order by event_timestamp asc limit 1)[safe_offset(0)] as country

    from base_events
    group by
        session_key,
        user_pseudo_id,
        ga_session_id

)

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
from session_rollup
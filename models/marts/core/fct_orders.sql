{{ config(materialized='view') }}

with orders as (

    select *
    from {{ ref('int_orders') }}

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
    platform,
    device_category,
    country
from orders
{{ config(
    materialized = 'table'
) }}

with session_base as (
    select
        user_pseudo_id,
        session_key,
        session_date,
        session_start_ts,
        session_end_ts,
        session_duration_seconds,
        event_count,
        page_view_count,
        product_view_count,
        add_to_cart_count,
        begin_checkout_count,
        purchase_count,
        transaction_count,
        has_purchase,
        has_transaction,
        platform,
        device_category,
        country
    from {{ ref('fct_sessions') }}
    where user_pseudo_id is not null
),

session_rollup as (
    select
        user_pseudo_id,
        min(session_date) as first_session_date,
        max(session_date) as last_session_date,
        min(session_start_ts) as first_session_ts,
        max(session_end_ts) as last_session_ts,
        date_diff(max(session_date), min(session_date), day) as user_lifetime_days,
        count(distinct session_key) as lifetime_session_count,
        sum(event_count) as lifetime_event_count,
        sum(session_duration_seconds) as lifetime_session_duration_seconds,
        sum(page_view_count) as lifetime_page_view_count,
        sum(product_view_count) as lifetime_product_view_count,
        sum(add_to_cart_count) as lifetime_add_to_cart_count,
        sum(begin_checkout_count) as lifetime_begin_checkout_count,
        sum(purchase_count) as lifetime_purchase_count,
        sum(transaction_count) as lifetime_transaction_count,
        countif(page_view_count > 0) as page_view_session_count,
        countif(product_view_count > 0) as product_view_session_count,
        countif(add_to_cart_count > 0) as add_to_cart_session_count,
        countif(begin_checkout_count > 0) as begin_checkout_session_count,
        countif(has_purchase) as purchase_session_count,
        countif(has_transaction) as transaction_session_count
    from session_base
    group by user_pseudo_id
),

session_dims as (
    select
        user_pseudo_id,
        array_agg(platform ignore nulls order by session_start_ts asc limit 1)[safe_offset(0)] as first_platform,
        array_agg(device_category ignore nulls order by session_start_ts asc limit 1)[safe_offset(0)] as first_device_category,
        array_agg(country ignore nulls order by session_start_ts asc limit 1)[safe_offset(0)] as first_country,
        array_agg(platform ignore nulls order by session_start_ts desc limit 1)[safe_offset(0)] as latest_platform,
        array_agg(device_category ignore nulls order by session_start_ts desc limit 1)[safe_offset(0)] as latest_device_category,
        array_agg(country ignore nulls order by session_start_ts desc limit 1)[safe_offset(0)] as latest_country
    from session_base
    group by user_pseudo_id
),

order_rollup as (
    select
        user_pseudo_id,
        count(distinct transaction_id) as lifetime_order_count,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        min(order_ts) as first_order_ts,
        max(order_ts) as last_order_ts,
        sum(order_revenue) as lifetime_revenue,
        sum(order_revenue_usd) as lifetime_revenue_usd,
        sum(order_tax) as lifetime_tax,
        sum(order_shipping) as lifetime_shipping,
        sum(total_item_quantity) as lifetime_item_quantity
    from {{ ref('fct_orders') }}
    where user_pseudo_id is not null
    group by user_pseudo_id
)

select
    s.user_pseudo_id,
    s.first_session_date,
    s.last_session_date,
    s.first_session_ts,
    s.last_session_ts,
    s.user_lifetime_days,
    s.lifetime_session_count,
    s.lifetime_event_count,
    s.lifetime_session_duration_seconds,
    s.lifetime_page_view_count,
    s.lifetime_product_view_count,
    s.lifetime_add_to_cart_count,
    s.lifetime_begin_checkout_count,
    s.lifetime_purchase_count,
    s.lifetime_transaction_count,
    s.page_view_session_count,
    s.product_view_session_count,
    s.add_to_cart_session_count,
    s.begin_checkout_session_count,
    s.purchase_session_count,
    s.transaction_session_count,
    coalesce(o.lifetime_order_count, 0) as lifetime_order_count,
    o.first_order_date,
    o.last_order_date,
    o.first_order_ts,
    o.last_order_ts,
    d.first_platform,
    d.first_device_category,
    d.first_country,
    d.latest_platform,
    d.latest_device_category,
    d.latest_country,
    coalesce(o.lifetime_order_count, 0) > 0 as is_customer,
    safe_divide(coalesce(o.lifetime_order_count, 0), s.lifetime_session_count) as orders_per_session,
    safe_divide(s.purchase_session_count, s.lifetime_session_count) as purchase_session_rate,
    safe_divide(s.begin_checkout_session_count, s.lifetime_session_count) as begin_checkout_session_rate,
    safe_divide(s.add_to_cart_session_count, s.lifetime_session_count) as add_to_cart_session_rate,
    coalesce(o.lifetime_revenue, 0) as lifetime_revenue,
    coalesce(o.lifetime_revenue_usd, 0) as lifetime_revenue_usd,
    coalesce(o.lifetime_tax, 0) as lifetime_tax,
    coalesce(o.lifetime_shipping, 0) as lifetime_shipping,
    coalesce(o.lifetime_item_quantity, 0) as lifetime_item_quantity,
    safe_divide(coalesce(o.lifetime_revenue, 0), nullif(coalesce(o.lifetime_order_count, 0), 0)) as average_order_value,
    safe_divide(coalesce(o.lifetime_revenue, 0), s.lifetime_session_count) as revenue_per_session
from session_rollup s
left join session_dims d
    on s.user_pseudo_id = d.user_pseudo_id
left join order_rollup o
    on s.user_pseudo_id = o.user_pseudo_id

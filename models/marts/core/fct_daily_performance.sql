{{ config(
    materialized = 'table'
) }}

with session_metrics as (

    select
        session_date as metric_date,
        coalesce(platform, 'unknown') as platform,
        coalesce(device_category, 'unknown') as device_category,
        coalesce(country, 'unknown') as country,

        count(*) as session_count,
        count(distinct user_pseudo_id) as user_count,

        sum(case when page_view_count > 0 then 1 else 0 end) as page_view_sessions,
        sum(case when product_view_count > 0 then 1 else 0 end) as product_view_sessions,
        sum(case when add_to_cart_count > 0 then 1 else 0 end) as add_to_cart_sessions,
        sum(case when begin_checkout_count > 0 then 1 else 0 end) as begin_checkout_sessions,
        sum(case when has_purchase then 1 else 0 end) as purchase_sessions,
        sum(case when has_transaction then 1 else 0 end) as transaction_sessions,

        sum(event_count) as total_events,
        sum(session_duration_seconds) as total_session_duration_seconds,
        avg(session_duration_seconds) as avg_session_duration_seconds

    from {{ ref('fct_sessions') }}
    group by 1, 2, 3, 4

),

order_metrics as (

    select
        order_date as metric_date,
        coalesce(platform, 'unknown') as platform,
        coalesce(device_category, 'unknown') as device_category,
        coalesce(country, 'unknown') as country,

        count(*) as order_count,
        count(distinct user_pseudo_id) as ordering_user_count

    from {{ ref('fct_orders') }}
    group by 1, 2, 3, 4

),

combined as (

    select
        coalesce(s.metric_date, o.metric_date) as metric_date,
        coalesce(s.platform, o.platform) as platform,
        coalesce(s.device_category, o.device_category) as device_category,
        coalesce(s.country, o.country) as country,

        coalesce(s.session_count, 0) as session_count,
        coalesce(s.user_count, 0) as user_count,

        coalesce(s.page_view_sessions, 0) as page_view_sessions,
        coalesce(s.product_view_sessions, 0) as product_view_sessions,
        coalesce(s.add_to_cart_sessions, 0) as add_to_cart_sessions,
        coalesce(s.begin_checkout_sessions, 0) as begin_checkout_sessions,
        coalesce(s.purchase_sessions, 0) as purchase_sessions,
        coalesce(s.transaction_sessions, 0) as transaction_sessions,

        coalesce(s.total_events, 0) as total_events,
        coalesce(s.total_session_duration_seconds, 0) as total_session_duration_seconds,
        s.avg_session_duration_seconds,

        coalesce(o.order_count, 0) as order_count,
        coalesce(o.ordering_user_count, 0) as ordering_user_count

    from session_metrics s
    full outer join order_metrics o
        on s.metric_date = o.metric_date
       and s.platform = o.platform
       and s.device_category = o.device_category
       and s.country = o.country

)

select
    to_hex(md5(concat(
        cast(metric_date as string), '||',
        platform, '||',
        device_category, '||',
        country
    ))) as daily_performance_key,

    metric_date,
    platform,
    device_category,
    country,

    session_count,
    user_count,

    page_view_sessions,
    product_view_sessions,
    add_to_cart_sessions,
    begin_checkout_sessions,
    purchase_sessions,
    transaction_sessions,

    total_events,
    total_session_duration_seconds,
    avg_session_duration_seconds,

    order_count,
    ordering_user_count,

    safe_divide(page_view_sessions, session_count) as page_view_session_rate,
    safe_divide(product_view_sessions, session_count) as product_view_session_rate,
    safe_divide(add_to_cart_sessions, session_count) as add_to_cart_session_rate,
    safe_divide(begin_checkout_sessions, session_count) as begin_checkout_session_rate,
    safe_divide(purchase_sessions, session_count) as purchase_session_rate,
    safe_divide(transaction_sessions, session_count) as transaction_session_rate,
    safe_divide(order_count, session_count) as orders_per_session,
    safe_divide(ordering_user_count, user_count) as ordering_user_rate

from combined
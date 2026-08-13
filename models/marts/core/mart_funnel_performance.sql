{{ config(
    materialized = 'table'
) }}

with session_agg as (
    select
        session_date as metric_date,
        coalesce(lower(trim(session_source)), 'unknown') as source,
        coalesce(lower(trim(session_medium)), 'unknown') as medium,
        coalesce(lower(trim(session_campaign)), 'unknown') as campaign,
        coalesce(lower(trim(platform)), 'unknown') as platform,
        coalesce(lower(trim(device_category)), 'unknown') as device_category,
        coalesce(lower(trim(country)), 'unknown') as country,

        count(distinct session_key) as sessions,
        count(distinct user_pseudo_id) as users,
        countif(product_view_count > 0) as product_view_sessions,
        countif(add_to_cart_count > 0) as add_to_cart_sessions,
        countif(begin_checkout_count > 0) as begin_checkout_sessions,
        countif(has_purchase) as purchase_sessions
    from {{ ref('fct_sessions') }}
    group by 1, 2, 3, 4, 5, 6, 7
),

order_agg as (
    select
        order_date as metric_date,
        coalesce(lower(trim(order_source)), 'unknown') as source,
        coalesce(lower(trim(order_medium)), 'unknown') as medium,
        coalesce(lower(trim(order_campaign)), 'unknown') as campaign,
        coalesce(lower(trim(platform)), 'unknown') as platform,
        coalesce(lower(trim(device_category)), 'unknown') as device_category,
        coalesce(lower(trim(country)), 'unknown') as country,

        count(distinct transaction_id) as orders,
        count(distinct user_pseudo_id) as purchasing_users,
        sum(order_revenue) as total_revenue
    from {{ ref('fct_orders') }}
    group by 1, 2, 3, 4, 5, 6, 7
),

final as (
    select
        coalesce(s.metric_date, o.metric_date) as metric_date,
        coalesce(s.source, o.source) as source,
        coalesce(s.medium, o.medium) as medium,
        coalesce(s.campaign, o.campaign) as campaign,
        coalesce(s.platform, o.platform) as platform,
        coalesce(s.device_category, o.device_category) as device_category,
        coalesce(s.country, o.country) as country,

        coalesce(s.sessions, 0) as sessions,
        coalesce(s.users, 0) as users,
        coalesce(s.product_view_sessions, 0) as product_view_sessions,
        coalesce(s.add_to_cart_sessions, 0) as add_to_cart_sessions,
        coalesce(s.begin_checkout_sessions, 0) as begin_checkout_sessions,
        coalesce(s.purchase_sessions, 0) as purchase_sessions,
        coalesce(o.orders, 0) as orders,
        coalesce(o.purchasing_users, 0) as purchasing_users,
        coalesce(o.total_revenue, 0) as total_revenue
    from session_agg s
    full outer join order_agg o
        on s.metric_date = o.metric_date
       and s.source = o.source
       and s.medium = o.medium
       and s.campaign = o.campaign
       and s.platform = o.platform
       and s.device_category = o.device_category
       and s.country = o.country
)

select
    to_hex(md5(concat(
        cast(metric_date as string),
        '|',
        source,
        '|',
        medium,
        '|',
        campaign,
        '|',
        platform,
        '|',
        device_category,
        '|',
        country
    ))) as funnel_performance_key,

    metric_date,
    source,
    medium,
    campaign,
    platform,
    device_category,
    country,

    sessions,
    users,
    product_view_sessions,
    add_to_cart_sessions,
    begin_checkout_sessions,
    purchase_sessions,
    orders,
    purchasing_users,
    total_revenue,

    safe_divide(product_view_sessions, sessions) as session_to_product_view_rate,
    safe_divide(add_to_cart_sessions, product_view_sessions) as product_view_to_add_to_cart_rate,
    safe_divide(begin_checkout_sessions, add_to_cart_sessions) as add_to_cart_to_begin_checkout_rate,
    safe_divide(purchase_sessions, begin_checkout_sessions) as begin_checkout_to_purchase_rate,
    safe_divide(purchase_sessions, sessions) as session_to_purchase_rate,
    safe_divide(orders, sessions) as session_to_order_rate,

    safe_divide(add_to_cart_sessions - begin_checkout_sessions, add_to_cart_sessions) as cart_abandonment_rate,
    safe_divide(begin_checkout_sessions - purchase_sessions, begin_checkout_sessions) as checkout_abandonment_rate,

    product_view_sessions - add_to_cart_sessions as product_view_dropoff_sessions,
    add_to_cart_sessions - begin_checkout_sessions as cart_dropoff_sessions,
    begin_checkout_sessions - purchase_sessions as checkout_dropoff_sessions,

    safe_divide(total_revenue, orders) as average_order_value,
    safe_divide(total_revenue, sessions) as revenue_per_session,
    safe_divide(total_revenue, purchase_sessions) as revenue_per_purchase_session
from final

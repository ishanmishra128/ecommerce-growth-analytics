{{ config(
    materialized = 'table'
) }}

with session_agg as (
    select
        session_date as metric_date,
        coalesce(lower(trim(session_source)), 'unknown') as source,
        coalesce(lower(trim(session_medium)), 'unknown') as medium,
        coalesce(lower(trim(session_campaign)), 'unknown') as campaign,
        count(distinct session_key) as sessions,
        count(distinct user_pseudo_id) as users,
        countif(product_view_count > 0) as product_view_sessions,
        countif(add_to_cart_count > 0) as add_to_cart_sessions,
        countif(begin_checkout_count > 0) as begin_checkout_sessions,
        countif(has_purchase) as purchase_sessions
    from {{ ref('fct_sessions') }}
    group by 1, 2, 3, 4
),

order_agg as (
    select
        order_date as metric_date,
        coalesce(lower(trim(order_source)), 'unknown') as source,
        coalesce(lower(trim(order_medium)), 'unknown') as medium,
        coalesce(lower(trim(order_campaign)), 'unknown') as campaign,
        count(distinct transaction_id) as orders,
        count(distinct user_pseudo_id) as purchasing_users,
        sum(order_revenue) as total_revenue,
        sum(order_revenue_usd) as total_revenue_usd,
        sum(order_tax) as total_tax,
        sum(order_shipping) as total_shipping,
        sum(total_item_quantity) as total_item_quantity
    from {{ ref('fct_orders') }}
    group by 1, 2, 3, 4
),

spend_agg as (
    select
        spend_date as metric_date,
        coalesce(lower(trim(source)), 'unknown') as source,
        coalesce(lower(trim(medium)), 'unknown') as medium,
        coalesce(lower(trim(campaign)), 'unknown') as campaign,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend
    from {{ ref('stg_channel_spend') }}
    group by 1, 2, 3, 4
),

final as (
    select
        coalesce(s.metric_date, o.metric_date, sp.metric_date) as metric_date,
        coalesce(s.source, o.source, sp.source) as source,
        coalesce(s.medium, o.medium, sp.medium) as medium,
        coalesce(s.campaign, o.campaign, sp.campaign) as campaign,

        coalesce(s.sessions, 0) as sessions,
        coalesce(s.users, 0) as users,
        coalesce(s.product_view_sessions, 0) as product_view_sessions,
        coalesce(s.add_to_cart_sessions, 0) as add_to_cart_sessions,
        coalesce(s.begin_checkout_sessions, 0) as begin_checkout_sessions,
        coalesce(s.purchase_sessions, 0) as purchase_sessions,

        coalesce(o.orders, 0) as orders,
        coalesce(o.purchasing_users, 0) as purchasing_users,
        coalesce(o.total_revenue, 0) as total_revenue,
        coalesce(o.total_revenue_usd, 0) as total_revenue_usd,
        coalesce(o.total_tax, 0) as total_tax,
        coalesce(o.total_shipping, 0) as total_shipping,
        coalesce(o.total_item_quantity, 0) as total_item_quantity,

        coalesce(sp.impressions, 0) as impressions,
        coalesce(sp.clicks, 0) as clicks,
        coalesce(sp.spend, 0) as spend
    from session_agg s
    full outer join order_agg o
        on s.metric_date = o.metric_date
       and s.source = o.source
       and s.medium = o.medium
       and s.campaign = o.campaign
    full outer join spend_agg sp
        on coalesce(s.metric_date, o.metric_date) = sp.metric_date
       and coalesce(s.source, o.source) = sp.source
       and coalesce(s.medium, o.medium) = sp.medium
       and coalesce(s.campaign, o.campaign) = sp.campaign
)

select
    to_hex(md5(concat(
        cast(metric_date as string),
        '|',
        source,
        '|',
        medium,
        '|',
        campaign
    ))) as channel_efficiency_key,
    metric_date,
    source,
    medium,
    campaign,
    sessions,
    users,
    product_view_sessions,
    add_to_cart_sessions,
    begin_checkout_sessions,
    purchase_sessions,
    orders,
    purchasing_users,
    total_revenue,
    total_revenue_usd,
    total_tax,
    total_shipping,
    total_item_quantity,
    impressions,
    clicks,
    spend,
    safe_divide(clicks, impressions) as ctr,
    safe_divide(spend, clicks) as cpc,
    safe_divide(spend * 1000, impressions) as cpm,
    safe_divide(product_view_sessions, sessions) as product_view_session_rate,
    safe_divide(add_to_cart_sessions, sessions) as add_to_cart_session_rate,
    safe_divide(begin_checkout_sessions, sessions) as begin_checkout_session_rate,
    safe_divide(purchase_sessions, sessions) as purchase_session_rate,
    safe_divide(orders, sessions) as order_conversion_rate,
    safe_divide(purchasing_users, users) as purchaser_rate,
    safe_divide(total_revenue, orders) as average_order_value,
    safe_divide(total_revenue, users) as revenue_per_user,
    safe_divide(total_revenue, sessions) as revenue_per_session,
    safe_divide(spend, sessions) as cost_per_session,
    safe_divide(spend, orders) as cost_per_order,
    safe_divide(spend, purchasing_users) as cost_per_purchasing_user,
    safe_divide(total_revenue, spend) as roas_proxy,
    safe_divide(sessions, clicks) as sessions_per_click
from final

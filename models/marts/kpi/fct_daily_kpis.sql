{{ config(
    materialized = 'table'
) }}

with session_daily as (
    select
        session_date as date_day,
        count(distinct session_key) as sessions,
        count(distinct user_pseudo_id) as users
    from {{ ref('fct_sessions') }}
    group by 1
),

order_daily as (
    select
        order_date as date_day,
        count(distinct transaction_id) as orders,
        count(distinct user_pseudo_id) as purchasing_users,
        sum(order_revenue) as total_revenue,
        sum(order_revenue_usd) as total_revenue_usd
    from {{ ref('fct_orders') }}
    group by 1
)

select
    coalesce(s.date_day, o.date_day) as date_day,
    coalesce(s.sessions, 0) as sessions,
    coalesce(s.users, 0) as users,
    coalesce(o.orders, 0) as orders,
    coalesce(o.purchasing_users, 0) as purchasing_users,
    coalesce(o.total_revenue, 0) as total_revenue,
    coalesce(o.total_revenue_usd, 0) as total_revenue_usd,
    safe_divide(coalesce(o.orders, 0), coalesce(s.sessions, 0)) as conversion_rate,
    safe_divide(coalesce(o.orders, 0), coalesce(s.users, 0)) as orders_per_user,
    safe_divide(coalesce(o.purchasing_users, 0), coalesce(s.users, 0)) as purchaser_rate,
    safe_divide(coalesce(o.total_revenue, 0), coalesce(o.orders, 0)) as average_order_value,
    safe_divide(coalesce(o.total_revenue, 0), coalesce(s.users, 0)) as revenue_per_active_user,
    safe_divide(coalesce(o.total_revenue, 0), coalesce(s.sessions, 0)) as revenue_per_session
from session_daily s
full outer join order_daily o
    on s.date_day = o.date_day

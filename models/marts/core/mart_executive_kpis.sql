{{ config(
    materialized = 'table'
) }}

with base as (
    select
        date_day,
        sessions,
        users,
        orders,
        purchasing_users,
        total_revenue,
        total_revenue_usd,
        conversion_rate,
        orders_per_user,
        purchaser_rate,
        average_order_value,
        revenue_per_active_user,
        revenue_per_session
    from {{ ref('fct_daily_kpis') }}
),

enriched as (
    select
        date_day,
        sessions,
        users,
        orders,
        purchasing_users,
        total_revenue,
        total_revenue_usd,
        conversion_rate,
        orders_per_user,
        purchaser_rate,
        average_order_value,
        revenue_per_active_user,
        revenue_per_session,

        lag(sessions) over (order by date_day) as prior_day_sessions,
        lag(users) over (order by date_day) as prior_day_users,
        lag(orders) over (order by date_day) as prior_day_orders,
        lag(purchasing_users) over (order by date_day) as prior_day_purchasing_users,
        lag(total_revenue) over (order by date_day) as prior_day_total_revenue,
        lag(total_revenue_usd) over (order by date_day) as prior_day_total_revenue_usd,
        lag(conversion_rate) over (order by date_day) as prior_day_conversion_rate,
        lag(orders_per_user) over (order by date_day) as prior_day_orders_per_user,
        lag(purchaser_rate) over (order by date_day) as prior_day_purchaser_rate,
        lag(average_order_value) over (order by date_day) as prior_day_average_order_value,
        lag(revenue_per_active_user) over (order by date_day) as prior_day_revenue_per_active_user,
        lag(revenue_per_session) over (order by date_day) as prior_day_revenue_per_session,

        avg(sessions) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_sessions,

        avg(users) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_users,

        avg(orders) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_orders,

        avg(purchasing_users) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_purchasing_users,

        avg(total_revenue) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_revenue,

        avg(total_revenue_usd) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_revenue_usd,

        avg(conversion_rate) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_conversion_rate,

        avg(orders_per_user) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_orders_per_user,

        avg(purchaser_rate) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_purchaser_rate,

        avg(average_order_value) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_average_order_value,

        avg(revenue_per_active_user) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_revenue_per_active_user,

        avg(revenue_per_session) over (
            order by date_day
            rows between 6 preceding and current row
        ) as rolling_7d_avg_revenue_per_session
    from base
)

select
    to_hex(md5(cast(date_day as string))) as executive_kpi_key,
    date_day,
    sessions,
    users,
    orders,
    purchasing_users,
    total_revenue,
    total_revenue_usd,
    conversion_rate,
    orders_per_user,
    purchaser_rate,
    average_order_value,
    revenue_per_active_user,
    revenue_per_session,

    prior_day_sessions,
    prior_day_users,
    prior_day_orders,
    prior_day_purchasing_users,
    prior_day_total_revenue,
    prior_day_total_revenue_usd,
    prior_day_conversion_rate,
    prior_day_orders_per_user,
    prior_day_purchaser_rate,
    prior_day_average_order_value,
    prior_day_revenue_per_active_user,
    prior_day_revenue_per_session,

    sessions - prior_day_sessions as sessions_dod_change,
    users - prior_day_users as users_dod_change,
    orders - prior_day_orders as orders_dod_change,
    purchasing_users - prior_day_purchasing_users as purchasing_users_dod_change,
    total_revenue - prior_day_total_revenue as revenue_dod_change,
    total_revenue_usd - prior_day_total_revenue_usd as revenue_usd_dod_change,
    conversion_rate - prior_day_conversion_rate as conversion_rate_dod_point_change,
    average_order_value - prior_day_average_order_value as average_order_value_dod_change,
    revenue_per_active_user - prior_day_revenue_per_active_user as revenue_per_active_user_dod_change,
    revenue_per_session - prior_day_revenue_per_session as revenue_per_session_dod_change,

    safe_divide(sessions - prior_day_sessions, prior_day_sessions) as sessions_dod_change_pct,
    safe_divide(users - prior_day_users, prior_day_users) as users_dod_change_pct,
    safe_divide(orders - prior_day_orders, prior_day_orders) as orders_dod_change_pct,
    safe_divide(purchasing_users - prior_day_purchasing_users, prior_day_purchasing_users) as purchasing_users_dod_change_pct,
    safe_divide(total_revenue - prior_day_total_revenue, prior_day_total_revenue) as revenue_dod_change_pct,
    safe_divide(total_revenue_usd - prior_day_total_revenue_usd, prior_day_total_revenue_usd) as revenue_usd_dod_change_pct,
    safe_divide(average_order_value - prior_day_average_order_value, prior_day_average_order_value) as average_order_value_dod_change_pct,
    safe_divide(revenue_per_active_user - prior_day_revenue_per_active_user, prior_day_revenue_per_active_user) as revenue_per_active_user_dod_change_pct,
    safe_divide(revenue_per_session - prior_day_revenue_per_session, prior_day_revenue_per_session) as revenue_per_session_dod_change_pct,

    rolling_7d_avg_sessions,
    rolling_7d_avg_users,
    rolling_7d_avg_orders,
    rolling_7d_avg_purchasing_users,
    rolling_7d_avg_revenue,
    rolling_7d_avg_revenue_usd,
    rolling_7d_avg_conversion_rate,
    rolling_7d_avg_orders_per_user,
    rolling_7d_avg_purchaser_rate,
    rolling_7d_avg_average_order_value,
    rolling_7d_avg_revenue_per_active_user,
    rolling_7d_avg_revenue_per_session,

    total_revenue > prior_day_total_revenue as is_revenue_up_vs_prior_day,
    orders > prior_day_orders as is_orders_up_vs_prior_day,
    conversion_rate > prior_day_conversion_rate as is_conversion_up_vs_prior_day
from enriched

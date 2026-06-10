{{ config(
    materialized = 'table'
) }}

with sessions_daily as (

    select
        session_date as date_day,
        count(distinct ga_session_id) as sessions,
        count(distinct user_pseudo_id) as users
    from {{ ref('fct_sessions') }}
    group by 1

),

orders_daily as (

    select
        order_date as date_day,
        count(distinct order_key) as orders,
        count(distinct user_pseudo_id) as purchasing_users
    from {{ ref('fct_orders') }}
    group by 1

),

date_spine as (

    select date_day from sessions_daily
    union distinct
    select date_day from orders_daily

),

final as (

    select
        ds.date_day,

        coalesce(sd.sessions, 0) as sessions,
        coalesce(sd.users, 0) as users,

        coalesce(od.orders, 0) as orders,
        coalesce(od.purchasing_users, 0) as purchasing_users,

        case
            when coalesce(sd.sessions, 0) = 0 then 0
            else 1.0 * coalesce(od.orders, 0) / sd.sessions
        end as conversion_rate,

        case
            when coalesce(sd.users, 0) = 0 then 0
            else 1.0 * coalesce(od.orders, 0) / sd.users
        end as orders_per_user,

        case
            when coalesce(sd.users, 0) = 0 then 0
            else 1.0 * coalesce(od.purchasing_users, 0) / sd.users
        end as purchaser_rate

    from date_spine ds
    left join sessions_daily sd
        on ds.date_day = sd.date_day
    left join orders_daily od
        on ds.date_day = od.date_day

)

select *
from final
order by date_day
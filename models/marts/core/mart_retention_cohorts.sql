{{ config(
    materialized = 'table'
) }}

with user_orders as (
    select
        user_pseudo_id,
        transaction_id,
        order_date,
        order_ts,
        order_revenue
    from {{ ref('fct_orders') }}
    where user_pseudo_id is not null
),

ranked_orders as (
    select
        user_pseudo_id,
        transaction_id,
        order_date,
        order_ts,
        order_revenue,
        row_number() over (
            partition by user_pseudo_id
            order by order_ts
        ) as order_number
    from user_orders
),

user_order_summary as (
    select
        user_pseudo_id,
        min(case when order_number = 1 then order_date end) as first_order_date,
        min(case when order_number = 2 then order_date end) as second_order_date,
        count(distinct transaction_id) as total_orders,
        sum(order_revenue) as lifetime_revenue
    from ranked_orders
    group by user_pseudo_id
),

user_retention_flags as (
    select
        user_pseudo_id,
        first_order_date,
        second_order_date,
        total_orders,
        lifetime_revenue,

        date_trunc(first_order_date, month) as cohort_month,

        case
            when total_orders > 1 then true
            else false
        end as is_repeat_purchaser,

        case
            when second_order_date is not null
                 and date_diff(second_order_date, first_order_date, day) <= 30 then true
            else false
        end as repeated_within_30d,

        case
            when second_order_date is not null
                 and date_diff(second_order_date, first_order_date, day) <= 60 then true
            else false
        end as repeated_within_60d,

        case
            when second_order_date is not null
                 and date_diff(second_order_date, first_order_date, day) <= 90 then true
            else false
        end as repeated_within_90d,

        case
            when second_order_date is not null then date_diff(second_order_date, first_order_date, day)
            else null
        end as days_to_second_purchase
    from user_order_summary
    where first_order_date is not null
),

cohort_agg as (
    select
        cohort_month,
        count(*) as cohort_users,
        sum(case when is_repeat_purchaser then 1 else 0 end) as repeat_purchasers,
        sum(case when repeated_within_30d then 1 else 0 end) as repeat_30d_users,
        sum(case when repeated_within_60d then 1 else 0 end) as repeat_60d_users,
        sum(case when repeated_within_90d then 1 else 0 end) as repeat_90d_users,
        avg(days_to_second_purchase) as avg_days_to_second_purchase,
        avg(total_orders) as avg_orders_per_customer,
        sum(lifetime_revenue) as cohort_lifetime_revenue,
        sum(case when is_repeat_purchaser then lifetime_revenue else 0 end) as repeat_purchaser_revenue
    from user_retention_flags
    group by cohort_month
)

select
    to_hex(md5(cast(cohort_month as string))) as retention_cohort_key,
    cohort_month,
    cohort_users,
    repeat_purchasers,
    repeat_30d_users,
    repeat_60d_users,
    repeat_90d_users,
    avg_days_to_second_purchase,
    avg_orders_per_customer,
    cohort_lifetime_revenue,
    repeat_purchaser_revenue,
    safe_divide(repeat_purchasers, cohort_users) as repeat_purchase_rate,
    safe_divide(repeat_30d_users, cohort_users) as repeat_purchase_rate_30d,
    safe_divide(repeat_60d_users, cohort_users) as repeat_purchase_rate_60d,
    safe_divide(repeat_90d_users, cohort_users) as repeat_purchase_rate_90d,
    safe_divide(repeat_purchaser_revenue, cohort_lifetime_revenue) as revenue_share_from_returning_customers
from cohort_agg
order by cohort_month

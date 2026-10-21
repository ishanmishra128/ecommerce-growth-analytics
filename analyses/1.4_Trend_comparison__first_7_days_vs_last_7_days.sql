with ordered as (
  select
    *,
    row_number() over (order by date_day asc) as rn_asc,
    row_number() over (order by date_day desc) as rn_desc
  from `ecommerce-growth-analytics-fri.dbt_imishra.mart_executive_kpis`
),
first_7 as (
  select
    avg(sessions) as avg_sessions,
    avg(users) as avg_users,
    avg(orders) as avg_orders,
    avg(total_revenue) as avg_revenue,
    avg(conversion_rate) as avg_conversion_rate,
    avg(average_order_value) as avg_aov,
    avg(revenue_per_active_user) as avg_rpau
  from ordered
  where rn_asc <= 7
),
last_7 as (
  select
    avg(sessions) as avg_sessions,
    avg(users) as avg_users,
    avg(orders) as avg_orders,
    avg(total_revenue) as avg_revenue,
    avg(conversion_rate) as avg_conversion_rate,
    avg(average_order_value) as avg_aov,
    avg(revenue_per_active_user) as avg_rpau
  from ordered
  where rn_desc <= 7
)
select
  'first_7_days' as period,
  *
from first_7
union all
select
  'last_7_days' as period,
  *
from last_7;

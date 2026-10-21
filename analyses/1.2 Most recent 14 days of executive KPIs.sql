select
  date_day,
  sessions,
  users,
  orders,
  purchasing_users,
  total_revenue,
  conversion_rate,
  average_order_value,
  revenue_per_active_user,
  revenue_per_session,
  sessions_dod_change_pct,
  orders_dod_change_pct,
  revenue_dod_change_pct
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_executive_kpis`
order by date_day desc
limit 14;

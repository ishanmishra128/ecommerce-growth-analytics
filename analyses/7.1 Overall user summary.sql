select
  count(*) as users,
  sum(case when is_customer then 1 else 0 end) as customers,
  avg(lifetime_session_count) as avg_sessions_per_user,
  avg(lifetime_order_count) as avg_orders_per_user,
  avg(lifetime_revenue) as avg_revenue_per_user,
  avg(orders_per_session) as avg_orders_per_session,
  avg(purchase_session_rate) as avg_purchase_session_rate
from `ecommerce-growth-analytics-fri.dbt_imishra.dim_users`;

select
  sum(sessions) as sessions,
  sum(users) as users,
  sum(orders) as orders,
  sum(purchasing_users) as purchasing_users,
  sum(total_revenue) as total_revenue,
  safe_divide(sum(orders), sum(sessions)) as conversion_rate,
  safe_divide(sum(total_revenue), sum(orders)) as average_order_value,
  safe_divide(sum(total_revenue), sum(users)) as revenue_per_active_user,
  safe_divide(sum(total_revenue), sum(sessions)) as revenue_per_session
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_executive_kpis`;

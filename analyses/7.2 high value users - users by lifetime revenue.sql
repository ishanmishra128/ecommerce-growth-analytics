select
  user_pseudo_id,
  lifetime_session_count,
  lifetime_order_count,
  lifetime_revenue,
  average_order_value,
  revenue_per_session,
  first_country,
  latest_country,
  first_device_category,
  latest_device_category
from `ecommerce-growth-analytics-fri.dbt_imishra.dim_users`
order by lifetime_revenue desc
limit 25;


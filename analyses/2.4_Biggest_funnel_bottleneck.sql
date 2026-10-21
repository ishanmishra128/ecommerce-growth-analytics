select
  sum(product_view_dropoff_sessions) as product_view_dropoff_sessions,
  sum(cart_dropoff_sessions) as cart_dropoff_sessions,
  sum(checkout_dropoff_sessions) as checkout_dropoff_sessions
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_funnel_performance`;

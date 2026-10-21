select
  sum(sessions) as sessions,
  sum(product_view_sessions) as product_view_sessions,
  sum(add_to_cart_sessions) as add_to_cart_sessions,
  sum(begin_checkout_sessions) as begin_checkout_sessions,
  sum(purchase_sessions) as purchase_sessions,
  safe_divide(sum(product_view_sessions), sum(sessions)) as session_to_product_view_rate,
  safe_divide(sum(add_to_cart_sessions), sum(product_view_sessions)) as product_view_to_add_to_cart_rate,
  safe_divide(sum(begin_checkout_sessions), sum(add_to_cart_sessions)) as add_to_cart_to_begin_checkout_rate,
  safe_divide(sum(purchase_sessions), sum(begin_checkout_sessions)) as begin_checkout_to_purchase_rate,
  safe_divide(sum(purchase_sessions), sum(sessions)) as session_to_purchase_rate,
  safe_divide(sum(add_to_cart_sessions) - sum(begin_checkout_sessions), sum(add_to_cart_sessions)) as cart_abandonment_rate,
  safe_divide(sum(begin_checkout_sessions) - sum(purchase_sessions), sum(begin_checkout_sessions)) as checkout_abandonment_rate
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_funnel_performance`;


select
  is_customer,
  count(*) as users,
  avg(lifetime_session_count) as avg_sessions,
  avg(lifetime_page_view_count) as avg_page_views,
  avg(lifetime_product_view_count) as avg_product_views,
  avg(lifetime_add_to_cart_count) as avg_add_to_cart,
  avg(lifetime_begin_checkout_count) as avg_begin_checkout,
  avg(lifetime_purchase_count) as avg_purchase_events
from `ecommerce-growth-analytics-fri.dbt_imishra.dim_users`
group by 1;

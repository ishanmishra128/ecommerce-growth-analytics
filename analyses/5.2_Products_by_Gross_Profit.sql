select
  item_name,
  resolved_product_category,
  total_revenue,
  total_gross_profit,
  gross_margin_pct
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_product_performance`
order by total_gross_profit desc
limit 25;

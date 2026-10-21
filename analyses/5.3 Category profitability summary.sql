select
  resolved_product_category,
  count(*) as products,
  sum(order_count) as orders,
  sum(total_quantity_sold) as total_quantity_sold,
  sum(total_revenue) as total_revenue,
  sum(total_gross_profit) as total_gross_profit,
  safe_divide(sum(total_gross_profit), sum(total_revenue)) as gross_margin_pct
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_product_performance`
group by 1
order by total_revenue desc;

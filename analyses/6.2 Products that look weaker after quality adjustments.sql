select
  item_name,
  resolved_product_category,
  risk_tier,
  total_revenue,
  total_gross_profit,
  estimated_refund_value,
  estimated_support_cost,
  estimated_net_contribution_after_returns_support,
  total_gross_profit - estimated_net_contribution_after_returns_support as contribution_erosion
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_product_profit_quality`
order by contribution_erosion desc
limit 25;

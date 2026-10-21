select
  item_name,
  resolved_product_category,
  risk_tier,
  total_revenue,
  total_gross_profit,
  estimated_refund_value,
  estimated_support_cost,
  estimated_net_contribution_after_returns_support,
  estimated_net_contribution_margin_pct
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_product_profit_quality`
order by estimated_net_contribution_after_returns_support desc
limit 25;

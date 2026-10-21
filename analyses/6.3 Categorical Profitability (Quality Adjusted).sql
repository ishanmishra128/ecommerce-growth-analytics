select
  resolved_product_category,
  risk_tier,
  sum(total_revenue) as total_revenue,
  sum(total_gross_profit) as total_gross_profit,
  sum(estimated_refund_value) as estimated_refund_value,
  sum(estimated_support_cost) as estimated_support_cost,
  sum(estimated_net_contribution_after_returns_support) as estimated_net_contribution_after_returns_support,
  safe_divide(
    sum(estimated_net_contribution_after_returns_support),
    sum(total_revenue)
  ) as estimated_net_contribution_margin_pct
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_product_profit_quality`
group by 1, 2
order by total_revenue desc;

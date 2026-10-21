select
  source,
  medium,
  campaign,
  sum(sessions) as sessions,
  sum(users) as users,
  sum(orders) as orders,
  sum(total_revenue) as total_revenue,
  sum(spend) as spend,
  safe_divide(sum(orders), sum(sessions)) as order_conversion_rate,
  safe_divide(sum(total_revenue), sum(sessions)) as revenue_per_session,
  safe_divide(sum(spend), sum(orders)) as cost_per_order,
  safe_divide(sum(total_revenue), sum(spend)) as roas_proxy
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_channel_efficiency`
group by 1, 2, 3
order by spend desc, total_revenue desc;
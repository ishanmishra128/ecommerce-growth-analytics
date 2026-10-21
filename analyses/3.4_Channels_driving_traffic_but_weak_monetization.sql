select
  source,
  medium,
  campaign,
  sum(sessions) as sessions,
  sum(total_revenue) as total_revenue,
  safe_divide(sum(total_revenue), sum(sessions)) as revenue_per_session,
  safe_divide(sum(orders), sum(sessions)) as order_conversion_rate
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_channel_efficiency`
group by 1, 2, 3
order by sessions desc;

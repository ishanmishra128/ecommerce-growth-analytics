select
  source,
  medium,
  campaign,
  sum(spend) as spend_sum,
  sum(orders) as orders,
  safe_divide(sum(spend), sum(orders)) as cost_per_order
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_channel_efficiency`
group by 1, 2, 3
having spend_sum > 0
order by cost_per_order desc;

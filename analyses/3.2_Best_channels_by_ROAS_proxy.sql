select
  source,
  medium,
  campaign,
  sum(spend) as spend_sum,
  sum(total_revenue) as total_revenue,
  safe_divide(sum(total_revenue), sum(spend)) as roas_proxy
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_channel_efficiency`
group by 1, 2, 3
having spend_sum > 0
order by roas_proxy desc, spend_sum desc;

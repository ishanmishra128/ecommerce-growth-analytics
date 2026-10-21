select
  cohort_month,
  cohort_users,
  repeat_purchase_rate,
  repeat_purchase_rate_30d,
  repeat_purchase_rate_60d,
  repeat_purchase_rate_90d,
  avg_days_to_second_purchase
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_retention_cohorts`
order by repeat_purchase_rate desc;

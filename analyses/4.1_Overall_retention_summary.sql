select
  sum(cohort_users) as cohort_users,
  sum(repeat_purchasers) as repeat_purchasers,
  safe_divide(sum(repeat_purchasers), sum(cohort_users)) as repeat_purchase_rate,
  safe_divide(sum(repeat_30d_users), sum(cohort_users)) as repeat_purchase_rate_30d,
  safe_divide(sum(repeat_60d_users), sum(cohort_users)) as repeat_purchase_rate_60d,
  safe_divide(sum(repeat_90d_users), sum(cohort_users)) as repeat_purchase_rate_90d,
  avg(avg_days_to_second_purchase) as avg_days_to_second_purchase,
  safe_divide(sum(repeat_purchaser_revenue), sum(cohort_lifetime_revenue)) as revenue_share_from_returning_customers
from `ecommerce-growth-analytics-fri.dbt_imishra.mart_retention_cohorts`;

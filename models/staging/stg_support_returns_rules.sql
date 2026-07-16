{{ config(
    materialized = 'view'
) }}

select
    lower(trim(resolved_product_category)) as resolved_product_category,
    cast(expected_return_rate as float64) as expected_return_rate,
    cast(expected_support_case_rate as float64) as expected_support_case_rate,
    cast(avg_refund_pct_if_returned as float64) as avg_refund_pct_if_returned,
    cast(avg_support_cost_per_order as float64) as avg_support_cost_per_order,
    cast(avg_resolution_days as int64) as avg_resolution_days,
    lower(trim(risk_tier)) as risk_tier
from {{ ref('support_returns_rules') }}

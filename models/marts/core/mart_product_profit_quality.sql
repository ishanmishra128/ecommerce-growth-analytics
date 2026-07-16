{{ config(
    materialized = 'table'
) }}

with base as (
    select
        product_performance_key,
        item_id,
        item_name,
        normalized_item_name,
        item_brand,
        resolved_product_category,
        purchase_item_rows,
        order_count,
        purchasing_user_count,
        total_quantity_sold,
        total_revenue,
        total_cogs,
        total_gross_profit,
        gross_margin_pct,
        realized_avg_unit_price,
        estimated_avg_unit_cogs,
        estimated_gross_profit_per_unit,
        revenue_per_order,
        gross_profit_per_order,
        exact_margin_match_rows,
        fallback_margin_rows,
        exact_margin_match_rate
    from {{ ref('mart_product_performance') }}
),

rules as (
    select
        resolved_product_category,
        expected_return_rate,
        expected_support_case_rate,
        avg_refund_pct_if_returned,
        avg_support_cost_per_order,
        avg_resolution_days,
        risk_tier
    from {{ ref('stg_support_returns_rules') }}
),

final as (
    select
        b.*,
        r.expected_return_rate,
        r.expected_support_case_rate,
        r.avg_refund_pct_if_returned,
        r.avg_support_cost_per_order,
        r.avg_resolution_days,
        r.risk_tier,

        b.order_count * r.expected_return_rate as estimated_returned_orders,
        b.order_count * r.expected_support_case_rate as estimated_support_cases,
        b.total_revenue * r.expected_return_rate * r.avg_refund_pct_if_returned as estimated_refund_value,
        b.order_count * r.avg_support_cost_per_order as estimated_support_cost,
        b.total_gross_profit
            - (b.total_revenue * r.expected_return_rate * r.avg_refund_pct_if_returned)
            - (b.order_count * r.avg_support_cost_per_order) as estimated_net_contribution_after_returns_support
    from base b
    left join rules r
        on lower(trim(b.resolved_product_category)) = lower(trim(r.resolved_product_category))
)

select
    to_hex(md5(product_performance_key)) as product_profit_quality_key,
    product_performance_key,
    item_id,
    item_name,
    normalized_item_name,
    item_brand,
    resolved_product_category,
    purchase_item_rows,
    order_count,
    purchasing_user_count,
    total_quantity_sold,
    total_revenue,
    total_cogs,
    total_gross_profit,
    gross_margin_pct,
    realized_avg_unit_price,
    estimated_avg_unit_cogs,
    estimated_gross_profit_per_unit,
    revenue_per_order,
    gross_profit_per_order,
    exact_margin_match_rows,
    fallback_margin_rows,
    exact_margin_match_rate,
    expected_return_rate,
    expected_support_case_rate,
    avg_refund_pct_if_returned,
    avg_support_cost_per_order,
    avg_resolution_days,
    risk_tier,
    estimated_returned_orders,
    estimated_support_cases,
    estimated_refund_value,
    estimated_support_cost,
    estimated_net_contribution_after_returns_support,
    safe_divide(estimated_net_contribution_after_returns_support, nullif(total_revenue, 0)) as estimated_net_contribution_margin_pct
from final

{{ config(
    materialized = 'table'
) }}

with base as (
    select
        item_id,
        item_name,
        normalized_item_name,
        item_brand,
        resolved_product_category,
        transaction_id,
        user_pseudo_id,
        quantity,
        estimated_line_revenue,
        estimated_line_cogs,
        estimated_gross_profit,
        estimated_gross_margin_pct,
        margin_source
    from {{ ref('int_order_items_margin') }}
),

aggregated as (
    select
        item_id,
        item_name,
        normalized_item_name,
        item_brand,
        resolved_product_category,
        count(*) as purchase_item_rows,
        count(distinct transaction_id) as order_count,
        count(distinct user_pseudo_id) as purchasing_user_count,
        sum(quantity) as total_quantity_sold,
        sum(estimated_line_revenue) as total_revenue,
        sum(estimated_line_cogs) as total_cogs,
        sum(estimated_gross_profit) as total_gross_profit,
        safe_divide(sum(estimated_gross_profit), nullif(sum(estimated_line_revenue), 0)) as gross_margin_pct,
        safe_divide(sum(estimated_line_revenue), nullif(sum(quantity), 0)) as realized_avg_unit_price,
        safe_divide(sum(estimated_line_cogs), nullif(sum(quantity), 0)) as estimated_avg_unit_cogs,
        safe_divide(sum(estimated_gross_profit), nullif(sum(quantity), 0)) as estimated_gross_profit_per_unit,
        safe_divide(sum(estimated_line_revenue), nullif(count(distinct transaction_id), 0)) as revenue_per_order,
        safe_divide(sum(estimated_gross_profit), nullif(count(distinct transaction_id), 0)) as gross_profit_per_order,
        countif(margin_source = 'exact_margin_seed_match') as exact_margin_match_rows,
        countif(margin_source != 'exact_margin_seed_match') as fallback_margin_rows
    from base
    group by
        item_id,
        item_name,
        normalized_item_name,
        item_brand,
        resolved_product_category
)

select
    to_hex(md5(concat(
        coalesce(item_id, ''),
        '|',
        coalesce(normalized_item_name, ''),
        '|',
        coalesce(resolved_product_category, '')
    ))) as product_performance_key,
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
    safe_divide(exact_margin_match_rows, nullif(purchase_item_rows, 0)) as exact_margin_match_rate
from aggregated

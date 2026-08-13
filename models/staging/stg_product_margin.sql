{{ config(
    materialized = 'view'
) }}

select
    lower(trim(item_name)) as normalized_item_name,
    item_name,
    lower(trim(product_category)) as product_category,
    cast(unit_cogs as float64) as unit_cogs,
    cast(assumed_unit_price as float64) as assumed_unit_price,
    cast(gross_margin_pct as float64) as gross_margin_pct,
    cast(assumed_unit_price as float64) - cast(unit_cogs as float64) as gross_margin_per_unit
from {{ ref('product_margin') }}

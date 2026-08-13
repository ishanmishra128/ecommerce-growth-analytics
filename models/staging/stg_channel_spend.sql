{{ config(
    materialized = 'view'
) }}

select
    cast(spend_date as date) as spend_date,
    lower(trim(source)) as source,
    lower(trim(medium)) as medium,
    lower(trim(campaign)) as campaign,
    cast(impressions as int64) as impressions,
    cast(clicks as int64) as clicks,
    cast(spend as float64) as spend,
    safe_divide(cast(clicks as float64), nullif(cast(impressions as float64), 0)) as ctr,
    safe_divide(cast(spend as float64), nullif(cast(clicks as float64), 0)) as cpc,
    safe_divide(cast(spend as float64) * 1000, nullif(cast(impressions as float64), 0)) as cpm
from {{ ref('channel_spend') }}

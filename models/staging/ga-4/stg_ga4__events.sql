{{ config(materialized='view') }}

with source as (
    select *
    from {{ source('ga4', 'events') }}
),

renamed as (
    select
        parse_date('%Y%m%d', event_date) as event_date,
        timestamp_micros(event_timestamp) as event_timestamp,
        event_name,
        user_pseudo_id,

        cast((
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_id'
        ) as string) as ga_session_id,

        concat(
            user_pseudo_id,
            '-',
            cast((
                select value.int_value
                from unnest(event_params)
                where key = 'ga_session_id'
            ) as string)
        ) as session_key,

        to_hex(md5(concat(
            coalesce(user_pseudo_id, ''),
            '-',
            coalesce(cast(event_timestamp as string), ''),
            '-',
            coalesce(event_name, ''),
            '-',
            coalesce(cast((
                select value.int_value
                from unnest(event_params)
                where key = 'ga_session_id'
            ) as string), '')
        ))) as event_key,

        platform,
        device.category as device_category,
        geo.country as country,

        coalesce(
            ecommerce.transaction_id,
            (
                select value.string_value
                from unnest(event_params)
                where key = 'transaction_id'
            )
        ) as transaction_id,

        coalesce(
            (
                select value.string_value
                from unnest(event_params)
                where key = 'source'
            ),
            traffic_source.source
        ) as traffic_source,

        coalesce(
            (
                select value.string_value
                from unnest(event_params)
                where key = 'medium'
            ),
            traffic_source.medium
        ) as traffic_medium,

        coalesce(
            (
                select value.string_value
                from unnest(event_params)
                where key = 'campaign'
            ),
            traffic_source.name
        ) as traffic_campaign,

        ecommerce.purchase_revenue as purchase_revenue,
        ecommerce.purchase_revenue_in_usd as purchase_revenue_in_usd,
        ecommerce.tax_value as tax_value,
        ecommerce.shipping_value as shipping_value,
        ecommerce.total_item_quantity as total_item_quantity

    from source
)

select *
from renamed

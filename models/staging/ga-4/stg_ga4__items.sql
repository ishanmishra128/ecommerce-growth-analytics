with source as (

    select *
    from {{ source('ga4', 'events') }}

),

unnested_items as (

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

        item_offset,

        item.item_id,
        item.item_name,
        item.item_brand,
        item.item_variant,
        item.item_category,
        item.item_category2,
        item.item_category3,
        item.item_category4,
        item.item_category5,
        item.price,
        item.quantity,
        item.item_revenue,
        item.coupon,
        item.affiliation,
        item.location_id,
        item.item_list_id,
        item.item_list_name,
        item.item_list_index

    from source
    cross join unnest(items) as item with offset as item_offset

)

select
    to_hex(md5(concat(
        coalesce(event_key, ''),
        '-',
        cast(item_offset as string)
    ))) as event_item_key,

    event_key,
    session_key,
    event_date,
    event_timestamp,
    event_name,
    user_pseudo_id,
    ga_session_id,
    item_offset,

    item_id,
    item_name,
    item_brand,
    item_variant,
    item_category,
    item_category2,
    item_category3,
    item_category4,
    item_category5,
    price as item_price,
    quantity,
    item_revenue,
    coupon as item_coupon,
    affiliation,
    location_id,
    item_list_id,
    item_list_name,
    item_list_index

from unnested_items
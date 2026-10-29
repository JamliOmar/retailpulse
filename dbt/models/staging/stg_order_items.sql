select
    order_id || '-' || order_item_id        as order_item_key,
    order_id,
    order_item_id::int                      as item_number,
    product_id,
    seller_id,
    shipping_limit_date::timestamp          as shipping_limit_at,
    price::numeric(12, 2)                   as price,
    freight_value::numeric(12, 2)           as freight_value,
    _loaded_at,
    _source_file
from {{ source('raw', 'order_items') }}

{{ config(materialized='table', schema='gold') }}

-- Grain : une ligne par article de commande
select
    md5(i.order_item_key)                                   as sales_key,
    i.order_id,
    i.item_number                                           as order_item_number,
    md5(c.customer_unique_id)                               as customer_key,
    md5(i.product_id)                                       as product_key,
    md5(i.seller_id)                                        as seller_key,
    to_char(o.purchased_at, 'YYYYMMDD')::int                as purchase_date_key,
    to_char(o.estimated_delivery_at, 'YYYYMMDD')::int       as estimated_date_key,
    to_char(o.delivered_at, 'YYYYMMDD')::int                as delivered_date_key,
    o.order_status,
    i.price,
    i.freight_value,
    i.price + i.freight_value                               as item_total,
    o.delivered_at::date - o.purchased_at::date             as delivery_days,
    o.delivered_at::date - o.estimated_delivery_at::date    as delay_days,
    o.delivered_at::date > o.estimated_delivery_at::date    as is_late
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o
    on i.order_id = o.order_id
join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id

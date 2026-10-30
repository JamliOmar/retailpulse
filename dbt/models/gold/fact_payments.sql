{{ config(materialized='table', schema='gold') }}

-- Grain : une ligne par paiement d'une commande
select
    md5(p.payment_key)                                  as payment_key,
    p.order_id,
    md5(c.customer_unique_id)                           as customer_key,
    md5(p.payment_type)                                 as payment_type_key,
    to_char(o.purchased_at, 'YYYYMMDD')::int            as purchase_date_key,
    p.payment_sequential,
    p.installments,
    p.payment_value
from {{ ref('stg_order_payments') }} p
join {{ ref('stg_orders') }} o
    on p.order_id = o.order_id
join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id

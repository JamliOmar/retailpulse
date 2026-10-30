{{ config(materialized='table', schema='gold') }}

-- Une ligne par personne (customer_unique_id), avec l'adresse de sa derniere commande
with customer_orders as (
    select
        c.customer_unique_id,
        c.zip_code_prefix,
        c.city,
        c.state,
        o.purchased_at
    from {{ ref('stg_customers') }} c
    left join {{ ref('stg_orders') }} o
        on o.customer_id = c.customer_id
),

latest as (
    select
        *,
        row_number() over (
            partition by customer_unique_id
            order by purchased_at desc nulls last
        ) as rn
    from customer_orders
)

select
    md5(l.customer_unique_id)   as customer_key,
    l.customer_unique_id,
    l.zip_code_prefix,
    l.city,
    l.state,
    g.latitude,
    g.longitude
from latest l
left join {{ ref('stg_geolocation') }} g
    on l.zip_code_prefix = g.zip_code_prefix
where l.rn = 1

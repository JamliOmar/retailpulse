{{ config(materialized='table', schema='gold') }}

-- Grain : une ligne par avis client
select
    md5(r.review_key)                                   as review_key,
    r.order_id,
    md5(c.customer_unique_id)                           as customer_key,
    to_char(r.created_at, 'YYYYMMDD')::int              as review_date_key,
    r.review_score,
    coalesce(trim(r.comment_message), '') <> ''         as has_comment
from {{ ref('stg_order_reviews') }} r
join {{ ref('stg_orders') }} o
    on r.order_id = o.order_id
join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id

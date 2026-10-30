{{ config(materialized='table', schema='gold') }}

select
    md5(payment_type) as payment_type_key,
    payment_type
from (
    select distinct payment_type
    from {{ ref('stg_order_payments') }}
    where payment_type is not null
) t

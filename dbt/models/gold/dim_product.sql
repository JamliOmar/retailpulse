{{ config(materialized='table', schema='gold') }}

select
    md5(product_id)                          as product_key,
    product_id,
    category_name,
    category_name_pt,
    photos_qty,
    weight_g,
    length_cm * height_cm * width_cm         as volume_cm3
from {{ ref('stg_products') }}

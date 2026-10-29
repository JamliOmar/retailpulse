select
    p.product_id,
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category_name,
    p.product_category_name                 as category_name_pt,
    p.product_name_lenght::numeric::int     as name_length,
    p.product_description_lenght::numeric::int as description_length,
    p.product_photos_qty::numeric::int      as photos_qty,
    p.product_weight_g::numeric             as weight_g,
    p.product_length_cm::numeric            as length_cm,
    p.product_height_cm::numeric            as height_cm,
    p.product_width_cm::numeric             as width_cm,
    p._loaded_at,
    p._source_file
from {{ source('raw', 'products') }} p
left join {{ source('raw', 'product_category_name_translation') }} t
    on p.product_category_name = t.product_category_name

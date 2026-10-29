select
    seller_id,
    seller_zip_code_prefix     as zip_code_prefix,
    initcap(seller_city)       as city,
    upper(seller_state)        as state,
    _loaded_at,
    _source_file
from {{ source('raw', 'sellers') }}

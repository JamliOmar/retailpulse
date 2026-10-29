select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix   as zip_code_prefix,
    initcap(customer_city)     as city,
    upper(customer_state)      as state,
    _loaded_at,
    _source_file
from {{ source('raw', 'customers') }}

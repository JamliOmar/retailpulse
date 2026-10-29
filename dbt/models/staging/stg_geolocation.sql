{{ config(materialized='table') }}

select
    geolocation_zip_code_prefix                              as zip_code_prefix,
    avg(geolocation_lat::numeric)                            as latitude,
    avg(geolocation_lng::numeric)                            as longitude,
    mode() within group (order by initcap(geolocation_city)) as city,
    mode() within group (order by upper(geolocation_state))  as state
from {{ source('raw', 'geolocation') }}
group by geolocation_zip_code_prefix

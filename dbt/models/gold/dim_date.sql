{{ config(materialized='table', schema='gold') }}

with days as (
    select d::date as full_date
    from generate_series('2016-01-01'::date, '2018-12-31'::date, interval '1 day') as d
)

select
    to_char(full_date, 'YYYYMMDD')::int                 as date_key,
    full_date,
    extract(year from full_date)::int                   as year,
    extract(quarter from full_date)::int                as quarter,
    extract(month from full_date)::int                  as month,
    trim(to_char(full_date, 'Month'))                   as month_name,
    extract(week from full_date)::int                   as week_of_year,
    extract(isodow from full_date)::int                 as day_of_week,
    trim(to_char(full_date, 'Day'))                     as day_name,
    extract(isodow from full_date) in (6, 7)            as is_weekend,
    false                                               as is_holiday,
    null::text                                          as holiday_name
from days

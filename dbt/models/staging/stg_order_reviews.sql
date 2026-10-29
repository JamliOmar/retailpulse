with ranked as (
    select
        *,
        row_number() over (
            partition by review_id, order_id
            order by review_answer_timestamp::timestamp desc
        ) as rn
    from {{ source('raw', 'order_reviews') }}
)

select
    review_id || '-' || order_id            as review_key,
    review_id,
    order_id,
    review_score::int                       as review_score,
    review_comment_title                    as comment_title,
    review_comment_message                  as comment_message,
    review_creation_date::timestamp         as created_at,
    review_answer_timestamp::timestamp      as answered_at,
    _loaded_at,
    _source_file
from ranked
where rn = 1

-- Description: Monthly capitation payment summary per provider
-- Granularity: One row per provider_id + payment_month
-- Key Business Logic:
--   - Capitation is a fixed monthly fee paid per enrolled member regardless of utilization
--   - total_capitation_php = member_count * capitation_rate_php (from provider_rates seed)
--   - Covers capitation-eligible providers only
--   - member_count is the enrolled headcount as of the first day of the payment month

with providers as (

    select *
    from {{ ref('stg_providers') }}
    where capitation_eligible = true

),

enrollments as (

    select * from {{ ref('stg_member_enrollments') }}

),

capitation_rates as (

    -- Seed file with agreed capitation rates per provider tier
    select * from {{ ref('provider_rates') }}

),

monthly_enrollment as (

    -- Headcount per provider per month (as-of first day of month)
    select
        provider_id,
        date_trunc(enrollment_date, month)      as payment_month,
        count(distinct member_id)               as member_count

    from enrollments
    where enrollment_status = 'active'
    group by 1, 2

),

final as (

    select
        me.provider_id,
        p.provider_name,
        p.provider_type,
        p.region,
        p.capitation_rate_tier,
        me.payment_month,
        me.member_count,
        cr.capitation_rate_php,
        me.member_count * cr.capitation_rate_php    as total_capitation_php

    from monthly_enrollment me
    inner join providers p
        on me.provider_id = p.provider_id
    left join capitation_rates cr
        on p.capitation_rate_tier = cr.rate_tier

)

select * from final

-- Description: Fact table for paid claims, one row per claim payment event
-- Granularity: One row per claim_id + payment_date
-- Key Business Logic:
--   - Filters to finalized claims only (status = 'paid')
--   - Joins provider dim for provider metadata
--   - Joins member dim for plan and group info
--   - claim_amount_php is the gross paid amount before deductions

with source as (

    select * from {{ ref('stg_claims') }}

),

providers as (

    select * from {{ ref('dim_providers') }}

),

members as (

    select * from {{ ref('dim_members') }}

),

paid_claims as (

    -- Filter to finalized paid claims only
    select *
    from source
    where claim_status = 'paid'
      and payment_date is not null

),

final as (

    select
        pc.claim_id,
        pc.member_id,
        pc.provider_id,
        pc.service_date,
        pc.payment_date,
        pc.claim_amount_php,
        pc.deductible_amount_php,
        pc.net_paid_amount_php,
        pc.diagnosis_code,
        pc.claim_type,                          -- inpatient, outpatient, pharmacy
        p.provider_name,
        p.provider_type,
        p.region,
        m.plan_code,
        m.group_id,
        m.corporate_account

    from paid_claims pc
    left join providers p
        on pc.provider_id = p.provider_id
    left join members m
        on pc.member_id = m.member_id

)

select * from final

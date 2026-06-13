-- Description: Staging model for provider master data from the accreditation system
-- Granularity: One row per provider_id
-- Key Business Logic:
--   - provider_id is cast to STRING to align with claims source (source has mixed int/string)
--   - Filters to active accreditation status only
--   - capitation_eligible flags providers enrolled in the capitation payment scheme
--   - BUG FIX: previously joined on tin instead of provider_id, causing fan-out on shared TINs
--     (e.g. hospital networks with multiple branches under one TIN)

with source as (

    select * from {{ source('accreditation', 'providers') }}

),

renamed as (

    select
        cast(provider_id as string)             as provider_id,    -- fix: was int, mismatched claims join key
        provider_name,
        tin,                                                        -- tax identification number
        provider_type,                                              -- hospital, clinic, pharmacy
        accreditation_status,
        accreditation_start_date,
        accreditation_end_date,
        region,
        city,
        contact_email,
        cast(capitation_eligible as bool)       as capitation_eligible,
        capitation_rate_tier

    from source

),

active_providers as (

    -- Keep only currently accredited providers
    select *
    from renamed
    where accreditation_status = 'active'
      and accreditation_end_date >= current_date()

)

select * from active_providers

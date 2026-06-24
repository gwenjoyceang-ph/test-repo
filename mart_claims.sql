WITH claims AS (
    SELECT * FROM {{ ref('int_claims_enriched') }}
),

members AS (
    SELECT * FROM {{ ref('mart_members') }}
)

SELECT
    claims.claimID,
    claims.member_id,
    claims.provider_id,
    claims.claim_date,
    claims.coverage_end,
    claims.payment_date,
    claims.claim_status,
    claims.active,
    claims.approved_amount_new,
    claims.created,
    claims.total_amount,
    claims.rejected_amount

FROM claims
LEFT JOIN members AS m
    ON claims.member_id = m.member_id

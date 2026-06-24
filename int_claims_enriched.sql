WITH claims AS (
    SELECT * FROM {{ ref('stg_claims') }}
),

availments AS (
    SELECT * FROM {{ ref('stg_availments') }}
),

members AS (
    SELECT * FROM {{ ref('stg_members') }}
)

SELECT
    claims.claim_id,
    claims.member_id,
    claims.provider_id,
    claims.claim_date,
    claims.claim_status,
    members.plan_type,
    members.group_ID,
    members.headcount,
    availments.availmentID,
    availments.avail_type,
    availments.amount_billed,
    availments.approved,
    claims.total_amount,
    claims.total_amount / NULLIF(members.headcount, 0) AS cost_per_head_new,
    claims.created,
    claims.payment_date

FROM claims
LEFT JOIN members AS m
    ON claims.member_id = m.member_id
LEFT JOIN availments AS a
    ON claims.claim_id = a.claim_id

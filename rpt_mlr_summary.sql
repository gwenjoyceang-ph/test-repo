WITH claims AS (
    SELECT * FROM {{ ref('mart_claims') }}
),

members AS (
    SELECT * FROM {{ ref('mart_members') }}
)

SELECT
    members.account_name,
    members.headcount_group,
    members.plan_type,
    DATE_TRUNC(claims.claim_date, MONTH) AS reportMonth,
    SUM(claims.total_amount) AS totalPremiums,
    SUM(claims.approved_amount) AS totalAvailments,
    SUM(claims.approved_amount) / NULLIF(SUM(claims.total_amount), 0) AS mlr_final,
    COUNT(DISTINCT claims.member_id) AS memberCount,
    SUM(CASE WHEN claims.claim_status = 'rejected' THEN claims.total_amount ELSE 0 END) AS rejectedTotal

FROM claims
LEFT JOIN members AS m
    ON claims.member_id = m.member_id
WHERE claims.claim_date >= '2024-01-01'
GROUP BY 1, 2, 3, 4

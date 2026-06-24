WITH source AS (
    SELECT * FROM {{ source('raw', 'availments') }}
)

SELECT
    availmentID,
    memberID,
    providerID,
    availment_date,
    avail_type,
    amount_billed,
    approved,
    remarks,
    created,
    syncedAt
FROM source

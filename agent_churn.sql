-- agent_churn.sql
-- Purpose: Build a DAILY user-level snapshot used by the retention agent
-- Grain: 1 row per user per day
-- This table feeds churn prediction + uplift models

WITH base_users AS (
    SELECT
        u.user_id,
        u.signup_date
    FROM users u
),

activity_agg AS (
    SELECT
        e.user_id,
        COUNT(*) FILTER (WHERE e.event_date >= CURRENT_DATE - INTERVAL '7 days')  AS sessions_7d,
        COUNT(*) FILTER (WHERE e.event_date >= CURRENT_DATE - INTERVAL '30 days') AS sessions_30d,
        MAX(e.event_date)                                                          AS last_active_date
    FROM user_events e
    GROUP BY e.user_id
),

purchase_agg AS (
    SELECT
        p.user_id,
        COUNT(*) FILTER (WHERE p.purchase_date >= CURRENT_DATE - INTERVAL '30 days') AS purchases_30d,
        SUM(p.amount) FILTER (WHERE p.purchase_date >= CURRENT_DATE - INTERVAL '30 days') AS revenue_30d
    FROM purchases p
    GROUP BY p.user_id
),

agent_churn_snapshot AS (
    SELECT
        b.user_id,

        -- Time-based features
        DATE_PART('day', CURRENT_DATE - b.signup_date)         AS tenure_days,
        DATE_PART('day', CURRENT_DATE - a.last_active_date)    AS days_inactive,

        -- Engagement features
        COALESCE(a.sessions_7d, 0)                              AS sessions_7d,
        COALESCE(a.sessions_30d, 0)                             AS sessions_30d,

        -- Monetization features
        COALESCE(p.purchases_30d, 0)                            AS purchases_30d,
        COALESCE(p.revenue_30d, 0)                              AS revenue_30d,

        -- Snapshot date
        CURRENT_DATE                                            AS snapshot_date
    FROM base_users b
    LEFT JOIN activity_agg a
        ON b.user_id = a.user_id
    LEFT JOIN purchase_agg p
        ON b.user_id = p.user_id
)

SELECT *
FROM agent_churn_snapshot;

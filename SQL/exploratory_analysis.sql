-- Section 1
-- Define customer portfolio size and average attrition rates

SELECT
    COUNT (*) AS total_customers,
    SUM(churned) AS attrited_customers,
    COUNT(*) - SUM(churned) AS retained_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM bank_data;

SELECT
    ROUND(AVG(customer_age), 2) AS avg_customer_age,
    ROUND(AVG(customer_tenure_months), 2) AS avg_tenure_months,
    ROUND(AVG(total_relationship_count), 2) AS avg_relationship_count,
    ROUND(AVG(months_inactive_12_mon), 2) AS avg_inactive_months,
    ROUND(AVG(total_trans_ct), 2) AS avg_transaction_count,
    ROUND(AVG(total_trans_amt), 2) AS avg_transaction_amount,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit,
    ROUND(AVG(avg_utilization_ratio), 3) AS avg_utilization_ratio
FROM bank_data;

-- Section 2
-- Compare retained and attrited customers across different characteristics

SELECT
    attrition_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_age), 2) AS avg_customer_age,
    ROUND(AVG(customer_tenure_months), 2) AS avg_tenure_months,
    ROUND(AVG(total_relationship_count), 2) AS avg_relationship_count,
    ROUND(AVG(months_inactive_12_mon), 2) AS avg_inactive_months,
    ROUND(AVG(total_trans_ct), 2) AS avg_transaction_count,
    ROUND(AVG(total_trans_amt), 2) AS avg_transaction_amount,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit,
    ROUND(AVG(total_revolving_bal), 2) AS avg_revolving_balance,
    ROUND(AVG(avg_utilization_ratio), 3) AS avg_utilization_ratio
FROM bank_data
GROUP BY attrition_status;

-- Section 3
-- Examine customer attrition based on number of relationships

SELECT
    total_relationship_count,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM bank_data
GROUP BY total_relationship_count
ORDER BY total_relationship_count;

SELECT
    CASE
        WHEN total_relationship_count <= 2 THEN 'Weak Relationship (1-2)'
        WHEN total_relationship_count = 3 THEN 'Moderate Relationship (3)'
        ELSE 'Strong Relationship (4-6)'
    END AS relationship_group,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM bank_data
GROUP BY relationship_group
ORDER BY attrition_rate_pct DESC;

-- Section 4
-- Explore the relationship between inactive months and attrition rate

SELECT
    months_inactive_12_mon,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM bank_data
GROUP BY months_inactive_12_mon
ORDER BY months_inactive_12_mon;

-- Explore the relationship between transaction count and churn

WITH transaction_quartiles AS (
    SELECT
        total_trans_ct,
        churned,
        NTILE(4) OVER (ORDER BY total_trans_ct) AS transaction_quartile
    FROM bank_data
)

SELECT
    transaction_quartile,
    MIN(total_trans_ct) AS min_transaction_count,
    MAX(total_trans_ct) AS max_transaction_count,
    ROUND(AVG(total_trans_ct), 1) AS avg_transaction_count,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM transaction_quartiles
GROUP BY transaction_quartile
ORDER BY transaction_quartile;

-- Explore the relationship between transaction count growth trend and churn

WITH transaction_change_quartiles AS (
    SELECT
        total_ct_chng_q4_q1,
        churned,
        NTILE(4) OVER (ORDER BY total_ct_chng_q4_q1) AS change_quartile
    FROM bank_data
)

SELECT
    change_quartile,
    MIN(total_ct_chng_q4_q1) AS min_change,
    MAX(total_ct_chng_q4_q1) AS max_change,
    ROUND(AVG(total_ct_chng_q4_q1), 3) AS avg_change,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM transaction_change_quartiles
GROUP BY change_quartile
ORDER BY change_quartile;

-- Explore the relationship between transaction amount and attrition

WITH transaction_amount_quartiles AS (
    SELECT
        total_trans_amt,
        churned,
        NTILE(4) OVER (ORDER BY total_trans_amt) AS amount_quartile
    FROM bank_data
)

SELECT
    amount_quartile,
    MIN(total_trans_amt) AS min_transaction_amount,
    MAX(total_trans_amt) AS max_transaction_amount,
    ROUND(AVG(total_trans_amt), 2) AS avg_transaction_amount,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM transaction_amount_quartiles
GROUP BY amount_quartile
ORDER BY amount_quartile;

-- Explore the relationship between transaction amount growth trend and attrition

WITH transaction_amount_change_quartiles AS (
    SELECT
        total_amt_chng_q4_q1,
        churned,
        NTILE(4) OVER (ORDER BY total_amt_chng_q4_q1) AS amount_change_quartile
    FROM bank_data
)

SELECT
    amount_change_quartile,
    MIN(total_amt_chng_q4_q1) AS min_amount_change,
    MAX(total_amt_chng_q4_q1) AS max_amount_change,
    ROUND(AVG(total_amt_chng_q4_q1), 3) AS avg_amount_change,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM transaction_amount_change_quartiles
GROUP BY amount_change_quartile
ORDER BY amount_change_quartile;

-- Explore credit utilization vs attrition

WITH utilization_quartiles AS (
    SELECT
        avg_utilization_ratio,
        churned,
        NTILE(4) OVER (ORDER BY avg_utilization_ratio) AS utilization_quartile
    FROM bank_data
)

SELECT
    utilization_quartile,
    MIN(avg_utilization_ratio) AS min_utilization,
    MAX(avg_utilization_ratio) AS max_utilization,
    ROUND(AVG(avg_utilization_ratio), 4) AS avg_utilization,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM utilization_quartiles
GROUP BY utilization_quartile
ORDER BY utilization_quartile;

-- Explore relationship between revolving balance and churn

WITH revolving_balance_quartiles AS (
    SELECT
        total_revolving_bal,
        churned,
        NTILE(4) OVER (ORDER BY total_revolving_bal) AS balance_quartile
    FROM bank_data
)

SELECT
    balance_quartile,
    MIN(total_revolving_bal) AS min_revolving_balance,
    MAX(total_revolving_bal) AS max_revolving_balance,
    ROUND(AVG(total_revolving_bal), 3) AS avg_revolving_balance,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM revolving_balance_quartiles
GROUP BY balance_quartile
ORDER BY balance_quartile;

-- Exploratory risk score

WITH risk_features AS (
    SELECT
        churned,
        total_relationship_count,

        NTILE(4) OVER (
            ORDER BY total_trans_ct
        ) AS transaction_quartile,

        NTILE(4) OVER (
            ORDER BY total_ct_chng_q4_q1
        ) AS transaction_change_quartile,

        NTILE(4) OVER (
            ORDER BY avg_utilization_ratio
        ) AS utilization_quartile

    FROM bank_data
),

risk_scores AS (
    SELECT
        churned,

        CASE
            WHEN total_relationship_count <= 2 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN transaction_quartile = 1 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN transaction_change_quartile = 1 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN utilization_quartile = 1 THEN 1
            ELSE 0
        END
        AS risk_signal_count

    FROM risk_features
)

SELECT
    risk_signal_count,
    COUNT(*) AS customer_count,
    SUM(churned) AS attrited_customers,
    ROUND(100.0 * AVG(churned), 2) AS attrition_rate_pct
FROM risk_scores
GROUP BY risk_signal_count
ORDER BY risk_signal_count;

-- Final assessment

WITH risk_features AS (
    SELECT
        customer_id,
        churned,
        total_relationship_count,
        total_trans_ct,
        total_ct_chng_q4_q1,
        avg_utilization_ratio,

        NTILE(4) OVER (
            ORDER BY total_trans_ct
        ) AS transaction_quartile,

        NTILE(4) OVER (
            ORDER BY total_ct_chng_q4_q1
        ) AS transaction_change_quartile,

        NTILE(4) OVER (
            ORDER BY avg_utilization_ratio
        ) AS utilization_quartile

    FROM bank_data
),

risk_scores AS (
    SELECT
        customer_id,
        churned,
        total_relationship_count,
        total_trans_ct,
        total_ct_chng_q4_q1,
        avg_utilization_ratio,

        CASE
            WHEN total_relationship_count <= 2 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN transaction_quartile = 1 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN transaction_change_quartile = 1 THEN 1
            ELSE 0
        END
        +
        CASE
            WHEN utilization_quartile = 1 THEN 1
            ELSE 0
        END AS risk_signal_count

    FROM risk_features
)

SELECT
    customer_id,
    risk_signal_count,
    total_relationship_count,
    total_trans_ct,
    total_ct_chng_q4_q1,
    avg_utilization_ratio
FROM risk_scores
WHERE churned = 0
    AND risk_signal_count >= 2
ORDER BY risk_signal_count DESC, total_trans_ct ASC;
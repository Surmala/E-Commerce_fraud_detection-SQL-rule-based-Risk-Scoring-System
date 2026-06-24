CREATE DATABASE fraud_db;
USE fraud_db;
DESCRIBE fraud_data;

SELECT database();
SELECT COUNT(*) FROM fraud_data;

-- class distribution
SELECT is_fraudulent , 
	COUNT(*) AS Count,
    ROUND(COUNT(*) *100.0/SUM(COUNT(*)) OVER() ,2)AS PCT
    FROM fraud_data
    GROUP BY is_fraudulent;
    
 -- customer age distribution
 SELECT
 MAX(customer_age) AS max_age,
 MIN(customer_age) AS min_age,
 ROUND(AVG(customer_age),1) as avg_age,
 COUNT(*) AS total_rows
 FROM fraud_data;
 
 -- Fraud rate by payment Method
 SELECT payment_method ,
 COUNT(*) AS total_txns,
 SUM(is_fraudulent) AS fraud_count,
 ROUND(SUM(is_fraudulent)*100.0 /COUNT(*) ,2) AS fraud_rate_pct
 FROM fraud_data
 GROUP BY payment_method
 ORDER BY fraud_rate_pct DESC;

-- Fraud rate  by product category
SELECT product_category,
COUNT(*) AS total_txns,
SUM(is_fraudulent) AS fraud_count,
ROUND(SUM(is_fraudulent) * 100.0 /COUNT(*) ,2) AS fraud_rate_pct
FROM fraud_data
GROUP BY product_category
ORDER BY fraud_rate_pct DESC;

-- fraud rate by device used
SELECT device_used,
COUNT(*) AS total_txns,
SUM(is_fraudulent) AS fraud_count,
ROUND(SUM(is_fraudulent)* 100.0 /COUNT(*),2) AS fraud_rate_pct
FROM fraud_data
GROUP BY device_used
ORDER BY fraud_rate_pct DESC;

-- fraud rate by Hour of day
SELECT transaction_hour,
COUNT(*) AS total_txxns,
SUM(is_fraudulent) AS fraud_count,
ROUND(SUM(is_fraudulent) * 100.0 /COUNT(*),2) AS fraud_rate_pct
FROM fraud_data
GROUP BY transaction_hour
ORDER BY transaction_hour;

-- Transaction Amount 
SELECT 
	is_fraudulent,
    ROUND(AVG(transaction_amount),2)AS avg_amount,
    ROUND(MIN(transaction_amount),2)AS min_amount,
    ROUND(MAX(transaction_amount),2)AS max_amount,
    ROUND(STDDEV(transaction_amount),2) AS std_amount
FROM fraud_data
GROUP BY is_fraudulent ;    
 
-- Account Age Buckets
SELECT 
	CASE
    WHEN account_age_days <30 THEN '0-30 days (new)'
	WHEN account_age_days <180 THEN '30-180 days'
     WHEN account_age_days <365 THEN '180-365 days'
     ELSE '365+ days(established)'
     END AS account_age_bucket,
     COUNT(*) AS total_txns,
     SUM(is_fraudulent)AS fraud_count,
     ROUND(SUM(is_fraudulent)* 100.0 /COUNT(*) ,2) AS fraud_rate_pct
     FROM fraud_data
 GROUP BY account_age_bucket
 ORDER BY fraud_rate_pct DESC;
 
 -- Monthly fraud Trend
 SELECT 
	DATE_FORMAT(transaction_date ,'%Y-%m')AS month,
    COUNT(*) AS total_txns,
    SUM(is_fraudulent) AS fraud_count,
    ROUND(SUM(is_fraudulent) * 100.0/COUNT(*) ,2)AS fraud_rate_pct
    FROM fraud_data
    GROUP BY month
    ORDER BY month;
 
 -- Financial Exposure
 SELECT 
	ROUND(SUM(CASE WHEN is_fraudulent =1 THEN transaction_amount ELSE 0 END),2) AS fraud_reveue_lost,
    ROUND(SUM(transaction_amount),2) AS total_revenue,
    ROUND(SUM(CASE WHEN is_fraudulent = 1 THEN transaction_amount ELSE 0 END) * 100.0 / SUM(transaction_amount),2)AS fraud_revenue_pct
    FROM fraud_data;
    
    -- Velocity check
    SELECT 
    customer_id,
    DATE(transaction_date)AS txn_date,
    COUNT(*) AS txn_count,
    SUM(transaction_amount) AS total_amount,
    SUM(is_fraudulent) AS fraud_txns
    FROM fraud_data
    GROUP BY customer_id ,DATE(transaction_date)
    HAVING COUNT(*) >=3
    ORDER BY txn_count DESC
    LIMIT 20;
    
    -- rule based risk scoring
    CREATE VIEW fraud_risk_scores AS
    SELECT 
		transaction_id,
        customer_id,
        transaction_amount,
        payment_method,
        product_category,
        transaction_hour,
        account_age_days,
        is_fraudulent,
        CASE WHEN transaction_amount >800 THEN 1 ELSE 0 END AS flag_high_amount,
        CASE WHEN account_age_days <30 THEN 1 ELSE 0 END AS flag_new_account,
        CASE WHEN transaction_hour BETWEEN 0 AND 5 THEN 1 ELSE 0 END AS flag_odd_hour,
        CASE WHEN payment_method ='credit card' THEN 1 ELSE 0 END AS flag_payment_method,
        CASE WHEN product_category = 'electronics' THEN 1 ELSE 0 END AS flag_category,
        (
        CASE WHEN transaction_amount > 800         THEN 1 ELSE 0 END +
        CASE WHEN account_age_days < 30            THEN 1 ELSE 0 END +
        CASE WHEN transaction_hour BETWEEN 0 AND 5 THEN 1 ELSE 0 END +
        CASE WHEN payment_method = 'credit card'   THEN 1 ELSE 0 END +
        CASE WHEN product_category = 'electronics' THEN 1 ELSE 0 END
    ) AS risk_score
    FROM fraud_data;


-- evaluating the scoring model
SELECT 
risk_score,
COUNT(*) AS total_txns,
SUM(is_fraudulent) AS actual_fraud,
ROUND(SUM(is_fraudulent)*100.0 /COUNT(*),2) AS fraud_rate_pct
FROM fraud_risk_scores
GROUP BY risk_score
ORDER BY risk_score DESC;

-- precision and recall at score 3+
SELECT
SUM(CASE WHEN risk_score >=3 AND is_fraudulent =1 THEN 1 ELSE 0 END) AS true_positive,
SUM(CASE WHEN risk_score >=3 AND is_fraudulent =0 THEN 1 ELSE 0 END) AS false_positive,
SUM(CASE WHEN risk_score <3 AND is_fraudulent =1 THEN 1 ELSE 0 END) AS false_negative,
SUM(CASE WHEN risk_score <3 AND is_fraudulent =0 THEN 1 ELSE 0 END) AS true_negative,

ROUND(SUM(CASE WHEN risk_score >=3 AND is_fraudulent =1 THEN 1 ELSE 0 END) *100.0 /
	NULLIF(SUM(CASE WHEN risk_score >=3 THEN 1 ELSE 0 END ) ,0),2) AS precision_pct,
    
    ROUND(SUM(CASE WHEN risk_score >=3 AND is_fraudulent =1 THEN 1 ELSE 0 END)*100.0 / NULLIF(SUM(is_fraudulent),0),2)AS recall_pct
    FROM fraud_risk_scores;

-- top high risk transactions for review queue
SELECT 
	transaction_id,
    transaction_amount,
    payment_method,
    product_category,
    transaction_hour,
    account_age_days,
    risk_score,
    is_fraudulent
FROM fraud_risk_scores
WHERE risk_score >=4
ORDER BY transaction_amount DESC
LIMIT 10;    
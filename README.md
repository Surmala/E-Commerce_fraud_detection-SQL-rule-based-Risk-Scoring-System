# E-Commerce Fraud Detection — SQL Rule-Based Risk Scoring System

## Overview
Analyzed 1.49 million e-commerce transactions across two source files to identify 
fraudulent activity using SQL-based exploratory analysis and a rule-based risk 
scoring system. This project mirrors the approach a fraud analyst or compliance 
analyst would take in a real banking or fintech environment.
---------------
## Dataset
- Source: Fraudulent E-Commerce Transactions (Kaggle) https://www.kaggle.com/datasets/shriyashjagtap/fraudulent-e-commerce-transactions
- Size: 1,496,586 transactions across 2 files
- Features: 16 columns including transaction amount, payment method, product 
  category, device used, customer age, account age, transaction hour
- Target Variable: is_fraudulent (1 = fraud, 0 = legitimate)

---
## Tools Used
- Python (Pandas) — data ingestion, cleaning, column standardisation
- SQLAlchemy — ETL pipeline from Python to MySQL
- MySQL — all EDA, fraud pattern analysis, risk scoring, evaluation
- Power BI (planned) — fraud monitoring dashboard on top of SQL views

---
## Project Workflow

### 1. Data Ingestion (Python)
- Loaded both CSV files and combined into a single dataframe of 1.49M rows
- Standardised column names — lowercased, spaces replaced with underscores
- Applied business rule: removed all accounts where customer_age < 18 as minors 
  are not valid account holders in financial and e-commerce platforms
- Loaded cleaned data into MySQL via SQLAlchemy using engine.begin() for 
  reliable transaction commit
  
### 2. Exploratory Data Analysis (MySQL)
Investigated fraud patterns across multiple dimensions:

- Class distribution — confirmed 95% legitimate, 5% fraud (class imbalance)
- Payment method — identified which methods carry highest fraud rate
- Product category — identified high-risk categories
- Device used — compared fraud rates across mobile, desktop, tablet
- Transaction hour — identified peak fraud hours (late night window)
- Transaction amount — compared average and distribution for fraud vs legitimate
- Account age — new accounts (under 30 days) showed significantly higher fraud rates
- Monthly trend — tracked fraud rate over time to identify seasonal patterns
- Financial exposure — quantified total revenue lost to fraud in dollar terms

### 3. Velocity Check
Flagged customers making 3 or more transactions in a single day — a standard 
fraud signal used by banks to detect card testing and smash-and-grab behaviour.

### 4. Rule-Based Risk Scoring
Built a MySQL VIEW (fraud_risk_scores) assigning each transaction a risk score 
from 0 to 5 based on EDA findings:  
| Rule | Signal |
|---|---|
| flag_high_amount | Transaction amount above 800 |
| flag_new_account | Account age under 30 days |
| flag_odd_hour | Transaction between midnight and 5am |
| flag_payment_method | Highest fraud rate payment method from EDA |
| flag_category | Highest fraud rate product category from EDA |

Thresholds were set based on actual EDA findings, not arbitrary values.
### 5. Model Evaluation
Evaluated scoring model at threshold score >= 3 using:
- True Positives, False Positives, False Negatives, True Negatives
- Precision — of all flagged transactions, how many were actual fraud
- Recall — of all actual fraud, how many did the model catch

Recall was prioritised over precision as missed fraud carries higher business 
cost than a false flag requiring manual review.

### 6. Review Queue
Generated a prioritised list of transactions scoring 4 or 5 — the operational 
output a fraud ops team would action daily for manual investigation.

---

## Key Findings

- Overall fraud rate: 5% across 1.43M transactions
- Highest fraud rate payment method: range 4.97% to 5.03% -bank transfer
- Highest fraud rate product category:4.95% to 5.04%  -clothing
- Peak fraud hour window: Midnight to 5am — consistently ~10% fraud rate 
- New accounts (under 30 days) fraud rate: 22.35% fraud rate
- Total revenue lost to fraud: $39.28M of $324.32M total — 12.11%
- Scoring model recall at threshold 3:  18.74% at threshold score 3 
- Scoring model precision at threshold 3: 27.98% at threshold score 3

---

## Business Impact
The rule-based scoring system produces an auditable, explainable fraud flag for 
every transaction — critical in regulated banking environments where black-box 
models face compliance scrutiny. The review queue output directly reduces 
investigator workload by prioritising highest-risk transactions rather than 
requiring manual review of all flagged activity.

---

## Limitations
- Rule thresholds are static and require periodic recalibration as fraud patterns evolve
- No real-time scoring element — batch analysis only
- No cost-benefit analysis of false positive rate vs investigator capacity
- A next step would be integrating this scoring view into Power BI for a live 
  fraud monitoring dashboard

---

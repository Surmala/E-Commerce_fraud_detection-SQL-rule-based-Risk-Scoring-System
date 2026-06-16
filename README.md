# E-Commerce Fraud Detection — SQL Rule-Based Risk Scoring System

## Overview
Analyzed 1.49 million e-commerce transactions across two source files to identify 
fraudulent activity using SQL-based exploratory analysis and a rule-based risk 
scoring system. This project mirrors the approach a fraud analyst or compliance 
analyst would take in a real banking or fintech environment.
---------------
## Dataset
- Source: Fraudulent E-Commerce Transactions (Kaggle)
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

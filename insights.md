# Fraud Detection — Insights & Interpretation

## What the Data Is Actually Telling Us

### 1. Account Age Is the Strongest Fraud Signal
New accounts under 30 days show a 22.35% fraud rate compared to 3.48% 
for established accounts over a year old — a 6.4x difference. This is 
the single most actionable finding in the dataset. In a real fraud ops 
environment, any transaction from an account under 30 days old should 
automatically trigger enhanced review, regardless of other factors.

### 2. Fraudsters Spend More
Fraudulent transactions average $548 compared to $209 for legitimate 
ones — 2.6x higher. This tells us fraudsters are not testing cards with 
small amounts in this dataset. They are going straight for high-value 
purchases, which makes transaction amount a reliable secondary signal 
when combined with account age.

### 3. Late Night Transactions Are Consistently Risky
Fraud rate sits around 10% between midnight and 5am — roughly double 
the overall 5% baseline. This is a well-known fraud pattern globally — 
fraudsters operate during off-peak hours when human review teams are 
smaller and automated flags are less likely to trigger immediate action.

### 4. Payment Method and Device Tell Us Nothing Here
Bank transfer, debit card, PayPal, and credit card all cluster between 
4.97% and 5.03%. Mobile, tablet, and desktop are similarly flat between 
4.98% and 5.06%. In this dataset, these dimensions carry no predictive 
value. A real fraud team would deprioritise these as scoring signals and 
focus resources on account age and transaction amount instead.

### 5. Fraud Is Stable — Not Seasonal
Monthly fraud rate holds steady at approximately 5% across all months 
in 2024. There are no holiday spikes or campaign-driven surges visible 
in this data. This suggests the fraud in this dataset reflects systematic 
behaviour rather than opportunistic event-driven attacks.

### 6. The Financial Exposure Is Significant
$39.28M lost to fraud out of $324.32M total revenue — 12.11%. For 
context, most e-commerce platforms target fraud loss rates below 1%. 
A 12% loss rate would be a critical business problem requiring immediate 
intervention, making this dataset a realistic simulation of a company 
under active fraud pressure.

### 7. The Scoring Model Needs Improvement
At threshold score 3, the rule-based model achieves 27.98% precision 
and 18.74% recall. This means it catches roughly 1 in 5 actual fraud 
cases and generates significant false positives. The low performance is 
expected — payment method and device carried no signal, so two of the 
five scoring rules added noise rather than value. A revised model 
dropping those two rules and adding a high transaction amount flag 
weighted more heavily would likely improve recall meaningfully.

## What a Fraud Team Would Do Next
- Implement an automatic hold on all transactions from accounts under 
  30 days old exceeding $400 in value
- Flag all transactions between midnight and 5am for next-day review 
  regardless of other signals
- Recalibrate the scoring model by removing payment method and device 
  flags and replacing with a combined account age + transaction amount 
  composite rule
- Set up monthly model performance tracking — precision and recall 
  should be recalculated every 30 days as fraud patterns evolve

-- 1) Find all transactions with cardholder details.
SELECT t.id AS transaction_id, t.date, t.amount,
	   c.card AS card_number, ch.id AS card_holder_id, ch.name AS card_holder_name
FROM transaction t
JOIN credit_card c ON t.card=c.card
JOIN card_holder ch ON c.id_card_holder = ch.id;

-- 2) Find the total amount spent by each cardholder.
SELECT ch.id AS card_holder_id, ch.name AS card_holder_name,
       SUM(t.amount) AS total_spent
FROM transaction t 
JOIN credit_card c ON t.card = c.card
JOIN card_holder ch ON c.id_card_holder = ch.id
GROUP BY ch.id, ch.name
ORDER BY total_spent DESC;

-- 3) List transactions with merchant details.
SELECT t.id AS transaction_id, t.date, t.amount,
       m.name AS merchant_name, mc.name AS merchant_category
FROM transaction t 
JOIN merchant m ON t.id_merchant = m.id
JOIN merchant_category mc ON m.id_merchant_category = mc.id;

-- 4) Find the highest transaction amount per card holder.
SELECT ch.id AS card_holder_id, ch.name AS card_holder_name,
       MAX(t.amount) AS max_transaction
FROM transaction t
JOIN credit_card c ON t.card = c.card
JOIN card_holder ch ON c.id_card_holder = ch.id
GROUP BY ch.id,ch.name
ORDER BY max_transaction DESC;

-- 5) Find the most used merchant category.
SELECT mc.name AS merchant_category, COUNT(t.id) AS total_transactions
FROM transaction t
JOIN merchant m ON t.id_merchant = m.id
JOIN merchant_category mc ON m.id_merchant_category = mc.id
GROUP BY mc.name
ORDER BY total_transactions DESC LIMIT 1;

-- 6) Find transactions above a certain threshold($500).
SELECT t.id AS transaction_id, t.date, t.amount,
       ch.name AS card_holder_name, m.name AS merchant_name
FROM transaction t 
JOIN credit_card c ON t.card = c.card
JOIN card_holder ch ON c.id_card_holder = ch.id
JOIN merchant m ON t.id_merchant = m.id
WHERE t.amount > 500
ORDER BY t.amount DESC;

-- 7) Find card holder who have never made a transaction. 
SELECT ch.id AS card_holder_id, ch.name AS card_holder_name
FROM card_holder ch
LEFT JOIN credit_card c ON ch.id = c.id_card_holder
LEFT JOIN transaction t ON c.card = t.card
WHERE t.id IS NULL;

-- 8) Find the number of transactions per merchant.
SELECT m.name AS merchant_name, COUNT(t.id) AS total_transactions
FROM transaction t
JOIN merchant m ON t.id_merchant = m.id
GROUP BY m.name
ORDER BY total_transactions DESC;

-- 9) Find the merchant with the highest total transaction amount. 
SELECT m.name AS merchant_name, SUM(t.amount) AS total_revenue
FROM transaction t
JOIN merchant m ON t.id_merchant = m.id
GROUP BY m.name
ORDER BY total_revenue DESC
LIMIT 1;

-- 10) Find the average transaction amount per card holder. 
SELECT ch.id AS card_holder_id, ch.name AS card_holder_name, 
       AVG(t.amount) AS avg_transaction_amount
FROM transaction t
JOIN credit_card c ON t.card = c.card
JOIN card_holder ch ON c.id_card_holder = ch.id
GROUP BY ch.id, ch.name
ORDER BY avg_transaction_amount DESC;

-- 11) Detect the most fraudulent transactions by cardholder.
SELECT ch.id AS card_holder_id, ch.name AS card_holder_name, 
       COUNT(t.id) AS total_suspicious_transactions, 
       SUM(t.amount) AS total_fraud_amount
FROM transaction t
JOIN credit_card c ON t.card = c.card
JOIN card_holder ch ON c.id_card_holder = ch.id
WHERE t.amount > (SELECT AVG(amount) * 3 FROM transaction)  -- Transactions 3x higher than avg
   OR t.card IN ( -- check if card has more than 5 transactions in a short time 
       SELECT card 
       FROM transaction 
       GROUP BY card, date -- ensure grouping by card & date 
       HAVING COUNT(id) > 5 
   )
GROUP BY ch.id, ch.name
ORDER BY total_suspicious_transactions DESC, total_fraud_amount DESC
LIMIT 5;

-- 12) Identifying transactions at unsual hours(e.g., Midnight to 4 AM)
SELECT t.id, t.card, ch.name AS card_holder, t.amount, t.date
FROM transaction t
JOIN credit_card cc ON t.card = cc.card
JOIN card_holder ch ON cc.id_card_holder = ch.id
WHERE HOUR(t.date) BETWEEN 0 AND 4;

-- 13) identifying high - risk merchant categories 
SELECT mc.name AS merchant_category, COUNT(t.id) AS transaction_count
FROM transaction t
JOIN merchant m ON t.id_merchant = m.id
JOIN merchant_category mc ON m.id_merchant_category = mc.id
GROUP BY mc.name
ORDER BY transaction_count DESC
LIMIT 10;

-- 14) Detecting  repeatedly disputed transactions(If disputed data exists)
SELECT t.card, ch.name AS card_holder, COUNT(t.id) AS dispute_count
FROM transaction t
JOIN credit_card cc ON t.card = cc.card
JOIN card_holder ch ON cc.id_card_holder = ch.id
WHERE t.id IN (SELECT id FROM transaction)  -- Assuming a transactions table exists
GROUP BY t.card, ch.name
ORDER BY dispute_count DESC;

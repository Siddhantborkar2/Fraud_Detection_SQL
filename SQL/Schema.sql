-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/s8Wnqm

--Card Holder
CREATE TABLE card_holder(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Credit Card
CREATE TABLE credit_card(
    card VARCHAR(20) NOT NULL PRIMARY KEY,
    id_card_holder INT NOT NULL
);

-- Merchant
  CREATE TABLE merchant(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    id_merchant_category INT NOT NULL
);

-- Merchant Category
CREATE TABLE merchant_category(
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Transaction
CREATE TABLE transaction(
    id INT NOT NULL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    amount FLOAT NOT NULL,
    card VARCHAR(20) NOT NULL,
    id_merchant INT NOT NULL
);

ALTER TABLE credit_card ADD CONSTRAINT FOREIGN KEY(id_card_holder) REFERENCES card_holder(id);

ALTER TABLE merchant ADD CONSTRAINT FOREIGN KEY(id_merchant_category) REFERENCES merchant_category(id);

ALTER TABLE transaction ADD CONSTRAINT FOREIGN KEY(card) REFERENCES credit_card(card);

ALTER TABLE transaction ADD CONSTRAINT FOREIGN KEY(id_merchant) REFERENCES merchant (id);




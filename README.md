# 💊 Pharmacy Management System

A database-driven **Pharmacy Management System** developed using **Oracle SQL and PL/SQL** to manage medicine inventory, process sales, generate customer bills, maintain stock levels, and calculate sales revenue.

## 📌 Project Overview

The Pharmacy Management System automates essential pharmacy operations using relational database tables, PL/SQL procedures, sequences, constraints, and exception handling. It ensures that expired medicines and sales exceeding available stock are rejected.

## ✨ Features

- **Medicine Inventory Management** — Store medicine IDs, names, categories, prices, stock quantities, and expiry dates.
- **Medicine Availability** — Display medicines that are in stock and have not expired.
- **User Input** — Accept medicine ID, quantity, and customer name during a sale.
- **Medicine Sales** — Process transactions through a reusable PL/SQL stored procedure.
- **Automatic Bill Generation** — Calculate the total bill and display a formatted sales receipt.
- **Stock Management** — Automatically reduce inventory after a successful sale.
- **Expiry Validation** — Prevent the sale of expired medicines.
- **Stock Validation** — Reject transactions when sufficient stock is unavailable.
- **Input Validation** — Validate customer names and positive whole-number quantities.
- **Exception Handling** — Handle invalid medicine IDs and other transaction errors.
- **Sales Reports** — Display transaction details, total units sold, and total revenue.

## 🛠️ Technologies Used

- **Database:** Oracle Database
- **Query Language:** SQL
- **Procedural Language:** PL/SQL
- **Database Objects:** Tables, sequences, stored procedures, constraints
- **Reporting:** SQL queries and `DBMS_OUTPUT`

## 🗄️ Database Design

### 1. MEDICINES

Stores medicine inventory information.

| Column | Description |
|---|---|
| MEDICINE_ID | Unique medicine identifier and primary key |
| MEDICINE_NAME | Name of the medicine |
| CATEGORY | Medicine category |
| PRICE | Price per unit |
| STOCK_QUANTITY | Available stock |
| EXPIRY_DATE | Medicine expiry date |

### 2. PHARMACY_SALES

Stores completed sales transactions.

| Column | Description |
|---|---|
| SALE_ID | Unique transaction ID |
| MEDICINE_ID | Reference to the medicine sold |
| QUANTITY | Number of units sold |
| UNIT_PRICE | Price per unit at the time of sale |
| TOTAL_AMOUNT | Total bill amount |
| SALE_DATE | Date and time of sale |
| CUSTOMER_NAME | Customer's name |

### 3. SEQ_SALE

An Oracle sequence used to generate unique sale IDs automatically.

## ⚙️ How It Works

1. Create the medicine and sales tables.
2. Create the sales sequence.
3. Insert sample medicine records.
4. Execute the `SELL_MEDICINE` stored procedure.
5. Enter the medicine ID, quantity, and customer name.
6. Validate the input, expiry date, and available stock.
7. Calculate the bill and record the transaction.
8. Update the remaining stock.
9. Display the sales receipt.
10. Run SQL queries to review inventory, sales, and revenue.

## ▶️ How to Run the Project

### Prerequisites

- Oracle Database
- Oracle SQL Developer or Oracle SQL*Plus
- Basic knowledge of SQL and PL/SQL

### Step 1: Open Your SQL Environment

Connect to your Oracle database using SQL Developer or SQL*Plus.

### Step 2: Enable Output

Run the following command to display the generated bill:

```sql
SET SERVEROUTPUT ON;
```

In Oracle SQL Developer, you can also enable the **DBMS Output** panel for your database connection.

### Step 3: Execute the SQL Script

Run the script in the following order:

1. Create the `MEDICINES` table.
2. Create the `PHARMACY_SALES` table.
3. Create the `SEQ_SALE` sequence.
4. Insert the sample medicine data.
5. Create the `SELL_MEDICINE` procedure.
6. Execute the inventory and sales queries as required.

Execute the entire setup script before running the interactive sale block.

### Step 4: Sell a Medicine

Example input:

- Medicine ID: `101`
- Quantity: `2`
- Customer Name: `Rahul Sharma`

Execute:

```sql
BEGIN
    SELL_MEDICINE(
        &medicine_id,
        &quantity,
        '&customer_name'
    );
END;
/
```

When prompted, enter the values above.

The system calculates the bill, records the sale, updates the medicine stock, and prints the receipt.

### Step 5: View Reports

**View available medicines:**

```sql
SELECT *
FROM MEDICINES
WHERE STOCK_QUANTITY > 0
  AND EXPIRY_DATE >= TRUNC(SYSDATE)
ORDER BY MEDICINE_ID;
```

**View all sales:**

```sql
SELECT
    S.SALE_ID,
    S.CUSTOMER_NAME,
    M.MEDICINE_NAME,
    S.QUANTITY,
    S.UNIT_PRICE,
    S.TOTAL_AMOUNT,
    S.SALE_DATE
FROM PHARMACY_SALES S
JOIN MEDICINES M
    ON S.MEDICINE_ID = M.MEDICINE_ID
ORDER BY S.SALE_ID;
```

**Calculate sales revenue:**

```sql
SELECT
    COUNT(*) AS TOTAL_TRANSACTIONS,
    NVL(SUM(QUANTITY), 0) AS TOTAL_UNITS_SOLD,
    NVL(SUM(TOTAL_AMOUNT), 0) AS TOTAL_REVENUE
FROM PHARMACY_SALES;
```

## 🧠 SQL and PL/SQL Concepts Demonstrated

- DDL — `CREATE TABLE`, `CREATE SEQUENCE`
- DML — `INSERT`, `UPDATE`
- Data integrity — Primary keys, foreign keys, `NOT NULL`, and `CHECK` constraints
- PL/SQL — Variables, conditional statements, and stored procedures
- Exception handling — `NO_DATA_FOUND`, `WHEN OTHERS`, and `RAISE_APPLICATION_ERROR`
- Transactions — `COMMIT` and `ROLLBACK`
- Concurrency control — `SELECT ... FOR UPDATE`
- Reporting — Aggregate functions, joins, filtering, and sorting

## 📊 Sample Data

The project includes five sample medicines:

| Medicine ID | Medicine Name | Price (₹) | Initial Stock |
|---:|---|---:|---:|
| 101 | Paracetamol | 20.00 | 100 |
| 102 | Cetirizine | 35.00 | 50 |
| 103 | Vitamin C | 80.00 | 40 |
| 104 | Cough Syrup | 120.00 | 25 |
| 105 | Antacid | 45.00 | 0 |

## 🚀 Future Enhancements

- Add medicine purchase and restocking functionality.
- Generate daily, monthly, and category-wise sales reports.
- Add low-stock alerts.
- Track medicines nearing their expiry dates.
- Introduce supplier and purchase management.
- Add customer records and sales history.
- Develop a graphical user interface for easier operation.

## 🎯 Learning Outcomes

This project demonstrates practical implementation of relational database design, Oracle SQL queries, PL/SQL programming, transaction management, exception handling, inventory control, and sales reporting.

It is suitable as an academic DBMS/PL-SQL project and as a beginner database development portfolio project.

---

**Project:** Pharmacy Management System  
**Technology:** Oracle SQL and PL/SQL  
**Category:** Database Management System (DBMS)  

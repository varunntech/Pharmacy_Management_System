-- ============================================================
-- PROJECT: PHARMACY MANAGEMENT SYSTEM
-- TECHNOLOGY: ORACLE SQL AND PL/SQL
-- FEATURES:
-- 1. Medicine Inventory
-- 2. User Input
-- 3. Medicine Sales
-- 4. Bill Generation
-- 5. Stock Management
-- 6. Exception Handling
-- 7. Sales Reports
-- ============================================================


-- ============================================================
-- 1. CREATE MEDICINES TABLE
-- ============================================================

CREATE TABLE MEDICINES (
    MEDICINE_ID NUMBER PRIMARY KEY,
    MEDICINE_NAME VARCHAR2(100) NOT NULL,
    CATEGORY VARCHAR2(50),
    PRICE NUMBER(10,2) NOT NULL,
    STOCK_QUANTITY NUMBER DEFAULT 0 NOT NULL,
    EXPIRY_DATE DATE NOT NULL,
    CONSTRAINT CHK_MED_PRICE CHECK (PRICE >= 0),
    CONSTRAINT CHK_MED_STOCK CHECK (STOCK_QUANTITY >= 0)
);


-- ============================================================
-- 2. CREATE PHARMACY SALES TABLE
-- ============================================================

CREATE TABLE PHARMACY_SALES (
    SALE_ID NUMBER PRIMARY KEY,
    MEDICINE_ID NUMBER REFERENCES MEDICINES(MEDICINE_ID),
    QUANTITY NUMBER NOT NULL,
    UNIT_PRICE NUMBER(10,2) NOT NULL,
    TOTAL_AMOUNT NUMBER(10,2) NOT NULL,
    SALE_DATE DATE DEFAULT SYSDATE,
    CUSTOMER_NAME VARCHAR2(100) NOT NULL,
    CONSTRAINT CHK_SALE_QTY CHECK (QUANTITY > 0)
);


-- ============================================================
-- 3. CREATE SEQUENCE FOR SALES
-- ============================================================

CREATE SEQUENCE SEQ_SALE
START WITH 1
INCREMENT BY 1;


-- ============================================================
-- 4. INSERT SAMPLE MEDICINE DATA
-- ============================================================

INSERT INTO MEDICINES
VALUES (101, 'Paracetamol', 'Tablet', 20, 100,
        DATE '2027-12-31');

INSERT INTO MEDICINES
VALUES (102, 'Cetirizine', 'Tablet', 35, 50,
        DATE '2027-10-31');

INSERT INTO MEDICINES
VALUES (103, 'Vitamin C', 'Supplement', 80, 40,
        DATE '2028-06-30');

INSERT INTO MEDICINES
VALUES (104, 'Cough Syrup', 'Syrup', 120, 25,
        DATE '2027-08-31');

INSERT INTO MEDICINES
VALUES (105, 'Antacid', 'Tablet', 45, 0,
        DATE '2027-11-30');

COMMIT;


-- ============================================================
-- 5. PROCEDURE TO SELL MEDICINE AND GENERATE BILL
-- ============================================================

CREATE OR REPLACE PROCEDURE SELL_MEDICINE (
    P_MEDICINE_ID IN NUMBER,
    P_QUANTITY IN NUMBER,
    P_CUSTOMER_NAME IN VARCHAR2
)
AS
    V_MEDICINE_NAME MEDICINES.MEDICINE_NAME%TYPE;
    V_PRICE MEDICINES.PRICE%TYPE;
    V_STOCK MEDICINES.STOCK_QUANTITY%TYPE;
    V_EXPIRY_DATE MEDICINES.EXPIRY_DATE%TYPE;
    V_SALE_ID PHARMACY_SALES.SALE_ID%TYPE;
    V_TOTAL NUMBER(10,2);
BEGIN

    -- Validate quantity

    IF P_QUANTITY IS NULL
       OR P_QUANTITY <= 0
       OR P_QUANTITY <> TRUNC(P_QUANTITY) THEN

        RAISE_APPLICATION_ERROR(
            -20001,
            'Quantity must be a positive whole number.'
        );

    END IF;


    -- Validate customer name

    IF P_CUSTOMER_NAME IS NULL
       OR TRIM(P_CUSTOMER_NAME) IS NULL THEN

        RAISE_APPLICATION_ERROR(
            -20002,
            'Customer name cannot be empty.'
        );

    END IF;


    -- Retrieve medicine details and lock the row

    SELECT MEDICINE_NAME,
           PRICE,
           STOCK_QUANTITY,
           EXPIRY_DATE
    INTO V_MEDICINE_NAME,
         V_PRICE,
         V_STOCK,
         V_EXPIRY_DATE
    FROM MEDICINES
    WHERE MEDICINE_ID = P_MEDICINE_ID
    FOR UPDATE;


    -- Check expiry date

    IF V_EXPIRY_DATE < TRUNC(SYSDATE) THEN

        RAISE_APPLICATION_ERROR(
            -20003,
            'Expired medicine cannot be sold.'
        );

    END IF;


    -- Check stock availability

    IF V_STOCK < P_QUANTITY THEN

        RAISE_APPLICATION_ERROR(
            -20004,
            'Insufficient stock available.'
        );

    END IF;


    -- Calculate bill

    V_TOTAL := V_PRICE * P_QUANTITY;


    -- Generate sale ID

    V_SALE_ID := SEQ_SALE.NEXTVAL;


    -- Insert sale details

    INSERT INTO PHARMACY_SALES (
        SALE_ID,
        MEDICINE_ID,
        QUANTITY,
        UNIT_PRICE,
        TOTAL_AMOUNT,
        SALE_DATE,
        CUSTOMER_NAME
    )
    VALUES (
        V_SALE_ID,
        P_MEDICINE_ID,
        P_QUANTITY,
        V_PRICE,
        V_TOTAL,
        SYSDATE,
        TRIM(P_CUSTOMER_NAME)
    );


    -- Update medicine stock

    UPDATE MEDICINES
    SET STOCK_QUANTITY = STOCK_QUANTITY - P_QUANTITY
    WHERE MEDICINE_ID = P_MEDICINE_ID;


    COMMIT;


    -- Display bill

    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('       PHARMACY MANAGEMENT SYSTEM       ');
    DBMS_OUTPUT.PUT_LINE('              SALES RECEIPT             ');
    DBMS_OUTPUT.PUT_LINE('========================================');

    DBMS_OUTPUT.PUT_LINE('Sale ID        : ' || V_SALE_ID);
    DBMS_OUTPUT.PUT_LINE('Customer Name  : ' || TRIM(P_CUSTOMER_NAME));
    DBMS_OUTPUT.PUT_LINE('Medicine ID    : ' || P_MEDICINE_ID);
    DBMS_OUTPUT.PUT_LINE('Medicine Name  : ' || V_MEDICINE_NAME);
    DBMS_OUTPUT.PUT_LINE('Quantity       : ' || P_QUANTITY);

    DBMS_OUTPUT.PUT_LINE(
        'Price Per Unit : Rs. ' ||
        TO_CHAR(V_PRICE, 'FM9999990.00')
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    DBMS_OUTPUT.PUT_LINE(
        'TOTAL BILL     : Rs. ' ||
        TO_CHAR(V_TOTAL, 'FM9999990.00')
    );

    DBMS_OUTPUT.PUT_LINE(
        'Remaining Stock: ' || (V_STOCK - P_QUANTITY)
    );

    DBMS_OUTPUT.PUT_LINE('Status         : SUCCESSFUL');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Thank you for visiting our pharmacy!');
    DBMS_OUTPUT.PUT_LINE('========================================');


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;

        RAISE_APPLICATION_ERROR(
            -20005,
            'Medicine ID does not exist.'
        );

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

END SELL_MEDICINE;
/

 
-- ============================================================
-- 6. DISPLAY AVAILABLE MEDICINES
-- ============================================================

SELECT
    MEDICINE_ID,
    MEDICINE_NAME,
    CATEGORY,
    PRICE,
    STOCK_QUANTITY,
    EXPIRY_DATE
FROM MEDICINES
WHERE STOCK_QUANTITY > 0
  AND EXPIRY_DATE >= TRUNC(SYSDATE)
ORDER BY MEDICINE_ID;


-- ============================================================
-- 7. TAKE USER INPUT AND SELL MEDICINE
-- Enter medicine ID, quantity, and customer name when prompted.
-- Example: 101, 2, Rahul Sharma
-- ============================================================

BEGIN
    SELL_MEDICINE(
        &medicine_id,
        &quantity,
        '&customer_name'
    );
END;
/


-- ============================================================
-- 8. DISPLAY UPDATED MEDICINE STOCK
-- ============================================================

SELECT
    MEDICINE_ID,
    MEDICINE_NAME,
    STOCK_QUANTITY,
    PRICE
FROM MEDICINES
ORDER BY MEDICINE_ID;


-- ============================================================
-- 9. DISPLAY ALL SALES
-- ============================================================

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


-- ============================================================
-- 10. CALCULATE TOTAL REVENUE
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_TRANSACTIONS,
    NVL(SUM(QUANTITY), 0) AS TOTAL_UNITS_SOLD,
    NVL(SUM(TOTAL_AMOUNT), 0) AS TOTAL_REVENUE
FROM PHARMACY_SALES;
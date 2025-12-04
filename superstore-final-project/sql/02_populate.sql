-- 02_populate.sql
-- Нормализация данных из Raw_Superstore в схему Superstore

USE superstore_db;

------------------------------------------------------------
-- Чистим нормализованные таблицы перед повторным заполнением
------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Order_Items;
TRUNCATE TABLE Orders;
TRUNCATE TABLE Products;
TRUNCATE TABLE Customers;
TRUNCATE TABLE Locations;

SET FOREIGN_KEY_CHECKS = 1;

------------------------------------------------------------
-- Customers
------------------------------------------------------------
INSERT INTO Customers (Customer_ID, Customer_Name, Segment)
SELECT DISTINCT
    TRIM(Customer_ID)       AS Customer_ID,
    Customer_Name,
    Segment
FROM Raw_Superstore
WHERE Customer_ID IS NOT NULL
  AND TRIM(Customer_ID) <> '';

------------------------------------------------------------
-- Locations
-- Используем GROUP BY, чтобы избежать дублей по Postal_Code
------------------------------------------------------------
INSERT INTO Locations (Postal_Code, City, State, Country, Region)
SELECT
    Postal_Code,
    MAX(City)    AS City,
    MAX(State)   AS State,
    MAX(Country) AS Country,
    MAX(Region)  AS Region
FROM Raw_Superstore
WHERE Postal_Code IS NOT NULL
GROUP BY Postal_Code;

------------------------------------------------------------
-- Products
-- Убираем дубли по Product_ID, берём одну версию записи
------------------------------------------------------------
INSERT INTO Products (Product_ID, Category, Sub_Category, Product_Name)
SELECT
    TRIM(Product_ID)          AS Product_ID,
    MAX(Category)     AS Category,
    MAX(Sub_Category) AS Sub_Category,
    MAX(Product_Name) AS Product_Name
FROM Raw_Superstore
WHERE Product_ID IS NOT NULL
  AND TRIM(Product_ID) <> ''
GROUP BY TRIM(Product_ID);

------------------------------------------------------------
-- Orders
-- Конвертируем строки дат в тип DATE
------------------------------------------------------------
INSERT INTO Orders (Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code)
SELECT DISTINCT
    TRIM(Order_ID)                                        AS Order_ID,
    STR_TO_DATE(Order_Date, '%m/%d/%Y')                   AS Order_Date,
    STR_TO_DATE(Ship_Date, '%m/%d/%Y')                    AS Ship_Date,
    Ship_Mode,
    TRIM(Customer_ID)                                     AS Customer_ID,
    Postal_Code
FROM Raw_Superstore
WHERE Order_ID IS NOT NULL
  AND TRIM(Order_ID) <> '';

------------------------------------------------------------
-- Order_Items
------------------------------------------------------------
INSERT INTO Order_Items (Row_ID, Order_ID, Product_ID, Sales, Quantity, Discount, Profit)
SELECT
    Row_ID,
    TRIM(Order_ID)    AS Order_ID,
    TRIM(Product_ID)  AS Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit
FROM Raw_Superstore
WHERE Order_ID IS NOT NULL
  AND Product_ID IS NOT NULL
  AND TRIM(Order_ID) <> ''
  AND TRIM(Product_ID) <> '';

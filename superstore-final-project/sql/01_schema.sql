-- 01_schema.sql
-- Создание базы данных и схемы Superstore

CREATE DATABASE IF NOT EXISTS superstore_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE superstore_db;

-- На всякий случай: очищаем старые таблицы, если файл запускают повторно
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS Raw_Superstore;

SET FOREIGN_KEY_CHECKS = 1;

------------------------------------------------------------
-- RAW STAGING TABLE
-- Сюда импортируется CSV "Sample - Superstore.csv"
------------------------------------------------------------
CREATE TABLE Raw_Superstore (
    Row_ID       INT           NOT NULL,
    Order_ID     VARCHAR(50),
    Order_Date   VARCHAR(20),
    Ship_Date    VARCHAR(20),
    Ship_Mode    VARCHAR(50),
    Customer_ID  VARCHAR(50),
    Customer_Name VARCHAR(255),
    Segment      VARCHAR(50),
    Country      VARCHAR(100),
    City         VARCHAR(100),
    State        VARCHAR(100),
    Postal_Code  VARCHAR(20),
    Region       VARCHAR(50),
    Product_ID   VARCHAR(50),
    Category     VARCHAR(100),
    Sub_Category VARCHAR(100),
    Product_Name VARCHAR(255),
    Sales        DECIMAL(10,2),
    Quantity     INT,
    Discount     DECIMAL(5,2),
    Profit       DECIMAL(10,2),
    PRIMARY KEY (Row_ID)
) ENGINE=InnoDB;

------------------------------------------------------------
-- DIMENSION TABLES
------------------------------------------------------------

-- Customers
CREATE TABLE Customers (
    Customer_ID   VARCHAR(50)  NOT NULL,
    Customer_Name VARCHAR(255) NOT NULL,
    Segment       VARCHAR(50),
    PRIMARY KEY (Customer_ID)
) ENGINE=InnoDB;

-- Locations (по заданному ERD: ключ - Postal_Code)
CREATE TABLE Locations (
    Postal_Code VARCHAR(20)  NOT NULL,
    City        VARCHAR(100) NOT NULL,
    State       VARCHAR(100),
    Country     VARCHAR(100),
    Region      VARCHAR(50),
    PRIMARY KEY (Postal_Code)
) ENGINE=InnoDB;

-- Products
CREATE TABLE Products (
    Product_ID   VARCHAR(50)  NOT NULL,
    Category     VARCHAR(100),
    Sub_Category VARCHAR(100),
    Product_Name VARCHAR(255),
    PRIMARY KEY (Product_ID)
) ENGINE=InnoDB;

------------------------------------------------------------
-- FACT TABLES
------------------------------------------------------------

-- Orders (заказ как факт + ключи на Customer и Location)
CREATE TABLE Orders (
    Order_ID    VARCHAR(50) NOT NULL,
    Order_Date  DATE,
    Ship_Date   DATE,
    Ship_Mode   VARCHAR(50),
    Customer_ID VARCHAR(50) NOT NULL,
    Postal_Code VARCHAR(20),
    PRIMARY KEY (Order_ID),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Customers (Customer_ID),
    CONSTRAINT fk_orders_location
        FOREIGN KEY (Postal_Code)
        REFERENCES Locations (Postal_Code)
) ENGINE=InnoDB;

-- Order_Items (позиции в заказе)
CREATE TABLE Order_Items (
    Row_ID     INT          NOT NULL,
    Order_ID   VARCHAR(50)  NOT NULL,
    Product_ID VARCHAR(50)  NOT NULL,
    Sales      DECIMAL(10,2),
    Quantity   INT,
    Discount   DECIMAL(5,2),
    Profit     DECIMAL(10,2),
    PRIMARY KEY (Row_ID),
    CONSTRAINT fk_items_order
        FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID),
    CONSTRAINT fk_items_product
        FOREIGN KEY (Product_ID)
        REFERENCES Products (Product_ID)
) ENGINE=InnoDB;

------------------------------------------------------------
-- INDEXES (Database optimization by indexing)
------------------------------------------------------------

-- Orders: ускоряем join'ы и аналитику
CREATE INDEX idx_orders_customer   ON Orders (Customer_ID);
CREATE INDEX idx_orders_postal     ON Orders (Postal_Code);
CREATE INDEX idx_orders_dates      ON Orders (Order_Date, Ship_Date);
CREATE INDEX idx_orders_shipmode   ON Orders (Ship_Mode);

-- Order_Items: ускоряем связи и фильтры по метрикам
CREATE INDEX idx_items_order       ON Order_Items (Order_ID);
CREATE INDEX idx_items_product     ON Order_Items (Product_ID);
CREATE INDEX idx_items_profit      ON Order_Items (Profit);
CREATE INDEX idx_items_discount    ON Order_Items (Discount);
CREATE INDEX idx_items_sales       ON Order_Items (Sales);

-- Locations: анализ по регионам
CREATE INDEX idx_locations_region  ON Locations (Region);

-- Products: анализ по категориям и подкатегориям
CREATE INDEX idx_products_category ON Products (Category, Sub_Category);

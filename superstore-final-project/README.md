
# 📘 Superstore Database Project

### *Final Project — SQL Developer & AI Engineer*

This project demonstrates the full data engineering + AI analytics pipeline using the **Superstore dataset**.
It includes relational database design, data normalization, SQL optimization, analytical VIEWs, and an AI-powered SQL agent (Gemini + LangChain).

---

# **📂 Project Structure**

```
superstore-final-project/
│
├── sql/
│   ├── 01_schema.sql        → creates database, tables, PK/FK, indexes
│   ├── 02_populate.sql      → populates normalized tables from Raw_Superstore
│
├── data/
│   └── Sample-Superstore.csv (optional — raw dataset for staging)
│
├── notebooks/
│   └── AI_agent.ipynb       → Gemini + LangChain SQL agent notebook
│
└── README.md                → project documentation
```

---

# **🧱 1. SQL Developer Component**

The SQL Developer is responsible for:

* Designing the relational schema based on the ER diagram
* Creating tables, keys, and indexes
* Importing the raw Superstore dataset
* Cleaning and normalizing data
* Populating all dimension and fact tables
* Preparing the dataset for downstream analytics and AI queries

Below is the guide to reproduce the full database.

---

# **🚀 How to Recreate the Database**

## **1️⃣ Run the Schema Script**

Open MySQL Workbench → run:

```sql
SOURCE sql/01_schema.sql;
```

This script will:

* Create the database `superstore_db`
* Create staging table `Raw_Superstore`
* Create normalized tables:

  * `Customers`
  * `Locations`
  * `Products`
  * `Orders`
  * `Order_Items`
* Add primary keys, foreign keys, and optimization indexes

---

## **2️⃣ Import the CSV into Raw_Superstore**

Using **Table Data Import Wizard**:

* File: `Sample - Superstore.csv`
* Target Table: `Raw_Superstore`
* Encoding: UTF-8
* Import mode: Replace existing data

After import:

```sql
SELECT COUNT(*) FROM Raw_Superstore;
```

---

## **3️⃣ Populate Normalized Tables**

Run:

```sql
SOURCE sql/02_populate.sql;
```

This script:

* Cleans existing data
* Removes duplicates using `GROUP BY`
* Converts date fields using `STR_TO_DATE`
* Populates dimension tables (Customers, Locations, Products)
* Populates fact tables (Orders, Order_Items)

---

## **4️⃣ Verify Successful Load**

Run:

```sql
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Locations', COUNT(*) FROM Locations
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Items', COUNT(*) FROM Order_Items;
```

You should see >1000 rows in each table.

---

# **🤖 2. AI Engineer Component**

The AI Engineer is responsible for:

* Connecting Python to MySQL
* Creating analytical SQL VIEWs for each business problem
* Implementing an AI agent using Google Gemini + LangChain
* Performing data analysis via natural language questions

---

# **🔍 Analytical SQL VIEWs**

The following VIEWs are created to generate insights:

### **1. Regional & Category Profitability Analysis**

Identifies bottom-5 regions/sub-categories by profit and evaluates correlation with discounts.

### **2. Shipping Performance Optimization**

Analyzes delivery speed and profitability across ship modes.

### **3. High-Value Customer Segmentation**

Finds top 10 customers by Sales and their Segment.

### **4. Inventory & Seasonal Trends**

Monthly and yearly sales trends for each sub-category.

Example:

```sql
CREATE OR REPLACE VIEW vw_shipmode_performance AS
SELECT
    o.Ship_Mode,
    AVG(DATEDIFF(o.Ship_Date, o.Order_Date)) AS avg_delivery_days,
    SUM(oi.Sales)  AS total_sales,
    SUM(oi.Profit) AS total_profit
FROM Orders o
JOIN Order_Items oi ON o.Order_ID = oi.Order_ID
GROUP BY o.Ship_Mode;
```

---

# **🤖 AI Agent (Gemini + LangChain)**

The AI agent:

* Reads natural language questions
* Classifies the user intent
* Generates SQL queries using Gemini
* Executes SQL through LangChain
* Returns results + explanation

### **Dependencies**

```bash
pip install google-generativeai langchain langchain-community langchain-google-vertexai mysql-connector-python
```

### **Database Connection Example**

```python
from langchain_community.utilities import SQLDatabase

db = SQLDatabase.from_uri(
    "mysql+mysqlconnector://root:YOUR_PASSWORD@localhost:3306/superstore_db"
)
```

### **Agent Example**

```python
response = agent.run("Show me the bottom 5 sub-categories by profit.")
print(response)
```

---

# **🛠 Technologies Used**

### **SQL Developer**

* MySQL Workbench
* ER modeling
* Relational normalization
* Data cleaning
* Indexing (performance optimization)

### **AI Engineer**

* Python + Jupyter Notebook
* Google Gemini 2.5 Flash
* LangChain Agents
* SQLDatabase tools
* Pandas

---

# **🎯 Final Outcome**

✔ Fully normalized and indexed SQL database
✔ Analytical SQL VIEWs aligned with business goals
✔ AI-powered natural-language SQL agent
✔ Reproducible setup using SQL scripts + this README
✔ Clear separation of roles: SQL Developer & AI Engineer

* или заполнить Authors секцию.



---

# 📘 Superstore Database Project

### *Final Project — SQL Developer & AI Engineer*

This project demonstrates a complete data engineering + AI analytics workflow using the **Superstore dataset**.
It includes relational database design, data normalization, SQL optimization, analytical VIEWs, and an AI-powered SQL assistant built with **Google Gemini 2.5 Flash + LangChain**.

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
│   └── Sample-Superstore.csv  → raw dataset for staging
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
* Creating tables, PKs, FKs, and performance indexes
* Importing the raw Superstore dataset
* Cleaning and normalizing data
* Populating dimension and fact tables
* Preparing the dataset for analytical queries and AI processing

Below is the full guide to reconstruct the database.

---

# **🚀 How to Recreate the Database**

## **1️⃣ Run the Schema Script**

In MySQL Workbench:

```sql
SOURCE sql/01_schema.sql;
```

This script will:

* Create database: `superstore_db`

* Create staging table: `Raw_Superstore`

* Create normalized tables:

  * `Customers`
  * `Locations`
  * `Products`
  * `Orders`
  * `Order_Items`

* Add primary keys, foreign keys, indexing

---

## **2️⃣ Import the CSV into Raw_Superstore**

Using **Table Data Import Wizard**:

* File → `Sample - Superstore.csv`
* Target table → `Raw_Superstore`
* Encoding → UTF-8
* Import mode → Replace data

Verify import:

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

* Cleans duplicates using `GROUP BY`
* Converts date formats via `STR_TO_DATE`
* Populates Customers, Locations, Products
* Populates Orders and Order_Items fact tables

---

## **4️⃣ Verify Data Load**

```sql
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL SELECT 'Locations', COUNT(*) FROM Locations
UNION ALL SELECT 'Products', COUNT(*) FROM Products
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Order_Items', COUNT(*) FROM Order_Items;
```

You should see thousands of rows across all tables.

---

# **🤖 2. AI Engineer Component (UPDATED)**

The AI Engineer built an AI-driven Text-to-SQL system that enables natural-language analytics against the MySQL database.

The system uses:

* **Google Gemini 2.5 Flash**
* **LangChain (custom pipeline)**
* **MySQLConnector + SQLAlchemy**
* **Custom-built ask() and insight() functions**

The Text-to-SQL agent:

1. Reads the database schema
2. Accepts natural-language questions
3. Generates SQL using Gemini
4. Executes SQL on MySQL
5. Produces human-readable business insights

This allows non-technical users to run complex queries without writing SQL.

---

# **🔍 Analytical SQL VIEWs Created by AI Engineer**

To support the 4 business problem statements, four VIEWs were created:

---

### **1. Regional & Category Profitability**

```sql
CREATE OR REPLACE VIEW vw_regional_profitability AS
SELECT
    l.Region,
    SUM(oi.Sales) AS total_sales,
    SUM(oi.Profit) AS total_profit,
    AVG(oi.Discount) AS avg_discount
FROM Orders o
JOIN Locations l ON o.Postal_Code = l.Postal_Code
JOIN Order_Items oi ON o.Order_ID = oi.Order_ID
GROUP BY l.Region;
```

---

### **2. Shipping Performance Optimization**

```sql
CREATE OR REPLACE VIEW vw_shipping_performance AS
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

### **3. High-Value Customer Revenue Ranking**

```sql
CREATE OR REPLACE VIEW vw_customer_revenue AS
SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    SUM(oi.Sales)  AS total_sales,
    SUM(oi.Profit) AS total_profit,
    COUNT(DISTINCT o.Order_ID) AS total_orders
FROM Customers c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
JOIN Order_Items oi ON o.Order_ID = oi.Order_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Segment;
```

---

### **4. Sub-Category Seasonal Sales Trends**

```sql
CREATE OR REPLACE VIEW vw_subcategory_sales_trends AS
SELECT
    p.Sub_Category,
    YEAR(o.Order_Date) AS year,
    MONTH(o.Order_Date) AS month,
    SUM(oi.Sales)  AS total_sales,
    SUM(oi.Profit) AS total_profit
FROM Orders o
JOIN Order_Items oi ON o.Order_ID = oi.Order_ID
JOIN Products p ON oi.Product_ID = p.Product_ID
GROUP BY p.Sub_Category, YEAR(o.Order_Date), MONTH(o.Order_Date);
```

---

# **🤖 AI Text-to-SQL Agent (Gemini + LangChain)**

The AI Engineer implemented a **custom Text-to-SQL agent** rather than LangChain’s default agents (which deprecated several components).

The architecture includes:

* Schema-aware system prompt
* Dynamic SQL generation
* Multi-statement SQL parsing
* Automatic SQL execution
* AI-powered insight generation based on results

---

## **Python Setup**

```python
from langchain_community.utilities import SQLDatabase
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import SystemMessage, HumanMessage
import pandas as pd
import os
```

Database connection:

```python
db = SQLDatabase.from_uri(
    "mysql+mysqlconnector://root:YOUR_PASSWORD@localhost:3306/superstore_db"
)
```

Gemini model:

```python
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    temperature=0
)
```

---

# **ask() — Execute AI-Generated SQL**

```python
def ask(question: str):
    response = llm.invoke([system_msg, HumanMessage(content=question)])
    raw_sql = response.content.strip()

    statements = [s.strip() for s in raw_sql.split(";") if s.strip()]
    results = []

    for stmt in statements:
        try:
            res = db.run(stmt)
            results.append((stmt, res))
        except Exception as e:
            results.append((stmt, f"ERROR: {e}"))

    return results
```

---

# **insight() — AI-Generated Business Insights**

```python
def insight(question: str):
    sql_response = llm.invoke([system_msg, HumanMessage(content=question)])
    sql = sql_response.content.strip().split(";")[0]

    result = db.run(sql)

    explanation_prompt = f"""
    SQL:
    {sql}

    RESULT:
    {result}

    Provide a 2–3 sentence business insight:
    """
    explanation = llm.invoke([HumanMessage(content=explanation_prompt)])
    return explanation.content
```

---

# **📊 Examples of AI Usage**

```python
ask("How many rows does each table contain?")
insight("Which regions have the lowest profit and why?")
insight("Which shipping mode performs best?")
insight("Who are the top 10 most valuable customers?")
insight("Which sub-categories show seasonal sales trends?")
```

---

# **🛠 Technologies Used**

### **SQL Developer**

* MySQL Workbench
* ERD modeling
* Normalization & cleaning
* Indexing
* SQL scripting

### **AI Engineer**

* Python + VS Code / Jupyter
* Google Gemini 2.5 Flash
* LangChain (custom pipeline)
* MySQLConnector
* Pandas

---

# **🎯 Final Outcome**

✔ Fully normalized and indexed database
✔ Analytical SQL VIEWs mapped to business goals
✔ A fully working natural-language **AI SQL agent**
✔ Automated insight generation
✔ Reproducible setup using provided SQL scripts
✔ Clear role separation: SQL Developer & AI Engineer

---


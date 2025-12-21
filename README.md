# ECommerce SQL Database Project

##  Overview
This project is a **fully designed E-Commerce relational database** built using **Microsoft SQL Server**, focused on **data integrity, performance optimization, and real-world database architecture** 

The goal was to demonstrate how a production-style database is structured, optimized, and protected using SQL Server features.

---

This project was created to go further and **showcase advanced database concepts**, including:

- Proper normalization and relational modeling
- Enforced business rules at the database level
- Performance-focused design decisions
- Realistic E-Commerce data flow (orders, statuses, payments, etc.)

In short: **the database does not trust the application layer** — it protects itself.

---

##  Key Concepts Demonstrated

###  Data Integrity & Constraints
- Primary & Foreign Keys
- CHECK constraints for business rules
- UNIQUE constraints where applicable
- NOT NULL enforcement
- Default constraints for timestamps and states

###  Advanced SQL Logic
- **Stored Procedures** for controlled data operations
- **Triggers** for:
  - Audit/history tracking
  - State change validation
- **Views** for simplified and secure data access
- **Transactions** to guarantee consistency

###  Performance & Optimization
- Indexing strategy based on access patterns
- Avoiding redundant data
- Server-side logic to reduce application overhead
- Designed with scalability in mind

###  Realistic E-Commerce Structure
- Customers
- Products
- Categories
- Orders
- Order statuses & history
- Payments
- Suppliers
- Inventory-related logic

---

##  Project Structure
The repository is organized so scripts are executed in a **specific order** to avoid dependency issues.

```text
/Scripts
│
├── _create_database_and_tables.sql
├── _insert_script.sql
├── _reset_identity.sql (just in case)
├── _creating_indexes.sql
├── _creating_views.sql
├── _creating_triggers.sql
├── _stored_procedures.sql
└── _test_queries.sql
```
---

##  Seed Data (CSV Files)
Initial data is populated using **CSV files** to simulate realistic production-like datasets.

- Data is bulk-inserted during `_insert_script.sql`
- CSV files represent real-world entities (customers, products, orders, etc.)
- This approach allows:
  - Fast database initialization
  - Easy data replacement or scaling
  - Cleaner separation between schema and data

CSV-based seeding was chosen instead of hardcoded INSERT statements to better reflect real enterprise workflows.


##  Script Execution Order 
Run the scripts **in the following order**:

1. **_create_database_and_tables.sql**  
   Creates the database and tables, adds foreign keys, CHECK constraints, UNIQUE rules, and defaults..

2. **_insert_script.sql**  
   Inserts data from csv files to tables.

3. **_creating_indexes.sql**  
   Creating indexes for query optimization.

4. **_creating_views.sql**  
   Creates views for simplified querying.

5. **_creating_triggers.sql**  
   Enables audit/history logic and automatic state tracking.

6. **_stored_procedures.sql**  
   Adds stored procedures for core operations.

7. **_test_queries.sql**  
   Optional — used to validate behavior and logic.


 **Running scripts out of order will cause errors** due to dependencies.

---

##  Important Notice — BULK INSERT Paths
⚠️ **Attention before running seed scripts**

The `_insert_script.sql` uses **BULK INSERT** statements that reference **local file system paths** for CSV files.

After cloning this repository, you **must update the file paths** in the script to match the location of the CSV files on your own machine.

Failure to update the paths will result in **BULK INSERT errors** and the seed process will fail.

This is expected behavior and not a project issue.

---

##  Tested With
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)

---

##  Future Improvements
- More advanced reporting views
- Additional performance benchmarks
- Partitioning for large datasets
- Integration-focused stored procedures

---

##  Author
**Temo Meshveliani**

This project is intended for:
- Portfolio demonstration
- SQL Server skill validation
- Backend & database-oriented roles


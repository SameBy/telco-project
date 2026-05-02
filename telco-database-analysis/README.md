# 📊 i2i Systems - Telecom Database Operations & Analytics

**Developer:** Samet Bekir Yüksel (Database Developer Intern)  
**Company:** i2i Systems  
**Domain:** Telecommunications Data Engineering  

## 📝 Project Overview
This project involves designing a database schema and writing advanced SQL queries to address specific business scenarios within a telecommunications context. The primary objective is to extract meaningful insights regarding subscriber behavior, tariff distributions, resource usage limits, and financial payment statuses using Oracle XE.

## ⚙️ Functional Requirements & Compliance
This repository was developed in strict adherence to the project guidelines:
1. **Scenario-Based SQL Queries:** Developed robust queries for 6 major analytical modules (Tariff Queries, Distribution, Registration Analysis, Missing Records, Usage Alerts, and Payment Health).
2. **Comprehensive Documentation:** Every SQL solution includes a detailed, multi-sentence comment block (minimum 3 sentences) explaining the technical approach, functions used, and logical reasoning behind the query.
3. **Database Schema Design:** Exercised creative freedom to design relational tables (`CUSTOMERS`, `TARIFFS`, `MONTHLY_STATS`) applying appropriate data types and constraints based on the provided datasets.
4. **Data Import & Execution:** Utilized DBeaver to import `.csv` data into the Oracle XE environment and thoroughly test each query.

## 🛠️ Technical Stack & Methodologies
During the development phase, several key database querying techniques were implemented:
*   **Relational Joins:** Connecting normalized tables using Primary/Foreign keys (`CUSTOMER_ID`, `TARIFF_ID`).
*   **Analytical Window Functions:** Utilizing `SUM() OVER(PARTITION BY ...)` to calculate accurate market shares and percentage distributions without losing row-level context.
*   **Data Type Conversions:** Managing non-standard string formats with `TO_DATE()` and `UPPER()` for precise chronological sorting and case-insensitive filtering.
*   **Set Operations:** Performing data integrity audits using the `MINUS` operator to pinpoint synchronization gaps between demographic data and operational logs.

## 📂 Repository Structure
*   📄 **`SOLUTIONS.sql`:** The master script containing all documented SQL queries and their detailed explanations.
*   📁 **`OUTPUTS/`:** A directory containing the resulting `.csv` datasets exported directly from DBeaver after executing the queries. 
    *   *Note: Files such as `5.2_Exhausted_Package_Limits.csv` represent the exact state of the database. If a specific edge-case condition (e.g., all limits maxed out simultaneously) did not exist in the source data, the resulting empty set was exported as proof of query execution and data validation.*
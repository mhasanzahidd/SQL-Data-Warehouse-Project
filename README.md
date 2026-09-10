# SQL Data Warehouse

## Overview

This project is a SQL Server-based Data Warehouse built to integrate data from multiple CRM and ERP source systems into a clean and structured analytical data model.

The main goal of this project is to take raw source data, process it through a structured ETL pipeline, and transform it into reliable, business-ready data using a Bronze, Silver, and Gold layer architecture.

The project focuses on practical Data Warehousing concepts such as data integration, data cleansing, transformation, data quality validation, dimensional modeling, and Star Schema design.
---

## Project Goals

The main objectives of this project are to:

- Build a structured SQL Data Warehouse from raw CRM and ERP data
- Integrate data from multiple source systems
- Preserve raw source data in the Bronze layer
- Clean and standardize data in the Silver layer
- Create a business-ready dimensional model in the Gold layer
- Apply data quality checks throughout the process
- Implement fact and dimension tables
- Create reliable relationships between business entities
- Document the warehouse structure and transformations
---

## Data Architecture

The project follows a **Medallion Architecture** with three main layers:

<img width="5100" height="3300" alt="data_architecture" src="https://github.com/user-attachments/assets/822783ea-b8d7-4339-9064-553c42918532" />

1. **Bronze Layer:** Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer:** This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics.
---

## Repository Structure

```text
SQL-Data-Warehouse/
│
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── source_erp/
│       ├── cust_az12.csv
│       ├── loc_a101.csv
│       └── px_cat_g1v2.csv
│
├── docs/
│   ├── data_architecture.jpg
│   ├── data_dictionary.md
│   ├── data_flow.jpg
│   ├── data_integration.jpg
│   ├── data_model.jpg
│   └── naming_conventions.md
│
├── scripts/
│   │
│   ├── 01_database_setup/
│   │   └── init_database.sql
│   │
│   ├── 02_bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── 03_silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   │
│   └── 04_gold/
│       └── ddl_gold.sql
│
├── screenshots/
|   ├── 01_database_setup.png
|   ├── 02_bronze_layer.png
|   ├── 03_silver_layer.png
|   ├── 04_quality_checks_silver.png
|   ├── 05_gold_layer.png
|   └── 06_quality_checks_gold.png
|
├── tests/
|   ├── quality_checks_silver.sql
|   └── quality_checks_gold.sql
|
└── README.md

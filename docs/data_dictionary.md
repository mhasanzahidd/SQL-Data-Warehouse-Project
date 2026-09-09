# Data Dictionary

## 1. Overview

This document provides a detailed description of the tables and columns used in the SQL Data Warehouse project.
The data warehouse follows a Medallion Architecture:
- Bronze Layer: Raw source data
- Silver Layer: Cleaned and transformed data
- Gold Layer: Business-ready data for analytics and reporting
---

## 2. Bronze Layer

### CRM Tables

#### bronze.crm_cst_info

| Column              | Data Type     | Description                                         |
|---------------------|---------------|-----------------------------------------------------|
| cst_id              | INT           | Unique identifier assigned to each customer         |
| cst_key             | NVARCHAR(50)  | Unique business key used to identify the customer   |
| cst_firstname       | NVARCHAR(50)  | Customer's first name                               |
| cst_lastname        | NVARCHAR(50)  | Customer's last name                                |
| cst_marital_status  | NVARCHAR(50)  | Customer's marital status                           |
| cst_gndr            | NVARCHAR(50)  | Customer's gender                                   |
| cst_create_date     | DATE          | Date when the customer record was created           |
---

#### bronze.crm_prd_info

| Column              | Data Type     | Description                                        |
|---------------------|---------------|----------------------------------------------------|
| prd_id              | INT           | Unique identifier assigned to each product         |
| prd_key             | NVARCHAR(50)  | Unique business key identifying the product        |
| prd_nm              | NVARCHAR(50)  | Name of the product                                |
| prd_cost            | INT           | Cost associated with the product                   |
| prd_line            | NVARCHAR(50)  | Product line associated with the product           |
| prd_start_dt        | DATE          | Date when the product record became valid          |
| prd_end_dt          | DATE          | Date when the product record stopped being valid   |
---

#### bronze.crm_sales_details

| Column           | Data Type     | Description                                        |
|------------------|---------------|----------------------------------------------------|
| sls_ord_num      | NVARCHAR(50)  | Unique identifier for the sales order              |
| sls_prd_key      | NVARCHAR(50)  | Business key identifying the product               |
| sls_cust_id      | INT           | Identifier of the customer who placed the order    |
| sls_order_dt     | INT           | Date when the sales order was placed               |
| sls_ship_dt      | INT           | Date when the order was shipped                    |
| sls_due_dt       | INT           | Date when the order was due to be delivered        |
| sls_sales        | INT           | Total sales amount for the order                   |
| sls_quantity     | INT           | Quantity of products sold                          |
| sls_price        | INT           | Price of the product at the time of sale           |
---

### ERP Tables

#### bronze.erp_cust_az12

| Column   | Data Type     | Description                     |
|----------|---------------|---------------------------------|
| cid      | NVARCHAR(50)  | Identifier of the customer      |
| bdate    | DATE          | Customer's birth date           |
| gen      | NVARCHAR(50)  | Gender of the customer          |

#### bronze.erp_loc_a101

| Column   | Data Type     | Description                     |
|----------|---------------|---------------------------------|
| cid      | NVARCHAR(50)  | Identifier of the customer      |
| cntry    | NVARCHAR(50)  | Country of the customer         |

#### bronze.erp_px_cat_g1v2

| Column        | Data Type     | Description                     |
|---------------|---------------|---------------------------------|
| id            | NVARCHAR(50)  | Identifier of the category      |
| cat           | NVARCHAR(50)  | Name of the category            |
| subcat        | NVARCHAR(50)  | Name of the subcategory         |
| maintenance   | NVARCHAR(50)  | Maintenance? (Yes or No)        |

## 3. Silver Layer

### CRM Tables

#### silver.crm_cst_info

| Column              | Data Type     | Description                                         |
|---------------------|---------------|-----------------------------------------------------|
| cst_id              | INT           | Unique identifier assigned to each customer         |
| cst_key             | NVARCHAR(50)  | Unique business key used to identify the customer   |
| cst_firstname       | NVARCHAR(50)  | Customer's first name                               |
| cst_lastname        | NVARCHAR(50)  | Customer's last name                                |
| cst_marital_status  | NVARCHAR(50)  | Customer's marital status                           |
| cst_gndr            | NVARCHAR(50)  | Customer's gender                                   |
| cst_create_date     | DATE          | Date when the customer record was created           |
| dwh_create_date     | DATETIME2     | Date when the data warehouse was created            |
---

#### silver.crm_prd_info

| Column              | Data Type     | Description                                        |
|---------------------|---------------|----------------------------------------------------|
| prd_id              | INT           | Unique identifier assigned to each product         |
| cat_id              | NVARCHAR(50)  | Identifier of the category                         |
| prd_key             | NVARCHAR(50)  | Unique business key identifying the product        |
| prd_nm              | NVARCHAR(50)  | Name of the product                                |
| prd_cost            | INT           | Cost associated with the product                   |
| prd_line            | NVARCHAR(50)  | Product line associated with the product           |
| prd_start_dt        | DATE          | Date when the product record became valid          |
| prd_end_dt          | DATE          | Date when the product record stopped being valid   |
| dwh_create_date     | DATETIME2     | Date when the data warehouse was created           |
---

#### silver.crm_sales_details

| Column           | Data Type     | Description                                        |
|------------------|---------------|----------------------------------------------------|
| sls_ord_num      | NVARCHAR(50)  | Unique identifier for the sales order              |
| sls_prd_key      | NVARCHAR(50)  | Business key identifying the product               |
| sls_cust_id      | INT           | Identifier of the customer who placed the order    |
| sls_order_dt     | Date          | Date when the sales order was placed               |
| sls_ship_dt      | Date          | Date when the order was shipped                    |
| sls_due_dt       | Date          | Date when the order was due to be delivered        |
| sls_sales        | INT           | Total sales amount for the order                   |
| sls_quantity     | INT           | Quantity of products sold                          |
| sls_price        | INT           | Price of the product at the time of sale           |
| dwh_create_date  | DATETIME2     | Date when the data warehouse was created           |
---

### ERP Tables

#### silver.erp_cust_az12

| Column              | Data Type     | Description                                 |
|---------------------|---------------|---------------------------------------------|
| cid                 | NVARCHAR(50)  | Identifier of the customer                  |
| bdate               | DATE          | Customer's birth date                       |
| gen                 | NVARCHAR(50)  | Gender of the customer                      |
| dwh_create_date     | DATETIME2     | Date when the data warehouse was created    |

#### silver.erp_loc_a101

| Column              | Data Type     | Description                                  |
|---------------------|---------------|----------------------------------------------|
| cid                 | NVARCHAR(50)  | Identifier of the customer                   |
| cntry               | NVARCHAR(50)  | Country of the customer                      |
| dwh_create_date     | DATETIME2     | Date when the data warehouse was created     |

#### silver.erp_px_cat_g1v2

| Column              | Data Type     | Description                                 |
|---------------------|---------------|---------------------------------------------|
| id                  | NVARCHAR(50)  | Identifier of the category                  |
| cat                 | NVARCHAR(50)  | Name of the category                        |
| subcat              | NVARCHAR(50)  | Name of the subcategory                     |
| maintenance         | NVARCHAR(50)  | Maintenance? (Yes or No)                    |
| dwh_create_date     | DATETIME2     | Date when the data warehouse was created    |
---

### Transformations
- Removed duplicate records.
- Removed duplicate primary key values.
- Handled NULL and missing values.
- Standardized gender values.
- Standardized marital status values.
- Standardized product line values.
- Standardized date formats.
- Trimmed leading and trailing whitespace.
- Corrected inconsistent or invalid data values.
- Validated data types for consistency.
---

## 4. Gold Layer

### gold.dim_customers

| Column Name      | Data Type     | Description                                                                            |
|------------------|---------------|----------------------------------------------------------------------------------------|
| customer_key     | INT           | Surrogate key uniquely identifying each customer record in the dimension table.        |
| customer_id      | INT           | Unique numerical identifier assigned to each customer.                                 |
| customer_number  | NVARCHAR(50)  | Alphanumeric identifier representing the customer, used for tracking and referencing.  |
| first_name       | NVARCHAR(50)  | The customer's first name, as recorded in the system.                                  |
| last_name        | NVARCHAR(50)  | The customer's last name or family name.                                               |
| country          | NVARCHAR(50)  | The country of residence for the customer (e.g., 'Australia').                         |
| marital_status   | NVARCHAR(50)  | The marital status of the customer (e.g., 'Married', 'Single').                        |
| gender           | NVARCHAR(50)  | The gender of the customer (e.g., 'Male', 'Female', 'n/a').                            |
| birthdate        | DATE          | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06).         |
| create_date      | DATE          | The date and time when the customer record was created in the system                   |

### Type
Dimension Table

### Primary Key
customer_key

### Purpose
Contains business-ready customer information used for reporting and analysis.
---

## gold.dim_products

| Column Name         | Data Type    | Description                                                                                   |
|---------------------|--------------|-----------------------------------------------------------------------------------------------|
| product_key         | INT          | Surrogate key uniquely identifying each product record in the product dimension table.        |
| product_id          | INT          | A unique identifier assigned to the product for internal tracking and referencing.            |
| product_number      | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization or inventory.  |
| product_name        | NVARCHAR(50) | Descriptive name of the product, including key details such as type, color, and size.         |
| category_id         | NVARCHAR(50) | A unique identifier for the product's category, linking to its high-level classification.     |
| category            | NVARCHAR(50) | The broader classification of the product (e.g., Bikes, Components) to group related items.   |
| subcategory         | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type.      |
| maintenance_required| NVARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                       |
| cost                | INT          | The cost or base price of the product, measured in monetary units.                            |
| product_line        | NVARCHAR(50) | The specific product line or series to which the product belongs (e.g., Road, Mountain).      |
| start_date          | DATE         | The date when the product became available for sale or use, stored in|

### Type
Dimension Table

### Primary Key
product_key

### Purpose
Contains business-ready product information.
---

## gold.fact_sales

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').                      |
| product_key     | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_key    | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date when the order was placed.                                                           |
| shipping_date   | DATE          | The date when the order was shipped to the customer.                                          |
| due_date        | DATE          | The date when the order payment was due.                                                      |
| sales_amount    | INT           | The total monetary value of the sale for the line item, in whole currency units (e.g., 25).   |
| quantity        | INT           | The number of units of the product ordered for the line item (e.g., 1).                       |
| price           | INT           | The price per unit of the product for the line item, in whole currency units (e.g., 25).      |

### Type
Fact Table

### Primary Key
order_number + product_key

### Foreign Keys
- product_key → gold.dim_products
- customer_key → gold.dim_customers

### Purpose
Stores measurable sales transactions used for business analysis and reporting.
---

# 5. Relationships

The Gold layer follows a Star Schema:

gold.dim_customers
        |
        |
gold.fact_sales
        |
        |
gold.dim_products

Relationships:
- dim_customers.customer_key → fact_sales.customer_key
- dim_products.product_key → fact_sales.product_key


# 6. Data Quality Rules

The following rules are applied to the warehouse:
- Primary keys must be unique.
- Primary keys must not contain NULL values.
- Foreign keys should match corresponding dimension records.
- Duplicate records should be removed.
- Invalid dates should be identified.
- Numerical values should be within valid ranges.
- Required fields should not contain NULL values.

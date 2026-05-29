# Sales Analytics Dashboard – Azure
> **Author:** MEZGHIT Ilias (Aspiring Data Analyst)

## Project Overview
This project demonstrates an end-to-end **Sales Analytics Dashboard** built using **Azure Synapse Analytics**, **Azure Data Lake Storage (ADLS Gen2)**, and **Power BI**.  
It follows the **Medallion architecture** (Bronze → Silver → Gold) to process and transform raw sales data into curated insights ready for business reporting.

- **Silver Layer (Root Directory):** Contains cleaned, validated, and structured CSV datasets.
- **Gold Layer (`/Gold` Directory):** Contains curated analytics-ready data modeled into a **Snowflake Schema** with Fact and Dimension tables created through Synapse SQL scripts.

---

## Architecture Overview

### Technologies Used
- **Azure Synapse Analytics** – Data transformation and modeling  
- **ADLS Gen2** – Centralized data lake storage  
- **Azure Data Factory** – Pipeline orchestration between layers  
- **Power BI** – Interactive visualization and dashboards  
- **T-SQL / PySpark** – Data transformation and aggregation  

### Medallion Layers
| Layer | Description |
|--------|--------------|
| **Bronze** | Raw ingested data from multiple sources |
| **Silver** | Cleaned, validated, and structured datasets (Root CSV files) |
| **Gold** | Curated analytics-ready data located in `/Gold` (Fact & Dimension tables) |

---

## Data Schema & Structure

### Silver Layer Datasets (Root CSV Files)

| File Name | Description |
|-----------|-------------|
| **customers.csv** | Raw/Cleaned customer details including IDs and location. |
| **geoLocation.csv** | Geographic reference data by ZIP code, city, and state. |
| **orders.csv** | Transactional order headers and status updates. |
| **order_items.csv** | Itemized product details per order. |
| **order_payments.csv** | Payment transaction breakdown and methods. |
| **order_reviews.csv** | Customer feedback, review scores, and timestamps. |
| **products.csv** | Specifications and attributes for all sold products. |
| **product_category_name_translation.csv** | Category translations between languages. |
| **sellers.csv** | Seller account and geographic details. |
| **statesEnglishName.csv** | Reference mapping for state abbreviations to English names. |

---

### Gold Layer Schema (Located in `/Gold`)

| Table Name | Type | Description |
|-------------|------|-------------|
| **DimCustomers** | Dimension | Customer dimension built from Silver customer datasets. |
| **DimSellers** | Dimension | Seller information formatted for analytics. |
| **DimProducts** | Dimension | Enriched product details and specifications. |
| **DimReviews** | Dimension | Customer review metrics and sentiment scores. |
| **DimGeoLocation** | Dimension | Consolidated geographic mappings. |
| **DimStatesEnglishName** | Dimension | Standardized reference mapping for state codes. |
| **FactOrders** | Fact | Central transactional table consolidating orders, items, and payments. |

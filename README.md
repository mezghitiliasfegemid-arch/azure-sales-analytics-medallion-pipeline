# Sales Analytics Dashboard – Azure
> **Author:** MEZGHIT Ilias (Aspiring Data Analyst)
## Project Overview
This project demonstrates an end-to-end **Sales Analytics Dashboard** built using **Azure Synapse Analytics**, **Azure Data Lake Storage (ADLS Gen2)**, and **Power BI**.  
It follows the **Medallion architecture** (Bronze → Silver → Gold) to process and transform raw sales data into curated insights ready for business reporting.

The **Gold layer** is modelled using a **Snowflake Schema** that includes one Fact table and six Dimension tables created through Synapse SQL scripts.  
A connected **Power BI dashboard** visualizes sales, products, and customer performance insights.

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
| **Silver** | Cleaned, validated, and structured data |
| **Gold** | Curated analytics-ready data (Fact & Dimension tables) |

---

## Gold Layer Schema

### Gold Schema Structure

| Table Name | Type | Description |
|-------------|------|-------------|
| **DimCustomers** | Dimension | Contains customer details including ID, location, and unique identifiers. |
| **DimSellers** | Dimension | Holds seller information such as ID, city, and state. |
| **DimProducts** | Dimension | Includes product specifications such as category, weight, and size. |
| **DimReviews** | Dimension | Stores customer review data, scores, and timestamps. |
| **DimGeoLocation** | Dimension | Maps geographic data by ZIP code, city, and state. |
| **DimStatesEnglishName** | Dimension | Reference table mapping state codes to English names. |
| **FactOrders** | Fact | Central transactional table containing order, product, payment, and delivery details. |


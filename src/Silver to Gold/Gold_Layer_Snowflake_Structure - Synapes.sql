----------------------------------------------
-- Author: Fuad Abo dayyak
-- Project: E-Commerce Data Platform
-- Layer: Gold (Snowflake Schema)
-- Environment: Azure Synapse Analytics
----------------------------------------------

-- 1️ Create Gold Schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Gold')
    EXEC('CREATE SCHEMA Gold');
GO


-- 2️ Create a Gold View combining all Silver data
CREATE OR ALTER VIEW Gold.AllData
AS
SELECT *
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/',
        FORMAT = 'PARQUET'
    ) AS result;
GO


-- Define External Data Source and File Format
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'GoldenLayer')
CREATE EXTERNAL DATA SOURCE [GoldenLayer]
WITH (
    LOCATION = 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Gold/',
    CREDENTIAL = [fuad Abo Dayyak]
);
GO

IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'ParquetFormat')
CREATE EXTERNAL FILE FORMAT [ParquetFormat]
WITH (
    FORMAT_TYPE = PARQUET
);
GO


-- 4️ DIMENSION TABLES
----------------------------------------------

-- DimCustomers
CREATE OR ALTER VIEW Gold.DimCustomersView AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Customers/',
        FORMAT = 'PARQUET'
    ) AS src;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimCustomers
WITH (
    LOCATION = 'DimCustomers/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimCustomersView;
GO


-- DimSellers
CREATE OR ALTER VIEW Gold.DimSellersView AS
SELECT DISTINCT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Sellers/',
        FORMAT = 'PARQUET'
    ) AS src;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimSellers
WITH (
    LOCATION = 'DimSellers/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimSellersView;
GO


-- DimProducts
CREATE OR ALTER VIEW Gold.DimProductsView AS
SELECT DISTINCT
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Products/',
        FORMAT = 'PARQUET'
    ) AS src;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimProducts
WITH (
    LOCATION = 'DimProducts/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimProductsView;
GO


-- DimReviews
CREATE OR ALTER VIEW Gold.DimReviewsView AS
SELECT DISTINCT
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Reviews/',
        FORMAT = 'PARQUET'
    ) AS src;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimReviews
WITH (
    LOCATION = 'DimReviews/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimReviewsView;
GO


-- DimGeoLocation
CREATE OR ALTER VIEW Gold.DimGeoLocationView AS
SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS record_count
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/GeoLocation/',
        FORMAT = 'PARQUET'
    ) AS src
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimGeoLocation
WITH (
    LOCATION = 'DimGeoLocation/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimGeoLocationView;
GO


-- DimStatesEnglishName
CREATE OR ALTER VIEW Gold.DimStatesEnglishNameView AS
SELECT DISTINCT
    state_code,
    state_english_name
FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/StatesEnglishName/',
        FORMAT = 'PARQUET'
    ) AS src;
GO

CREATE OR ALTER EXTERNAL TABLE Gold.DimStatesEnglishName
WITH (
    LOCATION = 'DimStatesEnglishName/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS SELECT * FROM Gold.DimStatesEnglishNameView;
GO


-- FACT TABLE
----------------------------------------------
CREATE OR ALTER VIEW Gold.FactOrdersView
AS
SELECT DISTINCT
    o.order_id,
    r.review_id,
    o.customer_id,
    i.seller_id,
    i.product_id,
    o.order_status,

    -- Split purchase timestamp into date and time
    CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_date,
    CAST(o.order_purchase_timestamp AS TIME) AS order_purchase_time,

    -- Split delivered timestamp into date and time
    CAST(o.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
    CAST(o.order_delivered_customer_date AS TIME) AS order_delivered_customer_time,

    -- Estimated delivery
    CAST(o.order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date,

    -- Shipping limit
    CAST(i.shipping_limit_date AS DATE) AS shipping_limit_date,
    CAST(i.shipping_limit_date AS TIME) AS shipping_limit_time,

    -- Monetary values
    i.price,
    i.freight_value,
    p.payment_type,
    p.payment_value

FROM OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Orders/',
        FORMAT = 'PARQUET'
    ) AS o

-- Join with Order Items
INNER JOIN OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/OrderItems/',
        FORMAT = 'PARQUET'
    ) AS i
    ON o.order_id = i.order_id

-- Join with Payments
LEFT JOIN OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Payments/',
        FORMAT = 'PARQUET'
    ) AS p
    ON o.order_id = p.order_id

-- Join with Reviews
LEFT JOIN OPENROWSET(
        BULK 'https://ecomdataplatformsa.dfs.core.windows.net/ecomdataplatformcontainer/Silver/Reviews/',
        FORMAT = 'PARQUET'
    ) AS r
    ON o.order_id = r.order_id;
GO


-- 6️ Create External Table for FactOrders
IF OBJECT_ID('Gold.FactOrders', 'U') IS NOT NULL
    DROP EXTERNAL TABLE Gold.FactOrders;
GO

CREATE EXTERNAL TABLE Gold.FactOrders
WITH (
    LOCATION = 'FactOrders/',
    DATA_SOURCE = [GoldenLayer],
    FILE_FORMAT = [ParquetFormat]
)
AS
SELECT
    order_id,
    review_id,
    customer_id,
    seller_id,
    product_id,
    order_status,
    order_purchase_date,
    order_purchase_time,
    order_delivered_customer_date,
    order_delivered_customer_time,
    order_estimated_delivery_date,
    shipping_limit_date,
    shipping_limit_time,
    price,
    freight_value,
    payment_type,
    payment_value
FROM Gold.FactOrdersView;
GO

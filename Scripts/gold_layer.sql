------------------------------------------------------------------------------------------------------
-- Creating the gold layer will not be raw data but the result of queries from the silver layer data
-- The result of queries are saved in views then later converted into an external table that will be
-- saved in the gold layer. This will be used in the phase three of the project (Project)
-- The data will be ready to be consumed form PowerBI
------------------------------------------------------------------------------------------------------


----------------------------------
--- CREATE VIEW CALENDAR
----------------------------------
CREATE VIEW gold.calendar
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Calendar/',
        FORMAT = 'PARQUET'
    )as Query1


----------------------------------
--- CREATE VIEW CUSTOMER
----------------------------------
CREATE VIEW gold.customers
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Customers/',
        FORMAT = 'PARQUET'
    )as Query2

----------------------------------
--- CREATE VIEW PRODUCTS
----------------------------------
CREATE VIEW gold.products
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Products/',
        FORMAT = 'PARQUET'
    )as Query3


----------------------------------
--- CREATE VIEW RETURNS
----------------------------------
CREATE VIEW gold.returns
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Returns/',
        FORMAT = 'PARQUET'
    )as Query4



----------------------------------
--- CREATE VIEW SALES
----------------------------------
CREATE VIEW gold.sales
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Sales*/',
        FORMAT = 'PARQUET'
    )as Query5



----------------------------------
--- CREATE VIEW TERRITORIES
----------------------------------
CREATE VIEW gold.territories
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/AdventureWorks_Territories/',
        FORMAT = 'PARQUET'
    )as Query6


    ----------------------------------
--- CREATE VIEW SUBCATEGORIES
----------------------------------
CREATE VIEW gold.sub_categories
AS
SELECT 
*
FROM 
    OPENROWSET(
        BULK'https://awstoragedatalakedulla.blob.core.windows.net/silver/Product_Subcategories/',
        FORMAT = 'PARQUET'
    )as Query7


------------------------------------------------------------------------------------------------------
-- At this level, we will createan  external table from the views, then save them in the gold laye,r which
-- which is sitting in the blob container storage lake
------------------------------------------------------------------------------------------------------


CREATE DATABASE SCOPED CREDENTIAL cred_dulla
WITH 
    IDENTITY = 'Managed Identity'



CREATE EXTERNAL DATA SOURCE source_silver
WITH(
    LOCATION = 'https://awstoragedatalakedulla.blob.core.windows.net/silver',
    CREDENTIAL = cred_dulla
)


CREATE EXTERNAL DATA SOURCE source_gold
WITH(
    LOCATION = 'https://awstoragedatalakedulla.blob.core.windows.net/gold',
    CREDENTIAL = cred_dulla
)


CREATE EXTERNAL FILE FORMAT format_parquet
WITH(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)



---------------------------------------------------------------------

-- CREATE EXTERNAL TABLE EXTSALES from the Sales View

----------------------------------------------------------------------

CREATE EXTERNAL TABLE gold.extsales
WITH(
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS 
SELECT * FROM gold.sales




---------------------------------------------------------------------

-- CREATE EXTERNAL TABLE EXTPRODUCTS from the Product View

----------------------------------------------------------------------

CREATE EXTERNAL TABLE gold.extprod
WITH(
    LOCATION = 'extprod',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS SELECT * FROM gold.products


---------------------------------------------------------------------

-- CREATE EXTERNAL TABLE EXTRETURNS from the Returns View

----------------------------------------------------------------------

CREATE EXTERNAL TABLE gold.extret
WITH(
    LOCATION = 'extret',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS SELECT * FROM gold.returns

/*
=======================================================================================================================
Create Database and Schemas
=======================================================================================================================
Script Purpose:
    This script creates the 'DataWarehouse' database and initializes the three-layer architecture used by the 
    data warehouse: 'bronze', 'silver', and 'gold'.

    If the database already exists, it is removed and recreated to provide a clean environment for rebuilding the
    data warehouse from scratch.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before 
    running this script.
=======================================================================================================================
*/

USE master;
GO

-- Force active connections to close before recreating the database.
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Initialize a fresh database environment for the data warehouse.
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas representing the Bronze, Silver, and Gold layers of the warehouse.
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

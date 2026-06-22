-- ============================================================================
-- LACERA Intelligence Agent
-- File: 01_database_and_schema.sql
-- Purpose: Create database, schemas, and warehouse for LACERA
-- Execution Order: 1 of 9
-- ============================================================================

-- Create the main database
CREATE DATABASE IF NOT EXISTS LACERA_DB;
USE DATABASE LACERA_DB;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS RAW
    COMMENT = 'Raw ingestion layer for LACERA investment data from external sources';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
    COMMENT = 'Analytics and consumption layer with views, semantic views, and search services';

-- Create the warehouse
CREATE OR REPLACE WAREHOUSE LACERA_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for LACERA Intelligence Agent workloads';

USE WAREHOUSE LACERA_WH;
USE SCHEMA RAW;

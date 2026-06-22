-- ============================================================================
-- LACERA Intelligence Agent
-- File: 06_create_cortex_search.sql
-- Purpose: Create 3 Cortex Search services for RAG-based document search
-- Execution Order: 6 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- 1. POLICY_SEARCH - Search investment policy documents
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE POLICY_SEARCH
  ON CONTENT
  ATTRIBUTES POLICY_NAME, POLICY_CATEGORY, STATUS
  WAREHOUSE = LACERA_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search service for LACERA investment policy documents including IPS, asset class guidelines, ESG policy, and risk framework'
AS (
  SELECT
    POLICY_ID,
    POLICY_NAME,
    POLICY_CATEGORY,
    EFFECTIVE_DATE,
    CONTENT,
    VERSION,
    APPROVED_BY,
    STATUS
  FROM LACERA_DB.RAW.POLICY_DOCUMENTS
  WHERE STATUS = 'ACTIVE'
);

-- ============================================================================
-- 2. BOARD_MATERIALS_SEARCH - Search board meeting materials
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE BOARD_MATERIALS_SEARCH
  ON CONTENT
  ATTRIBUTES DOCUMENT_TYPE, SECTION, FISCAL_YEAR
  WAREHOUSE = LACERA_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search service for LACERA Board of Investments meeting materials including performance reports, risk updates, and strategic reviews'
AS (
  SELECT
    MATERIAL_ID,
    MEETING_DATE,
    DOCUMENT_TYPE,
    TITLE,
    CONTENT,
    SECTION,
    PRESENTER,
    FISCAL_YEAR,
    QUARTER
  FROM LACERA_DB.RAW.BOARD_MATERIALS
);

-- ============================================================================
-- 3. MANAGER_RESEARCH_SEARCH - Search manager due diligence research
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MANAGER_RESEARCH_SEARCH
  ON CONTENT
  ATTRIBUTES RESEARCH_TYPE, RECOMMENDATION, RISK_RATING
  WAREHOUSE = LACERA_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search service for LACERA investment manager due diligence research notes, performance reviews, and operational assessments'
AS (
  SELECT
    RESEARCH_ID,
    mr.MANAGER_ID,
    im.MANAGER_NAME,
    RESEARCH_DATE,
    RESEARCH_TYPE,
    TITLE,
    mr.CONTENT,
    ANALYST,
    RECOMMENDATION,
    RISK_RATING
  FROM LACERA_DB.RAW.MANAGER_RESEARCH mr
  JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON mr.MANAGER_ID = im.MANAGER_ID
);

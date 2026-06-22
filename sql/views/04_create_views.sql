-- ============================================================================
-- LACERA Intelligence Agent
-- File: 04_create_views.sql
-- Purpose: Create analytical views for reporting and dashboarding
-- Execution Order: 4 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- 1. PORTFOLIO_ALLOCATION_VW - Current asset allocation summary
-- ============================================================================
CREATE OR REPLACE VIEW PORTFOLIO_ALLOCATION_VW AS
SELECT
    ph.AS_OF_DATE,
    ac.ASSET_CLASS_NAME,
    ac.ASSET_CLASS_CATEGORY,
    SUM(ph.MARKET_VALUE) AS TOTAL_MARKET_VALUE,
    SUM(ph.COST_BASIS) AS TOTAL_COST_BASIS,
    SUM(ph.UNREALIZED_GAIN_LOSS) AS TOTAL_UNREALIZED_GL,
    ROUND(SUM(ph.MARKET_VALUE) / SUM(SUM(ph.MARKET_VALUE)) OVER (PARTITION BY ph.AS_OF_DATE) * 100, 2) AS ACTUAL_ALLOCATION_PCT,
    ac.TARGET_ALLOCATION_PCT,
    ROUND(SUM(ph.MARKET_VALUE) / SUM(SUM(ph.MARKET_VALUE)) OVER (PARTITION BY ph.AS_OF_DATE) * 100, 2) - ac.TARGET_ALLOCATION_PCT AS ALLOCATION_DEVIATION,
    ac.MIN_ALLOCATION_PCT,
    ac.MAX_ALLOCATION_PCT,
    COUNT(DISTINCT ph.MANAGER_ID) AS NUM_MANAGERS
FROM LACERA_DB.RAW.PORTFOLIO_HOLDINGS ph
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON ph.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
GROUP BY ph.AS_OF_DATE, ac.ASSET_CLASS_NAME, ac.ASSET_CLASS_CATEGORY,
         ac.TARGET_ALLOCATION_PCT, ac.MIN_ALLOCATION_PCT, ac.MAX_ALLOCATION_PCT;

-- ============================================================================
-- 2. PERFORMANCE_ATTRIBUTION_VW - Performance by asset class and manager
-- ============================================================================
CREATE OR REPLACE VIEW PERFORMANCE_ATTRIBUTION_VW AS
SELECT
    pr.AS_OF_DATE,
    ac.ASSET_CLASS_NAME,
    ac.ASSET_CLASS_CATEGORY,
    im.MANAGER_NAME,
    im.STRATEGY_TYPE,
    pr.RETURN_1M,
    pr.RETURN_3M,
    pr.RETURN_YTD,
    pr.RETURN_1Y,
    pr.RETURN_3Y,
    pr.RETURN_5Y,
    pr.BENCHMARK_RETURN_1M,
    pr.BENCHMARK_RETURN_1Y,
    pr.EXCESS_RETURN_1M,
    pr.EXCESS_RETURN_1Y,
    ac.BENCHMARK_INDEX
FROM LACERA_DB.RAW.PERFORMANCE_RETURNS pr
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON pr.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON pr.MANAGER_ID = im.MANAGER_ID;

-- ============================================================================
-- 3. RISK_DASHBOARD_VW - Risk metrics overview
-- ============================================================================
CREATE OR REPLACE VIEW RISK_DASHBOARD_VW AS
SELECT
    rm.AS_OF_DATE,
    ac.ASSET_CLASS_NAME,
    ac.ASSET_CLASS_CATEGORY,
    im.MANAGER_NAME,
    im.STRATEGY_TYPE,
    rm.VAR_95,
    rm.VAR_99,
    rm.TRACKING_ERROR,
    rm.BETA,
    rm.VOLATILITY_ANNUALIZED,
    rm.SHARPE_RATIO,
    rm.INFORMATION_RATIO,
    rm.MAX_DRAWDOWN,
    rm.SORTINO_RATIO
FROM LACERA_DB.RAW.RISK_METRICS rm
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON rm.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON rm.MANAGER_ID = im.MANAGER_ID;

-- ============================================================================
-- 4. COMPLIANCE_MONITOR_VW - Compliance event tracking
-- ============================================================================
CREATE OR REPLACE VIEW COMPLIANCE_MONITOR_VW AS
SELECT
    ce.EVENT_ID,
    ce.EVENT_DATE,
    ac.ASSET_CLASS_NAME,
    im.MANAGER_NAME,
    ce.EVENT_TYPE,
    ce.SEVERITY,
    ce.DESCRIPTION,
    ce.POLICY_REFERENCE,
    ce.RESOLUTION_STATUS,
    ce.RESOLUTION_DATE,
    ce.RESOLVED_BY,
    DATEDIFF(DAY, ce.EVENT_DATE, COALESCE(ce.RESOLUTION_DATE, CURRENT_DATE())) AS DAYS_TO_RESOLVE
FROM LACERA_DB.RAW.COMPLIANCE_EVENTS ce
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON ce.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
LEFT JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON ce.MANAGER_ID = im.MANAGER_ID;

-- ============================================================================
-- 5. ESG_PORTFOLIO_VW - ESG scoring and sustainability metrics
-- ============================================================================
CREATE OR REPLACE VIEW ESG_PORTFOLIO_VW AS
SELECT
    es.AS_OF_DATE,
    ac.ASSET_CLASS_NAME,
    im.MANAGER_NAME,
    es.ESG_FRAMEWORK,
    es.OVERALL_SCORE,
    es.ENVIRONMENTAL_SCORE,
    es.SOCIAL_SCORE,
    es.GOVERNANCE_SCORE,
    es.CARBON_INTENSITY,
    es.ENERGY_TRANSITION_RISK,
    es.RATING_AGENCY
FROM LACERA_DB.RAW.ESG_SCORES es
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON es.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON es.MANAGER_ID = im.MANAGER_ID;

-- ============================================================================
-- 6. MANAGER_PERFORMANCE_VW - Manager comparison and scoring
-- ============================================================================
CREATE OR REPLACE VIEW MANAGER_PERFORMANCE_VW AS
SELECT
    im.MANAGER_ID,
    im.MANAGER_NAME,
    im.STRATEGY_TYPE,
    ac.ASSET_CLASS_NAME,
    im.INCEPTION_DATE,
    im.AUM_MILLIONS,
    im.FEE_BPS,
    im.STATUS,
    pr.AS_OF_DATE,
    pr.RETURN_1M,
    pr.RETURN_1Y,
    pr.RETURN_3Y,
    pr.EXCESS_RETURN_1Y,
    rm.SHARPE_RATIO,
    rm.INFORMATION_RATIO,
    rm.TRACKING_ERROR,
    rm.MAX_DRAWDOWN,
    rm.VOLATILITY_ANNUALIZED
FROM LACERA_DB.RAW.INVESTMENT_MANAGERS im
JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON im.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
LEFT JOIN LACERA_DB.RAW.PERFORMANCE_RETURNS pr ON im.MANAGER_ID = pr.MANAGER_ID
LEFT JOIN LACERA_DB.RAW.RISK_METRICS rm ON im.MANAGER_ID = rm.MANAGER_ID AND pr.AS_OF_DATE = rm.AS_OF_DATE;

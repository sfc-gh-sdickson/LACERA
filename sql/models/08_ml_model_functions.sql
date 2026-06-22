-- ============================================================================
-- LACERA Intelligence Agent
-- File: 08_ml_model_functions.sql
-- Purpose: Create 3 ML prediction UDFs for the agent
-- Execution Order: 8 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- 1. FORECAST_RETURNS - Time series return forecasting by asset class
-- Description: Uses exponential smoothing with momentum adjustment to forecast
--              returns for a given asset class over a specified horizon
-- ============================================================================
CREATE OR REPLACE FUNCTION FORECAST_RETURNS(P_ASSET_CLASS VARCHAR, P_HORIZON_MONTHS NUMBER)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'asset_class', ASSET_CLASS_NAME,
    'forecast_month', FORECAST_MONTH,
    'forecasted_return_pct', ROUND(FORECASTED_RETURN * 100, 3),
    'confidence_lower_pct', ROUND((FORECASTED_RETURN - 1.96 * VOLATILITY) * 100, 3),
    'confidence_upper_pct', ROUND((FORECASTED_RETURN + 1.96 * VOLATILITY) * 100, 3),
    'methodology', 'Exponential smoothing with momentum adjustment'
))
FROM (
    SELECT
        ac.ASSET_CLASS_NAME,
        DATEADD(MONTH, m.N, CURRENT_DATE())::DATE AS FORECAST_MONTH,
        AVG(pr.RETURN_1M) * 0.7 + (AVG(pr.RETURN_1M) - LAG(AVG(pr.RETURN_1M)) OVER (ORDER BY m.N)) * 0.3 AS FORECASTED_RETURN,
        STDDEV(pr.RETURN_1M) AS VOLATILITY
    FROM LACERA_DB.RAW.PERFORMANCE_RETURNS pr
    JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON pr.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
    CROSS JOIN (SELECT SEQ4() + 1 AS N FROM TABLE(GENERATOR(ROWCOUNT => 12))) m
    WHERE ac.ASSET_CLASS_NAME ILIKE '%' || P_ASSET_CLASS || '%'
      AND pr.AS_OF_DATE >= DATEADD(MONTH, -12, CURRENT_DATE())
      AND m.N <= P_HORIZON_MONTHS
    GROUP BY ac.ASSET_CLASS_NAME, m.N
    ORDER BY m.N
) sub
$$;

-- ============================================================================
-- 2. DETECT_RISK_ANOMALIES - Anomaly detection on risk metrics
-- Description: Uses statistical Z-score method to identify unusual risk metric
--              readings that may indicate emerging problems
-- ============================================================================
CREATE OR REPLACE FUNCTION DETECT_RISK_ANOMALIES(P_LOOKBACK_DAYS NUMBER)
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'as_of_date', AS_OF_DATE,
    'manager_name', MANAGER_NAME,
    'asset_class', ASSET_CLASS_NAME,
    'metric_name', METRIC_NAME,
    'metric_value', ROUND(METRIC_VALUE, 4),
    'z_score', ROUND(Z_SCORE, 2),
    'anomaly_severity', CASE
        WHEN ABS(Z_SCORE) > 3.0 THEN 'CRITICAL'
        WHEN ABS(Z_SCORE) > 2.5 THEN 'HIGH'
        ELSE 'MEDIUM'
    END,
    'direction', CASE WHEN Z_SCORE > 0 THEN 'ABOVE_NORMAL' ELSE 'BELOW_NORMAL' END
))
FROM (
    SELECT * FROM (
        SELECT
            rm.AS_OF_DATE,
            im.MANAGER_NAME,
            ac.ASSET_CLASS_NAME,
            'VOLATILITY' AS METRIC_NAME,
            rm.VOLATILITY_ANNUALIZED AS METRIC_VALUE,
            (rm.VOLATILITY_ANNUALIZED - AVG(rm.VOLATILITY_ANNUALIZED) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING))
            / NULLIF(STDDEV(rm.VOLATILITY_ANNUALIZED) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING), 0) AS Z_SCORE
        FROM LACERA_DB.RAW.RISK_METRICS rm
        JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON rm.MANAGER_ID = im.MANAGER_ID
        JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON rm.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
        WHERE rm.AS_OF_DATE >= DATEADD(DAY, -1 * P_LOOKBACK_DAYS, CURRENT_DATE())
          AND im.STATUS = 'ACTIVE'
        UNION ALL
        SELECT
            rm.AS_OF_DATE,
            im.MANAGER_NAME,
            ac.ASSET_CLASS_NAME,
            'TRACKING_ERROR' AS METRIC_NAME,
            rm.TRACKING_ERROR AS METRIC_VALUE,
            (rm.TRACKING_ERROR - AVG(rm.TRACKING_ERROR) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING))
            / NULLIF(STDDEV(rm.TRACKING_ERROR) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING), 0) AS Z_SCORE
        FROM LACERA_DB.RAW.RISK_METRICS rm
        JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON rm.MANAGER_ID = im.MANAGER_ID
        JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON rm.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
        WHERE rm.AS_OF_DATE >= DATEADD(DAY, -1 * P_LOOKBACK_DAYS, CURRENT_DATE())
          AND im.STATUS = 'ACTIVE'
        UNION ALL
        SELECT
            rm.AS_OF_DATE,
            im.MANAGER_NAME,
            ac.ASSET_CLASS_NAME,
            'MAX_DRAWDOWN' AS METRIC_NAME,
            rm.MAX_DRAWDOWN AS METRIC_VALUE,
            (rm.MAX_DRAWDOWN - AVG(rm.MAX_DRAWDOWN) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING))
            / NULLIF(STDDEV(rm.MAX_DRAWDOWN) OVER (PARTITION BY rm.MANAGER_ID ORDER BY rm.AS_OF_DATE ROWS BETWEEN 12 PRECEDING AND 1 PRECEDING), 0) AS Z_SCORE
        FROM LACERA_DB.RAW.RISK_METRICS rm
        JOIN LACERA_DB.RAW.INVESTMENT_MANAGERS im ON rm.MANAGER_ID = im.MANAGER_ID
        JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON rm.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
        WHERE rm.AS_OF_DATE >= DATEADD(DAY, -1 * P_LOOKBACK_DAYS, CURRENT_DATE())
          AND im.STATUS = 'ACTIVE'
    ) anomalies
    WHERE ABS(Z_SCORE) > 2.0
    ORDER BY ABS(Z_SCORE) DESC
    LIMIT 20
) final
$$;

-- ============================================================================
-- 3. SCORE_MANAGER_PERFORMANCE - Composite manager scoring model
-- Description: Multi-factor scoring model that ranks managers using weighted
--              combination of return, risk-adjusted return, consistency, and fees
-- ============================================================================
CREATE OR REPLACE FUNCTION SCORE_MANAGER_PERFORMANCE()
RETURNS ARRAY
AS
$$
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
    'manager_name', MANAGER_NAME,
    'asset_class', ASSET_CLASS_NAME,
    'strategy_type', STRATEGY_TYPE,
    'composite_score', ROUND(COMPOSITE_SCORE, 1),
    'return_score', ROUND(RETURN_SCORE, 1),
    'risk_adj_score', ROUND(RISK_ADJ_SCORE, 1),
    'consistency_score', ROUND(CONSISTENCY_SCORE, 1),
    'fee_efficiency_score', ROUND(FEE_SCORE, 1),
    'ranking', RANKING,
    'quartile', CASE
        WHEN RANKING <= TOTAL_MANAGERS * 0.25 THEN 'Q1 - Top Quartile'
        WHEN RANKING <= TOTAL_MANAGERS * 0.50 THEN 'Q2 - Above Median'
        WHEN RANKING <= TOTAL_MANAGERS * 0.75 THEN 'Q3 - Below Median'
        ELSE 'Q4 - Bottom Quartile'
    END
))
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY COMPOSITE_SCORE DESC) AS RANKING,
        COUNT(*) OVER () AS TOTAL_MANAGERS
    FROM (
        SELECT
            im.MANAGER_NAME,
            ac.ASSET_CLASS_NAME,
            im.STRATEGY_TYPE,
            -- Return score: percentile of average 1Y return (weight: 30%)
            PERCENT_RANK() OVER (ORDER BY AVG(pr.RETURN_1Y)) * 100 * 0.30 AS RETURN_SCORE,
            -- Risk-adjusted score: percentile of Sharpe ratio (weight: 30%)
            PERCENT_RANK() OVER (ORDER BY AVG(rm.SHARPE_RATIO)) * 100 * 0.30 AS RISK_ADJ_SCORE,
            -- Consistency score: inverse of return volatility (weight: 25%)
            PERCENT_RANK() OVER (ORDER BY -STDDEV(pr.RETURN_1M)) * 100 * 0.25 AS CONSISTENCY_SCORE,
            -- Fee efficiency: excess return per bps of fee (weight: 15%)
            PERCENT_RANK() OVER (ORDER BY CASE WHEN im.FEE_BPS > 0 THEN AVG(pr.EXCESS_RETURN_1Y) / (im.FEE_BPS / 10000.0) ELSE 0 END) * 100 * 0.15 AS FEE_SCORE,
            -- Composite
            PERCENT_RANK() OVER (ORDER BY AVG(pr.RETURN_1Y)) * 100 * 0.30 +
            PERCENT_RANK() OVER (ORDER BY AVG(rm.SHARPE_RATIO)) * 100 * 0.30 +
            PERCENT_RANK() OVER (ORDER BY -STDDEV(pr.RETURN_1M)) * 100 * 0.25 +
            PERCENT_RANK() OVER (ORDER BY CASE WHEN im.FEE_BPS > 0 THEN AVG(pr.EXCESS_RETURN_1Y) / (im.FEE_BPS / 10000.0) ELSE 0 END) * 100 * 0.15 AS COMPOSITE_SCORE
        FROM LACERA_DB.RAW.INVESTMENT_MANAGERS im
        JOIN LACERA_DB.RAW.ASSET_CLASSES ac ON im.ASSET_CLASS_ID = ac.ASSET_CLASS_ID
        JOIN LACERA_DB.RAW.PERFORMANCE_RETURNS pr ON im.MANAGER_ID = pr.MANAGER_ID
        JOIN LACERA_DB.RAW.RISK_METRICS rm ON im.MANAGER_ID = rm.MANAGER_ID AND pr.AS_OF_DATE = rm.AS_OF_DATE
        WHERE im.STATUS = 'ACTIVE'
          AND pr.AS_OF_DATE >= DATEADD(YEAR, -1, CURRENT_DATE())
        GROUP BY im.MANAGER_NAME, ac.ASSET_CLASS_NAME, im.STRATEGY_TYPE, im.FEE_BPS
    ) scored
) ranked
ORDER BY RANKING
$$;

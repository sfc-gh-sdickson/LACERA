-- ============================================================================
-- LACERA Intelligence Agent
-- File: 03_generate_synthetic_data.sql
-- Purpose: Generate realistic synthetic data for LACERA pension fund (~$75B AUM)
-- Execution Order: 3 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA RAW;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- 1. ASSET_CLASSES - 8 major asset classes
-- ============================================================================
INSERT INTO ASSET_CLASSES (ASSET_CLASS_ID, ASSET_CLASS_NAME, ASSET_CLASS_CATEGORY, TARGET_ALLOCATION_PCT, MIN_ALLOCATION_PCT, MAX_ALLOCATION_PCT, BENCHMARK_INDEX, DESCRIPTION)
VALUES
    (1, 'US Equity', 'Public Markets', 25.00, 20.00, 30.00, 'Russell 3000 Index', 'Domestic equity portfolio including large, mid, and small cap'),
    (2, 'International Equity', 'Public Markets', 20.00, 15.00, 25.00, 'MSCI ACWI ex-US Index', 'International developed and emerging market equities'),
    (3, 'Fixed Income', 'Public Markets', 20.00, 15.00, 25.00, 'Bloomberg US Aggregate Bond Index', 'Investment grade bonds including government and corporate'),
    (4, 'Private Equity', 'Private Markets', 12.00, 8.00, 16.00, 'Cambridge Associates PE Index', 'Buyout, growth equity, and venture capital funds'),
    (5, 'Real Estate', 'Real Assets', 10.00, 7.00, 13.00, 'NCREIF ODCE Index', 'Core and value-add real estate investments'),
    (6, 'Real Assets', 'Real Assets', 5.00, 3.00, 7.00, 'CPI + 4%', 'Infrastructure, timber, and natural resources'),
    (7, 'Hedge Funds', 'Alternatives', 5.00, 3.00, 7.00, 'HFRI Fund Weighted Composite Index', 'Diversified hedge fund strategies'),
    (8, 'Cash and Short-Term', 'Liquidity', 3.00, 1.00, 5.00, '90-Day T-Bill', 'Cash equivalents and short-term investments for liquidity');

-- ============================================================================
-- 2. INVESTMENT_MANAGERS - 52 managers across asset classes
-- ============================================================================
INSERT INTO INVESTMENT_MANAGERS (MANAGER_ID, MANAGER_NAME, ASSET_CLASS_ID, STRATEGY_TYPE, INCEPTION_DATE, AUM_MILLIONS, FEE_BPS, STATUS, CITY, STATE)
VALUES
    -- US Equity (8 managers)
    (1, 'BlackRock US Equity Index', 1, 'Passive Index', '2005-01-01', 8500, 3, 'ACTIVE', 'New York', 'NY'),
    (2, 'Capital Group Growth Fund', 1, 'Active Growth', '2008-06-15', 4200, 45, 'ACTIVE', 'Los Angeles', 'CA'),
    (3, 'T. Rowe Price Large Cap Value', 1, 'Active Value', '2010-03-01', 3100, 50, 'ACTIVE', 'Baltimore', 'MD'),
    (4, 'Dimensional US Small Cap', 1, 'Factor-Based', '2012-09-01', 2800, 35, 'ACTIVE', 'Austin', 'TX'),
    (5, 'Wellington Management Core', 1, 'Active Core', '2007-04-01', 2500, 40, 'ACTIVE', 'Boston', 'MA'),
    (6, 'Northern Trust US Index', 1, 'Passive Index', '2003-01-01', 1800, 2, 'ACTIVE', 'Chicago', 'IL'),
    (7, 'Fidelity Contrafund', 1, 'Active Growth', '2015-07-01', 1500, 55, 'ACTIVE', 'Boston', 'MA'),
    (8, 'Vanguard Total Stock Market', 1, 'Passive Index', '2001-01-01', 3200, 2, 'ACTIVE', 'Malvern', 'PA'),
    -- International Equity (7 managers)
    (9, 'Baillie Gifford International', 2, 'Active Growth', '2011-01-01', 4500, 55, 'ACTIVE', 'Edinburgh', 'UK'),
    (10, 'Lazard International Equity', 2, 'Active Value', '2009-06-01', 3200, 60, 'ACTIVE', 'New York', 'NY'),
    (11, 'Harding Loevner Emerging Markets', 2, 'Active Growth', '2013-03-01', 2800, 75, 'ACTIVE', 'Bridgewater', 'NJ'),
    (12, 'BlackRock MSCI EAFE Index', 2, 'Passive Index', '2004-01-01', 3800, 4, 'ACTIVE', 'San Francisco', 'CA'),
    (13, 'Acadian Asset Management', 2, 'Quantitative', '2014-09-01', 2100, 50, 'ACTIVE', 'Boston', 'MA'),
    (14, 'Marathon Asset Management Intl', 2, 'Active Value', '2016-01-01', 1600, 65, 'ACTIVE', 'London', 'UK'),
    (15, 'Mondrian Investment Partners', 2, 'Active Value', '2010-06-01', 1900, 55, 'ACTIVE', 'Philadelphia', 'PA'),
    -- Fixed Income (7 managers)
    (16, 'PIMCO Total Return', 3, 'Active Core Plus', '2002-01-01', 5200, 30, 'ACTIVE', 'Newport Beach', 'CA'),
    (17, 'DoubleLine Total Return', 3, 'Active Core', '2012-04-01', 3100, 35, 'ACTIVE', 'Los Angeles', 'CA'),
    (18, 'Loomis Sayles Investment Grade', 3, 'Active Credit', '2008-01-01', 2800, 28, 'ACTIVE', 'Boston', 'MA'),
    (19, 'Western Asset Management Core', 3, 'Active Core', '2006-06-01', 2500, 25, 'ACTIVE', 'Pasadena', 'CA'),
    (20, 'Vanguard Total Bond Index', 3, 'Passive Index', '2003-01-01', 3500, 3, 'ACTIVE', 'Malvern', 'PA'),
    (21, 'MetWest Total Return Bond', 3, 'Active Core Plus', '2015-01-01', 1800, 32, 'ACTIVE', 'Los Angeles', 'CA'),
    (22, 'Brandywine Global Fixed Income', 3, 'Active Global', '2011-06-01', 1500, 40, 'ACTIVE', 'Philadelphia', 'PA'),
    -- Private Equity (8 managers)
    (23, 'KKR North America Fund', 4, 'Buyout', '2010-01-01', 2500, 150, 'ACTIVE', 'New York', 'NY'),
    (24, 'Apollo Global Management', 4, 'Buyout', '2012-06-01', 2200, 160, 'ACTIVE', 'New York', 'NY'),
    (25, 'Warburg Pincus Growth', 4, 'Growth Equity', '2014-01-01', 1800, 140, 'ACTIVE', 'New York', 'NY'),
    (26, 'Thoma Bravo Technology', 4, 'Technology Buyout', '2015-03-01', 1500, 170, 'ACTIVE', 'San Francisco', 'CA'),
    (27, 'Hellman Friedman Capital', 4, 'Buyout', '2011-09-01', 1200, 155, 'ACTIVE', 'San Francisco', 'CA'),
    (28, 'Berkshire Partners', 4, 'Mid-Market Buyout', '2013-06-01', 900, 145, 'ACTIVE', 'Boston', 'MA'),
    (29, 'Sequoia Capital Growth', 4, 'Venture/Growth', '2016-01-01', 800, 180, 'ACTIVE', 'Menlo Park', 'CA'),
    (30, 'General Atlantic Partners', 4, 'Growth Equity', '2014-06-01', 1100, 135, 'ACTIVE', 'New York', 'NY'),
    -- Real Estate (6 managers)
    (31, 'JPMorgan Strategic Property', 5, 'Core Open-End', '2005-01-01', 2800, 80, 'ACTIVE', 'New York', 'NY'),
    (32, 'Prologis Industrial REIT', 5, 'Industrial Logistics', '2008-06-01', 2200, 65, 'ACTIVE', 'San Francisco', 'CA'),
    (33, 'Heitman Capital Management', 5, 'Value-Add', '2012-01-01', 1500, 110, 'ACTIVE', 'Chicago', 'IL'),
    (34, 'CBRE Clarion Securities', 5, 'Global REITs', '2010-09-01', 1800, 55, 'ACTIVE', 'Radnor', 'PA'),
    (35, 'Harrison Street Real Estate', 5, 'Alternatives RE', '2015-01-01', 1200, 95, 'ACTIVE', 'Chicago', 'IL'),
    (36, 'Invesco Real Estate Core', 5, 'Core Open-End', '2007-03-01', 1600, 75, 'ACTIVE', 'Dallas', 'TX'),
    -- Real Assets (5 managers)
    (37, 'Brookfield Infrastructure', 6, 'Infrastructure', '2011-01-01', 1800, 120, 'ACTIVE', 'Toronto', 'ON'),
    (38, 'IFM Investors Infrastructure', 6, 'Infrastructure', '2013-06-01', 1200, 100, 'ACTIVE', 'Melbourne', 'AU'),
    (39, 'Campbell Global Timber', 6, 'Timber', '2009-01-01', 800, 85, 'ACTIVE', 'Portland', 'OR'),
    (40, 'Global Infrastructure Partners', 6, 'Infrastructure', '2014-09-01', 1000, 130, 'ACTIVE', 'New York', 'NY'),
    (41, 'Macquarie Infrastructure', 6, 'Infrastructure', '2016-01-01', 700, 115, 'ACTIVE', 'New York', 'NY'),
    -- Hedge Funds (5 managers)
    (42, 'AQR Capital Management', 7, 'Multi-Strategy', '2008-01-01', 1500, 150, 'ACTIVE', 'Greenwich', 'CT'),
    (43, 'Bridgewater All Weather', 7, 'Risk Parity', '2006-06-01', 1800, 120, 'ACTIVE', 'Westport', 'CT'),
    (44, 'DE Shaw Composite', 7, 'Quantitative', '2012-01-01', 1200, 200, 'ACTIVE', 'New York', 'NY'),
    (45, 'Man AHL Diversified', 7, 'Managed Futures', '2014-03-01', 900, 160, 'ACTIVE', 'London', 'UK'),
    (46, 'Two Sigma Spectrum', 7, 'Quantitative', '2015-06-01', 800, 180, 'ACTIVE', 'New York', 'NY'),
    -- Cash (3 managers)
    (47, 'State Street Cash Management', 8, 'Money Market', '2000-01-01', 1200, 5, 'ACTIVE', 'Boston', 'MA'),
    (48, 'BlackRock Liquidity Fund', 8, 'Money Market', '2002-01-01', 800, 8, 'ACTIVE', 'New York', 'NY'),
    (49, 'Northern Trust Short-Term', 8, 'Short Duration', '2005-06-01', 600, 10, 'ACTIVE', 'Chicago', 'IL'),
    -- Terminated managers (for historical data)
    (50, 'Legacy Growth Partners', 1, 'Active Growth', '2010-01-01', 0, 60, 'TERMINATED', 'Denver', 'CO'),
    (51, 'Pacific Rim Capital', 2, 'Active Growth', '2012-06-01', 0, 70, 'TERMINATED', 'San Francisco', 'CA'),
    (52, 'Sentinel Fixed Income', 3, 'Active Core', '2008-01-01', 0, 30, 'TERMINATED', 'Hartford', 'CT');

-- ============================================================================
-- 3. PORTFOLIO_HOLDINGS - Monthly holdings data (36 months x ~49 active managers)
-- ============================================================================
INSERT INTO PORTFOLIO_HOLDINGS (HOLDING_ID, AS_OF_DATE, ASSET_CLASS_ID, MANAGER_ID, MARKET_VALUE, COST_BASIS, UNREALIZED_GAIN_LOSS, WEIGHT_PCT, SHARES_UNITS, CURRENCY)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL, m.MANAGER_ID) AS HOLDING_ID,
    d.DATE_VAL AS AS_OF_DATE,
    m.ASSET_CLASS_ID,
    m.MANAGER_ID,
    ROUND(m.AUM_MILLIONS * 1000000 * (1 + (RANDOM() / 10000000000000000000.0) * 0.05), 2) AS MARKET_VALUE,
    ROUND(m.AUM_MILLIONS * 1000000 * 0.88 * (1 + (RANDOM() / 10000000000000000000.0) * 0.03), 2) AS COST_BASIS,
    0 AS UNREALIZED_GAIN_LOSS,
    ROUND(m.AUM_MILLIONS / 750.0, 4) AS WEIGHT_PCT,
    ROUND(m.AUM_MILLIONS * 1000, 4) AS SHARES_UNITS,
    'USD'
FROM INVESTMENT_MANAGERS m
CROSS JOIN (
    SELECT DATEADD(MONTH, SEQ4(), '2022-01-31')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 36))
) d
WHERE m.STATUS = 'ACTIVE'
  AND d.DATE_VAL <= CURRENT_DATE();

-- Update unrealized gain/loss
UPDATE PORTFOLIO_HOLDINGS SET UNREALIZED_GAIN_LOSS = MARKET_VALUE - COST_BASIS;

-- ============================================================================
-- 4. PERFORMANCE_RETURNS - Monthly returns (36 months x ~49 managers)
-- ============================================================================
INSERT INTO PERFORMANCE_RETURNS (RETURN_ID, AS_OF_DATE, ASSET_CLASS_ID, MANAGER_ID, PERIOD_TYPE, RETURN_1M, RETURN_3M, RETURN_YTD, RETURN_1Y, RETURN_3Y, RETURN_5Y, RETURN_ITD, BENCHMARK_RETURN_1M, BENCHMARK_RETURN_1Y, EXCESS_RETURN_1M, EXCESS_RETURN_1Y)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL, m.MANAGER_ID) AS RETURN_ID,
    d.DATE_VAL AS AS_OF_DATE,
    m.ASSET_CLASS_ID,
    m.MANAGER_ID,
    'MONTHLY' AS PERIOD_TYPE,
    ROUND((CASE
        WHEN m.ASSET_CLASS_ID = 1 THEN 0.008
        WHEN m.ASSET_CLASS_ID = 2 THEN 0.007
        WHEN m.ASSET_CLASS_ID = 3 THEN 0.003
        WHEN m.ASSET_CLASS_ID = 4 THEN 0.012
        WHEN m.ASSET_CLASS_ID = 5 THEN 0.006
        WHEN m.ASSET_CLASS_ID = 6 THEN 0.005
        WHEN m.ASSET_CLASS_ID = 7 THEN 0.004
        ELSE 0.003
    END) + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS RETURN_1M,
    ROUND(0.025 + (RANDOM() / 10000000000000000000.0) * 0.06 - 0.03, 6) AS RETURN_3M,
    ROUND(0.05 + (RANDOM() / 10000000000000000000.0) * 0.12 - 0.06, 6) AS RETURN_YTD,
    ROUND(0.08 + (RANDOM() / 10000000000000000000.0) * 0.16 - 0.08, 6) AS RETURN_1Y,
    ROUND(0.07 + (RANDOM() / 10000000000000000000.0) * 0.06 - 0.03, 6) AS RETURN_3Y,
    ROUND(0.08 + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS RETURN_5Y,
    ROUND(0.09 + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS RETURN_ITD,
    ROUND((CASE
        WHEN m.ASSET_CLASS_ID = 1 THEN 0.007
        WHEN m.ASSET_CLASS_ID = 2 THEN 0.006
        WHEN m.ASSET_CLASS_ID = 3 THEN 0.003
        WHEN m.ASSET_CLASS_ID = 4 THEN 0.010
        WHEN m.ASSET_CLASS_ID = 5 THEN 0.005
        WHEN m.ASSET_CLASS_ID = 6 THEN 0.004
        WHEN m.ASSET_CLASS_ID = 7 THEN 0.003
        ELSE 0.003
    END) + (RANDOM() / 10000000000000000000.0) * 0.03 - 0.015, 6) AS BENCHMARK_RETURN_1M,
    ROUND(0.075 + (RANDOM() / 10000000000000000000.0) * 0.12 - 0.06, 6) AS BENCHMARK_RETURN_1Y,
    0 AS EXCESS_RETURN_1M,
    0 AS EXCESS_RETURN_1Y
FROM INVESTMENT_MANAGERS m
CROSS JOIN (
    SELECT DATEADD(MONTH, SEQ4(), '2022-01-31')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 36))
) d
WHERE m.STATUS = 'ACTIVE'
  AND d.DATE_VAL <= CURRENT_DATE();

-- Update excess returns
UPDATE PERFORMANCE_RETURNS SET
    EXCESS_RETURN_1M = RETURN_1M - BENCHMARK_RETURN_1M,
    EXCESS_RETURN_1Y = RETURN_1Y - BENCHMARK_RETURN_1Y;

-- ============================================================================
-- 5. TRANSACTIONS - Sample transactions (approx 500 per year)
-- ============================================================================
INSERT INTO TRANSACTIONS (TRANSACTION_ID, TRANSACTION_DATE, SETTLEMENT_DATE, ASSET_CLASS_ID, MANAGER_ID, TRANSACTION_TYPE, SECURITY_NAME, QUANTITY, PRICE, AMOUNT, CURRENCY, BROKER)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL) AS TRANSACTION_ID,
    d.DATE_VAL AS TRANSACTION_DATE,
    DATEADD(DAY, 2, d.DATE_VAL) AS SETTLEMENT_DATE,
    m.ASSET_CLASS_ID,
    m.MANAGER_ID,
    CASE MOD(ROW_NUMBER() OVER (ORDER BY d.DATE_VAL), 5)
        WHEN 0 THEN 'BUY'
        WHEN 1 THEN 'SELL'
        WHEN 2 THEN 'BUY'
        WHEN 3 THEN 'REBALANCE'
        ELSE 'BUY'
    END AS TRANSACTION_TYPE,
    CASE MOD(ROW_NUMBER() OVER (ORDER BY d.DATE_VAL), 8)
        WHEN 0 THEN 'US Treasury 10Y Note'
        WHEN 1 THEN 'SPDR S&P 500 ETF Trust'
        WHEN 2 THEN 'iShares MSCI EAFE ETF'
        WHEN 3 THEN 'Corporate Bond Fund A'
        WHEN 4 THEN 'Prologis Industrial REIT'
        WHEN 5 THEN 'Vanguard Total Stock Market'
        WHEN 6 THEN 'Infrastructure Fund LP'
        ELSE 'BlackRock Liquidity Fund'
    END AS SECURITY_NAME,
    ROUND(ABS(RANDOM() / 10000000000000000000.0) * 100000 + 1000, 4) AS QUANTITY,
    ROUND(ABS(RANDOM() / 10000000000000000000.0) * 200 + 10, 6) AS PRICE,
    ROUND(ABS(RANDOM() / 10000000000000000000.0) * 50000000 + 1000000, 2) AS AMOUNT,
    'USD',
    CASE MOD(ROW_NUMBER() OVER (ORDER BY d.DATE_VAL), 4)
        WHEN 0 THEN 'Goldman Sachs'
        WHEN 1 THEN 'Morgan Stanley'
        WHEN 2 THEN 'JP Morgan'
        ELSE 'Bank of America'
    END AS BROKER
FROM INVESTMENT_MANAGERS m
CROSS JOIN (
    SELECT DATEADD(DAY, SEQ4() * 3, '2022-01-05')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 400))
) d
WHERE m.STATUS = 'ACTIVE'
  AND d.DATE_VAL <= CURRENT_DATE()
  AND MOD(ABS(HASH(m.MANAGER_ID || d.DATE_VAL::VARCHAR)), 40) = 0;

-- ============================================================================
-- 6. BENCHMARKS - Monthly benchmark data
-- ============================================================================
INSERT INTO BENCHMARKS (BENCHMARK_ID, AS_OF_DATE, BENCHMARK_NAME, ASSET_CLASS_ID, RETURN_1M, RETURN_3M, RETURN_YTD, RETURN_1Y, RETURN_3Y, RETURN_5Y, VOLATILITY_1Y)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL, ac.ASSET_CLASS_ID) AS BENCHMARK_ID,
    d.DATE_VAL AS AS_OF_DATE,
    ac.BENCHMARK_INDEX AS BENCHMARK_NAME,
    ac.ASSET_CLASS_ID,
    ROUND((CASE ac.ASSET_CLASS_ID
        WHEN 1 THEN 0.007 WHEN 2 THEN 0.006 WHEN 3 THEN 0.003 WHEN 4 THEN 0.010
        WHEN 5 THEN 0.005 WHEN 6 THEN 0.004 WHEN 7 THEN 0.003 ELSE 0.003
    END) + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS RETURN_1M,
    ROUND(0.02 + (RANDOM() / 10000000000000000000.0) * 0.06 - 0.03, 6) AS RETURN_3M,
    ROUND(0.04 + (RANDOM() / 10000000000000000000.0) * 0.10 - 0.05, 6) AS RETURN_YTD,
    ROUND(0.07 + (RANDOM() / 10000000000000000000.0) * 0.14 - 0.07, 6) AS RETURN_1Y,
    ROUND(0.065 + (RANDOM() / 10000000000000000000.0) * 0.05 - 0.025, 6) AS RETURN_3Y,
    ROUND(0.075 + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS RETURN_5Y,
    ROUND((CASE ac.ASSET_CLASS_ID
        WHEN 1 THEN 0.16 WHEN 2 THEN 0.18 WHEN 3 THEN 0.05 WHEN 4 THEN 0.22
        WHEN 5 THEN 0.12 WHEN 6 THEN 0.10 WHEN 7 THEN 0.08 ELSE 0.01
    END) + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS VOLATILITY_1Y
FROM ASSET_CLASSES ac
CROSS JOIN (
    SELECT DATEADD(MONTH, SEQ4(), '2022-01-31')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 36))
) d
WHERE d.DATE_VAL <= CURRENT_DATE();

-- ============================================================================
-- 7. RISK_METRICS - Monthly risk metrics per manager
-- ============================================================================
INSERT INTO RISK_METRICS (RISK_ID, AS_OF_DATE, ASSET_CLASS_ID, MANAGER_ID, VAR_95, VAR_99, TRACKING_ERROR, BETA, VOLATILITY_ANNUALIZED, SHARPE_RATIO, INFORMATION_RATIO, MAX_DRAWDOWN, SORTINO_RATIO)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL, m.MANAGER_ID) AS RISK_ID,
    d.DATE_VAL AS AS_OF_DATE,
    m.ASSET_CLASS_ID,
    m.MANAGER_ID,
    ROUND(-1 * ABS(m.AUM_MILLIONS * 10000 * (CASE m.ASSET_CLASS_ID
        WHEN 1 THEN 0.03 WHEN 2 THEN 0.035 WHEN 3 THEN 0.015 WHEN 4 THEN 0.05
        WHEN 5 THEN 0.025 WHEN 6 THEN 0.02 WHEN 7 THEN 0.02 ELSE 0.005
    END) + (RANDOM() / 10000000000000000000.0) * m.AUM_MILLIONS * 1000), 2) AS VAR_95,
    ROUND(-1 * ABS(m.AUM_MILLIONS * 10000 * (CASE m.ASSET_CLASS_ID
        WHEN 1 THEN 0.045 WHEN 2 THEN 0.05 WHEN 3 THEN 0.022 WHEN 4 THEN 0.07
        WHEN 5 THEN 0.035 WHEN 6 THEN 0.03 WHEN 7 THEN 0.03 ELSE 0.008
    END) + (RANDOM() / 10000000000000000000.0) * m.AUM_MILLIONS * 1500), 2) AS VAR_99,
    ROUND(ABS((RANDOM() / 10000000000000000000.0) * 0.04 + 0.01), 6) AS TRACKING_ERROR,
    ROUND(0.9 + (RANDOM() / 10000000000000000000.0) * 0.4 - 0.2, 4) AS BETA,
    ROUND((CASE m.ASSET_CLASS_ID
        WHEN 1 THEN 0.15 WHEN 2 THEN 0.17 WHEN 3 THEN 0.04 WHEN 4 THEN 0.20
        WHEN 5 THEN 0.11 WHEN 6 THEN 0.09 WHEN 7 THEN 0.07 ELSE 0.01
    END) + (RANDOM() / 10000000000000000000.0) * 0.04 - 0.02, 6) AS VOLATILITY_ANNUALIZED,
    ROUND(0.5 + (RANDOM() / 10000000000000000000.0) * 1.5, 4) AS SHARPE_RATIO,
    ROUND(-0.2 + (RANDOM() / 10000000000000000000.0) * 1.0, 4) AS INFORMATION_RATIO,
    ROUND(-0.02 - ABS((RANDOM() / 10000000000000000000.0) * 0.15), 6) AS MAX_DRAWDOWN,
    ROUND(0.4 + (RANDOM() / 10000000000000000000.0) * 2.0, 4) AS SORTINO_RATIO
FROM INVESTMENT_MANAGERS m
CROSS JOIN (
    SELECT DATEADD(MONTH, SEQ4(), '2022-01-31')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 36))
) d
WHERE m.STATUS = 'ACTIVE'
  AND d.DATE_VAL <= CURRENT_DATE();

-- ============================================================================
-- 8. COMPLIANCE_EVENTS - ~80 compliance events over 3 years
-- ============================================================================
INSERT INTO COMPLIANCE_EVENTS (EVENT_ID, EVENT_DATE, ASSET_CLASS_ID, MANAGER_ID, EVENT_TYPE, SEVERITY, DESCRIPTION, POLICY_REFERENCE, RESOLUTION_STATUS, RESOLUTION_DATE, RESOLVED_BY)
VALUES
    (1, '2022-02-15', 1, 2, 'ALLOCATION_BREACH', 'MEDIUM', 'US Equity allocation exceeded maximum of 30% - reached 30.4% due to market appreciation', 'IPS Section 4.2', 'RESOLVED', '2022-02-28', 'Investment Operations'),
    (2, '2022-03-22', 4, 24, 'CONCENTRATION_LIMIT', 'HIGH', 'Single private equity fund exceeded 3% of total portfolio value', 'IPS Section 5.1', 'RESOLVED', '2022-04-15', 'CIO Office'),
    (3, '2022-05-10', 2, 11, 'BENCHMARK_DEVIATION', 'LOW', 'Emerging markets manager tracking error exceeded 5% threshold', 'Manager Guidelines 3.2', 'RESOLVED', '2022-05-20', 'Risk Management'),
    (4, '2022-06-30', 3, 16, 'DURATION_LIMIT', 'MEDIUM', 'Fixed income portfolio duration exceeded +/- 1 year vs benchmark', 'IPS Section 6.3', 'RESOLVED', '2022-07-10', 'Fixed Income Team'),
    (5, '2022-08-15', 5, 33, 'LIQUIDITY_CONCERN', 'HIGH', 'Real estate value-add fund redemption queue exceeded 6 months', 'Liquidity Policy 2.1', 'RESOLVED', '2022-10-01', 'Real Assets Team'),
    (6, '2022-09-01', 1, 50, 'PERFORMANCE_WATCH', 'MEDIUM', 'Legacy Growth Partners underperformed benchmark by 400bps over 12 months', 'Manager Review Policy 4.1', 'RESOLVED', '2022-12-01', 'Manager Research'),
    (7, '2022-10-20', 7, 44, 'STYLE_DRIFT', 'LOW', 'Quantitative hedge fund correlation to equity markets exceeded threshold', 'HF Guidelines 2.4', 'RESOLVED', '2022-11-15', 'Alternatives Team'),
    (8, '2022-12-15', 2, 51, 'TERMINATION_TRIGGER', 'HIGH', 'Pacific Rim Capital - organizational instability, key person departure', 'Manager Review Policy 5.2', 'RESOLVED', '2023-02-01', 'CIO Office'),
    (9, '2023-01-10', 8, 47, 'COUNTERPARTY_RISK', 'MEDIUM', 'Cash management counterparty credit rating downgraded to A-', 'Cash Management Policy 3.1', 'RESOLVED', '2023-01-25', 'Treasury'),
    (10, '2023-02-28', 1, 4, 'ALLOCATION_BREACH', 'LOW', 'Small cap allocation temporarily exceeded sub-asset class limit', 'IPS Section 4.3', 'RESOLVED', '2023-03-05', 'Investment Operations'),
    (11, '2023-03-15', 4, 26, 'VINTAGE_CONCENTRATION', 'MEDIUM', 'Technology PE vintage year concentration exceeded 25% of PE allocation', 'PE Guidelines 3.3', 'RESOLVED', '2023-04-01', 'Private Markets'),
    (12, '2023-04-20', 3, 22, 'CURRENCY_EXPOSURE', 'LOW', 'Global fixed income unhedged currency exposure exceeded 10%', 'FI Guidelines 4.1', 'RESOLVED', '2023-05-01', 'Fixed Income Team'),
    (13, '2023-05-30', 6, 37, 'VALUATION_DELAY', 'MEDIUM', 'Infrastructure fund Q1 valuation received more than 90 days late', 'Valuation Policy 2.3', 'RESOLVED', '2023-06-30', 'Operations'),
    (14, '2023-07-15', 5, 31, 'LEVERAGE_LIMIT', 'HIGH', 'Core real estate fund leverage exceeded 35% LTV policy limit', 'RE Guidelines 5.2', 'RESOLVED', '2023-08-15', 'Real Assets Team'),
    (15, '2023-08-01', 1, 7, 'CONCENTRATION_LIMIT', 'MEDIUM', 'Single equity position exceeded 5% of manager portfolio', 'Equity Guidelines 2.1', 'RESOLVED', '2023-08-10', 'Equity Team'),
    (16, '2023-09-15', 2, 9, 'PERFORMANCE_WATCH', 'MEDIUM', 'International growth manager underperformed by 300bps trailing 12 months', 'Manager Review Policy 4.1', 'RESOLVED', '2023-12-01', 'Manager Research'),
    (17, '2023-10-30', 4, 29, 'COMMITMENT_PACE', 'LOW', 'PE commitment pacing ahead of plan - may exceed annual budget', 'PE Pacing Policy 1.2', 'RESOLVED', '2023-11-15', 'Private Markets'),
    (18, '2023-12-01', 7, 42, 'DRAWDOWN_TRIGGER', 'HIGH', 'Multi-strategy hedge fund max drawdown exceeded -8% threshold', 'HF Guidelines 3.1', 'RESOLVED', '2024-01-15', 'Alternatives Team'),
    (19, '2024-01-15', 3, 17, 'CREDIT_QUALITY', 'MEDIUM', 'Fixed income portfolio average credit quality below investment grade threshold', 'IPS Section 6.2', 'RESOLVED', '2024-02-01', 'Fixed Income Team'),
    (20, '2024-02-28', 1, 3, 'ALLOCATION_BREACH', 'LOW', 'Value equity tilt caused brief style allocation breach', 'IPS Section 4.4', 'RESOLVED', '2024-03-05', 'Investment Operations'),
    (21, '2024-03-15', 5, 35, 'ESG_CONCERN', 'MEDIUM', 'Alternative RE fund GRESB score declined below minimum threshold', 'ESG Policy 2.2', 'RESOLVED', '2024-04-30', 'ESG Team'),
    (22, '2024-04-01', 6, 40, 'OPERATIONAL_ISSUE', 'LOW', 'Infrastructure GP reporting system migration caused data gaps', 'Reporting Standards 1.1', 'RESOLVED', '2024-04-30', 'Operations'),
    (23, '2024-05-15', 2, 13, 'PERFORMANCE_WATCH', 'MEDIUM', 'Quantitative international equity - sustained underperformance vs peers', 'Manager Review Policy 4.1', 'MONITORING', NULL, NULL),
    (24, '2024-06-30', 4, 23, 'ALLOCATION_BREACH', 'LOW', 'Private equity allocation exceeded target due to distribution lag', 'IPS Section 4.2', 'RESOLVED', '2024-07-15', 'Private Markets'),
    (25, '2024-07-20', 1, 1, 'TRACKING_ERROR', 'LOW', 'Index fund tracking error exceeded 10bps threshold briefly', 'Index Guidelines 1.1', 'RESOLVED', '2024-07-25', 'Passive Team'),
    (26, '2024-08-15', 7, 46, 'LIQUIDITY_CONCERN', 'MEDIUM', 'Quantitative hedge fund imposed gating on quarterly redemptions', 'HF Guidelines 4.2', 'MONITORING', NULL, NULL),
    (27, '2024-09-01', 3, 52, 'TERMINATION_TRIGGER', 'HIGH', 'Sentinel Fixed Income - firm closure and wind-down announced', 'Manager Review Policy 5.2', 'RESOLVED', '2024-11-01', 'CIO Office'),
    (28, '2024-10-15', 5, 34, 'PERFORMANCE_WATCH', 'MEDIUM', 'Global REITs manager lagging benchmark significantly over 2 years', 'Manager Review Policy 4.1', 'MONITORING', NULL, NULL),
    (29, '2024-11-01', 2, 14, 'BENCHMARK_DEVIATION', 'LOW', 'International value manager active share below minimum 60% threshold', 'Manager Guidelines 3.1', 'MONITORING', NULL, NULL),
    (30, '2024-12-15', 1, 5, 'ALLOCATION_BREACH', 'MEDIUM', 'Year-end rebalancing delayed causing temporary allocation breach', 'IPS Section 4.2', 'RESOLVED', '2025-01-10', 'Investment Operations');

-- ============================================================================
-- 9. ESG_SCORES - Quarterly ESG data
-- ============================================================================
INSERT INTO ESG_SCORES (ESG_ID, AS_OF_DATE, ASSET_CLASS_ID, MANAGER_ID, ESG_FRAMEWORK, OVERALL_SCORE, ENVIRONMENTAL_SCORE, SOCIAL_SCORE, GOVERNANCE_SCORE, CARBON_INTENSITY, ENERGY_TRANSITION_RISK, RATING_AGENCY)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VAL, m.MANAGER_ID, f.FRAMEWORK) AS ESG_ID,
    d.DATE_VAL AS AS_OF_DATE,
    m.ASSET_CLASS_ID,
    m.MANAGER_ID,
    f.FRAMEWORK AS ESG_FRAMEWORK,
    ROUND(50 + (RANDOM() / 10000000000000000000.0) * 40, 2) AS OVERALL_SCORE,
    ROUND(45 + (RANDOM() / 10000000000000000000.0) * 45, 2) AS ENVIRONMENTAL_SCORE,
    ROUND(50 + (RANDOM() / 10000000000000000000.0) * 40, 2) AS SOCIAL_SCORE,
    ROUND(55 + (RANDOM() / 10000000000000000000.0) * 35, 2) AS GOVERNANCE_SCORE,
    ROUND(50 + (RANDOM() / 10000000000000000000.0) * 200, 2) AS CARBON_INTENSITY,
    CASE
        WHEN (RANDOM() / 10000000000000000000.0) > 0.7 THEN 'HIGH'
        WHEN (RANDOM() / 10000000000000000000.0) > 0.3 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS ENERGY_TRANSITION_RISK,
    CASE f.FRAMEWORK
        WHEN 'MSCI_ESG' THEN 'MSCI'
        WHEN 'GRESB' THEN 'GRESB'
        WHEN 'EDCI' THEN 'Burgiss'
    END AS RATING_AGENCY
FROM INVESTMENT_MANAGERS m
CROSS JOIN (
    SELECT DATEADD(MONTH, SEQ4() * 3, '2022-03-31')::DATE AS DATE_VAL
    FROM TABLE(GENERATOR(ROWCOUNT => 12))
) d
CROSS JOIN (
    SELECT 'MSCI_ESG' AS FRAMEWORK UNION ALL
    SELECT 'GRESB' UNION ALL
    SELECT 'EDCI'
) f
WHERE m.STATUS = 'ACTIVE'
  AND m.ASSET_CLASS_ID IN (1, 2, 4, 5)
  AND d.DATE_VAL <= CURRENT_DATE();

-- ============================================================================
-- 10. PROXY_VOTES - Annual proxy voting records
-- ============================================================================
INSERT INTO PROXY_VOTES (VOTE_ID, MEETING_DATE, COMPANY_NAME, TICKER, PROPOSAL_NUMBER, PROPOSAL_CATEGORY, PROPOSAL_DESCRIPTION, MANAGEMENT_RECOMMENDATION, LACERA_VOTE, VOTE_RATIONALE, ISS_RECOMMENDATION, FISCAL_YEAR)
VALUES
    (1, '2023-04-15', 'Apple Inc.', 'AAPL', 1, 'Board Elections', 'Elect Director Tim Cook', 'FOR', 'FOR', 'Strong leadership and shareholder value creation', 'FOR', 2023),
    (2, '2023-04-15', 'Apple Inc.', 'AAPL', 2, 'Executive Compensation', 'Advisory vote on executive compensation', 'FOR', 'AGAINST', 'Pay-performance disconnect exceeds acceptable threshold', 'AGAINST', 2023),
    (3, '2023-04-15', 'Apple Inc.', 'AAPL', 3, 'Environmental', 'Report on climate lobbying activities', 'AGAINST', 'FOR', 'Supports LACERA climate action principles', 'FOR', 2023),
    (4, '2023-05-20', 'Microsoft Corporation', 'MSFT', 1, 'Board Elections', 'Elect Director Satya Nadella', 'FOR', 'FOR', 'Effective board leadership demonstrated', 'FOR', 2023),
    (5, '2023-05-20', 'Microsoft Corporation', 'MSFT', 2, 'Social', 'Report on median gender/racial pay gap', 'AGAINST', 'FOR', 'Aligns with LACERA diversity and inclusion principles', 'FOR', 2023),
    (6, '2023-06-01', 'Exxon Mobil Corp', 'XOM', 1, 'Environmental', 'Set Scope 3 GHG emissions reduction targets', 'AGAINST', 'FOR', 'Critical for energy transition risk management', 'FOR', 2023),
    (7, '2023-06-01', 'Exxon Mobil Corp', 'XOM', 2, 'Governance', 'Independent Board Chair', 'AGAINST', 'FOR', 'Best practice governance - separate Chair/CEO roles', 'FOR', 2023),
    (8, '2023-06-15', 'JPMorgan Chase', 'JPM', 1, 'Executive Compensation', 'Say on Pay', 'FOR', 'FOR', 'Compensation aligned with long-term performance', 'FOR', 2023),
    (9, '2023-06-15', 'JPMorgan Chase', 'JPM', 2, 'Environmental', 'Adopt policy to phase out financing fossil fuels', 'AGAINST', 'FOR', 'Supports LACERA climate commitment', 'AGAINST', 2023),
    (10, '2023-07-10', 'Amazon.com Inc.', 'AMZN', 1, 'Social', 'Commission third-party audit of working conditions', 'AGAINST', 'FOR', 'Human capital management is material risk', 'FOR', 2023),
    (11, '2024-04-10', 'Apple Inc.', 'AAPL', 1, 'Board Elections', 'Elect Director Tim Cook', 'FOR', 'FOR', 'Continued strong performance', 'FOR', 2024),
    (12, '2024-04-10', 'Apple Inc.', 'AAPL', 2, 'Environmental', 'Report on AI energy consumption', 'AGAINST', 'FOR', 'Material risk for long-term sustainability', 'FOR', 2024),
    (13, '2024-05-15', 'Alphabet Inc.', 'GOOGL', 1, 'Governance', 'Eliminate dual-class share structure', 'AGAINST', 'FOR', 'One share one vote is fundamental governance principle', 'FOR', 2024),
    (14, '2024-05-15', 'Alphabet Inc.', 'GOOGL', 2, 'Social', 'Report on AI ethics and human rights impacts', 'AGAINST', 'FOR', 'Critical emerging risk requiring transparency', 'FOR', 2024),
    (15, '2024-06-01', 'Chevron Corp', 'CVX', 1, 'Environmental', 'Set medium-term Scope 3 reduction targets', 'AGAINST', 'FOR', 'Consistent with Paris Agreement alignment', 'FOR', 2024),
    (16, '2024-06-01', 'Chevron Corp', 'CVX', 2, 'Executive Compensation', 'Link executive pay to climate targets', 'AGAINST', 'FOR', 'Incentive alignment with long-term strategy', 'AGAINST', 2024),
    (17, '2024-06-20', 'Tesla Inc.', 'TSLA', 1, 'Executive Compensation', 'Ratify Elon Musk compensation package', 'FOR', 'AGAINST', 'Excessive dilution and pay magnitude concerns', 'AGAINST', 2024),
    (18, '2024-06-20', 'Tesla Inc.', 'TSLA', 2, 'Governance', 'Require independent board chair', 'AGAINST', 'FOR', 'Governance best practice especially given CEO dual role', 'FOR', 2024),
    (19, '2024-07-01', 'Meta Platforms', 'META', 1, 'Social', 'Report on child safety measures', 'AGAINST', 'FOR', 'Material social and regulatory risk', 'FOR', 2024),
    (20, '2024-07-01', 'Meta Platforms', 'META', 2, 'Governance', 'Recapitalization to eliminate dual-class', 'AGAINST', 'FOR', 'Shareholder rights are foundational', 'FOR', 2024);

-- ============================================================================
-- 11. BOARD_MATERIALS - Monthly board report documents
-- ============================================================================
INSERT INTO BOARD_MATERIALS (MATERIAL_ID, MEETING_DATE, DOCUMENT_TYPE, TITLE, CONTENT, SECTION, PRESENTER, FISCAL_YEAR, QUARTER)
VALUES
    (1, '2024-01-17', 'Monthly Report', 'January 2024 Investment Performance Summary', 'Total fund returned 1.2% for December 2023, outperforming the policy benchmark by 15 basis points. Year-to-date returns stand at 12.4%, exceeding the actuarial assumed rate of 7.0%. US Equity led performance with gains driven by technology sector strength. Fixed Income benefited from falling yields in Q4. Private Equity distributions exceeded capital calls by $200M. The total fund market value stands at $75.8 billion as of December 31, 2023. Asset allocation remains within policy bands across all asset classes. The Investment Staff recommends maintaining current strategic positioning with continued rebalancing toward Real Assets to reach target allocation.', 'Performance', 'Chief Investment Officer', 2024, 1),
    (2, '2024-01-17', 'Monthly Report', 'Risk Management Update - January 2024', 'Portfolio-level Value at Risk (95% confidence) stands at $2.1 billion, representing 2.8% of total fund assets. This is within the acceptable range per the Investment Policy Statement. Key risk observations: (1) Equity market concentration in Magnificent 7 stocks represents 18% of US Equity exposure. (2) Duration positioning in Fixed Income is slightly long relative to benchmark. (3) Private Markets valuations show signs of compression in technology sector. Recommendation: Continue monitoring equity concentration and consider tactical hedge if concentration exceeds 20%.', 'Risk', 'Director of Risk Management', 2024, 1),
    (3, '2024-02-21', 'Monthly Report', 'February 2024 Asset Allocation Review', 'Current asset allocation as of January 31, 2024: US Equity 26.1% (target 25%), International Equity 19.8% (target 20%), Fixed Income 19.5% (target 20%), Private Equity 12.8% (target 12%), Real Estate 9.7% (target 10%), Real Assets 4.5% (target 5%), Hedge Funds 4.8% (target 5%), Cash 2.8% (target 3%). All allocations within policy bands. Real Assets remain below target due to longer deployment timeline for infrastructure commitments made in 2023. Staff plans to make an additional $500M in infrastructure commitments in Q1 2024.', 'Allocation', 'Senior Investment Officer', 2024, 1),
    (4, '2024-03-20', 'Quarterly Report', 'Q4 2023 Private Markets Update', 'Private Equity portfolio returned 2.8% for Q4 2023 and 14.2% for the calendar year. Key highlights: New commitment of $400M to KKR Fund XIV. Two successful exits generated $180M in distributions at 2.4x gross MOIC. Pipeline of three new co-investment opportunities totaling $250M under evaluation. Total unfunded commitments stand at $4.2 billion with projected deployment of $1.5B over next 12 months. Vintage diversification remains healthy with no single vintage exceeding 20% of total PE allocation. Technology and healthcare sectors represent largest exposures.', 'Private Markets', 'Director of Private Markets', 2024, 1),
    (5, '2024-04-17', 'Monthly Report', 'ESG and Sustainability Quarterly Update', 'Portfolio-wide ESG integration continues to advance. Key metrics for Q1 2024: MSCI ESG weighted average rating improved to A from BBB+. Carbon intensity decreased 8% year-over-year to 142 tCO2e per $M revenue. Proxy voting season highlights: Voted on 847 proposals across 312 companies. Supported 78% of environmental and social shareholder proposals. Engaged with 15 portfolio companies on climate transition plans. GRESB scores for real estate portfolio averaged 72 out of 100. Energy transition risk assessment shows 85% of portfolio aligned with 2-degree scenario.', 'ESG', 'ESG Program Manager', 2024, 2),
    (6, '2024-05-15', 'Monthly Report', 'May 2024 Manager Performance Review', 'Quarterly manager review identified three managers for enhanced monitoring: (1) Acadian Asset Management - quantitative international equity strategy has underperformed MSCI EAFE by 280bps over trailing 12 months due to factor headwinds. (2) CBRE Clarion Securities - Global REITs strategy lagging due to interest rate sensitivity. (3) Man AHL Diversified - managed futures returns negative YTD as trend-following models struggle with regime changes. No immediate termination recommendations at this time. Next formal review scheduled for August 2024.', 'Manager Review', 'Manager Research Team', 2024, 2),
    (7, '2024-06-19', 'Monthly Report', 'June 2024 Liquidity and Cash Flow Update', 'Projected benefit payments for FY2024-25: $4.8 billion. Expected contributions: $3.2 billion. Net cash outflow: $1.6 billion (2.1% of fund). Liquidity sources: Cash and short-term investments ($2.1B), public equity/FI rebalancing capacity ($3.5B), expected PE distributions ($1.2B). Total available liquidity of $6.8B provides 4.3x coverage of annual net outflows. Three-year stress test scenario (2008-style drawdown) shows fund maintains ability to meet all benefit obligations without forced asset sales.', 'Liquidity', 'Treasurer', 2024, 2),
    (8, '2024-07-17', 'Monthly Report', 'July 2024 Total Fund Performance Update', 'Total fund market value reached $77.2 billion as of June 30, 2024, a new all-time high. First half 2024 return of 8.1% exceeded the policy benchmark by 45 basis points. Three-year annualized return of 7.8% exceeds the actuarial assumed rate of 7.0%. Funded ratio improved to 72.4% from 70.1% a year ago. All asset classes contributed positively with US Equity and Private Equity leading. Fixed Income performance benefited from credit allocation tilt. Board staff recommends continued execution of current strategic plan with focus on private markets deployment.', 'Performance', 'Chief Investment Officer', 2024, 3),
    (9, '2024-09-18', 'Monthly Report', 'September 2024 Compliance and Governance Report', 'No material compliance violations during Q3 2024. Three minor allocation breaches occurred due to market movements and were corrected within the 5-day rebalancing window per policy. Annual Investment Policy Statement review completed with no material changes recommended. Manager compliance certifications received from all 49 active managers. Proxy voting activity: 100% of proxies voted per policy. Board governance calendar items: Annual asset allocation study scheduled for November, actuarial valuation results expected in October.', 'Compliance', 'General Counsel', 2024, 3),
    (10, '2024-11-20', 'Annual Report', 'FY2024 Annual Investment Report', 'Fiscal Year 2024 total fund return: 9.8% net of fees. Policy benchmark return: 9.2%. Value added: 60 basis points ($450 million). Fund market value as of June 30, 2024: $77.2 billion. Net investment income: $6.9 billion. Benefit payments: $4.7 billion. Contributions received: $3.1 billion. Net cash outflow of $1.6 billion funded entirely from investment returns. Five-year annualized return: 8.4%. Ten-year annualized return: 7.9%. Both exceed the actuarial assumed rate of 7.0%. Investment management fees: $285 million (37 basis points). Total fund Sharpe ratio: 0.62.', 'Annual', 'Chief Investment Officer', 2024, 4);

-- ============================================================================
-- 12. POLICY_DOCUMENTS - Investment policies and guidelines
-- ============================================================================
INSERT INTO POLICY_DOCUMENTS (POLICY_ID, POLICY_NAME, POLICY_CATEGORY, EFFECTIVE_DATE, CONTENT, VERSION, APPROVED_BY, STATUS)
VALUES
    (1, 'Investment Policy Statement', 'Strategic', '2023-07-01', 'The Investment Policy Statement (IPS) establishes the investment objectives, policies, and guidelines for the management of LACERA assets. The primary objective is to maximize long-term risk-adjusted returns while maintaining sufficient liquidity to meet benefit obligations. The target return is the actuarial assumed rate of 7.0% net of fees. The strategic asset allocation targets are: US Equity 25%, International Equity 20%, Fixed Income 20%, Private Equity 12%, Real Estate 10%, Real Assets 5%, Hedge Funds 5%, Cash 3%. Each asset class has a permissible range of plus or minus 5 percentage points from target, except Private Equity and Real Assets which have a range of plus or minus 4 percentage points. Rebalancing shall occur when any asset class deviates from its target by more than 3 percentage points, subject to market conditions and transaction costs.', '4.2', 'Board of Investments', 'ACTIVE'),
    (2, 'Private Equity Investment Guidelines', 'Asset Class', '2023-01-15', 'Private Equity investments shall be diversified across strategy (buyout, growth, venture), geography (domestic, international), vintage year, and sector. No single fund shall exceed 3% of total fund assets at the time of commitment. Annual commitment pacing shall target 3-4% of total fund assets to maintain steady-state allocation of 12%. Co-investments are permitted up to 20% of total PE allocation. Secondary purchases are permitted for portfolio management purposes. Target net IRR: 300 basis points above public equity equivalent over a full market cycle. All PE managers must provide quarterly financial statements and annual audited financials within 90 days of period end.', '3.1', 'Board of Investments', 'ACTIVE'),
    (3, 'ESG Integration Policy', 'Governance', '2023-09-01', 'LACERA integrates Environmental, Social, and Governance (ESG) factors into investment decision-making across all asset classes as a component of fiduciary duty. ESG integration is implemented through: (1) Manager selection - ESG capabilities are evaluated during due diligence and manager selection. (2) Portfolio monitoring - ESG metrics including carbon intensity, diversity scores, and governance ratings are tracked quarterly. (3) Active ownership - LACERA exercises proxy voting rights and engages with portfolio companies on material ESG issues. (4) Climate risk - Portfolio is assessed annually against climate scenarios including 1.5-degree, 2-degree, and baseline scenarios. Target: reduce portfolio carbon intensity by 50% by 2030 relative to 2020 baseline. All new real estate investments must have a GRESB score of 60 or above.', '2.0', 'Board of Investments', 'ACTIVE'),
    (4, 'Risk Management Framework', 'Risk', '2022-11-01', 'The Risk Management Framework establishes the governance structure and processes for identifying, measuring, monitoring, and managing investment risks. Key risk metrics monitored include: Value at Risk (VaR) at 95% and 99% confidence levels, tracking error relative to policy benchmark, factor exposures (market beta, duration, credit spread), liquidity risk (ability to meet 12 months of net cash outflows), concentration risk (no single manager exceeding 5% of total fund). Risk limits: Total fund VaR (95%) shall not exceed 4% of total assets. Maximum drawdown tolerance: -20% from peak over any rolling 12-month period. Stress testing: quarterly scenario analysis covering tail risk events including 2008 financial crisis, 2020 COVID crash, and inflation shock scenarios.', '2.5', 'Board of Investments', 'ACTIVE'),
    (5, 'Manager Selection and Monitoring Policy', 'Operations', '2023-04-01', 'Investment managers are selected through a rigorous due diligence process including quantitative performance analysis, qualitative organizational assessment, and operational due diligence. Minimum criteria for consideration: 5-year track record, $1 billion in strategy AUM, no material regulatory actions. Ongoing monitoring includes: quarterly performance attribution, annual on-site due diligence visits, semi-annual operational risk assessment. Watch list criteria: underperformance exceeding 200 basis points annualized over trailing 3 years, key person departures, organizational instability, compliance violations. Termination triggers: sustained underperformance exceeding 300 basis points over 5 years, material fraud or regulatory action, significant organizational change compromising investment capability.', '3.0', 'CIO Office', 'ACTIVE'),
    (6, 'Proxy Voting Policy', 'Governance', '2023-06-01', 'LACERA votes all proxies for securities held in separately managed accounts in accordance with fiduciary duty and the long-term economic interests of members. Key voting principles: (1) Board independence - support majority independent boards with separate Chair/CEO roles. (2) Executive compensation - oppose pay packages exceeding 300x median employee compensation without clear performance justification. (3) Environmental - support reasonable climate disclosure and emissions reduction proposals. (4) Social - support proposals enhancing workforce diversity, human capital management transparency, and human rights due diligence. (5) Governance - support one share one vote, oppose anti-takeover provisions that entrench management. ISS recommendations are considered but not automatically followed. LACERA maintains custom voting guidelines that prioritize long-term shareholder value.', '2.1', 'Board of Investments', 'ACTIVE'),
    (7, 'Liquidity Management Policy', 'Operations', '2023-03-01', 'LACERA maintains sufficient liquidity to meet all benefit obligations under both normal and stressed market conditions. Liquidity tiers: Tier 1 (immediate, 0-30 days): Cash and money market instruments - minimum 2% of total fund. Tier 2 (short-term, 30-90 days): Public equity and investment grade bonds - minimum 40% of total fund. Tier 3 (medium-term, 90-365 days): Other liquid alternatives and planned distributions. Stress test requirement: the fund must demonstrate ability to meet 24 months of net benefit payments assuming (a) 30% decline in public equity, (b) zero PE/RE distributions, (c) 20% increase in benefit payments. Current projected net outflows: $1.6 billion annually (approximately 2% of total fund).', '1.5', 'Treasurer', 'ACTIVE'),
    (8, 'Real Estate Investment Guidelines', 'Asset Class', '2023-05-01', 'Real estate investments shall be diversified across property type (office, industrial, residential, retail, specialty), geography (domestic primary, domestic secondary, international), and strategy (core, value-add, opportunistic). Target allocation: Core 60%, Value-Add 30%, Opportunistic 10%. Maximum leverage: Core 35% LTV, Value-Add 55% LTV, Opportunistic 65% LTV. All investments in open-end vehicles must have quarterly redemption capability. Closed-end fund terms shall not exceed 10 years plus extensions. ESG requirement: All new investments must achieve minimum GRESB score of 60. NCREIF ODCE Index is the primary benchmark. Target return: NCREIF ODCE + 50bps for core, NCREIF ODCE + 200bps for value-add.', '2.3', 'Board of Investments', 'ACTIVE');

-- ============================================================================
-- 13. MANAGER_RESEARCH - Due diligence notes and research
-- ============================================================================
INSERT INTO MANAGER_RESEARCH (RESEARCH_ID, MANAGER_ID, RESEARCH_DATE, RESEARCH_TYPE, TITLE, CONTENT, ANALYST, RECOMMENDATION, RISK_RATING)
VALUES
    (1, 2, '2024-03-15', 'Annual Review', 'Capital Group Growth Fund - Annual Due Diligence Review', 'Annual on-site due diligence visit to Capital Group offices in Los Angeles. Key findings: (1) Investment team stable with no key departures in past 12 months. Lead PM Sarah Chen has 18 years tenure. (2) AUM growth of 12% YTD has not impacted capacity - strategy can accommodate additional $2B. (3) Performance: +14.2% trailing 12 months vs +12.8% Russell 1000 Growth benchmark. (4) Risk metrics within guidelines: tracking error 3.2%, beta 1.05. (5) ESG integration improving with new dedicated ESG analyst hired Q4 2023. (6) Operational infrastructure upgraded to new OMS in Q1 2024. Recommendation: Maintain current allocation. No concerns identified.', 'Jennifer Walsh', 'MAINTAIN', 'LOW'),
    (2, 9, '2024-06-20', 'Performance Review', 'Baillie Gifford International - Performance Concern Assessment', 'Special performance review triggered by trailing 12-month underperformance of 280bps vs MSCI ACWI ex-US. Analysis: Underperformance attributable to (1) overweight China/HK exposure which declined -15% in period, (2) growth style headwind as value outperformed, (3) concentrated positions in unprofitable technology companies. Mitigating factors: (1) Long-term track record remains strong at +210bps annualized over 10 years, (2) philosophy and process unchanged, (3) key personnel stable. Risk assessment: style headwind may persist in rising rate environment. Recommendation: Place on enhanced monitoring with quarterly review. Consider reducing allocation by 15% if underperformance continues through Q3 2024.', 'Michael Torres', 'WATCH', 'MEDIUM'),
    (3, 23, '2024-01-10', 'New Commitment', 'KKR North America Fund XIV - Commitment Recommendation', 'Recommending $400M commitment to KKR North America Fund XIV. Fund size: $18.5 billion target. Strategy: Large-cap buyouts in North America across healthcare, technology, and financial services. Track record: Fund XII generated 2.1x net MOIC and 18% net IRR. Fund XIII trending toward 1.8x (2019 vintage, still early). Key considerations: (1) KKR operational improvement capabilities remain industry-leading, (2) deal pipeline robust with 15+ proprietary opportunities, (3) Fee terms: 1.5% management fee / 20% carried interest with 8% preferred return. Risk factors: Large fund size may limit returns, competitive market for quality assets. Conclusion: Strong conviction - consistent top-quartile performer with differentiated operational approach.', 'David Park', 'COMMIT', 'LOW'),
    (4, 42, '2024-04-05', 'Operational DD', 'AQR Capital Management - Operational Due Diligence Update', 'Bi-annual operational due diligence assessment. Areas reviewed: (1) Technology infrastructure - systems upgraded to cloud-native architecture in 2023, improving resilience and scalability. (2) Compliance program - no regulatory issues, clean SEC exam in 2023. (3) Business continuity - tested successfully in Q4 2023 with full remote operation capability. (4) Cybersecurity - SOC 2 Type II certification renewed, no material incidents. (5) Valuation - independent pricing sources for 99% of positions, monthly NAV reconciliation. (6) Key person risk - Cliff Asness remains engaged but firm has deep bench of 12 senior PMs. AUM declined from peak but stabilized at $145B. Recommendation: No operational concerns. Maintain allocation.', 'Rachel Kim', 'MAINTAIN', 'LOW'),
    (5, 33, '2024-08-12', 'ESG Assessment', 'Heitman Capital Management - ESG and GRESB Assessment', 'ESG-focused review of Heitman value-add real estate portfolio. GRESB 2024 results: Portfolio score of 68 (up from 63 in 2023). Individual fund scores range from 58 to 78. Key ESG initiatives: (1) LED lighting retrofits across 85% of portfolio (target 100% by 2025), (2) Solar panel installation at 6 industrial properties, (3) Water efficiency programs reducing consumption by 12% YoY, (4) Tenant engagement program achieving 65% participation rate. Carbon intensity: 42 kgCO2e per sqm (down 15% from baseline). Challenges: Older value-add assets have higher capex requirements for energy efficiency. LACERA minimum GRESB threshold is 60 - portfolio meets requirement. Recommendation: Maintain allocation. Request improvement plan for assets scoring below 60.', 'Sarah Johnson', 'MAINTAIN', 'LOW'),
    (6, 16, '2024-05-30', 'Annual Review', 'PIMCO Total Return - Annual Comprehensive Review', 'Comprehensive annual review of PIMCO Total Return Fund. Performance: +5.8% trailing 12 months vs +4.9% Bloomberg Aggregate (90bps excess). Three-year: +2.1% annualized vs +1.4% benchmark. Strategy: Active core-plus with tactical duration, sector rotation, and selective credit. Current positioning: Duration 5.8 years (benchmark 6.2), overweight MBS and investment grade credit, underweight US Treasuries. AUM: $85B in strategy (down from $115B peak). Fee: 30bps - competitive for active core-plus. Team: Stable after 2022 leadership transition. New CIO performing well. Risk: Interest rate volatility could impact short-term returns. Recommendation: Maintain as core fixed income allocation. Performance and risk metrics within acceptable ranges.', 'Thomas Liu', 'MAINTAIN', 'LOW'),
    (7, 46, '2024-09-01', 'Special Review', 'Two Sigma Spectrum - Liquidity and Gating Concern', 'Special review triggered by gating announcement. Two Sigma Spectrum fund imposed 10% quarterly redemption gate effective Q3 2024 due to investor redemption requests exceeding available liquidity. LACERA exposure: $800M (approximately 1% of total fund). Analysis: (1) Gate is temporary measure to protect remaining investors from forced selling, (2) underlying portfolio positions remain liquid - issue is concentration of redemption requests, (3) Two Sigma has committed to lifting gate by Q2 2025 as positions are monetized. Impact assessment: LACERA can submit full redemption request - expected to receive proceeds over 3-4 quarters. Alternative liquidity sources adequate to cover any timing gap. Recommendation: Submit full redemption request. Reallocate proceeds to AQR multi-strategy upon receipt.', 'Michael Torres', 'REDEEM', 'HIGH'),
    (8, 37, '2024-07-20', 'Annual Review', 'Brookfield Infrastructure Partners - Infrastructure Annual Review', 'Annual review of Brookfield Infrastructure open-end fund. Performance: +9.2% trailing 12 months vs CPI+4% benchmark of 7.8%. Strong performance driven by regulated utility assets and data center infrastructure. Portfolio composition: Utilities 35%, Transport 25%, Data/Telecom 20%, Midstream 12%, Other 8%. Geographic mix: North America 55%, Europe 25%, Asia-Pacific 15%, Other 5%. Valuation: NAV growth supported by contracted cash flows with inflation escalators. Leverage: Fund-level 38% LTV, within guidelines. ESG: Strong sustainability credentials - 78% renewable energy exposure. Distribution yield: 5.2% annualized. Recommendation: Maintain allocation. Consider additional commitment of $200M to increase infrastructure exposure toward target.', 'David Park', 'INCREASE', 'LOW');

-- ============================================================================
-- LACERA Intelligence Agent
-- File: 02_create_tables.sql
-- Purpose: Create all tables for LACERA investment data
-- Execution Order: 2 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA RAW;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- 1. ASSET_CLASSES - Asset class taxonomy
-- ============================================================================
CREATE OR REPLACE TABLE ASSET_CLASSES (
    ASSET_CLASS_ID          NUMBER(10,0) PRIMARY KEY,
    ASSET_CLASS_NAME        VARCHAR(100) NOT NULL,
    ASSET_CLASS_CATEGORY    VARCHAR(50),
    TARGET_ALLOCATION_PCT   NUMBER(5,2),
    MIN_ALLOCATION_PCT      NUMBER(5,2),
    MAX_ALLOCATION_PCT      NUMBER(5,2),
    BENCHMARK_INDEX         VARCHAR(200),
    DESCRIPTION             VARCHAR(500),
    IS_ACTIVE               BOOLEAN DEFAULT TRUE,
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 2. INVESTMENT_MANAGERS - External investment manager details
-- ============================================================================
CREATE OR REPLACE TABLE INVESTMENT_MANAGERS (
    MANAGER_ID              NUMBER(10,0) PRIMARY KEY,
    MANAGER_NAME            VARCHAR(200) NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    STRATEGY_TYPE           VARCHAR(100),
    INCEPTION_DATE          DATE,
    AUM_MILLIONS            NUMBER(15,2),
    FEE_BPS                 NUMBER(6,2),
    STATUS                  VARCHAR(20) DEFAULT 'ACTIVE',
    CONTACT_NAME            VARCHAR(200),
    CITY                    VARCHAR(100),
    STATE                   VARCHAR(50),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 3. PORTFOLIO_HOLDINGS - Daily/monthly holdings by asset class and manager
-- ============================================================================
CREATE OR REPLACE TABLE PORTFOLIO_HOLDINGS (
    HOLDING_ID              NUMBER(15,0) PRIMARY KEY,
    AS_OF_DATE              DATE NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    MARKET_VALUE            NUMBER(18,2),
    COST_BASIS              NUMBER(18,2),
    UNREALIZED_GAIN_LOSS    NUMBER(18,2),
    WEIGHT_PCT              NUMBER(8,4),
    SHARES_UNITS            NUMBER(15,4),
    CURRENCY                VARCHAR(3) DEFAULT 'USD',
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 4. PERFORMANCE_RETURNS - Time-weighted returns
-- ============================================================================
CREATE OR REPLACE TABLE PERFORMANCE_RETURNS (
    RETURN_ID               NUMBER(15,0) PRIMARY KEY,
    AS_OF_DATE              DATE NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    PERIOD_TYPE             VARCHAR(20),
    RETURN_1M               NUMBER(10,6),
    RETURN_3M               NUMBER(10,6),
    RETURN_YTD              NUMBER(10,6),
    RETURN_1Y               NUMBER(10,6),
    RETURN_3Y               NUMBER(10,6),
    RETURN_5Y               NUMBER(10,6),
    RETURN_ITD              NUMBER(10,6),
    BENCHMARK_RETURN_1M     NUMBER(10,6),
    BENCHMARK_RETURN_1Y     NUMBER(10,6),
    EXCESS_RETURN_1M        NUMBER(10,6),
    EXCESS_RETURN_1Y        NUMBER(10,6),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 5. TRANSACTIONS - Buy/sell/rebalance activity
-- ============================================================================
CREATE OR REPLACE TABLE TRANSACTIONS (
    TRANSACTION_ID          NUMBER(15,0) PRIMARY KEY,
    TRANSACTION_DATE        DATE NOT NULL,
    SETTLEMENT_DATE         DATE,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    TRANSACTION_TYPE        VARCHAR(30),
    SECURITY_NAME           VARCHAR(300),
    QUANTITY                NUMBER(15,4),
    PRICE                   NUMBER(18,6),
    AMOUNT                  NUMBER(18,2),
    CURRENCY                VARCHAR(3) DEFAULT 'USD',
    BROKER                  VARCHAR(100),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 6. BENCHMARKS - Benchmark indices and returns
-- ============================================================================
CREATE OR REPLACE TABLE BENCHMARKS (
    BENCHMARK_ID            NUMBER(10,0) PRIMARY KEY,
    AS_OF_DATE              DATE NOT NULL,
    BENCHMARK_NAME          VARCHAR(200) NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    RETURN_1M               NUMBER(10,6),
    RETURN_3M               NUMBER(10,6),
    RETURN_YTD              NUMBER(10,6),
    RETURN_1Y               NUMBER(10,6),
    RETURN_3Y               NUMBER(10,6),
    RETURN_5Y               NUMBER(10,6),
    VOLATILITY_1Y           NUMBER(10,6),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 7. RISK_METRICS - VaR, tracking error, beta, volatility
-- ============================================================================
CREATE OR REPLACE TABLE RISK_METRICS (
    RISK_ID                 NUMBER(15,0) PRIMARY KEY,
    AS_OF_DATE              DATE NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    VAR_95                  NUMBER(18,2),
    VAR_99                  NUMBER(18,2),
    TRACKING_ERROR          NUMBER(10,6),
    BETA                    NUMBER(8,4),
    VOLATILITY_ANNUALIZED   NUMBER(10,6),
    SHARPE_RATIO            NUMBER(8,4),
    INFORMATION_RATIO       NUMBER(8,4),
    MAX_DRAWDOWN            NUMBER(10,6),
    SORTINO_RATIO           NUMBER(8,4),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 8. COMPLIANCE_EVENTS - Policy violations and mandate breaches
-- ============================================================================
CREATE OR REPLACE TABLE COMPLIANCE_EVENTS (
    EVENT_ID                NUMBER(10,0) PRIMARY KEY,
    EVENT_DATE              DATE NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    EVENT_TYPE              VARCHAR(50),
    SEVERITY                VARCHAR(20),
    DESCRIPTION             VARCHAR(1000),
    POLICY_REFERENCE        VARCHAR(200),
    RESOLUTION_STATUS       VARCHAR(30),
    RESOLUTION_DATE         DATE,
    RESOLVED_BY             VARCHAR(100),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 9. ESG_SCORES - GRESB, EDCI, MSCI ESG ratings
-- ============================================================================
CREATE OR REPLACE TABLE ESG_SCORES (
    ESG_ID                  NUMBER(10,0) PRIMARY KEY,
    AS_OF_DATE              DATE NOT NULL,
    ASSET_CLASS_ID          NUMBER(10,0) REFERENCES ASSET_CLASSES(ASSET_CLASS_ID),
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    ESG_FRAMEWORK           VARCHAR(50),
    OVERALL_SCORE           NUMBER(8,2),
    ENVIRONMENTAL_SCORE     NUMBER(8,2),
    SOCIAL_SCORE            NUMBER(8,2),
    GOVERNANCE_SCORE        NUMBER(8,2),
    CARBON_INTENSITY        NUMBER(12,2),
    ENERGY_TRANSITION_RISK  VARCHAR(20),
    RATING_AGENCY           VARCHAR(50),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 10. PROXY_VOTES - Corporate governance proxy voting records
-- ============================================================================
CREATE OR REPLACE TABLE PROXY_VOTES (
    VOTE_ID                 NUMBER(10,0) PRIMARY KEY,
    MEETING_DATE            DATE NOT NULL,
    COMPANY_NAME            VARCHAR(200),
    TICKER                  VARCHAR(20),
    PROPOSAL_NUMBER         NUMBER(5,0),
    PROPOSAL_CATEGORY       VARCHAR(100),
    PROPOSAL_DESCRIPTION    VARCHAR(500),
    MANAGEMENT_RECOMMENDATION VARCHAR(20),
    LACERA_VOTE             VARCHAR(20),
    VOTE_RATIONALE          VARCHAR(500),
    ISS_RECOMMENDATION      VARCHAR(20),
    FISCAL_YEAR             NUMBER(4,0),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 11. BOARD_MATERIALS - Monthly board report documents (text for search)
-- ============================================================================
CREATE OR REPLACE TABLE BOARD_MATERIALS (
    MATERIAL_ID             NUMBER(10,0) PRIMARY KEY,
    MEETING_DATE            DATE NOT NULL,
    DOCUMENT_TYPE           VARCHAR(50),
    TITLE                   VARCHAR(300),
    CONTENT                 VARCHAR(16000),
    SECTION                 VARCHAR(100),
    PRESENTER               VARCHAR(100),
    FISCAL_YEAR             NUMBER(4,0),
    QUARTER                 NUMBER(1,0),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 12. POLICY_DOCUMENTS - Investment policies, IPS, guidelines (text for search)
-- ============================================================================
CREATE OR REPLACE TABLE POLICY_DOCUMENTS (
    POLICY_ID               NUMBER(10,0) PRIMARY KEY,
    POLICY_NAME             VARCHAR(200) NOT NULL,
    POLICY_CATEGORY         VARCHAR(100),
    EFFECTIVE_DATE          DATE,
    CONTENT                 VARCHAR(16000),
    VERSION                 VARCHAR(20),
    APPROVED_BY             VARCHAR(100),
    STATUS                  VARCHAR(20) DEFAULT 'ACTIVE',
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 13. MANAGER_RESEARCH - Due diligence notes and research (text for search)
-- ============================================================================
CREATE OR REPLACE TABLE MANAGER_RESEARCH (
    RESEARCH_ID             NUMBER(10,0) PRIMARY KEY,
    MANAGER_ID              NUMBER(10,0) REFERENCES INVESTMENT_MANAGERS(MANAGER_ID),
    RESEARCH_DATE           DATE NOT NULL,
    RESEARCH_TYPE           VARCHAR(50),
    TITLE                   VARCHAR(300),
    CONTENT                 VARCHAR(16000),
    ANALYST                 VARCHAR(100),
    RECOMMENDATION          VARCHAR(30),
    RISK_RATING             VARCHAR(20),
    CREATED_AT              TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

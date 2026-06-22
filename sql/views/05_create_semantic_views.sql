-- ============================================================================
-- LACERA Intelligence Agent
-- File: 05_create_semantic_views.sql
-- Purpose: Create 3 semantic views for Cortex Analyst text-to-SQL
-- Execution Order: 5 of 9
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- SEMANTIC VIEW 1: PORTFOLIO_ANALYTICS_SV
-- Purpose: Holdings, allocations, performance, and attribution analysis
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW PORTFOLIO_ANALYTICS_SV

  TABLES (
    holdings AS LACERA_DB.RAW.PORTFOLIO_HOLDINGS
      PRIMARY KEY (HOLDING_ID)
      COMMENT = 'Monthly portfolio holdings showing market values and weights by manager and asset class',
    asset_classes AS LACERA_DB.RAW.ASSET_CLASSES
      PRIMARY KEY (ASSET_CLASS_ID)
      WITH SYNONYMS ('asset class', 'asset type', 'investment category')
      COMMENT = 'Asset class definitions including targets and benchmarks',
    managers AS LACERA_DB.RAW.INVESTMENT_MANAGERS
      PRIMARY KEY (MANAGER_ID)
      WITH SYNONYMS ('investment manager', 'fund manager', 'external manager')
      COMMENT = 'External investment manager details and AUM',
    performance AS LACERA_DB.RAW.PERFORMANCE_RETURNS
      PRIMARY KEY (RETURN_ID)
      WITH SYNONYMS ('returns', 'investment returns', 'performance data')
      COMMENT = 'Monthly time-weighted returns by manager and asset class',
    transactions AS LACERA_DB.RAW.TRANSACTIONS
      PRIMARY KEY (TRANSACTION_ID)
      COMMENT = 'Buy/sell/rebalance transaction activity'
  )

  RELATIONSHIPS (
    holdings_to_asset_classes AS
      holdings (ASSET_CLASS_ID) REFERENCES asset_classes,
    holdings_to_managers AS
      holdings (MANAGER_ID) REFERENCES managers,
    performance_to_asset_classes AS
      performance (ASSET_CLASS_ID) REFERENCES asset_classes,
    performance_to_managers AS
      performance (MANAGER_ID) REFERENCES managers,
    managers_to_asset_classes AS
      managers (ASSET_CLASS_ID) REFERENCES asset_classes,
    transactions_to_asset_classes AS
      transactions (ASSET_CLASS_ID) REFERENCES asset_classes,
    transactions_to_managers AS
      transactions (MANAGER_ID) REFERENCES managers
  )

  FACTS (
    holdings.market_value_fact AS MARKET_VALUE
      COMMENT = 'Market value of holding in USD',
    holdings.cost_basis_fact AS COST_BASIS
      COMMENT = 'Original cost basis in USD',
    holdings.unrealized_gl_fact AS UNREALIZED_GAIN_LOSS
      COMMENT = 'Unrealized gain or loss (market value minus cost)',
    holdings.weight_pct_fact AS WEIGHT_PCT
      COMMENT = 'Weight of holding as percentage of total fund',
    performance.return_1m_fact AS RETURN_1M
      COMMENT = 'One-month return',
    performance.return_1y_fact AS RETURN_1Y
      COMMENT = 'One-year annualized return',
    performance.return_3y_fact AS RETURN_3Y
      COMMENT = 'Three-year annualized return',
    performance.excess_return_1y_fact AS EXCESS_RETURN_1Y
      COMMENT = 'One-year excess return over benchmark (alpha)',
    transactions.transaction_amount_fact AS AMOUNT
      COMMENT = 'Transaction amount in USD'
  )

  DIMENSIONS (
    holdings.as_of_date AS AS_OF_DATE
      WITH SYNONYMS ('date', 'reporting date', 'period end')
      COMMENT = 'Date of the holdings snapshot',
    asset_classes.asset_class_name AS ASSET_CLASS_NAME
      WITH SYNONYMS ('asset class', 'asset type', 'investment type')
      COMMENT = 'Name of asset class such as US Equity, Fixed Income, Private Equity',
    asset_classes.asset_class_category AS ASSET_CLASS_CATEGORY
      WITH SYNONYMS ('category', 'market type')
      COMMENT = 'Category grouping: Public Markets, Private Markets, Real Assets, Alternatives, Liquidity',
    asset_classes.target_allocation_pct AS TARGET_ALLOCATION_PCT
      WITH SYNONYMS ('target', 'policy target', 'strategic allocation')
      COMMENT = 'Target allocation percentage from Investment Policy Statement',
    asset_classes.benchmark_index AS BENCHMARK_INDEX
      WITH SYNONYMS ('benchmark', 'index')
      COMMENT = 'Benchmark index name for the asset class',
    managers.manager_name AS MANAGER_NAME
      WITH SYNONYMS ('manager', 'fund manager', 'investment manager name')
      COMMENT = 'Name of the external investment manager',
    managers.strategy_type AS STRATEGY_TYPE
      WITH SYNONYMS ('strategy', 'investment style', 'approach')
      COMMENT = 'Investment strategy type such as Active Growth, Passive Index, Buyout',
    managers.status AS MANAGER_STATUS
      WITH SYNONYMS ('manager status', 'active or terminated')
      COMMENT = 'Manager status: ACTIVE or TERMINATED',
    managers.aum_millions AS MANAGER_AUM_MILLIONS
      WITH SYNONYMS ('AUM', 'assets under management')
      COMMENT = 'Assets under management in millions USD allocated by LACERA',
    managers.fee_bps AS FEE_BPS
      WITH SYNONYMS ('fee', 'management fee', 'fee rate')
      COMMENT = 'Management fee in basis points',
    performance.as_of_date AS PERFORMANCE_DATE
      WITH SYNONYMS ('return date', 'performance period')
      COMMENT = 'Date of the performance measurement',
    transactions.transaction_date AS TRANSACTION_DATE
      COMMENT = 'Date the transaction was executed',
    transactions.transaction_type AS TRANSACTION_TYPE
      WITH SYNONYMS ('trade type', 'buy or sell')
      COMMENT = 'Transaction type: BUY, SELL, or REBALANCE'
  )

  METRICS (
    holdings.total_market_value AS SUM(holdings.market_value_fact)
      WITH SYNONYMS ('total value', 'portfolio value', 'total assets', 'AUM')
      COMMENT = 'Total market value of holdings in USD',
    holdings.total_unrealized_gl AS SUM(holdings.unrealized_gl_fact)
      WITH SYNONYMS ('total gain loss', 'unrealized P&L')
      COMMENT = 'Total unrealized gain or loss across holdings',
    holdings.holding_count AS COUNT(HOLDING_ID)
      COMMENT = 'Number of holdings',
    performance.avg_return_1m AS AVG(performance.return_1m_fact)
      WITH SYNONYMS ('average monthly return', 'avg 1 month return')
      COMMENT = 'Average one-month return',
    performance.avg_return_1y AS AVG(performance.return_1y_fact)
      WITH SYNONYMS ('average annual return', 'avg 1 year return')
      COMMENT = 'Average one-year return',
    performance.avg_excess_return AS AVG(performance.excess_return_1y_fact)
      WITH SYNONYMS ('average alpha', 'average excess return', 'value added')
      COMMENT = 'Average one-year excess return (alpha) over benchmark',
    transactions.total_transaction_volume AS SUM(transactions.transaction_amount_fact)
      WITH SYNONYMS ('transaction volume', 'trading volume')
      COMMENT = 'Total dollar volume of transactions',
    transactions.transaction_count AS COUNT(TRANSACTION_ID)
      COMMENT = 'Number of transactions',
    managers.manager_count AS COUNT(DISTINCT managers.MANAGER_ID)
      WITH SYNONYMS ('number of managers', 'manager count')
      COMMENT = 'Count of distinct investment managers'
  )

  COMMENT = 'Semantic view for LACERA portfolio analytics including holdings, allocations, performance attribution, and transaction analysis'

  AI_SQL_GENERATION 'When calculating asset allocation percentages, use the most recent AS_OF_DATE available. When showing performance, default to trailing 1-year returns unless specified otherwise. Round all percentages to 2 decimal places and dollar amounts to whole numbers. Total fund value is approximately $75 billion.'

  AI_QUESTION_CATEGORIZATION 'This view handles questions about portfolio holdings, asset allocation, investment performance, manager returns, benchmarks, and transaction activity. If a question asks about risk metrics, compliance, ESG, or policy documents, indicate that a different tool should be used.';

-- ============================================================================
-- SEMANTIC VIEW 2: RISK_COMPLIANCE_SV
-- Purpose: Risk metrics, compliance events, and scenario analysis
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW RISK_COMPLIANCE_SV

  TABLES (
    risk_metrics AS LACERA_DB.RAW.RISK_METRICS
      PRIMARY KEY (RISK_ID)
      WITH SYNONYMS ('risk data', 'risk analytics', 'risk measures')
      COMMENT = 'Monthly risk metrics by manager and asset class',
    compliance AS LACERA_DB.RAW.COMPLIANCE_EVENTS
      PRIMARY KEY (EVENT_ID)
      WITH SYNONYMS ('compliance events', 'violations', 'breaches')
      COMMENT = 'Compliance events including policy violations and mandate breaches',
    asset_classes AS LACERA_DB.RAW.ASSET_CLASSES
      PRIMARY KEY (ASSET_CLASS_ID)
      COMMENT = 'Asset class reference data',
    managers AS LACERA_DB.RAW.INVESTMENT_MANAGERS
      PRIMARY KEY (MANAGER_ID)
      COMMENT = 'Investment manager reference data'
  )

  RELATIONSHIPS (
    risk_to_asset_classes AS
      risk_metrics (ASSET_CLASS_ID) REFERENCES asset_classes,
    risk_to_managers AS
      risk_metrics (MANAGER_ID) REFERENCES managers,
    compliance_to_asset_classes AS
      compliance (ASSET_CLASS_ID) REFERENCES asset_classes,
    compliance_to_managers AS
      compliance (MANAGER_ID) REFERENCES managers,
    managers_to_asset_classes AS
      managers (ASSET_CLASS_ID) REFERENCES asset_classes
  )

  FACTS (
    risk_metrics.var_95_fact AS VAR_95
      COMMENT = 'Value at Risk at 95% confidence level (negative number representing potential loss)',
    risk_metrics.var_99_fact AS VAR_99
      COMMENT = 'Value at Risk at 99% confidence level',
    risk_metrics.tracking_error_fact AS TRACKING_ERROR
      COMMENT = 'Annualized tracking error vs benchmark',
    risk_metrics.beta_fact AS BETA
      COMMENT = 'Market beta exposure',
    risk_metrics.volatility_fact AS VOLATILITY_ANNUALIZED
      COMMENT = 'Annualized volatility of returns',
    risk_metrics.sharpe_fact AS SHARPE_RATIO
      COMMENT = 'Sharpe ratio - risk-adjusted return measure',
    risk_metrics.info_ratio_fact AS INFORMATION_RATIO
      COMMENT = 'Information ratio - excess return per unit of tracking error',
    risk_metrics.max_dd_fact AS MAX_DRAWDOWN
      COMMENT = 'Maximum drawdown from peak to trough',
    risk_metrics.sortino_fact AS SORTINO_RATIO
      COMMENT = 'Sortino ratio - downside risk-adjusted return'
  )

  DIMENSIONS (
    risk_metrics.as_of_date AS RISK_DATE
      WITH SYNONYMS ('date', 'risk date', 'measurement date')
      COMMENT = 'Date of risk measurement',
    asset_classes.asset_class_name AS ASSET_CLASS_NAME
      WITH SYNONYMS ('asset class', 'asset type')
      COMMENT = 'Asset class name',
    asset_classes.asset_class_category AS ASSET_CLASS_CATEGORY
      COMMENT = 'Asset class category grouping',
    managers.manager_name AS MANAGER_NAME
      WITH SYNONYMS ('manager', 'investment manager')
      COMMENT = 'Investment manager name',
    managers.strategy_type AS STRATEGY_TYPE
      COMMENT = 'Investment strategy type',
    compliance.event_date AS COMPLIANCE_EVENT_DATE
      WITH SYNONYMS ('violation date', 'breach date')
      COMMENT = 'Date the compliance event occurred',
    compliance.event_type AS COMPLIANCE_EVENT_TYPE
      WITH SYNONYMS ('violation type', 'breach type')
      COMMENT = 'Type of compliance event such as ALLOCATION_BREACH, PERFORMANCE_WATCH, CONCENTRATION_LIMIT',
    compliance.severity AS COMPLIANCE_SEVERITY
      WITH SYNONYMS ('severity level', 'risk level')
      COMMENT = 'Severity of the compliance event: HIGH, MEDIUM, or LOW',
    compliance.resolution_status AS RESOLUTION_STATUS
      WITH SYNONYMS ('status', 'resolved or open')
      COMMENT = 'Resolution status: RESOLVED, MONITORING, or OPEN',
    compliance.description AS COMPLIANCE_DESCRIPTION
      COMMENT = 'Detailed description of the compliance event',
    compliance.policy_reference AS POLICY_REFERENCE
      COMMENT = 'Reference to the policy section that was breached'
  )

  METRICS (
    risk_metrics.avg_var_95 AS AVG(risk_metrics.var_95_fact)
      WITH SYNONYMS ('average VaR', 'portfolio VaR')
      COMMENT = 'Average Value at Risk at 95% confidence',
    risk_metrics.total_var_95 AS SUM(risk_metrics.var_95_fact)
      WITH SYNONYMS ('total VaR', 'aggregate VaR')
      COMMENT = 'Total portfolio Value at Risk at 95%',
    risk_metrics.avg_sharpe AS AVG(risk_metrics.sharpe_fact)
      WITH SYNONYMS ('average Sharpe', 'portfolio Sharpe ratio')
      COMMENT = 'Average Sharpe ratio across managers',
    risk_metrics.avg_tracking_error AS AVG(risk_metrics.tracking_error_fact)
      COMMENT = 'Average tracking error across managers',
    risk_metrics.avg_volatility AS AVG(risk_metrics.volatility_fact)
      WITH SYNONYMS ('average volatility', 'portfolio volatility')
      COMMENT = 'Average annualized volatility',
    risk_metrics.worst_drawdown AS MIN(risk_metrics.max_dd_fact)
      WITH SYNONYMS ('worst drawdown', 'maximum loss')
      COMMENT = 'Worst maximum drawdown across all managers',
    compliance.compliance_event_count AS COUNT(compliance.EVENT_ID)
      WITH SYNONYMS ('number of violations', 'compliance count', 'breach count')
      COMMENT = 'Total count of compliance events',
    compliance.high_severity_count AS COUNT_IF(compliance.SEVERITY = 'HIGH')
      WITH SYNONYMS ('critical violations', 'high priority events')
      COMMENT = 'Count of HIGH severity compliance events'
  )

  COMMENT = 'Semantic view for LACERA risk analytics and compliance monitoring including VaR, volatility, Sharpe ratios, and policy violation tracking'

  AI_SQL_GENERATION 'VaR values are negative numbers representing potential losses. When reporting VaR, show the absolute value with appropriate context. Sharpe ratios above 1.0 are generally considered good. Tracking error is annualized. For compliance events, default to showing the most recent events first.'

  AI_QUESTION_CATEGORIZATION 'This view handles questions about risk metrics (VaR, volatility, Sharpe ratio, tracking error, beta, drawdown), compliance events, policy violations, and mandate breaches. If a question is about portfolio allocations, performance returns, ESG scores, or policy documents, indicate a different tool should be used.';

-- ============================================================================
-- SEMANTIC VIEW 3: ESG_GOVERNANCE_SV
-- Purpose: ESG scores, proxy voting, and sustainability metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW ESG_GOVERNANCE_SV

  TABLES (
    esg_scores AS LACERA_DB.RAW.ESG_SCORES
      PRIMARY KEY (ESG_ID)
      WITH SYNONYMS ('ESG data', 'sustainability scores', 'ESG ratings')
      COMMENT = 'Quarterly ESG scores from MSCI, GRESB, and EDCI frameworks',
    proxy_votes AS LACERA_DB.RAW.PROXY_VOTES
      PRIMARY KEY (VOTE_ID)
      WITH SYNONYMS ('proxy voting', 'shareholder votes', 'corporate governance votes')
      COMMENT = 'Annual proxy voting records on shareholder proposals',
    asset_classes AS LACERA_DB.RAW.ASSET_CLASSES
      PRIMARY KEY (ASSET_CLASS_ID)
      COMMENT = 'Asset class reference data',
    managers AS LACERA_DB.RAW.INVESTMENT_MANAGERS
      PRIMARY KEY (MANAGER_ID)
      COMMENT = 'Investment manager reference data'
  )

  RELATIONSHIPS (
    esg_to_asset_classes AS
      esg_scores (ASSET_CLASS_ID) REFERENCES asset_classes,
    esg_to_managers AS
      esg_scores (MANAGER_ID) REFERENCES managers,
    managers_to_asset_classes AS
      managers (ASSET_CLASS_ID) REFERENCES asset_classes
  )

  FACTS (
    esg_scores.overall_score_fact AS OVERALL_SCORE
      COMMENT = 'Overall ESG composite score (0-100)',
    esg_scores.environmental_fact AS ENVIRONMENTAL_SCORE
      COMMENT = 'Environmental pillar score (0-100)',
    esg_scores.social_fact AS SOCIAL_SCORE
      COMMENT = 'Social pillar score (0-100)',
    esg_scores.governance_fact AS GOVERNANCE_SCORE
      COMMENT = 'Governance pillar score (0-100)',
    esg_scores.carbon_fact AS CARBON_INTENSITY
      COMMENT = 'Carbon intensity in tonnes CO2e per million dollars revenue'
  )

  DIMENSIONS (
    esg_scores.as_of_date AS ESG_DATE
      WITH SYNONYMS ('date', 'reporting date', 'quarter end')
      COMMENT = 'Date of ESG score measurement (quarterly)',
    esg_scores.esg_framework AS ESG_FRAMEWORK
      WITH SYNONYMS ('framework', 'rating system', 'methodology')
      COMMENT = 'ESG framework: MSCI_ESG, GRESB, or EDCI',
    esg_scores.energy_transition_risk AS ENERGY_TRANSITION_RISK
      WITH SYNONYMS ('transition risk', 'climate risk level')
      COMMENT = 'Energy transition risk level: HIGH, MEDIUM, or LOW',
    esg_scores.rating_agency AS RATING_AGENCY
      COMMENT = 'ESG rating agency name',
    asset_classes.asset_class_name AS ASSET_CLASS_NAME
      WITH SYNONYMS ('asset class', 'asset type')
      COMMENT = 'Asset class name',
    managers.manager_name AS MANAGER_NAME
      WITH SYNONYMS ('manager', 'fund manager')
      COMMENT = 'Investment manager name',
    proxy_votes.meeting_date AS PROXY_MEETING_DATE
      WITH SYNONYMS ('meeting date', 'AGM date')
      COMMENT = 'Date of the shareholder meeting',
    proxy_votes.company_name AS COMPANY_NAME
      WITH SYNONYMS ('company', 'issuer')
      COMMENT = 'Company name for the proxy vote',
    proxy_votes.proposal_category AS PROPOSAL_CATEGORY
      WITH SYNONYMS ('proposal type', 'vote category')
      COMMENT = 'Category of proposal: Environmental, Social, Governance, Board Elections, Executive Compensation',
    proxy_votes.lacera_vote AS LACERA_VOTE
      WITH SYNONYMS ('our vote', 'how we voted', 'vote cast')
      COMMENT = 'How LACERA voted: FOR, AGAINST, or ABSTAIN',
    proxy_votes.management_recommendation AS MANAGEMENT_REC
      COMMENT = 'Management recommendation on the proposal',
    proxy_votes.fiscal_year AS PROXY_FISCAL_YEAR
      COMMENT = 'Fiscal year of the proxy vote',
    proxy_votes.vote_rationale AS VOTE_RATIONALE
      COMMENT = 'Reason for the voting decision'
  )

  METRICS (
    esg_scores.avg_overall_score AS AVG(esg_scores.overall_score_fact)
      WITH SYNONYMS ('average ESG score', 'portfolio ESG rating')
      COMMENT = 'Average overall ESG score across the portfolio',
    esg_scores.avg_environmental AS AVG(esg_scores.environmental_fact)
      WITH SYNONYMS ('average E score', 'environmental rating')
      COMMENT = 'Average environmental pillar score',
    esg_scores.avg_social AS AVG(esg_scores.social_fact)
      WITH SYNONYMS ('average S score', 'social rating')
      COMMENT = 'Average social pillar score',
    esg_scores.avg_governance AS AVG(esg_scores.governance_fact)
      WITH SYNONYMS ('average G score', 'governance rating')
      COMMENT = 'Average governance pillar score',
    esg_scores.avg_carbon_intensity AS AVG(esg_scores.carbon_fact)
      WITH SYNONYMS ('portfolio carbon footprint', 'average carbon')
      COMMENT = 'Average carbon intensity in tCO2e per $M revenue',
    proxy_votes.total_votes AS COUNT(proxy_votes.VOTE_ID)
      WITH SYNONYMS ('total proxy votes', 'number of votes cast')
      COMMENT = 'Total number of proxy votes cast',
    proxy_votes.votes_against_mgmt AS COUNT_IF(proxy_votes.LACERA_VOTE != proxy_votes.MANAGEMENT_RECOMMENDATION)
      WITH SYNONYMS ('dissent votes', 'votes against management')
      COMMENT = 'Number of votes where LACERA voted against management recommendation'
  )

  COMMENT = 'Semantic view for LACERA ESG analytics and corporate governance including sustainability scores, carbon metrics, and proxy voting analysis'

  AI_SQL_GENERATION 'ESG scores range from 0 to 100 with higher being better. Carbon intensity is measured in tonnes CO2 equivalent per million dollars of revenue - lower is better. When analyzing proxy votes, distinguish between FOR and AGAINST votes relative to management recommendations. GRESB scores are specific to real estate investments.'

  AI_QUESTION_CATEGORIZATION 'This view handles questions about ESG scores, sustainability metrics, carbon intensity, energy transition risk, GRESB ratings, proxy voting records, corporate governance, and shareholder engagement. If a question is about portfolio performance, risk metrics, or investment policy text, indicate a different tool should be used.';

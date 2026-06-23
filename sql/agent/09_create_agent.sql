-- ============================================================================
-- LACERA Intelligence Agent
-- File: 09_create_agent.sql
-- Purpose: Create the LACERA Intelligence Agent with all tools configured
-- Execution Order: 9 of 9 (final step)
-- ============================================================================

USE DATABASE LACERA_DB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE LACERA_WH;

-- ============================================================================
-- Create the LACERA Intelligence Agent
-- Tools: 3 Semantic Views + 3 Cortex Search + 3 ML Functions = 9 tools
-- ============================================================================
CREATE OR REPLACE AGENT LACERA_DB.ANALYTICS.LACERA_AGENT
  COMMENT = 'LACERA Intelligence Agent - Natural language interface for investment analytics, risk monitoring, ESG reporting, and policy search for the Los Angeles County Employees Retirement Association ($75B pension fund)'
  PROFILE = '{"display_name": "LACERA Investment Assistant", "color": "blue"}'
  FROM SPECIFICATION
$$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 360
    tokens: 32000

instructions:
  system: "You are the LACERA Intelligence Agent for the Los Angeles County Employees Retirement Association, managing approximately 75 billion dollars in assets for over 180,000 members. You help investment staff, the CIO, the Board of Investments, and compliance teams analyze portfolio data, monitor risks, track ESG metrics, and access investment policies."
  orchestration: "Route questions about portfolio holdings, asset allocation, performance returns, manager details, and transactions to the portfolio_analytics tool. Route questions about risk metrics (VaR, volatility, Sharpe ratio, tracking error, drawdowns), compliance events, and policy violations to the risk_compliance tool. Route questions about ESG scores, sustainability, carbon intensity, proxy voting, and corporate governance to the esg_governance tool. For questions about investment policies or guidelines, use policy_search. For board meeting materials, use board_search. For manager research, use manager_search. For return forecasts, use forecast_returns. For risk anomalies, use risk_anomalies. For manager scoring, use manager_scoring."
  response: "Provide clear, concise answers suitable for investment professionals. Use appropriate formatting: percentages to 2 decimal places, dollar amounts with proper notation. When discussing returns, always clarify the time period. When presenting risk metrics, provide context. For compliance events, include severity and resolution status."
  sample_questions:
    - question: "What is our current asset allocation across all asset classes?"
    - question: "Which managers are underperforming their benchmarks?"
    - question: "Are there any open compliance violations?"
    - question: "What is our portfolio-wide ESG score?"
    - question: "What does our Investment Policy Statement say about private equity allocation limits?"
    - question: "What were the key highlights from the most recent board performance report?"
    - question: "What are the forecasted returns for US Equity over the next 6 months?"
    - question: "Are there any risk anomalies detected in the last 90 days?"
    - question: "How are our managers ranked by composite score?"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "portfolio_analytics"
      description: "Query LACERA portfolio data including holdings, asset allocation, performance returns, investment managers, and transactions. Use for questions about total fund value, asset class weights, manager AUM, return comparisons, and trading activity."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "risk_compliance"
      description: "Query LACERA risk metrics and compliance data including Value at Risk (VaR), volatility, Sharpe ratios, tracking error, beta, maximum drawdown, and compliance events such as policy violations and mandate breaches."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "esg_governance"
      description: "Query LACERA ESG and governance data including MSCI ESG scores, GRESB ratings, EDCI metrics, carbon intensity, energy transition risk, proxy voting records, and shareholder engagement activities."
  - tool_spec:
      type: "cortex_search"
      name: "policy_search"
      description: "Search LACERA investment policy documents including the Investment Policy Statement (IPS), asset class guidelines, ESG integration policy, risk management framework, manager selection policy, proxy voting policy, and liquidity management policy."
  - tool_spec:
      type: "cortex_search"
      name: "board_search"
      description: "Search LACERA Board of Investments meeting materials including monthly performance reports, quarterly reviews, risk management updates, asset allocation studies, and annual investment reports."
  - tool_spec:
      type: "cortex_search"
      name: "manager_search"
      description: "Search LACERA investment manager research and due diligence materials including annual reviews, performance assessments, operational due diligence reports, ESG evaluations, and special reviews."
  - tool_spec:
      type: "generic"
      name: "forecast_returns"
      description: "Generate return forecasts for a specified asset class over a given time horizon using exponential smoothing with momentum adjustment. Provides point forecast with 95% confidence intervals."
      input_schema:
        type: "object"
        properties:
          asset_class:
            type: "string"
            description: "Asset class name to forecast (e.g., US Equity, Fixed Income, Private Equity)"
          horizon_months:
            type: "number"
            description: "Number of months to forecast (1-12)"
        required:
          - "asset_class"
          - "horizon_months"
  - tool_spec:
      type: "generic"
      name: "risk_anomalies"
      description: "Detect anomalies in risk metrics (volatility, tracking error, drawdowns) using statistical Z-score analysis. Returns managers with unusual risk readings that may indicate emerging problems."
      input_schema:
        type: "object"
        properties:
          lookback_days:
            type: "number"
            description: "Number of days to look back for anomaly detection (default 90)"
        required:
          - "lookback_days"
  - tool_spec:
      type: "generic"
      name: "manager_scoring"
      description: "Score and rank all active investment managers using a multi-factor composite model. Factors: return performance (30%), risk-adjusted returns via Sharpe ratio (30%), consistency of returns (25%), and fee efficiency (15%). Returns managers ranked by quartile."

tool_resources:
  portfolio_analytics:
    semantic_view: "LACERA_DB.ANALYTICS.PORTFOLIO_ANALYTICS_SV"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  risk_compliance:
    semantic_view: "LACERA_DB.ANALYTICS.RISK_COMPLIANCE_SV"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  esg_governance:
    semantic_view: "LACERA_DB.ANALYTICS.ESG_GOVERNANCE_SV"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  policy_search:
    search_service: "LACERA_DB.ANALYTICS.POLICY_SEARCH"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  board_search:
    search_service: "LACERA_DB.ANALYTICS.BOARD_MATERIALS_SEARCH"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  manager_search:
    search_service: "LACERA_DB.ANALYTICS.MANAGER_RESEARCH_SEARCH"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 299
  forecast_returns:
    type: "function"
    identifier: "LACERA_DB.ANALYTICS.FORECAST_RETURNS"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 120
  risk_anomalies:
    type: "function"
    identifier: "LACERA_DB.ANALYTICS.DETECT_RISK_ANOMALIES"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 120
  manager_scoring:
    type: "function"
    identifier: "LACERA_DB.ANALYTICS.SCORE_MANAGER_PERFORMANCE"
    execution_environment:
      type: "warehouse"
      warehouse: "LACERA_WH"
      query_timeout: 120
$$;

-- ============================================================================
-- Verify Agent Creation
-- ============================================================================
SHOW AGENTS LIKE 'LACERA_AGENT' IN SCHEMA LACERA_DB.ANALYTICS;
DESCRIBE AGENT LACERA_DB.ANALYTICS.LACERA_AGENT;

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
  FROM SPECIFICATION $spec$
{
  "models": {
    "orchestration": "auto"
  },
  "orchestration": {
    "budget": {
      "seconds": 360,
      "tokens": 32000
    }
  },
  "instructions": {
    "system": "You are the LACERA Intelligence Agent - a specialized assistant for the Los Angeles County Employees Retirement Association (LACERA), one of the largest county retirement systems in the United States managing approximately $75 billion in assets for over 180,000 members. You help investment staff, the CIO, the Board of Investments, and compliance teams analyze portfolio data, monitor risks, track ESG metrics, and access investment policies.",
    "orchestration": "Route questions about portfolio holdings, asset allocation, performance returns, manager details, and transactions to the portfolio_analytics tool. Route questions about risk metrics (VaR, volatility, Sharpe ratio, tracking error, drawdowns), compliance events, and policy violations to the risk_compliance tool. Route questions about ESG scores, sustainability, carbon intensity, proxy voting, and corporate governance to the esg_governance tool. For questions about investment policies, guidelines, or IPS sections, use the policy_search tool. For questions about board meeting materials or past presentations, use the board_search tool. For manager due diligence research, use the manager_search tool. For return forecasts, use the forecast_returns tool. For risk anomaly detection, use the risk_anomalies tool. For manager scoring and rankings, use the manager_scoring tool.",
    "response": "Provide clear, concise answers suitable for investment professionals. When presenting financial data, use appropriate formatting: percentages to 2 decimal places, dollar amounts with proper notation (e.g., $75.2B or $2.1M), and dates in standard format. When discussing returns, always clarify the time period. When presenting risk metrics, provide context (e.g., whether a Sharpe ratio is above or below average). For compliance events, always include the severity level and resolution status. Reference specific policies or guidelines when relevant."
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "portfolio_analytics",
        "description": "Query LACERA portfolio data including holdings, asset allocation, performance returns, investment managers, and transactions. Use this for questions about portfolio value, allocations vs targets, manager performance, benchmark comparisons, and trading activity."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "risk_compliance",
        "description": "Query LACERA risk metrics and compliance data including Value at Risk (VaR), volatility, Sharpe ratios, tracking error, beta, drawdowns, and compliance events such as policy violations and mandate breaches."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "esg_governance",
        "description": "Query LACERA ESG and governance data including MSCI ESG scores, GRESB ratings, EDCI metrics, carbon intensity, energy transition risk, proxy voting records, and shareholder engagement activities."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "policy_search",
        "description": "Search LACERA investment policy documents including the Investment Policy Statement (IPS), asset class guidelines, ESG integration policy, risk management framework, manager selection policy, proxy voting policy, and liquidity management policy."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "board_search",
        "description": "Search LACERA Board of Investments meeting materials including monthly performance reports, quarterly reviews, risk management updates, asset allocation studies, and annual investment reports."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "manager_search",
        "description": "Search LACERA investment manager research and due diligence materials including annual reviews, performance assessments, operational due diligence reports, ESG evaluations, and special reviews."
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "forecast_returns",
        "description": "Generate return forecasts for a specified asset class over a given time horizon using exponential smoothing with momentum adjustment. Provides point forecast with confidence intervals. Parameters: asset_class (e.g., 'US Equity'), horizon_months (1-12).",
        "input_schema": {
          "type": "object",
          "properties": {
            "asset_class": {
              "type": "string",
              "description": "Asset class name to forecast (e.g., US Equity, Fixed Income, Private Equity)"
            },
            "horizon_months": {
              "type": "number",
              "description": "Number of months to forecast (1-12)"
            }
          },
          "required": ["asset_class", "horizon_months"]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "risk_anomalies",
        "description": "Detect anomalies in risk metrics (volatility, tracking error, drawdowns) using statistical Z-score analysis. Returns managers with unusual risk readings that may indicate emerging problems. Parameter: lookback_days (number of days to analyze, default 90).",
        "input_schema": {
          "type": "object",
          "properties": {
            "lookback_days": {
              "type": "number",
              "description": "Number of days to look back for anomaly detection (default 90)"
            }
          },
          "required": ["lookback_days"]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "manager_scoring",
        "description": "Score and rank all active investment managers using a multi-factor composite model. Factors include: return performance (30%), risk-adjusted returns via Sharpe ratio (30%), consistency of returns (25%), and fee efficiency (15%). Returns managers ranked by quartile with component scores."
      }
    }
  ],
  "tool_resources": {
    "portfolio_analytics": {
      "semantic_view": "LACERA_DB.ANALYTICS.PORTFOLIO_ANALYTICS_SV",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "risk_compliance": {
      "semantic_view": "LACERA_DB.ANALYTICS.RISK_COMPLIANCE_SV",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "esg_governance": {
      "semantic_view": "LACERA_DB.ANALYTICS.ESG_GOVERNANCE_SV",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "policy_search": {
      "search_service": "LACERA_DB.ANALYTICS.POLICY_SEARCH",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "board_search": {
      "search_service": "LACERA_DB.ANALYTICS.BOARD_MATERIALS_SEARCH",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "manager_search": {
      "search_service": "LACERA_DB.ANALYTICS.MANAGER_RESEARCH_SEARCH",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 299
      }
    },
    "forecast_returns": {
      "type": "function",
      "identifier": "LACERA_DB.ANALYTICS.FORECAST_RETURNS",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 120
      }
    },
    "risk_anomalies": {
      "type": "function",
      "identifier": "LACERA_DB.ANALYTICS.DETECT_RISK_ANOMALIES",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 120
      }
    },
    "manager_scoring": {
      "type": "function",
      "identifier": "LACERA_DB.ANALYTICS.SCORE_MANAGER_PERFORMANCE",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "LACERA_WH",
        "query_timeout": 120
      }
    }
  }
}
$spec$;

-- ============================================================================
-- Verify Agent Creation
-- ============================================================================
SHOW AGENTS LIKE 'LACERA_AGENT' IN SCHEMA LACERA_DB.ANALYTICS;
DESCRIBE AGENT LACERA_DB.ANALYTICS.LACERA_AGENT;

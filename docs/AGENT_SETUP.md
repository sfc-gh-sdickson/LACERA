<img src="images/Snowflake_Logo.svg" width="200">

# LACERA Agent - Setup Guide

## Prerequisites

<table>
<thead>
<tr><th>Requirement</th><th>Details</th></tr>
</thead>
<tbody>
<tr><td>Snowflake Account</td><td>Enterprise Edition or higher with Cortex AI enabled</td></tr>
<tr><td>Role</td><td>ACCOUNTADMIN or role with CREATE DATABASE, CREATE WAREHOUSE, CREATE AGENT privileges</td></tr>
<tr><td>Cortex Access</td><td>SNOWFLAKE.CORTEX_USER database role granted to your role</td></tr>
<tr><td>Region</td><td>AWS US West 2 (Oregon), US East 1, or other Cortex-supported region</td></tr>
</tbody>
</table>

## Step-by-Step Setup

### Step 1: Database and Schema Setup

Execute `sql/setup/01_database_and_schema.sql` to create:
- Database: `LACERA_DB`
- Schemas: `RAW` (ingestion), `ANALYTICS` (consumption)
- Warehouse: `LACERA_WH` (X-Small, auto-suspend 5 min)

```sql
-- Verify after execution
SHOW DATABASES LIKE 'LACERA_DB';
SHOW SCHEMAS IN DATABASE LACERA_DB;
SHOW WAREHOUSES LIKE 'LACERA_WH';
```

### Step 2: Create Tables

Execute `sql/setup/02_create_tables.sql` to create 13 tables in the RAW schema.

```sql
-- Verify
SHOW TABLES IN SCHEMA LACERA_DB.RAW;
-- Expected: 13 tables
```

### Step 3: Load Synthetic Data

Execute `sql/data/03_generate_synthetic_data.sql` to populate all tables with realistic pension fund data.

```sql
-- Verify row counts
SELECT 'ASSET_CLASSES' AS TBL, COUNT(*) AS ROWS FROM LACERA_DB.RAW.ASSET_CLASSES
UNION ALL SELECT 'INVESTMENT_MANAGERS', COUNT(*) FROM LACERA_DB.RAW.INVESTMENT_MANAGERS
UNION ALL SELECT 'PORTFOLIO_HOLDINGS', COUNT(*) FROM LACERA_DB.RAW.PORTFOLIO_HOLDINGS
UNION ALL SELECT 'PERFORMANCE_RETURNS', COUNT(*) FROM LACERA_DB.RAW.PERFORMANCE_RETURNS
UNION ALL SELECT 'RISK_METRICS', COUNT(*) FROM LACERA_DB.RAW.RISK_METRICS;
```

### Step 4: Create Analytical Views

Execute `sql/views/04_create_views.sql` to create 6 reporting views in the ANALYTICS schema.

```sql
-- Verify
SHOW VIEWS IN SCHEMA LACERA_DB.ANALYTICS;
```

### Step 5: Create Semantic Views

Execute `sql/views/05_create_semantic_views.sql` to create 3 semantic views for Cortex Analyst.

```sql
-- Verify
SHOW SEMANTIC VIEWS IN SCHEMA LACERA_DB.ANALYTICS;
-- Expected: PORTFOLIO_ANALYTICS_SV, RISK_COMPLIANCE_SV, ESG_GOVERNANCE_SV
```

### Step 6: Create Cortex Search Services

Execute `sql/search/06_create_cortex_search.sql` to create 3 search services.

```sql
-- Verify (may take a few minutes to build index)
SHOW CORTEX SEARCH SERVICES IN SCHEMA LACERA_DB.ANALYTICS;
-- Expected: POLICY_SEARCH, BOARD_MATERIALS_SEARCH, MANAGER_RESEARCH_SEARCH
```

### Step 7: ML Models (Optional)

Review `notebooks/07_ml_models.ipynb` for model documentation. The models are SQL-based and do not require separate training.

### Step 8: Create ML Functions

Execute `sql/models/08_ml_model_functions.sql` to create 3 ML prediction UDFs.

```sql
-- Verify
SHOW FUNCTIONS IN SCHEMA LACERA_DB.ANALYTICS;
-- Expected: FORECAST_RETURNS, DETECT_RISK_ANOMALIES, SCORE_MANAGER_PERFORMANCE
```

### Step 9: Create the Agent

Execute `sql/agent/09_create_agent.sql` to create the LACERA Intelligence Agent.

```sql
-- Verify
SHOW AGENTS LIKE 'LACERA_AGENT' IN SCHEMA LACERA_DB.ANALYTICS;
DESCRIBE AGENT LACERA_DB.ANALYTICS.LACERA_AGENT;
```

## Granting Access

To allow other roles to use the agent:

```sql
-- Grant usage on the agent
GRANT USAGE ON AGENT LACERA_DB.ANALYTICS.LACERA_AGENT TO ROLE <role_name>;

-- Grant required database/schema access
GRANT USAGE ON DATABASE LACERA_DB TO ROLE <role_name>;
GRANT USAGE ON SCHEMA LACERA_DB.ANALYTICS TO ROLE <role_name>;
```

## Troubleshooting

<table>
<thead>
<tr><th>Issue</th><th>Solution</th></tr>
</thead>
<tbody>
<tr><td>Agent creation fails with permission error</td><td>Ensure your role has CREATE AGENT on LACERA_DB.ANALYTICS</td></tr>
<tr><td>Cortex Search service fails to create</td><td>Verify SNOWFLAKE.CORTEX_USER database role is granted</td></tr>
<tr><td>Semantic view creation error</td><td>Ensure tables exist and have data before creating semantic views</td></tr>
<tr><td>Agent cannot access tools</td><td>Verify USAGE grants on all schemas and REFERENCES on semantic views</td></tr>
<tr><td>ML functions return empty arrays</td><td>Ensure data exists in PERFORMANCE_RETURNS and RISK_METRICS tables</td></tr>
</tbody>
</table>

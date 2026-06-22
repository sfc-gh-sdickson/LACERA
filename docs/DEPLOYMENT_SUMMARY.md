<img src="images/Snowflake_Logo.svg" width="200">

# LACERA Agent - Deployment Summary

## Deployment Status

<table>
<thead>
<tr><th>Component</th><th>Object Name</th><th>Status</th><th>Notes</th></tr>
</thead>
<tbody>
<tr><td>Database</td><td>LACERA_DB</td><td>Ready to Deploy</td><td>Main database for all LACERA objects</td></tr>
<tr><td>Schema - Raw</td><td>LACERA_DB.RAW</td><td>Ready to Deploy</td><td>Ingestion layer with 13 tables</td></tr>
<tr><td>Schema - Analytics</td><td>LACERA_DB.ANALYTICS</td><td>Ready to Deploy</td><td>Consumption layer with views and agent tools</td></tr>
<tr><td>Warehouse</td><td>LACERA_WH</td><td>Ready to Deploy</td><td>X-Small, auto-suspend 5 min</td></tr>
<tr><td>Semantic View 1</td><td>PORTFOLIO_ANALYTICS_SV</td><td>Ready to Deploy</td><td>Holdings, allocations, performance</td></tr>
<tr><td>Semantic View 2</td><td>RISK_COMPLIANCE_SV</td><td>Ready to Deploy</td><td>Risk metrics, compliance events</td></tr>
<tr><td>Semantic View 3</td><td>ESG_GOVERNANCE_SV</td><td>Ready to Deploy</td><td>ESG scores, proxy voting</td></tr>
<tr><td>Search Service 1</td><td>POLICY_SEARCH</td><td>Ready to Deploy</td><td>Investment policy documents</td></tr>
<tr><td>Search Service 2</td><td>BOARD_MATERIALS_SEARCH</td><td>Ready to Deploy</td><td>Board meeting materials</td></tr>
<tr><td>Search Service 3</td><td>MANAGER_RESEARCH_SEARCH</td><td>Ready to Deploy</td><td>Manager due diligence research</td></tr>
<tr><td>ML Function 1</td><td>FORECAST_RETURNS</td><td>Ready to Deploy</td><td>Return forecasting by asset class</td></tr>
<tr><td>ML Function 2</td><td>DETECT_RISK_ANOMALIES</td><td>Ready to Deploy</td><td>Risk anomaly detection</td></tr>
<tr><td>ML Function 3</td><td>SCORE_MANAGER_PERFORMANCE</td><td>Ready to Deploy</td><td>Manager composite scoring</td></tr>
<tr><td>Agent</td><td>LACERA_AGENT</td><td>Ready to Deploy</td><td>9 tools configured</td></tr>
</tbody>
</table>

## Agent Configuration

<table>
<thead>
<tr><th>Setting</th><th>Value</th></tr>
</thead>
<tbody>
<tr><td>Agent Name</td><td>LACERA_DB.ANALYTICS.LACERA_AGENT</td></tr>
<tr><td>Orchestration Model</td><td>auto</td></tr>
<tr><td>Budget - Seconds</td><td>360</td></tr>
<tr><td>Budget - Tokens</td><td>32,000</td></tr>
<tr><td>Total Tools</td><td>9 (3 Semantic Views + 3 Search Services + 3 ML Functions)</td></tr>
<tr><td>Warehouse</td><td>LACERA_WH</td></tr>
<tr><td>Query Timeout</td><td>299 seconds (analyst/search), 120 seconds (ML functions)</td></tr>
</tbody>
</table>

## Data Summary

<table>
<thead>
<tr><th>Metric</th><th>Value</th></tr>
</thead>
<tbody>
<tr><td>Total Fund AUM (synthetic)</td><td>~$75 billion</td></tr>
<tr><td>Asset Classes</td><td>8</td></tr>
<tr><td>Active Investment Managers</td><td>49</td></tr>
<tr><td>Historical Data Period</td><td>January 2022 - Present (36 months)</td></tr>
<tr><td>Monthly Holdings Records</td><td>~1,764</td></tr>
<tr><td>Performance Records</td><td>~1,764</td></tr>
<tr><td>Risk Metric Records</td><td>~1,764</td></tr>
<tr><td>Compliance Events</td><td>30</td></tr>
<tr><td>ESG Score Records</td><td>~1,200</td></tr>
<tr><td>Proxy Voting Records</td><td>20</td></tr>
<tr><td>Policy Documents</td><td>8</td></tr>
<tr><td>Board Materials</td><td>10</td></tr>
<tr><td>Manager Research Notes</td><td>8</td></tr>
</tbody>
</table>

## Execution Checklist

- [ ] Step 1: `sql/setup/01_database_and_schema.sql` - Database, schemas, warehouse
- [ ] Step 2: `sql/setup/02_create_tables.sql` - 13 tables created
- [ ] Step 3: `sql/data/03_generate_synthetic_data.sql` - Synthetic data loaded
- [ ] Step 4: `sql/views/04_create_views.sql` - 6 analytical views
- [ ] Step 5: `sql/views/05_create_semantic_views.sql` - 3 semantic views
- [ ] Step 6: `sql/search/06_create_cortex_search.sql` - 3 search services
- [ ] Step 7: `notebooks/07_ml_models.ipynb` - (Optional) Review ML documentation
- [ ] Step 8: `sql/models/08_ml_model_functions.sql` - 3 ML prediction functions
- [ ] Step 9: `sql/agent/09_create_agent.sql` - Agent created and verified

<img src="images/Snowflake_Logo.svg" width="200">

# LACERA Agent - Test Questions by Tool

Use these questions to test each of the 9 agent tools individually. Each section targets a specific tool to verify it routes and responds correctly.

---

## Tool 1: portfolio_analytics (Cortex Analyst - Semantic View)

Questions that should route to the Portfolio Analytics semantic view:

1. What is our current total fund market value?
2. What is our current asset allocation across all asset classes?
3. How does our actual allocation compare to the policy targets?
4. Which asset classes are over-allocated or under-allocated relative to targets?
5. What are the top 5 managers by assets under management?
6. Show me the performance of US Equity managers over the trailing 12 months
7. Which managers are outperforming their benchmarks this year?
8. Which managers are underperforming their benchmarks by more than 200 basis points?
9. What is the total unrealized gain/loss across the portfolio?
10. How much transaction volume occurred in the last quarter?
11. What is the average 1-year return for Fixed Income managers?
12. How many active investment managers do we have?

---

## Tool 2: risk_compliance (Cortex Analyst - Semantic View)

Questions that should route to the Risk and Compliance semantic view:

13. What is our total portfolio Value at Risk at the 95% confidence level?
14. Which managers have the highest annualized volatility?
15. What is the average Sharpe ratio across the portfolio?
16. Are there any compliance violations in the last 90 days?
17. How many HIGH severity compliance events are currently unresolved?
18. Show me all compliance events related to allocation breaches
19. What is the worst maximum drawdown across all managers?
20. Which managers have tracking error above 4%?
21. What is the average information ratio by asset class?
22. Show me compliance events that are still in MONITORING status
23. What was the most recent compliance violation and what was its severity?

---

## Tool 3: esg_governance (Cortex Analyst - Semantic View)

Questions that should route to the ESG and Governance semantic view:

24. What is our portfolio-wide average ESG score?
25. How have our ESG scores trended over the past year?
26. What is our average carbon intensity across the portfolio?
27. Which managers have HIGH energy transition risk?
28. How many proxy votes did we cast in fiscal year 2024?
29. What percentage of our votes went against management recommendations?
30. Show me all proxy votes on environmental proposals
31. What is the average GRESB score for our real estate managers?
32. Which asset class has the highest average ESG score?
33. How did we vote on executive compensation proposals?
34. What is the average governance score by ESG framework?

---

## Tool 4: policy_search (Cortex Search)

Questions that should route to the Policy Document search service:

35. What does our Investment Policy Statement say about private equity allocation limits?
36. What is our maximum permissible allocation range for US Equity?
37. What are the manager termination triggers per our policy?
38. What is our target return per the IPS?
39. What does our ESG policy say about carbon reduction targets?
40. What are the liquidity stress test requirements?
41. What is the maximum leverage allowed for core real estate?
42. What are our proxy voting principles regarding executive compensation?
43. What is the rebalancing threshold per the Investment Policy Statement?
44. What are the minimum criteria for manager selection?

---

## Tool 5: board_search (Cortex Search)

Questions that should route to the Board Materials search service:

45. What were the key highlights from the most recent board performance report?
46. What was the total fund return for fiscal year 2024?
47. What did the risk management update say about equity concentration?
48. What was the latest update on private markets deployment?
49. What did the liquidity report say about benefit payment coverage?
50. What managers were placed on enhanced monitoring in the May 2024 review?
51. What is the current funded ratio reported to the board?
52. What was discussed about asset allocation in February 2024?

---

## Tool 6: manager_search (Cortex Search)

Questions that should route to the Manager Research search service:

53. What are the current recommendations on Baillie Gifford?
54. What was the rationale for the KKR Fund XIV commitment?
55. What operational concerns were raised about Two Sigma?
56. What is the latest due diligence assessment of Capital Group?
57. What did the ESG review say about Heitman Capital?
58. What is the recommendation for Brookfield Infrastructure?
59. Which managers have a HIGH risk rating in research?
60. What was the PIMCO Total Return annual review conclusion?

---

## Tool 7: forecast_returns (ML Function)

Questions that should route to the return forecasting function:

61. What are the forecasted returns for US Equity over the next 6 months?
62. What are the return forecasts for Fixed Income over the next 3 months?
63. Forecast Private Equity returns for the next 12 months
64. What is the projected return for International Equity next quarter?
65. Give me a 6-month return forecast for Real Estate

---

## Tool 8: risk_anomalies (ML Function)

Questions that should route to the risk anomaly detection function:

66. Are there any risk anomalies detected in the last 90 days?
67. Which managers currently have anomalous risk readings?
68. Detect any critical risk anomalies in the last 60 days
69. Are there any unusual volatility spikes across our managers?
70. Show me risk anomalies from the past 180 days

---

## Tool 9: manager_scoring (ML Function)

Questions that should route to the manager scoring function:

71. How are our managers ranked by composite score?
72. Which managers are in the bottom quartile?
73. What are the top-scoring managers by composite score?
74. Show me the manager performance rankings
75. Which managers have the best risk-adjusted scores?

---

## Multi-Tool Questions (should invoke multiple tools)

76. Compare our actual US Equity allocation to the IPS target and show which managers are driving the deviation
77. What compliance events have occurred for managers that are in the bottom quartile of performance?
78. What does our policy say about the managers currently on the watch list?
79. Summarize the risk profile and ESG scores for our Private Equity portfolio
80. What did the board materials say about managers that currently have risk anomalies?

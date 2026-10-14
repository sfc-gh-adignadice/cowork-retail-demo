# Lab Complete

## Why This Matters

You just experienced Snowflake CoWork. But that is not the real lesson.

The real lesson is this: **enterprise AI that actually deploys requires governance, trust, and action — not just a chat interface.** Every answer Jordan received today was governed by their role, every metric was attributable to a curated definition, every action respected the same security boundary that protects the underlying data.

Jordan walks away able to **independently get answers, generate cited reports, and act on insights — without code, without waiting, without leaving the governed boundary of their enterprise data.**

The Platform Principles you experienced today:
- **Governance travels with the data** — Jordan's row access policy limited results automatically. No one configured this per-agent.
- **AI lives next to governed data** — Every question was answered by querying Snowflake tables directly. No data left the governed boundary.
- **One agent, full business context** — From revenue trends to supplier delays to channel mix — one conversation, no tool-switching.
- **Cost is observable** — Every interaction is metered, attributed, and governable through standard Snowflake cost controls.

CoWork is one component. The Snowflake AI Data Cloud is the competitive advantage.

---

## What You Accomplished

| Time | What You Did | Traditional Equivalent |
|------|-------------|----------------------|
| 5 min | Logged in, oriented, selected agent | Find the right dashboard, check filters |
| 10 min | Identified the decline, found root cause | 2-3 analyst requests (2-5 days) |
| 10 min | Found growth story, compared blender range, tested cannibalization | Second analyst request |
| 10 min | Deep Research cited report on supply disruption | Analyst + BA project (3-5 days) |
| 10 min | Prescriptive meeting brief, shared via Slack | Manual email/Slack + repeat effort weekly |
| **~45 min** | **Full Monday morning workflow** | **1-2 weeks of analyst time** |

---

## Feature Coverage

Each question introduced exactly one new CoWork capability:

| # | Prompt | Feature Taught |
|---|--------|---------------|
| Q0 | "What's on my calendar today?" | Natural language Q&A (ice-breaker) |
| Q1 | "How did H&K perform last week vs the week before?" | Verified Answers |
| Q2 | "Which subcategory drove the decline?" | Conversational context (follow-ups) |
| Q3 | Drill into Kitchen Appliances product-level | Auto-visualization (line chart) |
| Q4 | "Which products declined most?" | Chart customization + cross-table reasoning |
| Q5 | "Why are these products declining?" | Multi-table joins (supplier investigation) |
| Q6 | "What's growing fastest in the last 8 weeks?" | Growth discovery (% change) |
| Q7 | "How do all blenders compare to ProBlend 9000?" | Multi-series comparison chart + chart editing |
| Q8 | "Is ProBlend 9000 cannibalizing existing products?" | Analytical reasoning (not just retrieval) |
| Q9 | Deep Research: Apex impact investigation | Multi-agent cited research |
| Q10 | "Create a PDF of the research output" | Built-in skills + code execution sandbox |
| Q11 | Prescriptive meeting brief prompt | Synthesis from full conversation + structured prompting |
| Q12 | "Share to #merch-planning Slack" | MCP Connector (external action) |

---

## Bonus Activities

| Activity | Feature Taught |
|----------|---------------|
| Create a User Skill ("Monday Category Review") | User Skills (automation) |
| Same question, different role | Row-Level Security inheritance |

---

## Business Outcome Validation

Without running any queries, can you answer these four questions?

1. **What is the business problem this lab addresses?**
   Business users are stuck between stale dashboards and multi-day analyst queues, unable to self-serve on time-sensitive questions.

2. **Why does the Snowflake AI Data Cloud solve it better than alternatives?**
   One agent with full business context, automatic data understanding, day-one usefulness — all within the governed boundary, with no parallel security stack to build.

3. **What would break if a customer tried to build this outside of Snowflake?**
   They'd need to rebuild governance (RBAC, masking, row access) in a separate system, build semantic layers from scratch, manage AI infrastructure, handle data movement, and maintain sync between the analytics layer and the security layer.

4. **How would you explain the production operations story to a VP?**
   "It inherits everything — roles, policies, access controls — automatically. No new security stack to manage. Data never leaves Snowflake. Every answer is attributable. Every credit is observable. And it's available today."

If you can answer all four, the lab has done its job.

---

## What to Do Next

1. **Try with your own data.** Ask your data team to enable CoWork and connect it to your business data.
2. **Start with the question you ask most.** What do you email your analyst about every week?
3. **Create your first User Skill.** Automate the workflow you dread every Monday.
4. **Share with a colleague.** CoWork respects your existing RBAC, so everyone sees only what they should.

---

## Resources

**Official documentation:**
- [Snowflake CoWork Overview](https://docs.snowflake.com/en/user-guide/snowflake-cowork/about-cowork)
- [Using CoWork](https://docs.snowflake.com/en/user-guide/snowflake-cowork/using-cowork)
- [Cortex Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Semantic Views](https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view)
- [Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row-intro)

**Cost and monitoring:**
- [Cortex AI Usage History](https://docs.snowflake.com/en/sql-reference/account-usage/cortex_ai_functions_usage_history)
- [Budgets and Cost Controls](https://docs.snowflake.com/en/user-guide/budgets)

---

*Built for Snowflake World Tour Auckland 2026*

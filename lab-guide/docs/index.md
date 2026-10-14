# How I Start My Day with Snowflake CoWork

## The Problem

> **Business Context:** Every Monday morning, business leaders face the same friction: dashboards are stale, the analyst queue is days long, and decisions can't wait. You know the data exists — revenue by category, supplier performance, product trends — but getting answers means filing a ticket, waiting for a query, and hoping the result matches your question.

In the old world, a category manager's Monday morning looks like this:

- Check a static dashboard (limited view, can't answer new questions)
- Email the analytics team with follow-up questions (2-3 days wait)
- Schedule a meeting to clarify what you actually wanted
- Wait for the revised analysis
- Scramble to prep for your buyer meeting

**What if you could just ask?**

Snowflake CoWork is an AI-powered conversational agent that connects directly to your governed enterprise data. No SQL. No dashboards to build. No waiting. Just ask a question in plain language and get trusted, visualized answers — with the full governance and security your enterprise requires.

---

## Your Scenario

You are **Jordan Chen**, a **Regional Category Manager** at **Mosaic Retail**, a mid-to-large omnichannel retailer based in Auckland. You oversee the Home & Kitchen product category across ANZ.

It's Monday morning. You have a buyer meeting at 2pm, and you need to:

- Check how your category performed last week
- Understand why a key product line is underperforming
- Prepare a brief with supporting data for your buyer meeting
- Share your findings with your merchandise planning team

You're going to do all of this with CoWork — before your first coffee gets cold.

---

## Platform Principles

Before we begin, these are the enduring ideas you should carry forward:

- **Governance travels with the data, not the application.** CoWork inherits every row-access policy, column mask, and RBAC grant your admin already configured. There is no parallel security stack to build or maintain.
- **AI lives next to governed data.** Your questions are answered by an agent that queries your Snowflake tables directly — data never leaves the governed boundary. No data movement, no shadow copies, no ungoverned exports.
- **One agent, full business context.** CoWork combines structured tables, unstructured documents, and external context in a single conversational experience. No tool-switching, no context loss between systems.
- **Cost is observable.** Every CoWork interaction consumes Cortex AI credits. Your admin can monitor usage via `SNOWFLAKE.ACCOUNT_USAGE` views — no surprise bills, full attribution by user and role.

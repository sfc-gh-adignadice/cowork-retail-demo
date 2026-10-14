# Hands on Lab

Welcome to your hands-on lab! This lab uses a fictional hand soap company, "Lather and Leaf," to demonstrate a common retail use case. The story progresses naturally, turning data points into business decisions. * **Purpose:** The final prompt shows the platform's ability to handle **"what-if" scenarios** and provide a concrete, actionable business recommendation. that's been pre-configured in your Snowflake environment.

## 🎯 What You'll Discover

This demo showcases how Snowflake's snowflake-cortex, sentiment-analysis, machine-learning, streamlit, ai capabilities work together to solve real business challenges.

### Learning Objectives
- Understand the pre-configured demo environment
- Explore the data model and business logic through Snowsight interface
- Validate that all components are working correctly
- Get familiar with the demo narrative and value proposition

## 🗄️ Explore Your Environment

Let's start by understanding what's been set up for this demonstration:

### Step 1: Navigate and Validate Your Setup

Use Snowsight's interface to explore your environment:

1. **Browse Available Databases**
   - Navigate to the "Data" section in Snowsight
   - Look for these databases: SNOWFLAKE_INTELLIGENCE, RETAIL_SNOWFLAKE_INTELLIGENCE_DB
   - Explore the database structure using the visual browser

2. **Explore the Data Model Visually**
   - Use Snowsight's data browser to review tables and their relationships
   - Key tables to explore: PRODUCT_SALES, PRODUCT_REVIEWS, INSTAGRAM_PAGE_STREAM, PRODUCT_SALES_ANALYSIS, PRODUCT_INVENTORY
   - Browse sample data to understand the business context

3. **Understand the Business Context**
   - An effective Snowflake Intelligence demo tells a cohesive story that links technical capabilities to real-world business value. The goal is to show how the platform can provide intelligent, data-driven answers by orchestrating multiple data sources and AI services. Frame your demo around a central business narrative. This example uses a fictional hand soap company, "Lather and Leaf," to demonstrate a common retail use case. The story progresses naturally, turning data points into business decisions. * **Purpose:** The final prompt shows the platform's ability to handle **"what-if" scenarios** and provide a concrete, actionable business recommendation.

### Validation Through Interface

Confirm your setup by navigating through Snowsight:
- ✅ **Database Access**: Navigate to each database and confirm you can access them
- ✅ **Schema Exploration**: Browse through the schemas and table structure
- ✅ **Data Validation**: Use Snowsight's preview feature to see sample data
- ✅ **Component Discovery**: Identify the key components and their purposes


## 📊 Semantic Models

This demo includes 3 semantic model files that define the business logic:
- product_inventory.yaml, product_sales_analysis.yaml, product_comments_and_stats.yaml

These models provide consistent definitions for metrics and dimensions used throughout the demo. You'll see how these integrate with the platform's analytical capabilities.



## 🚀 Demo Flow Content

The following sections are part of the hands-on demo experience:

### **Creating the Cortex Agent**

With your files staged, you can now create the agent in the Snowflake UI and connect it to your semantic models.

1.  **Navigate to the Snowflake Intelligence UI:**

      * In Snowsight, go to **AI & ML**.
      * Select **Agents**.
      * Click the **+ Create Agent** button.

2.  **Fill in the Agent Details:**

      * Give your agent a **name** (e.g., `Retail_Analytics_Agent`).
      * Provide a **description** that explains the agent's purpose, such as "An agent to help a direct-to-consumer company analyze sales, inventory, and customer sentiment."

3.  **Add the Semantic Models as Tools:**

      * In the agent creation wizard, go to the **Tools** section.
      * Under the "Cortex Analyst" heading, click the **+ Add** button.
      * Select **Semantic Model File**.
      * Choose the database, schema, and stage you created (`RETAIL_SNOWFLAKE_INTELLIGENCE_DB`, `ANALYTICS`, `SEMANTIC_MODELS`).
      * Select each of your three YAML files from the list (`sales_model.yaml`, `inventory_model.yaml`, `comments_model.yaml`).
      * Select `RETAIL_SNOWFLAKE_INTELLIGENCE_WH` warehouse
      * Add a timeout of 60 seconds
      * Have Cortex create a description 
      * Click **Add**. This will add all three models to your agent.

4.  **Finalize and Create:**

      * Review the agent's details and tools.
      * Click **Create Agent**.

Your new Cortex Agent is now configured and ready to be used in the Snowflake Intelligence chat. You can now use the prompts from the demo to test its functionality.

### **The Narrative and Storyboard**

Frame your demo around a central business narrative. This example uses a fictional hand soap company, "Lather and Leaf," to demonstrate a common retail use case. The story progresses naturally, turning data points into business decisions.

**The Story Flow:**

1.  **Launch:** New seasonal products are released.

2.  **Initial Inquiry:** How are the sales for the new products? The answer should be positive but not yet statistically significant, creating the need for more information.

3.  **Leading Indicators:** Since sales are inconclusive, what other data can we check? This leads to asking about online customer sentiment.
4.  **Sentiment Analysis:** The response shows one product is receiving very positive buzz, suggesting a potential top performer.
5.  **Forecasting & Action:** Based on the strong sentiment, what are the likely future sales? Do we have enough inventory to meet demand, and if not, where can we get more?

***

### **Prompts for Snowflake Intelligence**

These are the key prompts used in the demo, designed to be copy-pasted directly into the Snowflake Intelligence chat. They demonstrate a progression from simple to complex, multi-source questions.

1.  **How are the sales for my 2 newest scents doing?**
    * **Purpose:** This initial query shows Snowflake Intelligence’s ability to summarize structured sales data.

2.  **Are our 2 new scents getting a lot of positive buzz online?**
    * **Purpose:** This highlights the platform’s capability to analyze unstructured data (social media comments, reviews) and provide a sentiment overview.

3.  **What are the latest comments for Peachwood Breeze?**
    * **Purpose:** This illustrates how the platform can retrieve specific, unstructured data points (text comments) to provide tangible evidence that supports the analysis.

4.  **If Peachwood Breeze sells online like previous top performing scents, what will be the likely sales online over the next 12 weeks? And do I have enough inventory to fulfill those sales from my online distribution center?**
    * **Purpose:** This powerful prompt showcases **predictive analytics** and **multi-source querying**, combining a sales forecast with an inventory check.

5.  **I want to be safe and handle online sales of up to 16,000 units. If that happens, are there any distribution centers that are likely to have extra inventory so we can transfer to meet online demand?**
    * **Purpose:** The final prompt shows the platform's ability to handle **"what-if" scenarios** and provide a concrete, actionable business recommendation.

***

### **Key Business Value**

The demo highlights several core values:

* **Actionable Insights:** Snowflake Intelligence doesn't just provide data; it offers a clear path forward. It moves beyond "what happened" to answer "what should we do next."
* **Efficiency:** A complex, multi-faceted analysis that would typically take an analyst days can be completed in minutes using natural language. 
* **Unified Data & AI Platform:** The demo shows how both **structured data** (sales, inventory) and **unstructured data** (customer comments) are accessed and analyzed from a **single, secure platform**. The user doesn't need to know where the data is stored.
* **Democratization of Data:** Business users can get answers to complex questions without needing to know SQL. This empowers anyone in the organization to be data-driven.
* **Trust and Governance:** The entire process operates within Snowflake's secure perimeter, inheriting existing governance and access controls.

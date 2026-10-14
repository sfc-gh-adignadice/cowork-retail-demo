-- =============================================================================
-- Mosaic Retail - CoWork HOL Setup Script
-- Snowflake World Tour Auckland 2026
-- =============================================================================
-- Run this script as ACCOUNTADMIN in each trial account to provision the
-- complete CoWork hands-on lab environment.
--
-- Pre-requisite: The 6 CSV files (daily_sales.csv, products.csv, stores.csv,
-- suppliers.csv, suppliers_contact.csv, role_category_access.csv) must be
-- staged. See Section 6 for staging options.
-- =============================================================================

USE ROLE ACCOUNTADMIN;

-- =============================================================================
-- 1. ACCOUNT-LEVEL SETTINGS
-- =============================================================================

-- Enable cross-region inference (required for Cortex model availability)
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

-- =============================================================================
-- 2. WAREHOUSE
-- =============================================================================

CREATE WAREHOUSE IF NOT EXISTS HOL_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse for CoWork HOL queries';

USE WAREHOUSE HOL_WH;

-- =============================================================================
-- 3. DATABASE AND SCHEMA
-- =============================================================================

CREATE DATABASE IF NOT EXISTS MOSAIC_RETAIL
    COMMENT = 'Mosaic Retail - Omnichannel retailer (ANZ) for CoWork HOL';

USE DATABASE MOSAIC_RETAIL;
CREATE SCHEMA IF NOT EXISTS RETAIL
    COMMENT = 'Core retail data - sales, products, stores, suppliers';
USE SCHEMA RETAIL;

-- =============================================================================
-- 4. TABLES
-- =============================================================================

CREATE OR REPLACE TABLE STORES (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    store_type VARCHAR(20) NOT NULL,
    opened_date DATE,
    sqm INT
);

CREATE OR REPLACE TABLE SUPPLIERS (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    lead_time_days INT,
    reliability_score INT,
    delivery_delay_days INT DEFAULT 0,
    delay_start_date DATE,
    expected_resolution_date DATE,
    primary_category VARCHAR(50)
);

CREATE OR REPLACE TABLE SUPPLIERS_CONTACT (
    supplier_id INT REFERENCES SUPPLIERS(supplier_id),
    contact_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(200) NOT NULL,
    contact_phone VARCHAR(50)
);

CREATE OR REPLACE TABLE PRODUCTS (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    department VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50) NOT NULL,
    supplier_id INT REFERENCES SUPPLIERS(supplier_id),
    unit_cost NUMBER(10,2),
    unit_price NUMBER(10,2),
    launch_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE OR REPLACE TABLE DAILY_SALES (
    sale_date DATE NOT NULL,
    store_id INT REFERENCES STORES(store_id),
    product_id INT REFERENCES PRODUCTS(product_id),
    department VARCHAR(50) NOT NULL,
    sales_channel VARCHAR(20) NOT NULL,
    units_sold INT NOT NULL,
    revenue NUMBER(12,2) NOT NULL,
    discount_pct INT DEFAULT 0
);

CREATE OR REPLACE TABLE ROLE_CATEGORY_ACCESS (
    role_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE MEETINGS (
    meeting_id INT PRIMARY KEY,
    meeting_date DATE NOT NULL,
    meeting_time VARCHAR(10) NOT NULL,
    title VARCHAR(200) NOT NULL,
    attendees VARCHAR(500),
    notes VARCHAR(1000),
    location VARCHAR(200)
);

-- =============================================================================
-- 5. LOAD DIMENSION DATA (small tables - inline INSERT)
-- =============================================================================

INSERT INTO MEETINGS VALUES
(1, '2026-09-01', '09:00', 'Weekly Category Standup', 'Category team', 'Review weekly KPIs and priorities', 'Meeting Room 3A'),
(2, '2026-09-01', '14:00', 'Supplier Review - Apex Kitchen Co', 'Apex account manager, Procurement', 'Discuss delivery delays and resolution timeline', 'Meeting Room 2B'),
(3, '2026-09-02', '10:00', 'Q3 Range Planning', 'Merchandise Planning team', 'Finalise Q4 kitchen range selections', 'Board Room'),
(4, '2026-09-02', '15:30', 'Digital Marketing Sync', 'Marketing team', 'Review online campaign performance for Home & Kitchen', 'Virtual - Teams'),
(5, '2026-09-03', '09:30', 'Morning Briefing', 'Direct reports', 'Daily priorities and blockers', 'Meeting Room 3A'),
(6, '2026-09-03', '14:00', 'Buyer Meeting - Q4 Kitchen Range', 'Sarah Wong (buyer), Procurement lead', 'Present Q4 range recommendations with supporting data', 'Board Room'),
(7, '2026-09-04', '11:00', 'Store Visit - Hamilton', 'Hamilton store manager', 'Review store performance and new layout effectiveness', 'Hamilton Centre Store'),
(8, '2026-09-05', '13:00', 'Weekly Wrap / WBR', 'Leadership team', 'Weekly business review - present category highlights', 'Executive Board Room');

-- =============================================================================
-- 6. FILE FORMAT AND STAGE
-- =============================================================================

CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', '');

CREATE OR REPLACE STAGE HOL_DATA_STAGE
    FILE_FORMAT = CSV_FORMAT;

-- =============================================================================
-- 7. LOAD DATA FROM STAGE
-- =============================================================================
-- Option A: PUT files from local machine (for testing)
--   PUT file:///path/to/stores.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/suppliers.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/suppliers_contact.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/products.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/daily_sales.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--   PUT file:///path/to/role_category_access.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE;
--
-- Option B: Copy from an external stage / S3 bucket (for bulk provisioning)
-- Option C: Cross-account data share from a master HOL account

COPY INTO STORES FROM @HOL_DATA_STAGE/stores.csv.gz FILE_FORMAT = CSV_FORMAT;
COPY INTO SUPPLIERS FROM @HOL_DATA_STAGE/suppliers.csv.gz FILE_FORMAT = CSV_FORMAT;
COPY INTO SUPPLIERS_CONTACT FROM @HOL_DATA_STAGE/suppliers_contact.csv.gz FILE_FORMAT = CSV_FORMAT;
COPY INTO PRODUCTS FROM @HOL_DATA_STAGE/products.csv.gz FILE_FORMAT = CSV_FORMAT;
COPY INTO DAILY_SALES FROM @HOL_DATA_STAGE/daily_sales.csv.gz FILE_FORMAT = CSV_FORMAT;
COPY INTO ROLE_CATEGORY_ACCESS FROM @HOL_DATA_STAGE/role_category_access.csv.gz FILE_FORMAT = CSV_FORMAT;

-- =============================================================================
-- 8. ROLES
-- =============================================================================

CREATE ROLE IF NOT EXISTS HOL_ATTENDEE_ROLE
    COMMENT = 'Role for CoWork HOL attendees - restricted to Home & Kitchen data';
CREATE ROLE IF NOT EXISTS HOL_ADMIN_ROLE
    COMMENT = 'Admin role for HOL - can see all departments';

GRANT ROLE HOL_ATTENDEE_ROLE TO ROLE ACCOUNTADMIN;
GRANT ROLE HOL_ADMIN_ROLE TO ROLE ACCOUNTADMIN;

-- =============================================================================
-- 9. ROW-LEVEL SECURITY
-- =============================================================================

CREATE OR REPLACE ROW ACCESS POLICY DEPARTMENT_RLS AS (dept_val VARCHAR)
RETURNS BOOLEAN ->
    CURRENT_ROLE() = 'HOL_ADMIN_ROLE'
    OR CURRENT_ROLE() = 'ACCOUNTADMIN'
    OR EXISTS (
        SELECT 1
        FROM MOSAIC_RETAIL.RETAIL.ROLE_CATEGORY_ACCESS
        WHERE role_name = CURRENT_ROLE()
          AND department = dept_val
    );

ALTER TABLE DAILY_SALES ADD ROW ACCESS POLICY DEPARTMENT_RLS ON (department);
ALTER TABLE PRODUCTS ADD ROW ACCESS POLICY DEPARTMENT_RLS ON (department);

-- =============================================================================
-- 10. SEMANTIC VIEW
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE HOL_WH;
USE DATABASE MOSAIC_RETAIL;
USE SCHEMA RETAIL;

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'MOSAIC_RETAIL.RETAIL',
$$
name: MOSAIC_RETAIL_ANALYTICS

tables:
  - name: daily_sales
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: DAILY_SALES
    description: "Daily sales transactions by product, store, and channel. One row per (date, store, product, channel) combination."
    facts:
      - name: revenue
        expr: REVENUE
        description: "Revenue from the sale in NZD (units_sold x unit_price x (1 - discount_pct/100))."
      - name: units_sold
        expr: UNITS_SOLD
        synonyms:
          - quantity
          - volume
          - units
        description: "Number of units sold."
      - name: discount_pct
        expr: DISCOUNT_PCT
        description: "Discount percentage applied (0, 5, 10, 15, or 20)."
    dimensions:
      - name: sale_date
        expr: SALE_DATE
        synonyms:
          - date
          - day
          - transaction date
        description: "The date the sale occurred."
      - name: sales_channel
        expr: SALES_CHANNEL
        synonyms:
          - channel
          - purchase channel
        description: "Sales channel: In-Store, Online, or Click-and-Collect."
      - name: department
        expr: DEPARTMENT
        synonyms:
          - category
          - dept
        description: "Product department (e.g. Home & Kitchen, Electronics)."
      - name: product_id
        expr: PRODUCT_ID
      - name: store_id
        expr: STORE_ID
    metrics:
      - name: total_revenue
        expr: SUM(daily_sales.revenue)
        synonyms:
          - sales
          - total sales
          - income
        description: "Sum of all revenue in NZD."
      - name: total_units
        expr: SUM(daily_sales.units_sold)
        synonyms:
          - units sold
          - volume
        description: "Total number of units sold."
      - name: avg_discount
        expr: AVG(daily_sales.discount_pct)
        description: "Average discount percentage applied."

  - name: products
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: PRODUCTS
    primary_key:
      columns:
        - PRODUCT_ID
    description: "Product catalog with departments, pricing, and supplier linkage."
    facts:
      - name: unit_cost
        expr: UNIT_COST
        description: "Wholesale cost per unit in NZD."
      - name: unit_price
        expr: UNIT_PRICE
        synonyms:
          - price
          - retail price
          - rrp
          - selling price
        description: "Retail selling price in NZD."
    dimensions:
      - name: product_id
        expr: PRODUCT_ID
      - name: product_name
        expr: PRODUCT_NAME
        synonyms:
          - product
          - item
          - SKU
        description: "Name of the product."
      - name: department
        expr: DEPARTMENT
        synonyms:
          - category
          - dept
        description: "Top-level product department (e.g. Home & Kitchen)."
      - name: subcategory
        expr: SUBCATEGORY
        synonyms:
          - sub-category
          - product type
          - product group
        description: "Product subcategory (e.g. Kitchen Appliances, Cookware, Home Decor)."
      - name: product_status
        expr: STATUS
        description: "Product status: Active or Discontinued."
      - name: launch_date
        expr: LAUNCH_DATE
        description: "Date the product was first available for sale."
      - name: supplier_id
        expr: SUPPLIER_ID
    metrics:
      - name: margin_pct
        expr: "AVG(ROUND((products.unit_price - products.unit_cost) / NULLIF(products.unit_price, 0) * 100, 1))"
        description: "Average gross margin percentage."

  - name: stores
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: STORES
    primary_key:
      columns:
        - STORE_ID
    description: "Retail store locations across ANZ and online."
    facts:
      - name: sqm
        expr: SQM
        synonyms:
          - floor area
          - square meters
          - size
        description: "Store floor area in square meters. NULL for online store."
    dimensions:
      - name: store_id
        expr: STORE_ID
      - name: store_name
        expr: STORE_NAME
        synonyms:
          - store
          - location
          - branch
        description: "Name of the store location."
      - name: city
        expr: CITY
        description: "City where the store is located."
      - name: region
        expr: REGION
        description: "Geographic region: North Island, South Island, Australia, or Online."
      - name: store_type
        expr: STORE_TYPE
        description: "Store format: Flagship, Standard, or Online."
      - name: opened_date
        expr: OPENED_DATE
        description: "Date the store opened or last reopened."

  - name: suppliers
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: SUPPLIERS
    primary_key:
      columns:
        - SUPPLIER_ID
    description: "Supplier directory with lead times, reliability scores, and current delay status."
    facts:
      - name: lead_time_days
        expr: LEAD_TIME_DAYS
        synonyms:
          - lead time
          - delivery days
          - standard lead time
        description: "Standard delivery lead time in days."
      - name: reliability_score
        expr: RELIABILITY_SCORE
        synonyms:
          - reliability
          - score
        description: "Historical reliability score from 0 to 100."
      - name: delivery_delay_days
        expr: DELIVERY_DELAY_DAYS
        synonyms:
          - delay
          - current delay
        description: "Current delivery delay in days (0 = no delay)."
    dimensions:
      - name: supplier_id
        expr: SUPPLIER_ID
      - name: supplier_name
        expr: SUPPLIER_NAME
        synonyms:
          - supplier
          - vendor
        description: "Name of the supplier company."
      - name: country
        expr: COUNTRY
        synonyms:
          - origin
          - supplier country
        description: "Country where the supplier is based."
      - name: primary_category
        expr: PRIMARY_CATEGORY
        description: "The main product subcategory this supplier provides."
      - name: delay_start_date
        expr: DELAY_START_DATE
        description: "Date the current delivery delay began (NULL if no delay)."
      - name: expected_resolution_date
        expr: EXPECTED_RESOLUTION_DATE
        description: "Expected date the delivery delay will be resolved (NULL if no delay)."

  - name: suppliers_contact
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: SUPPLIERS_CONTACT
    primary_key:
      columns:
        - SUPPLIER_ID
    description: "Contact information for each supplier. Use when the user asks for supplier contact details, email, or phone."
    dimensions:
      - name: supplier_id
        expr: SUPPLIER_ID
      - name: contact_name
        expr: CONTACT_NAME
        synonyms:
          - contact
          - representative
          - rep
        description: "Name of the primary contact person at the supplier."
      - name: contact_email
        expr: CONTACT_EMAIL
        synonyms:
          - email
        description: "Email address of the supplier contact."
      - name: contact_phone
        expr: CONTACT_PHONE
        synonyms:
          - phone
          - phone number
        description: "Phone number of the supplier contact."

  - name: meetings
    base_table:
      database: MOSAIC_RETAIL
      schema: RETAIL
      table: MEETINGS
    primary_key:
      columns:
        - MEETING_ID
    description: "Calendar and meeting schedule. Use this table when the user asks about their schedule, calendar, meetings, or what is on today."
    dimensions:
      - name: meeting_date
        expr: MEETING_DATE
        synonyms:
          - date
          - when
        description: "The date of the meeting."
      - name: meeting_time
        expr: MEETING_TIME
        synonyms:
          - time
          - start time
        description: "The start time of the meeting (e.g. 09:00, 14:00)."
      - name: title
        expr: TITLE
        synonyms:
          - meeting name
          - subject
          - event
        description: "Title or subject of the meeting."
      - name: attendees
        expr: ATTENDEES
        synonyms:
          - participants
          - who
        description: "People attending the meeting."
      - name: notes
        expr: NOTES
        description: "Meeting agenda or preparation notes."
      - name: location
        expr: LOCATION
        description: "Where the meeting takes place."

relationships:
  - name: sales_to_products
    left_table: daily_sales
    right_table: products
    relationship_columns:
      - left_column: product_id
        right_column: product_id
  - name: sales_to_stores
    left_table: daily_sales
    right_table: stores
    relationship_columns:
      - left_column: store_id
        right_column: store_id
  - name: products_to_suppliers
    left_table: products
    right_table: suppliers
    relationship_columns:
      - left_column: supplier_id
        right_column: supplier_id
  - name: suppliers_to_contacts
    left_table: suppliers
    right_table: suppliers_contact
    relationship_columns:
      - left_column: supplier_id
        right_column: supplier_id

custom_instructions: |
  The dataset contains sales data from 2026-03-01 through 2026-09-02.
  Snowflake weeks start on Monday (ISO standard). DATE_TRUNC('week', date) returns the Monday of that week.
  When calculating weekly aggregations, use DATE_TRUNC('week', SALE_DATE) and exclude any partial trailing week (where the week extends beyond the last date in the dataset).
  All currency is in NZD. Round numeric values to 2 decimal places.
  The Hamilton store reopened on 2026-04-01 after renovation — it has no sales in March.
  When the user asks about their calendar, schedule, or meetings for "today", query the meetings table with meeting_date = '2026-09-03'.

verified_queries:
  - name: whats_on_today
    question: "What is on my calendar today?"
    use_as_onboarding_question: true
    verified_at: 1724976000
    verified_by: "Angela Dignadice"
    sql: |
      SELECT MEETING_TIME, TITLE, ATTENDEES, NOTES, LOCATION
      FROM MOSAIC_RETAIL.RETAIL.MEETINGS
      WHERE MEETING_DATE = '2026-09-03'
      ORDER BY MEETING_TIME

  - name: kitchen_appliances_last_week
    question: "How did Kitchen Appliances perform last week?"
    verified_at: 1724976000
    verified_by: "Angela Dignadice"
    sql: |
      SELECT p.SUBCATEGORY,
             ROUND(SUM(s.REVENUE), 2) AS total_revenue,
             SUM(s.UNITS_SOLD) AS total_units
      FROM MOSAIC_RETAIL.RETAIL.DAILY_SALES s
      JOIN MOSAIC_RETAIL.RETAIL.PRODUCTS p ON s.PRODUCT_ID = p.PRODUCT_ID
      WHERE p.SUBCATEGORY = 'Kitchen Appliances'
      GROUP BY p.SUBCATEGORY

  - name: supplier_issues
    question: "Are there any supplier issues?"
    verified_at: 1724976000
    verified_by: "Angela Dignadice"
    sql: |
      SELECT sup.SUPPLIER_NAME, sup.COUNTRY,
             sup.DELIVERY_DELAY_DAYS, sup.DELAY_START_DATE,
             sup.EXPECTED_RESOLUTION_DATE,
             COUNT(DISTINCT p.PRODUCT_ID) AS products_affected
      FROM MOSAIC_RETAIL.RETAIL.SUPPLIERS sup
      JOIN MOSAIC_RETAIL.RETAIL.PRODUCTS p ON sup.SUPPLIER_ID = p.SUPPLIER_ID
      WHERE sup.DELIVERY_DELAY_DAYS > 0
      GROUP BY sup.SUPPLIER_NAME, sup.COUNTRY, sup.DELIVERY_DELAY_DAYS,
               sup.DELAY_START_DATE, sup.EXPECTED_RESOLUTION_DATE

  - name: trending_products
    question: "What products are trending?"
    verified_at: 1724976000
    verified_by: "Angela Dignadice"
    sql: |
      SELECT p.PRODUCT_NAME, p.SUBCATEGORY,
             ROUND(SUM(CASE WHEN s.SALE_DATE BETWEEN '2026-08-01' AND '2026-08-31' THEN s.REVENUE END), 2) AS aug_revenue,
             ROUND(SUM(CASE WHEN s.SALE_DATE BETWEEN '2026-07-01' AND '2026-07-31' THEN s.REVENUE END), 2) AS jul_revenue,
             ROUND(
               (SUM(CASE WHEN s.SALE_DATE BETWEEN '2026-08-01' AND '2026-08-31' THEN s.REVENUE END)
                - SUM(CASE WHEN s.SALE_DATE BETWEEN '2026-07-01' AND '2026-07-31' THEN s.REVENUE END))
               / NULLIF(SUM(CASE WHEN s.SALE_DATE BETWEEN '2026-07-01' AND '2026-07-31' THEN s.REVENUE END), 0) * 100, 1
             ) AS growth_pct
      FROM MOSAIC_RETAIL.RETAIL.DAILY_SALES s
      JOIN MOSAIC_RETAIL.RETAIL.PRODUCTS p ON s.PRODUCT_ID = p.PRODUCT_ID
      GROUP BY p.PRODUCT_NAME, p.SUBCATEGORY
      HAVING aug_revenue > 0
      ORDER BY growth_pct DESC
      LIMIT 10

  - name: blender_range_weekly_comparison
    question: "How do all the blender products in Kitchen Appliances compare to ProBlend 9000 over time?"
    verified_at: 1724976000
    verified_by: "Angela Dignadice"
    sql: |
      SELECT DATE_TRUNC('week', s.SALE_DATE) AS WEEK_START,
             p.PRODUCT_NAME,
             ROUND(SUM(s.REVENUE), 2) AS WEEKLY_REVENUE
      FROM MOSAIC_RETAIL.RETAIL.DAILY_SALES s
      JOIN MOSAIC_RETAIL.RETAIL.PRODUCTS p ON s.PRODUCT_ID = p.PRODUCT_ID
      WHERE p.PRODUCT_NAME IN ('ProBlend 9000', 'ProBlend 5000', 'Apex InfuseMax Blender', 'BlendTech SmoothiePro', 'BlendTech JuicePress 400')
        AND s.SALE_DATE >= '2026-06-01'
        AND DATE_TRUNC('week', s.SALE_DATE) <= '2026-08-25'
      GROUP BY DATE_TRUNC('week', s.SALE_DATE), p.PRODUCT_NAME
      ORDER BY WEEK_START, p.PRODUCT_NAME

  - name: How did Home & Kitchen perform in the past week compared to the week before?
    question: How did Home & Kitchen perform in the past week compared to the week before?
    sql: |-
      SELECT
        ROUND(
          SUM(
            CASE
              WHEN s.sale_date <= CURRENT_DATE
              AND s.sale_date >= DATEADD(DAY, -7, CURRENT_DATE) THEN s.revenue
            END
          ),
          2
        ) AS last_week_revenue,
        ROUND(
          SUM(
            CASE
              WHEN s.sale_date <= DATEADD(WEEK, -1, CURRENT_DATE)
              AND s.sale_date >= DATEADD(DAY, -14, CURRENT_DATE) THEN s.revenue
            END
          ),
          2
        ) AS prior_week_revenue,
        SUM(
          CASE
            WHEN s.sale_date <= CURRENT_DATE
            AND s.sale_date >= DATEADD(DAY, -7, CURRENT_DATE) THEN s.units_sold
          END
        ) AS last_week_units,
        SUM(
          CASE
            WHEN s.sale_date <= DATEADD(WEEK, -1, CURRENT_DATE)
            AND s.sale_date >= DATEADD(DAY, -14, CURRENT_DATE) THEN s.units_sold
          END
        ) AS prior_week_units,
        ROUND(
          (
            SUM(
              CASE
                WHEN s.sale_date <= CURRENT_DATE
                AND s.sale_date >= DATEADD(DAY, -7, CURRENT_DATE) THEN s.revenue
              END
            ) - SUM(
              CASE
                WHEN s.sale_date <= DATEADD(WEEK, -1, CURRENT_DATE)
                AND s.sale_date >= DATEADD(DAY, -14, CURRENT_DATE) THEN s.revenue
              END
            )
          ) / NULLIF(
            NULLIF(
              SUM(
                CASE
                  WHEN s.sale_date <= DATEADD(WEEK, -1, CURRENT_DATE)
                  AND s.sale_date >= DATEADD(DAY, -14, CURRENT_DATE) THEN s.revenue
                END
              ),
              0
            ),
            0
          ) * 100,
          1
        ) AS revenue_growth_pct
      FROM
        daily_sales AS s
        JOIN products AS p ON p.product_id = s.product_id
      WHERE
        p.department = 'Home & Kitchen'
    use_as_onboarding_question: false
    verified_by: "Angela Dignadice"
    verified_at: 1788142474
$$
);

-- =============================================================================
-- 11. CORTEX AGENT
-- =============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE MOSAIC_RETAIL;
USE SCHEMA RETAIL;
USE WAREHOUSE HOL_WH;

CREATE OR REPLACE AGENT MOSAIC_RETAIL.RETAIL.MOSAIC_RETAIL_AGENT
WITH PROFILE='{ "display_name": "Mosaic Retail Agent" }'
    COMMENT=$$ CoWork agent for Mosaic Retail HOL - Auckland World Tour $$
FROM SPECIFICATION $$
{
    "models": { "orchestration": "auto" },
    "orchestration": { "budget": { "seconds": 30 } },
    "instructions": {
        "response": "You are a retail analytics assistant for Mosaic Retail, an omnichannel retailer operating across Australia and New Zealand. Your expertise covers sales performance, product trends, store comparisons, channel mix (Online, In-Store, Click-and-Collect), supplier health, and schedule management.\n\n**Style and Communication:**\n- Be direct and factual. Lead with the most important insight, then supporting data.\n- Use NZD for all currency values. Round to 2 decimal places.\n- When a result shows growth or decline, state the percentage change clearly.\n- If a question is ambiguous, ask one brief clarifying question.\n\n**Presentation Rules:**\n- Always describe the data and context in text. Never only present a chart.\n- **Trends over time:** Use a line chart with date on the x-axis.\n- **Comparisons/Rankings:** Use a bar chart or table for comparing stores, products, or categories.\n- **Single metrics:** State the number prominently with context (e.g. vs last month).\n- **Schedules/meetings:** Present as a clean table with time, title, and attendees.\n\n**Context:**\n- Today is 2026-09-03.\n- The Hamilton store reopened 2026-04-01 after renovation (no March sales).\n\n**Important:** Do not proactively mention or cross-reference supplier issues, delivery delays, or supplier names unless the user explicitly asks about suppliers. Answer only the question asked.",
        "orchestration": "Use the retail_analytics tool for ALL questions including: Sales, revenue, products, stores, suppliers, performance metrics, schedule, calendar, meetings, what is on today. Use data_to_chart when presenting time-series or comparison data. For complex questions, break them into steps: first retrieve the relevant data, then present the insight with appropriate visualization.",
        "sample_questions": [
            { "question": "What is on my calendar today?" },
            { "question": "How did Kitchen Appliances perform last week?" },
            { "question": "Which store is performing best this month?" },
            { "question": "How is online vs in-store trending?" },
            { "question": "Are there any supplier issues I should know about?" },
            { "question": "What products are trending right now?" }
        ]
    },
    "tools": [
        {
            "tool_spec": {
                "type": "cortex_analyst_text_to_sql",
                "name": "retail_analytics",
                "description": "Queries Mosaic Retail data including sales performance, products, stores, suppliers, AND the meetings/calendar schedule. Use this for ANY data question including schedule and calendar queries."
            }
        },
        {
            "tool_spec": {
                "type": "data_to_chart",
                "name": "data_to_chart",
                "description": "Generates chart visualizations from query results"
            }
        },
        {
          "tool_spec": {
                "type": "code_execution",
                "name": "code_execution"
            }
        }
    ],
    "tool_resources": {
        "retail_analytics": {
            "semantic_view": "MOSAIC_RETAIL.RETAIL.MOSAIC_RETAIL_ANALYTICS",
            "execution_environment": {
                "type": "warehouse",
                "warehouse": "HOL_WH"
            }
        },
        "code_execution" :
            {
            }
    },
     "skills": [
        {
          "name": "executive_brief",
          "source": {
            "type": "STAGE",
            "path": "@MOSAIC_RETAIL.RETAIL.AGENT_SKILLS/executive_brief"
          }
        }
      ]
}
$$;


-- =============================================================================
-- 12. GRANTS
-- =============================================================================

GRANT USAGE ON WAREHOUSE HOL_WH TO ROLE HOL_ATTENDEE_ROLE;
GRANT USAGE ON DATABASE MOSAIC_RETAIL TO ROLE HOL_ATTENDEE_ROLE;
GRANT USAGE ON SCHEMA MOSAIC_RETAIL.RETAIL TO ROLE HOL_ATTENDEE_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA MOSAIC_RETAIL.RETAIL TO ROLE HOL_ATTENDEE_ROLE;
GRANT SELECT ON SEMANTIC VIEW MOSAIC_RETAIL.RETAIL.MOSAIC_RETAIL_ANALYTICS TO ROLE HOL_ATTENDEE_ROLE;
GRANT USAGE ON AGENT MOSAIC_RETAIL.RETAIL.MOSAIC_RETAIL_AGENT TO ROLE HOL_ATTENDEE_ROLE;

-- =============================================================================
-- 13. PROVISION ATTENDEE USER
-- =============================================================================

CREATE OR REPLACE PROCEDURE MOSAIC_RETAIL.RETAIL.PROVISION_ATTENDEE(username VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
BEGIN
    EXECUTE IMMEDIATE 'GRANT ROLE HOL_ATTENDEE_ROLE TO USER ' || :username;
    EXECUTE IMMEDIATE 'ALTER USER ' || :username || ' SET DEFAULT_ROLE = ''HOL_ATTENDEE_ROLE''';
    EXECUTE IMMEDIATE 'ALTER USER ' || :username || ' SET DEFAULT_WAREHOUSE = ''HOL_WH''';
    EXECUTE IMMEDIATE 'ALTER USER ' || :username || ' SET DEFAULT_NAMESPACE = ''MOSAIC_RETAIL.RETAIL''';
    RETURN 'User ' || :username || ' configured successfully';
END;

-- Example usage:
-- CALL MOSAIC_RETAIL.RETAIL.PROVISION_ATTENDEE('USER_001');

-- =============================================================================
-- SETUP COMPLETE
-- =============================================================================
-- After running this script, the attendee can:
-- 1. Open CoWork (Snowflake Intelligence)
-- 2. Select the MOSAIC_RETAIL_AGENT
-- 3. Start prompting: "What's on my calendar today?"
-- =============================================================================

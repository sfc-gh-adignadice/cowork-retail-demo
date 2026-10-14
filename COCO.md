# Mosaic Retail — CoWork HOL Setup

This project contains everything needed to provision a Snowflake Intelligence (CoWork) hands-on lab on a trial account. An SE can open this folder in CoCo Desktop and say **"set up the CoWork lab on my account"** — CoCo will handle the rest.

## When the user asks to set up the lab

### Step 1: Gather configuration

Before running anything, ask the user these questions (provide the defaults shown):

1. **Snow CLI connection name** — the name of the connection in `~/.snowflake/connections.toml` that targets the trial account (needed for PUT commands). Run `snow connection list` to show available connections.
2. **Database name** (default: `MOSAIC_RETAIL`)
3. **Schema name** (default: `RETAIL`)
4. **Warehouse name** (default: `HOL_WH`)
5. **Attendee role name** (default: `HOL_ATTENDEE_ROLE`)
6. **Number of attendee users** (e.g. 10, 50, 200)
7. **Number of lab instructor users** (e.g. 1, 2, 3)
8. **Password for attendee users** — entered at runtime, never written to any file
9. **Password for instructor users** — entered at runtime, never written to any file (should differ from attendee password)
10. **Deploy lab guide to GitHub Pages?** (yes/no) — if yes, also ask for the **site name** (default: `Snowflake CoWork Lab`)

Use the `ask_user_question` tool to collect these in one go. All subsequent steps use these values as variables.

### Step 2: Account settings

```sql
USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
```

### Step 3: Create warehouse

```sql
CREATE WAREHOUSE IF NOT EXISTS <warehouse>
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse for CoWork HOL queries';
USE WAREHOUSE <warehouse>;
```

### Step 4: Create database and schema

```sql
CREATE DATABASE IF NOT EXISTS <database>
    COMMENT = 'Mosaic Retail - Omnichannel retailer (ANZ) for CoWork HOL';
USE DATABASE <database>;
CREATE SCHEMA IF NOT EXISTS <schema>
    COMMENT = 'Core retail data - sales, products, stores, suppliers';
USE SCHEMA <schema>;
```

### Step 5: Create tables

Create tables in this order (foreign key dependencies):

1. `STORES` — no dependencies
2. `SUPPLIERS` — no dependencies
3. `ROLE_CATEGORY_ACCESS` — no dependencies
4. `MEETINGS` — no dependencies
5. `SUPPLIERS_CONTACT` — references SUPPLIERS
6. `PRODUCTS` — references SUPPLIERS
7. `DAILY_SALES` — references STORES and PRODUCTS

Read the table DDL from `./setup/setup.sql` (sections 4-5 of that file). Replace all `MOSAIC_RETAIL.RETAIL` references with `<database>.<schema>`. After creating MEETINGS, insert the inline meeting data from section 5 of the same file.

### Step 6: Create file format and stage, upload and load CSV data

```sql
CREATE OR REPLACE FILE FORMAT <database>.<schema>.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', '');

CREATE OR REPLACE STAGE <database>.<schema>.HOL_DATA_STAGE
    FILE_FORMAT = CSV_FORMAT;
```

PUT the 6 CSV files from `./data/` using the `snow` CLI. The absolute path to each file is `<workspace_root>/data/<filename>.csv`. Use the Snow CLI connection confirmed in Step 1.

```bash
snow sql -c <connection> --role ACCOUNTADMIN --warehouse <warehouse> --database <database> --schema <schema> \
  -q "PUT file://<absolute-path>/data/<file>.csv @HOL_DATA_STAGE AUTO_COMPRESS=TRUE"
```

PUT files in this order, then COPY INTO in the same order (respects foreign keys):
1. `stores.csv` → `STORES`
2. `suppliers.csv` → `SUPPLIERS`
3. `role_category_access.csv` → `ROLE_CATEGORY_ACCESS`
4. `suppliers_contact.csv` → `SUPPLIERS_CONTACT`
5. `products.csv` → `PRODUCTS`
6. `daily_sales.csv` → `DAILY_SALES`

```sql
COPY INTO <database>.<schema>.<TABLE> FROM @<database>.<schema>.HOL_DATA_STAGE/<file>.csv.gz FILE_FORMAT = <database>.<schema>.CSV_FORMAT;
```

After loading, verify row counts:
- STORES: 12
- SUPPLIERS: 20
- SUPPLIERS_CONTACT: 20
- PRODUCTS: 87
- DAILY_SALES: 160,765
- ROLE_CATEGORY_ACCESS: 8
- MEETINGS: 8 (from inline insert)

### Step 7: Create roles

```sql
USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS <attendee_role>
    COMMENT = 'Role for CoWork HOL attendees';
CREATE ROLE IF NOT EXISTS HOL_ADMIN_ROLE
    COMMENT = 'Admin role for HOL - can see all departments';
GRANT ROLE <attendee_role> TO ROLE ACCOUNTADMIN;
GRANT ROLE HOL_ADMIN_ROLE TO ROLE ACCOUNTADMIN;
```

### Step 8: Row-level security

```sql
CREATE OR REPLACE ROW ACCESS POLICY <database>.<schema>.DEPARTMENT_RLS AS (dept_val VARCHAR)
RETURNS BOOLEAN ->
    CURRENT_ROLE() = 'HOL_ADMIN_ROLE'
    OR CURRENT_ROLE() = 'ACCOUNTADMIN'
    OR EXISTS (
        SELECT 1
        FROM <database>.<schema>.ROLE_CATEGORY_ACCESS
        WHERE role_name = CURRENT_ROLE()
          AND department = dept_val
    );

ALTER TABLE <database>.<schema>.DAILY_SALES ADD ROW ACCESS POLICY DEPARTMENT_RLS ON (department);
ALTER TABLE <database>.<schema>.PRODUCTS ADD ROW ACCESS POLICY DEPARTMENT_RLS ON (department);
```

### Step 9: Create semantic view

Read `./setup/setup.sql` section 10 for the full `CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(...)` statement. Replace all occurrences of `MOSAIC_RETAIL` with `<database>` and `RETAIL` with `<schema>` in the YAML body. The semantic view name stays `MOSAIC_RETAIL_ANALYTICS` unless the user requests otherwise.

### Step 10: Upload agent skill and create agent

First, create the stage and upload the skill file:

```sql
CREATE STAGE IF NOT EXISTS <database>.<schema>.AGENT_SKILLS;
```

The skill file is at `./skills/executive_brief/SKILL.md`. PUT it using the absolute path:

```bash
snow sql -c <connection> --role ACCOUNTADMIN --warehouse <warehouse> --database <database> --schema <schema> \
  -q "PUT file://<workspace_root>/skills/executive_brief/SKILL.md @AGENT_SKILLS/executive_brief AUTO_COMPRESS=FALSE"
```

Then read `./setup/setup.sql` section 11 for the full `CREATE OR REPLACE AGENT` statement. Replace all occurrences of `MOSAIC_RETAIL` with `<database>`, `RETAIL` with `<schema>`, and `HOL_WH` with `<warehouse>`.

### Step 11: Grant permissions to the attendee role

```sql
USE ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE <warehouse> TO ROLE <attendee_role>;
GRANT USAGE ON DATABASE <database> TO ROLE <attendee_role>;
GRANT USAGE ON SCHEMA <database>.<schema> TO ROLE <attendee_role>;
GRANT SELECT ON ALL TABLES IN SCHEMA <database>.<schema> TO ROLE <attendee_role>;
GRANT SELECT ON SEMANTIC VIEW <database>.<schema>.MOSAIC_RETAIL_ANALYTICS TO ROLE <attendee_role>;
GRANT USAGE ON AGENT <database>.<schema>.MOSAIC_RETAIL_AGENT TO ROLE <attendee_role>;
GRANT READ ON STAGE <database>.<schema>.AGENT_SKILLS TO ROLE <attendee_role>;
```

### Step 12: Create users

Read `./users/usernames.csv` for the attendee username pool (columns: `id`, `username`).

**Attendee users** — take the first N usernames from the CSV:
```sql
USE ROLE USERADMIN;
CREATE OR REPLACE USER <username> PASSWORD = '<attendee_password>'
    LOGIN_NAME = '<username>'
    FIRST_NAME = '<Username>'
    LAST_NAME = 'Snowflake'
    MUST_CHANGE_PASSWORD = FALSE
    TYPE = PERSON
    DEFAULT_ROLE = <attendee_role>
    DEFAULT_WAREHOUSE = <warehouse>
    DEFAULT_NAMESPACE = <database>.<schema>;
GRANT ROLE <attendee_role> TO USER <username>;
```

**Lab instructor users** — use the naming pattern `lab_instructor_1`, `lab_instructor_2`, etc:
```sql
USE ROLE USERADMIN;
CREATE OR REPLACE USER lab_instructor_<N> PASSWORD = '<instructor_password>'
    LOGIN_NAME = 'lab_instructor_<N>'
    FIRST_NAME = 'Lab Instructor <N>'
    LAST_NAME = 'Snowflake'
    MUST_CHANGE_PASSWORD = FALSE
    TYPE = PERSON
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = <warehouse>;
GRANT ROLE ACCOUNTADMIN TO USER lab_instructor_<N>;
GRANT ROLE <attendee_role> TO USER lab_instructor_<N>;
```

### Step 13: Restrict attendees to Snowflake Intelligence only

After creating all attendee users, restrict each one so they can only access Snowflake Intelligence (not Snowsight):

```sql
USE ROLE SECURITYADMIN;
ALTER USER <username> SET ALLOWED_INTERFACES = (SNOWFLAKE_INTELLIGENCE);
```

Run this for **every attendee user**. Do NOT run it for instructor users — they need full Snowsight access.

### Step 14: Verify

Run a quick verification:
1. Check table row counts match expected values (Step 6)
2. Confirm the semantic view exists: `SHOW SEMANTIC VIEWS IN SCHEMA <database>.<schema>`
3. Confirm the agent exists: `SHOW AGENTS IN SCHEMA <database>.<schema>`
4. Confirm attendee role has all grants: `SHOW GRANTS TO ROLE <attendee_role>`
5. Confirm at least one attendee user has the role: `SHOW GRANTS TO USER <first_username>`

Report the results to the user and confirm setup is complete.

### Step 15: Deploy lab guide to GitHub Pages (if requested)

Only run this step if the user said yes to deploying the lab guide in Step 1.

1. Update the `site_name` in `./lab-guide/mkdocs.yml` to the name the user provided.
2. Ensure the repo has been pushed to GitHub. If not, guide the user to create a repo and push.
3. Tell the user to enable GitHub Pages in their repo settings:
   - Go to **Settings → Pages → Build and deployment**
   - Set **Source** to **GitHub Actions**
4. The workflow at `.github/workflows/deploy-lab-guide.yml` will automatically build and deploy the MkDocs site whenever changes under `lab-guide/` are pushed to `main`.
5. After the first push, the lab guide will be live at `https://<github-username>.github.io/<repo-name>/`.
6. Share this URL with attendees before the lab.

## Teardown

When the user asks to tear down or clean up the lab:

```sql
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS <database>;
DROP WAREHOUSE IF EXISTS <warehouse>;
DROP ROLE IF EXISTS <attendee_role>;
DROP ROLE IF EXISTS HOL_ADMIN_ROLE;
```

Then drop all created users (attendee + instructor).

## Folder Structure

```
├── COCO.md                          ← This file (CoCo setup instructions)
├── README.md                        ← Lab guide for attendees
├── setup/
│   ├── setup.sql                    ← Reference SQL for all objects
│   └── generate_data.py             ← Script that generated the CSV data
├── data/
│   ├── daily_sales.csv              ← 160,765 rows of sales transactions
│   ├── products.csv                 ← 87 products
│   ├── stores.csv                   ← 12 stores
│   ├── suppliers.csv                ← 20 suppliers
│   ├── suppliers_contact.csv        ← 20 supplier contacts
│   ├── role_category_access.csv     ← 8 role-department mappings
│   └── meetings.csv                 ← 8 meetings (also inserted inline)
├── users/
│   └── usernames.csv                ← 200 animal-themed usernames (no passwords)
├── skills/
│   └── executive_brief/SKILL.md     ← Agent skill for executive briefs
└── lab-guide/                       ← MkDocs lab guide site (customise per event)
```

## Important Notes

- **Passwords are never stored in this repo.** They are collected at runtime.
- **The `snow` CLI connection must target the correct account.** Always confirm which connection to use before running PUT commands.
- **Table creation order matters** due to foreign key references.
- **The attendee role name must be consistent** across all steps — roles, grants, user defaults, RLS policy, and semantic view. A mismatch means users get "no agents available" in CoWork.
- **`ALLOWED_INTERFACES`** is a per-user setting, not per-role. It must be set on each attendee user individually.

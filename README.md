# Unclogging the Funnel - Driving Conversion, Retention, and Revenue: An End-to-End E-commerce Analytics Case Study

## Project Summary

A mid-sized retailer with a growing e-commerce channel has been investing in digital acquisition to increase online revenue. Although traffic and engagement have grown, revenue has not kept pace. This project investigates where the customer journey is breaking down, which acquisition channels drive high-value users, and what behaviors are associated with repeat purchase. The goal is to build an end-to-end analytics workflow that transforms event-level behavioral data into executive-ready business recommendations.

## Business Problem

Leadership is concerned that increased top-of-funnel activity is not translating into proportional revenue growth. The business needs to understand whether the problem is driven by weak acquisition quality, poor on-site conversion, low repeat purchase behavior, or a combination of all three. This project is designed to identify the highest-impact opportunities to improve conversion, retention, and growth efficiency.

## Stakeholders

The primary stakeholders for this project are:

- **VP of Product**, who cares about user journey friction, on-site behavior, and conversion opportunities
- **Director of E-commerce**, who cares about revenue performance, merchandising outcomes, and digital channel health
- **Director of Growth Marketing**, who cares about acquisition quality, channel efficiency, and downstream commercial impact

A secondary stakeholder is the **Director of Finance**, who cares about growth efficiency, return on investment, and whether e-commerce investments are generating sustainable  returns.

## Core Business Question

**How should leadership prioritize improvements across acquisition, on-site conversion, and retention to drive revenue growth more efficiently?**

## Project Objectives

This project is designed to:

- measure the end-to-end customer funnel from session start through purchase
- identify where and how users drop off in the purchase journey
- evaluate channel quality using conversion, revenue, and spend-based efficiency metrics
- analyze repeat purchase behavior and customer retention patterns
- create a business-ready data model in the cloud using modern analytics tooling
- deliver a dashboard and executive recommendations that support decision-making

## Scope

This project analyzes the digital customer journey from traffic acquisition through purchase, with a focus on funnel performance, repeat purchase behavior, channel quality, and revenue contribution. It includes a cloud-based analytics workflow, event-level data transformation into business-ready models, KPI design, a stakeholder-facing dashboard, and business recommendations supported by SQL, Python, and BI outputs.

To make the analysis more realistic, the project also incorporates synthetic data tables such as marketing spend, product margin estimates, and support or returns signals.

This project does **not** attempt to build a recommendation engine or an ML model. Instead, it focuses on descriptive and diagnostic analytics, metric design, and decision support.

## Data Sources

This project uses the following data sources:

- **GA4 public sample e-commerce dataset in BigQuery** as the primary source of event-level digital behavior
- **Synthetic channel spend table** to support acquisition efficiency analysis
- **Synthetic product margin table** to estimate gross profit and margin contribution
- **Synthetic support / returns table** to introduce operational and customer experience guardrails

## Architecture Overview

The analytics workflow follows this structure:

**GA4 event data + synthetic enrichment tables -> staging models in BigQuery -> intermediate behavioral models -> business marts for funnel, retention, and channel efficiency -> Tableau dashboard + executive memo**

The stack used in this project includes:

- **BigQuery** for cloud data warehousing
- **dbt** for SQL-based transformations and layered modeling
- **Python** for data quality validation, cohort analysis, and scenario testing
- **Tableau** for dashboarding and business communication
- **GitHub** for documentation and version control

## Core Data Models

The project highlights the following 8 core models:

- **int_sessions**
- **int_funnel_events**
- **int_orders**
- **int_user_activity**
- **mart_funnel_performance**
- **mart_retention_cohorts**
- **mart_channel_efficiency**
- **mart_executive_kpis**

Supporting enrichment models in the repo:

- **stg_ga4_events**
- **stg_channel_spend**
- **stg_product_margin**
- **stg_support_returns**
- **mart_product_performance**

## Metric Framework

### North-Star Metric

The north-star metric for this project is:

**Revenue per Active User (RPAU)**

**Formula:**  
Total Revenue / Distinct Active Users in Period

I chose this metric because it reflects whether the business is converting traffic into value. It captures the combined effects of acquisition quality, on-site conversion, repeat purchase behavior, and monetization.

### Executive KPI Scorecard

Other metrics include:

- **Revenue**
- **Purchase Conversion Rate**
- **Average Order Value**
- **Repeat Purchase Rate**
- **Estimated Gross Profit**
- **ROAS Proxy** or **CAC Proxy**

### Funnel Metrics

The funnel is:

- **Session Start**
- **Product View**
- **Add to Cart**
- **Begin Checkout**
- **Purchase**

The funnel metrics include:

- **Session-to-Product View Rate**
- **Product View-to-Add to Cart Rate**
- **Add to Cart-to-Begin Checkout Rate**
- **Begin Checkout-to-Purchase Rate**
- **Overall Session-to-Purchase Conversion Rate**
- **Cart Abandonment Rate**
- **Checkout Abandonment Rate**

### Retention Metrics

The retention metrics are:

- **30-day Repeat Purchase Rate**
- **60-day Repeat Purchase Rate**
- **90-day Repeat Purchase Rate**
- **Average Days to Second Purchase**
- **Purchase Frequency per Customer**
- **Revenue Share from Returning Customers**
- **Cohort Retention by First Purchase Period**

## Dashboard Overview

The Tableau dashboard is designed for executive and stakeholder use. It will include:

- an **executive KPI scorecard**
- a **conversion funnel view**
- a **channel efficiency analysis**
- a **retention and cohort analysis**
- a **product or category performance view**
- filters for channel, device, time period, and product category

The goal of the dashboard is not just to display performance, but to support prioritization and decision-making.

## Key Business Questions This Project Answers

This project will answer questions such as:

- Where is the biggest drop-off in the digital purchase journey?
- Which acquisition channels bring high-intent and high-value customers?
- Are increases in traffic translating into efficient revenue growth?
- What behaviors are associated with repeat purchase?
- Which device types, product categories, or channels underperform?
- What should leadership prioritize to improve conversion, retention, and profitability?

## Expected Deliverables

This repository will contain:

- SQL / dbt models for staging, intermediate transformations, and business marts
- Python notebooks for validation, cohort analysis, and scenario testing
- synthetic enrichment tables used to support realistic business analysis
- a Tableau dashboard for stakeholder consumption
- architecture and metric documentation
- an executive summary and recommendation memo

## Repository Structure

A planned repository structure for this project is:

- `README.md`
- `docs/`
- `data/synthetic/`
- `dbt/`
- `notebooks/`
- `dashboard/`
- `presentation/`

Documentation will include the business case, architecture, metric dictionary, executive summary, and dashboard notes.

## Tech Stack

- **SQL**
- **BigQuery**
- **dbt**
- **Python**
- **Tableau**
- **GitHub**

## Why This Project Matters

This project is intended to demonstrate the end-to-end skill set expected in analyst and analytics-focused roles, including:

- product analytics
- SQL transformation and business modeling
- Python-based analytical support
- cloud data warehousing
- BI dashboarding
- stakeholder-oriented metric design
- business recommendation development
- executive communication

## Next Build Steps

The next implementation steps are:

- set up the GitHub repository
- connect to the GA4 public dataset in BigQuery
- define the synthetic enrichment tables
- create the dbt project structure
- build staging models
- begin metric validation for the funnel and executive KPIs

## Status

This project is currently in active development. The business problem, architecture, metric framework, and repository structure have been defined. The next phase is implementation of the cloud data model and analytics workflow.

---

**Author:** Ishan (Friday) Mishra
**Program:** M.S. in Information Systems Management (Business Intelligence & Data Analytics), Carnegie Mellon University  
**Background:** B.S. in Information Systems and Data Science, University of Wisconsin–Madison

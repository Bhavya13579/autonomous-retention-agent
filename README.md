# Autonomous Retention Intervention Agent

## Overview
A closed-loop, agentic system that **detects churn risk, selects the optimal intervention, executes automatically, and learns from outcomes** to maximize retention ROI.  
This project is designed to demonstrate **business judgment + data science + automation** at a FAANG-level bar.

---

## Business Problem
Retention actions are:
- Reactive
- Uniformly applied
- Cost-inefficient

Result: wasted incentives, poor ROI, and late intervention.

---

## Objective
Reduce **30-day churn** by intervening **only when expected retention uplift exceeds intervention cost**.

---

## Core Decision
> For each user, each day:  
> **Intervene (and how) vs Do Nothing**

---

## Agentic Workflow

OBSERVE → REASON → ACT → LEARN


### Observe
- Daily user behavior aggregated via SQL
- User-level feature snapshot

### Reason
- Predict churn probability
- Estimate uplift per intervention
- Choose optimal action

### Act
- Execute discount / nudge / no-op
- Log every action

### Learn
- Measure treatment effects
- Update thresholds and policies

---

## Success Metrics
- **Primary**: 30-day retention uplift
- **Secondary**: Cost per retained user
- **Guardrails**: Over-intervention rate, false positives

---

## Repository Structure

retention-agent/
│
├── README.md
│
├── data/
│ ├── raw/ # Immutable raw events
│ ├── processed/ # Daily user feature tables
│ └── experiments/ # Historical A/B outcomes
│
├── sql/
│ ├── user_activity.sql # Feature aggregation
│ ├── churn_labels.sql # Churn definition
│ └── intervention_log.sql # Action logging
│
├── src/
│ ├── config.py # Costs, thresholds, constants
│ │
│ ├── features/
│ │ └── build_features.py
│ │
│ ├── models/
│ │ ├── churn_model.py
│ │ └── uplift_model.py
│ │
│ ├── decision/
│ │ └── policy.py
│ │
│ ├── actions/
│ │ └── executor.py
│ │
│ ├── evaluation/
│ │ └── treatment_effect.py
│ │
│ └── pipeline/
│ └── daily_run.py
│
├── notebooks/
│ ├── 01_eda.ipynb
│ ├── 02_model_validation.ipynb
│ └── 03_policy_analysis.ipynb
│
├── docs/
│ ├── system_design.md
│ ├── decision_memo.md
│ └── assumptions.md
│
├── tests/
│ ├── test_models.py
│ └── test_policy.py
│
└── requirements.txt


---

## Decision Logic (Simplified)

```text
IF churn_risk × uplift > intervention_cost:
    intervene
ELSE:
    do nothing

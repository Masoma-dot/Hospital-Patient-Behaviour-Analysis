# Hospital Patient Behaviour & Appointment Analysis

**Tools:** Excel · Python · SQL (BigQuery) · Power BI  
**Dataset:** [Kaggle — Medical Appointment No Shows](https://www.kaggle.com/datasets/joniarroba/noshowappointments)  
**Records:** 110,527 hospital appointment records (Brazil, 2016)

---

## Project Overview

This end-to-end data analysis project examines patient behaviour at a Brazilian public hospital. The goal was to identify the key drivers behind appointment no-shows and surface actionable insights that an operations team could act on.

The project covers the full data analyst workflow — from raw data cleaning through to automated reporting — using four industry-standard tools.

---

## Key Findings

- **20%+ no-show rate** — roughly 1 in 5 patients misses their scheduled appointment
- **Young Adults (18–34)** have the highest no-show rate of any age group
- **Longer wait times** strongly correlate with higher no-show rates — patients waiting 60+ days are significantly more likely to not attend
- **SMS reminders** show a measurable difference in attendance, yet only ~32% of patients received one
- **Geographic variation** in no-show rates points to potential access or socioeconomic barriers in certain neighbourhoods
- **Monday and Saturday** appointments show higher no-show rates than mid-week slots

---

## Repository Structure

```
hospital-patient-analysis/
│
├── data/
│   ├── hospital_clean_shortened.csv
│   └── raw
│
├── notebook/
│   ├── eda.ipynb
│   └── hospital_eda.ipynb
│
├── report/
│   └── Hospital_Patient_Analysis_Report.pdf
│
├── sql/
│   └── queries.sql
│
├── visuals/
│   ├── plot1_attendance.png
│   ├── plot2_age_group.png
│   ├── plot3_day_of_week.png
│   ├── plot4_sms.png
│   └── plot5_wait_days.png
│
└── README.md
```

---

## Tools & Workflow

### 1 — Excel (Data Cleaning & Exploration)

**What I did:**
- Renamed all columns to consistent `snake_case`
- Fixed data types for date columns (`scheduled_day`, `appointment_day`)
- Removed duplicate rows using the `appointment_id` column
- Filtered out invalid records (negative ages)
- Created two helper columns using Excel formulas:
  - `wait_days` — days between booking and appointment using `=DAYS()`
  - `age_group` — categorised patients into Child / Young Adult / Adult / Senior using nested `IF()`
- Built PivotTable summaries for show vs no-show split and age group breakdown

**Formulas used:**
```excel
=DAYS(E2, D2)
=IF(F2<18,"Child",IF(F2<35,"Young Adult",IF(F2<60,"Adult","Senior")))
```

---

### 2 — Python (EDA & Automated Report)

**Libraries:** `pandas`, `matplotlib`, `numpy`, `reportlab`

**EDA script (`hospital_eda.py`) produces:**
- Data quality checks (nulls, dtypes, shape)
- 5 charts saved as `.png` files:
  - Overall show vs no-show attendance
  - No-show rate by age group
  - No-show rate by day of week
  - SMS reminder vs no-show rate
  - No-show rate by wait time bucket
- Exports `hospital_final.csv` for BigQuery upload

**Report generator (`generate_report.py`) produces:**
- A fully automated 7-page professional PDF report
- Cover page, executive summary, KPI cards, charts, data tables, insight boxes, methodology section
- Header and footer on every page
- No manual formatting — runs entirely from `hospital_final.csv`

**How to run:**

```bash
# Install dependencies
pip install pandas matplotlib numpy reportlab

# Run EDA
python hospital_eda.py

# Generate PDF report
python generate_report.py
```

---

### 3 — SQL in BigQuery

**Setup:**
1. Created a BigQuery project: `hospital-analysis`
2. Created a dataset: `hospital_data`
3. Uploaded `hospital_final.csv` as table `appointments` (auto-detect schema)

**Queries written:**

| File | Business Question |
|------|------------------|
| `query1_gender_noshow.sql` | What is the no-show rate split by gender? |
| `query2_age_group.sql` | Which age group has the highest no-show rate? |
| `query3_top_neighbourhoods.sql` | Which neighbourhoods have the most no-shows? |
| `query4_sms_impact.sql` | Do SMS reminders reduce no-show rates? |
| `query5_monthly_trend.sql` | How did appointment volume and no-show rates change month by month? |

**Sample query:**
```sql
SELECT
  age_group,
  COUNT(*) AS total_appointments,
  SUM(no_show_flag) AS total_no_shows,
  ROUND(SUM(no_show_flag) / COUNT(*) * 100, 2) AS no_show_rate_pct
FROM
  `hospital-analysis.hospital_data.appointments`
GROUP BY
  age_group
ORDER BY
  no_show_rate_pct DESC;
```

---

### 4 — Power BI / PDF Report

The final output is a professional multi-page report generated automatically in Python using `reportlab`. This approach was chosen because it is reproducible, version-controllable, and produces a consistent output every time — advantages over a manually built BI dashboard.

**Report pages:**
1. Cover page
2. Executive Summary — KPI cards + key findings + recommendations
3. Attendance Overview — show/no-show split, gender breakdown
4. Patient Demographics — age group analysis with data table
5. SMS Reminders & Wait Times — two charts + insight boxes
6. Temporal Patterns — monthly trend (dual axis) + day of week
7. Geographic Analysis — neighbourhood no-show ranking + table
8. Methodology — tools, cleaning steps, limitations

> **Note:** If your role requires a `.pbix` file specifically, the same charts and KPI measures are straightforward to recreate in Power BI Desktop using the `hospital_final.csv` file and the DAX measures documented in the project notes.

**DAX measures (for Power BI):**
```dax
Total Appointments = COUNT('appointments'[appointment_id])
Total No-Shows = SUM('appointments'[no_show_flag])
No-Show Rate = DIVIDE([Total No-Shows], [Total Appointments], 0) * 100
Avg Wait Days = AVERAGE('appointments'[wait_days])

Wait Bucket =
SWITCH(
  TRUE(),
  'appointments'[wait_days] = 0, "Same day",
  'appointments'[wait_days] <= 7, "1-7 days",
  'appointments'[wait_days] <= 30, "8-30 days",
  'appointments'[wait_days] <= 60, "31-60 days",
  "60+ days"
)
```

---

## Recommendations

Based on the analysis:

1. **Expand SMS reminders** — only 32% of patients receive one; scaling this to 80%+ is the single highest-leverage intervention available
2. **Implement a 48-hour re-confirmation** for appointments booked 30+ days in advance — these patients have significantly higher no-show rates
3. **Target 18–34 age group** with digital-first engagement (WhatsApp, app notifications)
4. **Investigate high-risk neighbourhoods** for access barriers — transport subsidies or satellite clinic hours may help
5. **Favour mid-week scheduling** for non-urgent appointments — Monday and Saturday show elevated no-show rates

---

## How to Reproduce This Project

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/joniarroba/noshowappointments) and save as `hospital_final.csv`
2. Run `python hospital_eda.py` to clean data and generate EDA charts
3. Upload `hospital_final.csv` to BigQuery and run the 5 SQL queries in the `sql/` folder
4. Run `python generate_report.py` to produce the full PDF report

---

## Dataset Description

| Column | Description |
|--------|-------------|
| `patient_id` | Unique patient identifier |
| `appointment_id` | Unique appointment identifier |
| `gender` | Patient gender (M/F) |
| `scheduled_day` | Date the appointment was booked |
| `appointment_day` | Date of the actual appointment |
| `age` | Patient age in years |
| `neighbourhood` | Clinic neighbourhood |
| `scholarship` | Whether patient is on a government welfare programme (0/1) |
| `hypertension` | Hypertension diagnosis flag (0/1) |
| `diabetes` | Diabetes diagnosis flag (0/1) |
| `alcoholism` | Alcoholism flag (0/1) |
| `handicap` | Handicap flag (0/1) |
| `sms_received` | Whether patient received an SMS reminder (0/1) |
| `no_show` | Whether patient missed the appointment (Yes/No) |
| `wait_days` | Derived: days between scheduling and appointment |
| `age_group` | Derived: Child / Young Adult / Adult / Senior |

---

## CV Description

> **Hospital Patient Behaviour & Appointment Analysis**  
> *Tools: Excel · Python (pandas, matplotlib, reportlab) · SQL (BigQuery) · Power BI*
>
> Analysed 110,000+ real hospital appointment records to identify patient no-show patterns across age, gender, geography, and time. Cleaned and validated raw data in Excel, performed exploratory data analysis and visualisation in Python, wrote 5 business-focused aggregation queries in BigQuery, and built an automated 7-page professional PDF report using Python's ReportLab library — covering KPI summaries, demographic breakdowns, temporal trends, and geographic analysis.

---

*Dataset: Joni Hoppen & Aquarela Advanced Analytics — published on Kaggle under CC0 Public Domain licence.*

# PlatinumRx Data Analyst Assignment

## Author
[Your Name] | [Your Email]

---

## Project Structure

```
Data_Analyst_Assignment/
├── SQL/
│   ├── 01_Hotel_Schema_Setup.sql   # CREATE TABLE + INSERT for Hotel system
│   ├── 02_Hotel_Queries.sql        # Hotel queries Q1–Q5
│   ├── 03_Clinic_Schema_Setup.sql  # CREATE TABLE + INSERT for Clinic system
│   └── 04_Clinic_Queries.sql       # Clinic queries Q1–Q5
│
├── Spreadsheets/
│   └── Ticket_Analysis.xlsx        # Excel workbook with ticket + feedbacks + analysis sheets
│
├── Python/
│   ├── 01_Time_Converter.py        # Minutes → hrs & minutes
│   └── 02_Remove_Duplicates.py     # Remove duplicate characters via loop
│
└── README.md
```

---

## Phase 1 — SQL

**Tool used:** MySQL 8 on DB Fiddle (db-fiddle.com)

### Hotel System (Part A)

| Q  | Question | Approach |
|----|----------|----------|
| Q1 | Last booked room per user | `ORDER BY booking_date DESC LIMIT 1` with JOIN to users |
| Q2 | Total billing per booking in Nov 2021 | 3-table JOIN, `SUM(item_quantity × item_rate)`, filter by YEAR/MONTH |
| Q3 | Bills > 1000 in Oct 2021 | `GROUP BY bill_id`, `HAVING SUM > 1000` |
| Q4 | Most/least ordered item per month | CTE + `RANK() OVER(PARTITION BY month ORDER BY total_qty DESC/ASC)` |
| Q5 | 2nd highest bill per month | CTE + `DENSE_RANK() OVER(ORDER BY bill_total DESC)`, filter rank = 2 |

### Clinic System (Part B)

| Q  | Question | Approach |
|----|----------|----------|
| Q1 | Revenue by sales channel | `GROUP BY sales_channel`, `SUM(amount)`, filter by year |
| Q2 | Top 10 most valuable customers | JOIN clinic_sales + customer, `SUM(amount)` per customer, `LIMIT 10` |
| Q3 | Month-wise revenue, expense, profit, status | Two CTEs (revenue & expenses by month+clinic), LEFT JOIN, profit = revenue − expense, CASE WHEN for status |
| Q4 | Most profitable clinic per city per month | CTE profit calculation + `RANK() OVER(PARTITION BY city, month ORDER BY profit DESC)`, filter rank = 1 |
| Q5 | 2nd least profitable clinic per state per month | Same profit CTE + `DENSE_RANK() OVER(PARTITION BY state, month ORDER BY profit ASC)`, filter rank = 2 |

---

## Phase 2 — Spreadsheet

**Tool used:** Microsoft Excel / Google Sheets

### Sheet structure
- **Sheet 1: `ticket`** — ticket_id, created_at, closed_at, outlet_id, cms_id
  - Helper column F: `Same_Day?` → `=INT(B2)=INT(C2)` — TRUE if created and closed on same date
  - Helper column G: `Same_Hour?` → `=AND(INT(B2)=INT(C2), HOUR(B2)=HOUR(C2))` — TRUE if same day AND same hour

- **Sheet 2: `feedbacks`** — cms_id, feedback_at, feedback_rating, ticket_created_at
  - `ticket_created_at` is populated using VLOOKUP

- **Sheet 3: `analysis`** — outlet-wise counts for Q2a and Q2b

### Q1 — Populate ticket_created_at
In `feedbacks!D2`:
```
=IFERROR(VLOOKUP(A2, ticket!$E:$B, 2, FALSE), "Not Found")
```
- Lookup value: `cms_id` in feedbacks (column A)
- Table array: ticket sheet columns E→B
- Col index: 2 = created_at
- Drag down for all rows

### Q2a — Tickets created and closed same day (per outlet)
Uses helper column F (`Same_Day?`) in ticket sheet:
```
=COUNTIFS(ticket!$D:$D, outlet_id, ticket!$F:$F, TRUE)
```

### Q2b — Same hour of same day (per outlet)
Uses helper column G (`Same_Hour?`) in ticket sheet:
```
=COUNTIFS(ticket!$D:$D, outlet_id, ticket!$G:$G, TRUE)
```

---

## Phase 3 — Python

**Tool used:** Python 3.x

### Script 1 — Time Converter (`01_Time_Converter.py`)
- Input: integer minutes (e.g. 130)
- Output: human-readable string (e.g. "2 hrs 10 minutes")
- Uses `//` integer division for hours and `%` modulo for remaining minutes
- Handles singular/plural: "1 hr" vs "2 hrs", "1 minute" vs "2 minutes"

```python
hours          = total_minutes // 60
remaining_mins = total_minutes % 60
```

### Script 2 — Remove Duplicates (`02_Remove_Duplicates.py`)
- Input: any string (e.g. "programming")
- Output: string with duplicate characters removed (e.g. "progamin")
- Uses a `for` loop as required — no built-in dedup functions
- Preserves original character order

```python
result = ""
for char in input_string:
    if char not in result:
        result += char
```

---

## How to Run

### SQL
1. Open [db-fiddle.com](https://www.db-fiddle.com) → select **MySQL 8**
2. Left panel → paste `01_Hotel_Schema_Setup.sql` → Run
3. Right panel → paste queries from `02_Hotel_Queries.sql` one at a time → Run
4. Repeat with `03_Clinic_Schema_Setup.sql` and `04_Clinic_Queries.sql`

### Python
```bash
python Python/01_Time_Converter.py
python Python/02_Remove_Duplicates.py
```

### Spreadsheet
Open `Spreadsheets/Ticket_Analysis.xlsx` in Excel or Google Sheets.
Formulas in column D of feedbacks sheet and columns F/G of ticket sheet will auto-calculate.

---

## Assumptions
- MySQL 8 used (required for CTEs and window functions like RANK, DENSE_RANK)
- Sample data covers all months of 2021 to exercise all queries
- "Second highest" uses DENSE_RANK so tied values are handled correctly
- Clinic schema follows the PDF exactly: clinics, customer, clinic_sales, expenses tables
- Spreadsheet VLOOKUP assumes cms_id is unique per ticket
- Python scripts use only basic syntax (loops, modulo) as specified in the assignment

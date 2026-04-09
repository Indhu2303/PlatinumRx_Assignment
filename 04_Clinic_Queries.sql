-- ============================================================
-- PlatinumRx Assignment | Clinic Management System
-- File: 04_Clinic_Queries.sql
-- Purpose: Queries for Part B (Questions 1–5)
-- ============================================================


-- ============================================================
-- Q1: Revenue from each SALES CHANNEL in a given year
-- ============================================================
-- LOGIC:
--   GROUP BY sales_channel and SUM the amount.
--   Filter by YEAR = 2021.
-- ============================================================

SELECT
    sales_channel,
    COUNT(oid)          AS total_orders,
    SUM(amount)         AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel
ORDER BY total_revenue DESC;


-- ============================================================
-- Q2: Top 10 most VALUABLE CUSTOMERS for a given year
-- ============================================================
-- LOGIC:
--   JOIN clinic_sales with customer to get names.
--   SUM amount per customer, filter by year.
--   ORDER by total DESC, LIMIT 10.
-- ============================================================

SELECT
    c.uid,
    c.name              AS customer_name,
    c.mobile,
    COUNT(s.oid)        AS total_orders,
    SUM(s.amount)       AS total_spent
FROM clinic_sales s
JOIN customer c ON s.uid = c.uid
WHERE YEAR(s.datetime) = 2021
GROUP BY c.uid, c.name, c.mobile
ORDER BY total_spent DESC
LIMIT 10;


-- ============================================================
-- Q3: Month-wise REVENUE, EXPENSE, PROFIT and STATUS
-- ============================================================
-- LOGIC:
--   CTE 1: Monthly revenue per clinic from clinic_sales.
--   CTE 2: Monthly expenses per clinic from expenses.
--   JOIN on clinic + month, calculate profit = revenue - expense.
--   CASE WHEN profit >= 0 → 'Profitable', else → 'Not-Profitable'
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        cid,
        MONTH(datetime)      AS month_num,
        MONTHNAME(datetime)  AS month_name,
        SUM(amount)          AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY cid, MONTH(datetime), MONTHNAME(datetime)
),
monthly_expenses AS (
    SELECT
        cid,
        MONTH(datetime)      AS month_num,
        SUM(amount)          AS expenses
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY cid, MONTH(datetime)
)
SELECT
    cl.clinic_name,
    r.month_num,
    r.month_name,
    r.revenue,
    COALESCE(e.expenses, 0)                          AS expenses,
    (r.revenue - COALESCE(e.expenses, 0))            AS profit,
    CASE
        WHEN (r.revenue - COALESCE(e.expenses, 0)) >= 0
        THEN 'Profitable'
        ELSE 'Not-Profitable'
    END                                              AS status
FROM monthly_revenue r
LEFT JOIN monthly_expenses e
       ON r.cid = e.cid AND r.month_num = e.month_num
JOIN clinics cl ON r.cid = cl.cid
ORDER BY r.month_num, cl.clinic_name;


-- ============================================================
-- Q4: For each CITY, find the MOST PROFITABLE clinic
--     for a given month
-- ============================================================
-- LOGIC:
--   Step 1: Calculate profit per clinic per month (same as Q3).
--   Step 2: Use RANK() partitioned by city + month,
--           ordered by profit DESC → rank 1 = most profitable.
--   Step 3: Filter WHERE rank = 1.
-- ============================================================

WITH clinic_profit AS (
    SELECT
        s.cid,
        cl.clinic_name,
        cl.city,
        MONTH(s.datetime)      AS month_num,
        MONTHNAME(s.datetime)  AS month_name,
        SUM(s.amount)          AS revenue
    FROM clinic_sales s
    JOIN clinics cl ON s.cid = cl.cid
    WHERE YEAR(s.datetime) = 2021
    GROUP BY s.cid, cl.clinic_name, cl.city,
             MONTH(s.datetime), MONTHNAME(s.datetime)
),
clinic_expense AS (
    SELECT
        cid,
        MONTH(datetime)  AS month_num,
        SUM(amount)      AS expenses
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY cid, MONTH(datetime)
),
profit_ranked AS (
    SELECT
        p.cid,
        p.clinic_name,
        p.city,
        p.month_num,
        p.month_name,
        p.revenue,
        COALESCE(e.expenses, 0)                        AS expenses,
        (p.revenue - COALESCE(e.expenses, 0))          AS profit,
        RANK() OVER (
            PARTITION BY p.city, p.month_num
            ORDER BY (p.revenue - COALESCE(e.expenses, 0)) DESC
        )                                              AS profit_rank
    FROM clinic_profit p
    LEFT JOIN clinic_expense e
           ON p.cid = e.cid AND p.month_num = e.month_num
)
SELECT
    city,
    month_num,
    month_name,
    clinic_name,
    revenue,
    expenses,
    profit
FROM profit_ranked
WHERE profit_rank = 1
ORDER BY city, month_num;


-- ============================================================
-- Q5: For each STATE, find the SECOND LEAST PROFITABLE clinic
--     for a given month
-- ============================================================
-- LOGIC:
--   Same profit calculation as Q4.
--   Use DENSE_RANK() partitioned by state + month,
--   ordered by profit ASC → rank 1 = least, rank 2 = second least.
--   Filter WHERE rank = 2.
-- ============================================================

WITH clinic_profit AS (
    SELECT
        s.cid,
        cl.clinic_name,
        cl.city,
        cl.state,
        MONTH(s.datetime)      AS month_num,
        MONTHNAME(s.datetime)  AS month_name,
        SUM(s.amount)          AS revenue
    FROM clinic_sales s
    JOIN clinics cl ON s.cid = cl.cid
    WHERE YEAR(s.datetime) = 2021
    GROUP BY s.cid, cl.clinic_name, cl.city, cl.state,
             MONTH(s.datetime), MONTHNAME(s.datetime)
),
clinic_expense AS (
    SELECT
        cid,
        MONTH(datetime)  AS month_num,
        SUM(amount)      AS expenses
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY cid, MONTH(datetime)
),
profit_ranked AS (
    SELECT
        p.cid,
        p.clinic_name,
        p.city,
        p.state,
        p.month_num,
        p.month_name,
        p.revenue,
        COALESCE(e.expenses, 0)                        AS expenses,
        (p.revenue - COALESCE(e.expenses, 0))          AS profit,
        DENSE_RANK() OVER (
            PARTITION BY p.state, p.month_num
            ORDER BY (p.revenue - COALESCE(e.expenses, 0)) ASC
        )                                              AS profit_rank
    FROM clinic_profit p
    LEFT JOIN clinic_expense e
           ON p.cid = e.cid AND p.month_num = e.month_num
)
SELECT
    state,
    month_num,
    month_name,
    clinic_name,
    city,
    revenue,
    expenses,
    profit
FROM profit_ranked
WHERE profit_rank = 2
ORDER BY state, month_num;

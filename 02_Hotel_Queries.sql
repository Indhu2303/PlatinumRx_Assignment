-- ============================================================
-- PlatinumRx Assignment | Hotel Management System
-- File: 02_Hotel_Queries.sql
-- Purpose: Queries for Part A (Questions 1–5)
-- ============================================================


-- ============================================================
-- Q1: Find the LAST BOOKED room (most recent booking)
-- ============================================================
-- LOGIC:
--   We want the booking with the latest (maximum) booking_date.
--   We JOIN bookings with users so we can also show the guest name.
--   ORDER BY booking_date DESC puts the latest date first.
--   LIMIT 1 picks only the top (most recent) row.
-- ============================================================

SELECT
    b.booking_id,
    b.booking_date,
    b.room_no,
    u.name         AS guest_name
FROM bookings b
JOIN users u ON b.user_id = u.user_id
ORDER BY b.booking_date DESC
LIMIT 1;


-- ============================================================
-- Q2: Total billing amount for each booking in NOVEMBER 2021
-- ============================================================
-- LOGIC:
--   We need to calculate: quantity × item_rate = line total
--   Then SUM all line totals per booking.
--
--   Tables involved:
--     bookings            → to filter by month (booking_date)
--     booking_commercials → has quantity for each item per booking
--     items               → has item_rate (price per unit)
--
--   We use YEAR() and MONTH() functions to filter November 2021.
--   GROUP BY booking_id gives one total row per booking.
-- ============================================================

SELECT
    b.booking_id,
    b.booking_date,
    b.room_no,
    u.name                                              AS guest_name,
    SUM(bc.item_quantity * i.item_rate)                 AS total_bill_amount
FROM bookings b
JOIN users u               ON b.user_id    = u.user_id
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i               ON bc.item_id   = i.item_id
WHERE YEAR(b.booking_date)  = 2021
  AND MONTH(b.booking_date) = 11
GROUP BY
    b.booking_id,
    b.booking_date,
    b.room_no,
    u.name;


-- ============================================================
-- Q3: Find all BILLS with total amount GREATER THAN 1000
-- ============================================================
-- LOGIC:
--   A "bill" is identified by bill_id in booking_commercials.
--   We sum up (quantity × rate) for all items on the same bill_id.
--   HAVING is like WHERE but it filters AFTER aggregation (after SUM).
--   So: GROUP BY bill_id → SUM the total → HAVING total > 1000
-- ============================================================

SELECT
    bc.bill_id,
    bc.bill_date,
    b.room_no,
    u.name                              AS guest_name,
    SUM(bc.item_quantity * i.item_rate) AS bill_total
FROM booking_commercials bc
JOIN bookings b ON bc.booking_id = b.booking_id
JOIN users u    ON b.user_id     = u.user_id
JOIN items i    ON bc.item_id    = i.item_id
GROUP BY
    bc.bill_id,
    bc.bill_date,
    b.room_no,
    u.name
HAVING bill_total > 1000
ORDER BY bill_total DESC;


-- ============================================================
-- Q4: MOST and LEAST ordered item per month (by quantity)
-- ============================================================
-- LOGIC:
--   Step 1 → Group by month + item, SUM the quantities ordered.
--   Step 2 → Use RANK() window function to rank items within
--            each month: rank 1 = most ordered.
--   Step 3 → Use RANK() again but in ASC order: rank 1 = least.
--   Step 4 → Filter where either rank = 1 to get top and bottom.
--
--   A CTE (WITH clause) is just a named temporary result —
--   it makes the query easier to read.
-- ============================================================

WITH monthly_item_totals AS (
    -- Step 1: Total quantity ordered per item per month
    SELECT
        MONTH(bc.bill_date)                         AS order_month,
        MONTHNAME(bc.bill_date)                     AS month_name,
        i.item_name,
        SUM(bc.item_quantity)                       AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY
        MONTH(bc.bill_date),
        MONTHNAME(bc.bill_date),
        i.item_name
),
ranked AS (
    -- Step 2 & 3: Rank items within each month (most and least)
    SELECT
        order_month,
        month_name,
        item_name,
        total_qty,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty DESC) AS rank_most,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty ASC)  AS rank_least
    FROM monthly_item_totals
)
-- Step 4: Show only the most and least ordered item per month
SELECT
    order_month,
    month_name,
    item_name,
    total_qty,
    CASE
        WHEN rank_most  = 1 THEN 'Most Ordered'
        WHEN rank_least = 1 THEN 'Least Ordered'
    END AS order_rank_label
FROM ranked
WHERE rank_most = 1 OR rank_least = 1
ORDER BY order_month, order_rank_label;


-- ============================================================
-- Q5: Find the 2nd HIGHEST bill amount
-- ============================================================
-- LOGIC:
--   Step 1 → Calculate total per bill_id (same as Q3).
--   Step 2 → Use DENSE_RANK() to rank bills by total descending.
--            DENSE_RANK means: if two bills tie for rank 1,
--            the next one is still rank 2 (not rank 3).
--   Step 3 → Filter WHERE rank = 2.
-- ============================================================

WITH bill_totals AS (
    -- Step 1: Sum each bill
    SELECT
        bc.bill_id,
        bc.bill_date,
        b.room_no,
        u.name                              AS guest_name,
        SUM(bc.item_quantity * i.item_rate) AS bill_total
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN users u    ON b.user_id     = u.user_id
    JOIN items i    ON bc.item_id    = i.item_id
    GROUP BY
        bc.bill_id,
        bc.bill_date,
        b.room_no,
        u.name
),
ranked_bills AS (
    -- Step 2: Rank bills by total amount (highest first)
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY bill_total DESC) AS bill_rank
    FROM bill_totals
)
-- Step 3: Pick rank = 2
SELECT
    bill_id,
    bill_date,
    room_no,
    guest_name,
    bill_total,
    bill_rank
FROM ranked_bills
WHERE bill_rank = 2;

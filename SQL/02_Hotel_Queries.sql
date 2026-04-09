-- ============================================================
-- PlatinumRx Assignment | Hotel Management System
-- File: 02_Hotel_Queries.sql
-- Purpose: Queries for Part A (Questions 1–5)
-- ============================================================


-- ============================================================
-- Q1: Find the LAST BOOKED room (most recent booking)
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

WITH monthly_item_totals AS (
    
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
    
    SELECT
        order_month,
        month_name,
        item_name,
        total_qty,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty DESC) AS rank_most,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty ASC)  AS rank_least
    FROM monthly_item_totals
)

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


WITH bill_totals AS (
    
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
   
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY bill_total DESC) AS bill_rank
    FROM bill_totals
)

SELECT
    bill_id,
    bill_date,
    room_no,
    guest_name,
    bill_total,
    bill_rank
FROM ranked_bills
WHERE bill_rank = 2;

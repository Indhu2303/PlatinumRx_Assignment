-- ============================================================
-- PlatinumRx Assignment | Hotel Management System
-- File: 01_Hotel_Schema_Setup.sql
-- Purpose: Create tables and insert sample data
-- ============================================================

-- Drop tables if they exist (for re-runs)
DROP TABLE IF EXISTS booking_commercials;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;

-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE users (
    user_id        VARCHAR(50) PRIMARY KEY,
    name           VARCHAR(100),
    phone_number   VARCHAR(20),
    mail_id        VARCHAR(100),
    billing_address TEXT
);

-- ============================================================
-- TABLE: items
-- ============================================================
CREATE TABLE items (
    item_id    VARCHAR(50) PRIMARY KEY,
    item_name  VARCHAR(100),
    item_rate  DECIMAL(10, 2)
);

-- ============================================================
-- TABLE: bookings
-- ============================================================
CREATE TABLE bookings (
    booking_id   VARCHAR(50) PRIMARY KEY,
    booking_date DATETIME,
    room_no      VARCHAR(50),
    user_id      VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================================
-- TABLE: booking_commercials
-- ============================================================
CREATE TABLE booking_commercials (
    id            VARCHAR(50) PRIMARY KEY,
    booking_id    VARCHAR(50),
    bill_id       VARCHAR(50),
    bill_date     DATETIME,
    item_id       VARCHAR(50),
    item_quantity DECIMAL(10, 2),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (item_id)    REFERENCES items(item_id)
);

-- ============================================================
-- SAMPLE DATA: users
-- ============================================================
INSERT INTO users (user_id, name, phone_number, mail_id, billing_address) VALUES
('21wrcxuy-67erfn', 'John Doe',    '9700000001', 'john.doe@example.com',    '10, Street A, Mumbai'),
('user-002-abc',    'Jane Smith',  '9700000002', 'jane.smith@example.com',  '20, Street B, Delhi'),
('user-003-xyz',    'Ravi Kumar',  '9700000003', 'ravi.kumar@example.com',  '30, Street C, Pune'),
('user-004-pqr',    'Priya Nair',  '9700000004', 'priya.nair@example.com',  '40, Street D, Chennai'),
('user-005-lmn',    'Amit Sharma', '9700000005', 'amit.sharma@example.com', '50, Street E, Hyderabad');

-- ============================================================
-- SAMPLE DATA: items
-- ============================================================
INSERT INTO items (item_id, item_name, item_rate) VALUES
('itm-a9e8-q8fu',  'Tawa Paratha',     18.00),
('itm-a07vh-aer8', 'Mix Veg',          89.00),
('itm-w978-23u4',  'Butter Chicken',  220.00),
('itm-k123-r9s2',  'Cold Coffee',      80.00),
('itm-m456-t3u7',  'Masala Chai',      30.00),
('itm-n789-v5w8',  'Paneer Tikka',    180.00),
('itm-p012-x7y9',  'Biryani',         250.00),
('itm-q345-z9a1',  'Fresh Juice',      60.00),
('itm-r678-b2c3',  'Club Sandwich',   120.00),
('itm-s901-d4e5',  'Dessert Platter', 150.00);

-- ============================================================
-- SAMPLE DATA: bookings  (spread across 2021 to test queries)
-- ============================================================
INSERT INTO bookings (booking_id, booking_date, room_no, user_id) VALUES
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn'),
('bk-q034-q4o',   '2021-09-23 07:40:00', 'rm-c123-aaaa',  'user-002-abc'),
('bk-nov1-001',   '2021-11-05 10:00:00', 'rm-d456-bbbb',  '21wrcxuy-67erfn'),
('bk-nov1-002',   '2021-11-12 14:00:00', 'rm-e789-cccc',  'user-002-abc'),
('bk-nov1-003',   '2021-11-20 09:00:00', 'rm-f012-dddd',  'user-003-xyz'),
('bk-oct1-001',   '2021-10-03 11:00:00', 'rm-g345-eeee',  'user-004-pqr'),
('bk-oct1-002',   '2021-10-15 13:00:00', 'rm-h678-ffff',  'user-005-lmn'),
('bk-oct1-003',   '2021-10-28 16:00:00', 'rm-i901-gggg',  '21wrcxuy-67erfn'),
('bk-jan1-001',   '2021-01-10 08:00:00', 'rm-j234-hhhh',  'user-002-abc'),
('bk-feb1-001',   '2021-02-14 12:00:00', 'rm-k567-iiii',  'user-003-xyz'),
('bk-mar1-001',   '2021-03-01 09:00:00', 'rm-l890-jjjj',  'user-004-pqr'),
('bk-dec1-001',   '2021-12-25 10:00:00', 'rm-m123-kkkk',  'user-005-lmn');

-- ============================================================
-- SAMPLE DATA: booking_commercials
-- ============================================================
INSERT INTO booking_commercials (id, booking_id, bill_id, bill_date, item_id, item_quantity) VALUES
-- September bookings
('q34r-3q4o8-q34u', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('q3o4-ahf32-o2u4', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1),
('134lr-oyfo8-3qk4','bk-q034-q4o',   'bl-34qhd-r7h8', '2021-09-23 12:05:37', 'itm-w978-23u4', 0.5),

-- November bookings (for Q2)
('nov-bc-001', 'bk-nov1-001', 'bl-nov-001', '2021-11-05 13:00:00', 'itm-w978-23u4', 2),
('nov-bc-002', 'bk-nov1-001', 'bl-nov-001', '2021-11-05 13:00:00', 'itm-a07vh-aer8', 3),
('nov-bc-003', 'bk-nov1-002', 'bl-nov-002', '2021-11-12 15:00:00', 'itm-p012-x7y9', 2),
('nov-bc-004', 'bk-nov1-002', 'bl-nov-002', '2021-11-12 15:00:00', 'itm-n789-v5w8', 1),
('nov-bc-005', 'bk-nov1-003', 'bl-nov-003', '2021-11-20 10:00:00', 'itm-k123-r9s2', 4),
('nov-bc-006', 'bk-nov1-003', 'bl-nov-003', '2021-11-20 10:00:00', 'itm-r678-b2c3', 2),

-- October bookings (for Q3 — bills > 1000)
('oct-bc-001', 'bk-oct1-001', 'bl-oct-001', '2021-10-03 12:00:00', 'itm-w978-23u4', 4),    -- 880
('oct-bc-002', 'bk-oct1-001', 'bl-oct-001', '2021-10-03 12:00:00', 'itm-p012-x7y9', 2),    -- 500  total=1380
('oct-bc-003', 'bk-oct1-002', 'bl-oct-002', '2021-10-15 14:00:00', 'itm-n789-v5w8', 3),    -- 540
('oct-bc-004', 'bk-oct1-002', 'bl-oct-002', '2021-10-15 14:00:00', 'itm-s901-d4e5', 4),    -- 600  total=1140
('oct-bc-005', 'bk-oct1-003', 'bl-oct-003', '2021-10-28 17:00:00', 'itm-m456-t3u7', 2),    --  60
('oct-bc-006', 'bk-oct1-003', 'bl-oct-003', '2021-10-28 17:00:00', 'itm-a9e8-q8fu', 5),    --  90  total=150 (below 1000)

-- Jan/Feb/Mar/Dec for Q4 monthly item ordering
('jan-bc-001', 'bk-jan1-001', 'bl-jan-001', '2021-01-10 09:00:00', 'itm-a9e8-q8fu', 5),
('jan-bc-002', 'bk-jan1-001', 'bl-jan-001', '2021-01-10 09:00:00', 'itm-m456-t3u7', 2),
('jan-bc-003', 'bk-jan1-001', 'bl-jan-001', '2021-01-10 09:00:00', 'itm-a9e8-q8fu', 3),
('feb-bc-001', 'bk-feb1-001', 'bl-feb-001', '2021-02-14 13:00:00', 'itm-p012-x7y9', 3),
('feb-bc-002', 'bk-feb1-001', 'bl-feb-001', '2021-02-14 13:00:00', 'itm-n789-v5w8', 2),
('mar-bc-001', 'bk-mar1-001', 'bl-mar-001', '2021-03-01 10:00:00', 'itm-w978-23u4', 4),
('mar-bc-002', 'bk-mar1-001', 'bl-mar-001', '2021-03-01 10:00:00', 'itm-q345-z9a1', 1),
('dec-bc-001', 'bk-dec1-001', 'bl-dec-001', '2021-12-25 11:00:00', 'itm-s901-d4e5', 6),
('dec-bc-002', 'bk-dec1-001', 'bl-dec-001', '2021-12-25 11:00:00', 'itm-k123-r9s2', 1);

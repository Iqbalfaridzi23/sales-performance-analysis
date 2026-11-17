-- =====================================================================
-- File    : 03_data_validation.sql
-- Tujuan  : Memastikan data di database sama dengan hasil cleaning di Python
-- Angka yang diharapkan ada di komentar.
-- =====================================================================

-- [V1] Jumlah baris dan jumlah pesanan unik            -> 9993 | 5009
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS total_orders
FROM superstore_sales;

-- [V2] Total sales dan profit                           -> 2296919.49 | 286409.08
SELECT ROUND(SUM(sales), 2) AS total_sales, ROUND(SUM(profit), 2) AS total_profit
FROM superstore_sales;

-- [V3] Tidak ada duplikat (semua kolom sama)            -> 0 baris
SELECT order_id, product_id, sales, quantity, discount, profit, COUNT(*) AS jumlah
FROM superstore_sales
GROUP BY order_id, product_id, sales, quantity, discount, profit, order_date, ship_date, customer_id
HAVING COUNT(*) > 1;

-- [V4] Ship Date tidak boleh lebih awal dari Order Date -> 0
SELECT COUNT(*) AS tanggal_tidak_valid
FROM superstore_sales
WHERE ship_date < order_date;

-- [V5] Kode pos harus 5 karakter                        -> 0 baris bermasalah
SELECT COUNT(*) AS postal_code_bermasalah
FROM superstore_sales
WHERE LENGTH(postal_code) <> 5;

-- [V6] Kode pos berawalan 0 hanya di timur laut AS      -> 7 state
SELECT DISTINCT state
FROM superstore_sales
WHERE postal_code LIKE '0%'
ORDER BY state;

-- [V7] Rentang tanggal dan nilai diskon yang wajar
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
       MIN(discount) AS min_discount, MAX(discount) AS max_discount
FROM superstore_sales;

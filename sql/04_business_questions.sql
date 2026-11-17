-- =====================================================================
-- Project 01: Sales Performance Analysis
-- File    : 04_business_questions.sql
-- Tujuan  : Menjawab 10 business questions dengan SQL (PostgreSQL)
--
-- Konvensi:
--   * margin_pct = SUM(profit) / SUM(sales) * 100  (bukan rata-rata margin per baris)
--   * jumlah pesanan = COUNT(DISTINCT order_id)    (1 baris = 1 item produk)
--   * Setiap hasil sudah dicocokkan dengan perhitungan pandas di notebook EDA.
-- =====================================================================


-- =====================================================================
-- Q1. Berapa total sales, profit, margin? Bagaimana trennya per tahun?
-- =====================================================================

-- >>> Q1a: KPI utama   (diharapkan: 2296919.49 | 286409.08 | 12.47 | 5009 | 793 | 458.56)
SELECT
    ROUND(SUM(sales), 2)                              AS total_sales,
    ROUND(SUM(profit), 2)                             AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)          AS profit_margin_pct,
    COUNT(DISTINCT order_id)                          AS total_orders,
    COUNT(DISTINCT customer_id)                       AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)   AS avg_order_value
FROM superstore_sales;

-- >>> Q1b: Tren tahunan + pertumbuhan (window function LAG)
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT AS year,
        SUM(sales)                         AS sales,
        SUM(profit)                        AS profit,
        COUNT(DISTINCT order_id)           AS orders
    FROM superstore_sales
    GROUP BY 1
)
SELECT
    year,
    ROUND(sales, 2)                                          AS sales,
    ROUND(profit, 2)                                         AS profit,
    orders,
    ROUND(profit / sales * 100, 2)                           AS margin_pct,
    ROUND(sales / orders, 2)                                 AS avg_order_value,
    ROUND((sales  / LAG(sales)  OVER (ORDER BY year) - 1) * 100, 2) AS sales_growth_pct,
    ROUND((profit / LAG(profit) OVER (ORDER BY year) - 1) * 100, 2) AS profit_growth_pct
FROM yearly
ORDER BY year;

-- >>> Q1c: Pertumbuhan kumulatif 2014 -> 2017   (diharapkan: sales +51.5% | profit +88.6% | orders +74.1%)
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM order_date)::INT AS year,
           SUM(sales) AS sales, SUM(profit) AS profit, COUNT(DISTINCT order_id) AS orders
    FROM superstore_sales
    GROUP BY 1
)
SELECT
    ROUND((MAX(sales)  FILTER (WHERE year = 2017) / MAX(sales)  FILTER (WHERE year = 2014) - 1) * 100, 1) AS sales_growth_pct,
    ROUND((MAX(profit) FILTER (WHERE year = 2017) / MAX(profit) FILTER (WHERE year = 2014) - 1) * 100, 1) AS profit_growth_pct,
    ROUND((MAX(orders) FILTER (WHERE year = 2017)::NUMERIC / MAX(orders) FILTER (WHERE year = 2014) - 1) * 100, 1) AS orders_growth_pct
FROM yearly;


-- =====================================================================
-- Q2. Apakah ada pola musiman?
-- =====================================================================

-- >>> Q2a: Margin kuartalan + pembanding kuartal yang sama tahun lalu (LAG 4 baris)
--          (diharapkan: 2016-Q4 16.15 | 2017-Q4 9.80)
WITH quarterly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT    AS year,
        EXTRACT(QUARTER FROM order_date)::INT AS quarter,
        SUM(sales)  AS sales,
        SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY 1, 2
)
SELECT
    year || '-Q' || quarter                          AS year_quarter,
    ROUND(sales, 2)                                  AS sales,
    ROUND(profit, 2)                                 AS profit,
    ROUND(profit / sales * 100, 2)                   AS margin_pct,
    ROUND(LAG(profit / sales * 100, 4) OVER (ORDER BY year, quarter), 2) AS margin_pct_same_q_last_year
FROM quarterly
ORDER BY year, quarter;

-- >>> Q2b: Musiman bulanan = rata-rata total bulanan per tahun
--          (diharapkan: Nov sales 88115.27 margin 10.06 | Feb sales 14937.81 margin 17.23)
WITH monthly AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT  AS year,
        EXTRACT(MONTH FROM order_date)::INT AS month,
        SUM(sales)  AS sales,
        SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY 1, 2
)
SELECT
    month,
    TO_CHAR(TO_DATE(month::TEXT, 'MM'), 'Mon')   AS month_name,
    ROUND(AVG(sales), 2)                         AS avg_sales,
    ROUND(AVG(profit), 2)                        AS avg_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)     AS margin_pct
FROM monthly
GROUP BY month
ORDER BY month;

-- >>> Q2c: Bulan dengan profit negatif   (diharapkan: 2014-07 dan 2015-01)
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS year_month,
    ROUND(SUM(sales), 2)           AS sales,
    ROUND(SUM(profit), 2)          AS profit
FROM superstore_sales
GROUP BY 1
HAVING SUM(profit) < 0
ORDER BY 1;


-- =====================================================================
-- Q3. Kategori dan sub-kategori mana yang paling menguntungkan / rugi?
-- =====================================================================

-- >>> Q3a: Per kategori   (diharapkan: Furniture margin 2.49 | Office 17.04 | Technology 17.40)
SELECT
    category,
    ROUND(SUM(sales), 2)                              AS sales,
    ROUND(SUM(profit), 2)                             AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)          AS margin_pct,
    ROUND(SUM(sales)  / SUM(SUM(sales))  OVER () * 100, 1) AS share_of_sales_pct,
    ROUND(SUM(profit) / SUM(SUM(profit)) OVER () * 100, 1) AS share_of_profit_pct
FROM superstore_sales
GROUP BY category
ORDER BY profit DESC;

-- >>> Q3b: Per sub-kategori + peringkat di dalam kategori
--          (diharapkan rugi: Tables -17725.48 | Bookcases -3472.56 | Supplies -1189.10)
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2)                                   AS sales,
    ROUND(SUM(profit), 2)                                  AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)               AS margin_pct,
    ROUND(SUM(profit) / SUM(SUM(profit)) OVER () * 100, 2) AS share_of_total_profit_pct,
    RANK() OVER (PARTITION BY category ORDER BY SUM(profit) DESC) AS rank_in_category
FROM superstore_sales
GROUP BY category, sub_category
ORDER BY profit;


-- =====================================================================
-- Q4. Produk apa yang sales-nya tinggi tetapi profit-nya negatif?
-- =====================================================================

-- >>> Q4a: Ringkasan produk merugi   (diharapkan: 299 dari 1850 | total -77068.38; 2 produk dengan profit ~0 tidak dihitung rugi)
WITH produk AS (
    SELECT product_name, SUM(sales) AS sales, SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY product_name
)
SELECT
    COUNT(*)                                        AS total_products,
    COUNT(*) FILTER (WHERE profit < 0)              AS loss_products,
    ROUND(SUM(profit) FILTER (WHERE profit < 0), 2) AS total_loss
FROM produk;

-- >>> Q4b: 10 produk dengan profit paling negatif   (teratas: Cubify CubeX 3D Printer Double Head Print -8879.97)
SELECT
    product_name,
    ROUND(SUM(sales), 2)                      AS sales,
    ROUND(SUM(profit), 2)                     AS profit,
    ROUND(AVG(discount) * 100, 1)             AS avg_discount_pct,
    COUNT(DISTINCT order_id)                  AS orders
FROM superstore_sales
GROUP BY product_name
ORDER BY SUM(profit)
LIMIT 10;

-- >>> Q4c: Produk di 10% sales teratas yang profit-nya negatif (NTILE)
WITH produk AS (
    SELECT product_name, SUM(sales) AS sales, SUM(profit) AS profit,
           ROUND(AVG(discount) * 100, 1) AS avg_discount_pct
    FROM superstore_sales
    GROUP BY product_name
),
dengan_desil AS (
    SELECT *, NTILE(10) OVER (ORDER BY sales DESC) AS sales_decile
    FROM produk
)
SELECT product_name, ROUND(sales, 2) AS sales, ROUND(profit, 2) AS profit, avg_discount_pct
FROM dengan_desil
WHERE sales_decile = 1 AND profit < 0
ORDER BY sales DESC
LIMIT 10;


-- =====================================================================
-- Q5. Region, state, dan kota mana yang berkontribusi / menjadi beban?
-- =====================================================================

-- >>> Q5a: Per region   (diharapkan: Central margin 7.92, rata-rata diskon 24.0 | West 14.94)
SELECT
    region,
    ROUND(SUM(sales), 2)                      AS sales,
    ROUND(SUM(profit), 2)                     AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)  AS margin_pct,
    ROUND(AVG(discount) * 100, 1)             AS avg_discount_pct
FROM superstore_sales
GROUP BY region
ORDER BY profit;

-- >>> Q5b: 10 state dengan profit terendah   (diharapkan: Texas -25729.36, Ohio -16959.32, Pennsylvania -15559.96, Illinois -12607.89)
SELECT
    state,
    ROUND(SUM(sales), 2)                      AS sales,
    ROUND(SUM(profit), 2)                     AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)  AS margin_pct,
    ROUND(AVG(discount) * 100, 1)             AS avg_discount_pct,
    RANK() OVER (ORDER BY SUM(profit))        AS loss_rank
FROM superstore_sales
GROUP BY state
ORDER BY profit
LIMIT 10;

-- >>> Q5c: Ringkasan state merugi   (diharapkan: 10 state | total -98234.68 | 30.7% sales | diskon 33.6% vs 4.2%)
WITH state_profit AS (
    SELECT state, SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY state
)
SELECT
    CASE WHEN sp.profit < 0 THEN 'State merugi' ELSE 'State lain' END AS kelompok,
    COUNT(DISTINCT t.state)                                          AS jumlah_state,
    ROUND(SUM(t.profit), 2)                                          AS total_profit,
    ROUND(SUM(t.sales) / SUM(SUM(t.sales)) OVER () * 100, 1)         AS share_of_sales_pct,
    ROUND(AVG(t.discount) * 100, 1)                                  AS avg_discount_pct
FROM superstore_sales t
JOIN state_profit sp USING (state)
GROUP BY 1
ORDER BY 1 DESC;

-- >>> Q5d: 10 kota dengan profit terendah   (teratas: Philadelphia -13837.77, Houston -10153.55)
SELECT
    city, state,
    ROUND(SUM(sales), 2)  AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct
FROM superstore_sales
GROUP BY city, state
ORDER BY SUM(profit)
LIMIT 10;


-- =====================================================================
-- Q6. Segmen pelanggan mana yang paling bernilai?
-- =====================================================================

-- >>> Q6: Per segmen   (diharapkan: Consumer margin 11.55 | Corporate 13.03 | Home Office 14.05)
SELECT
    segment,
    ROUND(SUM(sales), 2)                                   AS sales,
    ROUND(SUM(profit), 2)                                  AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)               AS margin_pct,
    COUNT(DISTINCT customer_id)                            AS customers,
    COUNT(DISTINCT order_id)                               AS orders,
    ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1)   AS share_of_sales_pct
FROM superstore_sales
GROUP BY segment
ORDER BY profit DESC;


-- =====================================================================
-- Q7. Siapa pelanggan teratas dan seberapa besar ketergantungan bisnis?
-- =====================================================================

-- >>> Q7a: 10 pelanggan dengan sales terbesar   (teratas: Sean Miller 25043.05, profit -1980.74)
SELECT
    customer_id, customer_name,
    ROUND(SUM(sales), 2)  AS sales,
    ROUND(SUM(profit), 2) AS profit,
    COUNT(DISTINCT order_id) AS orders
FROM superstore_sales
GROUP BY customer_id, customer_name
ORDER BY SUM(sales) DESC
LIMIT 10;

-- >>> Q7b: Porsi 10 pelanggan teratas   (diharapkan: 6.7% sales | 14.4% profit)
WITH cust AS (
    SELECT customer_id, SUM(sales) AS sales, SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY customer_id
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
    FROM cust
)
SELECT
    ROUND(SUM(sales)  FILTER (WHERE rn <= 10) / SUM(sales)  * 100, 1) AS top10_share_of_sales_pct,
    ROUND(SUM(profit) FILTER (WHERE rn <= 10) / SUM(profit) * 100, 1) AS top10_share_of_profit_pct
FROM ranked;

-- >>> Q7c: Analisis Pareto   (diharapkan: 396 dari 793 pelanggan = 49.9% untuk mencapai 80% sales)
WITH cust AS (
    SELECT customer_id, SUM(sales) AS sales
    FROM superstore_sales
    GROUP BY customer_id
),
kumulatif AS (
    SELECT
        customer_id,
        SUM(sales) OVER (ORDER BY sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            / SUM(sales) OVER () AS cum_share
    FROM cust
)
SELECT
    COUNT(*) FILTER (WHERE cum_share < 0.8) + 1                              AS customers_for_80pct_sales,
    (SELECT COUNT(*) FROM cust)                                              AS total_customers,
    ROUND((COUNT(*) FILTER (WHERE cum_share < 0.8) + 1) * 100.0 / (SELECT COUNT(*) FROM cust), 1) AS pct_of_customers
FROM kumulatif;

-- >>> Q7d: Pelanggan dengan total profit negatif   (diharapkan: 155 dari 793 | total -71212.42)
WITH cust AS (
    SELECT customer_id, SUM(profit) AS profit
    FROM superstore_sales
    GROUP BY customer_id
)
SELECT
    COUNT(*) FILTER (WHERE profit < 0)              AS loss_customers,
    COUNT(*)                                        AS total_customers,
    ROUND(SUM(profit) FILTER (WHERE profit < 0), 2) AS total_loss
FROM cust;


-- =====================================================================
-- Q8. Bagaimana hubungan diskon dengan profit?
-- =====================================================================

-- >>> Q8a: Margin per kelompok diskon
--          (diharapkan: 0% 29.51 | 1-20% 11.91 | 21-40% -15.31 | >40% -77.40)
SELECT
    CASE
        WHEN discount = 0   THEN '0%'
        WHEN discount <= 0.2 THEN '1-20%'
        WHEN discount <= 0.4 THEN '21-40%'
        ELSE '>40%'
    END                                           AS discount_band,
    COUNT(*)                                      AS rows,
    ROUND(SUM(sales), 2)                          AS sales,
    ROUND(SUM(profit), 2)                         AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)      AS margin_pct
FROM superstore_sales
GROUP BY 1
ORDER BY MIN(discount);

-- >>> Q8b: Kontribusi transaksi diskon > 20%
--          (diharapkan: 1392 baris = 13.9% | 15.8% sales | profit -135364.00 | margin diskon <=20%: 21.80)
SELECT
    COUNT(*) FILTER (WHERE discount > 0.2)                                              AS high_discount_rows,
    ROUND(COUNT(*) FILTER (WHERE discount > 0.2) * 100.0 / COUNT(*), 1)                 AS pct_of_rows,
    ROUND(SUM(sales)  FILTER (WHERE discount > 0.2) / SUM(sales) * 100, 1)              AS pct_of_sales,
    ROUND(SUM(profit) FILTER (WHERE discount > 0.2), 2)                                 AS profit_high_discount,
    ROUND(SUM(profit) FILTER (WHERE discount <= 0.2)
          / SUM(sales) FILTER (WHERE discount <= 0.2) * 100, 2)                         AS margin_pct_discount_up_to_20
FROM superstore_sales;

-- >>> Q8c: Diskon per sub-kategori   (diharapkan: Machines avg 30.6 / 46.1% baris >20% | Tables 26.1 / 55.2% | Binders 37.2 tapi tetap untung)
SELECT
    sub_category,
    ROUND(AVG(discount) * 100, 2)                              AS avg_discount_pct,
    ROUND(AVG((discount > 0.2)::INT) * 100, 2)                 AS pct_rows_discount_gt_20,
    ROUND(SUM(profit), 2)                                      AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)                   AS margin_pct
FROM superstore_sales
GROUP BY sub_category
ORDER BY avg_discount_pct DESC;


-- =====================================================================
-- Q9. Apakah mode pengiriman memengaruhi profitabilitas?
-- =====================================================================

-- >>> Q9: Per mode pengiriman   (diharapkan: margin 12.08 - 13.93; rata-rata durasi Same Day 0.04 | First 2.18 | Second 3.24 | Standard 5.01 hari)
SELECT
    ship_mode,
    ROUND(SUM(sales), 2)                                   AS sales,
    ROUND(SUM(profit), 2)                                  AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)               AS margin_pct,
    ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1)   AS share_of_sales_pct,
    ROUND(AVG(shipping_duration), 2)                       AS avg_shipping_days
FROM superstore_sales
GROUP BY ship_mode
ORDER BY profit DESC;


-- =====================================================================
-- Q10. Dukungan data untuk rekomendasi
-- =====================================================================

-- >>> Q10a: Hipotesis Q4 2017 - komposisi diskon dalam
--           (diharapkan 2016: sales diskon>20% 29706.07 profit -14681.72 | 2017: 48242.38 / -24209.59)
WITH q4 AS (
    SELECT EXTRACT(YEAR FROM order_date)::INT AS year, sales, profit, discount
    FROM superstore_sales
    WHERE EXTRACT(QUARTER FROM order_date) = 4
)
SELECT
    year,
    ROUND(SUM(sales), 2)                                    AS sales,
    ROUND(SUM(profit), 2)                                   AS profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)                AS margin_pct,
    ROUND(AVG(discount) * 100, 2)                           AS avg_discount_pct,
    ROUND(SUM(sales)  FILTER (WHERE discount > 0.2), 2)     AS sales_discount_gt_20,
    ROUND(SUM(profit) FILTER (WHERE discount > 0.2), 2)     AS profit_discount_gt_20
FROM q4
GROUP BY year
ORDER BY year;

-- >>> Q10b: Daftar sub-kategori yang merugi (prioritas tinjauan harga/diskon)
SELECT sub_category,
       ROUND(SUM(profit), 2)                        AS profit,
       ROUND(AVG(discount) * 100, 1)                AS avg_discount_pct
FROM superstore_sales
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit;

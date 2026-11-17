-- =====================================================================
-- File    : 02_load_data.sql
-- Tujuan  : Memuat CSV bersih ke tabel superstore_sales
--
-- CARA 1 (psql, jalankan dari FOLDER UTAMA proyek):
--   psql -U postgres -d superstore -f sql/01_create_table.sql
--   psql -U postgres -d superstore -f sql/02_load_data.sql
--
-- CARA 2 (pgAdmin): klik kanan tabel superstore_sales > Import/Export Data
--   Format: csv | Header: ON | Delimiter: , | Encoding: UTF8
--
-- Perintah \copy dijalankan di sisi klien (psql), jadi path relatif terhadap
-- folder tempat psql dijalankan. Di Windows, gunakan garis miring biasa (/).
-- =====================================================================

\copy superstore_sales FROM 'data/cleaned/Sample-Superstore-Cleaned.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- Verifikasi cepat (harus 9993 baris)
SELECT COUNT(*) AS total_rows FROM superstore_sales;

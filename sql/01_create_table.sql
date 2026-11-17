-- =====================================================================
-- Project 01: Sales Performance Analysis
-- File    : 01_create_table.sql
-- Tujuan  : Membuat tabel untuk data bersih (hasil notebook 02_data_cleaning)
-- Dialek  : PostgreSQL
-- Urutan kolom HARUS sama dengan file CSV bersih.
-- =====================================================================

DROP TABLE IF EXISTS superstore_sales;

CREATE TABLE superstore_sales (
    order_id           VARCHAR(20)    NOT NULL,
    order_date         DATE           NOT NULL,
    ship_date          DATE           NOT NULL,
    ship_mode          VARCHAR(20)    NOT NULL,
    customer_id        VARCHAR(15)    NOT NULL,
    customer_name      VARCHAR(60)    NOT NULL,
    segment            VARCHAR(20)    NOT NULL,
    city               VARCHAR(60)    NOT NULL,
    state              VARCHAR(40)    NOT NULL,
    postal_code        CHAR(5)        NOT NULL,   -- teks 5 karakter: nol di depan harus tetap ada
    region             VARCHAR(15)    NOT NULL,
    product_id         VARCHAR(20)    NOT NULL,
    category           VARCHAR(30)    NOT NULL,
    sub_category       VARCHAR(30)    NOT NULL,
    product_name       VARCHAR(200)   NOT NULL,
    sales              NUMERIC(12,4)  NOT NULL,
    quantity           INTEGER        NOT NULL,
    discount           NUMERIC(4,2)   NOT NULL,
    profit             NUMERIC(12,4)  NOT NULL,
    shipping_duration  INTEGER        NOT NULL
);

-- Catatan granularitas: SATU BARIS = SATU ITEM PRODUK DALAM SEBUAH PESANAN.
-- Satu order_id bisa muncul di banyak baris, jadi jumlah pesanan = COUNT(DISTINCT order_id).

COMMENT ON TABLE superstore_sales IS 'Data transaksi Superstore (bersih): 1 baris = 1 item produk dalam 1 pesanan';

# Sales Performance Analysis

Analisis kinerja penjualan sebuah jaringan ritel (dataset Superstore, 2014-2017) untuk menemukan **di mana profit bocor** dan apa yang perlu dilakukan manajemen. Proyek ini mencakup pembersihan data, EDA dengan Python, analisis dengan SQL (PostgreSQL), dan rekomendasi bisnis.

> **Ringkasan temuan:** penjualan tumbuh 51,5% dan profit 88,6% (2014 → 2017), tetapi margin tipis (12,47%). Transaksi dengan diskon di atas 20% hanya 13,9% dari baris data, namun menghasilkan profit **−135.364**, hampir setengah dari profit bersih.

<!-- Tambahkan screenshot dashboard di sini setelah dashboard selesai:
![Dashboard](dashboard/dashboard_overview.png)
-->

## 1. Business Problem

Manajemen perlu laporan kinerja penjualan untuk rapat strategi tahun depan. Dugaan awal: *"sales naik, tetapi profit tidak sebanding."* Tugas analis adalah memeriksa dugaan itu, menemukan produk, wilayah, segmen, dan praktik diskon yang mendorong atau justru menggerus profit, lalu memberi rekomendasi yang bisa ditindaklanjuti.

**Pertanyaan bisnis yang dijawab**

1. Berapa total sales, profit, dan margin, dan bagaimana trennya per tahun?
2. Apakah ada pola musiman?
3. Kategori dan sub-kategori mana yang paling menguntungkan dan mana yang merugi?
4. Produk apa yang sales-nya tinggi tetapi profit-nya negatif?
5. Region, state, dan kota mana yang berkontribusi atau menjadi beban?
6. Segmen pelanggan mana yang paling bernilai?
7. Siapa pelanggan teratas, dan seberapa besar ketergantungan bisnis padanya?
8. Bagaimana hubungan diskon dengan profit?
9. Apakah mode pengiriman memengaruhi profitabilitas?
10. Apa rekomendasi berdasarkan seluruh temuan?

## 2. Dataset

- **Sumber:** [Superstore Dataset (Kaggle)](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- **Isi:** 9.994 baris transaksi, 21 kolom (pesanan, pelanggan, produk, pengiriman, sales, diskon, profit), periode 2014-2017.
- **Catatan:** ini dataset **sampel/fiktif** yang populer untuk latihan analitik, bukan data bisnis nyata. Data tidak memuat biaya produk, sehingga analisis ini deskriptif dan tidak membuktikan hubungan sebab-akibat.
- Periksa ketentuan lisensi dataset di halaman Kaggle sebelum memakai ulang data.

## 3. Tools

| Tools | Fungsi |
|---|---|
| Python (pandas, matplotlib) di Jupyter Notebook | Cleaning, EDA, visualisasi |
| SQL (PostgreSQL) | Agregasi dan analisis dengan CTE dan window function |
| Power BI | Dashboard interaktif*
| Git dan GitHub | Version control dan publikasi |

## 4. Struktur Repositori

```
sales-performance-analysis/
├── data/
│   ├── raw/                 # data asli, tidak diubah
│   └── cleaned/             # data hasil cleaning (9.993 baris x 20 kolom)
├── notebooks/
│   ├── 01_data_understanding.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_eda.ipynb
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_load_data.sql
│   ├── 03_data_validation.sql
│   └── 04_business_questions.sql
├── dashboard/               # screenshot dan file dashboard
├── reports/
│   └── executive_summary.md
└── README.md
```

## 5. Metodologi

### Data cleaning
Setiap keputusan didokumentasikan di `notebooks/02_data_cleaning.ipynb`.

| Masalah | Temuan | Keputusan |
|---|---|---|
| Granularitas | 9.994 baris, 5.009 pesanan | 1 baris = 1 item produk; jumlah pesanan dihitung dari `Order ID` unik |
| Tipe tanggal | Terbaca sebagai teks | Diubah ke datetime (format `%m/%d/%Y`) |
| Duplikat | 1 baris identik (terlewat jika `Row ID` ikut dibandingkan) | Dihapus, tersisa 9.993 baris |
| `Postal Code` | Terbaca sebagai angka, nol di depan hilang | Diubah ke teks 5 karakter |
| Logika tanggal | 0 baris dengan `Ship Date` < `Order Date` | Ditambahkan kolom `shipping_duration` |
| Konsistensi nama | 32 `Product ID` bernama ganda, 16 `Product Name` ber-ID ganda | Analisis produk memakai `Product Name` |
| Outlier `Profit` | 1.881 baris (±18,8%) menurut IQR | Dipertahankan: nilai ekstrem adalah transaksi yang sah |
| Kolom | `Row ID` dan `Country` tidak informatif | Dibuang; nama kolom diubah ke `snake_case` |

### EDA dan SQL
EDA dilakukan di `notebooks/03_eda.ipynb`. Pertanyaan bisnis yang sama dijawab ulang dengan SQL di `sql/04_business_questions.sql`, dan **hasil SQL dicocokkan dengan hasil pandas** (total sales, margin per sub-kategori, kelompok diskon, state, dan pelanggan semuanya identik).

> Contoh catatan teknis: pandas menghitung 301 produk merugi, SQL menghitung 299. Selisihnya dua produk impas dengan profit −1,8e-15 (artefak pembulatan float). Perhitungan akhir memakai pembulatan 2 desimal.

## 6. Temuan Utama

| # | Temuan | Angka kunci |
|---|---|---|
| 1 | Dugaan awal tidak terbukti secara agregat | Sales +51,5%, profit +88,6% (2014 → 2017); namun margin tipis (12,47%) |
| 2 | **Diskon di atas 20% menggerus profit** | 13,9% baris menghasilkan profit −135.364 (≈ −47% dari profit bersih); margin transaksi diskon ≤20% = 21,8%. Titik impas diskon ≈ 20% |
| 3 | Furniture bermargin sangat rendah | 2,49% vs ±17% di kategori lain; Tables −17.725, Bookcases −3.473 |
| 4 | Sepuluh dari 49 state merugi | Total −98.235 pada ±31% sales; diskon rata-rata 33,6% vs 4,2% di state lain (Texas, Ohio, Pennsylvania, Illinois terbesar) |
| 5 | Region Central terlemah | Margin 7,92%, diskon rata-rata 24% (West: 14,94%) |
| 6 | Produk bernilai tinggi dengan diskon dalam | 299 dari 1.850 produk merugi (total ≈ −77.068); terbesar Cubify CubeX 3D Printer (diskon 53%) |
| 7 | Profit pelanggan tidak sejalan dengan sales | 155 pelanggan (19,5%) merugi (≈ −71.212); 10 pelanggan teratas hanya 6,7% sales |
| 8 | Jumlah pesanan naik, nilai per pesanan turun | Pesanan +74%, rata-rata nilai pesanan −13% (499 → 435) |
| 9 | Pola musiman kuat | Kuartal 4 tertinggi tiap tahun; sales rata-rata tertinggi November, terendah Februari |
| 10 | Margin Q4 2017 turun | Sales +18,6% tetapi profit −28%; penjualan diskon >20% naik 62% dan menjelaskan ≈ 89% penurunan profit |
| 11 | Segmen dan mode pengiriman bukan penyebab | Selisih margin kecil antar kelompok |

## 7. Rekomendasi

1. **Batasi diskon di atas 20%.** Terapkan persetujuan berjenjang dan batas maksimum untuk produk bernilai tinggi.
2. **Tinjau Tables, Bookcases, dan Machines** (harga, diskon, biaya). Untuk **Supplies**, periksa struktur biaya karena merugi tanpa diskon dalam.
3. **Audit sepuluh state yang merugi** dan kebijakan diskon di region Central.
4. **Nilai pelanggan berdasarkan profit, bukan hanya sales.**
5. **Lindungi profitabilitas kuartal 4** dengan membatasi promo diskon dalam di bulan ramai.
6. **Lengkapi data** dengan biaya produk dan alasan diskon agar sebab-akibat dan simulasi kebijakan bisa dianalisis.

Ringkasan satu halaman ada di [`reports/executive_summary.md`](reports/executive_summary.md).

## 8. Cara Menjalankan

**Python**
```bash
pip install pandas matplotlib jupyter
jupyter notebook
```
Jalankan notebook di folder `notebooks/` berurutan (01 → 03) dengan *Restart Kernel → Run All*. Saat membaca data bersih, gunakan:
```python
pd.read_csv('data/cleaned/Sample-Superstore-Cleaned.csv',
            dtype={'postal_code': str},
            parse_dates=['order_date', 'ship_date'])
```
(CSV tidak menyimpan tipe data; tanpa parameter ini nol di depan kode pos hilang.)

**SQL (PostgreSQL 14 atau lebih baru)**, jalankan dari folder utama proyek:
```bash
psql -U postgres -c "CREATE DATABASE superstore"
psql -U postgres -d superstore -f sql/01_create_table.sql
psql -U postgres -d superstore -f sql/02_load_data.sql
psql -U postgres -d superstore -f sql/03_data_validation.sql
psql -U postgres -d superstore -f sql/04_business_questions.sql
```
Setiap query di `04_business_questions.sql` memuat hasil yang diharapkan di komentar.

## 9. Keterbatasan

- Dataset sampel/fiktif, bukan data bisnis nyata.
- Tidak ada data biaya produk atau alasan pemberian diskon, jadi temuan bersifat deskriptif (korelasi, bukan sebab-akibat).
- Angka dampak (misalnya kerugian akibat diskon) bukan prediksi hasil kebijakan: menghapus transaksi diskon tinggi juga menghilangkan volume penjualan.

## 10. Pengembangan Selanjutnya

- Dashboard interaktif (Power BI) untuk KPI, tren, produk, wilayah, dan diskon.
- Simulasi kebijakan batas diskon.
- Analisis tingkat produk dengan data biaya.

## Kontak

**Iqbal Alfaridzi Balman**, lulusan Teknik Informatika, Universitas Tarumanagara
LinkedIn: Iqbal Balman | Email: <balmanlaw@gmail.com>

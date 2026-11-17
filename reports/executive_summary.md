# Executive Summary: Sales Performance Analysis

**Periode data:** 2014-2017 | **Cakupan:** 9.993 baris transaksi, 5.009 pesanan, 793 pelanggan | **Dataset:** Superstore (sampel)

## Pertanyaan manajemen
Penjualan tumbuh, tetapi apakah profit ikut sebanding, dan di mana keuntungan bocor?

## Jawaban singkat
**Profit memang tumbuh lebih cepat daripada sales, tetapi margin tetap tipis (12,47%) dan bocor di titik-titik tertentu**, terutama pada transaksi dengan diskon dalam, kategori Furniture, dan sepuluh state yang merugi.

## Gambaran kinerja

| Indikator | Nilai |
|---|---|
| Total sales | 2.296.919 |
| Total profit | 286.409 |
| Profit margin | 12,47% |
| Pertumbuhan 2014 → 2017 | Sales +51,5%, profit +88,6%, pesanan +74,1% |
| Rata-rata nilai per pesanan | 499 (2014) → 435 (2017), turun 13% |
| Margin per tahun | 10,2% → 13,1% → 13,4% → 12,7% |

Pertumbuhan sales berasal dari **bertambahnya jumlah pesanan**, bukan dari nilai tiap pesanan yang makin besar. Penjualan paling ramai di kuartal 4 (puncak November), dan polanya berulang tiap tahun.

## Temuan utama

1. **Diskon di atas 20% merugikan.** Transaksi dengan diskon >20% hanya 13,9% dari baris data (15,8% sales), tetapi menghasilkan profit **−135.364**, setara hampir setengah dari profit bersih. Transaksi dengan diskon ≤20% bermargin 21,8%. Titik impas diskon berada di sekitar 20%.
2. **Furniture hampir tidak menghasilkan profit** (margin 2,49% vs ±17% di Office Supplies dan Technology). Tables (−17.725) dan Bookcases (−3.473) merugi; keduanya paling sering didiskon dalam. Supplies juga merugi meski diskonnya kecil, sehingga penyebabnya kemungkinan harga atau biaya.
3. **Sepuluh dari 49 state merugi** dengan total −98.235 pada ±31% dari sales. Rata-rata diskon di state tersebut 33,6%, jauh di atas state lain (4,2%). Terbesar: Texas (−25.729), Ohio (−16.959), Pennsylvania (−15.560), dan Illinois (−12.608). Region Central bermargin terendah (7,92%).
4. **299 dari 1.850 produk merugi** (total ≈ −77.068), banyak di antaranya produk bernilai tinggi dengan diskon 40-80%.
5. **Penurunan margin Q4 2017** (16,15% → 9,80%): sales naik 18,6% tetapi profit turun 28%. Penjualan dengan diskon >20% naik 62% dan menjelaskan sekitar 89% dari penurunan profit.
6. **Pelanggan:** bisnis tidak bergantung pada segelintir pelanggan (10 teratas hanya 6,7% sales), tetapi **155 pelanggan (19,5%) merugi** dengan total ≈ −71.212. Pelanggan dengan sales terbesar justru berprofit negatif.
7. **Bukan penyebab utama:** segmen pelanggan dan mode pengiriman (selisih margin kecil).

## Rekomendasi

| Prioritas | Tindakan | Alasan |
|---|---|---|
| 1 | Batasi diskon di atas 20%: persetujuan berjenjang dan batas maksimum untuk produk bernilai tinggi | Sumber kebocoran profit terbesar |
| 2 | Tinjau harga, diskon, dan biaya Tables, Bookcases, dan Machines; periksa struktur biaya Supplies | Penyebab rendahnya margin Furniture |
| 3 | Audit sepuluh state merugi (Texas, Ohio, Pennsylvania, Illinois) dan kebijakan diskon region Central | Kerugian terkonsentrasi secara geografis |
| 4 | Nilai pelanggan berdasarkan profit, bukan hanya sales; tinjau 155 pelanggan yang merugi | Sales besar belum tentu menguntungkan |
| 5 | Batasi promo diskon dalam di bulan ramai (September, November, Desember) dan pantau margin bulanan | Menjaga profit kuartal 4 |
| 6 | Lengkapi data biaya produk dan alasan pemberian diskon | Memungkinkan analisis sebab-akibat dan simulasi kebijakan |

## Keterbatasan
Dataset adalah sampel/fiktif dan tidak memuat biaya produk, sehingga temuan bersifat deskriptif. Angka kerugian akibat diskon bukan prediksi hasil kebijakan, karena membatasi diskon juga dapat mengurangi volume penjualan.

*Detail metode dan kode: lihat `notebooks/` dan `sql/` di repositori.*

# Fitur Export Laporan Keuangan - SpendSense

## 📋 Deskripsi Fitur

Fitur **Export Laporan Keuangan** memungkinkan pengguna untuk mengekspor riwayat transaksi mereka dalam format PDF atau Excel dengan berbagai pilihan periode dan opsi distribusi.

## ✨ Fitur-Fitur Utama

### 1. **Format Export**
- **PDF**: Laporan profesional dengan layout yang rapi, ringkasan visual, dan grafik kategori
- **Excel**: File spreadsheet dengan multiple sheet untuk summary dan detail transaksi

### 2. **Pilihan Periode**
- 📅 **Bulan Ini**: Laporan transaksi bulan saat ini
- 📅 **Bulan Lalu**: Laporan bulan sebelumnya
- 📅 **Tahun Ini**: Laporan kumulatif tahun berjalan
- 📅 **Tahun Lalu**: Laporan tahun sebelumnya
- 📅 **Semua Data**: Laporan dari sejak awal menggunakan app
- 📅 **Kustom**: Pilih rentang tanggal spesifik

### 3. **Metode Export**
- ⬇️ **Download**: Simpan file langsung ke device
- 📤 **Share**: Bagikan file via email atau aplikasi lain

### 4. **Isi Laporan**
#### Halaman 1: Ringkasan (Summary)
- ✓ Informasi pengguna (nama, email, periode)
- ✓ Box statistik: Total Pemasukan, Pengeluaran, Saldo Bersih
- ✓ Tabel ringkasan: Jumlah transaksi, rata-rata, dll
- ✓ Pengeluaran berdasarkan kategori (tabel + persentase)
- ✓ Pemasukan berdasarkan kategori (tabel + persentase)

#### Halaman 2: Detail Transaksi (jika ada)
- ✓ Daftar semua transaksi dengan detail lengkap
- ✓ Kolom: Tanggal, Deskripsi, Kategori, Tipe, Jumlah

#### Sheet Excel:
- **Summary**: Ringkasan laporan
- **Transaksi**: Daftar detail semua transaksi
- **Kategori**: Breakdown pengeluaran dan pemasukan per kategori

## 🚀 Cara Menggunakan

### Akses Fitur

1. Buka aplikasi SpendSense
2. Buka **Settings** (tab profil)
3. Cari tombol **"Export Laporan Keuangan"**
4. Klik untuk membuka halaman export

### Langkah-Langkah Export

#### Step 1: Pilih Format
```
[PDF] atau [Excel]
```
- Pilih salah satu format sesuai kebutuhan
- PDF cocok untuk print/dokumentasi
- Excel cocok untuk analisis lebih lanjut

#### Step 2: Pilih Periode
```
Bulan Ini / Bulan Lalu / Tahun Ini / Tahun Lalu / Semua Data / Kustom
```

Jika memilih **Kustom**:
- Tentukan "Dari Tanggal" 
- Tentukan "Sampai Tanggal"

#### Step 3: Preview (Opsional)
```
[Pratinjau]
```
- Klik tombol Pratinjau untuk melihat summary data
- Data yang akan di-export ditampilkan dalam box preview
- Lihat: Total pemasukan, pengeluaran, saldo, jumlah transaksi

#### Step 4: Pilih Metode Export
```
[Download] atau [Share]
```

**Download**: 
- File tersimpan di device
- Gunakan file manager untuk akses

**Share**:
- Buka aplikasi sharing (email, drive, dll)
- Kirim langsung dari app

#### Step 5: Proses Export
```
[Download PDF/EXCEL] atau [Share PDF/EXCEL]
```
- Tunggu proses selesai (progress bar menunjukkan)
- Notification akan muncul saat selesai
- File siap untuk digunakan

## 📊 Contoh Laporan

### PDF Sample
```
═══════════════════════════════════════════════════════════════
  LAPORAN KEUANGAN SPENDSENSE
  Financial Report Generated
═══════════════════════════════════════════════════════════════

Pengguna: John Doe
Email: john@example.com
Periode Laporan: 01-06-2024 - 30-06-2024

┌─────────────────────────────────────────────────────────────┐
│  Rp 5.000.000  │  Rp 3.500.000  │  Rp 1.500.000  │
│  Pemasukan     │  Pengeluaran   │  Saldo Bersih  │
└─────────────────────────────────────────────────────────────┘

RINGKASAN LAPORAN
│ Jumlah Transaksi     │ 45                │
│ Total Pemasukan      │ Rp 5.000.000      │
│ Total Pengeluaran    │ Rp 3.500.000      │
│ Saldo Bersih         │ Rp 1.500.000      │

PENGELUARAN BERDASARKAN KATEGORI
│ Makanan      │ Rp 1.200.000  │ 34.3%  │
│ Transport    │ Rp 800.000    │ 22.9%  │
│ Hiburan      │ Rp 600.000    │ 17.1%  │
│ Lainnya      │ Rp 900.000    │ 25.7%  │

[Halaman 2: DAFTAR TRANSAKSI DETAIL]
...
```

## 📱 Tips & Trik

### ✅ Best Practices

1. **Untuk Analisis**
   - Export ke Excel untuk analisis lebih detail
   - Gunakan Kustom date range untuk fokus periode tertentu

2. **Untuk Laporan Formal**
   - Export ke PDF untuk presentasi/dokumentasi
   - Preview dulu sebelum export

3. **Untuk Backup**
   - Export "Semua Data" secara berkala
   - Simpan di cloud storage (Google Drive, OneDrive)

4. **Sharing dengan Orang Lain**
   - Gunakan Share untuk langsung kirim via email
   - Atau download dulu, share manual

### ⚡ Shortcuts

- Akses export dari Settings → Export Laporan Keuangan
- Bisa juga tambah shortcut ke Home Page (custom development)

## 🐛 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| File tidak tersimpan | Cek storage device cukup |
| Export lambat | Cek data banyak, tunggu proses selesai |
| Format PDF tidak rapi | Gunakan PDF viewer yang lebih baik |
| Excel tidak buka | Update aplikasi Excel/Office |
| Share tidak bekerja | Cek izin sharing app sudah aktif |

## 🔄 Update History

- **v1.0.0** (Hari ini)
  - ✨ Initial release
  - ✨ Support PDF & Excel
  - ✨ Multiple date range options
  - ✨ Category breakdown
  - ✨ Preview sebelum export

## 📞 Support

Jika ada pertanyaan atau bug:
1. Cek troubleshooting section di atas
2. Pastikan data transaksi tersinkronisasi dengan Supabase
3. Coba refresh atau restart app

---

**Happy exporting! 📊**

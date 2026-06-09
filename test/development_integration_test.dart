import 'package:flutter_test/flutter_test.dart';

// 1. STRUKTUR DATA SIMULASI (Representasi Model Aplikasi)
class Akun {
  final int id;
  final String nama;
  double saldo;
  Akun({required this.id, required this.nama, required this.saldo});
}

class Kategori {
  final int id;
  final String nama;
  final String tipe; // 'income' atau 'expense'
  Kategori({required this.id, required this.nama, required this.tipe});
}

class Transaksi {
  final int id;
  final int idAkun;
  final int? idAkunTujuan;
  final int? idKategori;
  final String tipe; // 'income', 'expense', 'transfer'
  final double jumlah;

  Transaksi({
    required this.id,
    required this.idAkun,
    this.idAkunTujuan,
    this.idKategori,
    required this.tipe,
    required this.jumlah,
  });
}

class Anggaran {
  final int id;
  final int idKategori;
  final double batasMaksimal;
  double totalTerpakai;

  Anggaran({
    required this.id,
    required this.idKategori,
    required this.batasMaksimal,
    this.totalTerpakai = 0.0,
  });
}

// 2. SISTEM INTI SIMULASI (Logika Bisnis Integrasi Fitur)
class SistemSpendSense {
  final Map<int, Akun> daftarAkun = {};
  final Map<int, Kategori> daftarKategori = {};
  final List<Transaksi> daftarTransaksi = [];
  final Map<int, Anggaran> daftarAnggaran = {};

  void tambahAkun(Akun akun) => daftarAkun[akun.id] = akun;
  void tambahKategori(Kategori kat) => daftarKategori[kat.id] = kat;
  void tambahAnggaran(Anggaran ang) => daftarAnggaran[ang.id] = ang;

  String eksekusiTransaksi(Transaksi t) {
    final akunSumber = daftarAkun[t.idAkun];
    if (akunSumber == null) return 'Error: Akun tidak ditemukan';

    if (t.tipe == 'income') {
      akunSumber.saldo += t.jumlah;
    } else if (t.tipe == 'expense') {
      if (akunSumber.saldo < t.jumlah) return 'Error: Saldo tidak cukup';
      akunSumber.saldo -= t.jumlah;

      // INTEGRASI: Update otomatis ke fitur Anggaran jika kategori cocok
      if (t.idKategori != null) {
        for (var anggaran in daftarAnggaran.values) {
          if (anggaran.idKategori == t.idKategori) {
            anggaran.totalTerpakai += t.jumlah;
          }
        }
      }
    } else if (t.tipe == 'transfer') {
      if (t.idAkunTujuan == null) return 'Error: Akun tujuan harus diisi';
      final akunTujuan = daftarAkun[t.idAkunTujuan];
      if (akunTujuan == null) return 'Error: Akun tujuan tidak ditemukan';
      if (akunSumber.saldo < t.jumlah) return 'Error: Saldo tidak cukup';

      akunSumber.saldo -= t.jumlah;
      akunTujuan.saldo += t.jumlah;
    }

    daftarTransaksi.add(t);
    return 'Sukses';
  }
}

// 3. RANGKAIAN PENGUJIAN INTEGRASI ALUR
void main() {
  group('Development Integration Testing - Core Financial Flows', () {
    late SistemSpendSense sistem;

    setUp(() {
      sistem = SistemSpendSense();

      // Memasukkan data master awal (Seeding Data)
      sistem.tambahAkun(Akun(id: 1, nama: 'Bank Mandiri', saldo: 1000000));
      sistem.tambahAkun(Akun(id: 2, nama: 'E-Wallet GoPay', saldo: 200000));

      sistem.tambahKategori(Kategori(id: 10, nama: 'Gaji Proyek', tipe: 'income'));
      sistem.tambahKategori(Kategori(id: 20, nama: 'Makan Malam', tipe: 'expense'));
    });

    test('POSITIF: Alur Utama Catat Pemasukan -> Set Budget -> Catat Pengeluaran Berdampak', () {
      // 1. User mencatat pemasukan gaji Rp 2.000.000 ke Bank Mandiri
      final transaksiGaji = Transaksi(id: 101, idAkun: 1, idKategori: 10, tipe: 'income', jumlah: 2000000);
      final statusGaji = sistem.eksekusiTransaksi(transaksiGaji);
      
      expect(statusGaji, equals('Sukses'));
      expect(sistem.daftarAkun[1]!.saldo, equals(3000000)); // Saldo bertambah otomatis

      // 2. User membuat alokasi anggaran untuk kategori Makan Malam sebesar Rp 500.000
      final budgetMakan = Anggaran(id: 50, idKategori: 20, batasMaksimal: 500000);
      sistem.tambahAnggaran(budgetMakan);

      // 3. User mencatat pengeluaran makan malam menggunakan Bank Mandiri sebesar Rp 150.000
      final transaksiMakan = Transaksi(id: 102, idAkun: 1, idKategori: 20, tipe: 'expense', jumlah: 150000);
      final statusMakan = sistem.eksekusiTransaksi(transaksiMakan);

      expect(statusMakan, equals('Sukses'));
      // VALIDASI INTEGRASI: Saldo bank berkurang DAN kuota budget makan otomatis terpakai
      expect(sistem.daftarAkun[1]!.saldo, equals(2850000));
      expect(sistem.daftarAnggaran[50]!.totalTerpakai, equals(150000));
    });

    test('POSITIF: Alur Transfer Dana Antar Akun', () {
      // User transfer dari Bank Mandiri ke GoPay sebesar Rp 300.000
      final transaksiTransfer = Transaksi(id: 103, idAkun: 1, idAkunTujuan: 2, tipe: 'transfer', jumlah: 300000);
      final statusTransfer = sistem.eksekusiTransaksi(transaksiTransfer);

      expect(statusTransfer, equals('Sukses'));
      // VALIDASI INTEGRASI: Akun pengirim berkurang DAN akun penerima bertambah
      expect(sistem.daftarAkun[1]!.saldo, equals(700000));
      expect(sistem.daftarAkun[2]!.saldo, equals(500000));
    });

    test('NEGATIF: Proteksi Alur Jika Saldo Akun Tidak Cukup Untuk Pengeluaran', () {
      final budgetMakan = Anggaran(id: 51, idKategori: 20, batasMaksimal: 500000);
      sistem.tambahAnggaran(budgetMakan);

      // User memaksa mencatat pengeluaran Rp 1.500.000 (Padahal saldo Bank Mandiri hanya Rp 1.000.000)
      final transaksiGagal = Transaksi(id: 104, idAkun: 1, idKategori: 20, tipe: 'expense', jumlah: 1500000);
      final statusGagal = sistem.eksekusiTransaksi(transaksiGagal);

      expect(statusGagal, equals('Error: Saldo tidak cukup'));
      // VALIDASI PROTEKSI: Saldo tidak boleh berubah DAN budget tidak boleh ikut terpotong
      expect(sistem.daftarAkun[1]!.saldo, equals(1000000));
      expect(sistem.daftarAnggaran[51]!.totalTerpakai, equals(0.0));
    });
  });
}
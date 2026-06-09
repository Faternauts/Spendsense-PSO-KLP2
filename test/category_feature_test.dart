import 'package:flutter_test/flutter_test.dart';

class ManajerKategori {
  final List<String> kategoriEksis = ['Food & Dining', 'Salary'];

  // Perbaikan: Menyatukan nama fungsi tanpa menggunakan spasi
  String tambahKategoriKustom({required String nama, required String tipe}) {
    if (nama.trim().isEmpty) return 'Error: Nama kategori tidak boleh kosong';
    if (tipe != 'income' && tipe != 'expense') return 'Error: Tipe kategori tidak valid';
    if (kategoriEksis.contains(nama.trim())) return 'Error: Nama kategori sudah digunakan';
    
    return 'Sukses';
  }
}

void main() {
  group('Feature Testing - Manajemen Kategori', () {
    late ManajerKategori manajer;

    setUp(() {
      manajer = ManajerKategori();
    });

    // --- TEST CASE POSITIF ---
    test('POSITIF: Harus berhasil menambahkan nama kategori baru unik', () {
      final hasil = manajer.tambahKategoriKustom(nama: 'Transportasi', tipe: 'expense');
      expect(hasil, equals('Sukses'));
    });

    // --- TEST CASE NEGATIF ---
    test('NEGATIF: Harus menolak penambahan kategori jika nama sudah terdaftar', () {
      final hasil = manajer.tambahKategoriKustom(nama: 'Salary', tipe: 'income');
      expect(hasil, equals('Error: Nama kategori sudah digunakan'));
    });

    test('NEGATIF: Harus menolak kategori jika tipe bukan berisi income atau expense', () {
      final hasil = manajer.tambahKategoriKustom(nama: 'Hiburan', tipe: 'transfer');
      expect(hasil, equals('Error: Tipe kategori tidak valid'));
    });
  });
}
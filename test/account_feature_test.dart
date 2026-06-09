import 'package:flutter_test/flutter_test.dart';

class ManajerAkun {
  final List<Map<String, dynamic>> daftarAkun = [];

  String buatAkun({required String nama, required String tipe, required double saldoAwal}) {
    if (nama.trim().isEmpty) return 'Error: Nama akun tidak boleh kosong';
    if (saldoAwal < 0) return 'Error: Saldo awal tidak boleh negatif';
    
    final tipeValid = ['cash', 'bank', 'card', 'savings'];
    if (!tipeValid.contains(tipe.toLowerCase())) return 'Error: Tipe akun tidak valid';

    daftarAkun.add({'nama': nama, 'tipe': tipe, 'saldo': saldoAwal});
    return 'Sukses';
  }
}

void main() {
  group('Feature Testing - Manajemen Akun', () {
    late ManajerAkun manajer;

    setUp(() {
      manajer = ManajerAkun();
    });

    // --- TEST CASE POSITIF ---
    test('POSITIF: Harus berhasil membuat akun baru dengan parameter valid', () {
      final hasil = manajer.buatAkun(nama: 'Bank Mandiri', tipe: 'bank', saldoAwal: 100000);
      expect(hasil, equals('Sukses'));
      expect(manajer.daftarAkun.length, equals(1));
    });

    // --- TEST CASE NEGATIF ---
    test('NEGATIF: Harus menolak pembuatan akun jika nama hanya berisi spasi kosong', () {
      final hasil = manajer.buatAkun(nama: '   ', tipe: 'cash', saldoAwal: 50000);
      expect(hasil, equals('Error: Nama akun tidak boleh kosong'));
      expect(manajer.daftarAkun.isEmpty, isTrue);
    });

    test('NEGATIF: Harus menolak pembuatan akun dengan nilai saldo awal negatif', () {
      final hasil = manajer.buatAkun(nama: 'Dompet Utama', tipe: 'cash', saldoAwal: -1000);
      expect(hasil, equals('Error: Saldo awal tidak boleh negatif'));
    });

    test('NEGATIF: Harus menolak pembuatan akun jika tipe produk tidak terdaftar', () {
      final hasil = manajer.buatAkun(nama: 'Saham', tipe: 'investment', saldoAwal: 500000);
      expect(hasil, equals('Error: Tipe akun tidak valid'));
    });
  });
}
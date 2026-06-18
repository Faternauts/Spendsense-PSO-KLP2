import 'package:flutter_test/flutter_test.dart';

class LayananTransaksi {
  double saldoAkun;
  LayananTransaksi({required this.saldoAkun});

  String catatTransaksi({required String tipe, required double jumlah}) {
    if (jumlah <= 0) return 'Error: Jumlah harus lebih dari nol';
    if (tipe != 'income' && tipe != 'expense') return 'Error: Tipe tidak valid';
    
    if (tipe == 'income') {
      saldoAkun += jumlah;
      return 'Sukses';
    } else {
      if (saldoAkun < jumlah) return 'Error: Saldo tidak mencukupi';
      saldoAkun -= jumlah;
      return 'Sukses';
    }
  }

  String transferDana({required LayananTransaksi tujuan, required double jumlah}) {
    if (jumlah <= 0) return 'Error: Jumlah transfer harus lebih dari nol';
    if (saldoAkun < jumlah) return 'Error: Saldo pengirim tidak cukup';
    
    saldoAkun -= jumlah;
    tujuan.saldoAkun += jumlah;
    return 'Sukses';
  }
}

void main() {
  group('Feature Testing - Manajemen Transaksi', () {
    late LayananTransaksi dompet;
    late LayananTransaksi bank;

    setUp(() {
      dompet = LayananTransaksi(saldoAkun: 500000);
      bank = LayananTransaksi(saldoAkun: 1000000);
    });

    // --- TEST CASE POSITIF ---
    test('POSITIF: Harus berhasil mencatat pemasukan valid', () {
      final hasil = dompet.catatTransaksi(tipe: 'income', jumlah: 200000);
      expect(hasil, equals('Sukses'));
      expect(dompet.saldoAkun, equals(700000));
    });

    test('POSITIF: Harus berhasil mencatat pengeluaran valid', () {
      final hasil = dompet.catatTransaksi(tipe: 'expense', jumlah: 100000);
      expect(hasil, equals('Sukses'));
      expect(dompet.saldoAkun, equals(400000));
    });

    test('POSITIF: Harus berhasil melakukan transfer antar akun valid', () {
      final hasil = bank.transferDana(tujuan: dompet, jumlah: 300000);
      expect(hasil, equals('Sukses'));
      expect(bank.saldoAkun, equals(700000));
      expect(dompet.saldoAkun, equals(800000));
    });

    // --- TEST CASE NEGATIF ---
    test('NEGATIF: Harus menolak transaksi dengan nominal minus atau nol', () {
      final hasil = dompet.catatTransaksi(tipe: 'income', jumlah: -50000);
      expect(hasil, contains('Error'));
      expect(dompet.saldoAkun, equals(500000));
    });

    test('NEGATIF: Harus menolak pengeluaran jika saldo tidak mencukupi', () {
      final hasil = dompet.catatTransaksi(tipe: 'expense', jumlah: 600000);
      expect(hasil, equals('Error: Saldo tidak mencukupi'));
      expect(dompet.saldoAkun, equals(500000));
    });

    test('NEGATIF: Harus menolak transfer jika saldo pengirim tidak mencukupi', () {
      final hasil = dompet.transferDana(tujuan: bank, jumlah: 600000);
      expect(hasil, equals('Error: Saldo pengirim tidak cukup'));
      expect(dompet.saldoAkun, equals(500000));
      expect(bank.saldoAkun, equals(1000000));
    });
  });
}
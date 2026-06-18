import 'package:flutter_test/flutter_test.dart';

class ManajerAnggaran {
  String validasiBudget({required double nominal, required DateTime mulai, required DateTime selesai}) {
    if (nominal <= 0) return 'Error: Alokasi dana anggaran harus lebih dari nol';
    if (selesai.isBefore(mulai)) return 'Error: Tanggal selesai tidak boleh mendahului tanggal mulai';
    return 'Sukses';
  }
}

void main() {
  group('Feature Testing - Manajemen Anggaran (Budget)', () {
    late ManajerAnggaran manajer;

    setUp(() {
      manajer = ManajerAnggaran();
    });

    // --- TEST CASE POSITIF ---
    test('POSITIF: Harus meloloskan alokasi anggaran dengan parameter rentang waktu valid', () {
      final mulai = DateTime(2026, 6, 1);
      final selesai = DateTime(2026, 6, 30);
      final hasil = manajer.validasiBudget(nominal: 500000, mulai: mulai, selesai: selesai);
      expect(hasil, equals('Sukses'));
    });

    // --- TEST CASE NEGATIF ---
    test('NEGATIF: Harus menolak anggaran jika nominal bernilai nol atau minus', () {
      final mulai = DateTime(2026, 6, 1);
      final selesai = DateTime(2026, 6, 30);
      final hasil = manajer.validasiBudget(nominal: 0, mulai: mulai, selesai: selesai);
      expect(hasil, equals('Error: Alokasi dana anggaran harus lebih dari nol'));
    });

    test('NEGATIF: Harus menolak anggaran jika rentang batas tanggal terbalik', () {
      final mulai = DateTime(2026, 6, 30);
      final selesai = DateTime(2026, 6, 1);
      final hasil = manajer.validasiBudget(nominal: 200000, mulai: mulai, selesai: selesai);
      expect(hasil, equals('Error: Tanggal selesai tidak boleh mendahului tanggal mulai'));
    });
  });
}
import 'package:flutter_test/flutter_test.dart';

class LayananAutentikasi {
  String validasiRegistrasi({required String username, required String email, required String password}) {
    if (username.trim().isEmpty) return 'Error: Username wajib diisi';
    if (!email.contains('@') || !email.contains('.')) return 'Error: Format email salah';
    if (password.length < 6) return 'Error: Password minimal harus 6 karakter';
    return 'Sukses';
  }
}

void main() {
  group('Feature Testing - Autentikasi Pengguna', () {
    late LayananAutentikasi auth;

    setUp(() {
      auth = LayananAutentikasi();
    });

    // --- TEST CASE POSITIF ---
    test('POSITIF: Harus meloloskan proses registrasi jika seluruh format data benar', () {
      final hasil = auth.validasiRegistrasi(
        username: 'arya_wira',
        email: 'arya@its.ac.id',
        password: 'password123',
      );
      expect(hasil, equals('Sukses'));
    });

    // --- TEST CASE NEGATIF ---
    test('NEGATIF: Harus menggagalkan registrasi jika struktur penulisan email tidak valid', () {
      final hasil = auth.validasiRegistrasi(
        username: 'arya_wira',
        email: 'aryawiragunaemailcom',
        password: 'password123',
      );
      expect(hasil, equals('Error: Format email salah'));
    });

    test('NEGATIF: Harus menggagalkan registrasi jika panjang karakter password terlalu pendek', () {
      final hasil = auth.validasiRegistrasi(
        username: 'arya_wira',
        email: 'arya@its.ac.id',
        password: '123',
      );
      expect(hasil, equals('Error: Password minimal harus 6 karakter'));
    });
  });
}
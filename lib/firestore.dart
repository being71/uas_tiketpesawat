import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fungsi login pengguna menggunakan email dan password
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login gagal, coba lagi.');
    }
  }

  // Fungsi untuk mengecek apakah data pengguna ada di Firestore
  Future<bool> isUserExists(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      throw Exception("Gagal memeriksa data pengguna: $e");
    }
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception('Pengguna tidak ditemukan di Firestore.');
      }
    } catch (e) {
      throw Exception("Gagal mengambil data pengguna: $e");
    }
  }

  // Fungsi untuk membuat data pengguna baru di Firestore
  Future<void> createUser({
    required String uid,
    required String email,
    required String nama,
    required String noTelp,
    required String status,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set({
        'email': email,
        'nama': nama,
        'noTelp': noTelp,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(), // Tambahkan waktu pembuatan
      });
    } catch (e) {
      throw Exception("Gagal menyimpan data pengguna: $e");
    }
  }
}

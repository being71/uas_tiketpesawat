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
}

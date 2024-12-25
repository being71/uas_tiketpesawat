// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';
import 'login.dart';

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  DaftarPageState createState() => DaftarPageState();
}

class DaftarPageState extends State<DaftarPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();

  String _errorMessage = '';

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String nama = _namaController.text.trim();
    String noTelp = _noTelpController.text.trim();

    if (email.isEmpty || password.isEmpty || nama.isEmpty || noTelp.isEmpty) {
      setState(() {
        _errorMessage = 'Semua kolom wajib diisi.';
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // Simpan data pengguna ke Firestore
        await FirestoreService().createUser(
          uid: user.uid,
          email: email,
          nama: nama,
          noTelp: noTelp,
          status: 'user', // Status tetap 'user'
        );

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(42.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            const Text(
              'Daftar Akun',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                hintText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noTelpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'No Telepon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
              ),
              child:
                  const Text('Daftar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

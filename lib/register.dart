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
  String _successMessage = '';

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String nama = _namaController.text.trim();
    String noTelp = _noTelpController.text.trim();

    // Validasi formulir kosong
    if (email.isEmpty || password.isEmpty || nama.isEmpty || noTelp.isEmpty) {
      setState(() {
        _errorMessage = 'Semua kolom wajib diisi.';
        _successMessage = '';
      });
      return;
    }

    // Validasi format email
    if (!RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(email)) {
      setState(() {
        _errorMessage = 'Format email salah.';
        _successMessage = '';
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

        setState(() {
          _errorMessage = '';
          _successMessage = 'Akun berhasil terdaftar.';
        });

        // Tunda untuk menampilkan pesan sukses
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          }
        });
      }
    } catch (e) {
      // Menangani jika email sudah terdaftar
      if (e.toString().contains('email-already-in-use')) {
        setState(() {
          _errorMessage = 'Email sudah terdaftar.';
          _successMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
          _successMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(42.0),
        child: SingleChildScrollView(
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
              const SizedBox(height: 8),
              if (_errorMessage.isNotEmpty) ...[
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (_successMessage.isNotEmpty) ...[
                Text(
                  _successMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                ),
                child: const Text(
                  'Daftar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

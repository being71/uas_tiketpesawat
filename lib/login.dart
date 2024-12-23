// ignore_for_file: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firestore.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong.';
      });
      return;
    }

    try {
      // Gunakan FirestoreService untuk login
      User? user = await FirestoreService().loginUser(email, password);

      if (user != null) {
        bool userExists = await FirestoreService().isUserExists(user.uid);

        if (userExists) {
          // Ambil data user dari Firestore
          var userData = await FirestoreService().getUserData(user.uid);
          String status = userData['status']; // Field status di Firestore

          if (status == 'user') {
            // Navigasi ke HomeScreen
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomePage(
                          userId: 'user.uid',
                        )),
                (Route<dynamic> route) => false,
              );
            }
          } else if (status == 'admin') {
            // Navigasi ke HomeAdminScreen
            if (mounted) {
              /*Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdminPage()),
              (Route<dynamic> route) => false,
            );*/
            }
          } else {
            setState(() {
              _errorMessage = 'Status pengguna tidak valid.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Pengguna tidak ditemukan di Firestore.';
          });
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
              'WELCOME to',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ticketloka',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade100, // Masuk button color
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(color: Colors.black), // Teks hitam
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DaftarPage(),
                      ),
                    ); */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange.shade100, // Daftar button color
                  ),
                  child: const Text('Daftar',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

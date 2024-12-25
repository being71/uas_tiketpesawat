import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen_user.dart'; // Pastikan mengganti ini sesuai lokasi file

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    validateAndFetchUserData();
  }

  // Fungsi untuk validasi autentikasi dan fetch data
  Future<void> validateAndFetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Jika user belum login, navigasi ke halaman login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      print('Authenticated User ID: ${user.uid}');
      fetchUserData(user.uid);
    } catch (e) {
      print('Error validating user: $e');
    }
  }

  // Fungsi untuk mengambil data user dari Firestore
  Future<void> fetchUserData(String userId) async {
    try {
      print('Fetching user data for userId: $userId');
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        print('Document ditemukan: ${userDoc.data()}');
        setState(() {
          userName = userDoc['nama'] ?? '';
          userEmail = userDoc['email'] ?? '';
          userPhone = userDoc['noTelp'] ?? '';
          isLoading = false;
        });
      } else {
        print('Document tidak ditemukan untuk userId: $userId');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userName.isEmpty && userEmail.isEmpty && userPhone.isEmpty
              ? Center(
                  child: Text(
                    'Data tidak ditemukan untuk userId.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nama:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userName,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Email:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nomor Telepon:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userPhone,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenUser(userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            // Navigasi ke halaman Pesanan (belum diimplementasikan)
          } else if (index == 2) {
            // Tetap di halaman Profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userId: widget.userId),
              ),
            );
          }
        },
      ),
    );
  }
}

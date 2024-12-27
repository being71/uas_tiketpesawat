import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen_user.dart';
import 'login.dart';
import 'orderedticket.dart';

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

  Future<void> validateAndFetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      fetchUserData(user.uid);
    } catch (e) {
      print('Error validating user: $e');
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['nama'] ?? '';
          userEmail = userDoc['email'] ?? '';
          userPhone = userDoc['noTelp'] ?? '';
          isLoading = false;
        });
      } else {
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
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userName.isEmpty && userEmail.isEmpty && userPhone.isEmpty
              ? const Center(
                  child: Text(
                    'Data tidak ditemukan.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Profil Info
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileRow(
                                icon: Icons.person,
                                label: 'Nama:',
                                value: userName,
                              ),
                              const SizedBox(height: 15),
                              ProfileRow(
                                icon: Icons.email,
                                label: 'Email:',
                                value: userEmail,
                              ),
                              const SizedBox(height: 15),
                              ProfileRow(
                                icon: Icons.phone,
                                label: 'Nomor Telepon:',
                                value: userPhone,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Tombol Logout
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 0, 115, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 28),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
      // Bottom Navigation Bar
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
            // Navigasi ke halaman Pesanan
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderedTicketPage(userId: widget.userId), // Gunakan userId
              ),
            );
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

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'firestore.dart';
import 'profile_page.dart';
//import 'booked_ticket_page.dart'; // Halaman untuk tiket yang dipesan

class HomeScreenUser extends StatelessWidget {
  final String userId;

  const HomeScreenUser({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    return await FirestoreService().getUserData(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Banner at the top
            Container(
              margin: const EdgeInsets.all(10.0),
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/topbanner.png'), // Ganti dengan path gambar lokal Anda
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Icon and button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and Text wrapped in their own container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/airplane.png', // Your image path
                          width: 150,
                          height: 70,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 30),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesan tiket kamu',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Sekarang!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Two small banners side by side
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 10, top: 10, right: 4, bottom: 10),
                    height: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/sidebanner.png'), // Gambar dari URL
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 4, top: 10, right: 10, bottom: 10),
                    height: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/sidebanner.png'), // Ganti dengan path gambar lokal Anda
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Single large banners
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/topbanner.png'), // Gambar dari URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/topbanner.png'), // Ganti dengan path gambar lokal Anda
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar
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
          // Navigasi berdasarkan ikon yang dipilih
          if (index == 0) {
            // Tetap di halaman Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenUser(userId: userId),
              ),
            );
          } else if (index == 1) {
            // Navigasi ke halaman Pesanan
            /* Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookedTicketPage(userId: userId),
              ),
            );*/
          } else if (index == 2) {
            // Navigasi ke halaman Profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userId: userId),
              ),
            );
          }
        },
      ),
    );
  }
}

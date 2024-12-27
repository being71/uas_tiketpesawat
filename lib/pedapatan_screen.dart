import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'home_screen_admin.dart';
import 'ticket_list_page.dart';
import 'user_list.dart';

class PendapatanScreen extends StatefulWidget {
  @override
  _PendapatanScreenState createState() => _PendapatanScreenState();
}

class _PendapatanScreenState extends State<PendapatanScreen> {
  int _currentIndex = 3; // Start with Pendapatan screen
  double totalPendapatan = 0;

  final List<Widget> _screens = [
    HomeScreenAdmin(),
    TicketListPage(),
    UserListPage(),
    PendapatanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pendapatan'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('booked_tickets').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          // Hitung total pendapatan
          totalPendapatan = 0;
          snapshot.data!.docs.forEach((doc) {
            var data = doc.data() as Map<String, dynamic>;
            totalPendapatan += data['totalPrice'] ?? 0;
          });

          return ListView.builder(
            itemCount: snapshot.data!.docs.length +
                1, // Menambah 1 untuk header total pendapatan
            itemBuilder: (context, index) {
              if (index == 0) {
                // Menampilkan total pendapatan di atas daftar
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Pendapatan: Rp ${totalPendapatan.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              var data =
                  snapshot.data!.docs[index - 1].data() as Map<String, dynamic>;
              var bookingDate = (data['timestamp'] as Timestamp).toDate();
              var totalPrice = data['totalPrice'];
              var paymentMethod = data['paymentMethod'];
              var userId = data['userId'];
              var ticketId = data['ticketId'];
              var passengers = data['passengers'] as List<dynamic>? ?? [];

              // Format tanggal
              String formattedDate =
                  DateFormat('MMMM dd, yyyy').format(bookingDate);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Pemesanan: $formattedDate',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Harga: Rp $totalPrice',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Metode Pembayaran: $paymentMethod',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'User ID: $userId',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ID Tiket: $ticketId',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Penumpang:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ...passengers.map((passenger) {
                        var passengerData =
                            passenger as Map<String, dynamic>? ?? {};
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama: ${passengerData['firstName']} ${passengerData['lastName']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Update the screen based on the selected index
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => _screens[index],
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number, color: Colors.black),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, color: Colors.black),
            label: 'Pendapatan',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}

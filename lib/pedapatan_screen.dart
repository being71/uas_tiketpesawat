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
        title: const Text(
          'Pendapatan',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 73, 146, 255),
        centerTitle: true,
        elevation: 4,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('booked_tickets').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Hitung total pendapatan
          totalPendapatan = 0;
          snapshot.data!.docs.forEach((doc) {
            var data = doc.data() as Map<String, dynamic>;
            totalPendapatan += data['totalPrice'] ?? 0;
          });

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pendapatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Total Pendapatan: Rp ${totalPendapatan.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Tiket Pemesanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.date_range,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Tanggal: $formattedDate',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.attach_money,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Total Harga: Rp $totalPrice',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.payment,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'Metode Pembayaran: $paymentMethod',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'User ID: $userId',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  'ID Tiket: $ticketId',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Penumpang:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                            ...passengers.map((passenger) {
                              var passengerData =
                                  passenger as Map<String, dynamic>? ?? {};
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_circle,
                                        color: Colors.blueAccent),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${passengerData['firstName']} ${passengerData['lastName']}',
                                      style: const TextStyle(fontSize: 14),
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
                ),
              ),
            ],
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Pendapatan',
          ),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

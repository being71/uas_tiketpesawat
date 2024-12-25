import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:uas_tiketpesawat/add_tiket_page.dart';
import 'package:uas_tiketpesawat/Ticket_Detail_Page.dart';
import 'package:uas_tiketpesawat/home_screen_admin.dart';
import 'package:uas_tiketpesawat/user_list.dart'; // If you have a UserListPage

class TicketListPage extends StatefulWidget {
  const TicketListPage({Key? key}) : super(key: key);

  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  int _currentIndex = 1; // Set initial index to 1 since we're on TicketListPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke halaman tambah tiket
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TicketPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('createdAt',
                descending: true) // Urutkan berdasarkan waktu pembuatan
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada tiket yang tersedia.'));
          }

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _buildTicketCard(context, ticket);
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

          // Navigation logic based on selected index
          switch (index) {
            case 0:
              // Navigate to Home screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeScreenAdmin()),
              );
              break;
            case 1:
              // Stay on TicketListPage
              break;
            case 2:
              // Navigate to User List Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListPage()),
              );
              break;
            case 3:
              // Navigate to Pendapatan Screen (not yet implemented)
              break;
          }
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

  Widget _buildTicketCard(BuildContext context, QueryDocumentSnapshot ticket) {
    // Get the date field
    dynamic dateField = ticket['date'];
    String formattedDate = '';

    // Check if the date is a Timestamp
    if (dateField is Timestamp) {
      // If it's a Timestamp, format it as a Date
      formattedDate = DateFormat('MMMM dd, yyyy').format(dateField.toDate());
    } else if (dateField is String) {
      // If it's a String, use it directly or format it if needed
      formattedDate =
          dateField; // Assuming the date is in the required format already
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi utama tiket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${ticket['origin']} → ${ticket['destination']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  "Rp ${ticket['price']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tanggal: $formattedDate", // Display the formatted date
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Durasi: ${ticket['flightDuration']} jam",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Keberangkatan: ${ticket['departureTime']}",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Mendarat: ${ticket['arrivalTime']}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            // Informasi tambahan tiket
            Text(
              "Tipe Penerbangan: ${ticket['flightType']}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Kelas: ${ticket['flightClass']}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Bagasi: ${ticket['baggageInfo']} kg",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman detail tiket
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailPage(ticketId: ticket.id),
                  ),
                );
              },
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

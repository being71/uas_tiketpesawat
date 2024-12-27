import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:uas_tiketpesawat/add_tiket_page.dart';
import 'package:uas_tiketpesawat/Ticket_Detail_Page.dart';
import 'package:uas_tiketpesawat/home_screen_admin.dart';
import 'package:uas_tiketpesawat/pedapatan_screen.dart';
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
            icon: const Icon(Icons.add, color: Colors.blue),
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
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada tiket yang tersedia.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
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

          switch (index) {
            case 0:
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PendapatanScreen()),
              );
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
    final data = ticket.data() as Map<String, dynamic>;
    String formattedDate = _formatDate(data['date']);
    bool isFull = data['status'] == 'full';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "${data['origin']} → ${data['destination']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              isFull
                  ? const Text(
                      "Sold Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    )
                  : Text(
                      "Rp ${data['price']}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
            ],
          ),
          const Divider(color: Colors.grey),
          Text(
            "Tanggal: $formattedDate",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Durasi: ${data['flightDuration']} jam",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Keberangkatan: ${data['departureTime']}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Mendarat: ${data['arrivalTime']}",
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(color: Colors.grey),
          Text(
            "Maskapai: ${data['airline']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white, // Warna teks tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailPage(ticketId: ticket.id),
                  ),
                );
              },
              child: const Text(
                'Lihat Detail',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('MMMM dd, yyyy').format(date.toDate());
    } else if (date is String) {
      return date;
    } else {
      return 'Invalid date';
    }
  }
}

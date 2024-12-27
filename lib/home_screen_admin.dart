import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_tiketpesawat/login.dart';
import 'package:uas_tiketpesawat/pedapatan_screen.dart';
import 'package:uas_tiketpesawat/ticket_list_page.dart';
import 'package:uas_tiketpesawat/user_list.dart';
import 'ticket_detail_page.dart';

class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({Key? key}) : super(key: key);

  @override
  _HomeScreenAdminState createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  int _currentIndex = 0;
  double totalPendapatan = 0;
  int totalTicketsSold = 0;

  // Function to get the number of users from Firestore
  Future<int> _getUserCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  // Function to calculate total revenue from bookings
  Future<void> _calculateRevenue() async {
    // Query the bookings collection
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('booked_tickets').get();

    double total = 0;
    int soldTickets = 0;

    // Loop through all the bookings to calculate the total revenue and total tickets sold
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Sum the totalPrice to get the total revenue
      total += data['totalPrice'] ?? 0;

      // Check the ticketId and count tickets if available
      if (data['ticketId'] != null) {
        soldTickets += 1; // Count the ticket as sold
      }
    }

    // Update the state to reflect the calculated values
    setState(() {
      totalPendapatan = total;
      totalTicketsSold = soldTickets;
    });
  }

  // Helper function to format the timestamp fields
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMMM dd, yyyy').format(timestamp.toDate());
    } else if (timestamp is String) {
      try {
        DateTime dateTime =
            DateTime.parse(timestamp); // Try parsing String to DateTime
        return DateFormat('MMMM dd, yyyy').format(dateTime);
      } catch (e) {
        return "Invalid date"; // Fallback if parsing fails
      }
    }
    return "Invalid date"; // Return a fallback if the type doesn't match
  }

  // Function to handle logout
  Future<void> _logout() async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Navigate to LoginPage and replace the current screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Ensure LoginPage is correctly imported
      );
    } catch (e) {
      print("Logout failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateRevenue(); // Call the function to calculate total revenue and tickets sold
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Call logout function when pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to left
          children: [
            // Dummy Card Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Card for "Jumlah User"
                FutureBuilder<int>(
                  future: _getUserCount(), // Fetch user count from Firestore
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text('Error fetching user count');
                    }
                    int userCount = snapshot.data ?? 0;
                    return Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.person, size: 40),
                            const SizedBox(height: 8),
                            const Text(
                              "Jumlah User",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$userCount", // Display the fetched user count
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Card for "Tiket Terjual"
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.confirmation_number, size: 40),
                        const SizedBox(height: 8),
                        const Text("Tiket Terjual",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          "$totalTicketsSold", // Display the number of tickets sold
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                // Card for "Pendapatan"
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.attach_money, size: 40),
                        const SizedBox(height: 8),
                        const Text("Pendapatan",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          "Rp ${totalPendapatan.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // Ticket List Section
            const Text(
              "List Tiket",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // StreamBuilder for fetching ticket data from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .orderBy('createdAt',
                        descending: true) // Sort by creation time
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada tiket yang tersedia.'));
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
            ),
          ],
        ),
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
              // Stay on Home screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeScreenAdmin()),
              );
              break;
            case 1:
              // Navigate to TicketListPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketListPage()),
              );
              break;
            case 2:
              // Navigate to User List Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserListPage()),
              );
              break;
            case 3:
              // Navigate to Pendapatan Screen
              // Navigate to User List Page
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to left
          children: [
            // Main ticket info
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
                    overflow: TextOverflow.ellipsis, // Truncate long text
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
                  "Tanggal: ${_formatTimestamp(ticket['date'])}", // Formatted date
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
            Text(
              "Maskapai: ${ticket['airline']}", // Menampilkan nama maskapai
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            // Additional ticket info
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
          ],
        ),
      ),
    );
  }
}

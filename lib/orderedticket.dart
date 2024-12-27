import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this import is here
import 'package:intl/intl.dart';
import 'firestore.dart';
import 'home_screen_user.dart';
import 'profile_page.dart';
import 'tiketpage.dart';

class OrderedTicketPage extends StatefulWidget {
  final String userId;

  const OrderedTicketPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OrderedTicketPageState createState() => _OrderedTicketPageState();
}

class _OrderedTicketPageState extends State<OrderedTicketPage> {
  late Future<List<Map<String, dynamic>>> bookedTickets;

  @override
  void initState() {
    super.initState();
    bookedTickets = FirestoreService().getBookedTickets(widget.userId);
  }

  // Fungsi untuk mengonversi Timestamp ke String
  String formatDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dateTime = date.toDate();
      return DateFormat('d MMMM yyyy').format(dateTime);
    }
    return date ?? 'Unknown Date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordered Tickets')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: bookedTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tickets found.'));
          }

          var tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticketData = tickets[index];
              var ticketId = ticketData['ticketId'];

              return FutureBuilder<Map<String, dynamic>>(
                future: FirestoreService().getTicketData(ticketId),
                builder: (context, ticketSnapshot) {
                  if (ticketSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (ticketSnapshot.hasError) {
                    return Center(child: Text('Error loading ticket details'));
                  }

                  var ticket = ticketSnapshot.data ?? {};

                  // Format tanggal menggunakan formatDate
                  String formattedDate = formatDate(ticket['date']);

                  // Mengonversi data lainnya
                  String flightDurationString =
                      '${ticket['flightDuration'] ?? 0}';
                  int flightDurationInt = ticket['flightDuration'] ?? 0;
                  String priceString = ticket['price']?.toString() ?? '0';

                  // Menentukan apakah tiket adalah pulang-pergi atau sekali jalan
                  if (ticket['flightType'] == 'Pulang Pergi') {
                    // If the flight type is 'Pulang Pergi', use the `FlightCardOrderedTwoWay` widget
                    return FlightCardOrderedTwoWay(
                      airline: ticket['airline'] ?? 'Unknown Airline',
                      date: formattedDate,
                      flightType: ticket['flightType'] ?? 'Unknown Flight Type',
                      departureTime: ticket['departureTime'] ?? 'Unknown Time',
                      arrivalTime: ticket['arrivalTime'] ?? 'Unknown Time',
                      flightDuration: flightDurationInt,
                      price: priceString,
                      flightClass: ticket['flightClass'] ?? 'Economy',
                      origin: ticket['origin'] ?? 'Unknown Origin',
                      destination:
                          ticket['destination'] ?? 'Unknown Destination',
                      ticket: ticket,
                    );
                  } else {
                    // If it's not a 'TwoWay' flight, use `FlightCardOrderedOneWay`
                    return FlightCardOrderedOneWay(
                      airline: ticket['airline'] ?? 'Unknown Airline',
                      date: formattedDate, // Use formatted date
                      flightType: ticket['flightType'] ?? 'Unknown Flight Type',
                      departureTime: ticket['departureTime'] ?? 'Unknown Time',
                      arrivalTime: ticket['arrivalTime'] ?? 'Unknown Time',
                      flightDuration: flightDurationInt,
                      price: priceString,
                      flightClass: ticket['flightClass'] ?? 'Economy',
                      origin: ticket['origin'] ?? 'Unknown Origin',
                      destination:
                          ticket['destination'] ?? 'Unknown Destination',
                      ticket: ticket,
                    );
                  }
                },
              );
            },
          );
        },
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenUser(userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            // Already on OrderedTicketPage
          } else if (index == 2) {
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

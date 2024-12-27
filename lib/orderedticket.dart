import 'package:flutter/material.dart';
import 'firestore.dart';
import 'tiketpage.dart';

class OrderedTicketPage extends StatelessWidget {
  final String userId;

  const OrderedTicketPage({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    return await FirestoreService().getUserData(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [],
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
      ),
    );
  }
}

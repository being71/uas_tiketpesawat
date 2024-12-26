import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const CheckoutPage({required this.ticket, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flight: ${ticket['airline']}'),
            Text('Departure: ${ticket['departureTime']}'),
            Text('Arrival: ${ticket['arrivalTime']}'),
            Text('Price: ${ticket['price']}'),
            ElevatedButton(
              onPressed: () {
                // Add checkout logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proceeding to payment')),
                );
              },
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

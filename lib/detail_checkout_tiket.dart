import 'package:flutter/material.dart';

class DetailCheckoutTicket extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final int ticketCount;

  const DetailCheckoutTicket({
    Key? key,
    required this.ticketData,
    required this.ticketCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Checkout Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detail Tiket: ${ticketData['origin']} → ${ticketData['destination']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Jumlah Tiket: $ticketCount"),
            const SizedBox(height: 16),
            for (int i = 0; i < ticketCount; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Penumpang ${i + 1}"),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Depan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Belakang',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Kewarganegaraan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/detail_checkout_payment');
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
    );
  }
}

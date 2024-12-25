import 'package:flutter/material.dart';

class DetailCheckoutPayment extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final List<Map<String, dynamic>> passengerData;

  const DetailCheckoutPayment({
    Key? key,
    required this.ticketData,
    required this.passengerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Checkout Payment')),
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
            const Text("Detail Penumpang:"),
            for (var passenger in passengerData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Nama: ${passenger['firstName']} ${passenger['lastName']}"),
                  Text("Tanggal Lahir: ${passenger['dob']}"),
                  Text("Kewarganegaraan: ${passenger['nationality']}"),
                  const Divider(),
                ],
              ),
            const SizedBox(height: 16),
            const Text("Metode Pembayaran:"),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(
                    value: 'Kartu Kredit', child: Text('Kartu Kredit')),
                DropdownMenuItem(
                    value: 'Transfer Bank', child: Text('Transfer Bank')),
                DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pembayaran Berhasil'),
                    content: const Text('Tiket telah dipesan!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/booked_ticket');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Bayar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

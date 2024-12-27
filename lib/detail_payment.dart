import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPaymentPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final List<Map<String, String>> passengers;

  const DetailPaymentPage({
    required this.ticket,
    required this.passengers,
    Key? key,
  }) : super(key: key);

  @override
  State<DetailPaymentPage> createState() => _DetailPaymentPageState();
}

class _DetailPaymentPageState extends State<DetailPaymentPage> {
  String selectedPaymentMethod = 'Credit Card';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double calculateTotalPrice() {
    return widget.passengers.length *
        double.parse(widget.ticket['price'].toString());
  }

  Future<void> _saveToFirebase() async {
    try {
      // Ambil ID tiket dari data yang dikirimkan
      final ticketId = widget.ticket['docId'];
      print('Ticket ID: $ticketId');

      if (ticketId == null || ticketId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket ID tidak ditemukan.')),
        );
        return;
      }

      // Referensi dokumen tiket
      DocumentReference ticketDoc =
          firestore.collection('tickets').doc(ticketId);

      // Ambil data tiket dari database
      DocumentSnapshot ticketSnapshot = await ticketDoc.get();

      if (!ticketSnapshot.exists) {
        print('Dokumen tiket tidak ditemukan untuk ID: $ticketId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dokumen tiket tidak ditemukan.')),
        );
        return;
      }

      // Ambil nilai seatCount
      int currentSeatCount = ticketSnapshot.get('seatCount');
      int seatsPurchased = widget.passengers.length;
      int updatedSeatCount = currentSeatCount - seatsPurchased;

      if (updatedSeatCount < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah kursi tidak mencukupi untuk pesanan ini.'),
          ),
        );
        return;
      }

      double totalPrice = calculateTotalPrice();

      // Simpan data pemesanan ke koleksi "booked_tickets"
      await firestore.collection('booked_tickets').add({
        'ticketId': ticketId,
        'passengers': widget.passengers,
        'paymentMethod': selectedPaymentMethod,
        'totalPrice': totalPrice,
        'status': 'Booked',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update seatCount dan status tiket
      Map<String, dynamic> ticketUpdateData = {'seatCount': updatedSeatCount};
      if (updatedSeatCount == 0) {
        ticketUpdateData['status'] = 'Full';
      }

      await ticketDoc.update(ticketUpdateData);

      // Tampilkan pesan sukses
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pembayaran Berhasil'),
            content: const Text('Tiket Anda telah berhasil dipesan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Tampilkan pesan kesalahan jika terjadi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Tiket
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Tiket Penerbangan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: Icon(Icons.airlines, color: Colors.blue),
                      title: const Text('Maskapai'),
                      subtitle: Text(widget.ticket['airline']),
                    ),
                    ListTile(
                      leading: Icon(Icons.flight_takeoff, color: Colors.blue),
                      title: const Text('Keberangkatan'),
                      subtitle: Text(widget.ticket['departureTime']),
                    ),
                    ListTile(
                      leading: Icon(Icons.flight_land, color: Colors.blue),
                      title: const Text('Kedatangan'),
                      subtitle: Text(widget.ticket['arrivalTime']),
                    ),
                    ListTile(
                      leading: Icon(Icons.timer, color: Colors.blue),
                      title: const Text('Durasi Penerbangan'),
                      subtitle:
                          Text('${widget.ticket['flightDuration']} menit'),
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on, color: Colors.blue),
                      title: const Text('Harga'),
                      subtitle: Text('Rp${widget.ticket['price']}'),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue),
                      title: const Text('Asal'),
                      subtitle: Text(widget.ticket['origin'] +
                          ' (' +
                          widget.ticket['originCode'] +
                          ')'),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.location_on_outlined, color: Colors.blue),
                      title: const Text('Tujuan'),
                      subtitle: Text(widget.ticket['destination'] +
                          ' (' +
                          widget.ticket['destinationCode'] +
                          ')'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detail Penumpang
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Penumpang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(thickness: 1),
                    ...widget.passengers.map((passenger) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${passenger['firstName']} ${passenger['lastName']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Tanggal Lahir: ${passenger['birthDate']}'),
                            Text(
                                'Kewarganegaraan: ${passenger['nationality']}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Detail Pembayaran
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: Icon(Icons.monetization_on, color: Colors.blue),
                      title: const Text('Total Harga'),
                      subtitle: Text('Rp${totalPrice.toInt()}'),
                    ),
                    ListTile(
                      leading: Icon(Icons.payment, color: Colors.blue),
                      title: const Text('Metode Pembayaran'),
                      subtitle: DropdownButton<String>(
                        value: selectedPaymentMethod,
                        items: const [
                          DropdownMenuItem(
                              value: 'Credit Card', child: Text('Credit Card')),
                          DropdownMenuItem(
                              value: 'Debit Card', child: Text('Debit Card')),
                          DropdownMenuItem(
                              value: 'E-Wallet', child: Text('E-Wallet')),
                          DropdownMenuItem(
                              value: 'Bank Transfer',
                              child: Text('Bank Transfer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Bayar
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _saveToFirebase,
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:uas_tiketpesawat/Edit_Ticket_Page.dart';

class TicketDetailPage extends StatelessWidget {
  final String ticketId;

  const TicketDetailPage({Key? key, required this.ticketId}) : super(key: key);

  Future<void> _deleteTicket(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket berhasil dihapus')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus tiket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tiket tidak ditemukan.'));
          }

          final ticket = snapshot.data!;

          // Format the date fields
          dynamic dateField = ticket['date'];
          String formattedDate = '';
          if (dateField is Timestamp) {
            formattedDate =
                DateFormat('MMMM dd, yyyy').format(dateField.toDate());
          } else if (dateField is String) {
            formattedDate =
                dateField; // Assuming the date is in a valid string format
          }

          // Format return date
          dynamic returnDateField = ticket[
              'returnDate']; // Assuming returnDate is available in the Firestore document
          String formattedReturnDate = '';
          if (returnDateField is Timestamp) {
            formattedReturnDate =
                DateFormat('MMMM dd, yyyy').format(returnDateField.toDate());
          } else if (returnDateField is String) {
            formattedReturnDate =
                returnDateField; // Assuming returnDate is in a valid string format
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informasi utama tiket
                Text(
                  "${ticket['origin']} → ${ticket['destination']}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Harga: Rp ${ticket['price']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Maskapai: ${ticket['airline']}", // Menampilkan nama maskapai
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tanggal Pergi: $formattedDate", // Display the formatted departure date
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tanggal Pulang: $formattedReturnDate", // Display the formatted return date
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Durasi: ${ticket['flightDuration']} jam",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Keberangkatan: ${ticket['departureTime']}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mendarat: ${ticket['arrivalTime']}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 20),
                // Informasi tambahan tiket
                Text(
                  "Tipe Penerbangan: ${ticket['flightType']}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Kelas: ${ticket['flightClass']}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Bagasi: ${ticket['baggageInfo']} kg",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Row for side-by-side Edit and Delete buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Aksi untuk mengedit tiket
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditTicketPage(ticketId: ticketId),
                          ),
                        );
                      },
                      child: const Text('Edit Tiket'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                                'Apakah Anda yakin ingin menghapus tiket ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          _deleteTicket(context);
                        }
                      },
                      child: const Text('Hapus Tiket'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

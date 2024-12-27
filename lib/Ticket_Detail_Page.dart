import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus tiket: $e')),
      );
    }
  }

  Future<void> _deletePassenger(
      BuildContext context, String ticketId, int passengerIndex) async {
    try {
      // Mengambil dokumen booked_tickets berdasarkan ticketId dan menghapus penumpang di index yang sesuai
      final bookedTicketsRef =
          FirebaseFirestore.instance.collection('booked_tickets');
      final snapshot =
          await bookedTicketsRef.where('ticketId', isEqualTo: ticketId).get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final List<dynamic> passengers = doc['passengers'];

        // Menghapus penumpang di index yang sesuai
        passengers.removeAt(passengerIndex);

        // Memperbarui data penumpang yang sudah dihapus
        await doc.reference.update({'passengers': passengers});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penumpang berhasil dihapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus penumpang: $e')),
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
          dynamic dateField = ticket['date'];
          String formattedDate = dateField is Timestamp
              ? DateFormat('MMMM dd, yyyy').format(dateField.toDate())
              : dateField.toString();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${ticket['origin']} (${ticket['originCode']}) → ${ticket['destination']} (${ticket['destinationCode']})",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Harga: Rp ${ticket['price']}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text("Maskapai: ${ticket['airline']}"),
                  Text("Kelas Penerbangan: ${ticket['flightClass']}"),
                  Text("Tipe Penerbangan: ${ticket['flightType']}"),
                  Text("Durasi Penerbangan: ${ticket['flightDuration']} jam"),
                  Text("Bagasi: ${ticket['baggageInfo']} kg"),
                  Text("Keberangkatan: ${ticket['departureTime']}"),
                  Text("Kedatangan: ${ticket['arrivalTime']}"),
                  Text("Tanggal: $formattedDate"),
                  Text("Status: ${ticket['status']}"),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus')),
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
                  const Divider(height: 20),
                  const Text(
                    "Daftar Penumpang:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('booked_tickets')
                        .where('ticketId', isEqualTo: ticketId)
                        .snapshots(),
                    builder: (context, passengerSnapshot) {
                      if (passengerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!passengerSnapshot.hasData ||
                          passengerSnapshot.data!.docs.isEmpty) {
                        return const Text(
                            "Belum ada penumpang yang terdaftar.");
                      }

                      final passengers = passengerSnapshot
                          .data!.docs.first['passengers'] as List<dynamic>;
                      // Mengakses data di luar passengers
                      final paymentMethod =
                          passengerSnapshot.data!.docs.first['paymentMethod'] ??
                              'Tidak tersedia';
                      final status =
                          passengerSnapshot.data!.docs.first['status'] ??
                              'Tidak tersedia';

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: passengers.length,
                        itemBuilder: (context, index) {
                          final passenger = passengers[index];

                          // Mengakses data dalam passengers
                          final firstName =
                              passenger['firstName'] ?? 'Tidak tersedia';
                          final lastName =
                              passenger['lastName'] ?? 'Tidak tersedia';
                          final birthDate =
                              passenger['birthDate'] ?? 'Tidak tersedia';
                          final nationality =
                              passenger['nationality'] ?? 'Tidak tersedia';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$firstName $lastName",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text("Tanggal Lahir: $birthDate"),
                                  Text("Kewarganegaraan: $nationality"),
                                  const SizedBox(height: 8),
                                  // Menampilkan data yang berada di luar passengers
                                  Text("Metode Pembayaran: $paymentMethod"),
                                  Text("Status: $status"),
                                  const SizedBox(height: 8),
                                  // Tombol Hapus Penumpang
                                  ElevatedButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Konfirmasi Hapus Penumpang'),
                                          content: const Text(
                                              'Apakah Anda yakin ingin menghapus penumpang ini?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Batal')),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Hapus')),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        _deletePassenger(
                                            context, ticketId, index);
                                      }
                                    },
                                    child: const Text('Hapus Penumpang'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .white, // Warna merah untuk tombol hapus
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

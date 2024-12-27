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
      final bookedTicketsRef =
          FirebaseFirestore.instance.collection('booked_tickets');
      final snapshot =
          await bookedTicketsRef.where('ticketId', isEqualTo: ticketId).get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final List<dynamic> passengers = doc['passengers'];

        passengers.removeAt(passengerIndex);

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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "${ticket['origin']} (${ticket['originCode']}) → ${ticket['destination']} (${ticket['destinationCode']})",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.monetization_on,
                      title: 'Harga',
                      value: "Rp ${ticket['price']}",
                      valueStyle: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    _buildListTile(
                      icon: Icons.airlines,
                      title: 'Maskapai',
                      value: ticket['airline'] ?? 'Tidak Diketahui',
                    ),
                    _buildListTile(
                      icon: Icons.airline_seat_recline_normal,
                      title: 'Kelas Penerbangan',
                      value: ticket['flightClass'] ?? 'Tidak Diketahui',
                    ),
                    _buildListTile(
                      icon: Icons.flight_takeoff,
                      title: 'Tipe Penerbangan',
                      value: ticket['flightType'] ?? 'Tidak Diketahui',
                    ),
                    _buildListTile(
                      icon: Icons.timer,
                      title: 'Durasi Penerbangan',
                      value: '${ticket['flightDuration']} jam',
                    ),
                    _buildListTile(
                      icon: Icons.luggage,
                      title: 'Bagasi',
                      value: '${ticket['baggageInfo']} kg',
                    ),
                    _buildListTile(
                      icon: Icons.access_time,
                      title: 'Keberangkatan',
                      value: ticket['departureTime'] ?? 'Tidak Diketahui',
                    ),
                    _buildListTile(
                      icon: Icons.access_time_filled,
                      title: 'Kedatangan',
                      value: ticket['arrivalTime'] ?? 'Tidak Diketahui',
                    ),
                    _buildListTile(
                      icon: Icons.calendar_today,
                      title: 'Tanggal',
                      value: formattedDate,
                    ),
                    _buildListTile(
                      icon: Icons.info,
                      title: 'Status',
                      value: ticket['status'] ?? 'Tidak Diketahui',
                    ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              _deleteTicket(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Hapus Tiket'),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    const Text(
                      "Daftar Penumpang:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!passengerSnapshot.hasData ||
                            passengerSnapshot.data!.docs.isEmpty) {
                          return const Text(
                              "Belum ada penumpang yang terdaftar.");
                        }

                        final passengers = passengerSnapshot
                            .data!.docs.first['passengers'] as List<dynamic>;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: passengers.length,
                          itemBuilder: (context, index) {
                            final passenger = passengers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  "${passenger['firstName']} ${passenger['lastName']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Tanggal Lahir: ${passenger['birthDate'] ?? 'Tidak tersedia'}"),
                                    Text(
                                        "Kewarganegaraan: ${passenger['nationality'] ?? 'Tidak tersedia'}"),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _deletePassenger(
                                      context, ticketId, index),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value, style: valueStyle),
        ),
        Divider(thickness: 1.5, color: Colors.grey[300]),
      ],
    );
  }
}

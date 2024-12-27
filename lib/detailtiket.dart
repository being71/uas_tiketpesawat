import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailTiketPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: SingleChildScrollView(
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
                    'Detail Tiket Penerbangan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(thickness: 1.5, color: Colors.grey[300]),
                ListTile(
                  leading: Icon(Icons.flight_takeoff, color: Colors.blueAccent),
                  title: Text(
                    'Tipe Penerbangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['flightType'] ?? 'Tidak Diketahui'),
                ),
                Divider(thickness: 1.5, color: Colors.grey[300]),
                ListTile(
                  leading: Icon(Icons.airlines, color: Colors.blueAccent),
                  title: Text(
                    'Maskapai',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['airline'] ?? 'Tidak Diketahui'),
                ),
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blueAccent),
                  title: Text(
                    'Waktu Keberangkatan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['departureTime'] ?? 'Tidak Diketahui'),
                ),
                ListTile(
                  leading:
                      Icon(Icons.access_time_filled, color: Colors.blueAccent),
                  title: Text(
                    'Waktu Kedatangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['arrivalTime'] ?? 'Tidak Diketahui'),
                ),
                ListTile(
                  leading: Icon(Icons.timer, color: Colors.blueAccent),
                  title: Text(
                    'Durasi Penerbangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${ticket['flightDuration'] ?? 0} menit'),
                ),
                ListTile(
                  leading: Icon(Icons.timer, color: Colors.blueAccent),
                  title: Text(
                    'Bagasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('${ticket['baggageInfo'] ?? 'Tidak Tersedia'} kg'),
                ),
                ListTile(
                  leading:
                      Icon(Icons.monetization_on, color: Colors.blueAccent),
                  title: Text(
                    'Harga',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(formatRupiah(ticket['price'] ?? 0)),
                ),
                ListTile(
                  leading: Icon(Icons.airline_seat_recline_normal,
                      color: Colors.blueAccent),
                  title: Text(
                    'Kelas Penerbangan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['flightClass'] ?? 'Tidak Diketahui'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blueAccent),
                  title: Text(
                    'Asal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      ticket['origin'] + ' (' + ticket['originCode'] + ')' ??
                          'Tidak Diketahui'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on_outlined,
                      color: Colors.blueAccent),
                  title: Text(
                    'Tujuan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(ticket['destination'] +
                          ' (' +
                          ticket['destinationCode'] +
                          ')' ??
                      'Tidak Diketahui'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatRupiah(int amount) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }
}

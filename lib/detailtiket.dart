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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipe Penerbangan: ${ticket['flightType'] ?? 'Tidak Diketahui'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Maskapai: ${ticket['airline'] ?? 'Tidak Diketahui'}'),
            Text(
                'Waktu Keberangkatan: ${ticket['departureTime'] ?? 'Tidak Diketahui'}'),
            Text(
                'Waktu Kedatangan: ${ticket['arrivalTime'] ?? 'Tidak Diketahui'}'),
            Text('Durasi Penerbangan: ${ticket['flightDuration'] ?? 0} menit'),
            Text('Harga: ${formatRupiah(ticket['price'] ?? 0)}'),
            Text(
                'Kelas Penerbangan: ${ticket['flightClass'] ?? 'Tidak Diketahui'}'),
            Text('Asal: ${ticket['originCode'] ?? 'Tidak Diketahui'}'),
            Text('Tujuan: ${ticket['destinationCode'] ?? 'Tidak Diketahui'}'),
          ],
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

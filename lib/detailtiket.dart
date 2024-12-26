import 'package:flutter/material.dart';

class DetailTiketPage extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketPage({Key? key, required this.ticket}) : super(key: key);

  @override
  _DetailCheckoutTiketPageState createState() =>
      _DetailCheckoutTiketPageState();
}

class _DetailCheckoutTiketPageState extends State<DetailTiketPage> {
  final List<Map<String, String>> _passengerDetails = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize passenger details with empty fields
    int passengerCount = widget.ticket['passengerCount'] ?? 1;
    for (int i = 0; i < passengerCount; i++) {
      _passengerDetails.add({
        'firstName': '',
        'lastName': '',
        'birthDate': '',
        'nationality': '',
      });
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      // Save data and navigate to payment page
      _formKey.currentState!.save();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            ticketId: widget.ticket['ticketId'],
            passengerDetails: _passengerDetails,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data penumpang wajib diisi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Checkout Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiket Info
                Text(
                  'Maskapai: ${widget.ticket['airline'] ?? 'Tidak Diketahui'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                    'Keberangkatan: ${widget.ticket['departureTime'] ?? 'Tidak Diketahui'}'),
                Text(
                    'Kedatangan: ${widget.ticket['arrivalTime'] ?? 'Tidak Diketahui'}'),
                Text(
                    'Kelas: ${widget.ticket['flightClass'] ?? 'Tidak Diketahui'}'),
                Text('Harga: Rp ${widget.ticket['price'] ?? 0}'),
                Text(
                    'Asal: ${widget.ticket['origin'] ?? 'Tidak Diketahui'} (${widget.ticket['originCode'] ?? 'Tidak Diketahui'})'),
                Text(
                    'Tujuan: ${widget.ticket['destination'] ?? 'Tidak Diketahui'} (${widget.ticket['destinationCode'] ?? 'Tidak Diketahui'})'),
                Text('Durasi: ${widget.ticket['flightDuration'] ?? 0} jam'),
                Text(
                    'Tipe Penerbangan: ${widget.ticket['flightType'] ?? 'Tidak Diketahui'}'),
                Text(
                    'Tanggal Pergi: ${widget.ticket['date'] ?? 'Tidak Diketahui'}'),
                Text(
                    'Tanggal Pulang: ${widget.ticket['returnDate'] ?? 'Tidak Diketahui'}'),
                Text(
                    'Bagasi: ${widget.ticket['baggageInfo'] ?? 'Tidak Diketahui'} kg'),
                const SizedBox(height: 20),

                // Passenger Forms
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.ticket['passengerCount'] ?? 1,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penumpang ${index + 1}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nama Depan',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Depan wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _passengerDetails[index]['firstName'] = value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nama Belakang',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama Belakang wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _passengerDetails[index]['lastName'] = value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal Lahir wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _passengerDetails[index]['birthDate'] = value!;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Kewarganegaraan',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kewarganegaraan wajib diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _passengerDetails[index]['nationality'] = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Button
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  child: const Text('Konfirmasi'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for Payment Page
class PaymentPage extends StatelessWidget {
  final String ticketId;
  final List<Map<String, String>> passengerDetails;

  const PaymentPage({
    Key? key,
    required this.ticketId,
    required this.passengerDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Center(
        child: Text(
          'Lanjutkan ke halaman pembayaran untuk tiket $ticketId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

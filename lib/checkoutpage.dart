import 'package:flutter/material.dart';
import 'detail_payment.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const CheckoutPage({required this.ticket, Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  int passengerCount = 1;
  final List<Map<String, String>> passengers = [];

  void _initializePassengers() {
    passengers.clear();
    for (int i = 0; i < passengerCount; i++) {
      passengers.add({
        'firstName': '',
        'lastName': '',
        'birthDate': '',
        'nationality': '',
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePassengers();

    // Cetak docId tiket ke konsol
    final docId = widget.ticket['docId'];
    print('DocId tiket yang sedang dilihat: $docId');
  }

  void _navigateToPaymentPage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailPaymentPage(ticket: widget.ticket, passengers: passengers),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap isi semua data penumpang dengan benar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      title: Text('Maskapai'),
                      subtitle: Text(widget.ticket['airline']),
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time, color: Colors.blue),
                      title: Text('Waktu Keberangkatan'),
                      subtitle: Text(widget.ticket['departureTime']),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.access_time_filled, color: Colors.blue),
                      title: Text('Waktu Kedatangan'),
                      subtitle: Text(widget.ticket['arrivalTime']),
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on, color: Colors.blue),
                      title: Text('Harga'),
                      subtitle: Text('Rp${widget.ticket['price']}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumlah Penumpang:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: passengerCount,
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      passengerCount = value!;
                      _initializePassengers();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: passengers.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penumpang ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Divider(),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nama Depan',
                            ),
                            onSaved: (value) =>
                                passengers[index]['firstName'] = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama depan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nama Belakang',
                            ),
                            onSaved: (value) =>
                                passengers[index]['lastName'] = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama belakang wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Lahir',
                            ),
                            onSaved: (value) =>
                                passengers[index]['birthDate'] = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal lahir wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Kewarganegaraan',
                            ),
                            onSaved: (value) =>
                                passengers[index]['nationality'] = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kewarganegaraan wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToPaymentPage,
                child: const Text('Konfirmasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uas_tiketpesawat/ticket_list_page.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _baggageInfoController = TextEditingController();
  final TextEditingController _flightDurationController =
      TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();

  String _flightType = 'Sekali Jalan';
  String _flightClass = 'Ekonomi';

  Future<void> _addTicket() async {
    String origin = _originController.text.trim();
    String destination = _destinationController.text.trim();
    String date = _dateController.text.trim();
    String seatCount = _seatController.text.trim();
    String price = _priceController.text.trim();
    String baggageInfo = _baggageInfoController.text.trim();
    String flightDuration = _flightDurationController.text.trim();
    String departureTime = _departureTimeController.text.trim();
    String arrivalTime = _arrivalTimeController.text.trim();

    if (origin.isEmpty ||
        destination.isEmpty ||
        date.isEmpty ||
        seatCount.isEmpty ||
        price.isEmpty ||
        baggageInfo.isEmpty ||
        flightDuration.isEmpty ||
        departureTime.isEmpty ||
        arrivalTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!')),
      );
      return;
    }

    try {
      // Parsing harga dengan menghilangkan semua karakter non-digit
      int parsedPrice = int.parse(price.replaceAll(RegExp(r'[^\d]'), ''));

      await FirebaseFirestore.instance.collection('tickets').add({
        'origin': origin,
        'destination': destination,
        'date': date,
        'flightType': _flightType,
        'flightClass': _flightClass,
        'seatCount': int.parse(seatCount),
        'price': parsedPrice, // Pastikan harga dalam bentuk integer
        'baggageInfo': int.parse(baggageInfo),
        'flightDuration': int.parse(flightDuration),
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'status': 'Available',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket berhasil ditambahkan!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah tiket: $e')),
      );
    }
  }

  void _clearFields() {
    _originController.clear();
    _destinationController.clear();
    _dateController.clear();
    _seatController.clear();
    _priceController.clear();
    _baggageInfoController.clear();
    _flightDurationController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
    setState(() {
      _flightType = 'Sekali Jalan';
      _flightClass = 'Ekonomi';
    });
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    try {
      return formatter
          .format(int.parse(value.replaceAll(RegExp(r'[^0-9]'), '')));
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tiket Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Bandara Asal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Bandara Tujuan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly:
                    true, // Membuat TextField hanya bisa diisi melalui DatePicker
                decoration: const InputDecoration(
                  labelText: 'Tanggal Tiket',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000), // Batas awal tanggal
                    lastDate: DateTime(2100), // Batas akhir tanggal
                  );

                  if (pickedDate != null) {
                    // Format tanggal menjadi dd/MM/yyyy
                    String formattedDate =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

                    setState(() {
                      _dateController.text =
                          formattedDate; // Set nilai ke TextField
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _flightType,
                items: const [
                  DropdownMenuItem(
                      value: 'Sekali Jalan', child: Text('Sekali Jalan')),
                  DropdownMenuItem(
                      value: 'Pulang Pergi', child: Text('Pulang Pergi')),
                ],
                onChanged: (value) {
                  setState(() {
                    _flightType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tipe Kepergian',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _flightClass,
                items: const [
                  DropdownMenuItem(value: 'Ekonomi', child: Text('Ekonomi')),
                  DropdownMenuItem(value: 'Bisnis', child: Text('Bisnis')),
                  DropdownMenuItem(
                      value: 'First Class', child: Text('First Class')),
                ],
                onChanged: (value) {
                  setState(() {
                    _flightClass = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Kelas Penerbangan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _seatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Kursi (Penumpang)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _priceController.text = formatCurrency(value);
                    _priceController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _priceController.text.length),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _baggageInfoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Informasi Bagasi (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _flightDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimasi Waktu Penerbangan (jam)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _departureTimeController,
                readOnly:
                    true, // Membuat TextField hanya bisa diisi melalui TimePicker
                decoration: const InputDecoration(
                  labelText: 'Jam Keberangkatan',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    // Format waktu menjadi HH:mm
                    String formattedTime = pickedTime.format(context);

                    setState(() {
                      _departureTimeController.text =
                          formattedTime; // Set nilai ke TextField
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _arrivalTimeController,
                readOnly:
                    true, // Membuat TextField hanya bisa diisi melalui TimePicker
                decoration: const InputDecoration(
                  labelText: 'Perkiraan Jam Mendarat',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    // Format waktu menjadi HH:mm
                    String formattedTime = pickedTime.format(context);

                    setState(() {
                      _arrivalTimeController.text =
                          formattedTime; // Set nilai ke TextField
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _addTicket(); // Tambah tiket ke Firestore
                    Navigator.push(
                      // Navigasi ke daftar tiket
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TicketListPage()),
                    );
                  },
                  child: const Text('Tambah Tiket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

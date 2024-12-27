import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditTicketPage extends StatefulWidget {
  final String ticketId;

  const EditTicketPage({Key? key, required this.ticketId}) : super(key: key);

  @override
  _EditTicketPageState createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TextEditingController _priceController;
  late TextEditingController _dateController;
  late TextEditingController _flightDurationController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _flightTypeController;
  late TextEditingController _flightClassController;
  late TextEditingController _baggageInfoController;
  late TextEditingController _airlineController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchTicketData();
  }

  void _initializeControllers() {
    _originController = TextEditingController();
    _destinationController = TextEditingController();
    _priceController = TextEditingController();
    _dateController = TextEditingController();
    _flightDurationController = TextEditingController();
    _departureTimeController = TextEditingController();
    _arrivalTimeController = TextEditingController();
    _flightTypeController = TextEditingController();
    _flightClassController = TextEditingController();
    _baggageInfoController = TextEditingController();
    _airlineController = TextEditingController();
  }

  Future<void> _fetchTicketData() async {
    DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.ticketId)
        .get();

    if (ticketDoc.exists) {
      final ticket = ticketDoc.data() as Map<String, dynamic>;

      _originController.text = ticket['origin'];
      _destinationController.text = ticket['destination'];
      _priceController.text = ticket['price'].toString();
      if (ticket['date'] is Timestamp) {
        Timestamp timestamp = ticket['date'];
        _dateController.text =
            DateFormat('yyyy-MM-dd').format(timestamp.toDate());
      } else if (ticket['date'] is String) {
        _dateController.text = ticket['date'];
      }
      _flightDurationController.text = ticket['flightDuration'].toString();
      _departureTimeController.text = ticket['departureTime'];
      _arrivalTimeController.text = ticket['arrivalTime'];
      _flightTypeController.text = ticket['flightType'];
      _flightClassController.text = ticket['flightClass'];
      _baggageInfoController.text = ticket['baggageInfo'].toString();
      _airlineController.text = ticket['airline'];
    }
  }

  Future<void> _updateTicket() async {
    if (_formKey.currentState!.validate()) {
      DateTime? selectedDate;
      if (_dateController.text.isNotEmpty) {
        selectedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
      }

      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticketId)
          .update({
        'origin': _originController.text,
        'destination': _destinationController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'date': selectedDate != null ? Timestamp.fromDate(selectedDate) : null,
        'flightDuration': int.tryParse(_flightDurationController.text) ?? 0,
        'departureTime': _departureTimeController.text,
        'arrivalTime': _arrivalTimeController.text,
        'flightType': _flightTypeController.text,
        'flightClass': _flightClassController.text,
        'baggageInfo': double.tryParse(_baggageInfoController.text) ?? 0.0,
        'airline': _airlineController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket berhasil diperbarui!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _flightDurationController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _flightTypeController.dispose();
    _flightClassController.dispose();
    _baggageInfoController.dispose();
    _airlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tiket'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildTextField(_originController, 'Asal',
                        'Harap masukkan asal penerbangan'),
                    _buildTextField(_destinationController, 'Tujuan',
                        'Harap masukkan tujuan penerbangan'),
                    _buildTextField(
                        _priceController, 'Harga', 'Harap masukkan harga tiket',
                        keyboardType: TextInputType.number),
                    _buildTextField(_dateController, 'Tanggal',
                        'Harap masukkan tanggal penerbangan'),
                    _buildTextField(_flightDurationController, 'Durasi (jam)',
                        'Harap masukkan durasi penerbangan',
                        keyboardType: TextInputType.number),
                    _buildTextField(
                        _departureTimeController,
                        'Waktu Keberangkatan',
                        'Harap masukkan waktu keberangkatan'),
                    _buildTextField(_arrivalTimeController, 'Waktu Mendarat',
                        'Harap masukkan waktu mendarat'),
                    _buildTextField(_flightTypeController, 'Tipe Penerbangan',
                        'Harap masukkan tipe penerbangan'),
                    _buildTextField(_flightClassController, 'Kelas Penerbangan',
                        'Harap masukkan kelas penerbangan'),
                    _buildTextField(_baggageInfoController, 'Bagasi (kg)',
                        'Harap masukkan informasi bagasi',
                        keyboardType: TextInputType.number),
                    _buildTextField(_airlineController, 'Airline',
                        'Harap masukkan nama maskapai'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _updateTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize:
                      const Size.fromHeight(48), // Tinggi tombol proporsional
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String errorMessage,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? errorMessage : null,
        keyboardType: keyboardType,
      ),
    );
  }
}

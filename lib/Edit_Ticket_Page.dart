import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      _dateController.text = ticket['date'];
      _flightDurationController.text = ticket['flightDuration'].toString();
      _departureTimeController.text = ticket['departureTime'];
      _arrivalTimeController.text = ticket['arrivalTime'];
      _flightTypeController.text = ticket['flightType'];
      _flightClassController.text = ticket['flightClass'];
      _baggageInfoController.text = ticket['baggageInfo'].toString();
    }
  }

  Future<void> _updateTicket() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticketId)
          .update({
        'origin': _originController.text,
        'destination': _destinationController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'date': _dateController.text,
        'flightDuration': int.tryParse(_flightDurationController.text) ?? 0,
        'departureTime': _departureTimeController.text,
        'arrivalTime': _arrivalTimeController.text,
        'flightType': _flightTypeController.text,
        'flightClass': _flightClassController.text,
        'baggageInfo': double.tryParse(_baggageInfoController.text) ?? 0.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiket berhasil diperbarui!')));
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
          child: ListView(
            children: [
              // Origin
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'Asal'),
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan asal penerbangan' : null,
              ),
              const SizedBox(height: 8),
              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Tujuan'),
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan tujuan penerbangan' : null,
              ),
              const SizedBox(height: 8),
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan harga tiket' : null,
              ),
              const SizedBox(height: 8),
              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Tanggal'),
                validator: (value) => value!.isEmpty
                    ? 'Harap masukkan tanggal penerbangan'
                    : null,
              ),
              const SizedBox(height: 8),
              // Flight Duration
              TextFormField(
                controller: _flightDurationController,
                decoration: const InputDecoration(labelText: 'Durasi (jam)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan durasi penerbangan' : null,
              ),
              const SizedBox(height: 8),
              // Departure Time
              TextFormField(
                controller: _departureTimeController,
                decoration:
                    const InputDecoration(labelText: 'Waktu Keberangkatan'),
                validator: (value) => value!.isEmpty
                    ? 'Harap masukkan waktu keberangkatan'
                    : null,
              ),
              const SizedBox(height: 8),
              // Arrival Time
              TextFormField(
                controller: _arrivalTimeController,
                decoration: const InputDecoration(labelText: 'Waktu Mendarat'),
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan waktu mendarat' : null,
              ),
              const SizedBox(height: 8),
              // Flight Type
              TextFormField(
                controller: _flightTypeController,
                decoration:
                    const InputDecoration(labelText: 'Tipe Penerbangan'),
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan tipe penerbangan' : null,
              ),
              const SizedBox(height: 8),
              // Flight Class
              TextFormField(
                controller: _flightClassController,
                decoration:
                    const InputDecoration(labelText: 'Kelas Penerbangan'),
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan kelas penerbangan' : null,
              ),
              const SizedBox(height: 8),
              // Baggage Info
              TextFormField(
                controller: _baggageInfoController,
                decoration: const InputDecoration(labelText: 'Bagasi (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harap masukkan informasi bagasi' : null,
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _updateTicket,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

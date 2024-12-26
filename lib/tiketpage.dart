import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore.dart';
import 'home_screen_user.dart';
import 'profile_page.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _tickets = []; // List to store ticket data

  // Controllers for user input
  final TextEditingController _asalController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _penumpangController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedIndex = 0; // Index for the selected tab

  String? _tipeKeberangkatan; // Dropdown value for Tipe Keberangkatan
  String? _kelasPenerbangan; // Dropdown value for Kelas Penerbangan

  // Fetch tickets from Firestore
  Future<void> _fetchTickets() async {
    List<Map<String, dynamic>> tickets = await _firestoreService.getTickets();
    setState(() {
      _tickets = tickets; // Update the UI with fetched data
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTickets(); // Fetch tickets when the page loads
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // Format the date into a readable string
  String _formatDate(String date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.parse(date));
  }

  String formatRupiah(int amount) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0, // No decimals for Rupiah
    );
    return currencyFormatter.format(amount);
  }

  void _searchTickets() async {
    // Validasi input
    if (_asalController.text.isEmpty ||
        _tujuanController.text.isEmpty ||
        _penumpangController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _tipeKeberangkatan == null ||
        _kelasPenerbangan == null) {
      // Jika ada yang kosong, tampilkan pesan peringatan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi')),
      );
      return;
    }
    print("Asal: ${_asalController.text}");
    print("Tujuan: ${_tujuanController.text}");
    print("Start Date: $_startDate");
    print("End Date: $_endDate");
    print("Jumlah Penumpang: ${_penumpangController.text}");
    print("Tipe Keberangkatan: $_tipeKeberangkatan");
    print("Kelas Penerbangan: $_kelasPenerbangan");

    // Ambil data tiket berdasarkan kriteria pencarian
    try {
      List<Map<String, dynamic>> tickets =
          await _firestoreService.getTicketsBySearch(
        asal: capitalize(_asalController.text),
        tujuan: capitalize(_tujuanController.text),
        penumpang: int.parse(_penumpangController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        tipeKeberangkatan: _tipeKeberangkatan!,
        kelasPenerbangan: _kelasPenerbangan!,
      );

      setState(() {
        _tickets = tickets;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Bagian Input Data
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            controller: _asalController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Asal',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            controller: _tujuanController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Tujuan',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDateRange(context),
                          child: Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Text(
                                _startDate != null && _endDate != null
                                    ? '${_formatDate(_startDate.toString())} - ${_formatDate(_endDate.toString())}'
                                    : 'Pilih Tanggal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: _penumpangController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Jumlah Penumpang',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tipeKeberangkatan,
                          items: const [
                            DropdownMenuItem(
                              value: "Sekali Jalan",
                              child: Text("Sekali Jalan"),
                            ),
                            DropdownMenuItem(
                              value: "Pulang Pergi",
                              child: Text("Pulang Pergi"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _tipeKeberangkatan = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tipe Keberangkatan',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _kelasPenerbangan,
                          items: const [
                            DropdownMenuItem(
                              value: "Ekonomi",
                              child: Text("Ekonomi"),
                            ),
                            DropdownMenuItem(
                              value: "Bisnis",
                              child: Text("Bisnis"),
                            ),
                            DropdownMenuItem(
                              value: "First Class",
                              child: Text("First Class"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _kelasPenerbangan = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Kelas Penerbangan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _searchTickets, // Panggil fungsi pencarian
                    child: const Text('Cari'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Daftar Penerbangan (Flight List)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _tickets.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada penerbangan ditemukan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ) // Show loading if no tickets are fetched yet
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) {
                          var ticket = _tickets[index];

                          // Use null-aware operator `??` to provide a default value
                          return FlightCard(
                            airline:
                                ticket['flightType'] ?? 'Unknown Flight Type',
                            departureTime: ticket['departureTime'] ?? 'Unknown',
                            arrivalTime: ticket['arrivalTime'] ?? 'Unknown',
                            flightDuration: ticket['flightDuration'] ?? 0,
                            price: formatRupiah(ticket['price'] ?? 0),
                            flightClass:
                                ticket['flightClass'] ?? 'Unknown Class',
                            origin: ticket['originCode'] ??
                                'Unknown Origin', // Default value added
                            destination: ticket['destinationCode'] ??
                                'Unknown Destination', // Default value added
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Simpan indeks tab yang dipilih
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreenUser(
                        userId: FirebaseAuth.instance.currentUser!.uid)),
              );
              break;
            case 1:
            /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PesananPage()),
        );
        break;*/
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                        userId: FirebaseAuth.instance.currentUser!.uid)),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

class FlightCard extends StatelessWidget {
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final int flightDuration;
  final String price;
  final String flightClass;
  final String origin;
  final String destination;

  const FlightCard({
    Key? key,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightDuration,
    required this.price,
    required this.flightClass,
    required this.origin,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flight details section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  flightClass,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                airline,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Time & Location section
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    departureTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(' $origin'),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                '• $flightDuration jam',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Text(
                    arrivalTime,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(' $destination'),
                ],
              ),
            ],
          ),

          // Price section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Mulai dari',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4.0),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

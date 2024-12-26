import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore.dart';
import 'home_screen_user.dart';
import 'profile_page.dart';
import 'detailtiket.dart';
import 'checkoutpage.dart';

class TicketPage extends StatefulWidget {
  final String userId;

  const TicketPage({required this.userId});

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

  String? _tipeKepergian; // Dropdown value for Tipe Kepergian
  String? _kelasPenerbangan; // Dropdown value for Kelas Penerbangan
  String? _filterHarga;

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
        int.parse(_penumpangController.text) <= 0 ||
        _startDate == null ||
        _endDate == null ||
        _tipeKepergian == null ||
        _kelasPenerbangan == null ||
        _filterHarga == null) {
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
    print("Tipe Kepergian: $_tipeKepergian");
    print("Kelas Penerbangan: $_kelasPenerbangan");

    // Ambil jumlah penumpang dari controller
    int jumlahPenumpang = int.parse(_penumpangController.text);

// Parse rentang harga dari dropdown
    List<String> hargaRange = _filterHarga!.split('-');
    int minHarga = int.parse(hargaRange[0]);
    int maxHarga = int.parse(hargaRange[1]);

    // Ambil data tiket berdasarkan kriteria pencarian
    try {
      List<Map<String, dynamic>> tickets =
          await _firestoreService.getTicketsBySearch(
        asal: capitalize(_asalController.text),
        tujuan: capitalize(_tujuanController.text),
        penumpang: int.parse(_penumpangController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        tipeKepergian: _tipeKepergian!,
        kelasPenerbangan: _kelasPenerbangan!,
        minHarga: minHarga.toString(),
        maxHarga: maxHarga.toString(),
      );

      // Filter tiket berdasarkan jumlah penumpang dan seatCount
      List<Map<String, dynamic>> filteredTickets = tickets.where((ticket) {
        // Pastikan 'seatCount' sudah dalam bentuk int
        int seatCount = int.tryParse(ticket['seatCount'].toString()) ??
            0; // Mengonversi ke int, jika gagal gunakan 0
        return seatCount >=
            jumlahPenumpang; // Hanya tampilkan tiket jika seatCount cukup
      }).toList();

      setState(() {
        _tickets = filteredTickets;
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
                          value: _tipeKepergian,
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
                              _tipeKepergian = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tipe Kepergian',
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
                            labelText: 'Kelas\nPenerbangan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Filter harga
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterHarga,
                          items: const [
                            DropdownMenuItem(
                              value: "100000-1000000",
                              child: Text("100 rb - 1 juta"),
                            ),
                            DropdownMenuItem(
                              value: "1000000-5000000",
                              child: Text("1 juta - 5 juta"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterHarga = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Filter Harga',
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
                  color: Colors.blueAccent,
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

                          // Tambahkan logika filtering berdasarkan tipe kepergian
                          if (_tipeKepergian == 'Sekali Jalan' &&
                              ticket['flightType'] != 'Sekali Jalan') {
                            return SizedBox
                                .shrink(); // Tidak menampilkan tiket jika tipe kepergian tidak sesuai
                          } else if (_tipeKepergian == 'Pulang Pergi' &&
                              ticket['flightType'] != 'Pulang Pergi') {
                            return SizedBox
                                .shrink(); // Tidak menampilkan tiket jika tipe kepergian tidak sesuai
                          }

                          // Menampilkan tiket yang sudah difilter berdasarkan tipe kepergian
                          if (_tipeKepergian == 'Sekali Jalan') {
                            return GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman DetailTicketPage dengan mengirimkan seluruh ticket data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailTiketPage(ticket: ticket),
                                  ),
                                );
                              },
                              child: FlightCardOneWay(
                                ticket: ticket,
                                flightType: ticket['flightType'] ??
                                    'Unknown Flight Type',
                                airline: ticket['airline'] ?? 'Unknown',
                                departureTime:
                                    ticket['departureTime'] ?? 'Unknown',
                                arrivalTime: ticket['arrivalTime'] ?? 'Unknown',
                                flightDuration: ticket['flightDuration'] ?? 0,
                                price: formatRupiah(ticket['price'] ?? 0),
                                flightClass:
                                    ticket['flightClass'] ?? 'Unknown Class',
                                origin:
                                    ticket['originCode'] ?? 'Unknown Origin',
                                destination: ticket['destinationCode'] ??
                                    'Unknown Destination',
                              ),
                            );
                          } else if (_tipeKepergian == 'Pulang Pergi') {
                            return GestureDetector(
                              onTap: () {
                                // Navigasi ke halaman DetailTicketPage dengan mengirimkan seluruh ticket data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailTiketPage(ticket: ticket),
                                  ),
                                );
                              },
                              child: FlightCardTwoWay(
                                ticket: ticket,
                                flightType: ticket['flightType'] ??
                                    'Unknown Flight Type',
                                departureTime:
                                    ticket['departureTime'] ?? 'Unknown',
                                arrivalTime: ticket['arrivalTime'] ?? 'Unknown',
                                flightDuration: ticket['flightDuration'] ?? 0,
                                price: formatRupiah(ticket['price'] ?? 0),
                                flightClass:
                                    ticket['flightClass'] ?? 'Unknown Class',
                                origin:
                                    ticket['originCode'] ?? 'Unknown Origin',
                                destination: ticket['destinationCode'] ??
                                    'Unknown Destination',
                                airline: ticket['airline'] ?? 'Unknown',
                              ),
                            );
                          }

                          return SizedBox
                              .shrink(); // Return an empty widget if no conditions are met
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigasi ke halaman Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenUser(userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            // Navigasi ke halaman Pesanan (belum diimplementasikan)
          } else if (index == 2) {
            // Tetap di halaman Profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userId: widget.userId),
              ),
            );
          }
        },
      ),
    );
  }

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

class FlightCardOneWay extends StatelessWidget {
  final String airline;
  final String flightType;
  final String departureTime;
  final String arrivalTime;
  final int flightDuration;
  final String price;
  final String flightClass;
  final String origin;
  final String destination;
  final Map<String, dynamic> ticket;

  const FlightCardOneWay({
    Key? key,
    required this.airline,
    required this.flightType,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightDuration,
    required this.price,
    required this.flightClass,
    required this.origin,
    required this.destination,
    required this.ticket,
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
                onPressed: () {
                  // Navigate to CheckoutPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(ticket: ticket),
                    ),
                  );
                },
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

class FlightCardTwoWay extends StatelessWidget {
  final String airline;
  final String flightType;
  final String departureTime;
  final String arrivalTime;
  final int flightDuration;
  final String price;
  final String flightClass;
  final String origin;
  final String destination;
  final Map<String, dynamic> ticket;

  const FlightCardTwoWay({
    Key? key,
    required this.airline,
    required this.flightType,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightDuration,
    required this.price,
    required this.flightClass,
    required this.origin,
    required this.destination,
    required this.ticket,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flight details section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      flightClass,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment
                    .end, // This will ensure content is spread out vertically
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '$airline',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Column(
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
                              const SizedBox(height: 4.0),
                            ],
                          ),
                          Text(
                            '• $flightDuration jam',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
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
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '$airline',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Column(
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
                              const SizedBox(height: 4.0),
                            ],
                          ),
                          Text(
                            '• $flightDuration jam',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
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
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          // Time & Location section

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
                onPressed: () {
                  // Navigate to CheckoutPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(ticket: ticket),
                    ),
                  );
                },
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

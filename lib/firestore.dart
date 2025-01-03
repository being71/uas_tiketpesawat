// ignore_for_file: equal_keys_in_map

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fungsi login pengguna menggunakan email dan password
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login gagal, coba lagi.');
    }
  }

  // Fungsi untuk mengecek apakah data pengguna ada di Firestore
  Future<bool> isUserExists(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      throw Exception("Gagal memeriksa data pengguna: $e");
    }
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception('Pengguna tidak ditemukan di Firestore.');
      }
    } catch (e) {
      throw Exception("Gagal mengambil data pengguna: $e");
    }
  }

  // Fungsi untuk membuat data pengguna baru di Firestore
  Future<void> createUser({
    required String uid,
    required String email,
    required String nama,
    required String noTelp,
    required String status,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set({
        'email': email,
        'nama': nama,
        'noTelp': noTelp,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(), // Tambahkan waktu pembuatan
      });
    } catch (e) {
      throw Exception("Gagal menyimpan data pengguna: $e");
    }
  }

  // Fetch tickets from Firestore
  Future<List<Map<String, dynamic>>> getTickets() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('tickets').get();
      List<Map<String, dynamic>> tickets = snapshot.docs.map((doc) {
        return {
          'docId': doc.id,
          'date': doc['date'] ?? 'Unknown Date',
          'airline': doc['airline'] ?? 'Unknown Airline',
          'arrivalTime': doc['arrivalTime'] ?? 'Unknown Arrival',
          'baggageInfo': doc['baggageInfo'] ?? 0,
          'createdAt': doc['createdAt'],
          'date': doc['date'] ?? 'Unknown Date',
          'departureTime': doc['departureTime'] ?? 'Unknown Departure',
          'destination': doc['destination'] ?? 'Unknown Destination',
          'destinationCode':
              doc['destinationCode'] ?? 'Unknown Destination Code',
          'flightClass': doc['flightClass'] ?? 'Unknown Class',
          'flightDuration': doc['flightDuration'] ?? 0,
          'flightType': doc['flightType'] ?? 'Unknown Type',
          'origin': doc['origin'] ?? 'Unknown Origin',
          'originCode': doc['originCode'] ?? 'Unknown Origin Code',
          'price': doc['price'] ?? 0,
          'seatCount': doc['seatCount'] ?? 0,
          'status': doc['status'] ?? 'Unknown Status',
        };
      }).toList();

      return tickets;
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  // Fungsi untuk mencari tiket berdasarkan kriteria pencarian
  Future<List<Map<String, dynamic>>> getTicketsBySearch(
      {required String asal,
      required String tujuan,
      required int penumpang,
      required DateTime startDate,
      required DateTime endDate,
      required String tipeKepergian,
      required String kelasPenerbangan,
      required String minHarga,
      required String maxHarga}) async {
    try {
      Query query = firestore.collection('tickets');

      // Filter berdasarkan asal dan tujuan
      query = query
          .where('origin', isEqualTo: asal)
          .where('destination', isEqualTo: tujuan)
          .where('flightType', isEqualTo: tipeKepergian)
          .where('flightClass', isEqualTo: kelasPenerbangan);

      // Filter berdasarkan tanggal Kepergian
      query = query
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate);

      query = query
          .where('price', isGreaterThanOrEqualTo: int.parse(minHarga))
          .where('price', isLessThanOrEqualTo: int.parse(maxHarga));

      // Ambil tiket sesuai kriteria
      QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> tickets = snapshot.docs.map((doc) {
        return {
          'docId': doc.id,
          'arrivalTime': doc['arrivalTime'] ?? 'Unknown Arrival',
          'baggageInfo': doc['baggageInfo'] ?? 0,
          'createdAt': doc['createdAt'],
          'date': doc['date'] ?? 'Unknown Date',
          'departureTime': doc['departureTime'] ?? 'Unknown Departure',
          'destination': doc['destination'] ?? 'Unknown Destination',
          'destinationCode':
              doc['destinationCode'] ?? 'Unknown Destination Code',
          'flightClass': doc['flightClass'] ?? 'Unknown Class',
          'flightDuration': doc['flightDuration'] ?? 0,
          'flightType': doc['flightType'] ?? 'Unknown Type',
          'origin': doc['origin'] ?? 'Unknown Origin',
          'originCode': doc['originCode'] ?? 'Unknown Origin Code',
          'price': doc['price'] ?? 0,
          'seatCount': doc['seatCount'] ?? 0,
          'status': doc['status'] ?? 'Unknown Status',
          'airline': doc['airline'] ?? 'Unknown Airline',
        };
      }).toList();

      return tickets;
    } catch (e) {
      throw Exception("Gagal melakukan pencarian tiket:$e");
    }
  }

  // Method untuk mengambil booked_tickets berdasarkan userId
  Future<List<Map<String, dynamic>>> getBookedTickets(String userId) async {
    try {
      var snapshot = await firestore
          .collection('booked_tickets')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> tickets = [];
      for (var doc in snapshot.docs) {
        tickets.add(doc.data());
      }
      return tickets;
    } catch (e) {
      print('Error fetching booked tickets: $e');
      return [];
    }
  }

  // Method untuk mengambil ticket berdasarkan ticketId
  Future<Map<String, dynamic>> getTicketData(String ticketId) async {
    try {
      var doc = await firestore.collection('tickets').doc(ticketId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error fetching ticket data: $e');
      return {};
    }
  }
}

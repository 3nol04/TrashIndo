import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/screens/detail_screen.dart';
import 'package:trashindo/model/Sampah.dart';

class BooksMarksScreens extends StatefulWidget {
  const BooksMarksScreens({super.key});

  @override
  State<BooksMarksScreens> createState() => _BooksMarksScreensState();
}

class _BooksMarksScreensState extends State<BooksMarksScreens> {
  List<Sampah> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .get();

      final bookmarks = snapshot.docs.map((doc) {
        return Sampah.fromJson(doc);
      }).toList();

      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'tersedia':
        return const Color(0xFFD6F5D6); // hijau muda
      case 'penuh':
        return const Color(0xFFFFF4CC); // kuning muda
      case 'rusak':
        return const Color(0xFFFFD6D6); // merah muda
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(child: Text('Belum ada bookmarks'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final sampah = _bookmarks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreens(idSampah: sampah.id ?? ''),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: sampah.image != null
                                    ? Image.memory(
                                        base64Decode(sampah.image!),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/broken-image.png',
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          sampah.daerah ?? 'Tanpa Nama',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sampah.deskripsi ??
                                          'Deskripsi tidak tersedia',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor(sampah.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  sampah.status ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/screens/detail_screen.dart';

class SearchScreens extends StatefulWidget {
  const SearchScreens({super.key});

  @override
  State<SearchScreens> createState() => _SearchScreensState();
}

class _SearchScreensState extends State<SearchScreens> {
  final TextEditingController _searchController = TextEditingController();
  List<Sampah> _allSampah = [];
  List<Sampah> _filteredSampah = [];

  @override
  void initState() {
    super.initState();
    _fetchSampah();
    _searchController.addListener(_filterSearch);
  }

  Future<void> _fetchSampah() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('sampah').get();
    final data = snapshot.docs.map((doc) => Sampah.fromJson(doc)).toList();
    setState(() {
      _allSampah = data;
      _filteredSampah = data;
    });
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    final filtered = _allSampah.where((sampah) {
      final daerah = sampah.daerah?.toLowerCase() ?? '';
      return daerah.contains(query);
    }).toList();

    setState(() {
      _filteredSampah = filtered;
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search..',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3E4B19),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hasil pencarian
              Expanded(
                child: _filteredSampah.isEmpty
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView.builder(
                        itemCount: _filteredSampah.length,
                        itemBuilder: (context, index) {
                          final sampah = _filteredSampah[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreens(
                                    idSampah: sampah.id ?? '',
                                  ),
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
                                    // Gambar
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

                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Colors.black54),
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
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            getStatusColor(sampah.status ?? ''),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

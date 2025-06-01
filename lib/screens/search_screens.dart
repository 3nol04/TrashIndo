
import 'package:flutter/material.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/wigedts/list_kotak_sampah_wegendsts.dart';

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
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                          return ListKotakSampahWegendsts(
                            id: sampah.id ?? '',
                            status: sampah.status ?? 'Tidak ada status',
                            image: sampah.image ?? '',
                            daerah: sampah.daerah ?? 'Tidak ada daerah',
                            deskripsi:
                                sampah.deskripsi ?? 'Tidak ada deskripsi',
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

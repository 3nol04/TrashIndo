import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/screens/detail_screen.dart';
import 'package:trashindo/wigedts/list_kotak_sampah_wegendsts.dart';

class CategoryScreen extends StatelessWidget {
  final String status;

  const CategoryScreen({super.key, required this.status});

  // Stream to fetch filtered Sampah data from Firestore
  Stream<List<Sampah>> getFilteredSampah() {
    return FirebaseFirestore.instance
        .collection('sampah')
        .where('status', isEqualTo: status)
        .limit(20) // Limit data for pagination
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sampah.fromJson(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Status: $status')),
      body: StreamBuilder<List<Sampah>>(
        stream: getFilteredSampah(),
        builder: (context, snapshot) {
          // Check for loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          // Check for errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get the data or handle empty state
          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 50, color: Colors.grey),
                  Text('Tidak ada data status "$status".',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
          // Display the data in a list view
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final sampah = data[index];
              return ListKotakSampahWegendsts(
                id: sampah.id ?? '',
                status: sampah.status ?? '',
                image: sampah.image ?? '',
                daerah: sampah.daerah ?? '',
                deskripsi: sampah.deskripsi ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

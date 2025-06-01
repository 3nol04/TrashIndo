import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/screens/detail_screen.dart';


class CategoryScreen extends StatelessWidget {
  final String status;

  const CategoryScreen({super.key, required this.status});

  Stream<List<Sampah>> getFilteredSampah() {
    return FirebaseFirestore.instance
        .collection('sampah')
        .where('status', isEqualTo: status)
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return Center(child: Text('Tidak ada data status "$status".'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final sampah = data[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreens(idSampah: sampah.id!),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (sampah.image != null &&
                                sampah.image!.isNotEmpty &&
                                Uri.tryParse(sampah.image!)?.hasAbsolutePath ==
                                    true)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(sampah.image!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                )
                              )
                            : const Icon(Icons.image_not_supported, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sampah.lokasiDetail ?? 'Tidak diketahui',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sampah.deskripsi ?? '-',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          sampah.status ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trashindo/model/Sampah.dart';
import 'package:trashindo/wigedts/list_kotak_sampah_wegendsts.dart';

class BooksMarksScreens extends StatefulWidget {
  const BooksMarksScreens({super.key});

  @override
  State<BooksMarksScreens> createState() => _BooksMarksScreensState();
}

class _BooksMarksScreensState extends State<BooksMarksScreens> {
  List<MarksBooks> _dataBookmarks = [];
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
          .collection('marksbooks')
          .get();

      final List<MarksBooks> bookmarks = snapshot.docs.map((doc) {
        return MarksBooks.fromToJson(doc);
      }).toList();
      setState(() {
        _dataBookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dataBookmarks.isEmpty
              ? const Center(child: Text('Belum ada bookmarks'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _dataBookmarks.length,
                  itemBuilder: (context, index) {
                    final _bookNark = _dataBookmarks[index];

                    return ListKotakSampahWegendsts(
                      id: _bookNark.sampahId ?? '',
                      status: _bookNark.status ?? '',
                      image: _bookNark.image ?? '',
                      daerah: _bookNark.daerah ?? '',
                      deskripsi: _bookNark.daerah ?? '',
                    );
                  },
                ),
    );
  }
}

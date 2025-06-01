import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trashindo/screens/chat.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isSearching = false;

  // Fungsi untuk memeriksa dan membuat room chat baru jika belum ada
  Future<void> _createRoomIfNotExist(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;

      // Membuat ID room dengan gabungan userId pengirim dan penerima
      String roomId = userId.compareTo(receiverId) < 0
          ? '$userId-$receiverId'
          : '$receiverId-$userId';

      // Memeriksa apakah room sudah ada
      final room = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      if (!room.exists) {
        // Jika room belum ada, buat room baru
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(roomId)
            .set({
          'userIds': [userId, receiverId],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(userId)
          .set({
        'recentChats': FieldValue.arrayUnion(
            [receiverId]),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(receiverId)
          .set({
        'recentChats': FieldValue.arrayUnion(
            [userId]), 
      }, SetOptions(merge: true));

    
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: roomId, 
          ),
        ),
      );
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      setState(() {
        _isSearching = true;
        _users = users.docs.map((doc) {
          return {
            'userId': doc.id,
            'name': doc['name'],
            'image': doc['image'] ?? '',
          };
        }).toList();
      });
    } else {
      setState(() {
        _isSearching = false;
        _users = [];
      });
    }
  }

  // Menampilkan daftar pengguna yang pernah berkomunikasi
  Future<List<Map<String, dynamic>>> _getRecentChats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final recentChatsSnapshot = await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(userId)
          .get();

      if (recentChatsSnapshot.exists) {
        final recentChats = recentChatsSnapshot.data()?['recentChats'] ?? [];
        List<Map<String, dynamic>> users = [];
        for (String userId in recentChats) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (userSnapshot.exists) {
            users.add({
              'userId': userId,
              'name': userSnapshot['name'],
              'image': userSnapshot['image'] ?? '',
            });
          }
        }
        return users;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _searchUsers(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? _users.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (ctx, index) {
                            final user = _users[index];
                            return ListTile(
                              leading: user['image'].isNotEmpty
                                  ? (user['image'].startsWith('http')
                                      ? Icon(Icons.person)
                                      : CircleAvatar(
                                          backgroundImage: MemoryImage(
                                              base64Decode(user['image']))))
                                  : const Icon(Icons.person),
                              title: Text(user['name']),
                              onTap: () {
                                // Memanggil fungsi untuk membuat atau menggunakan room chat yang sudah ada
                                _createRoomIfNotExist(user['userId']);
                              },
                            );
                          },
                        )
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getRecentChats(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong'));
                        }

                        final recentChats = snapshot.data ?? [];

                        return recentChats.isEmpty
                            ? const Center(child: Text('No previous chats'))
                            : ListView.builder(
                                itemCount: recentChats.length,
                                itemBuilder: (ctx, index) {
                                  final user = recentChats[index];
                                  return ListTile(
                                    leading: user['image'].isNotEmpty
                                        ? (user['image'].startsWith('http')
                                            ? Icon(Icons.person)
                                            : CircleAvatar(
                                                backgroundImage: MemoryImage(
                                                    base64Decode(
                                                        user['image']))))
                                        : const Icon(Icons.person),
                                    title: Text(user['name']),
                                    onTap: () {
                                      // Memanggil fungsi untuk membuat atau menggunakan room chat yang sudah ada
                                      _createRoomIfNotExist(user['userId']);
                                    },
                                  );
                                },
                              );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

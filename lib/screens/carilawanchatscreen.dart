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

  Future<void> _createRoomIfNotExist(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      String roomId = userId.compareTo(receiverId) < 0
          ? '$userId-$receiverId'
          : '$receiverId-$userId';

      final room = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();

      if (!room.exists) {
        await FirebaseFirestore.instance.collection('chat_rooms').doc(roomId).set({
          'userIds': [userId, receiverId],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(userId)
          .set({
        'recentChats': FieldValue.arrayUnion([receiverId]),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(receiverId)
          .set({
        'recentChats': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(roomId: roomId),
        ),
      );
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();

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
        for (String uid in recentChats) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (userSnapshot.exists) {
            users.add({
              'userId': uid,
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

  Widget _buildUserTile(Map<String, dynamic> user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: user['image'].isNotEmpty
          ? (user['image'].startsWith('http')
              ? CircleAvatar(backgroundImage: NetworkImage(user['image']))
              : CircleAvatar(backgroundImage: MemoryImage(base64Decode(user['image'])))
            )
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user['name'], style: const TextStyle(color: Colors.white)),
      onTap: () => _createRoomIfNotExist(user['userId']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1E),
      appBar: AppBar(
        title: const Text('Search Users', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2B2B30),
                hintText: 'Search by name...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _searchUsers(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? (_users.isEmpty
                      ? const Center(child: Text('No users found', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (ctx, index) => _buildUserTile(_users[index]),
                        ))
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getRecentChats(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong', style: TextStyle(color: Colors.red)));
                        }
                        final recentChats = snapshot.data ?? [];
                        return recentChats.isEmpty
                            ? const Center(child: Text('No previous chats', style: TextStyle(color: Colors.white54)))
                            : ListView.builder(
                                itemCount: recentChats.length,
                                itemBuilder: (ctx, index) => _buildUserTile(recentChats[index]),
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
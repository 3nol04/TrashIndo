import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String roomId;  // ID Room Chat

  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Menangkap notifikasi yang diterima saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Notification received: ${message.notification!.title}');
        print('Message: ${message.notification!.body}');
        _showNewMessageDialog(message.notification!.title, message.notification!.body);
      }
    });

    // Menangkap notifikasi saat aplikasi di background atau terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Menangani ketika user mengetuk notifikasi dan aplikasi dibuka
      print('Notification clicked!');
      print('Message: ${message.notification!.body}');
      _showNewMessageDialog(message.notification!.title, message.notification!.body);
    });

    // Menangkap notifikasi saat aplikasi di background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Fungsi untuk menangani notifikasi saat aplikasi di background
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.notification?.title}');
    print('Message: ${message.notification?.body}');
  }

  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final roomId = widget.roomId;

      // Menyimpan pesan ke dalam sub-koleksi 'messages' di dalam room tertentu
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'message': _controller.text,
        'senderId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Ambil token penerima (misalnya, dari Firestore)
      String receiverToken = await _getReceiverToken(roomId);

      // Mengirim notifikasi ke penerima melalui backend
      if (receiverToken.isNotEmpty) {
        await sendNotificationToReceiver(roomId, _controller.text, receiverToken);
      }

      // Clear input field setelah mengirim pesan
      _controller.clear();
    }
  }

  // Fungsi untuk mengirim notifikasi ke backend
  Future<void> sendNotificationToReceiver(String roomId, String message, String receiverToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://vercel.com/m-tri-setiantos-projects/cloud-notiv-9dr8/send-notification'),
        body: {
          'token': receiverToken,
          'title': 'New message',
          'body': message,
          'roomId': roomId,
        },
      );
      if (response.statusCode == 200) {
        print('Notification sent');
      } else {
        print('Failed to send notification');
      }
    } catch (error) {
      print('Error sending notification: $error');
    }
  }

  // Fungsi untuk mendapatkan token penerima dari Firestore
  Future<String> _getReceiverToken(String roomId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();
      if (doc.exists) {
        // Ganti dengan field yang sesuai di Firestore
        return doc.data()?['receiverToken'] ?? ''; 
      } else {
        return ''; // Token tidak ditemukan
      }
    } catch (error) {
      print('Error fetching receiver token: $error');
      return ''; // Return empty token if error
    }
  }

  // Fungsi untuk menampilkan dialog ketika menerima notifikasi baru
  void _showNewMessageDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'New Message'),
        content: Text(body ?? 'You have received a new message.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                final chatDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final chat = chatDocs[index];
                    final isCurrentUser = chat['senderId'] == FirebaseAuth.instance.currentUser!.uid;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue[200] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat['message'],
                                    style: TextStyle(
                                      color: isCurrentUser ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    chat['timestamp'] != null
                                        ? (chat['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[1]
                                        : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentUser ? Colors.white70 : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

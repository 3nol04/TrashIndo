import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _initializeLocalNotifications();
  }

  // Initialize Local Notifications
  void _initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Optimized Firebase Messaging Initialization
  void _initializeFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print("FCM Token: $token");
      }
    });
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Notification received: ${message.notification?.title}');
      print('Message: ${message.notification?.body}');
      _showNewMessagePopup(message.notification?.title, message.notification?.body);
    } else {
      print('Received message without notification');
    }
  }

  // Handle message when app is opened from background
  void _handleOpenedMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Notification clicked!');
      print('Message: ${message.notification?.body}');
      _showNewMessagePopup(message.notification?.title, message.notification?.body);
    } else {
      print('Opened message without notification');
    }
  }

  // Show popup notification
  Future<void> _showNewMessagePopup(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'message_channel', 
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'New Message',
      body ?? 'You have received a new message.',
      platformDetails,
      payload: 'message_payload',
    );
  }

  // Send message to Firestore
  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final roomId = widget.roomId;

      await FirebaseFirestore.instance.collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'message': _controller.text,
        'senderId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      String receiverToken = await _getReceiverToken(roomId);
      if (receiverToken.isNotEmpty) {
        await _sendNotificationToReceiver(roomId, _controller.text, receiverToken);
      }
      _controller.clear();
    }
  }

  // Send notification to the receiver
  Future<void> _sendNotificationToReceiver(String roomId, String message, String receiverToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://notif-six.vercel.app/send-notification'),
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

  // Get receiver token from Firestore
  Future<String> _getReceiverToken(String roomId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('chat_rooms')
          .doc(roomId)
          .get();
      final currentUser = doc.data();
      if (currentUser != null) {
        List<String> userIds = List<String>.from(currentUser['userIds']);
        print('User IDs in room: $userIds');
        final user = await FirebaseFirestore.instance.collection('users')
            .doc(userIds[0])  // Assuming the first user is the receiver
            .get();
        final receiverToken = user.data()?['tokenFCM'] as String?;
        if (receiverToken != null && receiverToken.isNotEmpty) {
          return receiverToken;
        }
      }
      return ''; // Token not found or document doesn't exist
    } catch (error) {
      print('Error fetching receiver token: $error');
      return ''; // Return empty token if error occurs
    }
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
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.blue[200]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat['message'],
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    chat['timestamp'] != null
                                        ? (chat['timestamp'] as Timestamp)
                                            .toDate()
                                            .toLocal()
                                            .toString()
                                            .split(' ')[1]
                                        : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrentUser
                                          ? Colors.white70
                                          : Colors.black45,
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

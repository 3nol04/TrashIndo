import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:trashindo/providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _initializeLocalNotifications();
  }

  // Firebase Messaging setup
  void _initializeFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print("FCM Token: $token");
      }
    });
  }

  // Local notifications setup
  void _initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Handle notification when the app is in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Notification received: ${message.notification?.title}');
      _showNewMessagePopup(
          message.notification?.title, message.notification?.body);
    } else {
      print('Received message without notification');
    }
  }

  // Handle notification when the app is in the background or terminated
  void _handleOpenedMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('Notification clicked!');
      _showNewMessagePopup(
          message.notification?.title, message.notification?.body);
    }
  }

  // Display local notification for new messages
  Future<void> _showNewMessagePopup(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'message_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  // Send message to Firestore
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'senderId': currentUser!.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    String receiverToken = await _getReceiverToken(widget.roomId);
    _sendNotificationToReceiver(widget.roomId, message, receiverToken);
    _messageController.clear();
    _scrollToBottom();
  }

  // Scroll to the bottom of the messages list
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Send notification to receiver
  Future<void> _sendNotificationToReceiver(
      String roomId, String message, String receiverToken) async {
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
      final doc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .get();
      final currentUser = doc.data();
      if (currentUser != null) {
        List<String> userIds = List<String>.from(currentUser['userIds']);
        print('User IDs in room: $userIds');
        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(userIds[0])
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

  // Format timestamp to a readable time
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Build message widget
  Widget _buildMessage(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;


    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isMe ? Colors.green[600] : Colors.grey[800],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              data['message'] ?? '',
              style: TextStyle(
                color : Colors.white

              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(data['timestamp']),
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    if (index == messages.length - 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    }
                    return _buildMessage(messages[index]);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Message input widget
  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: const Color(0xff1c1c1e),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xff2c2c2e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
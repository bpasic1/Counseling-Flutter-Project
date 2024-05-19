import 'package:counseling_flutter_app/widgets/message_chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /* @override
  void initState() {
    super.initState();
    _saveFcmToken();
    _configureFcm();
  }

  void _saveFcmToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
        });
      }
    }
  }

  void _configureFcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.messageId}');
      // Handle foreground message
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Handle notification tapped logic here
    });
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(chatId: widget.chatId),
          ),
          SendMessageForm(chatId: widget.chatId),
        ],
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final String chatId;

  const MessageList({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final messages = snapshot.data!.docs;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final messageData =
                  messages[index].data() as Map<String, dynamic>;
              final message = messageData['message'];
              final senderId = messageData['senderId'];
              final isExpertMessage =
                  senderId != FirebaseAuth.instance.currentUser!.uid;

              // Check if this message is the last or it's from a different sender
              final bool isFirstMessage = index == messages.length - 1 ||
                  messageData['senderId'] !=
                      (messages[index + 1].data()
                          as Map<String, dynamic>)['senderId'];

              final bool isLastMessage = index == 0 ||
                  messageData['senderId'] !=
                      (messages[index - 1].data()
                          as Map<String, dynamic>)['senderId'];

              final bool isNewUser = index > 0 &&
                  messageData['senderId'] !=
                      (messages[index - 1].data()
                          as Map<String, dynamic>)['senderId'];

              return MessageBubble(
                message: message,
                senderId: senderId,
                isExpertMessage: isExpertMessage,
                isFirstMessageInRow: isFirstMessage,
                displayProfileIcon: isLastMessage || isNewUser,
              );
            },
          );
        }
      },
    );
  }
}

class SendMessageForm extends StatefulWidget {
  final String chatId;

  const SendMessageForm({super.key, required this.chatId});

  @override
  State<SendMessageForm> createState() => _SendMessageFormState();
}

class _SendMessageFormState extends State<SendMessageForm> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () {
              _sendMessage();
            },
            icon: Icon(
              Icons.send,
              color: Colors.blue[400],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final senderId = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now();
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'message': message,
        'senderId': senderId,
        'timestamp': timestamp,
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

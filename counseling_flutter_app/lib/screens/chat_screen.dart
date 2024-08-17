import 'package:counseling_flutter_app/widgets/message_chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatPartnerName;
  String? chatPartnerUsername;

  @override
  void initState() {
    super.initState();
    _getChatPartnerName();
  }

  Future<void> _getChatPartnerName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final conversationDoc = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .get();

    final expertId = conversationDoc['expert_id'];
    final userId = conversationDoc['user_id'];

    final chatPartnerId = uid == expertId ? userId : expertId;

    final chatPartnerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(chatPartnerId)
        .get();

    setState(() {
      chatPartnerName =
          '${chatPartnerDoc['firstName']} ${chatPartnerDoc['lastName']}';
      chatPartnerUsername = chatPartnerDoc['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatPartnerName ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '@$chatPartnerUsername',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
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
              final message = messageData['message'] ?? '';
              final imageUrl = messageData['imageUrl'];
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
                imageUrl: imageUrl,
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

  Future<void> _sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        String username = userDoc['username'] ?? 'user';
        String imageFileName = '${username}_$fileName';

        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('chat_images/$imageFileName')
            .putFile(file);

        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Send the image URL in the message
        final senderId = FirebaseAuth.instance.currentUser!.uid;
        final timestamp = DateTime.now();
        FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.chatId)
            .collection('messages')
            .add({
          'imageUrl': downloadUrl,
          'senderId': senderId,
          'timestamp': timestamp,
        });

        // Log the event for analytics
        FirebaseAnalytics.instance.logEvent(
          name: 'image_sent',
          parameters: {
            'image_url': downloadUrl,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _sendImage,
            icon: Icon(
              Icons.image,
              color: Colors.blue[400],
            ),
          ),
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

      FirebaseAnalytics.instance.logEvent(
        name: 'message_sent',
        parameters: {
          'message_length': message.length,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

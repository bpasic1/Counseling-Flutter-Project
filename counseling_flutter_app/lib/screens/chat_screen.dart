import 'package:counseling_flutter_app/widgets/message_chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(chatId: chatId),
          ),
          SendMessageForm(chatId: chatId),
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
    String? _previousSenderId;
    bool _isFirstMessageInRow = true;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
              final isFirstMessageInRow =
                  _isFirstMessageInRow || senderId != _previousSenderId;
              _previousSenderId = senderId;
              _isFirstMessageInRow = isFirstMessageInRow;
              return MessageBubble(
                message: message,
                senderId: senderId,
                isExpertMessage: isExpertMessage,
                isFirstMessageInRow: isFirstMessageInRow,
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
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              _sendMessage();
            },
            child: Text('Send'),
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

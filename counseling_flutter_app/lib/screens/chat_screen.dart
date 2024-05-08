import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String chatTitle;

  ChatScreen({required this.chatTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatTitle),
      ),
      body: Center(
        child: Text('Chat with $chatTitle'),
      ),
    );
  }
}

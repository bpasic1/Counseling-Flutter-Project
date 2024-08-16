import 'package:counseling_flutter_app/widgets/single_chat_tab.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade100,
        title: const Text('Chats'),
      ),
      body: const SingleChatTab(),
    );
  }
}

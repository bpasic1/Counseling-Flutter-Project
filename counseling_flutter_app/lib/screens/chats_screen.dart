import 'package:counseling_flutter_app/widgets/group_chat_tab.dart';
import 'package:counseling_flutter_app/widgets/single_chat_tab.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Single Chats'),
              Tab(text: 'Group Chats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChatTab(),
            GroupChatTab(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:counseling_flutter_app/screens/chat_screen.dart';
import 'package:counseling_flutter_app/screens/select_expert_screen.dart';
import 'package:counseling_flutter_app/widgets/expert_chat_list.dart';

class SingleChatTab extends StatefulWidget {
  const SingleChatTab({Key? key}) : super(key: key);

  @override
  State<SingleChatTab> createState() => _SingleChatTabState();
}

class _SingleChatTabState extends State<SingleChatTab> {
  List<String> expertChats = [
    'Expert Chat 1',
    'Expert Chat 2',
    'Expert Chat 3'
  ];

  void addChat(String chat) {
    setState(() {
      expertChats.add(chat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: expertChats.isEmpty
          ? Center(
              child: Text('No messages found.'),
            )
          : ExpertChatList(expertChats: expertChats),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedExpert = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SelectExpertScreen(selectedExperts: expertChats),
            ),
          );
          if (selectedExpert != null) {
            addChat(selectedExpert);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatTitle: selectedExpert,
                ),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

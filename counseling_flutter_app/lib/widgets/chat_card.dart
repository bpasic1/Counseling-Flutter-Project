import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
            Icons.account_circle_rounded), // Icon or image before the chat name
        title: Text(name),
        onTap: onTap,
      ),
    );
  }
}

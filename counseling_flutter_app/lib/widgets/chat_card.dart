import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onDeletePressed; // Add this line
  final bool isDeleting; // Add this line

  const ChatCard({
    Key? key,
    required this.name,
    required this.onTap,
    required this.onDeletePressed, // Add this line
    required this.isDeleting, // Add this line
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
        trailing: isDeleting
            ? CircularProgressIndicator() // Show loading indicator if deleting
            : IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Chat"),
          content: Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeletePressed();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onDeletePressed;
  final bool isDeleting;

  const ChatCard({
    Key? key,
    required this.name,
    required this.onTap,
    required this.onDeletePressed,
    required this.isDeleting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue.shade100,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.account_circle_rounded),
        title: Text(name),
        onTap: onTap,
        trailing: isDeleting
            ? const CircularProgressIndicator()
            : IconButton(
                icon: const Icon(Icons.delete),
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
          title: const Text("Delete Chat"),
          content: const Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeletePressed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

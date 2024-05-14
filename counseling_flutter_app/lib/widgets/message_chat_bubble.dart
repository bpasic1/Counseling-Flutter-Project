import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderId;
  final bool isExpertMessage;
  final bool isFirstMessageInRow;
  final bool displayProfileIcon;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.senderId,
    required this.isExpertMessage,
    required this.isFirstMessageInRow,
    required this.displayProfileIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(senderId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('User not found');
        }

        String username = snapshot.data!['username'];

        return Column(
          crossAxisAlignment: isExpertMessage
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (isFirstMessageInRow)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                child: Text(
                  username, // Display the username instead of senderId
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              mainAxisAlignment: isExpertMessage
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpertMessage) ...[
                  if (displayProfileIcon)
                    // Display the icon to the left of the user/expert you are talking to
                    Padding(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: SizedBox(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.account_circle_rounded),
                        ),
                      ),
                    ),
                ],
                Flexible(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isExpertMessage
                          ? (displayProfileIcon
                              ? 0.0
                              : 32.0) // Expert with or without icon
                          : (displayProfileIcon
                              ? 0.0
                              : 32.0), // Non-expert with or without icon
                    ),
                    child: Card(
                      color: isExpertMessage
                          ? Colors.blue[100]
                          : Colors.green[100],
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(message),
                      ),
                    ),
                  ),
                ),
                if (!isExpertMessage) ...[
                  if (displayProfileIcon)
                    // Display the icon to the right of the current user's messages
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: SizedBox(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.account_circle_rounded),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

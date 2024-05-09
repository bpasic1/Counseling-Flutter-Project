import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderId;
  final bool isExpertMessage;
  final bool isFirstMessageInRow;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.senderId,
    required this.isExpertMessage,
    required this.isFirstMessageInRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isExpertMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        if (isFirstMessageInRow)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              senderId,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        Row(
          mainAxisAlignment:
              isExpertMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isExpertMessage) ...[
              // Display the icon to the left of the user/expert you are talking to
              Padding(
                child: Icon(Icons.person),
                padding: const EdgeInsets.only(right: 8.0),
              ),
            ],
            Flexible(
              child: Card(
                color: isExpertMessage ? Colors.blue[100] : Colors.green[100],
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(message),
                ),
              ),
            ),
            if (!isExpertMessage) ...[
              // Display the icon to the right of the current user's messages
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.person),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

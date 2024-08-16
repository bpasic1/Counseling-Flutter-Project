import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String? imageUrl;
  final String senderId;
  final bool isExpertMessage;
  final bool isFirstMessageInRow;
  final bool displayProfileIcon;

  const MessageBubble({
    Key? key,
    required this.message,
    this.imageUrl,
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
          return const Text('User not found');
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
              ),
            Row(
              mainAxisAlignment: isExpertMessage
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpertMessage) ...[
                  if (displayProfileIcon)
                    const Padding(
                      padding: EdgeInsets.only(right: 0.0),
                      child: SizedBox(
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.account_circle_rounded,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                ],
                Flexible(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isExpertMessage
                          ? (displayProfileIcon ? 0.0 : 32.0)
                          : (displayProfileIcon ? 0.0 : 32.0),
                    ),
                    child: Card(
                      color:
                          isExpertMessage ? Colors.blue[100] : Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerScreen(
                                          imageUrl: imageUrl!),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  imageUrl!,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (message.isNotEmpty) Text(message),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isExpertMessage) ...[
                  if (displayProfileIcon)
                    const Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: SizedBox(
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.account_circle_rounded,
                            color: Colors.grey,
                          ),
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

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

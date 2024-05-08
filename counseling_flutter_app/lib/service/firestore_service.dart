import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startConversation(String userId, String expertId) async {
    try {
      // Create a new conversation document
      final conversationDocRef = _firestore.collection('conversations').doc();

      // Add metadata to the conversation document
      await conversationDocRef.set({
        'user_id': userId,
        'expert_id': expertId,
        // Add any additional metadata here
      });

      // Create a new messages subcollection within the conversation document
      final messagesCollectionRef = conversationDocRef.collection('messages');

      // You can add an initial message here if needed

      print('Conversation started successfully');
    } catch (e) {
      print('Error starting conversation: $e');
      // Handle error
    }
  }
}

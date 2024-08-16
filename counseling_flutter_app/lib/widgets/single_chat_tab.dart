import 'package:counseling_flutter_app/screens/select_category_screen.dart';
import 'package:counseling_flutter_app/widgets/chat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:counseling_flutter_app/screens/chat_screen.dart';
import 'package:counseling_flutter_app/screens/select_expert_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SingleChatTab extends StatefulWidget {
  const SingleChatTab({Key? key}) : super(key: key);

  @override
  State<SingleChatTab> createState() => _SingleChatTabState();
}

class _SingleChatTabState extends State<SingleChatTab> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showFloatingButton = false;
  bool _isDeleting = false;
  String _deleteMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void refreshUI() {
    setState(() {
      _fetchChats();
    });
  }

  Future<void> _fetchUserRole() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userRole = userDoc.get('role');
      setState(() {
        _showFloatingButton = userRole == 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      key: _scaffoldKey,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> chats = snapshot.data ?? [];
            return chats.isEmpty
                ? const Center(child: Text('No messages found.'))
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return ChatCard(
                        name: chats[index]['category'] != 'null'
                            ? '${chats[index]['name']} - ${chats[index]['category']}'
                            : chats[index]['name'],
                        onTap: () {
                          _startConversation(
                            selectedExpertName: chats[index]['name'],
                            documentId: chats[index]['document_id'],
                          );
                        },
                        onDeletePressed: () {
                          _deleteChat(chats[index]['document_id']);
                        },
                        isDeleting: _isDeleting,
                      );
                    },
                  );
          }
        },
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _handleFloatingActionButtonPressed,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _handleFloatingActionButtonPressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> chats = await _fetchChats().first;
      final List<String> existingChatIds =
          chats.map((chat) => chat['id'] as String).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectCategoryScreen(
            existingChats: existingChatIds,
            refreshUI: refreshUI,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchChats() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      return FirebaseFirestore.instance
          .collection('conversations')
          .where('user_id', isEqualTo: userId)
          .get()
          .then((userConversations) async {
        return FirebaseFirestore.instance
            .collection('conversations')
            .where('expert_id', isEqualTo: userId)
            .get()
            .then((expertConversations) async {
          final chats = <Map<String, dynamic>>[];
          final conversationIds = <String>{};
          for (final doc in userConversations.docs) {
            final data = doc.data();
            final documentId = doc.id;
            final conversationId = '${data['user_id']}-${data['expert_id']}';
            if (!conversationIds.contains(conversationId)) {
              final expertId = data['expert_id'];
              final expertData = await _getUserDetails(expertId);
              final expertName =
                  '${expertData['firstName']} ${expertData['lastName']}';
              final expertExpertise = '${expertData['category']}';
              chats.add({
                'name': expertName,
                'id': expertId,
                'category': expertExpertise,
                'document_id': documentId
              });
              conversationIds.add(conversationId);
            }
          }
          for (final doc in expertConversations.docs) {
            final data = doc.data();
            final documentId = doc.id;
            final conversationId = '${data['user_id']}-${data['expert_id']}';
            if (!conversationIds.contains(conversationId)) {
              final expertId = data[
                  'user_id']; // Reverse as we're now getting user_id for expert
              final expertData = await _getUserDetails(expertId);
              final expertName =
                  '${expertData['firstName']} ${expertData['lastName']}';
              final expertExpertise = '${expertData['category']}';
              chats.add({
                'name': expertName,
                'category': expertExpertise,
                'id': expertId,
                'document_id': documentId
              });
              conversationIds.add(conversationId);
            }
          }
          return chats;
        });
      }).asStream();
    }
    return Stream.value([]);
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  void _startConversation({
    String? selectedExpertName,
    String? selectedExpertId,
    required String documentId,
    //required String username,
  }) async {
    // Navigate to the chat screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: documentId,

          //chatId: selectedExpertId,
        ),
      ),
    );
  }

  void _deleteChat(String documentId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(documentId)
          .delete();
      setState(() {
        _deleteMessage = 'Chat deleted successfully';
      });
    } catch (e) {
      setState(() {
        _deleteMessage = 'Failed to delete chat: $e';
      });
    } finally {
      setState(() {
        _isDeleting = false;
      });

      // Show snackbar with deletion result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_deleteMessage),
        ),
      );
    }
  }
}

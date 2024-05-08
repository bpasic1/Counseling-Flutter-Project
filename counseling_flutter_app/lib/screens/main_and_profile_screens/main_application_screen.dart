import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counseling_flutter_app/screens/chats_screen.dart';
import 'package:counseling_flutter_app/screens/main_and_profile_screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainApplicationScreen extends StatefulWidget {
  final bool isNewUser;

  const MainApplicationScreen({Key? key, required this.isNewUser})
      : super(key: key);

  @override
  State<MainApplicationScreen> createState() => _MainApplicationScreenState();
}

class _MainApplicationScreenState extends State<MainApplicationScreen> {
  late String username = '';
  late String email = '';
  late String firstName = '';
  late String lastName = '';
  bool isLoading = true;

  late Stream<DocumentSnapshot> userDataStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    userDataStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Advice Haven'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User data not found');
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              username = userData['username'] ?? '';
              email = userData['email'];
              firstName = userData['firstName'];
              lastName = userData['lastName'];
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(username),
                    accountEmail: Text(email),
                    currentAccountPicture: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            username: username,
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Chats'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              widget.isNewUser ? 'Welcome, new user!' : 'Welcome back!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

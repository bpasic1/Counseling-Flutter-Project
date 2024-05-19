import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counseling_flutter_app/screens/become_expert_screen.dart';
import 'package:counseling_flutter_app/screens/chats_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:counseling_flutter_app/screens/main_and_profile_screens/profile_screen.dart';
import 'package:counseling_flutter_app/screens/request_screen.dart';
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
  late String role = '';
  bool isLoading = true;

  late Stream<DocumentSnapshot> userDataStream;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    userDataStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();

    requestNotificationPermissions();
  }

  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await messaging.getToken();
      if (token != null) {
        await saveTokenToDatabase(token);
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> saveTokenToDatabase(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        //if (userData['role'] == 'administrator') {
        if (userData['role'] == 'user' ||
            userData['role'] == 'expert' ||
            userData['role'] == 'administrator') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'fcmToken': token,
          });
        }
      }
    }
  }

  Future<void> removeTokenFromDatabase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': FieldValue.delete(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Advice Haven'),
        actions: [
          IconButton(
            onPressed: () async {
              await removeTokenFromDatabase();
              await FirebaseAuth.instance.signOut();
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
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('User data not found');
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              username = userData['username'] ?? '';
              email = userData['email'];
              firstName = userData['firstName'];
              lastName = userData['lastName'];
              role = userData['role'] ?? 'user';
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
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: const Text('Profile'),
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
                  if (role == 'user' || role == 'expert') ...[
                    ListTile(
                      title: const Text('Chats'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  if (role == 'user') ...[
                    ListTile(
                      title: const Text('Become an Expert'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BecomeExpertScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  if (role == 'administrator') ...[
                    ListTile(
                      title: const Text('Requests'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RequestsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/counsle3.png', // Add your image asset here
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Advice Haven!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'We are here to provide you with support and guidance '
                'through your journey!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

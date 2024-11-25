
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

import 'userProfilePage.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Fetch the current user ID when the screen initializes
  }

  void _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Set the current user ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 111, 40),
        centerTitle: true,
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No users available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          var userDocs = snapshot.data!.docs;

          userDocs.sort((a, b) {
            var dataA = a.data() as Map<String, dynamic>;
            var dataB = b.data() as Map<String, dynamic>;

            List? followersA =
                dataA.containsKey('followers') ? dataA['followers'] : [];
            List? followersB =
                dataB.containsKey('followers') ? dataB['followers'] : [];

            int followersCountA = followersA?.length ?? 0;
            int followersCountB = followersB?.length ?? 0;

            return followersCountB.compareTo(followersCountA);
          });

          var top5Users = userDocs.take(10).toList();

          return ListView.builder(
            itemCount: top5Users.length,
            itemBuilder: (context, index) {
              var user = top5Users[index];
              var data = user.data() as Map<String, dynamic>;

              String uid = user.id;
              String username = data['name'] ?? 'Unknown';
              String email = data['email'] ?? 'No Email';
              String imageUrl = data['imageUrl'] ?? 'default_image_url';

              int followersCount =
                  (data['followers'] is List ? data['followers'] as List : [])
                      .length;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? const Color.fromARGB(255, 90, 89, 89)
                        : Color.fromARGB(255, 50, 162, 54),
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 8, 130, 79)
                            .withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(
                            userId: uid,
                            username: username,
                            userEmail: email,
                            currentUserId: currentUserId ?? 'Unknown',
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${index + 1} ]',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(imageUrl),
                              radius: 20,
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 175,
                              child: Text(
                                username,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              "$followersCount",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/postdetails.dart';
import 'package:project/setting.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  String? imageUrl;
  bool isLoading = true;
  int followersCount = 0;
  int followingCount = 0;
  int totalPosts = 0;
  String userName = '';
  String userBio = '';
  List<String> postImages = [];
  List<String> postIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      fetchUserProfileImage(),
      fetchUserProfile(),
      fetchFollowersAndFollowing(),
      fetchTotalPosts(),
      fetchPostImages(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshPage() async {
    await _loadData();
  }

  Future<void> fetchUserProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docData = snapshot.docs.first.data();
        setState(() {
          imageUrl = docData['imageUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          userName = docSnapshot.data()?['name'] ?? 'User not found';
          userBio = docSnapshot.data()?['bio'] ?? 'No bio added';
        });
      } else {
        setState(() {
          userName = 'User not found';
          userBio = 'No bio added';
        });
      }
    }
  }

  Future<void> fetchFollowersAndFollowing() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          final followersList = List<String>.from(userData['followers'] ?? []);
          final followingList = List<String>.from(userData['following'] ?? []);

          setState(() {
            followersCount = followersList.length;
            followingCount = followingList.length;
          });
        }
      } catch (e) {
        print("Error fetching followers and following: $e");
      }
    }
  }

  Future<void> fetchTotalPosts() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('userEmail', isEqualTo: currentUser.email)
            .get();

        setState(() {
          totalPosts = snapshot.size;
        });
      } catch (e) {
        print("Error fetching total posts: $e");
      }
    }
  }

  Future<void> fetchPostImages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('userEmail', isEqualTo: currentUser.email)
            .get();

        setState(() {
          postImages = snapshot.docs
              .map((doc) => doc.data()['imageURL'] as String)
              .toList();

          postIds = snapshot.docs.map((doc) => doc.id).toList();
        });
      } catch (e) {
        print("Error fetching post images: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 210,
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(24, 81, 27, 1),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(90),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProfileStat("Post", totalPosts),
                          _buildProfileStat("Followers", followersCount),
                          _buildProfileStat("Following", followingCount),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 90,
                      left: 30,
                      child: Container(
                        height: 110,
                        width: 110,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.transparent
                              : Colors.amber,
                          border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? const Color.fromARGB(255, 18, 18, 18)
                                  : Colors.white,
                              width: 6),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "assets/Default_pfp.svg.png",
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 125,
                      left: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            userBio,
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? const Color.fromARGB(255, 195, 194, 194)
                                  : Colors.black54,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
                child: Container(
                  height: 38,
                  width: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(24, 81, 27, 1),
                  ),
                  child: const Center(
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Post",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    SizedBox(width: 15),
                    Icon(Icons.grid_view),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 3),
              postImages.isEmpty
                  ? const Text("No posts available")
                  : Container(
                      height: 470,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: postImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetails(
                                    postId: postIds[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 110,
                              width: 150,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.isDarkMode
                                        ? const Color.fromARGB(255, 40, 40, 40)
                                        : Colors.grey,
                                    spreadRadius: 3,
                                    blurRadius: 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                color: const Color.fromARGB(255, 236, 235, 232),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                postImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, int count) {
    return Container(
      height: 60,
      width: 100,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

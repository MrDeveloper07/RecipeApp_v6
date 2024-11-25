import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/postdetails.dart';
import 'package:project/theme_provider.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String username;
  final String currentUserId;

  const UserDetailsPage({
    required this.userId,
    required this.userEmail,
    required this.username,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkFollowingStatus();
  }

  Future<void> checkFollowingStatus() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      if (currentUserDoc.exists) {
        final following = currentUserDoc.data()?['following'] ?? [];
        setState(() {
          isFollowing = following.contains(widget.userId);
        });
      }
    } catch (e) {
      print('Error checking following status: $e');
    }
  }

  Future<void> toggleFollow() async {
    try {
      final currentUserRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);
      final targetUserRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      if (isFollowing) {
        // Unfollow logic
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.userId]),
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayRemove([widget.currentUserId]),
        });
      } else {
        // Follow logic
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([widget.userId]),
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayUnion([widget.currentUserId]),
        });
      }

      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      print('Error updating follow status: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data()!;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return {};
  }

  Future<int> fetchUserPostCount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userEmail', isEqualTo: widget.userEmail)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error fetching user posts: $e');
    }
    return 0;
  }

  Widget buildFuturePostCountWidget(Future<int> future) {
    return FutureBuilder<int>(
      future: future,
      builder: (context, postCountSnapshot) {
        if (postCountSnapshot.connectionState == ConnectionState.waiting) {
          return const Text('NA');
        }
        if (!postCountSnapshot.hasData || postCountSnapshot.hasError) {
          return const Text('NA');
        }
        return Text(
          '${postCountSnapshot.data}',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchUserPosts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userEmail', isEqualTo: widget.userEmail)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'postId': doc.id // Add the postId to the data
              })
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(24, 81, 27, 1),
        title: Text(
          widget.username,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData) {
            return const Center(child: Text('Error fetching user details'));
          }

          final userData = userSnapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 210,
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(24, 81, 27, 1),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(90))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 60,
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "Post",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                                buildFuturePostCountWidget(
                                    fetchUserPostCount()),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "Followers",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                                Text(
                                  "${userData['followers']?.length ?? 0}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "Following",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                                Text(
                                  "${userData['following']?.length ?? 0}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          )
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
                              borderRadius: BorderRadius.circular(60)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: userData['imageUrl'] != null &&
                                    userData['imageUrl']!.isNotEmpty
                                ? Image.network(
                                    userData['imageUrl']!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/Default_pfp.svg.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )),
                    Positioned(
                        top: 125,
                        left: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.username,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            SingleChildScrollView(
                              child: SizedBox(
                                width: 280,
                                height: 80,
                                child: Text(
                                  userData['bio'],
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? const Color.fromARGB(
                                              255, 195, 194, 194)
                                          : Colors.black54,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              SizedBox(height: 4),
              if (widget.currentUserId != widget.userId)
                GestureDetector(
                  onTap: toggleFollow,
                  child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isFollowing
                            ? themeProvider.isDarkMode
                                ? const Color.fromARGB(255, 187, 186, 186)
                                : Colors.white
                            : Color.fromARGB(255, 42, 109, 44),
                        boxShadow: [
                          BoxShadow(
                              color: themeProvider.isDarkMode
                                  ? const Color.fromARGB(255, 67, 66, 66)
                                  : const Color.fromARGB(255, 213, 212, 212),
                              offset: const Offset(2.0, 2.0),
                              blurRadius: 10,
                              spreadRadius: 0.2),
                          BoxShadow(
                              color: themeProvider.isDarkMode
                                  ? const Color.fromARGB(255, 67, 66, 66)
                                  : const Color.fromARGB(255, 213, 212, 212),
                              offset: const Offset(-2.0, -2.0),
                              blurRadius: 10,
                              spreadRadius: 0.2)
                        ]),
                    child: Center(
                      child: Text(
                        isFollowing ? "Following" : "Follow",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: isFollowing
                              ? Color.fromARGB(255, 42, 109, 44)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Post",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(Icons.grid_view)
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchUserPosts(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!postsSnapshot.hasData || postsSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts found'));
                    }

                    final posts = postsSnapshot.data!;
                    return GridView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 9.0,
                        mainAxisSpacing: 9.0,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return GestureDetector(
                          onTap: () {
                           
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetails(
                                    postId: post['postId']), 
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
                                      ? const Color.fromARGB(255, 53, 53, 53)
                                      : Colors.grey,
                                  spreadRadius: 3,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.network(
                              post['imageURL'] ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/theme_provider.dart';
import 'package:provider/provider.dart';

class PostDetails extends StatefulWidget {
  final String postId;

  const PostDetails({required this.postId, Key? key}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  late String postOwnerId;
  late String postOwnerEmail;
  late String postOwnerUsername;
  late String userImageUrl;
  bool isFollowing = false;
  bool isLoading = true;
  String currentUserUid = '';

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchPostData();
  }

  Future<void> fetchPostData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (docSnapshot.exists) {
        final postData = docSnapshot.data() as Map<String, dynamic>;
        postOwnerId = postData['uid'];
        postOwnerEmail = postData['userEmail'];
        postOwnerUsername = postData['username'];
        await fetchUserImage(postData['userEmail']);
        await checkIfFollowing(postOwnerId);
      }
    } catch (e) {
      print('Error fetching post data: $e');
    }
  }

  Future<void> fetchUserImage(String userEmail) async {
    if (userEmail.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first.data();
          setState(() {
            userImageUrl = userDoc['imageUrl'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            userImageUrl = '';
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user image: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkIfFollowing(String userId) async {
    if (currentUserUid.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();

        if (userDoc.exists) {
          final followingList = List<String>.from(userDoc['following'] ?? []);
          setState(() {
            isFollowing = followingList.contains(userId);
          });
        }
      } catch (e) {
        print('Error checking following status: $e');
      }
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(targetUserId);

    if (isFollowing) {
      await userRef.update({
        'following': FieldValue.arrayRemove([targetUserId]),
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserUid]),
      });
    } else {
      await userRef.update({
        'following': FieldValue.arrayUnion([targetUserId]),
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserUid]),
      });
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  Future<Map<String, dynamic>?> fetchPostDetails() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();

    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
    return null;
  }

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchPostDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error loading post details'));
          }

          final postData = snapshot.data!;
          final ingredients = (postData['ingredients'] as List).cast<String>();
          final procedures = (postData['procedures'] as List).cast<String>();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
            child: ListView(
              children: [
                Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.transparent
                            : Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ], borderRadius: BorderRadius.circular(20)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      postData['imageURL'],
                      fit: BoxFit.cover,
                    )),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Text(
                    postData['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/dish-svgrepo-com.svg",
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            width: 18,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            " ${postData['category'] ?? 'N/A'}",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 139, 139, 139),
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "${postData['time']} min",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 139, 139, 139),
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    isLoading
                        ? const CircularProgressIndicator()
                        : CircleAvatar(
                            backgroundImage: userImageUrl.isNotEmpty
                                ? NetworkImage(userImageUrl)
                                : const AssetImage(
                                    'assets/default_profile.png'),
                            radius: 20,
                          ),
                    const SizedBox(width: 10),
                    Text(
                      postOwnerUsername,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    if (postOwnerId != currentUserUid)
                      GestureDetector(
                        onTap: () => toggleFollow(postOwnerId),
                        child: Container(
                          height: 33,
                          width: 85,
                          decoration: BoxDecoration(
                            color: !isFollowing
                                ? Colors.green[800]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              isFollowing ? "Following" : "Follow",
                              style: TextStyle(
                                color: !isFollowing
                                    ? Colors.white
                                    : Colors.green[800],
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
             
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child: Container(
                          width: 160,
                          child: Center(
                            child: Text(
                              "Ingridients",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: selectedIndex == 0
                                      ? Colors.white
                                      : Color.fromARGB(255, 42, 109, 44)),
                            ),
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: selectedIndex == 1
                                      ? Color.fromARGB(255, 42, 109, 44)
                                      : Colors.transparent,
                                  width: 2),
                              color: selectedIndex == 0
                                  ? Color.fromARGB(255, 42, 109, 44)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        child: Container(
                          width: 160,
                          child: Center(
                            child: Text(
                              "Procedure",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: selectedIndex == 0
                                      ? Color.fromARGB(255, 42, 109, 44)
                                      : Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: selectedIndex == 0
                                      ? Color.fromARGB(255, 42, 109, 44)
                                      : Colors.transparent,
                                  width: 2),
                              color: selectedIndex == 0
                                  ? Colors.white
                                  : Color.fromARGB(255, 42, 109, 44),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Container(
                  height: selectedIndex == 0 ? 500 : 800,
                  child: selectedIndex == 0
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.all(12),
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: themeProvider.isDarkMode
                                        ? const Color.fromARGB(255, 18, 53, 20)
                                        : Colors.green[200],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "[ ${index + 1} ]",
                                        style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 213, 212, 212)
                                                : Colors.black54,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(ingredients[index],
                                          style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? const Color.fromARGB(
                                                      255, 209, 207, 207)
                                                  : const Color.fromARGB(
                                                      255, 65, 64, 64),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          })
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: procedures.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? const Color.fromARGB(255, 18, 53, 20)
                                    : Colors.green[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Step ${index + 1}:",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(procedures[index],
                                      style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 65, 64, 64),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ],
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

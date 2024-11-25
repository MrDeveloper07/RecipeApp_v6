import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/postdetails.dart';
import 'package:project/setting.dart';
import 'package:project/theme_provider.dart';
import 'package:project/userProfilePage.dart';
import 'package:project/userprofilepost/postCommentScreen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String userName = '';
  String userBio = '';
  String userImageUrl = '';
  bool isLoading = true;
  String selectedCategory = 'All';
  String searchQuery = '';

  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final userDoc = snapshot.docs[0].data();
          setState(() {
            userName = userDoc['name'] ?? '';
            userBio = userDoc['bio'] ?? '';
            userImageUrl = userDoc['imageUrl'] ?? '';
            _nameController.text = userName;
            _bioController.text = userBio;
          });
        } else {
          setState(() {
            userImageUrl = '';
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
        setState(() {
          userImageUrl = '';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              const SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    "Notifications",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Your notifications will appear here."), // Dummy data
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? Color.fromARGB(255, 18, 18, 18)
          : const Color.fromARGB(255, 234, 234, 234),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello $userName',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What are you cooking today?',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: openBottomSheet,
                            icon: const Icon(Icons.notifications),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilePage()), // Add EditProfilePage
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : (userImageUrl.isNotEmpty
                                          ? NetworkImage(userImageUrl)
                                          : const AssetImage(
                                              'assets/default_profile.png'))
                                      as ImageProvider,
                              child: _image == null && userImageUrl.isEmpty
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search recipe',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          onChanged: (query) {
                            setState(() {
                              searchQuery = query;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            const Icon(Icons.filter_list, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryTab(
                          text: 'All',
                          isSelected: selectedCategory == 'All',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'All';
                            });
                          },
                        ),
                        CategoryTab(
                          text: 'Indian',
                          isSelected: selectedCategory == 'Indian',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'Indian';
                            });
                          },
                        ),
                        CategoryTab(
                          text: 'Italian',
                          isSelected: selectedCategory == 'Italian',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'Italian';
                            });
                          },
                        ),
                        CategoryTab(
                          text: 'Asian',
                          isSelected: selectedCategory == 'Asian',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'Asian';
                            });
                          },
                        ),
                        CategoryTab(
                          text: 'Chinese',
                          isSelected: selectedCategory == 'Chinese',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'Chinese';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'New Recipes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('time', descending: true)
                        .snapshots()
                        .map((snapshot) {
                      if (selectedCategory == 'All') {
                        return snapshot.docs;
                      } else {
                        return snapshot.docs
                            .where((doc) => doc['category'] == selectedCategory)
                            .toList();
                      }
                    }).map((docs) {
                      // Filter by search query
                      if (searchQuery.isNotEmpty) {
                        return docs
                            .where((doc) => (doc['title'] as String)
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()))
                            .toList();
                      }
                      return docs;
                    }),
                    builder: (context,
                        AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No recipes found.'));
                      }
                      return SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: PostCard(
                                  post: post), // Define PostCard widget
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Food Feed",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('time', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No recipes found.'));
                      }

                      return SizedBox(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];
                            return MostLikeCard(post: post);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 90,
                  )
                ],
              ),
            ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTab({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[900] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final QueryDocumentSnapshot post;

  const PostCard({required this.post, super.key});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;
  late String postId;

  @override
  void initState() {
    super.initState();
    final postData = widget.post.data() as Map<String, dynamic>;
    final likes = postData['likes'] != null
        ? List<String>.from(postData['likes'])
        : <String>[];
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    isLiked = currentUserUid != null && likes.contains(currentUserUid);
    likeCount = likes.length;
    postId = widget.post.id;
  }

  void toggleLike() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserUid]),
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserUid]),
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final postData = widget.post.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetails(postId: postId),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            width: 180,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 250,
                width: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomCenter,
                    colors: themeProvider.isDarkMode
                        ? [
                            const Color.fromARGB(255, 223, 221, 221),
                            const Color.fromARGB(255, 80, 77, 77)
                          ]
                        : [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 110),
                    SizedBox(
                      height: 80,
                      child: Text(
                        postData['title'] ?? 'No Title',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${postData['time'] ?? 'N/A'} mins',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: toggleLike,
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              '$likeCount',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -40,
                left: 12,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75),
                    child: Image.network(
                      postData['imageURL'] ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MostLikeCard extends StatefulWidget {
  final QueryDocumentSnapshot post;

  const MostLikeCard({required this.post, super.key});

  @override
  _MostLikeCardState createState() => _MostLikeCardState();
}

class _MostLikeCardState extends State<MostLikeCard> {
  late bool isLiked;
  late int likeCount;
  late String postId;
  String userImageUrl = '';
  bool isLoading = true;
  bool isFollowing = false;
  String currentUserUid = '';
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    final postData = widget.post.data() as Map<String, dynamic>;
    final likes = postData['likes'] != null
        ? List<String>.from(postData['likes'])
        : <String>[];
    final Timestamp? createdAt = postData['timestamp'] as Timestamp?;
    String elapsedTime = 'Just now';
    if (createdAt != null) {
      elapsedTime = timeago.format(createdAt.toDate());
    }
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    isLiked = currentUserUid != null && likes.contains(currentUserUid);
    likeCount = likes.length;
    postId = widget.post.id;

    fetchUserImage(postData['userEmail']);
    checkIfFollowing(postData['uid'], postData['userEmail']);
    checkIfBookmarked();
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
          if (mounted) {
            setState(() {
              userImageUrl = userDoc['imageUrl'] ?? '';
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              userImageUrl = '';
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print('Error fetching user image: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> checkIfFollowing(String userId, String userEmail) async {
    if (currentUserUid.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();

        if (userDoc.exists) {
          final followingList = List<String>.from(userDoc['following'] ?? []);
          if (mounted) {
            setState(() {
              isFollowing = followingList.contains(userId);
            });
          }
        }
      } catch (e) {
        print('Error checking following status: $e');
      }
    }
  }

  Future<void> toggleFollow(String targetUserId, String targetUserEmail) async {
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

    if (mounted) {
      setState(() {
        isFollowing = !isFollowing;
      });
    }
  }

  void toggleLike() async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserUid]),
      });
      if (mounted) {
        setState(() {
          isLiked = false;
          likeCount--;
        });
      }
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserUid]),
      });
      if (mounted) {
        setState(() {
          isLiked = true;
          likeCount++;
        });
      }
    }
  }

  Future<void> checkIfBookmarked() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        final bookmarkedPosts = List<String>.from(userDoc['bookmarks'] ?? []);
        if (mounted) {
          setState(() {
            isBookmarked = bookmarkedPosts.contains(postId);
          });
        }
      }
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> toggleBookmark() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserUid);

    if (isBookmarked) {
      await userRef.update({
        'bookmarks': FieldValue.arrayRemove([postId]),
      });
    } else {
      await userRef.update({
        'bookmarks': FieldValue.arrayUnion([postId]),
      });
    }

    if (mounted) {
      setState(() {
        isBookmarked = !isBookmarked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final postData = widget.post.data() as Map<String, dynamic>;
    final postOwnerId = postData['uid'];
    final postOwnerEmail = postData['userEmail'];
    final Timestamp? createdAt = postData['timestamp'] as Timestamp?;

    String elapsedTime = 'Just now';
    if (createdAt != null) {
      elapsedTime = timeago.format(createdAt.toDate());
    }

    return Container(
      height: 450,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Color.fromARGB(255, 49, 49, 49)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                isLoading
                    ? const CircularProgressIndicator()
                    : CircleAvatar(
                        backgroundImage: userImageUrl.isNotEmpty
                            ? NetworkImage(userImageUrl) as ImageProvider
                            : const AssetImage('assets/default_profile.png'),
                        radius: 20,
                      ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailsPage(
                          userId: postData['uid'],
                          userEmail: postData['userEmail'],
                          username: postData['username'] ?? 'User',
                          currentUserId: currentUserUid,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    postData['username'] ?? 'User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Color.fromARGB(255, 13, 13, 13),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                if (postOwnerId != currentUserUid)
                  GestureDetector(
                    onTap: () => toggleFollow(postOwnerId, postOwnerEmail),
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
                            color:
                                !isFollowing ? Colors.white : Colors.green[800],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 2,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetails(postId: postId),
                ),
              );
            },
            onDoubleTap: toggleLike,
            child: Image.network(
              postData['imageURL'] ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? Colors.red
                        : themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentSection(postId: postId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                ),
                const Spacer(),
                IconButton(
                  onPressed: toggleBookmark,
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isBookmarked
                        ? const Color.fromARGB(255, 27, 85, 29)
                        : themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$likeCount likes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              elapsedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

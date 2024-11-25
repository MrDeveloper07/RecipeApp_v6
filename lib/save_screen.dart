import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/postdetails.dart';
import 'package:project/theme_provider.dart';
import 'package:project/userProfilePage.dart';
import 'package:project/userprofilepost/postCommentScreen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SavedRecipes extends StatefulWidget {
  const SavedRecipes({super.key});

  @override
  State<SavedRecipes> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedRecipes> {
  late String currentUserUid;
  bool isLoading = true;
  List<DocumentSnapshot> bookmarkedPosts = [];

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchBookmarkedPosts();
  }

  Future<void> fetchBookmarkedPosts() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();
      if (userDoc.exists) {
        final bookmarkedPostIds = List<String>.from(userDoc['bookmarks'] ?? []);

        if (bookmarkedPostIds.isNotEmpty) {
        
          final querySnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .where(FieldPath.documentId, whereIn: bookmarkedPostIds)
              .get();

          setState(() {
            bookmarkedPosts = querySnapshot.docs;
          });
        }
      }
    } catch (e) {
      print('Error fetching bookmarked posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getUserProfileImage(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['imageUrl'] ?? '';
      }
    } catch (e) {
      print('Error fetching user profile image: $e');
    }
    return '';
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      final postDocRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postDocRef.get();

      if (postDoc.exists) {
        List<dynamic> likes = List.from(postDoc['likes'] ?? []);
        if (isLiked) {
          likes.remove(currentUserUid);
        } else {
          likes.add(currentUserUid);
        }
        await postDocRef.update({'likes': likes});
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> removeFromBookmarks(String postId) async {
    try {
    
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserUid);
      await userDocRef.update({
        'bookmarks': FieldValue.arrayRemove([postId]),
      });

  
      setState(() {
        bookmarkedPosts.removeWhere((post) => post.id == postId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe removed from bookmarks')),
      );
    } catch (e) {
      print('Error removing post from bookmarks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove recipe from bookmarks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 32, 94, 35),
        title: const Text(
          'Saved Recipes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await fetchBookmarkedPosts();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookmarkedPosts.isEmpty
                ? const Center(child: Text('No saved recipes yet!'))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          physics:
                              const NeverScrollableScrollPhysics(), 
                          shrinkWrap:
                              true, 
                          itemCount: bookmarkedPosts.length,
                          itemBuilder: (context, index) {
                            final post = bookmarkedPosts[index];
                            final postData =
                                post.data() as Map<String, dynamic>;
                            final postId = post.id;
                            final likes =
                                List<String>.from(postData['likes'] ?? []);
                            final likeCount = likes.length;
                            final userUid = postData['uid'] ?? '';
                            final username = postData['username'] ?? 'User';
                            final createdAt =
                                postData['timestamp'] as Timestamp?;
                            String elapsedTime = 'Just now';
                            if (createdAt != null) {
                              elapsedTime = timeago.format(createdAt.toDate());
                            }

                            final isLiked = likes.contains(currentUserUid);

                            return FutureBuilder<String>(
                              future: getUserProfileImage(userUid),
                              builder: (context, snapshot) {
                                final userImageUrl = snapshot.data ?? '';

                                return Container(
                                  height: 455,
                                  padding: const EdgeInsets.all(5),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode
                                        ? const Color.fromARGB(255, 39, 38, 38)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 82, 81, 81)
                                            : const Color.fromARGB(
                                                255, 204, 203, 203),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(userImageUrl),
                                              radius: 20,
                                            ),
                                            const SizedBox(width: 15),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserDetailsPage(
                                                      userId: postData['uid'],
                                                      userEmail:
                                                          postData['userEmail'],
                                                      username: postData[
                                                              'username'] ??
                                                          'User',
                                                      currentUserId:
                                                          currentUserUid,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                username,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.white
                                                          : Color.fromARGB(
                                                              255, 13, 13, 13),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () async {
                                                await removeFromBookmarks(
                                                    postId);
                                              },
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetails(postId: postId),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            postData['imageURL'] ?? '',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 300,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.image_not_supported);
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                toggleLike(postId, isLiked);
                                              },
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentSection(
                                                            postId: postId),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.comment_outlined),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                          '$likeCount likes',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                          elapsedTime,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 100,
                        ),
                      
                      ],
                    ),
                  ),
      ),
    );
  }
}

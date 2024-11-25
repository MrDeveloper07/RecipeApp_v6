import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({required this.postId, Key? key}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final postData = postDoc.data() as Map<String, dynamic>;
        setState(() {
          comments = postData['comments'] != null
              ? List<Map<String, dynamic>>.from(postData['comments'])
              : [];
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> addComment(String comment) async {
    if (comment.trim().isEmpty) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      // Fetch user data using currentUser.uid
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Using the UID for the user document
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found in the database");
      }

      // Get user details
      final username = userDoc.data()?['name'] ?? 'User';
      final imgurl =
          userDoc.data()?['imageUrl'] ?? ''; // Default empty string if no image

      // Check if imgurl is valid (optional step)
      if (imgurl.isEmpty) {
        print("No image URL found for the user. Using a default image.");
      }

      // Prepare the new comment
      final newComment = {
        'userId': currentUser.uid,
        'username': username,
        'comment': comment.trim(),
        'timestamp': Timestamp.now(),
        'imageurl': imgurl, // Add imageurl to the comment
      };

      // Update Firestore with the new comment
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      await postRef.update({
        'comments': FieldValue.arrayUnion([newComment]),
      });

      setState(() {
        comments.add(newComment);
        _commentController.clear();
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final imageUrl =
                    comment['imageurl'] ?? ''; // Get image URL from comment
                return ListTile(
                  leading: CircleAvatar(
                    // Display user image or a placeholder
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/placeholder.png')
                            as ImageProvider, // Placeholder image if no URL
                  ),
                  title: Text(comment['username'] ?? 'Unknown User'),
                  subtitle: Text(comment['comment'] ?? ''),
                  trailing: Text(
                    timeago
                        .format((comment['timestamp'] as Timestamp).toDate()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                addComment(_commentController.text),
                            icon: Icon(
                              Icons.send,
                              color: const Color.fromARGB(255, 32, 95, 34),
                            ))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

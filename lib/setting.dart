import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:project/login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                "Edit Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 8, 130, 79),
              ),
              onTap: () {
                // Navigate to the profile edit screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              title: const Text(
                "Manage Notifications",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(
                Icons.notifications,
                color: Color.fromARGB(255, 8, 130, 79),
              ),
              onTap: () {
                // Navigate to notification settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageNotificationScreen()),
                );
              },
            ),
            ListTile(
              title: const Text(
                "Privacy Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(
                Icons.lock,
                color: Color.fromARGB(255, 8, 130, 79),
              ),
              onTap: () {
              
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                );
              },
            ),
            ListTile(
              title: const Text(
                "Logout",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              leading: const Icon(
                Icons.exit_to_app,
                color: Color.fromARGB(255, 8, 130, 79),
              ),
              onTap: () {
              
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Perform logout logic here
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color.fromRGBO(27, 94, 32, 1)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Color.fromRGBO(27, 94, 32, 1)),
              ),
            ),
          ],
        );
      },
    );
  }
}



class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String userName = '';
  String userBio = '';
  String userImageUrl = '';
  bool isLoading = true;

  // Fetch user profile data from Firestore
  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Use the UID for direct access
          .get();

      if (snapshot.exists) {
        final userDoc = snapshot.data()!;
        setState(() {
          userName = userDoc['name'] ?? '';
          userBio = userDoc['bio'] ?? ''; // Default to empty string if not set
          userImageUrl = userDoc['imageUrl'] ??
              ''; // Fetch the imageUrl if exists, else empty
          _nameController.text = userName;
          _bioController.text = userBio;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Upload image to Firebase Storage and get URL
  Future<String?> uploadImageToStorage(File image) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('${currentUser.uid}.jpg');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL(); // Return download URL
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final updatedName = _nameController.text;
      final updatedBio = _bioController.text;

      String? imageUrl = userImageUrl; // Retain old image if not updated
      if (_image != null) {
        imageUrl = await uploadImageToStorage(_image!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(
            {
              'name': updatedName,
              'bio': updatedBio,
              'imageUrl': imageUrl, // Update or add the image URL
            },
            SetOptions(merge: true), // Merge ensures fields are not overwritten
          );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context); // Go back to the profile screen
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Profile Picture Section
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Show bottom sheet to choose between gallery or camera
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Take a photo"),
                                  onTap: () {
                                    _pickImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text("Choose from gallery"),
                                  onTap: () {
                                    _pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (userImageUrl.isNotEmpty
                                ? NetworkImage(userImageUrl)
                                : const AssetImage('assets/default_profile.png'))
                                as ImageProvider,
                        child: _image == null && userImageUrl.isEmpty
                            ? const Icon(Icons.camera_alt,
                                size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name TextField
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bio TextField
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  ElevatedButton(
                    onPressed: updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("Save Profile"),
                  ),
                ],
              ),
            ),
    );
  }
}


class ManageNotificationScreen extends StatefulWidget {
  const ManageNotificationScreen({super.key});

  @override
  _ManageNotificationScreenState createState() =>
      _ManageNotificationScreenState();
}

class _ManageNotificationScreenState extends State<ManageNotificationScreen> {
  bool _isNotificationsEnabled = false; // Notifications toggle state
  bool _newRecipeNotification = false; // New recipe notification
  bool _newFollowerNotification = false; // New follower notification
  bool _commentNotification = false; // Comment on post notification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Notifications"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Master toggle for notifications
            SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Turn notifications on or off"),
              value: _isNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isNotificationsEnabled = value;
                });
              },
              activeColor: const Color.fromARGB(255, 8, 130, 79),
            ),
            if (_isNotificationsEnabled) const Divider(),

            // New recipe notifications
            if (_isNotificationsEnabled)
              SwitchListTile(
                title: const Text("New Recipe Notifications"),
                subtitle:
                    const Text("Get notified when a new recipe is posted"),
                value: _newRecipeNotification,
                onChanged: (bool value) {
                  setState(() {
                    _newRecipeNotification = value;
                  });
                },
                activeColor: const Color.fromARGB(255, 8, 130, 79),
              ),
            if (_isNotificationsEnabled) const Divider(),

            // New follower notifications
            if (_isNotificationsEnabled)
              SwitchListTile(
                title: const Text("New Follower Notifications"),
                subtitle: const Text("Get notified when someone follows you"),
                value: _newFollowerNotification,
                onChanged: (bool value) {
                  setState(() {
                    _newFollowerNotification = value;
                  });
                },
                activeColor: const Color.fromARGB(255, 8, 130, 79),
              ),
            if (_isNotificationsEnabled) const Divider(),

            // Comment notifications
            if (_isNotificationsEnabled)
              SwitchListTile(
                title: const Text("Comment Notifications"),
                subtitle: const Text(
                    "Get notified when someone comments on your post"),
                value: _commentNotification,
                onChanged: (bool value) {
                  setState(() {
                    _commentNotification = value;
                  });
                },
                activeColor: const Color.fromARGB(255, 8, 130, 79),
              ),
            if (_isNotificationsEnabled) const Divider(),
          ],
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isAccountPrivate = false; // Account privacy (public/private)
  bool _isPostPrivate = false; // Post visibility (private/public)
  bool _hideActivityStatus = false; // Hide activity status (last seen)
  List<String> blockedUsers = []; // List of blocked users

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Account Privacy toggle (Public/Private)
            SwitchListTile(
              title: const Text("Make Account Private"),
              subtitle:
                  const Text("Set your account to private to restrict access."),
              value: _isAccountPrivate,
              onChanged: (bool value) {
                setState(() {
                  _isAccountPrivate = value;
                });
              },
              activeColor: const Color.fromARGB(255, 8, 130, 79),
            ),
            const Divider(),

            // Post Visibility (Public/Private)
            SwitchListTile(
              title: const Text("Make Posts Private"),
              subtitle: const Text("Set your posts to be visible only to you."),
              value: _isPostPrivate,
              onChanged: (bool value) {
                setState(() {
                  _isPostPrivate = value;
                });
              },
              activeColor: const Color.fromARGB(255, 8, 130, 79),
            ),
            const Divider(),

            // Hide Activity Status (Online/Last Seen)
            SwitchListTile(
              title: const Text("Hide Activity Status"),
              subtitle:
                  const Text("Hide your online status and last seen time."),
              value: _hideActivityStatus,
              onChanged: (bool value) {
                setState(() {
                  _hideActivityStatus = value;
                });
              },
              activeColor: const Color.fromARGB(255, 8, 130, 79),
            ),
            const Divider(),

            // Blocked Users Management
            ListTile(
              title: const Text("Manage Blocked Users"),
              subtitle: const Text("View or unblock users you have blocked."),
              onTap: () {
                // Navigate to blocked users management screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BlockedUsersScreen(blockedUsers: blockedUsers),
                  ),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

class BlockedUsersScreen extends StatefulWidget {
  final List<String> blockedUsers;
  const BlockedUsersScreen({super.key, required this.blockedUsers});

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late List<String> _blockedUsers;

  @override
  void initState() {
    super.initState();
    _blockedUsers = widget.blockedUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),
      ),
      body: ListView.builder(
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_blockedUsers[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _blockedUsers.removeAt(index); // Unblock the user
                });
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:project/commentScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project/likePage.dart';
import 'package:project/login.dart';
import 'package:project/navBarSetting.dart';

import 'package:project/setting.dart';

import 'package:provider/provider.dart';
import 'theme_provider.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  bool status = false;
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfileImage();
    fetchUserProfile();
  }

  Future<void> fetchUserProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch document where email matches current user's email
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docData = snapshot.docs.first.data();
        setState(() {
          imageUrl = docData['imageUrl'] ?? ''; // Set fetched imageUrl
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // No matching user found
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String userName = '';


  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
  
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users') // Your collection name here
          .doc(currentUser.uid) // Use UID for direct access
          .get();

      if (docSnapshot.exists) {
        setState(() {
      
          userName = docSnapshot.data()?['name'] ?? 'User not found';
        });
      } else {
        setState(() {
          userName = 'User not found';
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Drawer(
      child: Container(
        color: themeProvider.isDarkMode
            ? Colors.grey[800]
            : const Color.fromARGB(255, 39, 91, 41),
        padding:
            const EdgeInsets.only(top: 50, bottom: 30, left: 15, right: 15),
        child: Column(
          children: [
            Container(
              height: 85,
              width: 280,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? const Color.fromARGB(255, 49, 52, 50)
                    : const Color.fromARGB(255, 36, 86, 53),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 211, 223, 218)
                        .withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 188, 188, 188),
                            width: 2),
                        borderRadius: BorderRadius.circular(50)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              height: 45,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/Default_pfp.svg.png",
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 170,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                              color: Color.fromARGB(255, 193, 192, 192),
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                        Text(
                          "Chef",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      height: 380,
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Brows Menu's",
                            style: TextStyle(
                                color: Color.fromARGB(255, 210, 209, 209),
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfilePage()),
                              );
                            },
                            child: SizedBox(
                              height: 310,
                              width: 280,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    width: 250,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? const Color.fromARGB(
                                              255, 49, 52, 50)
                                          : const Color.fromARGB(
                                              255, 36, 86, 53),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider.isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 98, 104, 100)
                                              : const Color.fromARGB(
                                                      255, 8, 130, 79)
                                                  .withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0,
                                              2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/profile-svgrepo-com.svg",
                                          color: const Color.fromARGB(
                                              255, 211, 211, 211),
                                        ),
                                        // Icon(
                                        //   Icons.settings,
                                        //   color: Color.fromARGB(255, 211, 211, 211),
                                        //   size: 30,
                                        // ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text(
                                          "Account & Profile",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 211, 211, 211),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationSettingsPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      width: 250,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 49, 52, 50)
                                            : const Color.fromARGB(
                                                255, 36, 86, 53),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeProvider.isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 98, 104, 100)
                                                : const Color.fromARGB(
                                                        255, 8, 130, 79)
                                                    .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.notifications,
                                            color: Color.fromARGB(
                                                255, 211, 211, 211),
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Notifications",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 211, 211, 211),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsAndConditionsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      width: 250,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 49, 52, 50)
                                            : const Color.fromARGB(
                                                255, 36, 86, 53),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeProvider.isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 98, 104, 100)
                                                : const Color.fromARGB(
                                                        255, 8, 130, 79)
                                                    .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/signing-the-contract-svgrepo-com.svg",
                                            height: 26,
                                            color: const Color.fromARGB(
                                                255, 211, 211, 211),
                                          ),
                                       
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            "Terms & Conditions",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 211, 211, 211),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpAndSupportScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      width: 250,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 49, 52, 50)
                                            : const Color.fromARGB(
                                                255, 36, 86, 53),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeProvider.isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 98, 104, 100)
                                                : const Color.fromARGB(
                                                        255, 8, 130, 79)
                                                    .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/support-svgrepo-com.svg",
                                            height: 28,
                                            color: const Color.fromARGB(
                                                255, 211, 211, 211),
                                          ),
                                          
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            "Help & Support",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 211, 211, 211),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      width: 250,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 49, 52, 50)
                                            : const Color.fromARGB(
                                                255, 36, 86, 53),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeProvider.isDarkMode
                                                ? const Color.fromARGB(
                                                    255, 98, 104, 100)
                                                : const Color.fromARGB(
                                                        255, 8, 130, 79)
                                                    .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.settings,
                                            color: Color.fromARGB(
                                                255, 211, 211, 211),
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Settings",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 211, 211, 211),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 149, 148, 148),
                      height: 20,
                      thickness: 1,
                      indent: 5,
                      endIndent: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      width: 280,
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Activities",
                            style: TextStyle(
                                color: Color.fromARGB(255, 210, 209, 209),
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Likepage()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    width: 250,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? const Color.fromARGB(
                                              255, 49, 52, 50)
                                          : const Color.fromARGB(
                                              255, 36, 86, 53),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider.isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 98, 104, 100)
                                              : const Color.fromARGB(
                                                      255, 8, 130, 79)
                                                  .withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Color.fromARGB(
                                              255, 211, 211, 211),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Likes",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 211, 211, 211),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CommentScreen()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    width: 250,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? const Color.fromARGB(
                                              255, 49, 52, 50)
                                          : const Color.fromARGB(
                                              255, 36, 86, 53),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider.isDarkMode
                                              ? const Color.fromARGB(
                                                  255, 98, 104, 100)
                                              : const Color.fromARGB(
                                                      255, 8, 130, 79)
                                                  .withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0,
                                              2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.message,
                                          color: Color.fromARGB(
                                              255, 211, 211, 211),
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Comments",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 211, 211, 211),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 15),
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/moon-stars-svgrepo-com.svg",
                                  color:
                                      const Color.fromARGB(255, 211, 211, 211),
                                  width: 30,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  "Dark Mode",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 211, 211, 211),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                FlutterSwitch(
                                  width: 58.0,
                                  height: 28.0,
                                  valueFontSize: 13.0,
                                  toggleSize: 20.0,
                                  value: themeProvider.isDarkMode,
                                  borderRadius: 30.0,
                                  padding: 4.0,
                                  showOnOff: true,
                                  onToggle: (val) {
                                    setState(() {
                                      status = val;
                                      themeProvider.toggleTheme();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Color.fromARGB(255, 149, 148, 148),
                            height: 20,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/logout-svgrepo-com.svg",
                                    color: const Color.fromARGB(
                                        255, 211, 211, 211),
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Logout",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 211, 211, 211),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

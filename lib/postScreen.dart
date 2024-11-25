import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class PostScreen extends StatefulWidget {
  @override
  State createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String userName = '';
  TextEditingController titleController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();
  TextEditingController procedureController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  List<String> ingredients = [];
  List<String> procedures = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    'Indian',
    'Italian',
    'Asian',
    'Chinese',
    'Others'
  ];
  String? selectedCategory;

  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userName = snapshot.docs[0]['name'];
        });
      } else {
        setState(() {
          userName = 'User not found';
        });
      }
    }
  }

  void addIngredient() {
    String ingredient = ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        ingredients.add(ingredient);
        ingredientController.clear();
      });
    }
  }

  void addProcedure() {
    String procedure = procedureController.text.trim();
    if (procedure.isNotEmpty) {
      setState(() {
        procedures.add(procedure);
        procedureController.clear();
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadDataToFirestore() async {
    try {
      setState(() {
        isLoading = true; // Show loading animation
      });

      final title = titleController.text.trim();
      final time = timeController.text.trim();

      if (title.isEmpty ||
          time.isEmpty ||
          ingredients.isEmpty ||
          procedures.isEmpty ||
          selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields')),
        );
        setState(() {
          isLoading = false; // Stop loading animation
        });
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('posts').doc();
      final pid = docRef.id;

      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated')),
        );
        setState(() {
          isLoading = false; // Stop loading animation
        });
        return;
      }

      String imageURL = '';

      if (_selectedImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('post_images/$pid');
        final uploadTask = storageRef.putFile(_selectedImage!);

        final snapshot = await uploadTask.whenComplete(() => {});
        imageURL = await snapshot.ref.getDownloadURL();
      } else {
        imageURL = "https://via.placeholder.com/200";
      }

      await docRef.set({
        'pid': pid,
        'uid': uid,
        'title': title,
        'time': time,
        'ingredients': ingredients,
        'procedures': procedures,
        'imageURL': imageURL,
        'category': selectedCategory,
        'userEmail': FirebaseAuth.instance.currentUser?.email,
        'username': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe added successfully')),
      );

      setState(() {
        titleController.clear();
        timeController.clear();
        ingredients.clear();
        procedures.clear();
        _selectedImage = null;
        selectedCategory = null;
        isLoading = false; // Stop loading animation
      });
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add recipe: $e')),
      );
      setState(() {
        isLoading = false; // Stop loading animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : Colors.white60,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        const Text(
                          "Add Post",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 120,
                        ),
                        GestureDetector(
                          onTap: uploadDataToFirestore,
                          child: const Text(
                            "Post",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 31, 99, 33)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recipe Title",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                   

                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? const Color.fromARGB(255, 88, 87, 87)
                            : Colors.white, // Background color of the TextField
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            offset: Offset(-4, -4), // Top-left shadow (light)
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true, // Enable inset effect
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(4, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Enter title of recipe",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none, // Remove outer border
                          ),
                          prefixIcon: Icon(Icons.title),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Preparation Time (in minutes)",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                 
                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? const Color.fromARGB(255, 88, 87, 87)
                            : Colors.white, // Background color of the TextField
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            offset: Offset(-4, -4), // Top-left shadow (light)
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true, // Enable inset effect
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(4, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: ingredientController,
                        decoration: InputDecoration(
                          hintText: "Enter preparation time",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none, // Remove outer border
                          ),
                          prefixIcon: Icon(Icons.access_time),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: "Select a category",
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recipe Image",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _selectedImage != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green, width: 3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          )
                        : TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.photo,
                                      ),
                                      title: const Text("Gallery"),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        pickImage(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.camera_alt,
                                      ),
                                      title: const Text("Camera"),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.image,
                                color: Color.fromARGB(255, 31, 99, 33)),
                            label: const Text(
                              "Pick an Image",
                              style: TextStyle(
                                color: Color.fromARGB(255, 31, 99, 33),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ingredients",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                   

                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? const Color.fromARGB(255, 88, 87, 87)
                            : Colors.white, // Background color of the TextField
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            offset: Offset(-4, -4), // Top-left shadow (light)
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true, // Enable inset effect
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(4, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: ingredientController,
                        decoration: InputDecoration(
                          hintText: "Add an ingredient",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none, // Remove outer border
                          ),
                          prefixIcon: Icon(Icons.fastfood),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 26, 99, 28)),
                      ),
                      onPressed: addIngredient,
                      child: const Text(
                        "Add Ingredient",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ingredients
                          .map((ingredient) => ListTile(
                                title: Text(ingredient),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    setState(() {
                                      ingredients.remove(ingredient);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Procedure",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? const Color.fromARGB(255, 88, 87, 87)
                            : Colors.white, // Background color of the TextField
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            offset: Offset(-4, -4), // Top-left shadow (light)
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true, // Enable inset effect
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(4, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                            inset: true,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: procedureController,
                        decoration: InputDecoration(
                          hintText: "Add a procedure",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none, // Remove outer border
                          ),
                          prefixIcon: Icon(Icons.check),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 26, 99, 28)),
                      ),
                      onPressed: addProcedure,
                      child: const Text(
                        "Add Procedure",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: procedures
                          .map((procedure) => ListTile(
                                title: Text(procedure),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    setState(() {
                                      procedures.remove(procedure);
                                    });
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Center(
                child: Image.asset(
                  'assets/output-onlinegiftools.gif',
                  height: 150,
                  width: 150,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

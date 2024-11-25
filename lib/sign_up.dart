import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isTermsAccepted = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> SignUp() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept the terms and conditions.")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'followers': [], 
        'following': [], 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign-up successful!")),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == "weak-password") {
        errorMessage = "The password is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for this email.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign up: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create an account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                "Let's help you set up your account,",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                "it won't take long.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Name",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Email",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Password",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: "Enter Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _showPassword = !_showPassword;
                      setState(() {});
                    },
                    child: Icon(
                      (_showPassword) ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Confirm Password",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  hintText: "Retype Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _showConfirmPassword = !_showConfirmPassword;
                      setState(() {});
                    },
                    child: Icon(
                      (_showConfirmPassword) ? Icons.visibility : Icons.visibility_off,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: isTermsAccepted,
                    activeColor: Colors.amber,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isTermsAccepted = newValue ?? false;
                      });
                    },
                    side: const BorderSide(color: Colors.amber),
                  ),
                  Text(
                    "Accept terms & Conditions",
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: SignUp,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "------------Or Sign in with------------",
                  style: TextStyle(
                    color: Colors.black26,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/google.png",
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 30),
                  Image.asset(
                    "assets/images/facebook.png",
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

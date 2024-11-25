import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isNotificationOn = false;

  void _toggleNotification(bool newValue) {
    setState(() {
      _isNotificationOn = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notification Settings",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Notifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.notifications,
                size: 35,
                color: _isNotificationOn ? Colors.green : Colors.grey,
              ),
              title: const Text(
                "Enable Notifications",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
                ),
              ),
              trailing: Switch(
                value: _isNotificationOn,
                onChanged: _toggleNotification,
                activeColor: const Color.fromRGBO(27, 94, 32, 1),
                inactiveThumbColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Notification Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "• Receive daily updates about the latest features.\n"
              "• Get notified when someone likes your posts.\n"
              "• Stay up-to-date with news and announcements.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            // Additional information or settings can go here
          ],
        ),
      ),
    );
  }
}


class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Terms and Conditions",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Welcome to our Cooking App! Please read these Terms and Conditions carefully.

1. Acceptance of Terms: By using our app, you agree to be bound by these terms. 

2. Use of App: You are permitted to view, share, and post recipes, photos, and comments. However, content must be respectful and suitable for all audiences.

3. Content Ownership: All content you upload remains yours. However, by uploading, you grant us a license to use your content within the app for the benefit of other users.

4. User Conduct: You agree not to post any offensive or inappropriate content. Our team reserves the right to remove such content.

5. Liability: We are not liable for any issues that arise from using recipes or information from the app.

6. Privacy Policy: Your privacy is important to us. Please review our Privacy Policy for more details on how we protect your data.


If you have any questions regarding these terms, please feel free to contact us at support@cookingapp.com.''',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle accept terms action here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 94, 32, 1),
              ),
              child: const Text(
                "Accept",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            ListTile(
              leading: const Icon(
                Icons.help, 
                color: Color.fromARGB(255, 8, 130, 79),
                size: 30,
              ),
              title: const Text(
                "FAQs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: const Text("Common questions and answers"),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => FAQScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // Contact Support Section
            ListTile(
              leading: const Icon(
                Icons.support_agent, 
                color: Color.fromARGB(255, 8, 130, 79),
                size: 30,
              ),
              title: const Text(
                "Contact Support",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: const Text("Get in touch with our support team"),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // App Guide Section
            ListTile(
              leading: const Icon(
                Icons.book, 
                color: Color.fromARGB(255, 8, 130, 79),
                size: 30,
              ),
              title: const Text(
                "App Guide",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: const Text("Learn how to use the app features"),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const AppGuideScreen(), 
                  ),
                );
              },
            ),
            const Divider(),

            // Send Feedback Section
            ListTile(
              leading: const Icon(
                Icons.feedback, 
                color: Color.fromARGB(255, 8, 130, 79),
                size: 30,
              ),
              title: const Text(
                "Send Feedback",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              ),
              subtitle: const Text("Share your thoughts with us"),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const SendFeedbackScreen(),
                  ),
                );
              },
            ),
            const Spacer(),

            // Version Information
            const Center(
              child: Text(
                "App Version 1.0.0",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I upload a new recipe?",
      "answer": "To upload a new recipe, go to the post screen, fill out the recipe details, add photos, and tap 'Submit'."
    },
    {
      "question": "How can I save recipes to view later?",
      "answer": "You can save a recipe by tapping on the bookmark icon. All saved recipes will be available in your 'Saved Recipes' section."
    },
    {
      "question": "How do I follow other cooks?",
      "answer": "Search for the cook's profile and tap 'Follow'. You’ll see their new recipes in your feed."
    },
    {
      "question": "What should I do if I forget my password?",
      "answer": "On the login screen, tap 'Forgot Password' and follow the instructions to reset your password."
    },
    {
      "question": "How can I report inappropriate content?",
      "answer": "If you come across any inappropriate content, tap on the three-dot menu on the post and select 'Report'."
    },
  ];

  FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              faqs[index]["question"]!,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
            ),
            children: [Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                faqs[index]["answer"]!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300
                ),
              ),
            )],
          );
        },
      ),
    );
  }
}

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Support",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email us at support@example.com",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
            Text(
              "Call us at +1234567890",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "App Guide",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: ListView(
        children: const [
          ExpansionTile(
            title: Text(
              "How to post a new recipe?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "To post a new recipe, go to the 'Add Post' screen using the navigation bar. "
                  "Enter the title, ingredients, and procedure, then click 'Post' to share it with others.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "How to edit my profile?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "To edit your profile, go to 'Profile' in the navigation bar, "
                  "then tap on 'Edit Profile' to update your information such as profile picture, bio, and contact details.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "How to follow or unfollow someone?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "To follow someone, visit their profile and tap the 'Follow' button. "
                  "To unfollow, go to their profile again and tap 'Unfollow'.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "How to search for recipes?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "To search for recipes, go to the 'Search' tab in the navigation bar. "
                  "You can search by recipe name, ingredients, or even by chef names.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "How to manage my notifications?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "Go to 'Settings' and select 'Notifications'. "
                  "Toggle notifications on or off, and customize which alerts you want to receive.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100
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


class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  _SendFeedbackScreenState createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String feedback = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Feedback"),
              TextFormField(
                maxLines: 5,
                onChanged: (value) => feedback = value,
                decoration: const InputDecoration(hintText: "Write your feedback here..."),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle feedback submission
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Feedback submitted successfully!"),
                    ));
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


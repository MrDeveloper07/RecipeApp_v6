import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  int selectedIndex = 0;
  final List<Map> items = [
    {
      "userName": "Nadia_Santini",
      "userProfile": "assets/profileimg.jpg",
      "comments": "Delicious",
      "commentDate": "2w",
      "ReciverProfile": "assets/punnet.jfif",
      "ReciverName": "jeera.official",
      "postCaption": "new salad recipe",
      "postImage": "assets/salad.jpg",
      "postDate": "4w"
    },
    {
      "userName": "Nadia_Santini",
      "userProfile": "assets/profileimg.jpg",
      "comments": "Tasty and Healthy",
      "commentDate": "3w",
      "ReciverProfile": "assets/dolly.jfif",
      "ReciverName": "cashs.official",
      "postCaption": "Crunchy & spicy Sandwich",
      "postImage": "assets/recipe2.jfif",
      "postDate": "5w"
    },
    {
      "userName": "Nadia_Santini",
      "userProfile": "assets/profileimg.jpg",
      "comments": "Great Taste",
      "commentDate": "5w",
      "ReciverProfile": "assets/cookprofile.jfif",
      "ReciverName": "vasiyo.official",
      "postCaption": "Cheesy pizza spice",
      "postImage": "assets/recipe3.jfif",
      "postDate": "7w"
    },
    {
      "userName": "Nadia_Santini",
      "userProfile": "assets/profileimg.jpg",
      "comments": "Superior Recipe",
      "commentDate": "1w",
      "ReciverProfile": "assets/profilescom.png",
      "ReciverName": "chef_Ramesh_11",
      "postCaption": "Special Masala Dosa",
      "postImage": "assets/dosa.jfif",
      "postDate": "3w"
    }
  ];

  void sortItems() {
    switch (selectedIndex) {
      case 0: // Newest to Oldest
        items.sort((a, b) => b["commentDate"].compareTo(a["commentDate"]));
        break;
      case 1: // Oldest to Newest
        items.sort((a, b) => a["commentDate"].compareTo(b["commentDate"]));
        break;
      case 2: // Alphabetical by Author
        items.sort((a, b) => a["ReciverName"].compareTo(b["ReciverName"]));
        break;
      case 3: // Reverse Alphabetical by Author
        items.sort((a, b) => b["ReciverName"].compareTo(a["ReciverName"]));
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text(
          "Comments",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                      sortItems();
                    },
                    child: sortingButton("Newest to Oldest", 0),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                      sortItems();
                    },
                    child: sortingButton("Oldest to Newest", 1),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 2;
                      });
                      sortItems();
                    },
                    child: sortingButton("Alphabetical", 2),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 3;
                      });
                      sortItems();
                    },
                    child: sortingButton("Reverse Alphabetical", 3),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return commentCard(index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sortingButton(String title, int index) {
    return Container(
      height: 30,
      width: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: selectedIndex == index
            ? const Color.fromRGBO(27, 94, 32, 1)
            : Colors.white,
      ),
      child: Text(
        title,
        style: TextStyle(
            color: selectedIndex == index
                ? Colors.white
                : const Color.fromRGBO(27, 94, 32, 1),
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget commentCard(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          items[index]["ReciverProfile"],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              items[index]["ReciverName"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(width: 5),
                            Text(items[index]["postCaption"]),
                          ],
                        ),
                        Text(
                          items[index]["postDate"],
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    items[index]["postImage"],
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 50),
              SizedBox(
                width: 40,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    items[index]["userProfile"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        items[index]["userName"],
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(width: 5),
                      Text(items[index]["comments"]),
                    ],
                  ),
                  Text(
                    items[index]["commentDate"],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

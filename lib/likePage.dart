import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Likepage extends StatefulWidget {
  const Likepage({super.key});

  @override
  State<Likepage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Likepage> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> sortedFoodItems = [];

  final List<Map<String, dynamic>> foodItems = [
    {
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJRP5L1FODxAabZ1_W3gZou42CFUv-riEKvA&s",
      'time': DateTime(2024, 11, 15, 12, 0),
      'likes': "12.5K",
      'processTime': "17min",
      'author': "John Doe",
      'shared': true,
    },
    {
      'image':
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkyWx5iUzIVk_6gMGhI48aqPC0U-BJz2NmWw&s",
      'processTime': "17min",
      'time': DateTime(2024, 11, 10, 9, 0),
      'likes': "10K",
      'author': "Jane Smith",
      'shared': false,
    },
    {
      'image':
          "https://assets.epicurious.com/photos/5bce4de2ab2c1825ca89c5b5/6:4/w_1600%2Cc_limit/Thanksgiving-2-4-Corn-Spoon-Bread-recipe-09102018.jpg",
      'time': DateTime(2024, 11, 12, 14, 0),
      'likes': "15K",
      'author': "Alice Johnson",
      'processTime': "17min",
      'shared': true,
    },
    {
      'image':
          "https://nataliecooks.com/wp-content/uploads/2023/03/DSC07900-2-4.jpg",
      'time': DateTime(2024, 11, 5, 16, 0),
      'likes': "20K",
      'author': "Bob Brown",
      'processTime': "17min",
      'shared': false,
    },
    {
      'image':
          "https://cdn.shopify.com/s/files/1/1338/2981/files/Photo_5-4-2023_2_19_20_pmx_9e505a1a-e31f-46d5-aab8-4b9903e969f2_480x480.jpg?v=1680675310",
      'time': DateTime(2024, 11, 14, 18, 0),
      'likes': "8K",
      'author': "Charlie Lee",
      'processTime': "17min",
      'shared': true,
    },
  ];

  // Helper function to sort items based on selected index
  void sortFoodItems() {
    List<Map<String, dynamic>> sortedItems = List.from(foodItems);

    switch (selectedIndex) {
      case 0:
        // Newest to Old
        sortedItems.sort((a, b) => b['time'].compareTo(a['time']));
        break;
      case 1:
        // All Dates (no sorting)
        break;
      case 2:
        // All Authors
        sortedItems.sort((a, b) => a['author'].compareTo(b['author']));
        break;
      case 3:
        // Shared
        sortedItems =
            sortedItems.where((item) => item['shared'] == true).toList();
        break;
    }

    setState(() {
      sortedFoodItems = sortedItems;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize sorted list on page load
    sortFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text(
          "Like Posts",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: MediaQuery.of(context).size.height,
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
                      sortFoodItems(); // Sort when tap
                    },
                    child: Container(
                      height: 30,
                      width: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: selectedIndex == 0
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.white,
                      ),
                      child: Text(
                        "Newest to old",
                        style: TextStyle(
                            color: selectedIndex == 0
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                      sortFoodItems(); // Sort when tap
                    },
                    child: Container(
                      height: 30,
                      width: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: selectedIndex == 1
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.white,
                      ),
                      child: Text(
                        "All dates",
                        style: TextStyle(
                            color: selectedIndex == 1
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 2;
                      });
                      sortFoodItems(); // Sort when tap
                    },
                    child: Container(
                      height: 30,
                      width: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: selectedIndex == 2
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.white,
                      ),
                      child: Text(
                        "All Authors",
                        style: TextStyle(
                            color: selectedIndex == 2
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = 3;
                      });
                      sortFoodItems(); // Sort when tap
                    },
                    child: Container(
                      height: 30,
                      width: 110,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: selectedIndex == 3
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.white,
                      ),
                      child: Text(
                        "Shared",
                        style: TextStyle(
                            color: selectedIndex == 3
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: sortedFoodItems.length,
                itemBuilder: (context, index) {
                  final item = sortedFoodItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      width: 180,
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          SizedBox.expand(
                            child: Image.network(
                              item['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/clock-svgrepo-com (1).svg",
                                  width: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item['processTime'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item['likes'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

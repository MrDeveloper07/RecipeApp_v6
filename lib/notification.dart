import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Notify extends StatefulWidget {
  const Notify({super.key});

  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  List<Map<dynamic, dynamic>> notifications = [
    {
      "title": "New Recipe Alert!",
      "message":
          "Lorem Iqsum tempor incididunt ut labore et dolare in voluptate velit esse cillium",
      "time": "10:30 PM",
      "status": "unread",
    },
    {
      "title": "New Recipe Alert!",
      "message":
          "Lorem Iqsum tempor incididunt ut labore et dolare in voluptate velit esse cillium",
      "time": "12:30 AM",
      "status": "read",
    },
    {
      "title": "Reminder New Recipe!",
      "message":
          "Lorem Iqsum tempor incididunt ut labore et dolare in voluptate velit esse cillium",
      "time": "01:00 AM",
      "status": "unread",
    },
    {
      "title": "New Recipe Alert!",
      "message":
          "Lorem Iqsum tempor incididunt ut labore et dolare in voluptate velit esse cillium",
      "time": "1 days ago",
      "status": "read",
    },
    {
      "title": "Reminder New Recipe!",
      "message":
          "Lorem Iqsum tempor incididunt ut labore et dolare in voluptate velit esse cillium",
      "time": "2 days ago",
      "status": "unread",
    },
  ];

  String selectedSection = 'All';
  int selectedIndex = 0;

  List<Map<dynamic, dynamic>> getFilteredNotifications() {
    if (selectedSection == 'All') {
      return notifications;
    } else {
      return notifications
          .where((notification) => notification['status'] == selectedSection)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                      selectedSection = 'All';
                    });
                  },
                  child: Container(
                    width: 105,
                    height: 30,
                    decoration: BoxDecoration(
                        color: selectedIndex == 0
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "All",
                        style: TextStyle(
                            color: selectedIndex == 0
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                      selectedSection = 'read';
                    });
                  },
                  child: Container(
                    width: 105,
                    height: 30,
                    decoration: BoxDecoration(
                        color: selectedIndex == 1
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Read",
                        style: TextStyle(
                            color: selectedIndex == 1
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                      selectedSection = 'unread';
                    });
                  },
                  child: Container(
                    width: 105,
                    height: 30,
                    decoration: BoxDecoration(
                        color: selectedIndex == 2
                            ? const Color.fromRGBO(27, 94, 32, 1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Unread",
                        style: TextStyle(
                            color: selectedIndex == 2
                                ? Colors.white
                                : const Color.fromRGBO(27, 94, 32, 1),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: 380,
              height: 550,
              child: ListView.builder(
                  itemCount: getFilteredNotifications().length,
                  itemBuilder: (BuildContext context, int index) {
                    var notification = getFilteredNotifications()[index];
                    return Column(
                      children: [
                        Container(
                            padding:
                                const EdgeInsets.only(top: 8, left: 15, right: 15),
                            height: 95,
                            width: 360,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 192, 191, 191),
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 95,
                                  width: 300,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification["title"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        child: Text(
                                          notification["message"],
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 126, 125, 125),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification["time"],
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600]),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color.fromARGB(
                                              255, 246, 198, 56),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                              "assets/document-text-svgrepo-com.svg",
                                              width: 16,
                                              color: const Color.fromARGB(
                                                  255, 234, 142, 3)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(height: 10),
                      ],
                    );
                  })),
        ],
      ),
    );
  }
}

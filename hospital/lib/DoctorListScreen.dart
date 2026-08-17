import 'package:flutter/material.dart';
import 'package:hospital/Home_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left_sharp,
            size: 30,
            color: Colors.white,
          ),
        ),
        title: const Text("Doctors"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Doctors",
                  hintStyle: const TextStyle(color: Colors.white),

                  prefixIcon: const Icon(Icons.search, color: Colors.white),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),

            // Doctor Card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  height: 210,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Row(
                    children: [
                      // Doctor Image
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg",
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Dr. Alex Doe",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Cardiologist",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),

                                SizedBox(width: 4),

                                Text(
                                  "4.5 | 12 years",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Divider(),

                            ListTile(
                              title: Text("Next Available:"),
                              titleTextStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              subtitle: Text("12:30 PM"),
                              subtitleTextStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                              trailing: Icon(
                                Icons.calendar_month,
                                color: Colors.green[700],
                              ),
                            ),

                            // Row(
                            //   children: [
                            //     const Text(
                            //       "Next Available: ",
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),

                            //     Text(
                            //       "12:30 PM",
                            //       style: TextStyle(
                            //         color: Colors.green[700],
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Row(
                    children: [
                      // Doctor Image
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg",
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Dr. John Doe",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Cardiologist",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),

                                SizedBox(width: 4),

                                Text(
                                  "4.5 | 12 years",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            ListTile(
                              title: Text("Next Available:"),
                              titleTextStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              subtitle: Text("12:30 PM"),
                              subtitleTextStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                              trailing: Icon(
                                Icons.calendar_month,
                                color: Colors.green[700],
                              ),
                            ),

                            // Row(
                            //   children: [
                            //     const Text(
                            //       "Next Available: ",
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),

                            //     Text(
                            //       "12:30 PM",
                            //       style: TextStyle(
                            //         color: Colors.green[700],
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Row(
                    children: [
                      // Doctor Image
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg",
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Dr. John Doe",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Cardiologist",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),

                                SizedBox(width: 4),

                                Text(
                                  "4.5 | 12 years",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            ListTile(
                              title: Text("Next Available:"),
                              titleTextStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              subtitle: Text("12:30 PM"),
                              subtitleTextStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                              trailing: Icon(
                                Icons.calendar_month,
                                color: Colors.green[700],
                              ),
                            ),

                            // Row(
                            //   children: [
                            //     const Text(
                            //       "Next Available: ",
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),

                            //     Text(
                            //       "12:30 PM",
                            //       style: TextStyle(
                            //         color: Colors.green[700],
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Row(
                    children: [
                      // Doctor Image
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://i.pinimg.com/736x/bf/0c/76/bf0c7651ee5d65b983eed068bbbba1c8.jpg",
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Doctor Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Dr. Alex Doe",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Cardiologist",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),

                                SizedBox(width: 4),

                                Text(
                                  "4.5 | 12 years",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            ListTile(
                              title: Text("Next Available:"),
                              titleTextStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              subtitle: Text("12:30 PM"),
                              subtitleTextStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                              trailing: Icon(
                                Icons.calendar_month,
                                color: Colors.green[700],
                              ),
                            ),

                            // Row(
                            //   children: [
                            //     const Text(
                            //       "Next Available: ",
                            //       style: TextStyle(fontWeight: FontWeight.bold),
                            //     ),

                            //     Text(
                            //       "12:30 PM",
                            //       style: TextStyle(
                            //         color: Colors.green[700],
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

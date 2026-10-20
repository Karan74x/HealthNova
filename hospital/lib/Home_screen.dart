import 'package:flutter/material.dart';
import 'package:hospital/AppointmentScreen.dart';
import 'package:hospital/DenteethsScreen.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/Login_screen.dart';
import 'package:hospital/ReportsScreen.dart';
import 'package:hospital/advanced_appointment_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Hospital App',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notification_add, color: Colors.black),
          ),
          SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // GREETING HEADER
            _buildGreetingHeader(),

            SizedBox(height: 20),

            // SEARCH BAR
            _buildSearchBar(),

            SizedBox(height: 20),

            // BANNER CAROUSEL
            _buildBannerCarousel(),

            SizedBox(height: 20),

            // CATEGORIES SECTION
            _buildCategoriesSection(context),

            SizedBox(height: 20),

            // ALL DOCTORS SECTION
            _buildAllDoctorsSection(context),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== DRAWER ====================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // DRAWER HEADER
            _buildDrawerHeader(context),

            SizedBox(height: 10),

            // MENU ITEMS
            _buildDrawerMenuItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () => Navigator.pop(context),
            ),

            _buildDrawerMenuItem(
              icon: Icons.calendar_today,
              title: 'Appointments',
              badge: '3',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvancedAppointmentScreen(),
                  ),
                );
              },
            ),

            _buildDrawerMenuItem(
              icon: Icons.document_scanner,
              title: 'Medical Reports',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsScreen()),
                );
              },
            ),

            _buildDrawerMenuItem(
              icon: Icons.favorite,
              title: 'Saved Doctors',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorListScreen()),
                );
              },
            ),

            _buildDrawerMenuItem(
              icon: Icons.person,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile
              },
            ),

            _buildDrawerMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings
              },
            ),

            _buildDrawerMenuItem(
              icon: Icons.help_center,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                // Navigate to Help
              },
            ),

            Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),

            _buildDrawerMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            SizedBox(height: 20),

            // FOOTER
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  // DRAWER HEADER
  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/dr1.jpg'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bond James Bond',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'bond@example.com',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 14),
                SizedBox(width: 6),
                Text(
                  'Member since 2023',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DRAWER MENU ITEM
  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
      onTap: onTap,
      hoverColor: Colors.blue.withOpacity(0.1),
    );
  }

  // DRAWER FOOTER
  Widget _buildDrawerFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'Hospital App',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ==================== LOGOUT DIALOG ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                // Add logout logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ==================== GREETING HEADER ====================
  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage('assets/images/dr1.jpg'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, welcome back",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                Text(
                  "Bond James Bond",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for Doctor",
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.tune, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ==================== BANNER CAROUSEL ====================
  Widget _buildBannerCarousel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: List.generate(
            2,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                height: 160,
                width: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[500]!, Colors.blue[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Medical Center",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Get expert care today",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                            child: Text(
                              "Book Now",
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORIES SECTION ====================
  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {'title': 'Dentist', 'screen': DentistScreen()},
      {'title': 'Therapist', 'screen': null},
      {'title': 'Surgeon', 'screen': null},
      {'title': 'Cardiologist', 'screen': null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: Text("See All")),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: List.generate(
                categories.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildCategoryCard(
                    title: categories[index]['title'].toString(),
                    onTap: () {
                      if (categories[index]['screen'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                categories[index]['screen'] as Widget,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // CATEGORY CARD
  Widget _buildCategoryCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.indigo[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ALL DOCTORS SECTION ====================
  Widget _buildAllDoctorsSection(BuildContext context) {
    final doctors = [
      {
        'name': 'Dr. Alex Doe',
        'specialty': 'Cardiologist',
        'rating': '4.5',
        'experience': '12 years',
        'nextAvailable': '12:30 PM',
        'image': 'assets/images/dr2.jpg',
      },
      {
        'name': 'Dr. Sarah Smith',
        'specialty': 'Dentist',
        'rating': '4.8',
        'experience': '8 years',
        'nextAvailable': '2:00 PM',
        'image': 'assets/images/dr2.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Doctors",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorListScreen()),
                  );
                },
                child: Text("See All"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: List.generate(
              doctors.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildDoctorCard(
                  name: doctors[index]['name'].toString(),
                  specialty: doctors[index]['specialty'].toString(),
                  rating: doctors[index]['rating'].toString(),
                  experience: doctors[index]['experience'].toString(),
                  nextAvailable: doctors[index]['nextAvailable'].toString(),
                  image: doctors[index]['image'].toString(),
                  context: context,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DOCTOR CARD
  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String rating,
    required String experience,
    required String nextAvailable,
    required String image,
    required BuildContext context,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(radius: 45, backgroundImage: AssetImage(image)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "$rating • $experience",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Next: $nextAvailable",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdvancedAppointmentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Book",
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
  }
}

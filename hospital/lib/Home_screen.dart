import 'package:flutter/material.dart';
import 'package:hospital/AppointmentScreen.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/Login_screen.dart';
import 'package:hospital/ReportsScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://tse3.mm.bing.net/th/id/OIP._DMMzn70uJhTvlf9Tq8PUgHaFF?r=0&pid=Api&P=0&h=180",
              ),
            ),
            title: Text("Hi, welcome back"),
            titleTextStyle: TextStyle(color: Colors.blue, fontSize: 20),
            subtitle: Text("Bond James Bond"),
            subtitleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.notification_add, color: Colors.black),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: TextFormField(
                controller: SearchController(),

                decoration: InputDecoration(
                  hintText: "Search for Doctor",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: 200,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Medial Center",
                        style: TextStyle(color: Colors.white, fontSize: 35),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  height: 200,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Medial Center",
                        style: TextStyle(color: Colors.white, fontSize: 35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

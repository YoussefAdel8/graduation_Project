import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Screens/OrganizerList.dart';
import 'package:first_app/Screens/profile.dart';
import 'package:first_app/Screens/search.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:gap/gap.dart';
import '../utils/app_layout.dart';
import '../utils/app_styles.dart';
import '../screens/category.dart';
import '../screens/venue_screen.dart';
import '../utils/list.dart';
import 'Login.dart';
import 'imageSlide.dart';
import 'place_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  int _selectedIndex = 0; // Track the selected tab

  // List of pages for each tab
  final List<Widget> _pages = [
    const HomePageContent(), // Main content of Home page
    const SearchPage(), // Replace with Search page
    OrganizerListPage(), // Replace with Bookings page
    const Profile(), // User profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()), // Login page
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: _pages[_selectedIndex], // Display content based on the selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        selectedItemColor: Styles.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Main Home Page Content
class HomePageContent extends StatelessWidget {
  const HomePageContent({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> getVenueListFromFirestore() async {
    CollectionReference venuesCollection =
        FirebaseFirestore.instance.collection('places');

    try {
      QuerySnapshot querySnapshot = await venuesCollection.get();
      List<Map<String, dynamic>> venueList = [];

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic>? venueData =
            documentSnapshot.data() as Map<String, dynamic>?;

        venueList.add(venueData!);
      }

      return venueList;
    } catch (error) {
      print('Error fetching venue data: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: ListView(
        children: [
          MySlider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.getWidth(20)),
            child: Column(
              children: [
                Gap(AppLayout.getHeight(40)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                    Icon(FluentSystemIcons.ic_fluent_pin_filled,
                        color: Styles.primaryColor),
                    Text("Find the perfect place for you",
                        style: Styles.textStyle3),
                        
                  ]),
                  Gap(AppLayout.getHeight(15)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: categoryList
                            .map((singleCat) => Category(category: singleCat))
                            .toList()),
                  ),
                  Gap(AppLayout.getHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Venues", style: Styles.textStyle3),
                      
                    ],
                  )
                      ],
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: getVenueListFromFirestore(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final venueList = snapshot.data!;
                return SingleChildScrollView(
                  
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: venueList
                        .map((venue) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaceView(
                                      placeData: venue,
                                      venueData: {},
                                    ),
                                  ),
                                );
                              },
                              child: VenueScreen(venueData: venue),
                            ))
                        .toList(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}

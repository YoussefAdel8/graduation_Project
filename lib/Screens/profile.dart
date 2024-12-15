import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Screens/Login.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/app_layout.dart';
import '../utils/app_styles.dart';
import 'EditProfile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!; 
            _isLoading = false; 
          });
        } else {
          setState(() {
            _isLoading = false; 
            // Handle the case where the user document doesn't exist
            // You can display an error message or handle the situation accordingly
          });
        }
      } else {
        setState(() {
          _isLoading = false; 
          // Handle the case where no user is logged in
          // You can navigate to the login screen or show an error message
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false; 
        // Show an error message to the user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: AppBar(
        title: Center(child: Text("Profile", style: Styles.textStyle2)),
        backgroundColor: Styles.bgColor,
        actions: [
          IconButton(
            onPressed: () {
              if (_userData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(userData: _userData!),
                  ),
                );
              }
            },
            icon: const Icon(FluentSystemIcons.ic_fluent_edit_regular),
            color: Colors.black,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData != null
              ? SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.getWidth(12),
                      vertical: AppLayout.getHeight(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: AppLayout.getWidth(120),
                          height: AppLayout.getHeight(120),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppLayout.getWidth(100)),
                            child: _userData!['profileImage'] != null
                                ? Image.network(
                                    _userData!['profileImage'],
                                    fit: BoxFit.cover,
                                  )
                                : const Image(
                                    image: AssetImage("assets/images/profile.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Gap(AppLayout.getHeight(40)),
                        Text(
                          _userData!['fullName'] ?? 'Unknown User',
                          style: Styles.textStyle3,
                        ),
                        Gap(AppLayout.getHeight(15)),
                        Row(
                          children: [
                            const Icon(FluentSystemIcons.ic_fluent_mail_add_regular),
                            Gap(AppLayout.getWidth(15)),
                            Text(
                              _userData!['email'] ?? 'No email provided',
                              style: Styles.textStyle4.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                        Gap(AppLayout.getHeight(15)),
                        Row(
                          children: [
                            const Icon(FluentSystemIcons.ic_fluent_phone_mobile_regular),
                            Gap(AppLayout.getWidth(15)),
                            Text(
                              _userData!['phoneNumber'] ?? 'No phone number provided',
                              style: Styles.textStyle4.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                        Gap(AppLayout.getHeight(40)),
                        SizedBox(
                          width: AppLayout.getWidth(200),
                          height: AppLayout.getHeight(50),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfile(userData: _userData!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF8B39),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              "Edit Profile",
                              style: Styles.textStyle3.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        Gap(AppLayout.getWidth(20)),
                        SizedBox(
                          width: AppLayout.getWidth(200),
                          height: AppLayout.getHeight(50),
                          child: ElevatedButton(
                            onPressed: () {
                              _auth.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF8B39),
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              "LogOut",
                              style: Styles.textStyle3.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        Gap(AppLayout.getWidth(20)),
                        const Divider(),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text('No user data found.', style: Styles.textStyle3),
                ),
    );
  }
}
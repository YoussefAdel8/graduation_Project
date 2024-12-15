
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/app_layout.dart';
import '../utils/app_styles.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with the passed userData
    _fullNameController.text = widget.userData['fullName'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _phoneController.text = widget.userData['phoneNumber'] ?? '';
  }

  Future<void> _updateProfile() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Update user data in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          // Optionally, handle password updates in Auth directly
        });

        // Navigate back and show success message
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FluentSystemIcons.ic_fluent_arrow_left_regular),
          color: Colors.black,
        ),
        title: Text("Edit Profile", style: Styles.textStyle3),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: AppLayout.getWidth(500),
            padding: EdgeInsets.all(AppLayout.getWidth(10)),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: AppLayout.getWidth(120),
                      height: AppLayout.getHeight(120),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppLayout.getWidth(100)),
                        child: widget.userData['profileImage'] != null
                            ? Image.network(widget.userData['profileImage'], fit: BoxFit.cover)
                            : const Image(image: AssetImage("assets/images/profile.jpg"), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: AppLayout.getWidth(35),
                        height: AppLayout.getHeight(35),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppLayout.getWidth(100)),
                          color: const Color(0xFFEF8B39),
                        ),
                        child: Icon(
                          FluentSystemIcons.ic_fluent_edit_regular,
                          color: Colors.white,
                          size: AppLayout.getWidth(20),
                        ),
                      ),
                    )
                  ],
                ),
                Gap(AppLayout.getHeight(50)),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          label: const Text("Full Name"),
                          prefixIcon: const Icon(Icons.person_2_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                        ),
                      ),
                      Gap(AppLayout.getHeight(25)),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          label: const Text("Email"),
                          prefixIcon: const Icon(Icons.mail),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                        ),
                      ),
                      Gap(AppLayout.getHeight(25)),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          label: const Text("Phone Number"),
                          prefixIcon: const Icon(Icons.phone_android),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: AppLayout.getWidth(2), color: Styles.orangeColor),
                          ),
                        ),
                      ),
                      Gap(AppLayout.getHeight(40)),
                      SizedBox(
                        width: AppLayout.getWidth(500),
                        height: AppLayout.getHeight(50),
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF8B39),
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            "Save Changes",
                            style: Styles.textStyle3.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

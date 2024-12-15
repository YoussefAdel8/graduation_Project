import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../utils/app_layout.dart';
import '../utils/app_styles.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Login.dart';

class OrganiserPage extends StatelessWidget {
  final String organizerId;

  const OrganiserPage({super.key, required this.organizerId});

  Future<Map<String, dynamic>?> fetchOrganizerDetails(String id) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching organizer details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      appBar: AppBar(
        title: Center(child: Text("Profile", style: Styles.textStyle2)),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchOrganizerDetails(organizerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading details',
                style: Styles.textStyle4.copyWith(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Organizer details not found.',
                style: Styles.textStyle4.copyWith(color: Colors.black),
              ),
            );
          }

          final organizer = snapshot.data!;
          final previousWork = organizer['previous_work'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppLayout.getWidth(6),
                vertical: AppLayout.getHeight(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: AppLayout.getWidth(120),
                        height: AppLayout.getHeight(120),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppLayout.getWidth(100)),
                          child: Image.asset('assets/images/profile.jpg'), // Replace with actual profile image URL if available
                        ),
                      ),
                      Gap(AppLayout.getHeight(40)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            organizer['fullName'] ?? 'Unknown',
                            style: Styles.textStyle3,
                          ),
                          Gap(AppLayout.getHeight(15)),
                          Text(
                            organizer['email'] ?? 'No email provided',
                            style: Styles.textStyle4.copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(AppLayout.getHeight(40)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("experience", style: Styles.textStyle2.copyWith(color: Colors.black)),
                        Gap(AppLayout.getHeight(15)),
                        Text(
                          organizer['experience'] ?? 'No experience provided',
                          style: Styles.textStyle4.copyWith(color: Colors.grey.shade900),
                        ),
                        Gap(AppLayout.getHeight(35)),
                        Text("Phone Number", style: Styles.textStyle2.copyWith(color: Colors.black)),
                        Gap(AppLayout.getHeight(15)),
                        Text(
                          organizer['phoneNumber'] ?? 'No phone number provided',
                          style: Styles.textStyle4.copyWith(color: Colors.grey.shade900),
                        ),
                        Gap(AppLayout.getHeight(35)),
                        Text("Previous Work", style: Styles.textStyle2.copyWith(color: Colors.black)),
                        Gap(AppLayout.getHeight(15)),
                        ImageSlideshow(
                          width: AppLayout.getWidth(600),
                          height: AppLayout.getHeight(300),
                          children: previousWork.isNotEmpty
                              ? previousWork.map((work) {
                                  return Image.network(work, fit: BoxFit.cover);
                                }).toList()
                              : [
                                  Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover),
                                ],
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
    );
  }
}
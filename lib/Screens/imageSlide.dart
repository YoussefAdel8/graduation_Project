
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_app/Screens/OrganizerReg.dart';
import 'package:first_app/Screens/Register.dart';
import 'package:first_app/utils/app_styles.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import '../screens/category.dart';
import '../screens/venue_screen.dart';
import '../utils/app_styles.dart';
import '../utils/list.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:gap/gap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_layout.dart';
import 'bottom_bar.dart';
import 'login.dart';
import 'place_view.dart';

class MySlider extends StatefulWidget {
  const MySlider({Key? key}) : super(key: key);

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _navigateToOrganizerRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrganizerRegister()),
    );
  }

  void _navigateToHostRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Register()),
    );
  }

  void _navigateToPlaceView(Map<String, dynamic> placeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlaceView(
                placeData: placeData,
                venueData: {},
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.getWidth(20)),
            child: Column(
              children: [
                Gap(AppLayout.getHeight(40)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: AppLayout.getHeight(55),
                      width: AppLayout.getWidth(55),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppLayout.getWidth(12)),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  "assets/images/icon.jpg"))),
                    )
                  ],
                ),
                Text("Good Morning", style: Styles.textStyle4),
                        Gap(AppLayout.getHeight(7)),
                        Text("Book Venues ? ", style: Styles.textStyle2),

                Gap(AppLayout.getHeight(25)),
                ImageSlideshow(
                    width: AppLayout.getWidth(800),
                    height: AppLayout.getHeight(300),
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                                child: Image.asset(
                                    "assets/images/venue.jpg",
                                    fit: BoxFit.cover)),
                          ),
                          Center(
                              child: TextButton(
                            onPressed: _navigateToHostRegistration,
                            child: Text(
                              "Become a Host",
                              style: Styles.textStyle
                                  .copyWith(color: Colors.white),
                            ),
                          ))
                        ],
                      ),
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                                child: Image.asset(
                                    "assets/images/venue.jpg",
                                    fit: BoxFit.cover)),
                          ),
                          Center(
                              child: TextButton(
                            onPressed: _navigateToOrganizerRegistration,
                            child: Text(
                              "Become an Organizer",
                              style: Styles.textStyle
                                  .copyWith(color: Colors.white),
                            ),
                          ))
                        ],
                      ),
                    ]),
                
              ],
            ),
          ),
          Gap(AppLayout.getHeight(1)),
        ],
    );
  }

  
}

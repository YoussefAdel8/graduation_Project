import 'dart:io';

import '../utils/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/app_styles.dart';

class VenueScreen extends StatelessWidget {
  final Map<String, dynamic>? venueData;

  const VenueScreen({Key? key, required this.venueData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);

    // Handle the case when venueData is null
    if (venueData == null) {
      // Return a placeholder or an error message
      return Container(
        width: size.width * 0.8,
        height: AppLayout.getHeight(280),
        child: Text('Venue data not available'),
      );
    }

    // Access the properties of venueData using the null-aware operator
    final List<dynamic>? images = venueData!['images'];
    final String name = venueData!['name'] ?? '';
    final String place = venueData!['address'] ?? '';
    final int seats = venueData!['capacity'] ?? 0;
    final int price = venueData!['capacity'] ?? 0;
    print(images![0]);

    return SafeArea(
      child: Container(
        width: size.width * 0.8,
        height: AppLayout.getHeight(300),
        padding: EdgeInsets.symmetric(
          horizontal: AppLayout.getWidth(50),
          vertical: AppLayout.getHeight(20),
        ),
        margin: EdgeInsets.only(
          right: AppLayout.getWidth(20),
          top: AppLayout.getHeight(5),
        ),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(AppLayout.getWidth(24)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(137, 255, 119, 0),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppLayout.getHeight(150),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final String imageUrl = images[index];
                  return Container(
                    margin: EdgeInsets.only(right: AppLayout.getWidth(35)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppLayout.getWidth(12)),
                      color: Colors.white24,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                    ),
                  );
                },
              ),
            ),
            Gap(AppLayout.getHeight(10)),
            Text(
              "$name  ",
              style: Styles.textStyle3.copyWith(color:  Color.fromARGB(255, 0, 0, 0)),
            ),
            Gap(AppLayout.getHeight(5)),
            Text(
              "Up to $seats seats",
              style: Styles.textStyle4.copyWith(color:  Color.fromARGB(255, 0, 0, 0)),
            ),
            Gap(AppLayout.getHeight(8)),
            Text(
              "\$$price/Hour",
              style: Styles.textStyle5.copyWith(color: Color.fromARGB(255, 0, 0, 0)),
              
            ),
            
          ],
        ),
      ),
    );
  }
}

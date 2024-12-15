import '../utils/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/app_styles.dart';

class Category extends StatelessWidget {
  final Map<String, dynamic> category;
  const Category({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);
    return Container(
      width: size.width * 0.2,
      height: AppLayout.getHeight(100),
      padding: EdgeInsets.symmetric(vertical: AppLayout.getHeight(7)),
      margin: EdgeInsets.only(
          right: AppLayout.getWidth(15),
          top: AppLayout.getHeight(5),
          left: AppLayout.getWidth(10)),
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(AppLayout.getWidth(20)),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.7,
              spreadRadius: 0.5,
            )
          ]),
      child: Column(
        children: [
          Container(
            height: AppLayout.getHeight(45),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage("${category['image']}"))),
          ),
          const Gap(5),
          Text("${category['title']}",
              style: Styles.textStyle5.copyWith(color: Colors.black),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

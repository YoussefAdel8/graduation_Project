import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceDetailPage extends StatelessWidget {
  final String placeId;

  PlaceDetailPage({required this.placeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Details'),
        backgroundColor: Color(0xFFEF8B39),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('places').doc(placeId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final placeData = snapshot.data?.data() as Map<String, dynamic>?;
          if (placeData == null) {
            return Center(child: Text('Place not found'));
          }

          final String name = placeData['name'] ?? 'No Name';
          final String description = placeData['description'] ?? 'No Description';
          final String imageUrl = placeData['images']?.first ?? '';
          final int capacity = placeData['capacity'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(imageUrl,width: 400,height: 400,),
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(description),
                SizedBox(height: 10),
                Text('Capacity: $capacity'),
              ],
            ),
          );
        },
      ),
    );
  }
}

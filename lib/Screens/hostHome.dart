import 'package:first_app/Screens/Login.dart';
import 'package:first_app/Screens/placeDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'AddPlace.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int capacity;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.capacity,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      imageUrl: data['images']?.first ?? '',
      capacity: data['capacity'] ?? 0,
    );
  }
}

class HostHome extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Places'),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('places')
              .where('hostId', isEqualTo: userId) // Filter by hostId
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final List<Place> places = snapshot.data!.docs
                .map((doc) => Place.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final Place place = places[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(place.imageUrl),
                  ),
                  title: Text(place.name),
                  subtitle: Text(place.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailPage(placeId: place.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      // Add two FloatingActionButton widgets
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Logout button
          FloatingActionButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(), // Adjust to your Add Place screen
                ),
              ); // Adjust the route name accordingly
            },
            backgroundColor: const Color(0xFFEF8B39),
            child: const Icon(Icons.exit_to_app),
          ),
          const SizedBox(width: 16), // Add some spacing between the buttons
          // Add Place button
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPlaceScreen(), // Adjust to your Add Place screen
                ),
              );
            },
            backgroundColor: const Color(0xFFEF8B39),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

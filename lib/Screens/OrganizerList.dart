import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../utils/app_layout.dart';
import '../utils/app_styles.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'newOrg.dart';
import 'orgProfile.dart';

class Organizer {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  Organizer({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Organizer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Organizer(
      id: doc.id,
      name: data['fullName'] ?? 'No Name',
      description: data['experience'] ?? 'No Description',
      imageUrl: data['previous_work']?.first?.toString() ?? '',
    );
  }
}

class OrganizerListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer List'),
        backgroundColor: Color(0xFFEF8B39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .where('userType', isEqualTo: 'organizer')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final List<Organizer> organizers = snapshot.data!.docs
                .map((doc) => Organizer.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: organizers.length,
              itemBuilder: (context, index) {
                final Organizer organizer = organizers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(organizer.imageUrl),
                  ),
                  title: Text(organizer.name),
                  subtitle: Text(organizer.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganiserPage(organizerId: organizer.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ignore_for_file: file_names, library_private_types_in_public_api, deprecated_member_use

import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  String _name = '';
  String _address = '';
  String _description = '';
  int _capacity = 0;
  final List<File> _images = [];
  final List<String> items = [
    'Indoor',
    'Outdoor',
    'Cafe',
  ];
  String? selectedValue;

  Future<void> _addImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _images.add(File(pickedImage.path));
      });
    }
  }

  Future<void> _uploadImages(List<File> images) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final placeImagesRef = storage.ref().child('place_images');

    List<String> imageUrls = [];

    for (var imageFile in images) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadTask = placeImagesRef.child(fileName).putFile(imageFile);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    _savePlace(imageUrls);
  }

Future<void> _savePlace(List<String> imageUrls) async {
  final placesCollection = FirebaseFirestore.instance.collection('places');

  // Get the current user's ID (hostId)
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    // Handle the case when the user is not logged in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  // Prepare the place data with hostId included
  final placeData = {
    'name': _name,
    'address': _address,
    'description': _description,
    'capacity': _capacity,
    'images': imageUrls,
    'type': selectedValue,
    'hostId': userId,  // Add the hostId here
  };

  // Save the place data to Firestore
  try {
    await placesCollection.add(placeData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Place added successfully!')),
    );

    // Clear the form fields and images list
    setState(() {
      _name = '';
      _address = '';
      _description = '';
      _capacity = 0;
      _images.clear();
      selectedValue = null;
    });
  } catch (e) {
    print('Error saving place data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save place data: $e')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Place Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _address = value;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Place Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _capacity = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Select Item',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              items: items
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              value: selectedValue,
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value;
                });
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                width: 140,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFFEF8B39),
                    ),
                  ),
                  child: const Text('Add Image from Gallery'),
                  onPressed: () {
                    _addImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(width: 5.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFFEF8B39),
                    ),
                  ),
                  child: const Text('Add Image from Camera'),
                  onPressed: () {
                    _addImage(ImageSource.camera);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.file(_images[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color(0xFFEF8B39),
                ),
              ),
              child: const Text('Save'),
              onPressed: () {
                _uploadImages(_images);
              },
            ),
          ],
        ),
      ),
    );
  }
}

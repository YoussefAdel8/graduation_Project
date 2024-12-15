// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dob_input_field/dob_input_field.dart';
import 'package:first_app/Screens/Login.dart';
import 'package:first_app/Screens/orgProfile.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizerRegister extends StatefulWidget {
  const OrganizerRegister({Key? key}) : super(key: key);

  @override
  _OrganizerRegisterState createState() => _OrganizerRegisterState();
}

class _OrganizerRegisterState extends State<OrganizerRegister> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  List<File> _images = [];
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';
  String _experience = '';
  DateTime? _birthday;
Future<void> _addImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _images.add(File(pickedImage.path));
      });
    }
  }


Future<void> _registerWithEmailAndPassword() async {
  try {
    // Create user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    );

    // Get UID of the newly created user
    final uid = userCredential.user!.uid;

    // Upload images and save organizer data after successful registration
    await _uploadImages(_images, uid); // Pass the UID to save the organizer data

    // After saving images and organizer data, create the user document
    await _saveUser(uid);

  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      _showErrorDialog('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      _showErrorDialog('The account already exists for that email.');
    }
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> _saveUser(String uid) async {
  try {
    // Create a new document for the user in the 'users' collection
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(uid).set({
      'fullName': _fullName,
      'email': _email,
      'userType': 'organizer',
      'experience':_experience,
      'phoneNumber':_phoneNumber, // Set userType as 'organizer'
    });
  } catch (e) {
    print("Error saving user document: $e");
  }
}

Future<void> _uploadImages(List<File> images, String uid) async {
  final storage = firebase_storage.FirebaseStorage.instance;
  final organizerImagesRef = storage.ref().child('organizer_images');

  List<String> imageUrls = [];

  for (var imageFile in images) {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadTask = organizerImagesRef.child(fileName).putFile(imageFile);

    try {
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // Once all images are uploaded, save organizer data
  if (imageUrls.isNotEmpty) {
    await _saveOrganizer(uid, imageUrls); // Save organizer data with images
  } else {
    print("No images uploaded successfully");
  }
}

Future<void> _saveOrganizer(String uid, List<String> imageUrls) async {
  final organizersCollection = FirebaseFirestore.instance.collection('organizers');

  final organizerData = {
    'full_name': _fullName,
    'email': _email,
    'phone_number': _phoneNumber,
    'experience': _experience,
    'birthday': _birthday,
    'previous_work': imageUrls,
  };

  try {
    await organizersCollection.doc(uid).set(organizerData);
    _showSuccessDialog(); // Show success dialog
  } catch (e) {
    print("Error saving organizer data: $e");
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Success'),
        content: const Text('Organizer registered successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to the organizer's profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganiserRequest(organizerId: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(17),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Organizer Sign up",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFFEF8B39),
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _fullName = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your full name";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(value)) {
                      return "Please enter a valid email";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty ||
                        !RegExp(r'^01\d{1}[0-9]{8}$').hasMatch(value)) {
                      return "Please enter a valid phone number";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  obscureText: passwordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter password",
                    prefixIcon: const Icon(Icons.fingerprint_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a password";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Experience',
                    prefixIcon: Icon(Icons.add_task_rounded),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _experience = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your experience";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 30),
                DOBInputField(
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  showLabel: true,
                  showCursor: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  fieldLabelText: "Birthday",
                  inputDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  onDateSubmitted: (DateTime? date) {
                    setState(() {
                      _birthday = date;
                    });
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  width: 130,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFEF8B39),
                      ),
                    ),
                    child: const Text('Add Image',style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      _addImage(ImageSource.gallery);
                    },
                  ),
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
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFEF8B39),
                      ),
                    ),
                    child: const Text('Register',style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerWithEmailAndPassword();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

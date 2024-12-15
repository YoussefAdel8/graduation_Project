import 'package:first_app/Screens/AddPlace.dart';
import 'package:first_app/Screens/Home1.dart';
import 'package:first_app/Screens/bottom_bar.dart';
import 'package:first_app/Screens/hostHome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'orgProfile.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseAuth = FirebaseAuth.instance;

  UserType _selectedUserType = UserType.traditional;

  String _enteredEmail = '';
  String _enteredPassword = '';
  String _fullName = '';
  String _phoneNumber = '';
  DateTime? _birthdate;

  bool _passwordVisible = true;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        // Save user data to the database based on the selected user type
        final userId = userCredentials.user!.uid;
        await saveUserDataToDatabase(userId);
        // Navigate to the appropriate home screen based on the selected user type
        navigateToHomeScreen(_selectedUserType);
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ));
      }
    }
  }

  Future<void> saveUserDataToDatabase(String userId) async {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  
  // Using the userId to create the document
  final DocumentReference newUserDoc = usersCollection.doc(userId);

  final userData = {
    'fullName': _fullName,
    'email': _enteredEmail,
    'phoneNumber': _phoneNumber,
    'birthDate': _birthdate?.toString(),
    'userType': _selectedUserType.toString().split('.').last,  // Save userType as a string
  };

  // Save user data to the Firestore collection
  try {
    await newUserDoc.set(userData);
    print('User data saved successfully');
  } catch (e) {
    print('Error saving user data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save user data.')),
    );
  }
}

  void navigateToHomeScreen(UserType userType) {
  switch (userType) {
    case UserType.traditional:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
      break;
    case UserType.host:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HostHome()),
      );
      break;
    case UserType.organizer:
      final userId = FirebaseAuth.instance.currentUser?.uid;  // Get the current user's UID
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrganiserRequest(organizerId: userId),  // Pass the dynamic userId
          ),
        );
      } else {
        // Handle the case when the userId is null (shouldn't happen if user is logged in)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("User ID not found."),
        ));
      }
      break;
  }
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(17),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 39,
                      color: Color(0xFFEF8B39),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _fullName = newValue!;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredEmail = newValue!;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                    obscureText: _passwordVisible,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredPassword = newValue!;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your phone number";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _phoneNumber = newValue!;
                    },
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _birthdate = pickedDate;
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Birthdate',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.date_range),
                        ),
                        validator: (value) {
                          if (_birthdate == null) {
                            return 'Please select your birthdate';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text:
                              _birthdate != null ? _birthdate!.toString() : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<UserType>(
                    value: _selectedUserType,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (UserType? newValue) {
                      setState(() {
                        _selectedUserType = newValue!;
                      });
                    },
                    items: UserType.values
                        .map<DropdownMenuItem<UserType>>((UserType value) {
                      return DropdownMenuItem<UserType>(
                        value: value,
                        child: Text(value.toShortString()),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'User Type',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor:const Color(0xFFEF8B39)),
                      onPressed: _submit,
                      child: const Text('Register',style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum UserType {
  traditional,
  host,
  organizer,
}

extension UserTypeExtension on UserType {
  String toShortString() {
    return toString().split('.').last;
  }
}

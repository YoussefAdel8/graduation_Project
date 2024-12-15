// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'AddPlace.dart';
import 'Home1.dart';
import '../Screens/Register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrganizerList.dart';
import 'bottom_bar.dart';
import 'hostHome.dart';
import 'orgProfile.dart';
final _firebaseAuth = FirebaseAuth.instance;


class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool passwordVisible = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  UserType _selectedUserType = UserType.traditional; // Added user type field
  final _form = GlobalKey<FormState>();

void _submit(BuildContext context) async {
  // Validate the form
  var isValid = _form.currentState!.validate();
  if (!isValid) return;

  _form.currentState!.save();

try {
      // Sign in user with email and password (Firebase Authentication)
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      // Get the logged-in user
      final user = userCredential.user!;

      // Verify if the user exists in the Firestore "users" collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // User exists, check the user type
        final userType = userDoc.data()!['userType'];

        // Check user type
        if (_selectedUserType.toString().split('.').last != userType) {
          // User type mismatch
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Please select the correct user type.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
          return;
        }

        // Navigate based on user type
        switch (userType) {
          case 'traditional':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
            break;
          case 'host':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  HostHome()),
            );
            break;
          case 'organizer':
            // Replace with your organizer specific screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OrganiserRequest(organizerId: 'oF14LZECrtVENgzF22Tu')),
            );
            break;
          default:
            throw 'Invalid user type: $userType';
        }
      } else {
        // User not found in "users" collection
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: const Text('User not found. Please check your credentials.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth errors
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Login failed: ${e.message}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      print('Login error: $e');
    } catch (e) {
      // Handle general errors
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color(0xFFEF8B39),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _form,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "Enter Email",
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return "Please enter correct email";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        obscureText: passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter Password",
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
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<UserType>(
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedUserType,
                        items: UserType.values.map((UserType userType) {
                          return DropdownMenuItem<UserType>(
                            value: userType,
                            child: Text(userType.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (UserType? newValue) {
                          setState(() {
                            _selectedUserType = newValue!;
                          });
                        },
                        validator: (UserType? value) {
                          if (value == null) {
                            return 'Please select a user type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 53,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.grey.withOpacity(0.5),
                            primary: const Color(0xFFEF8B39),
                          ),
                          onPressed: () => _submit(context),
                          child: Text(
                            "Login".toUpperCase(),style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Register(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't Have An Account? ",
                            style: Theme.of(context).textTheme.bodyText1,
                            children: const [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFFEF8B39),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
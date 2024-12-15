import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/User_image_picker.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var isLoging = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  final _form = GlobalKey<FormState>();
  void _submit() async {
    var _isValid = _form.currentState!.validate();
    if (!_isValid || !isLoging) {
      return;
    }
    _form.currentState!.save();
    try {
      if (isLoging) {
        print('i am in login');
        final UserCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
      print('i am in sign up');
      final userCradentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      final Storagefile = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCradentials.user!.uid}.jpg');
      await Storagefile.putFile(_selectedImage!);
      final imageUrl = await Storagefile.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCradentials.user!.uid)
          .set({
        'userName': 'to be done',
        'email': _enteredEmail,
        'image': imageUrl,
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'auth failed!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 30),
              width: 200,
              child: Image.asset('assets/images/waiting.png'),
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isLoging)
                          UserImage(
                            onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'please enter a valid password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _submit,
                            child: Text(isLoging ? 'login' : 'signup')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                isLoging = !isLoging;
                              });
                            },
                            child: Text(isLoging
                                ? 'create a new account'
                                : 'already have account'))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}

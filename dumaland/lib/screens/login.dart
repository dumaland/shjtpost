import 'package:flutter/material.dart';
import '../logic/authentication.dart';
import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthenticationService _authenticationService = AuthenticationService();

  bool _isSignUp = false;

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Replace with your desired icon
            onPressed: () {
              // Handle button press
            },
          ),
        ],
        leading: Image.asset('assets/imgs/mini-5.png'),
        title: Text(
          _isSignUp ? 'Signing Up' : 'Please Login to use our services',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: kIsWeb
              ? MediaQuery.of(context).size.width * 0.3
              : MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              if (_isSignUp) ...[
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 0.5)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Set the button's text color
                  elevation: 4, // Set the button's elevation
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0), // Adjust the button's padding
                ),
                onPressed: () async {
                  final String email = _emailController.text.trim();
                  final String password = _passwordController.text;

                  if (_isSignUp) {
                    final String confirmPassword =
                        _confirmPasswordController.text;
                    if (password == confirmPassword) {
                      if (password.length < 6) {
                        setState(() {
                          _errorMessage = 'Password is too short.';
                        });
                      } else {
                        final bool isEmailTaken = await _authenticationService
                            .checkIfEmailTaken(email);
                        if (isEmailTaken) {
                          setState(() {
                            _errorMessage = 'Email is invalid.';
                          });
                        } else {
                          final String? uid = await _authenticationService
                              .signUpWithEmailAndPassword(
                            email,
                            password,
                          );
                          if (uid != null) {
                            _showSignUpSuccessDialog();
                          } else {
                            setState(() {
                              _errorMessage = 'Failed to sign up.';
                            });
                          }
                        }
                      }
                    } else {
                      setState(() {
                        _errorMessage = 'Passwords do not match.';
                      });
                    }
                  } else {
                    final String? uid = await _authenticationService
                        .signInWithEmailAndPassword(email, password);
                    if (uid != null) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Failed'),
                            content:
                                const Text('Check your email or password.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                child: Text(
                  _isSignUp ? 'Sign Up' : 'Login',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Visibility(
                visible: _errorMessage != null,
                child: Text(
                  _errorMessage ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              //sign up button
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account/Sign in'
                      : 'Create a new account',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              //forgot password button
            ],
          ),
        ),
      ),
    );
  }

  void _showSignUpSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Successful'),
          content:
              const Text('Please check your email and verify your account.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _isSignUp = false;
                  _errorMessage = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

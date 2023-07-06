import 'package:flutter/material.dart';
import '../logic/authentication.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Replace with your desired icon
            onPressed: () {
              // Handle button press
            },
          ),
        ],
        leading: Image.asset('assets/images/mini-5.png'),
        title: Text(
          _isSignUp ? 'Signing Up' : 'Please Login to use our services',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            if (_isSignUp) ...[
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
            ],
            ElevatedButton(
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
                      final bool isEmailTaken =
                          await _authenticationService.checkIfEmailTaken(email);
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
                          content: const Text('Invalid email or password.'),
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
              child: Text(_isSignUp ? 'Sign Up' : 'Login'),
            ),
            Visibility(
              visible: _errorMessage != null,
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                  _errorMessage = null; // Clear error message
                });
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account/Sign in'
                    : 'Create a new account',
              ),
            ),
          ],
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
                  _isSignUp = false; // Navigate back to sign-in screen
                  _errorMessage = null; // Clear error message
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

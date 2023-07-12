import 'package:dumaland/screens/loading.dart';
import 'package:flutter/material.dart';
import '../logic/authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthenticationService _authenticationService = AuthenticationService();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isSignUp = false;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        leading: Lottie.network(
          'https://assets6.lottiefiles.com/packages/lf20_jpxsQh.json',
        ),
        title: Text(
          _isSignUp ? 'Signing Up' : 'Welcome to WjbuVerse',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingScreen()
          : Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.network(
                        'https://assets1.lottiefiles.com/packages/lf20_a2chheio.json',
                        width: 200,
                        height: 200,
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: textinputdecorations.copyWith(
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        decoration: textinputdecorations.copyWith(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      const SizedBox(height: 16.0),
                      if (_isSignUp) ...[
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: textinputdecorations.copyWith(
                            labelText: 'Confirm Password',
                          ),
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Colors.blue, // Set the button's text color
                            elevation: 4, // Set the button's elevation
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal:
                                    32.0), // Adjust the button's padding
                          ),
                          onPressed: () async {
                            final String email = _emailController.text.trim();
                            final String password = _passwordController.text;
                            final String confirmPassword =
                                _confirmPasswordController.text;

                            setState(() {
                              _toggleLoading(); // Call _toggleLoading to start the loading state
                              _errorMessage = null; // Reset the error message
                            });

                            if (_isSignUp) {
                              // Perform sign up logic
                              if (password != confirmPassword) {
                                setState(() {
                                  _errorMessage = 'Passwords do not match.';
                                  _toggleLoading(); // Call _toggleLoading to stop the loading state
                                });
                              } else if (password.length < 6) {
                                setState(() {
                                  _errorMessage = 'Password is too short.';
                                  _toggleLoading(); // Call _toggleLoading to stop the loading state
                                });
                              } else {
                                final bool isEmailTaken =
                                    await _authenticationService
                                        .checkIfEmailTaken(email);
                                if (!isEmailTaken) {
                                  setState(() {
                                    _errorMessage = 'Email is invalid.';
                                    _toggleLoading(); // Call _toggleLoading to stop the loading state
                                  });
                                } else {
                                  final bool success =
                                      await _authenticationService
                                          .signUpWithEmailAndPassword(
                                              email, password);
                                  if (success) {
                                    _showSignUpSuccessDialog();
                                    _toggleLoading();
                                  } else {
                                    setState(() {
                                      _errorMessage = 'Failed to sign up.';
                                      _toggleLoading(); // Call _toggleLoading to stop the loading state
                                    });
                                  }
                                }
                              }
                            } else {
                              // Perform sign in logic
                              final BuildContext dialogContext = context;
                              final String? uid = await _authenticationService
                                  .signInWithEmailAndPassword(email, password);
                              if (uid != null) {
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                // ignore: use_build_context_synchronously
                                showDialog(
                                  context: dialogContext,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Login Failed'),
                                      content: const Text(
                                          'Check your email or password.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                setState(() {
                                  _toggleLoading(); // Call _toggleLoading to stop the loading state
                                });
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
                      ),
                      const SizedBox(height: 16.0),

                      Visibility(
                        visible: _errorMessage != null,
                        child: Text(
                          _errorMessage ?? '',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 20),
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
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EmailInputDialog();
                            },
                          );
                        },
                        child: const Text('I forgot my password',
                            style: TextStyle(fontSize: 17)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
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

class EmailInputDialog extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final AuthenticationService _authenticationService = AuthenticationService();

  EmailInputDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recover your password'),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: textinputdecorations.copyWith(
          labelText: 'Email',
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final String enteredEmail = _emailController.text;
                final bool isEmailTaken = await _authenticationService
                    .checkIfEmailTaken(enteredEmail);
                if (isEmailTaken) {
                  await _authenticationService.resetPassword(enteredEmail);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please check your email'),
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Email not found'),
                        content: const Text(
                            'No user found with this email, please check again'),
                        actions: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Send password reset email'),
            ),
          ),
        ),
      ],
    );
  }
}

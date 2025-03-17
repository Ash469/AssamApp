import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endgame/components/app_bar.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEmailLogin = true; // Toggle between email and phone login
  bool _isPasswordVisible = false;

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement your login logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attempting to login...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'User Login'),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User login logo or image
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                // Login header
                Text(
                  'User Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email/Phone toggle
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Email'),
                            icon: Icon(Icons.email),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Phone'),
                            icon: Icon(Icons.phone),
                          ),
                        ],
                        selected: {_isEmailLogin},
                        onSelectionChanged: (Set<bool> selection) {
                          setState(() {
                            _isEmailLogin = selection.first;
                            _emailPhoneController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Email or Phone field
                      TextFormField(
                        controller: _emailPhoneController,
                        maxLength: _isEmailLogin ? null : 10,
                        decoration: InputDecoration(
                          labelText: _isEmailLogin
                              ? 'Email'
                              : 'Phone Number (10 digits)',
                          prefixIcon:
                              Icon(_isEmailLogin ? Icons.email : Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: _isEmailLogin ? null : '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _isEmailLogin
                                ? 'Please enter your email'
                                : 'Please enter your phone number';
                          }
                          if (_isEmailLogin && !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          if (!_isEmailLogin) {
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Phone number must be exactly 10 digits';
                            }
                          }
                          return null;
                        },
                        inputFormatters: _isEmailLogin
                            ? []
                            : [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password logic
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      ElevatedButton(
                        onPressed: _attemptLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(1, 103, 104, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 16),
                          textStyle: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          minimumSize: const Size(180, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
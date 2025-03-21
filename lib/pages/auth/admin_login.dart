import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endgame/components/app_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endgame/pages/admin/admin_home.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEmailLogin = true; // Toggle between email and phone login
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logging in...'),
            duration: Duration(seconds: 2),
          ),
        );

        final response = await http.post(
          Uri.parse('http://192.168.128.52:3000/api/admin/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'identifier': _emailPhoneController.text,
            'password': _passwordController.text,
          }),
        );

        ScaffoldMessenger.of(context).clearSnackBars();
        final responseData = json.decode(response.body);

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('adminToken', responseData['token']);
          
          final adminData = {
            'firstname': responseData['admin']['firstName'],
            'email': responseData['admin']['email'],
            'adminId': responseData['admin']['adminId'],
          };
          await prefs.setString('adminData', json.encode(adminData));

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${adminData['firstname']}!'),
              backgroundColor: Colors.green,
            ),
          );

          // Replace this named route navigation
          // Navigator.of(context).pushReplacementNamed('/admin/dashboard');
          
          // With direct navigation to the AdminHome page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminHome()),
          );
        } else {
          String errorMessage = responseData['message'] ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error: Please check your internet connection'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Login'),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Admin login logo or image
                Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                // Login header
                Text(
                  'Admin Login',
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
                        // keyboardType: _isEmailLogin
                        //     ? TextInputType.emailAddress
                        //     : TextInputType.number,
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/homepage.dart' as home_page;
import 'package:endgame/components/app_bar.dart';
import 'dart:convert';

/*
  **Login Page**
  1. User enters username and password and clicks "Login"
  2. User receives OTP on phone number and enters it to complete login
*/
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpLogin = false; // Toggle between login methods
  String? _errorMessage;
  String? _serverOtp; // Store OTP received from backend
  String? _sessionId; // Store sessionId received from backend

  // **Login with Username & Password**
  Future<void> loginWithUsernamePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both username and password";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://192.168.11.13:3000/api/credentials-login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page.HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = data["error"] ?? "Invalid credentials";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // **Send OTP and Store sessionId**
  Future<void> sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      setState(() {
        _errorMessage = "Enter a valid 10-digit phone number";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://192.168.11.13:3000/api/login-phone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phoneNumber}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _serverOtp = data["otp"].toString(); // Store OTP received from backend
        _sessionId = data["phone"]; // Store sessionId received from backend

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully")),
        );
      } else {
        setState(() {
          _errorMessage = data["error"] ?? "Failed to send OTP";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // **Verify OTP & Complete Login**
  Future<void> verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String enteredOtp = _otpController.text.trim();

    if (enteredOtp.isEmpty || enteredOtp.length != 6) {
      setState(() {
        _errorMessage = "Enter a valid 6-digit OTP";
        _isLoading = false;
      });
      return;
    }

    if (enteredOtp != _serverOtp) {
      setState(() {
        _errorMessage = "Invalid OTP";
        _isLoading = false;
      });
      return;
    }

    // **Proceed with login after OTP verification**
    try {
      final response = await http.post(
        Uri.parse("http://192.168.11.13:3000/api/verify-phone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": _sessionId, "otp": enteredOtp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful! Redirecting...")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page.HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = data["error"] ?? "OTP verification failed";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // **Switch between login methods**
  void toggleLoginMethod() {
    setState(() {
      _isOtpLogin = !_isOtpLogin;
      _errorMessage = null; // Reset errors when switching
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Welcome Back'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Image
              const SizedBox(height: 40),
              Icon(
                Icons.account_circle,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 22),

              // Login Method Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: !_isOtpLogin
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        child: TextButton(
                          onPressed: () => setState(() => _isOtpLogin = false),
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: !_isOtpLogin ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: _isOtpLogin
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        child: TextButton(
                          onPressed: () => setState(() => _isOtpLogin = true),
                          child: Text(
                            "OTP",
                            style: TextStyle(
                              color: _isOtpLogin ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Login Forms
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: !_isOtpLogin
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild:_buildPasswordLogin(),
                secondChild: _buildOtpLogin(),
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordLogin() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: "Username",
            // floatingLabelStyle:
            //     // const TextStyle(fontSize: 22, color: Colors.black),
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : loginWithUsernamePassword,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            backgroundColor: const Color.fromRGBO(1, 103, 103, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text("Login",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildOtpLogin() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "Phone Number",
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : sendOtp,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15.0),
            backgroundColor: const Color.fromRGBO(1, 103, 103, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text("Send OTP",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        if (_serverOtp != null) ...[
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter OTP",
              prefixIcon: const Icon(Icons.lock_clock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : verifyOtp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15.0),
              backgroundColor: const Color.fromRGBO(1, 103, 103, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text("Verify OTP",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ],
    );
  }
}

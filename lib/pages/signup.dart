import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/components/app_bar.dart';
import 'dart:convert';

import 'package:endgame/homepage.dart' as home_page;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int _step = 1; // 1 = Signup Form, 2 = OTP Verification

  // **Send OTP and Register User**
  Future<void> sendOtp() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final String phoneNumber = _phoneController.text.trim();

  if (phoneNumber.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
    setState(() {
      _errorMessage = "Enter a valid 10-digit phone number";
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("http://192.168.11.13:3000/api/request-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phoneNumber}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _step = 2; // Move to OTP verification step
      });

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
  // **Verify OTP and Complete Signup**
  Future<void> verifyOtp() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final String otp = _otpController.text.trim();
  final String username = _usernameController.text.trim();
  final String password = _passwordController.text.trim();
  final String phoneNumber = _phoneController.text.trim();

  if (otp.isEmpty || otp.length != 6) {
    setState(() {
      _errorMessage = "Enter a valid 6-digit OTP";
      _isLoading = false;
    });
    return;
  }

  if (username.isEmpty || password.length < 6) {
    setState(() {
      _errorMessage = "Username and password (min 6 chars) required";
      _isLoading = false;
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse("http://192.168.11.13:3000/api/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phoneNumber,
        "otp": otp,
        "username": username,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful! Redirecting...")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const home_page.HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = data["error"] ?? "Invalid OTP";
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


  @override
  Widget build(BuildContext context) {
    // Add state variable for password visibility
    bool passwordVisible = false;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Sign Up'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_step == 1) ...[
              // **Username Input**

              // **Phone Number Input**
              TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter your 10-digit mobile number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              ),
              const SizedBox(height: 16),

              // **Send OTP Button**
              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color.fromRGBO(1, 103, 103, 1),
                ),
                onPressed: _isLoading ? null : sendOtp,
                child: _isLoading 
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Send OTP", style: TextStyle(fontSize: 16, color: Colors.white)), 
              ),
              ),
            ],
            if (_step == 2) ...[
               const SizedBox(height: 10),
                TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                ),
                // inputFormatters: [
                // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                // ],
                ),
                const SizedBox(height: 16),

              // **Password Input with visibility toggle**
              StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                controller: _passwordController,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    // color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                    passwordVisible = !passwordVisible;
                    });
                  },
                  ),
                ),
                );
              },
              ),
              const SizedBox(height: 16),
              // **OTP Input Step**
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                ),
              ),
              const SizedBox(height: 16),

              // **Verify OTP Button**
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromRGBO(1, 103, 103, 1),
                  ),
                  onPressed: _isLoading ? null : verifyOtp,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify OTP", style: TextStyle(fontSize: 16,color: Colors.white))
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red,fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

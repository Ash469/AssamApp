import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/homepage.dart' as home_page;
import 'dart:convert';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _serverOtp;

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
        Uri.parse("http://192.168.11.13:3000/api/login"), 
        // headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneNumber": phoneNumber}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _serverOtp = data["otp"]; // Store OTP for validation (only for demo purposes)
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

  void verifyOtp() {
    if (_otpController.text.trim() == _serverOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const home_page.HomePage()),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid OTP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter your 10-digit mobile number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : sendOtp,
              child: _isLoading ? const CircularProgressIndicator() : const Text("Send OTP"),
            ),
            if (_serverOtp != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text("Verify OTP"),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

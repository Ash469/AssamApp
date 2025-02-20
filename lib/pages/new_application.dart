import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';

class NewApplication extends StatefulWidget {
  const NewApplication({super.key});

  @override
  State<NewApplication> createState() => _NewApplicationState();
}

class _NewApplicationState extends State<NewApplication> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _documentUrlController = TextEditingController(text: "https://abcd.com/file.png");

  String? _selectedCategory;
  String? _selectedArea;
  String? _selectedGender;

  final List<String> _categories = ['Education', 'Employment', 'Health', 'Disaster Relief', 'Other'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _areas = ['Village' , 'Town' , 'Tehsil' , 'Development Block'];

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      var uri = Uri.parse("http://192.168.11.13:3000/api/applications");
      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": _fullNameController.text.trim(),
          "age": int.tryParse(_ageController.text.trim()) ?? 0,
          "phoneNo": _phoneNoController.text.trim(),
          "gender": _selectedGender ?? "",
          "occupation": _occupationController.text.trim(),
          "address": _addressController.text.trim(),
          "category": _selectedCategory ?? "",
          "area": _selectedArea ?? "",
          "remarks": _remarksController.text.trim(),
          "documenturl": _documentUrlController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        // debugPrint('Created application ID: ${jsonDecode(response.body)['_id']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application Submitted Successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit application: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'New Application'),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(label: 'Full Name', controller: _fullNameController),
                        _buildTextField(label: 'Age', controller: _ageController, keyboardType: TextInputType.number),
                        _buildTextField(label: 'Phone No.', controller: _phoneNoController, keyboardType: TextInputType.phone),
                        _buildDropdownField(
                          label: 'Gender',
                          value: _selectedGender,
                          items: _genders,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        _buildTextField(label: 'Occupation', controller: _occupationController),
                        _buildTextField(label: 'Address', controller: _addressController, maxLines: 2),
                        _buildDropdownField(
                          label: 'Category of application',
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        _buildDropdownField(
                          label: 'Area of residence',
                          value: _selectedArea,
                          items: _areas,
                          onChanged: (value) {
                            setState(() {
                              _selectedArea = value;
                            });
                          },
                        ),
                        _buildTextField(label: 'Add remarks', controller: _remarksController, maxLines: 3),
                        _buildTextField(label: 'Document URL', controller: _documentUrlController, maxLines: 1, validator: _validateDocumentUrl),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await _submitApplication();
              if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Congratulations!'),
                content: const Text('Your application has been submitted successfully.'),
                shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
                ),
                actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); 
              },
              child: const Text('OK'),
            ),
                ],
              );
            },
          );
              }
            // ignore: empty_catches
            } catch (e) {
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Submit Application',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String? _validateDocumentUrl(String? value) {
    final regex = RegExp(r'^(https?:\/\/.*\.(?:png|jpg|jpeg|pdf|docx?))$', caseSensitive: false);
    if (value == null || !regex.hasMatch(value)) {
      return 'Enter a valid document URL (PNG, JPG, PDF, DOC)';
    }
    return null;
  }
}

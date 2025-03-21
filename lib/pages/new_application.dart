import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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
  final TextEditingController _revenueCircleController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _documentUrlController = TextEditingController(text: "https://abcd.com/file.png");

  String? _selectedCategory;
  String? _selectedDistrict;
  String? _selectedVillageWard;
  String? _selectedGender;

  final List<String> _categories = ['Education', 'Employment', 'Health', 'Disaster Relief', 'Other'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _districts = [
    'Baksa', 'Barpeta', 'Biswanath', 'Bongaigaon', 'Cachar', 'Charaideo',
    'Chirang', 'Darrang', 'Dhemaji', 'Dhubri', 'Dibrugarh', 'Dima Hasao',
    'Goalpara', 'Golaghat', 'Hailakandi', 'Hojai', 'Jorhat', 'Kamrup',
    'Kamrup Metropolitan', 'Karbi Anglong', 'Karimganj', 'Kokrajhar',
    'Lakhimpur', 'Majuli', 'Morigaon', 'Nagaon', 'Nalbari', 'Sivasagar',
    'Sonitpur', 'South Salmara-Mankachar', 'Tinsukia', 'Udalguri', 'West Karbi Anglong'
  ];
  final List<String> _villagesWards = ['Village', 'Ward']; // Replace with actual data

  // Add these variables to track the selected file
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  // Add this method to handle file picking
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFileBytes = result.files.single.bytes;
          _documentUrlController.text = _selectedFileName ?? "";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting file: $e")),
      );
    }
  }

  bool _isLoading = false;

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse("http://192.168.128.52:3000/api/applications");
      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": _fullNameController.text.trim(),
          "age": int.tryParse(_ageController.text.trim()) ?? 0,
          "phoneNo": _phoneNoController.text.trim(),
          "gender": _selectedGender ?? "",
          "occupation": _occupationController.text.trim(),
          "district": _selectedDistrict ?? "",
          "revenueCircle": _revenueCircleController.text.trim(),
          "villageWard": _selectedVillageWard ?? "",
          "category": _selectedCategory ?? "",
          "remarks": _remarksController.text.trim(),
          "documentUrl": _documentUrlController.text.trim(), // Changed from documenturl to documentUrl
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        debugPrint('Created application ID: ${jsonDecode(response.body)['_id']}');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Your application has been submitted successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit application: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'New Application'),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                _buildDropdownField(
                  label: 'District of Assam',
                  value: _selectedDistrict,
                  items: _districts,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedVillageWard = null;
                    });
                  },
                ),
                _buildTextField(label: 'Revenue Circle', controller: _revenueCircleController),
                _buildDropdownField(
                  label: 'Village/Ward',
                  value: _selectedVillageWard,
                  items: _villagesWards,
                  onChanged: (value) {
                    setState(() {
                      _selectedVillageWard = value;
                    });
                  },
                ),
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
                _buildTextField(label: 'Add remarks', controller: _remarksController, maxLines: 3,isRequired: false),
                // _buildTextField(label: 'Document URL', controller: _documentUrlController, validator: _validateDocumentUrl),
                _buildDocumentUploadField(),
                const SizedBox(height: 10),
                const Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSubmitButton(),
              ],
            ),
          ),
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
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        validator: validator ?? (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;  // Return null for non-required fields even if empty
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: false,
        menuMaxHeight: 250, // Limit dropdown height
        dropdownColor: Colors.white,
        isDense: true,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please select $label';
          }
          return null;
        },
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10.0),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () async {
          if (_formKey.currentState!.validate()) {
            await _submitApplication();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 3,
        ),
        icon: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.send),
        label: Text(
          _isLoading ? 'SUBMITTING...' : 'SUBMIT APPLICATION',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildDocumentUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Upload *',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? "Upload your document",
                      style: TextStyle(
                        color: _selectedFileName != null ? Colors.black : Colors.grey[600],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_documentUrlController.text.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 12.0),
              child: Text(
                'Please upload a document',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

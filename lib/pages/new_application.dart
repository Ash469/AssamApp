import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:endgame/components/app_bar.dart';
import 'package:endgame/components/app_drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart'; // Add this import at the top of your file

class NewApplication extends StatefulWidget {
  const NewApplication({super.key});

  @override
  State<NewApplication> createState() => _NewApplicationState();
}

class _NewApplicationState extends State<NewApplication> {
  final String apiBaseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.150.54.176:3000';
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _revenueCircleController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _documentUrlController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDistrict;
  String? _selectedVillageWard;
  String? _selectedGender;

  final List<String> _categories = ['Administration', 'Legal', 'Business', 'Disaster Relief','Finance','Education', 'Other'];
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
        withData: true, // Ensure we get the file bytes
      );

      if (result != null) {
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;
        
        debugPrint('Selected file: $fileName, bytes length: ${fileBytes?.length}');
        
        if (fileBytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Could not read file data")),
          );
          return;
        }
        
        setState(() {
          _selectedFileName = fileName;
          _selectedFileBytes = fileBytes;
          _documentUrlController.text = _selectedFileName ?? "";
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
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

    String? documentUrl;
    
    try {
      // First upload the file to Cloudinary if a file was selected
      if (_selectedFileBytes != null && _selectedFileName != null) {
        // Show uploading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Uploading document to cloud...")),
          );
        }
        
        documentUrl = await _uploadToCloudinary(_selectedFileBytes!, _selectedFileName!);
        
        if (documentUrl == null) {
          throw Exception("Failed to upload document");
        }
      } else {
        throw Exception("Please select a document to upload");
      }

      // Create the request payload with all required fields
      final payload = {
        "fullName": _fullNameController.text.trim(),
        "age": int.tryParse(_ageController.text.trim()) ?? 0,
        "contactNumber": _contactNumberController.text.trim(),
        "gender": _selectedGender ?? "",
        "district": _selectedDistrict ?? "",
        "revenueCircle": _revenueCircleController.text.trim(),
        "villageWard": _selectedVillageWard ?? "",
        "category": _selectedCategory ?? "",
        "remarks": _remarksController.text.trim(),
        "documentUrl": documentUrl, // Now we only use the cloudinary URL
      };

      // Log the payload for debugging
      debugPrint('Sending payload: ${jsonEncode(payload)}');

      // Make the API request
      var uri = Uri.parse('$apiBaseUrl/api/applications');
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(payload),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        if (!mounted) return;
        final responseData = jsonDecode(response.body);
        debugPrint('Created application ID: ${responseData['_id']}');
        
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
      debugPrint('Error during submission: $e');
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

  Future<String?> _uploadToCloudinary(Uint8List fileBytes, String fileName) async {
    try {
      final cloudName = 'dwdjnzla2'; // Your Cloudinary cloud name
      final uploadPreset = 'assamoffice'; // Replace with your upload preset
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );
      
      // Add upload preset parameter (for unsigned uploads)
      request.fields['upload_preset'] = uploadPreset;
      
      // Determine file extension and MIME type
      final fileExtension = fileName.split('.').last.toLowerCase();
      String mimeType;
      
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'doc':
          mimeType = 'application/msword';
          break;
        case 'docx':
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        default:
          mimeType = 'application/octet-stream';
      }
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', 
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      // Log request details for debugging
      debugPrint('Sending upload request to Cloudinary...');
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Cloudinary upload success: ${responseData['secure_url']}');
        return responseData['secure_url'];
      } else {
        debugPrint('Cloudinary upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
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
                _buildTextField(label: 'Contact Number', controller: _contactNumberController, keyboardType: TextInputType.phone),
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
                // _buildTextField(label: 'Occupation', controller: _occupationController),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
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
      child: FormField<String>(
        initialValue: _selectedFileName,
        validator: (value) {
          if (_selectedFileBytes == null) {
            return 'Please select a document';
          }
          return null;
        },
        builder: (FormFieldState<String> state) {
          // This ensures state is updated when file is selected
          if (_selectedFileBytes != null && state.hasError) {
            Future.microtask(() => state.validate());
          }
          
          return Column(
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
                onTap: () async {
                  await _pickFile();
                  // Force validation update after picking file
                  state.didChange(_selectedFileName);
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: state.hasError ? Colors.red : Colors.grey),
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
                          _selectedFileName ?? "Select a document to upload",
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
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}


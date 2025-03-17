import 'package:flutter/material.dart';
import 'package:endgame/components/app_bar.dart';

class AdminSignup extends StatefulWidget {
  const AdminSignup({Key? key}) : super(key: key);

  @override
  _AdminSignupState createState() => _AdminSignupState();
}

class _AdminSignupState extends State<AdminSignup> {
  // Current step index
  int _currentStep = 0;
  
  // Form keys for validation
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Text editing controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userIdController = TextEditingController();

  // Gender selection
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];
  
  // Password visibility state
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Dispose controllers when widget is disposed
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  // Validate current step and move to next if valid
  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _formKey1.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _formKey2.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _formKey3.currentState?.validate() ?? false;
        if (isValid) {
          // Handle form submission here
          _submitForm();
          return;
        }
        break;
    }

    if (isValid && _currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Handle form submission
  void _submitForm() {
    // Collect all form data
    final userData = {
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text,
      'lastName': _lastNameController.text,
      'contactNumber': _contactNumberController.text,
      'age': _ageController.text,
      'gender': _selectedGender,
      'email': _emailController.text,
      'password': _passwordController.text,
      'userId': _userIdController.text,
    };
    
    // TODO: Implement the API call or data storage logic
    print('Form submitted: $userData');

    // Show success dialog or navigate to next screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: const CustomAppBar(title: 'Sign Up'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Step ${_currentStep + 1} of 3',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Step content
            Expanded(
              child: SingleChildScrollView(
                child: _buildCurrentStep(),
              ),
            ),
            
            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text('Back'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(1, 103, 104, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    minimumSize: const Size(180, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_currentStep == 2 ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildContactInfoStep();
      case 2:
        return _buildAccountInfoStep();
      default:
        return Container();
    }
  }

  // Step 1: Personal Information
  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your name?',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(20, 48, 74, 1),
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _firstNameController,
            hintText: 'First name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _middleNameController,
            hintText: 'Middle name (optional)',
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _lastNameController,
            hintText: 'Last name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Step 2: Contact Information
  Widget _buildContactInfoStep() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold,
             color: const Color.fromRGBO(20, 48, 74, 1),
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _contactNumberController,
            hintText: 'Contact number',
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your contact number';
              }
              if (value.length != 10) {
                return 'Contact number must be 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _ageController,
            hintText: 'Age',
            keyboardType: TextInputType.number,
            maxLength: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final age = int.tryParse(value);
              if (age == null || age <= 0) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text('Gender', 
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            )
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text('Select gender', style: TextStyle(color: Colors.grey[500])),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Account Information
  Widget _buildAccountInfoStep() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up your account',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(20, 48, 74, 1),
            ),
          ),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _emailController,
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _userIdController,
            hintText: 'Choose a username',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a user ID';
              }
              if (value.length < 4) {
                return 'User ID must be at least 4 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _passwordController,
            hintText: 'Create a password',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Password field with visibility toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: false,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    String? labelText,
    bool obscureText = false,
    String? prefixText,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: prefixText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: false,
            counterText: '', // Hide the counter text
          ),
          validator: validator,
        ),
      ],
    );
  }
}
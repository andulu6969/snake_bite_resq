import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:snake_bite_resq/services/api_service.dart';
import 'package:snake_bite_resq/widgets/fade_in_slide.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  String _selectedHospital = 'Hospital Sultanah Bahiyah';
  String _selectedSpecialization = 'General Practitioner';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const List<String> _kedahHospitals = [
    'Hospital Sultanah Bahiyah',
    'Hospital Sultan Abdul Halim',
    'Hospital Kulim',
    'Hospital Baling',
    'Hospital Sik',
    'Hospital Sultanah Maliha',
    'Hospital Yan',
    'Hospital Jitra',
    'Hospital Kuala Nerang',
    'Hospital Pendang',
  ];

  static const List<String> _specializations = [
    'General Practitioner',
    'Emergency Medicine',
    'Internal Medicine',
    'General Surgery',
    'Orthopedic Surgery',
    'Neurology',
    'Cardiology',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Dermatology',
    'Anesthesiology',
    'Radiology',
    'Pathology',
    'Psychiatry',
    'Ophthalmology',
    'ENT (Ear, Nose, Throat)',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse("${ApiService.baseUrl}/api/register_doctor.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": _usernameController.text.trim(),
              "password": _passwordController.text,
              "full_name": _fullNameController.text.trim(),
              "specialization": _selectedSpecialization,
              "hospital_name": _selectedHospital,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 201 && data['status'] == 'success') {
        _showSuccessDialog();
      } else {
        _showError(data['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Network error. Please check your connection and try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Registration Submitted'),
          ],
        ),
        content: const Text(
          'Your account has been submitted for review.\n\n'
          'An admin will approve your registration shortly. '
          'Once approved, you can log in with your username and password.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Back to login
            },
            child: const Text('Back to Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey.shade50),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.blue.shade700.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.teal.shade600.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.blueGrey.shade700),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Doctor Registration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: FadeInSlide(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 40,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Create Doctor Account',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Your request will be reviewed by an admin',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),
                              _sectionLabel('Personal Information'),
                              const SizedBox(height: 12),

                              // Full Name
                              _buildTextField(
                                controller: _fullNameController,
                                label: 'Full Name (incl. Dr.)',
                                icon: Icons.badge_outlined,
                                hint: 'e.g. Dr. Ahmad bin Razali',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Full name is required';
                                  if (v.trim().length < 5) return 'Enter a valid full name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Specialization
                              _buildDropdown(
                                label: 'Specialization',
                                icon: Icons.medical_services_outlined,
                                value: _selectedSpecialization,
                                items: _specializations,
                                onChanged: (v) => setState(() => _selectedSpecialization = v!),
                              ),
                              const SizedBox(height: 14),

                              // Hospital
                              _buildDropdown(
                                label: 'Assigned Hospital (Kedah)',
                                icon: Icons.local_hospital_outlined,
                                value: _selectedHospital,
                                items: _kedahHospitals,
                                onChanged: (v) => setState(() => _selectedHospital = v!),
                              ),

                              const SizedBox(height: 24),
                              _sectionLabel('Login Credentials'),
                              const SizedBox(height: 12),

                              // Username
                              _buildTextField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.person_outline,
                                hint: 'e.g. dr.ahmad',
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Username is required';
                                  if (v.trim().length < 3) return 'At least 3 characters';
                                  if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v.trim())) {
                                    return 'Only letters, numbers, dots, underscores';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Password
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscure: _obscurePassword,
                                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Confirm Password
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscure: _obscureConfirm,
                                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                validator: (v) {
                                  if (v != _passwordController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              // Info banner
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'After submitting, your account will be pending until approved by the hospital admin.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade900,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'SUBMIT REGISTRATION',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.blue.shade700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

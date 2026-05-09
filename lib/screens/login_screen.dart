import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_bite_resq/services/auth_service.dart';
import 'package:snake_bite_resq/screens/main_screen.dart';
import 'package:snake_bite_resq/screens/admin/admin_main_screen.dart';
import 'package:snake_bite_resq/widgets/fade_in_slide.dart'; // Import Custom Animation
import 'package:snake_bite_resq/utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitIdController = TextEditingController();
  final _passcodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _unitIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _unitIdController.text,
        _passcodeController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          final destination = authService.isAdmin
              ? const AdminMainScreen()
              : const MainScreen();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Access Denied. Check Unit ID or Passcode.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND (Clinical White)
          Container(color: Colors.grey.shade50),

          // 2. DECORATIVE CIRCLES (Background Pattern)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: r.adapt(phone: 200.0, tablet: 300.0),
              height: r.adapt(phone: 200.0, tablet: 300.0),
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
              width: r.adapt(phone: 300.0, tablet: 450.0),
              height: r.adapt(phone: 300.0, tablet: 450.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade600.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. CENTERED LOGIN CARD
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(r.pagePadding),
              child: FadeInSlide(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: r.adapt(phone: 400.0, tablet: 520.0),
                  ),
                  padding: EdgeInsets.all(r.adapt(phone: 32.0, tablet: 44.0)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.9,
                    ), // Glass-like opacity
                    borderRadius: BorderRadius.circular(r.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // LOGO
                        Container(
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: SizedBox(
                            height: r.adapt(phone: 130.0, tablet: 160.0),
                            width: r.adapt(phone: 130.0, tablet: 160.0),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: r.sectionSpacing),

                        // TITLE
                        Text(
                          "SnakeBiteResQ",
                          style: TextStyle(
                            fontSize: r.adapt(phone: 28.0, tablet: 36.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Station Login (Kiosk)",
                          style: TextStyle(
                            fontSize: r.fontMd,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: r.adapt(phone: 40.0, tablet: 52.0),
                        ),

                        // INPUTS
                        _buildTextField(
                          controller: _unitIdController,
                          label: "Unit / Station ID",
                          icon: Icons.apartment_rounded,
                          r: r,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passcodeController,
                          label: "Passcode",
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          r: r,
                        ),
                        SizedBox(
                          height: r.adapt(phone: 32.0, tablet: 44.0),
                        ),

                        // ACTION BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: r.adapt(phone: 56.0, tablet: 68.0),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(r.cardRadius),
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
                                : Text(
                                    "START SHIFT",
                                    style: TextStyle(
                                      fontSize: r.fontLg,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required ResponsiveUtils r,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontSize: r.fontMd,
      ), // Forced Black
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: r.fontMd),
        prefixIcon: Icon(
          icon,
          color: Colors.blue.shade400,
          size: r.iconSizeMd,
        ),
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: r.adapt(phone: 16.0, tablet: 20.0),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Required" : null,
    );
  }
}

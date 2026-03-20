import 'package:flutter/material.dart' hide RadialGradient, Image;
import 'package:flutter/material.dart' as material show RadialGradient, Image;
import 'package:rive/rive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/widgets/custom_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // simulate a small delay for premium feel
    await Future.delayed(const Duration(milliseconds: 800));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      if (mounted) {
        // Await the push so we can catch any errors during transition
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Clean up the error message for UX
          _errorMessage = e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password' 
              ? 'Invalid email or password' 
              : e.message ?? 'Authentication failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: material.RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 450,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mascot Animation
                    const SizedBox(
                      height: 180,
                      width: 180,
                      child: RiveAnimation.asset(
                        'assets/rive/antfly.riv',
                        artboard: 'New Artboard',
                        animations: ['idle'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // iRead Logo / Name
                    material.Image.asset(
                      'assets/iread_text.png',
                      height: 40,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Super Admin Portal',
                      style: AppTextStyles.heading2(context).copyWith(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign In',
                              style: AppTextStyles.heading1(context).copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please enter your credentials to continue',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Username Field
                            _buildTextField(
                              controller: _usernameController,
                              label: 'Email',
                              hint: 'Enter your admin email',
                              icon: Icons.email_outlined,
                              validator: (v) => v!.isEmpty ? 'Enter email' : null,
                            ),
                            const SizedBox(height: 20),
                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              isObscure: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              validator: (v) => v!.isEmpty ? 'Enter password' : null,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red[100]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTextStyles.bodyMedium(context).copyWith(
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 32),
                            // Login Button
                            CustomButton(
                              text: 'SIGN IN',
                              onPressed: _isLoading ? null : _login,
                              icon: _isLoading ? null : Icons.login,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '© 2026 iRead. Optimized for Super Admin.',
                      style: AppTextStyles.bodySmall(context).copyWith(color: Colors.grey[400]),
                    ),
                  ],
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
    required String hint,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          style: AppTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

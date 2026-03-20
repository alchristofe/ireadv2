import 'package:flutter/material.dart' hide RadialGradient, Image;
import 'package:flutter/material.dart' as material show RadialGradient, Image;
import 'package:rive/rive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/responsive_layout.dart';
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
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
    final bool isMobile = ResponsiveLayout.isMobile(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: material.RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.loginCardWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mascot Animation
                    SizedBox(
                      height: isMobile ? 140 : 180,
                      width: isMobile ? 140 : 180,
                      child: const RiveAnimation.asset(
                        'assets/rive/antfly.riv',
                        artboard: 'New Artboard',
                        animations: ['idle'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    AppSpacing.verticalM,
                    
                    // Logo
                    material.Image.asset(
                      'assets/iread_text.png',
                      height: 32,
                      color: AppColors.primary,
                    ),
                    AppSpacing.verticalS,
                    Text(
                      'SUPER ADMIN PORTAL',
                      style: AppTextStyles.label(context).copyWith(
                        color: AppColors.textLight,
                        letterSpacing: 2.0,
                      ),
                    ),
                    AppSpacing.verticalXL,
                    
                    // Login Card
                    Container(
                      padding: EdgeInsets.all(isMobile ? AppSpacing.l : AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.premiumShadow,
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign In',
                              style: AppTextStyles.heading2(context),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.verticalS,
                            Text(
                              'Enter your authorized credentials',
                              style: AppTextStyles.bodyMedium(context),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.verticalXL,
                            
                            // Username Field
                            _buildTextField(
                              controller: _usernameController,
                              label: 'Email Address',
                              hint: 'admin@iread.com',
                              icon: Icons.alternate_email_rounded,
                              validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                            ),
                            AppSpacing.verticalL,
                            
                            // Password Field
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              isObscure: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppColors.textLight,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                            ),
                            
                            if (_errorMessage != null) ...[
                              AppSpacing.verticalL,
                              Container(
                                padding: AppSpacing.edgeInsetsM,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                    AppSpacing.horizontalS,
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            AppSpacing.verticalXL,
                            
                            CustomButton(
                              text: 'SIGN IN TO DASHBOARD',
                              onPressed: _isLoading ? null : _login,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    AppSpacing.verticalXL,
                    Text(
                      '© 2026 iRead Education — Secure Access',
                      style: AppTextStyles.bodySmall(context),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: AppTextStyles.label(context)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textDark),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textLight),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorStyle: AppTextStyles.bodySmall(context).copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

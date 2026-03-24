import 'dart:ui';
import 'package:flutter/material.dart' hide RadialGradient, Image;
import 'package:flutter/material.dart' as material show RadialGradient, Image;
import 'package:rive/rive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate background
      body: Stack(
        children: [
          // Background Gradient Nebula effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: material.RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: material.RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 48,
            left: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/iread_logo_lightv1.svg',
                  height: 38,
                ),
                const SizedBox(height: 4),
                Text(
                  'SUPER ADMIN PORTAL',
                  style: AppTextStyles.label(context).copyWith(
                    color: Colors.white60,
                    fontSize: 9,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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
                    // Mascot Animation (Reduced size for focus)
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: const RiveAnimation.asset(
                        'assets/rive/antfly.riv',
                        artboard: 'New Artboard',
                        animations: ['idle'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    AppSpacing.verticalL,
                    
                    // Glassmorphism Login Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? AppSpacing.l : AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign In',
                                  style: AppTextStyles.heading2(context).copyWith(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                AppSpacing.verticalS,
                                Text(
                                  'Secure access to curriculum management',
                                  style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                                AppSpacing.verticalL,
                                
                                // Username Field
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Email Address',
                                  hint: 'admin@iread.com',
                                  icon: Icons.alternate_email_rounded,
                                  validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                                ),
                                AppSpacing.verticalM,
                                
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
                                      color: Colors.white38,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                                ),
                                
                                if (_errorMessage != null) ...[
                                  AppSpacing.verticalM,
                                  Container(
                                    padding: AppSpacing.edgeInsetsM,
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
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
                                
                                AppSpacing.verticalL,
                                
                                Hero(
                                  tag: 'login_button',
                                  child: CustomButton(
                                    text: 'SIGN IN TO DASHBOARD',
                                    onPressed: _isLoading ? null : _login,
                                    isLoading: _isLoading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    AppSpacing.verticalL,
                    Text(
                      '© 2026 iRead Education — Platform Control',
                      style: AppTextStyles.bodySmall(context).copyWith(color: Colors.white38, fontSize: 10),
                    ),
                    AppSpacing.verticalS,
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://iread-web1.vercel.app/')),
                      icon: const Icon(Icons.public_rounded, size: 14, color: AppColors.primary),
                      label: Text(
                        'Visit Official Website', 
                        style: AppTextStyles.label(context).copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    AppSpacing.verticalM,
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
          child: Text(label, style: AppTextStyles.label(context).copyWith(color: Colors.white70, fontSize: 11)),
        ),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white24),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorStyle: AppTextStyles.bodySmall(context).copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

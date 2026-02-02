import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/routes/route_names.dart';

/// Teacher login screen with PIN protection
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = '1234'; // Default PIN
  String? _errorMessage;

  void _login() {
    if (_pinController.text == _correctPin) {
      context.pushReplacement(RouteNames.teacherEditor);
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
      _pinController.clear();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Background Pattern (Upper)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/upper_pattern.png',
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textDark,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      Text(
                        'Teacher Access',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balancing back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Redesigned Header with Illustration
                          Container(
                            height: 220,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/ui/teacher_students.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Magandang Buhay!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Teacher Mode Login',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Enter Security PIN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: _pinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  autofocus: true,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    letterSpacing: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '••••',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade300,
                                      letterSpacing: 20,
                                    ),
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                  ),
                                  onSubmitted: (_) => _login(),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: 'CONTINUE',
                                  onPressed: _login,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Default PIN: 1234',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMedium.withValues(
                                alpha: 0.5,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
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
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iread/core/constants/app_colors.dart';
import 'package:iread/core/constants/app_text_styles.dart';
import 'package:iread/core/routes/route_names.dart';
import 'package:iread/core/widgets/custom_button.dart';
import 'package:iread/core/utils/responsive_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Tuklasin ang Kwento',
      description:
          'Magbasa at maglakbay sa mundo ng mga kwentong Pilipino sa loob ng ating munting Bahay Kubo.',
      image: 'assets/images/ui/onboarding_1.png',
    ),
    OnboardingData(
      title: 'Biyaheng Karunungan',
      description:
          'Sakay na sa ating makulay na Jeepney patungo sa masayang paglalakbay ng pagbabasa at pagtuklas.',
      image: 'assets/images/ui/onboarding_2.png',
    ),
    OnboardingData(
      title: 'Sama-sama sa Pag-aaral',
      description:
          'Ang pagkatuto ay mas masaya kapag kasama ang buong pamilya sa ilalim ng puno ng mangga.',
      image: 'assets/images/ui/onboarding_3.png',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go(RouteNames.languageSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle Filipino Pattern Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/upper_pattern.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // Bottom Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
                child: Column(
                  children: [
                    // Dot Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    if (_currentPage == _pages.length - 1)
                      CustomButton(
                        text: 'SIMULAN NA!',
                        onPressed: _completeOnboarding,
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              'LAKTAWAN',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: const CircleBorder(),
                              padding: EdgeInsets.all(16.w),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8.h,
      width: _currentPage == index ? 24.w : 8.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.w),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with responsive sizing
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth * 0.7;
              final finalSize = size > 300 ? 300.0 : size;

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30.w,
                      offset: Offset(0, 15.h),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    data.image,
                    height: finalSize,
                    width: finalSize,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

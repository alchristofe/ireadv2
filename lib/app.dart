import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/routes/app_router.dart';

import 'core/utils/responsive_utils.dart';

/// Main app widget
class IReadApp extends StatelessWidget {
  const IReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // Initialize responsive utils with the context
        Responsive.init(context);

        return MaterialApp.router(
          title: 'iRead - Learn Phonics',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.background,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.baloo2TextTheme(
              TextTheme(
                displayLarge: AppTextStyles.heading1,
                displayMedium: AppTextStyles.heading2,
                displaySmall: AppTextStyles.heading3,
                bodyLarge: AppTextStyles.bodyLarge,
                bodyMedium: AppTextStyles.bodyMedium,
                bodySmall: AppTextStyles.bodySmall,
              ),
            ),
          ),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

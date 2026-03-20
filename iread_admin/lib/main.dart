import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('DEBUG: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('DEBUG: Firebase initialized.');
  } catch (e) {
    print('DEBUG: Firebase error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iRead Super Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }

}

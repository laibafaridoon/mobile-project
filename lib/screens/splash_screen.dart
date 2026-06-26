import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
// Agar aapka AuthProvider kisi aur folder mein hai to us ka path check kar lijiye ga
// import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 3 seconds ka delay taake splash screen dikhe
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    /* NOTE: Abhi ke liye authentication bypass kar di hai taake direct 
      Onboarding screen khule. Jab aap saari screens check kar lein, 
      to aap nichay wala commented code un-comment kar sakte hain.
    */

    // Direct onboarding screen par bhejen:
    Navigator.pushReplacementNamed(context, AppRoutes.onboarding1);

    /* // Asli logic (Jab auth provider sahi chal rha ho):
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding1);
    }
    */
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).primaryColor, // Ya jo bhi aapka splash background color hai
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Aapka Hospital App ka Logo ya Icon
              const Icon(Icons.local_hospital, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              // App ka Naam
              const Text(
                'Smart Hospital',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

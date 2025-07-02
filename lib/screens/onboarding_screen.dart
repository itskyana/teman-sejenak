import 'package:flutter/material.dart';
import 'package:flutter_ins/screens/root_navigator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Material(
        color: Colors.transparent,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RootNavigation()),
      );
    });
  }

  Widget _socialIcon(BuildContext context, String assetPath) {
    return GestureDetector(
      onTap: () => _showLoading(context),
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight,
        ),
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero image
              SizedBox(
                height: size.height * 0.5,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/bg_hero_onboarding.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Teman Sejenak',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Temukan teman baru untuk berbagi momen dan menjelajah tempat seru bersama.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(color: AppColors.background),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Buat Akun Baru',
                          style: TextStyle(color: AppColors.secondaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'OR',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(context, 'assets/images/google.svg'),
                        const SizedBox(width: 24),
                        _socialIcon(context, 'assets/images/facebook.svg'),
                        const SizedBox(width: 24),
                        _socialIcon(context, 'assets/images/x.svg'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

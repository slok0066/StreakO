import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'SYSTEM INIT',
      description: 'Establish and monitor routines with maximum efficiency.',
      icon: Icons.track_changes,
    ),
    OnboardingPage(
      title: 'MAINTAIN LINK',
      description: 'Sustain uninterrupted streaks to optimize output.',
      icon: Icons.all_inclusive,
    ),
    OnboardingPage(
      title: 'ALERTS',
      description: 'Automated pings ensure routine compliance.',
      icon: Icons.notification_important,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '0${index + 1}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 1,
                          width: 48,
                          color: scheme.onSurface,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.description.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 1,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 12),
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? scheme.onSurface
                              : scheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_currentPage == _pages.length - 1) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(AppConstants.onboardingKey, true);

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: scheme.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'START'
                            : 'NEXT',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scheme.surface,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

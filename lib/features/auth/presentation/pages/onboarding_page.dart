import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _activePage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Elevate Your Trading",
      subtitle:
          "Join thousands of successful traders and master the art of the market with our professional tools.",
      icon: Icons.auto_graph_rounded,
      accentColor: const Color(0xFF7C4DFF),
      gradientColors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
    ),
    OnboardingData(
      title: "Expert Guidance",
      subtitle:
          "Learn from industry legends through interactive live sessions and personalized mentorship programs.",
      icon: Icons.school_rounded,
      accentColor: const Color(0xFF7C4DFF),
      gradientColors: [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
    ),
    OnboardingData(
      title: "Smart Strategies",
      subtitle:
          "Access real-time data and advanced analytics to make informed decisions and maximize your growth.",
      icon: Icons.account_balance_wallet_rounded,
      accentColor: const Color(0xFF7C4DFF),
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9173FF), // Purple background
      body: Stack(
        children: [
          // Background Spheres
          ...List.generate(5, (index) {
            return Positioned(
              top: (index * 150).toDouble(),
              left: index % 2 == 0 ? -30 : null,
              right: index % 2 != 0 ? -30 : null,
              child:
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 0,
                        end: 30,
                        duration: (2000 + index * 500).ms,
                      ),
            );
          }),

          SafeArea(
            child: Column(
              children: [
                // Top: Illustration
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _activePage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: _buildAnimatedCard(_pages[index], index),
                      );
                    },
                  ),
                ),

                // Bottom: Notched Card
                Expanded(
                  flex: 4,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _NotchedCardPainter()),
                      ),

                      // Floating plant ornament
                      Positioned(
                        top: -25,
                        right: 40,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF5252),
                          ),
                          child: const Icon(
                            Icons.park_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ).animate().scale(delay: 500.ms),
                      ),

                      Column(
                        children: [
                          const SizedBox(height: 30),
                          SmoothPageIndicator(
                            controller: _pageController,
                            count: _pages.length,
                            effect: const ExpandingDotsEffect(
                              dotWidth: 8,
                              dotHeight: 8,
                              expansionFactor: 3,
                              dotColor: Color(0xFFE0E0E0),
                              activeDotColor: Color(0xFF7C4DFF),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Text(
                                      _pages[_activePage].title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                      ),
                                    )
                                    .animate(key: ValueKey("t_$_activePage"))
                                    .fadeIn()
                                    .slideY(begin: 0.1, end: 0),
                                const SizedBox(height: 16),
                                Text(
                                      _pages[_activePage].subtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        height: 1.5,
                                      ),
                                    )
                                    .animate(key: ValueKey("s_$_activePage"))
                                    .fadeIn()
                                    .slideY(begin: 0.1, end: 0),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Navigation Button
                      Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (_activePage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: 500.ms,
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const LoginPage(),
                                ),
                              );
                            }
                          },
                          child:
                              Container(
                                    width: 75,
                                    height: 75,
                                    margin: const EdgeInsets.only(bottom: 25),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFFD1F5),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  )
                                  .animate(key: const ValueKey('btn'))
                                  .scale(curve: Curves.easeOutBack),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(OnboardingData data, int index) {
    return Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Stack(
              children: [
                // Animated Gradient Background
                Positioned.fill(
                  child:
                      Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: data.gradientColors,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .custom(
                            duration: 3.seconds,
                            builder: (context, value, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(value * 2 - 1, -1),
                                    end: Alignment(1 - value * 2, 1),
                                    colors: data.gradientColors,
                                  ),
                                ),
                              );
                            },
                          ),
                ),

                // Glassmorphism Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Floating Background Shapes
                ...List.generate(3, (i) {
                  return Positioned(
                    top: (i * 70).toDouble() + 40,
                    left: (i * 50).toDouble() + 30,
                    child:
                        Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .move(
                              begin: const Offset(0, 0),
                              end: Offset(15 * (i + 1).toDouble(), 15),
                              duration: 2.seconds,
                            ),
                  );
                }),

                // Centered Glow Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(data.icon, size: 80, color: Colors.white)
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack)
                        .shimmer(delay: 1.seconds, duration: 2.seconds),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(key: ValueKey("card_$index"))
        .slideX(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart)
        .fadeIn();
  }
}

class _NotchedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path();
    double r = 40;
    double nw = 110;

    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - r,
      size.height,
    );

    path.lineTo(size.width / 2 + nw / 2, size.height);
    path.arcToPoint(
      Offset(size.width / 2 - nw / 2, size.height),
      radius: const Radius.circular(55),
      clockwise: false,
    );

    path.lineTo(r, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    canvas.drawShadow(path, Colors.black, 15, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });
}

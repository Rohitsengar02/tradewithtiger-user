import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tradewithtiger/core/services/course_service.dart';
import 'package:tradewithtiger/features/course/presentation/pages/course_details_page.dart';
import 'package:tradewithtiger/features/course/presentation/pages/explore_courses_page.dart';
import 'package:tradewithtiger/core/services/home_page_settings_service.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/profile_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/login_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/signup_page.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _courseService = CourseService();
  final _settingsService = HomePageSettingsService();

  List<Map<String, dynamic>> _allCourses = [];
  Map<String, dynamic> _homeSettings = {};

  bool _isLoadingCourses = true;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _listenToCourses();
    _listenToSettings();
  }

  void _listenToSettings() {
    _settingsService.getHomePageSettings().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          _homeSettings = snapshot.data() as Map<String, dynamic>;
          _isLoadingSettings = false;
        });
      } else {
        setState(() => _isLoadingSettings = false);
      }
    });
  }

  void _listenToCourses() {
    _courseService.getCourses().listen((snapshot) {
      final courses = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      setState(() {
        _allCourses = courses;
        _isLoadingCourses = false;
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F172A), // Dark Background
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/trading_background.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.black),
              ),
            ),
          ),

          Column(
            children: [
              _buildNavBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      _buildFeaturesSection(),
                      _buildCoursesSection(),
                      _buildMentorsSection(),
                      _buildAboutSection(), // Added About Section
                      _buildBundlesSection(),
                      _buildLearningPathsSection(),
                      _buildPricingSection(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logoic.png", height: 60),
                const SizedBox(height: 10),
                Text(
                  "TRADE WITH TIGER",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem("HOME", Icons.home_rounded),
          _buildDrawerItem("SHOP", Icons.shopping_bag_outlined),
          _buildDrawerItem("ABOUT US", Icons.info_outline_rounded),
          _buildDrawerItem("CONTACT", Icons.contact_support_outlined),
          _buildDrawerItem("RULES", Icons.verified_outlined),
          _buildDrawerItem("FAQ", Icons.question_answer_outlined),
          _buildDrawerItem("NEWS", Icons.newspaper_outlined),
          const Divider(color: Colors.white24, height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildButton(
              "LOGIN",
              Colors.transparent,
              Colors.white,
              Icons.login,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildButton(
              "SIGNUP",
              Colors.redAccent,
              Colors.white,
              Icons.person_add,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (title == "SHOP") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreCoursesPage()),
          );
        }
      },
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      color: Colors.black.withValues(alpha: 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              // Hamburger for Mobile
              if (MediaQuery.of(context).size.width <= 900)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              if (MediaQuery.of(context).size.width <= 900)
                const SizedBox(width: 15),

              Image.asset("assets/images/logoic.png", height: 40),
              const SizedBox(width: 10),
              // Hide Text logo on very small screens if needed
              if (MediaQuery.of(context).size.width > 400)
                Text(
                  "TRADE WITH TIGER",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
            ],
          ),

          // Nav Links (Desktop Only)
          if (MediaQuery.of(context).size.width > 900)
            Row(
              children: [
                _buildNavLink("HOME"),
                _buildNavLink("SHOP"),
                _buildNavLink("ABOUT US"),
                _buildNavLink("CONTACT"),
                _buildNavLink("RULES"),
                _buildNavLink("FAQ"),
                _buildNavLink("NEWS"),
              ],
            ),

          // Actions
          if (MediaQuery.of(context).size.width > 900)
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: snapshot.data!.photoURL != null
                                ? NetworkImage(snapshot.data!.photoURL!)
                                : null,
                            child: snapshot.data!.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            snapshot.data!.displayName ?? "Profile",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ),
                      child: _buildButton(
                        "LOGIN",
                        Colors.transparent,
                        Colors.white,
                        Icons.login,
                        ignoreTap: true, // Handle tap here
                      ),
                    ),
                    const SizedBox(width: 15),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      ),
                      child: _buildButton(
                        "SIGNUP",
                        Colors.redAccent,
                        Colors.white,
                        Icons.person_add,
                        ignoreTap: true,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title) {
    return GestureDetector(
      onTap: () {
        if (title == "SHOP") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreCoursesPage()),
          );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color bgColor,
    Color textColor,
    IconData icon, {
    bool ignoreTap = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: bgColor == Colors.transparent
            ? Border.all(color: Colors.white24)
            : null,
        gradient: bgColor != Colors.transparent
            ? const LinearGradient(
                colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1100;

        return Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              left: -100,
              child:
                  Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.08),
                        ),
                      )
                      .animate()
                      .scale(duration: 2.seconds, curve: Curves.easeInOut)
                      .fadeIn(),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.05),
                ),
              ).animate().scale(delay: 500.ms, duration: 2.seconds).fadeIn(),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: isDesktop ? 100 : 50,
              ),
              child: isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildHeroContent(isDesktop: true),
                        ),
                        SizedBox(width: constraints.maxWidth * 0.05),
                        Expanded(
                          flex: 6,
                          child: _buildFightingVisual(height: 500),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeroContent(isDesktop: false),
                        const SizedBox(height: 60),
                        _buildFightingVisual(height: 300),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFightingVisual({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/heroimage1.png'),
          fit: BoxFit.contain,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack);
  }

  Widget _buildHeroContent({required bool isDesktop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                "Trusted by 50K+ Traders",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.5),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF93C5FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            "Master the Art of\nstock Trading",
            textAlign: isDesktop ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: isDesktop ? 72 : 48,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2), // Slight slide up
        const SizedBox(height: 24),
        Text(
          "Join the world's most disciplined community. Learn specific strategies, master risk management, and scale your portfolio with confidence.",
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade400,
            fontSize: isDesktop ? 18 : 16,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _buildHeroButton(
              context,
              "GET STARTED NOW",
              const Color(0xFF6366F1), // Indigo
              Colors.white,
              Icons.rocket_launch_rounded,
            ).animate().fadeIn(delay: 600.ms).scale(),
            _buildHeroButton(
              context,
              "VIEW COURSES",
              Colors.transparent,
              Colors.white,
              Icons.play_circle_outline_rounded,
            ).animate().fadeIn(delay: 700.ms).scale(),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroButton(
    BuildContext context,
    String text,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExploreCoursesPage()),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: bgColor == Colors.transparent
              ? Border.all(color: Colors.white24)
              : null,
          gradient: bgColor != Colors.transparent
              ? const LinearGradient(
                  colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 50),
      // Use Wrap for responsive stacking
      child: Center(
        child: Wrap(
          spacing: 30, // Horizontal space
          runSpacing: 30, // Vertical space
          alignment: WrapAlignment.center,
          children: [
            _buildFeatureCard(
              "100% Secure & Save",
              "We adhere to the highest security standards.",
              Icons.shield_moon_rounded,
              Colors.cyanAccent,
            ),
            _buildFeatureCard(
              "24/7 Support Center",
              "Whatever your question, we are here to help.",
              Icons.headset_mic_rounded,
              Colors.orangeAccent,
            ),
            _buildFeatureCard(
              "NO Hidden Charges",
              "Transparent pricing with no surprises.",
              Icons.money_off_csred_rounded,
              Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white.withValues(alpha: 0.03),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildAboutImage()),
                const SizedBox(width: 60),
                Expanded(child: _buildAboutContent()),
              ],
            )
          : Column(
              children: [
                _buildAboutImage(),
                const SizedBox(height: 50),
                _buildAboutContent(),
              ],
            ),
    );
  }

  Widget _buildAboutImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/about_hero.png'), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      // Fallback if image missing for placeholder
      child: const Center(
        child: Icon(Icons.trending_up, color: Colors.white24, size: 100),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Text(
            "MOTIVATION & DISCIPLINE",
            style: TextStyle(
              color: Colors.amber.shade300,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Master Your Mind,\nMaster The Market.",
          style: GoogleFonts.outfit(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Success in trading isn't just about strategy—it's about mindset. At Trade With Tiger, we don't just teach you how to read charts; we train you to think like the top 1% of traders. Discipline, patience, and emotional control are your greatest assets.",
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 18,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Column(
          children: [
            _buildAboutFeature("Emotional Control Mastery"),
            const SizedBox(height: 16),
            _buildAboutFeature("Risk Management Protocols"),
            const SizedBox(height: 16),
            _buildAboutFeature("Consistent Profitability Systems"),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2);
  }

  Widget _buildAboutFeature(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    // Responsive width: on small screens, take full width (minus padding) otherwise fixed
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : 350,
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    if (_isLoadingCourses) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      // Use max width constraint for large screens
      constraints: const BoxConstraints(maxWidth: 1600),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Explore Our Courses",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().moveY(begin: 20),

          const SizedBox(height: 16),

          Text(
            "Master trading with our expert-led courses",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 60),

          if (_allCourses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "No courses available at the moment.",
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            Wrap(
              spacing: 30,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: _allCourses.map((course) {
                return _buildCourseCard(course);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return _HoverableCourseCard(course: course);
  }

  Widget _buildMentorsSection() {
    if (_isLoadingSettings) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> mentors = List<Map<String, dynamic>>.from(
      _homeSettings['mentors'] ?? [],
    );

    if (mentors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      width: double.infinity,
      color: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          Text(
            "Top Mentors",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().moveY(begin: 20),
          const SizedBox(height: 16),
          Text(
            "Learn from the best in the industry",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 60),
          CarouselSlider(
            options: CarouselOptions(
              height: 420,
              viewportFraction: MediaQuery.of(context).size.width > 900
                  ? 0.22
                  : 0.85,
              initialPage: 0,
              enableInfiniteScroll:
                  mentors.length > 3 ||
                  MediaQuery.of(context).size.width <= 900,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              scrollDirection: Axis.horizontal,
            ),
            items: mentors.map((mentor) {
              return Builder(
                builder: (BuildContext context) {
                  return _buildMentorCard(mentor);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    String name = mentor['name'] ?? 'Mentor';
    String role = mentor['role'] ?? 'Expert';
    String imageUrl = mentor['imageUrl'] ?? '';

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                  ? NetworkImage(imageUrl)
                  : AssetImage(
                          imageUrl.isEmpty
                              ? 'assets/images/mentor_1.png'
                              : imageUrl,
                        )
                        as ImageProvider,
              backgroundColor: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              color: Colors.blueAccent.shade100,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 15),
              _buildSocialIcon(Icons.video_camera_back),
              const SizedBox(width: 15),
              _buildSocialIcon(Icons.link),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey, size: 18),
    );
  }

  Widget _buildBundlesSection() {
    if (_isLoadingCourses)
      return const SizedBox.shrink(); // Depend on courses now

    if (_allCourses.isEmpty) return const SizedBox.shrink();

    // Use a subset or all courses. Highlighting a few popular ones would be ideal,
    // but for now we'll show the fetched courses.
    final coursesToShow = _allCourses.take(8).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1600),
      child: Column(
        children: [
          Text(
            "Popular Courses",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().moveY(begin: 20),
          const SizedBox(height: 16),
          Text(
            "Trending courses chosen by our community",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 60),

          CarouselSlider(
            options: CarouselOptions(
              height: 520, // Increased height to prevent bottom overflow
              viewportFraction: MediaQuery.of(context).size.width > 900
                  ? 0.22
                  : 0.85,
              initialPage: 0,
              enableInfiniteScroll:
                  coursesToShow.length > 3 ||
                  MediaQuery.of(context).size.width <= 900,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.1,
              scrollDirection: Axis.horizontal,
            ),
            items: coursesToShow.map((course) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _HoverableCourseCard(course: course),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPathsSection() {
    if (_isLoadingSettings) return const SizedBox.shrink();
    final List<Map<String, dynamic>> paths = List<Map<String, dynamic>>.from(
      _homeSettings['learningPaths'] ?? [],
    );

    if (paths.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      width: double.infinity,
      color: Colors.black.withOpacity(0.3),
      child: Column(
        children: [
          Text(
            "Interactive Learning Paths",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().moveY(begin: 20),
          const SizedBox(height: 16),
          Text(
            "Structured roadmaps to guide your journey",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: paths.map((path) {
              return _buildPathCard(path);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPathCard(Map<String, dynamic> path) {
    final color = Color(path['color'] ?? 0xFF645AFF);
    final bgColor = Color(path['bgColor'] ?? 0x1A645AFF);
    final iconData = IconData(
      path['icon'] ?? Icons.star.codePoint,
      fontFamily: 'MaterialIcons',
    );

    // Responsive sizing
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : 300,
      constraints: const BoxConstraints(maxWidth: 300),
      height: 300, // Fixed height and width
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            path['name'] ?? 'Untitled',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            path['level'] ?? 'Beginner',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          // Start Path button removed
        ],
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildPricingSection() {
    if (_isLoadingSettings) return const SizedBox.shrink();
    final List<Map<String, dynamic>> tiers = List<Map<String, dynamic>>.from(
      _homeSettings['premiumTiers'] ?? [],
    );

    if (tiers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Simple, Transparent Pricing",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().moveY(begin: 20),
          const SizedBox(height: 16),
          Text(
            "Choose the plan that fits your trading goals",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: tiers.map((tier) {
              return _buildPricingCard(tier);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> tier) {
    final colorStart = Color(tier['colorStart'] ?? 0xFF6366F1);
    final colorEnd = Color(tier['colorEnd'] ?? 0xFF8B5CF6);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : 350,
      constraints: const BoxConstraints(maxWidth: 350),
      padding: const EdgeInsets.all(3), // Space for gradient border
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [colorStart, colorEnd.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorStart.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark background matching page
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: colorStart,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tier['name'] ?? 'Premium',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tier['desc'] ?? 'Unlock all features',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  tier['price'] ?? '₹999',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "/mo",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorStart, colorEnd]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colorStart.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Choose Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/images/logoic.png",
            height: 50,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 20),
          Text(
            "TRADE WITH TIGER",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "© 2024 TradeWithTiger. All rights reserved.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HoverableCourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  const _HoverableCourseCard({required this.course});

  @override
  State<_HoverableCourseCard> createState() => _HoverableCourseCardState();
}

class _HoverableCourseCardState extends State<_HoverableCourseCard> {
  bool _isHovered = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Pre-initialize video if available, but dont play yet
    // To save resources, we could also initialize only on hover.
    // For smoother experience, let's try init on hover or lazy init.
    // However, to show "video thumbnail" instantly on hover, it's better to ensure it's ready or load quickly.
    // Given potentially many cards, lazy load on hover is safer for memory.
  }

  void _initializeVideo() async {
    final videoUrl =
        widget.course['videoThumbnailUrl'] ?? widget.course['introVideoUrl'];
    if (videoUrl != null && _videoController == null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0); // Mute for preview
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          if (_isHovered) {
            _videoController!.play();
          }
        });
      }
    } else if (_videoController != null && _isHovered) {
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make course card responsive
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (event) {
        setState(() => _isHovered = true);
        _initializeVideo();
      },
      onExit: (event) {
        setState(() => _isHovered = false);
        _videoController?.pause();
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: widget.course),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isMobile ? double.infinity : 320,
          constraints: const BoxConstraints(
            maxWidth: 320,
          ), // Prevent too wide on tabs
          transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.blueAccent.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: _isHovered ? 30 : 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? Colors.blueAccent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Area (Square 1:1)
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Base Image
                    _buildThumbnailImage(),

                    // Video Overlay (when hovered)
                    if (_isHovered &&
                        _isVideoInitialized &&
                        _videoController != null &&
                        _videoController!.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),

                    // Badges
                    if ((widget.course['badges'] as List?)?.isNotEmpty ?? false)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (widget.course['badges'] as List).first
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course['level']?.toString().toUpperCase() ??
                          "ALL LEVELS",
                      style: TextStyle(
                        color: Colors.blueAccent.shade100,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.course['title'] ?? "Untitled Course",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${(widget.course['curriculum'] as List?)?.length ?? 0} Modules",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Start Learning",
                          style: TextStyle(
                            color: Colors.redAccent.shade100,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.redAccent.shade100,
                        ),
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

  Widget _buildThumbnailImage() {
    String? thumbnailUrl = widget.course['thumbnailUrl'];
    if (thumbnailUrl != null && thumbnailUrl.startsWith('http')) {
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Image.asset(
          'assets/images/course_trading_bull.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        thumbnailUrl ?? 'assets/images/course_trading_bull.png',
        fit: BoxFit.cover,
      );
    }
  }
}

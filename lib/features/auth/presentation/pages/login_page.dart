import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tradewithtiger/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:tradewithtiger/core/services/video_preload_service.dart';
import 'package:tradewithtiger/features/home/presentation/pages/home_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/signup_page.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final String _videoUrl =
      "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/1TsYn8t17L3k342Yuh.mp4?Expires=1767369890&Signature=OxCEPQtNva8RcjF-0k3LTHgrgaayRP16mfub2BwO67HMXLkJjp4M--o-G1UpQcRsWSHiQwkc2-2vz43zmrRsngwzVHCXirQEZ4rWnqdgQ0SocV~RM34-dy6PwrIYJBTGqKNUzoim2uGYXXgpRz7L6H7nxop1Kk-yBRsmGGCbnN~zO7FM6sx2i8DXVdbqjE0obE-RyyIKPWUgyujsoB2UZfxXEHzPhzPBMO21i4ZPyiKkp-bUwKgrLerHw~hZmyzpqisebLvU5kpd7iyufQXTmYyTwwN8lUWAVHQDe7Tld1p4AleYVZaDv0mSBo5FLjInEZqgOK-5-Gyz8R2h7I-PMg__&Key-Pair-Id=K2YEDJLVZ3XRI";

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _videoController = VideoPreloadService().getController(_videoUrl);
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() => _isVideoInitialized = true);
      _videoController!.play();
      _videoController!.setLooping(true);
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
      _videoController!.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isVideoInitialized = true);
        _videoController!.play();
        _videoController!.setLooping(true);
      });
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout();
          }
          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side: Animated Gradient & Hero Content
        Expanded(
          flex: 6,
          child:
              Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated Shapes Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 50,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Hero Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.trending_up,
                                size: 80,
                                color: Colors.white,
                              ).animate().scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Trade With Tiger",
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ).animate().fadeIn().slideY(begin: 0.3),
                              const SizedBox(height: 16),
                              Text(
                                "Master the markets with confidence.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                              const SizedBox(height: 48),
                              // Sign Up Call to Action on Left
                              Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "New Here?",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SignUpPage(),
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text(
                                            "CREATE ACCOUNT",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 400.ms)
                                  .slideY(begin: 0.2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .tint(
                    color: const Color(0xFF4F46E5).withOpacity(0.2),
                    duration: 3.seconds,
                  ),
        ),

        // Right Side: Login Form (Credentials)
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1E2D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please enter your details.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 48),

                    // Google Login Button (Main Credential)
                    _buildGoogleButton(),

                    const SizedBox(height: 32),
                    // Removed the Footer Link from here as it's now on the left
                  ],
                ).animate().fadeIn().slideX(begin: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      top: true,
      child: Stack(
        children: [
          // Video Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFA5A6F6).withValues(alpha: 0.1),
              ),
              child: _isVideoInitialized && _videoController != null
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
            ),
          ),

          // Main Content Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.74,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                        const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1E2D),
                                letterSpacing: -0.5,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "Login to continue your trading journey.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                  const Spacer(),

                  // Google Login Button
                  _buildGoogleButton()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  _buildFooterLink().animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Floating Back Button
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E1E2D),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Center(
      child: InkWell(
        onTap: () async {
          final credential = await AuthService().signInWithGoogle();
          if (credential != null &&
              credential.user != null &&
              context.mounted) {
            final uid = credential.user!.uid;
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();

            if (context.mounted) {
              final isComplete = userDoc.data()?['isProfileComplete'] ?? false;

              if (isComplete) {
                if (kIsWeb && MediaQuery.of(context).size.width > 900) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebHomePage(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupPage(),
                  ),
                );
              }
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                height: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Login with Google",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E2D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            ),
            child: const Text(
              "Create Now",
              style: TextStyle(
                color: Color(0xFF7D83FF),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

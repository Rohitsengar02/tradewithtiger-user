import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tradewithtiger/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:video_player/video_player.dart';

import 'package:tradewithtiger/core/services/video_preload_service.dart';
import 'package:tradewithtiger/features/home/presentation/pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final String _videoUrl =
      "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/LHb56Hp6YU03x34WJ3.mp4?Expires=1767370514&Signature=DSBNuUrVLfbf6~HbBByYijAvwtYVLWhBkhurA7r2Rp2KzNDaWkaMoj1CI~nqr4MLfDpH23yzB20gGZVxHXJEqa0yh74c1R201yXMKRsKlnsbNa3Ca~BRCEpelENHShcztPs03yrMX0QouxkGa7yGPURYFYHbcV8roiolCFuEZsHFrbZn2Dyao6QSvC1b8HdK-AOyxZtDs48b-vgPWaB2lmojVUyPjMJ-ijhsEwZphSVj4awQnD~P0B~JANWYjazwUVWmiuXExrxUV-WfKVtiCI93zN~oSFdudIfe0ba2xC9QZWP3U1TiiMWlTqEDYapveanQbpZGSnhhFlC2ahiA6g__&Key-Pair-Id=K2YEDJLVZ3XRI";

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
          child: Container(
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rocket_launch_rounded,
                        size: 80,
                        color: Colors.white,
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Join the Revolution",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.3),
                      const SizedBox(height: 16),
                      Text(
                        "Start your journey to financial freedom.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 48),
                      // Login Call to Action on Left
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
                              "Already a Member?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                ); // Go back to login if came from there, or push login
                                // Just in case, explicit push replacement
                                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                // Actually better to just pop if we assume a stack, but safer to pushReplacement to swap pages.
                                // However, Login is usually the 'base' or they are siblings.
                                // Let's use pushReplacement to be safe and consistent with login page logic.
                                // But wait, LoginPage is likely imported. Let's check imports.
                                // SignUpPage imports LoginPage? No, LoginPage imports SignUpPage.
                                // SignUpPage usually navigated TO from Login. So pop is often enough.
                                // But if user landed here directly?
                                // Let's try pop first, if can't pop, push login.
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  // We need to import LoginPage if we do this.
                                  // Let's assume standard flow for now or use named routes if available,
                                  // but avoiding new dependencies.
                                  // I'll stick to pop for "Back" behavior or just simple Pop since usually Login -> Signup.
                                  // BUT, user might want to switch.
                                  // Let's just use pop.
                                  Navigator.pop(context);
                                }
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
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "LOGIN HERE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).tint(color: const Color(0xFFEC4899).withOpacity(0.2), duration: 3.seconds),
        ),

        // Right Side: Sign Up Form
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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1E2D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Join the community today.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 48),

                    _buildGoogleButton(),

                    const SizedBox(height: 32),
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
            height: size.height * 0.40,
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
                              "Create Account",
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
                    "Join us to start learning trading strategies today.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                  const Spacer(),

                  // Google Sign Up Button
                  _buildGoogleButton()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),
                  _buildFooterLink().animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),
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
                "Sign Up with Google",
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
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: "Login",
                style: TextStyle(
                  color: Color(0xFF7D83FF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

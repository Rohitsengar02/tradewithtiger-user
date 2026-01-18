import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tradewithtiger/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:tradewithtiger/core/services/video_preload_service.dart';
import 'package:tradewithtiger/features/home/presentation/pages/home_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/signup_page.dart';
import 'package:video_player/video_player.dart';

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
    return Stack(
      children: [
        // Fullscreen Video Background
        Positioned.fill(
          child: _isVideoInitialized && _videoController != null
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Container(color: const Color(0xFFA5A6F6).withOpacity(0.1)),
        ),
        // Overlay to dim video with Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),

        // Centered Login Card
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 16),
                const Text(
                  "Login to continue your trading journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildGoogleButton(),
                const SizedBox(height: 24),
                _buildFooterLink(),
              ],
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 30,
          left: 30,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
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

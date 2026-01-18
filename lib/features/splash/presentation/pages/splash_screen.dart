import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tradewithtiger/core/services/video_preload_service.dart';
import 'package:flutter/foundation.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/login_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/onboarding_page.dart';
import 'package:tradewithtiger/features/home/presentation/pages/home_page.dart';
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  final List<String> _videoUrls = [
    "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/5zRtUXq9742k5c39XN.mp4?Expires=1767367334&Signature=meE3MSlyIzhHUdav5mVYEj1xBqvXx3IAi0uhxpc~iH1qJRVhYg3VYEWJ3kBa19-NwQLPs-MzHJLMpQ2eEFOyDxp6U1pTWSqziXvopoVZUHr~qIcCEf5hPTxxDYTqxIP35K-fq7MJ172SqObESt-Zs93jtwOhRMnA6KlDxUMvWRsGTPqSKNBHWGyjJbyg5RM7U1K-LABVFVfRttZ5yYJXX1NWru6zXy63HA4mWkdQ3618zn2lXn5DhuXivisPGHRryUlm4I~f0S6YBTMrF9LiQZvaHAZMuUSjFZSiHPFMYcBwXiHxL~YP-6ahIedZXZU1zgRuaIH6zmb5YA~nzANSZA__&Key-Pair-Id=K2YEDJLVZ3XRI",
    "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/lDEy8pqRAH1W57d280.mp4?Expires=1767367586&Signature=pf6tm3jEWYlqCnhWbWPvneNV4Ytiep3jGTTT10wrrl1yyG6lxSYFLhCNV0rDr4GuzfWvS1UusN3xB4RK4YpAl5eQ61Sob2nMVS4fRapbneIY~aDpBDQobf9oPwKD2Bble~lo5y5nfr829v9ODCpx1Fdrg2dFkTzHuSXbKdILQIlDlqphPrqpXId55g062Q1amfduiOwMT6gaCnq7RHfdjXijfYQNniIqlf02yLGP16cDvEpuxRc6vzlaZ1SlrQpNnGVPuY67DTn9M9k7lPYKIMTfzX0tvSuoVR4l5vUbHYUmEc01iNFaN3yelvLoaYaVsWajk1CcE48LhZTSICaVgA__&Key-Pair-Id=K2YEDJLVZ3XRI",
    "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/6j2s4i7BG5nXLgB8b2.mp4?Expires=1767367626&Signature=eyx~lbtFwUdGbiJd4dIQ3XmDdCe8F12k0fJ2ra4EbrsOl2A4j8KdxDaBCd-Aj7YAcaD7h3ZfeysiY6XdnFtD-vDHfzH0ADqFoQ11KdO2jFY71ZNxSy~WK1fh1Et1vB76Ur35Qra504Bx07PlgjyxrcNheJwiVivsQJ3bgqbqeP0zJP~uFeiwMuvcVSM1jJqbUxrZQ7F8X39VvAnVPXR1ZQsoqAvy-bqQLYTwEaHzjB4gFtKgmzT2BkkpL5~bunLvRv5hZx6ZViob~ZCQTiBZLWQxbuWm7A4GUJprFEBt0Y6kAV8F69RAffgeL5rwbcTS7EKLWHrCLBFUUvpBaDrcHw__&Key-Pair-Id=K2YEDJLVZ3XRI",
    "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/1TsYn8t17L3k342Yuh.mp4?Expires=1767369890&Signature=OxCEPQtNva8RcjF-0k3LTHgrgaayRP16mfub2BwO67HMXLkJjp4M--o-G1UpQcRsWSHiQwkc2-2vz43zmrRsngwzVHCXirQEZ4rWnqdgQ0SocV~RM34-dy6PwrIYJBTGqKNUzoim2uGYXXgpRz7L6H7nxop1Kk-yBRsmGGCbnN~zO7FM6sx2i8DXVdbqjE0obE-RyyIKPWUgyujsoB2UZfxXEHzPhzPBMO21i4ZPyiKkp-bUwKgrLerHw~hZmyzpqisebLvU5kpd7iyufQXTmYyTwwN8lUWAVHQDe7Tld1p4AleYVZaDv0mSBo5FLjInEZqgOK-5-Gyz8R2h7I-PMg__&Key-Pair-Id=K2YEDJLVZ3XRI",
    "https://d1jj76g3lut4fe.cloudfront.net/processed/thumb/LHb56Hp6YU03x34WJ3.mp4?Expires=1767370514&Signature=DSBNuUrVLfbf6~HbBByYijAvwtYVLWhBkhurA7r2Rp2KzNDaWkaMoj1CI~nqr4MLfDpH23yzB20gGZVxHXJEqa0yh74c1R201yXMKRsKlnsbNa3Ca~BRCEpelENHShcztPs03yrMX0QouxkGa7yGPURYFYHbcV8roiolCFuEZsHFrbZn2Dyao6QSvC1b8HdK-AOyxZtDs48b-vgPWaB2lmojVUyPjMJ-ijhsEwZphSVj4awQnD~P0B~JANWYjazwUVWmiuXExrxUV-WfKVtiCI93zN~oSFdudIfe0ba2xC9QZWP3U1TiiMWlTqEDYapveanQbpZGSnhhFlC2ahiA6g__&Key-Pair-Id=K2YEDJLVZ3XRI",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767287289/Pinedia.com_1767287168011_xywhlu.mp4",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767287790/Pinedia.com_1767287761056_qbrpft.mp4",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767288110/Pinedia.com_1767288101857_vszukd.mp4",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767288159/Pinedia.com_1767288151661_omefzc.mp4",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767288289/Pinedia.com_1767288282233_o4gca5.mp4",
    "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767289841/Pinedia.com_1767289825948_hldqfw.mp4",
  ];

  _navigateToHome() async {
    // Preload videos while showing splash screen
    await VideoPreloadService().preloadVideos(_videoUrls);

    // Ensure we show splash for at least some time
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check if running on web or large screen (desktop size)
    // The user requested to show onboarding only in "app" (mobile) and not on web or desktop screen size.
    final bool isDesktopScreen = MediaQuery.of(context).size.width > 800;

    if (kIsWeb || isDesktopScreen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation: Falling Effect
            Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A89FF).withValues(alpha: 0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/logoic.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate()
                .slideY(
                  begin: -2,
                  end: 0,
                  duration: 1200.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 800.ms)
                .then()
                .shimmer(
                  duration: 1500.ms,
                  color: Colors.blue.withValues(alpha: 0.2),
                ),

            const SizedBox(height: 48),

            // Text Animation
            Column(
              children: [
                const Text(
                      "TradeWithTiger",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -1.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                const Text(
                      "Master the Market, Empower Your Future",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1300.ms, duration: 600.ms)
                    .slideY(begin: 0.5, end: 0),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

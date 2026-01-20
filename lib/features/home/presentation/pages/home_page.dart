import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:tradewithtiger/core/theme/app_theme.dart';
import 'package:tradewithtiger/features/course/presentation/pages/course_details_page.dart';
// ExploreCoursesPage import removed
// MyLearningPage, CommunityFeedPage, ProfilePage imports removed as they are no longer in IndexedStack
import 'package:shimmer/shimmer.dart';
import 'package:tradewithtiger/core/services/home_page_settings_service.dart';
import 'package:tradewithtiger/core/services/course_service.dart';
import 'package:tradewithtiger/main.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_mobile_bottom_bar.dart'; // Added Import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  // _activeNavIndex removed as we don't use tabs anymore
  int _currentCarouselIndex = 0;
  bool _isMuted = true;
  late ScrollController _scrollController;
  bool _isHeaderVisible = true;
  bool _isPageOnTop = true;

  final _settingsService = HomePageSettingsService();
  final _courseService = CourseService();
  Map<String, dynamic> _homeSettings = {};
  List<Map<String, dynamic>> _allCourses = [];
  bool _isLoadingSettings = true;
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _listenToSettings();
    _listenToCourses();
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

  void _listenToSettings() {
    _settingsService.getHomePageSettings().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            _homeSettings = snapshot.data() as Map<String, dynamic>;
            _isLoadingSettings = false;
          });
        } else {
          // Document doesn't exist, use defaults
          setState(() {
            _homeSettings = {};
            _isLoadingSettings = false;
          });
        }
      },
      onError: (e) {
        debugPrint("Error loading home settings: $e");
        // Prevent infinite loading on error (e.g. permission denied)
        setState(() {
          _homeSettings = {};
          _isLoadingSettings = false;
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPushNext() {
    setState(() => _isPageOnTop = false);
  }

  @override
  void didPopNext() {
    setState(() => _isPageOnTop = true);
  }

  void _handleScroll() {
    final bool isVisible = _scrollController.offset < 200;
    if (isVisible != _isHeaderVisible) {
      setState(() {
        _isHeaderVisible = isVisible;
        if (isVisible) {
          _isMuted = true; // Force mute when header is visible
        }
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // Removed IndexedStack, just show Home Content
        body: _buildHomeContent(),
        // New Web-Style Bottom Bar
        bottomNavigationBar: const WebMobileBottomBar(currentRoute: "HOME"),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoadingSettings || _isLoadingCourses) {
      return _buildSkeleton();
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySearchBarDelegate(child: _buildCategoriesCarousel()),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTrendySection(),
              const SizedBox(height: 32),
              _buildSectionTitle("Top Mentors"),
              _buildMentorsSection(),
              const SizedBox(height: 32),
              _buildSectionTitle("Popular bundles"),
              _buildBundlesSection(),
              const SizedBox(height: 32),
              _buildSectionTitle("Interactive Learning Path"),
              _buildLearningPath(),
              const SizedBox(height: 32),
              _buildSectionTitle("Premium Member Tiers"),
              _buildSubscriptionTiers(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesCarousel() {
    final categories = [
      {
        "name": "Technical",
        "icon": Icons.analytics_rounded,
        "color": const Color(0xFF6366F1),
      },
      {
        "name": "Options",
        "icon": Icons.pie_chart_rounded,
        "color": const Color(0xFF8B5CF6),
      },
      {
        "name": "Futures",
        "icon": Icons.trending_up_rounded,
        "color": const Color(0xFFEC4899),
      },
      {
        "name": "Psychology",
        "icon": Icons.psychology_rounded,
        "color": const Color(0xFFF59E0B),
      },
      {
        "name": "Crypto",
        "icon": Icons.currency_bitcoin_rounded,
        "color": const Color(0xFF10B981),
      },
      {
        "name": "Risk",
        "icon": Icons.security_rounded,
        "color": const Color(0xFFEF4444),
      },
    ];

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final color = cat['color'] as Color;

          return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          cat['icon'] as IconData,
                          color: color,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOut,
              );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Skeleton
            Container(
              height: 240 + topPadding,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Search Bar & Categories Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Carousel Skeleton
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Mentors Section Skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(width: 150, height: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(left: 24),
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String headerVideoUrl =
        _homeSettings['headerVideoUrl'] ??
        "https://res.cloudinary.com/ds1wiqrdb/video/upload/v1767289841/Pinedia.com_1767289825948_hldqfw.mp4";

    final String title =
        _homeSettings['headerTitle'] ?? "Let's find your\nbest course!";
    final String subtitle =
        _homeSettings['headerSubtitle'] ?? "Hey Chou Tzuyu !";

    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 240 + topPadding,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Infinite Muted Background Video
          Positioned.fill(
            child: _HeaderVideoBackground(
              videoUrl: headerVideoUrl,
              shouldPlay: _isHeaderVisible && _isPageOnTop,
            ),
          ),

          // Dark Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20 + topPadding, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitle.replaceAll('\\n', '\n'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Text(
                        title.replaceAll('\\n', '\n'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/images/mentor_1.png"),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendySection() {
    if (_allCourses.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No courses available yet")),
      );
    }

    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
    ];

    return Column(
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24)),
        const SizedBox(height: 24),
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 0.82,
            enlargeCenterPage: true,
            autoPlay: false,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: _allCourses.asMap().entries.map((entry) {
            final index = entry.key;
            final course = entry.value;
            final bool isCenter = index == _currentCarouselIndex;

            final curriculumRaw = course['curriculum'];
            final int modulesCount = (curriculumRaw is List)
                ? curriculumRaw.length
                : 0;
            final List<String> badges = List<String>.from(
              course['badges'] ?? [],
            );

            // Use videoThumbnailUrl if available (it's often a short preview MP4)
            // otherwise fallback to introVideoUrl
            final String? previewVideo =
                course['videoThumbnailUrl'] ?? course['introVideoUrl'];

            return _buildTrendyCarouselCard(
              course, // Pass the full course object
              colors[index % colors.length],
              course['thumbnailUrl'],
              course['videoThumbnailUrl'],
              course['title'] ?? 'Untitled',
              course['level'] ?? 'All Levels',
              modulesCount,
              badges,
              "12.4k", // Students fallback
              previewVideo,
              isCenter,
              _isMuted,
              _isPageOnTop,
            );
          }).toList(),
        ),
        if (!_isHeaderVisible) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isMuted = !_isMuted),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMuted ? "Unmute" : "Mute",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(),
        ],
      ],
    );
  }

  Widget _buildTrendyCarouselCard(
    Map<String, dynamic> courseData, // Added full course data
    Color color,
    String? thumbnailUrl,
    String? videoThumbnailUrl,
    String title,
    String level,
    int modulesCount,
    List<String> badges,
    String students,
    String? videoUrl,
    bool isCenter,
    bool isMuted,
    bool isVisible,
  ) {
    // Determine the image to show as fallback
    Widget backgroundPlaceholder;
    if (thumbnailUrl != null && thumbnailUrl.startsWith('http')) {
      backgroundPlaceholder = Image.network(thumbnailUrl, fit: BoxFit.cover);
    } else {
      backgroundPlaceholder = Image.asset(
        thumbnailUrl ?? 'assets/images/course_trading_bull.png',
        fit: BoxFit.cover,
      );
    }
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(
              course: courseData, // Pass the full course object
            ),
          ),
        );
      },
      child:
          Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Premium Layered Shadows
                  Positioned(
                    bottom: -15,
                    child: Container(
                      width: 180,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // Main Premium Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Stack(
                        children: [
                          // High-quality Image/Video Background
                          Positioned.fill(
                            child: videoUrl != null
                                ? _VideoHeroCard(
                                    videoUrl: videoUrl,
                                    isActive: isCenter && isVisible,
                                    isMuted: isMuted,
                                    videoThumbnailUrl: videoThumbnailUrl,
                                    fallbackAsset:
                                        thumbnailUrl ??
                                        'assets/images/course_trading_bull.png',
                                  )
                                : backgroundPlaceholder,
                          ),

                          // Enhanced Gradient Mesh
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.95),
                                    Colors.black.withValues(alpha: 0.5),
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Floating Category Badge (Top Left)
                          Positioned(
                            top: 24,
                            left: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.category_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    level.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Play Icon Indicator
                          if (videoUrl != null)
                            Center(
                              child:
                                  Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      )
                                      .animate(onPlay: (c) => c.repeat())
                                      .scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1.1, 1.1),
                                        duration: 1.seconds,
                                      ),
                            ),

                          // Course Details (Bottom Area)
                          Positioned(
                            bottom: 24,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (badges.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFACC15),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          badges.first.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.people_alt_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$students Students",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFD700),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "5.0",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      width: 1,
                                      height: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$modulesCount Modules",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Multimedia Badge (Top Right)
                          Positioned(
                            top: 24,
                            right: 24,
                            child: Icon(
                              videoUrl != null
                                  ? Icons.videocam_rounded
                                  : Icons.image_rounded,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                curve: Curves.easeOutBack,
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.textBlack,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "See All",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF101214), // Premium Dark
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Background Decorative Element
            Positioned(
              right: -20,
              top: -20,
              child:
                  Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00D1FF).withValues(alpha: 0.1),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        duration: 3.seconds,
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            "DAILY BOOSTER",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Tiger Vault 🐯",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Claim 500 Tiger Points instantly!",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          "assets/images/reward_chest_3d.png",
                          fit: BoxFit.contain,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        duration: 2.seconds,
                        begin: -5,
                        end: 5,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorsSection() {
    final List<Map<String, dynamic>> mentors = List<Map<String, dynamic>>.from(
      _homeSettings['mentors'] ?? [],
    );

    if (mentors.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No mentors added yet")),
      );
    }

    // Group mentors into pairs of 2
    List<List<Map<String, dynamic>>> mentorGroups = [];
    for (var i = 0; i < mentors.length; i += 2) {
      List<Map<String, dynamic>> group = [mentors[i]];
      if (i + 1 < mentors.length) {
        group.add(mentors[i + 1]);
      }
      mentorGroups.add(group);
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.92, // To show full row with slight spacing at ends
        enlargeCenterPage: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enableInfiniteScroll: mentorGroups.length > 1,
        padEnds: false,
      ),
      items: mentorGroups.map((group) {
        return Row(
          children:
              group.map((mentor) {
                return Expanded(child: _buildMentorCard(mentor));
              }).toList() +
              // If odd number, add an empty space to keep sizing consistent
              (group.length == 1 ? [const Expanded(child: SizedBox())] : []),
        );
      }).toList(),
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    final color = Color(mentor['color'] ?? 0xFF4A89FF);
    final String imageUrl = mentor['imageUrl'] ?? '';
    final bool isNetworkImage = imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Full Image
          Positioned.fill(
            child: isNetworkImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: color.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  )
                : Image.asset(
                    imageUrl.isEmpty ? "assets/images/mentor_1.png" : imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: color.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
          ),
          // Bottom Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          // Text Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  mentor['name'] ?? 'Mentor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mentor['role'] ?? 'Market Expert',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundlesSection() {
    final List<Map<String, dynamic>> bundles = List<Map<String, dynamic>>.from(
      _homeSettings['bundles'] ?? [],
    );

    if (bundles.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No bundles available")),
      );
    }

    return Container(
      height: 230,
      padding: const EdgeInsets.only(left: 7),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: bundles.length,
        itemBuilder: (context, index) {
          final bundle = bundles[index];
          final color = Color(bundle['color'] ?? 0xFF6366F1);
          final String imageUrl = bundle['imageUrl'] ?? '';
          final bool isNetworkImage = imageUrl.startsWith('http');
          final int courseCount = (bundle['courseIds'] as List?)?.length ?? 0;

          return Container(
                width: 380,
                margin: const EdgeInsets.only(right: 8, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Full background image
                    Positioned.fill(
                      child: isNetworkImage
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: color.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.apps,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            )
                          : Image.asset(
                              imageUrl.isEmpty
                                  ? "assets/images/bundle_package_3d.png"
                                  : imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: color.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.apps,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                    ),
                    // Premium Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.95),
                              color.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Content Overlay
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              "MASTER BUNDLE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            bundle['title'] ?? 'Trading Bundle',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$courseCount Premium Courses",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "LIFETIME ACCESS",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  bundle['price'] ?? '₹0',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 200).ms)
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95));
        },
      ),
    );
  }

  Widget _buildLearningPath() {
    final List<Map<String, dynamic>> paths = List<Map<String, dynamic>>.from(
      _homeSettings['learningPaths'] ?? [],
    );

    if (paths.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("Learning path coming soon")),
      );
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.only(left: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: paths.length,
        itemBuilder: (context, index) {
          final path = paths[index];
          final color = Color(path['color'] ?? 0xFF645AFF);
          final bgColor = Color(path['bgColor'] ?? 0x1A645AFF);
          final iconData = IconData(
            path['icon'] ?? Icons.star.codePoint,
            fontFamily: 'MaterialIcons',
          );

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: color, size: 22),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    path['name'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    path['level'] ?? 'Beginner',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: (index * 150).ms).fadeIn().slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildSubscriptionTiers() {
    final List<Map<String, dynamic>> tiers = List<Map<String, dynamic>>.from(
      _homeSettings['premiumTiers'] ?? [],
    );

    if (tiers.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("Memberships coming soon")),
      );
    }

    return Column(
      children: tiers.map((tier) {
        final colorStart = Color(tier['colorStart'] ?? 0xFF6366F1);
        final colorEnd = Color(tier['colorEnd'] ?? 0xFF8B5CF6);

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorStart.withValues(alpha: 0.1),
                      colorEnd.withValues(alpha: 0.15),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_rounded, color: colorStart, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier['name'] ?? 'Premium Tier',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier['desc'] ?? 'Exclusive benefits',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tier['price'] ?? '₹0',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF101214),
                    ),
                  ),
                  Text(
                    "Select",
                    style: TextStyle(
                      color: colorStart,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                duration: 1.seconds,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
              )
              .then()
              .scale(
                duration: 1.seconds,
                begin: const Offset(1.2, 1.2),
                end: const Offset(0.8, 0.8),
              ),
          const SizedBox(height: 24),
          const Text(
            "QUICK QUIZ CHALLENGE",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Double your Tiger Points today by completing the Daily Strategy Quiz!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Start Now",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoHeroCard extends StatefulWidget {
  final String videoUrl;
  final bool isActive;
  final bool isMuted;
  final String? videoThumbnailUrl;
  final String fallbackAsset;

  const _VideoHeroCard({
    required this.videoUrl,
    required this.isActive,
    required this.isMuted,
    this.videoThumbnailUrl,
    required this.fallbackAsset,
  });

  @override
  State<_VideoHeroCard> createState() => _VideoHeroCardState();
}

class _VideoHeroCardState extends State<_VideoHeroCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    // Lazy initialization: Only init if it's the active card to save decoders
    if (widget.isActive) {
      _performInitialization();
    }
  }

  Future<void> _performInitialization() async {
    if (_controller == null || _isInitialized) return;

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        _handlePlayback();
        _controller!.addListener(_playbackWatcher);
      }
    } catch (e) {
      debugPrint("Hero video init error: $e");
    }
  }

  void _playbackWatcher() {
    if (!mounted || _controller == null || !_isInitialized) return;

    // If it's active but not playing, force it to resume
    if (widget.isActive &&
        !_controller!.value.isPlaying &&
        !_controller!.value.isBuffering) {
      _controller!.play();
    }
  }

  void _handlePlayback() {
    if (_controller == null || !_isInitialized) return;

    _controller!.setVolume(widget.isMuted ? 0 : 1.0);
    _controller!.setLooping(true);

    if (widget.isActive) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  @override
  void didUpdateWidget(_VideoHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.isMuted != widget.isMuted) {
      if (widget.isActive && !_isInitialized) {
        _performInitialization();
      } else {
        _handlePlayback();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_playbackWatcher);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.hasError) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildPlaceholder(),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      );
    }

    if (!_isInitialized || _controller == null) {
      return _buildPlaceholder();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }

  Widget _buildPlaceholder() {
    // 1. Try to show the video thumbnail (MP4 thumbnail image if available)
    final bool isVideoThumbAnImage =
        widget.videoThumbnailUrl != null &&
        widget.videoThumbnailUrl!.startsWith('http') &&
        !widget.videoThumbnailUrl!.toLowerCase().endsWith('.mp4') &&
        !widget.videoThumbnailUrl!.toLowerCase().endsWith('.mov');

    if (isVideoThumbAnImage) {
      return Image.network(
        widget.videoThumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    // 2. Otherwise use the fallback image logic
    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    if (widget.fallbackAsset.startsWith('http')) {
      return Image.network(
        widget.fallbackAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/course_trading_bull.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      widget.fallbackAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/course_trading_bull.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _HeaderVideoBackground extends StatefulWidget {
  final String videoUrl;
  final bool shouldPlay;

  const _HeaderVideoBackground({
    required this.videoUrl,
    required this.shouldPlay,
  });

  @override
  State<_HeaderVideoBackground> createState() => _HeaderVideoBackgroundState();
}

class _HeaderVideoBackgroundState extends State<_HeaderVideoBackground>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  void _initController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        await _controller!.setVolume(0); // Always muted
        await _controller!.setLooping(true);
        await _controller!.play();
        _controller!.addListener(_checkPlaybackStatus);
      }
    } catch (e) {
      debugPrint("Header video init error: $e");
    }
  }

  void _checkPlaybackStatus() {
    if (!mounted || _controller == null) return;
    if (_controller!.value.isInitialized &&
        !_controller!.value.isPlaying &&
        !_controller!.value.isBuffering &&
        widget.shouldPlay) {
      _controller!.play();
    } else if (!widget.shouldPlay && _controller!.value.isPlaying) {
      _controller!.pause();
    }
  }

  @override
  void didUpdateWidget(_HeaderVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldPlay != widget.shouldPlay) {
      if (widget.shouldPlay) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _controller != null) {
      if (widget.shouldPlay) _controller!.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_checkPlaybackStatus);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(color: const Color(0xFF1A1A1E));
    }

    return SizedOverflowBox(
      size: Size.infinite,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  double get minExtent => 120;
  @override
  double get maxExtent => 120;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickySearchBarDelegate oldDelegate) {
    return false;
  }
}

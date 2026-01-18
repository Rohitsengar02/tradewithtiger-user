import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tradewithtiger/features/course/presentation/pages/course_video_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Map<String, dynamic> _course;
  bool _isLoading = true;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final courseId = widget.course['id'];
      if (courseId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _course = {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching course details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPaymentGateway() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentGatewaySheet(
        courseName: _course['title'] ?? "Masterclass",
        price: _course['price']?.toString() ?? "₹4,999",
        onPaymentSuccess: () {
          setState(() {
            _isEnrolled = true;
          });
          Navigator.pop(context);
          _showConfettiDialog();
        },
      ),
    );
  }

  void _showConfettiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Enrolled Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "You now have full access to ${_course['title']}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A89FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Start Learning"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseHero(context),
              _buildCourseMeta(),
              _buildAboutSection(),
              _buildLessonHeader(),
              _buildLessonList(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAction(context),
      ),
    );
  }

  Widget _buildCourseHero(BuildContext context) {
    // Prioritize image thumbnail for static header background
    final String? thumbnailUrl =
        (_course['thumbnailUrl'] as String?) ??
        (_course['videoThumbnailUrl'] as String?);
    final String title = _course['title'] as String? ?? "Untitled Course";
    final String instructor =
        _course['instructor'] as String? ?? "Tiger Mentor";

    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        image: thumbnailUrl != null && thumbnailUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(thumbnailUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              )
            : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBlurButton(
                        context,
                        HugeIcons.strokeRoundedArrowLeft01,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildBlurButton(
                        context,
                        HugeIcons.strokeRoundedFavourite,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_course['badges'] is List &&
                      (_course['badges'] as List).contains('Best Seller'))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "BEST SELLER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundImage: AssetImage(
                          "assets/images/mentor_1.png",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "by $instructor",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurButton(
    BuildContext context,
    List<List<dynamic>> icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: HugeIcon(icon: icon, color: Colors.white, size: 20),
      ),
    );
  }

  String _calculateTotalDuration() {
    final curriculum = _course['curriculum'] as List?;
    if (curriculum == null || curriculum.isEmpty) {
      return _course['duration'] as String? ?? "0m";
    }

    int totalSeconds = 0;
    for (var lesson in curriculum) {
      final durationStr = lesson['duration'] as String?;
      if (durationStr != null) {
        final parts = durationStr
            .split(':')
            .map((e) => int.tryParse(e) ?? 0)
            .toList();
        if (parts.length == 2) {
          totalSeconds += parts[0] * 60 + parts[1];
        } else if (parts.length == 3) {
          totalSeconds += parts[0] * 3600 + parts[1] * 60 + parts[2];
        }
      }
    }

    if (totalSeconds == 0) {
      return _course['duration'] as String? ?? "0m";
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  Widget _buildCourseMeta() {
    final duration = _calculateTotalDuration();
    final students = _course['students']?.toString() ?? "2k";
    final rating = _course['rating']?.toString() ?? "5.0";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetaItem(HugeIcons.strokeRoundedClock01, duration, "Duration"),
          _buildMetaItem(
            HugeIcons.strokeRoundedUserGroup,
            "$students+",
            "Students",
          ),
          _buildMetaItem(HugeIcons.strokeRoundedStar, rating, "Rating"),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildMetaItem(List<List<dynamic>> icon, String value, String label) {
    return Column(
      children: [
        HugeIcon(icon: icon, color: const Color(0xFF4A89FF), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final description =
        _course['description'] as String? ??
        "No description available for this course.";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About this course",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1.seconds);
  }

  Widget _buildLessonHeader() {
    final lessons = (_course['curriculum'] as List?)?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Lessons",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "$lessons Lessons",
            style: const TextStyle(
              color: Color(0xFF4A89FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<dynamic> rawLessons = (_course['curriculum'] as List?) ?? [];
    final lessons = rawLessons.map((e) => e as Map<String, dynamic>).toList();

    if (lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "Lessons coming soon...",
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        // Lock logic: Only the 1st lesson (index 0) is unlocked if not enrolled.
        // User explicitly requested "only 1st video is user can play".
        bool isLocked = !_isEnrolled && index != 0;

        // Ensure title is displayable
        final String title = lesson['title'] ?? "Untitled Lesson";
        final String duration = lesson['duration'] ?? "00:00";
        // Use lesson thumbnail from database, or fallback to course's video thumbnail
        final String? lessonThumb =
            lesson['thumbnail'] ?? _course['videoThumbnailUrl'];

        return GestureDetector(
          onTap: () {
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Enroll to unlock this lesson"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseVideoPage(
                    course: _course,
                    initialLessonIndex: index,
                    isEnrolled: _isEnrolled,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: (lessonThumb != null && lessonThumb.isNotEmpty)
                              ? NetworkImage(lessonThumb) as ImageProvider
                              : const AssetImage(
                                  "assets/images/course_bg_analysis.png",
                                ),
                          fit: BoxFit.cover,
                          colorFilter: isLocked
                              ? ColorFilter.mode(
                                  Colors.black.withOpacity(0.5),
                                  BlendMode.darken,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (isLocked)
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "PREVIEW",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isLocked
                              ? Colors.grey
                              : const Color(0xFF1A1A1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked ? "Premium Access • $duration" : duration,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 14,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (1200 + (index * 100)).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    if (_isEnrolled) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CourseVideoPage(course: _course, isEnrolled: true),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A89FF),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Continue Learning",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF4A89FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _showPaymentGateway,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A89FF), Color(0xFF907DFF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A89FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Enroll Now • ${_course['price'] ?? '₹4,999'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentGatewaySheet extends StatefulWidget {
  final String courseName;
  final String price;
  final VoidCallback onPaymentSuccess;

  const _PaymentGatewaySheet({
    required this.courseName,
    required this.price,
    required this.onPaymentSuccess,
  });

  @override
  State<_PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<_PaymentGatewaySheet> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: Wallet

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Tiger Checkout",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.courseName,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 32),

          _buildPaymentMethod(
            0,
            "Unified Payments Interface (UPI)",
            Icons.qr_code_rounded,
          ),
          const SizedBox(height: 16),
          _buildPaymentMethod(
            1,
            "Credit / Debit Card",
            Icons.credit_card_rounded,
          ),
          const SizedBox(height: 16),
          _buildPaymentMethod(2, "Digital Wallet", Icons.wallet_rounded),

          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Payable",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A89FF),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _processPayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int index, String name, IconData icon) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A89FF).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A89FF) : Colors.grey.shade100,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4A89FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4A89FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _processPayment() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4A89FF)),
              SizedBox(height: 24),
              Text(
                "Securing Transaction...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context); // Close loading
    widget.onPaymentSuccess();
  }
}

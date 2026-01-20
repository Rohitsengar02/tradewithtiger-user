import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_mobile_bottom_bar.dart';
import 'package:tradewithtiger/features/home/presentation/widgets/web_sidebar.dart';
import 'package:tradewithtiger/features/course/presentation/pages/course_details_page.dart';
import 'package:shimmer/shimmer.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  List<Map<String, dynamic>> _myCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyCourses();
  }

  void _fetchMyCourses() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrolled_courses')
        .snapshots() // Real-time updates
        .listen(
          (snapshot) {
            final courses = snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList();

            if (mounted) {
              setState(() {
                _myCourses = courses;
                _isLoading = false;
              });
            }
          },
          onError: (e) {
            debugPrint("Error fetching courses: $e");
            if (mounted) setState(() => _isLoading = false);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isMobile
          ? AppBar(
              title: const Text(
                "My Courses",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              automaticallyImplyLeading:
                  false, // Don't show back arrow if using bottom nav
            )
          : null,
      bottomNavigationBar: isMobile
          ? const WebMobileBottomBar(currentRoute: "MY COURSE")
          : null,
      body: isMobile ? _buildMobileBody() : _buildDesktopBody(),
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 250, child: WebSidebar(activePage: "My Course")),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Learning",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Track your progress and continue learning.",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 40),
                _isLoading ? _buildSkeletonGrid() : _buildCoursesGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_isLoading ? _buildSkeletonGrid() : _buildCoursesGrid()],
      ),
    );
  }

  Widget _buildCoursesGrid() {
    if (_myCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "No courses enrolled yet.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Browse our shop to get started!",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width <= 900;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: isMobile
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio:
                  0.60, // Adjusted for mobile to fit content (taller)
            )
          : const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
      itemCount: _myCourses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(_myCourses[index]);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final String title = course['title'] ?? 'Untitled Course';
    // Handle dynamic field names (sometimes thumbnailUrl, sometimes videoThumbnailUrl)
    final String? thumbnailUrl =
        course['thumbnailUrl'] ?? course['videoThumbnailUrl'];
    final double progress = (course['progress'] as num?)?.toDouble() ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensure child overflow is clipped
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 140, // Fixed height for image
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              image: thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(thumbnailUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/course_bg_analysis.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // Content
          Expanded(
            // Fill remaining space
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.3,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 5), // Spacing
                      // Could add category or instructor here if available
                    ],
                  ),

                  // Progress and Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Maybe a small icon or badge?
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          color: const Color(0xFF6366F1),
                          backgroundColor: Colors.grey.shade100,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailsPage(course: course),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}

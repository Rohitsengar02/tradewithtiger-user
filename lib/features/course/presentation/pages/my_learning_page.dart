import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tradewithtiger/features/course/presentation/pages/course_video_page.dart';

class MyLearningPage extends StatelessWidget {
  const MyLearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SliverHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressSection(),
                _buildSectionTitle("Resume Learning"),
                _buildCourseList(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAnalytics02,
                  color: Color(0xFF4A89FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Goal",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "85% Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              bool isCurrent = index == 3;
              bool isDone = index < 3;
              return Column(
                children: [
                  Container(
                    width: 35,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF4A89FF)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (isDone || isCurrent)
                          Container(
                            width: 35,
                            height: isCurrent ? 60 : 80,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : const Color(
                                      0xFF4A89FF,
                                    ).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        if (isDone)
                          const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1E),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            "View All",
            style: TextStyle(
              color: const Color(0xFF4A89FF),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    final List<Map<String, dynamic>> courses = [
      {
        "title": "Crypto Trading Kings",
        "mentor": "Alex Rivers",
        "progress": 0.75,
        "lessons": "18/24",
        "bg": "assets/images/course_bg_cryptoking.png",
        "color": const Color(0xFFF97316),
      },
      {
        "title": "Options Strategy Pro",
        "mentor": "Sarah Jenkins",
        "progress": 0.35,
        "lessons": "8/32",
        "bg": "assets/images/course_bg_optionspro.png",
        "color": const Color(0xFF6366F1),
      },
      {
        "title": "Price Action Mastery",
        "mentor": "Michael Chen",
        "progress": 0.15,
        "lessons": "4/40",
        "bg": "assets/images/course_bg_priceaction.png",
        "color": const Color(0xFFEC4899),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CourseVideoPage(course: course, isEnrolled: true),
              ),
            );
          },
          child: Container(
            height: 160,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: DecorationImage(
                image: AssetImage(course['bg'] as String),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: (course['color'] as Color).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
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
                            color: (course['color'] as Color).withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (course['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            "IN PROGRESS",
                            style: TextStyle(
                              color: course['color'] as Color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mentor: ${course['mentor']}",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: CircularProgressIndicator(
                              value: course['progress'] as double,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              color: course['color'] as Color,
                              strokeWidth: 6,
                            ),
                          ),
                          Text(
                            "${((course['progress'] as double) * 100).toInt()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course['lessons'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (200 * index).ms).slideX(begin: 0.1),
        );
      },
    );
  }
}

class _SliverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: const Color(
                    0xFF4A89FF,
                  ).withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -30,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(
                    0xFF907DFF,
                  ).withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Library",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1E),
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              "Resume where you left off",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedFilter,
                            color: Color(0xFF1A1A1E),
                            size: 20,
                          ),
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
}

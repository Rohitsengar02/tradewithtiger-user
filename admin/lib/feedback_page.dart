import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User Feedback",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "See what your students are saying",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildRatingSummaryCard(context, isDark),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildFeedbackItem(context, index, isDark);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRatingSummaryCard(BuildContext context, bool isDark) {
    if (MediaQuery.of(context).size.width < 800) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Text(
            "4.8",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  Icon(Icons.star_half_rounded, color: Colors.amber, size: 16),
                ],
              ),
              Text(
                "Average Rating",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(BuildContext context, int index, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage(
                  'assets/images/user_placeholder.png',
                ),
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Student Name ${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: i < 4
                            ? Colors.amber
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                      );
                    }),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "2 days ago",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "The course content was absolutely amazing! I learned so much about forex trading strategies. Highly recommended for beginners and experts alike.",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag("Course Content", isDark),
              const SizedBox(width: 8),
              _buildTag("Quality", isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
      ),
    );
  }
}

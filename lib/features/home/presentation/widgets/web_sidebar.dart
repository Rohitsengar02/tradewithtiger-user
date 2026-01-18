import 'package:flutter/material.dart';
import 'package:tradewithtiger/features/course/presentation/pages/explore_courses_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/profile_page.dart';
import 'package:tradewithtiger/features/course/presentation/pages/my_courses_page.dart';
import 'package:tradewithtiger/features/home/presentation/pages/web_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/login_page.dart';
import 'package:tradewithtiger/features/auth/presentation/pages/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradewithtiger/features/community/presentation/pages/community_feed_page.dart';

import 'package:tradewithtiger/features/profile/presentation/pages/legal/about_us_page.dart';
import 'package:tradewithtiger/features/profile/presentation/pages/legal/help_support_page.dart';

class WebSidebar extends StatelessWidget {
  final String activePage; // "Home", "Shop", "MyCourses", "Profile", "About"
  final VoidCallback? onLogout;

  const WebSidebar({super.key, required this.activePage, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/images/logoic.png", height: 32),
              const SizedBox(width: 12),
              const Text(
                "TIGER STORE",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildNavItem(
            context,
            "Home",
            Icons.home_rounded,
            const WebHomePage(),
          ),
          _buildNavItem(
            context,
            "Shop",
            Icons.store_rounded,
            const ExploreCoursesPage(),
          ),
          _buildNavItem(
            context,
            "My Course",
            Icons.book_rounded,
            const MyCoursesPage(),
          ),
          _buildNavItem(
            context,
            "Community",
            Icons.forum_rounded,
            const CommunityFeedPage(),
          ),
          _buildNavItem(
            context,
            "Profile",
            Icons.person_rounded,
            const ProfilePage(),
          ),
          _buildNavItem(
            context,
            "About",
            Icons.info_outline_rounded,
            const AboutUsPage(),
          ),

          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportPage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF6366F1),
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Need Help?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Contact our support team for assistance.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildUserProfile(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget? page,
  ) {
    final bool isActive = activePage == title;
    return InkWell(
      onTap: () {
        if (isActive) return;
        if (page != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else if (title == "Home") {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6366F1) : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0F172A)
                    : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  foregroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final name = userData?['displayName'] ?? user.displayName ?? "User";
        final photoUrl = userData?['photoURL'] ?? user.photoURL;
        final role = userData?['occupation'] ?? "Trader";

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: photoUrl != null && photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : const DecorationImage(
                          image: AssetImage("assets/images/avatar_ryan.png"),
                          fit: BoxFit.cover,
                        ),
                ),
                // Fallback icon if image fails completely (can't easily detect here without state, but container color helps)
                child: photoUrl == null || photoUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.length > 15 ? '${name.substring(0, 15)}...' : name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      role.length > 15 ? '${role.substring(0, 15)}...' : role,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted && onLogout != null) {
                    onLogout!();
                  } else if (context.mounted) {
                    // Default logout behavior if validation needed
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
